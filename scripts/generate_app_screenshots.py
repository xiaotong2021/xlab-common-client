#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
App Store 截图生成脚本
从 splashScreen 图片生成符合 App Store 要求的截图
"""

import os
import sys
import requests
from PIL import Image, ImageDraw, ImageFont
from io import BytesIO
from pathlib import Path


class ScreenshotGenerator:
    """App Store 截图生成器"""

    # App Store 截图尺寸要求
    # 参考：https://help.apple.com/app-store-connect/#/devd274dd925
    SCREENSHOT_SIZES = {
        # iPhone 截图尺寸
        'iPhone_6.7': (1290, 2796),  # iPhone 14 Pro Max, 15 Pro Max (必需)
        'iPhone_6.5': (1242, 2688),  # iPhone 11 Pro Max, XS Max
        'iPhone_5.5': (1242, 2208),  # iPhone 8 Plus, 7 Plus

        # iPad 截图尺寸
        'iPad_12.9_3rd': (2048, 2732),  # iPad Pro 12.9" (第3代及以后)
        'iPad_12.9_2nd': (2048, 2732),  # iPad Pro 12.9" (第2代)
    }

    # 设备类型映射到 App Store Connect API
    DEVICE_TYPE_MAPPING = {
        'iPhone_6.7': 'APP_IPHONE_67',
        'iPhone_6.5': 'APP_IPHONE_65',
        'iPhone_5.5': 'APP_IPHONE_55',
        'iPad_12.9_3rd': 'APP_IPAD_PRO_3GEN_129',
        'iPad_12.9_2nd': 'APP_IPAD_PRO_129',
    }

    def __init__(self, output_dir):
        """
        初始化截图生成器

        Args:
            output_dir: 输出目录
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def download_image(self, url):
        """
        下载图片

        Args:
            url: 图片 URL

        Returns:
            PIL Image 对象
        """
        print(f"📥 下载图片: {url}")

        if url.startswith('http://') or url.startswith('https://'):
            # 从 URL 下载
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            image = Image.open(BytesIO(response.content))
        else:
            # 从本地文件读取
            image = Image.open(url)

        # 转换为 RGBA 模式（支持透明度）
        if image.mode != 'RGBA':
            image = image.convert('RGBA')

        print(f"✅ 图片下载成功: {image.size[0]}x{image.size[1]}")
        return image

    def center_image_on_canvas(self, image, canvas_size, background_color=(255, 255, 255, 255)):
        """
        将图片居中放置在指定尺寸的画布上

        Args:
            image: 原始图片
            canvas_size: 画布尺寸 (width, height)
            background_color: 背景颜色 (R, G, B, A)

        Returns:
            新的图片
        """
        canvas_width, canvas_height = canvas_size

        # 创建白色背景画布
        canvas = Image.new('RGBA', canvas_size, background_color)

        # 计算缩放比例，保持宽高比
        img_width, img_height = image.size

        # 计算适应画布的缩放比例（留一些边距）
        margin_ratio = 0.9  # 使用画布的 90%，留 10% 作为边距
        scale_w = (canvas_width * margin_ratio) / img_width
        scale_h = (canvas_height * margin_ratio) / img_height
        scale = min(scale_w, scale_h)

        # 缩放图片
        new_width = int(img_width * scale)
        new_height = int(img_height * scale)
        resized_image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)

        # 计算居中位置
        x = (canvas_width - new_width) // 2
        y = (canvas_height - new_height) // 2

        # 将图片粘贴到画布中央
        canvas.paste(resized_image, (x, y), resized_image)

        return canvas

    def add_text_overlay(self, image, app_name, subtitle=None):
        """
        在截图上添加文字说明（可选）

        Args:
            image: 图片
            app_name: 应用名称
            subtitle: 副标题

        Returns:
            添加了文字的图片
        """
        # 创建副本，避免修改原图
        img_copy = image.copy()
        draw = ImageDraw.Draw(img_copy)

        width, height = img_copy.size

        # 尝试加载系统字体
        try:
            # macOS 系统字体
            title_font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", size=int(height * 0.04))
            subtitle_font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", size=int(height * 0.025))
        except:
            try:
                # Linux 系统字体
                title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size=int(height * 0.04))
                subtitle_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", size=int(height * 0.025))
            except:
                # 使用默认字体
                title_font = ImageFont.load_default()
                subtitle_font = ImageFont.load_default()

        # 在底部添加应用名称
        text_y = int(height * 0.92)

        # 使用 textbbox 获取文本边界框
        bbox = draw.textbbox((0, 0), app_name, font=title_font)
        text_width = bbox[2] - bbox[0]
        text_x = (width - text_width) // 2

        # 添加文字阴影效果
        shadow_color = (0, 0, 0, 128)
        draw.text((text_x + 2, text_y + 2), app_name, font=title_font, fill=shadow_color)

        # 添加文字
        text_color = (50, 50, 50, 255)
        draw.text((text_x, text_y), app_name, font=title_font, fill=text_color)

        # 添加副标题（如果有）
        if subtitle:
            subtitle_y = text_y + int(height * 0.05)
            bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
            subtitle_width = bbox[2] - bbox[0]
            subtitle_x = (width - subtitle_width) // 2

            draw.text((subtitle_x + 1, subtitle_y + 1), subtitle, font=subtitle_font, fill=shadow_color)
            draw.text((subtitle_x, subtitle_y), subtitle, font=subtitle_font, fill=(100, 100, 100, 255))

        return img_copy

    def generate_screenshot(self, source_image_url, device_type, app_name, subtitle=None,
                          add_text=False, background_color=(255, 255, 255, 255), index=1):
        """
        生成单个设备类型的截图

        Args:
            source_image_url: 源图片 URL 或路径
            device_type: 设备类型 (如 'iPhone_6.7')
            app_name: 应用名称
            subtitle: 副标题
            add_text: 是否添加文字
            background_color: 背景颜色
            index: 截图序号（用于生成多张截图时区分文件名）

        Returns:
            生成的截图文件路径
        """
        if device_type not in self.SCREENSHOT_SIZES:
            raise ValueError(f"不支持的设备类型: {device_type}")

        canvas_size = self.SCREENSHOT_SIZES[device_type]

        print(f"🎨 生成截图 #{index}: {device_type} ({canvas_size[0]}x{canvas_size[1]})")

        # 下载源图片
        source_image = self.download_image(source_image_url)

        # 将图片居中放置在画布上
        screenshot = self.center_image_on_canvas(source_image, canvas_size, background_color)

        # 可选：添加文字说明
        if add_text:
            screenshot = self.add_text_overlay(screenshot, app_name, subtitle)

        # 转换为 RGB（PNG 不需要透明通道）
        screenshot = screenshot.convert('RGB')

        # 保存截图
        output_filename = f"screenshot_{device_type}_{index}.png"
        output_path = self.output_dir / output_filename
        screenshot.save(output_path, 'PNG', quality=95)

        print(f"✅ 截图已保存: {output_path}")

        return str(output_path)

    def generate_all_screenshots(self, source_image_urls, app_name, subtitle=None,
                                 device_types=None, add_text=False):
        """
        生成所有设备类型的截图（支持多张源图片）

        Args:
            source_image_urls: 源图片 URL 或路径列表
            app_name: 应用名称
            subtitle: 副标题
            device_types: 要生成的设备类型列表，None 表示生成所有类型
            add_text: 是否添加文字

        Returns:
            生成的截图文件路径字典，格式: {'device_type': ['path1', 'path2', ...], ...}
        """
        if device_types is None:
            # 默认只生成必需的设备类型
            device_types = ['iPhone_6.7', 'iPad_12.9_3rd']

        screenshots = {device_type: [] for device_type in device_types}

        # 遍历每个源图片
        for index, source_image_url in enumerate(source_image_urls, start=1):
            print(f"\n📸 处理源图片 {index}/{len(source_image_urls)}: {source_image_url}")
            print("-" * 60)

            # 为每个设备类型生成截图
            for device_type in device_types:
                try:
                    screenshot_path = self.generate_screenshot(
                        source_image_url=source_image_url,
                        device_type=device_type,
                        app_name=app_name,
                        subtitle=subtitle,
                        add_text=add_text,
                        index=index
                    )
                    screenshots[device_type].append(screenshot_path)
                except Exception as e:
                    print(f"❌ 生成 {device_type} 截图 #{index} 失败: {e}")

        return screenshots


def read_config(config_file):
    """读取配置文件"""
    config = {}
    with open(config_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                config[key.strip()] = value.strip()
    return config


def check_if_screenshots_should_skip(config, workspace_path, app_name):
    """
    检查是否应该跳过截图生成
    
    Args:
        config: 配置字典
        workspace_path: 工作目录路径
        app_name: 应用名称
    
    Returns:
        (should_skip, reason): 是否跳过和原因
    """
    # 检查是否启用了 App Store Connect
    enable_asc = config.get('enableAppStoreConnect', 'false').lower() == 'true'
    
    # 检查是否启用了截图上传
    enable_screenshot_upload = config.get('enableScreenshotUpload', 'false').lower() == 'true'
    
    # 如果没有启用 App Store Connect 或截图上传，不需要检查
    if not enable_asc or not enable_screenshot_upload:
        return False, ""
    
    # 检查配置项：是否在已有截图时跳过
    skip_if_exists = config.get('skipScreenshotIfExists', 'true').lower() == 'true'
    
    if not skip_if_exists:
        return False, ""
    
    # 检查是否有 App Store Connect API 凭证
    api_key_id = os.environ.get('APP_STORE_API_KEY_ID')
    api_issuer_id = os.environ.get('APP_STORE_API_ISSUER_ID')
    
    if not api_key_id or not api_issuer_id:
        # 没有 API 凭证，无法检查，继续生成
        return False, ""
    
    api_key_path = os.path.expanduser('~/.appstoreconnect/private_keys/AuthKey_' + api_key_id + '.p8')
    
    if not os.path.exists(api_key_path):
        # API 密钥文件不存在，无法检查，继续生成
        return False, ""
    
    try:
        # 导入 API 客户端（延迟导入，避免在不需要时导入）
        import sys
        import os
        sys.path.insert(0, os.path.dirname(__file__))
        from app_store_connect import AppStoreConnectAPI
        
        # 初始化 API 客户端
        api = AppStoreConnectAPI(api_key_id, api_issuer_id, api_key_path)
        
        # 查找应用
        bundle_id = config.get('appId')
        app = api.find_app_by_bundle_id(bundle_id)
        
        if not app:
            # 应用不存在，需要生成截图
            return False, ""
        
        app_id = app['id']
        
        # 获取最新版本
        version_info = api.get_latest_app_version(app_id)
        
        if not version_info:
            # 没有版本，需要生成截图
            return False, ""
        
        version_id = version_info["id"]
        
        # 检查是否已有截图
        existing_screenshots = api.check_existing_screenshots(version_id)
        
        if existing_screenshots:
            # 已有截图，跳过生成
            reason = f"应用已有截图（{', '.join([f'{k}: {v}张' for k, v in existing_screenshots.items()])}）"
            return True, reason
        else:
            # 没有截图，需要生成
            return False, ""
    
    except Exception as e:
        # 检查失败，继续生成截图
        print(f"⚠️  检查现有截图失败: {e}")
        print(f"将继续生成截图...")
        return False, ""


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python generate_app_screenshots.py <workspace_path>")
        sys.exit(1)

    workspace_path = sys.argv[1]

    # 读取 build.app 获取应用名称
    build_app_path = os.path.join(workspace_path, "assets", "build.app")
    with open(build_app_path, 'r') as f:
        for line in f:
            if line.startswith('appName='):
                app_name = line.split('=')[1].strip()
                break

    # 读取应用配置
    config_file = os.path.join(workspace_path, "assets", app_name, "app.cfg")
    print(f"📖 读取配置文件: {config_file}")
    config = read_config(config_file)
    
    # 检查是否应该跳过截图生成
    should_skip, skip_reason = check_if_screenshots_should_skip(config, workspace_path, app_name)
    
    if should_skip:
        print()
        print("=" * 60)
        print("⏭️  跳过截图生成")
        print("=" * 60)
        print(f"原因: {skip_reason}")
        print()
        print("提示:")
        print("  • 如需重新生成截图，请在 App Store Connect 中删除现有截图")
        print("  • 或在 app.cfg 中设置 skipScreenshotIfExists=false")
        print("=" * 60)
        sys.exit(0)

    # 获取配置 - 支持多个截图源
    snapshot_screens = []
    for i in range(1, 11):  # 支持最多10张截图
        key = 'snapshotScreen' if i == 1 else f'snapshotScreen{i}'
        url = config.get(key)
        if url:
            snapshot_screens.append(url)

    if not snapshot_screens:
        print("❌ 错误: 配置文件中未找到 snapshotScreen")
        sys.exit(1)

    app_display_name = config.get('appDisplayName', app_name)
    app_subtitle = config.get('appSubtitle', '')
    add_text = config.get('screenshotAddText', 'false').lower() == 'true'

    # 获取要生成的设备类型
    device_types_str = config.get('screenshotDeviceTypesList', 'iPhone_6.5,iPad_12.9_3rd')
    device_types = [dt.strip() for dt in device_types_str.split(',')]

    # 创建输出目录
    output_dir = os.path.join(workspace_path, "screenshots", app_name)

    print()
    print("=" * 60)
    print("📱 App Store 截图生成")
    print("=" * 60)
    print(f"应用名称: {app_display_name}")
    print(f"源图片数量: {len(snapshot_screens)}")
    for i, url in enumerate(snapshot_screens, 1):
        print(f"  {i}. {url}")
    print(f"设备类型: {', '.join(device_types)}")
    print(f"输出目录: {output_dir}")
    print("=" * 60)
    print()

    # 生成截图
    generator = ScreenshotGenerator(output_dir)

    try:
        screenshots = generator.generate_all_screenshots(
            source_image_urls=snapshot_screens,
            app_name=app_display_name,
            subtitle=app_subtitle if app_subtitle else None,
            device_types=device_types,
            add_text=add_text
        )

        print()
        print("=" * 60)
        print("✅ 截图生成完成!")
        print("=" * 60)
        total_screenshots = sum(len(paths) for paths in screenshots.values())
        print(f"共生成 {total_screenshots} 张截图:")
        for device_type, paths in screenshots.items():
            print(f"  - {device_type}: {len(paths)} 张")
            for path in paths:
                print(f"    • {os.path.basename(path)}")
        print("=" * 60)

        # 保存截图路径列表（供后续上传使用）
        screenshots_json_path = os.path.join(output_dir, "screenshots.json")
        import json
        with open(screenshots_json_path, 'w') as f:
            json.dump(screenshots, f, indent=2)

        print(f"📝 截图列表已保存: {screenshots_json_path}")

    except Exception as e:
        print(f"❌ 截图生成失败: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()


