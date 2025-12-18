#!/usr/bin/env python3
"""
配置文件读取和替换脚本
用于从 assets 目录读取配置并替换项目文件中的占位符
"""

import os
import sys
import re
import shutil
import urllib.request
import urllib.parse
import tempfile
from pathlib import Path

try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("Warning: PIL/Pillow not available. Icon resizing will be skipped.")

try:
    from urllib.parse import urljoin, urlparse
    from html.parser import HTMLParser
    import ssl
except ImportError as e:
    print(f"Error: Required module not available: {e}")
    sys.exit(1)


class HTMLResourceParser(HTMLParser):
    """解析HTML并提取资源链接"""
    def __init__(self, base_url):
        super().__init__()
        self.base_url = base_url
        self.resources = []
        self.tags_attrs = {
            'link': ['href'],
            'script': ['src'],
            'img': ['src'],
            'source': ['src', 'srcset'],
            'video': ['src', 'poster'],
            'audio': ['src'],
            'embed': ['src'],
            'object': ['data'],
            'iframe': ['src']
        }
    
    def handle_starttag(self, tag, attrs):
        if tag in self.tags_attrs:
            attrs_dict = dict(attrs)
            for attr_name in self.tags_attrs[tag]:
                if attr_name in attrs_dict:
                    url = attrs_dict[attr_name]
                    if url and not url.startswith('data:') and not url.startswith('javascript:'):
                        # 处理srcset（可能包含多个URL）
                        if attr_name == 'srcset':
                            urls = [u.strip().split()[0] for u in url.split(',')]
                            for u in urls:
                                full_url = urljoin(self.base_url, u)
                                if full_url not in self.resources:
                                    self.resources.append(full_url)
                        else:
                            full_url = urljoin(self.base_url, url)
                            if full_url not in self.resources:
                                self.resources.append(full_url)


class ConfigBuilder:
    def __init__(self, workspace_root):
        self.workspace_root = Path(workspace_root)
        self.assets_dir = self.workspace_root / "assets"
        self.android_dir = self.workspace_root / "android"
        self.ios_dir = self.workspace_root / "ios"
        self.config = {}
        
    def read_build_app(self):
        """读取 build.app 文件获取应用名称"""
        build_app_file = self.assets_dir / "build.app"
        if not build_app_file.exists():
            raise FileNotFoundError(f"build.app file not found at {build_app_file}")
        
        with open(build_app_file, 'r', encoding='utf-8') as f:
            content = f.read().strip()
            # 解析 appName=xxx
            match = re.match(r'appName=(.+)', content)
            if match:
                return match.group(1).strip()
            else:
                raise ValueError("Invalid build.app format. Expected: appName=xxx")
    
    def read_config(self, app_name):
        """读取应用配置文件"""
        config_file = self.assets_dir / app_name / "app.cfg"
        if not config_file.exists():
            raise FileNotFoundError(f"Config file not found at {config_file}")
        
        config = {}
        with open(config_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                # 跳过注释和空行
                if not line or line.startswith('#'):
                    continue
                
                # 解析 key=value
                if '=' in line:
                    key, value = line.split('=', 1)
                    config[key.strip()] = value.strip()
        
        return config
    
    def parse_boolean(self, value):
        """将字符串转换为布尔值"""
        if isinstance(value, bool):
            return value
        return value.lower() in ('true', 'yes', '1')
    
    def replace_file_content(self, file_path, replacements):
        """替换文件内容"""
        if not os.path.exists(file_path):
            print(f"Warning: File not found: {file_path}")
            return
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        for placeholder, value in replacements.items():
            content = content.replace(placeholder, str(value))
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"Updated: {file_path}")
    
    def download_resource(self, url, filename):
        """从网络下载资源文件到临时目录"""
        try:
            print(f"Downloading: {url}")
            
            # 创建临时目录
            temp_dir = Path(tempfile.gettempdir()) / "xlab_resources"
            temp_dir.mkdir(parents=True, exist_ok=True)
            
            # 下载文件
            temp_file = temp_dir / filename
            
            # 添加 User-Agent 避免某些服务器拒绝请求
            req = urllib.request.Request(
                url,
                headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'}
            )
            
            with urllib.request.urlopen(req, timeout=30) as response:
                with open(temp_file, 'wb') as out_file:
                    out_file.write(response.read())
            
            print(f"Downloaded: {url} -> {temp_file}")
            return temp_file
            
        except Exception as e:
            print(f"Error downloading {url}: {e}")
            return None
    
    def download_web_content(self, url, output_dir):
        """下载网页及其所有资源"""
        print(f"\n=== Downloading Web Content ===")
        print(f"URL: {url}")
        print(f"Output Directory: {output_dir}")
        
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # 下载主HTML文件
        try:
            req = urllib.request.Request(
                url,
                headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'}
            )
            
            with urllib.request.urlopen(req, timeout=30) as response:
                html_content = response.read().decode('utf-8', errors='ignore')
            
            # 解析HTML获取资源链接
            parser = HTMLResourceParser(url)
            parser.feed(html_content)
            
            print(f"Found {len(parser.resources)} resources to download")
            
            # 下载所有资源
            downloaded_resources = {}
            for resource_url in parser.resources:
                try:
                    parsed = urlparse(resource_url)
                    # 生成本地文件名（保留路径结构）
                    local_path = parsed.path.lstrip('/')
                    if not local_path:
                        continue
                    
                    # 创建本地目录结构
                    local_file = output_dir / local_path
                    local_file.parent.mkdir(parents=True, exist_ok=True)
                    
                    # 下载资源
                    req = urllib.request.Request(
                        resource_url,
                        headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'}
                    )
                    
                    with urllib.request.urlopen(req, timeout=30) as response:
                        with open(local_file, 'wb') as f:
                            f.write(response.read())
                    
                    print(f"  Downloaded: {resource_url} -> {local_path}")
                    downloaded_resources[resource_url] = local_path
                    
                except Exception as e:
                    print(f"  Warning: Failed to download {resource_url}: {e}")
            
            # 修改HTML中的资源链接为本地路径
            for resource_url, local_path in downloaded_resources.items():
                html_content = html_content.replace(resource_url, local_path)
                # 也替换相对路径版本
                parsed = urlparse(resource_url)
                html_content = html_content.replace(parsed.path, local_path)
            
            # 保存修改后的HTML
            index_file = output_dir / "index.html"
            with open(index_file, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            print(f"\nSaved HTML to: {index_file}")
            print(f"Total resources downloaded: {len(downloaded_resources)}")
            
            return True
            
        except Exception as e:
            print(f"Error downloading web content: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def get_resource_path(self, app_name, resource_config_value):
        """获取资源文件路径，支持本地路径和 HTTP(S) URL"""
        # 检查是否是 URL
        if resource_config_value.startswith('http://') or resource_config_value.startswith('https://'):
            # 从 URL 中提取文件名
            parsed_url = urllib.parse.urlparse(resource_config_value)
            filename = os.path.basename(parsed_url.path)
            
            # 如果没有文件名或扩展名，使用默认名称
            if not filename or '.' not in filename:
                # 根据配置项猜测文件类型
                if 'icon' in resource_config_value.lower():
                    filename = 'icon.png'
                elif 'loading' in resource_config_value.lower():
                    filename = 'loading.png'
                elif 'splash' in resource_config_value.lower():
                    filename = 'splash.png'
                else:
                    filename = 'resource.png'
            
            # 下载文件
            downloaded_file = self.download_resource(resource_config_value, filename)
            return downloaded_file if downloaded_file else None
        else:
            # 本地文件路径
            local_path = self.assets_dir / app_name / resource_config_value
            return local_path if local_path.exists() else None
    
    def copy_resources(self, app_name):
        """复制资源文件到项目目录"""
        app_assets_dir = self.assets_dir / app_name
        
        # 检查是否需要下载Web内容
        is_web_local = self.parse_boolean(self.config.get('isWebLocal', 'false'))
        if is_web_local:
            load_url = self.config.get('loadUrl', '')
            if load_url and (load_url.startswith('http://') or load_url.startswith('https://')):
                # 下载Web内容到临时目录
                temp_web_dir = Path(tempfile.gettempdir()) / "xlab_web_content"
                if temp_web_dir.exists():
                    shutil.rmtree(temp_web_dir)
                
                if self.download_web_content(load_url, temp_web_dir):
                    # 复制到Android assets
                    android_assets_dir = self.android_dir / "app" / "src" / "main" / "assets" / "webapp"
                    if android_assets_dir.exists():
                        shutil.rmtree(android_assets_dir)
                    shutil.copytree(temp_web_dir, android_assets_dir)
                    print(f"\nCopied web content to Android: {android_assets_dir}")
                    
                    # 复制到iOS bundle
                    ios_webapp_dir = self.ios_dir / "WebViewApp" / "webapp"
                    if ios_webapp_dir.exists():
                        shutil.rmtree(ios_webapp_dir)
                    shutil.copytree(temp_web_dir, ios_webapp_dir)
                    print(f"Copied web content to iOS: {ios_webapp_dir}")
                else:
                    print("Warning: Failed to download web content, continuing with online mode")
            else:
                print("Warning: isWebLocal=true but loadUrl is not a valid HTTP(S) URL")
        
        # 复制Android资源
        android_res_dir = self.android_dir / "app" / "src" / "main" / "res"
        
        # 获取 loading 图片路径（支持 URL）
        loading_config = self.config.get('loadingImage', 'loading.png')
        loading_img = self.get_resource_path(app_name, loading_config)
        
        if loading_img and loading_img.exists():
            drawable_dir = android_res_dir / "drawable"
            drawable_dir.mkdir(parents=True, exist_ok=True)
            target_loading = drawable_dir / "loading.png"
            
            # 使用 PIL 处理图片以确保 Android 兼容性
            if PIL_AVAILABLE:
                try:
                    img = Image.open(loading_img)
                    # 转换为 RGBA（Android 支持透明度）
                    if img.mode not in ('RGBA', 'RGB'):
                        img = img.convert('RGBA' if img.mode in ('LA', 'P') else 'RGB')
                    # 保存为优化的 PNG（移除可能有问题的元数据）
                    img.save(target_loading, 'PNG', optimize=True)
                    print(f"Processed and copied: {loading_img} -> {target_loading}")
                except Exception as e:
                    print(f"Warning: Failed to process loading image with PIL: {e}")
                    print(f"  Falling back to direct copy")
                    shutil.copy(loading_img, target_loading)
            else:
                shutil.copy(loading_img, target_loading)
                print(f"Copied: {loading_img} -> {target_loading} (PIL not available)")
        elif loading_config:
            print(f"Warning: Loading image not found: {loading_config}")
        
        # 获取应用图标路径（支持 URL）
        icon_config = self.config.get('appIcon', self.config.get('iconImage', 'icon.png'))
        icon_img = self.get_resource_path(app_name, icon_config)
        
        if icon_img and icon_img.exists():
            # 为不同密度创建mipmap目录
            mipmap_densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']
            for density in mipmap_densities:
                mipmap_dir = android_res_dir / f"mipmap-{density}"
                mipmap_dir.mkdir(parents=True, exist_ok=True)
                
                # 使用 PIL 处理图标以确保 Android 兼容性
                if PIL_AVAILABLE:
                    try:
                        img = Image.open(icon_img)
                        # Android 图标可以有透明度，但建议使用 RGBA 或 RGB
                        if img.mode == 'P':
                            img = img.convert('RGBA')
                        elif img.mode not in ('RGBA', 'RGB'):
                            img = img.convert('RGB')
                        
                        # 保存图标和圆形图标（移除元数据）
                        img.save(mipmap_dir / "ic_launcher.png", 'PNG', optimize=True)
                        img.save(mipmap_dir / "ic_launcher_round.png", 'PNG', optimize=True)
                    except Exception as e:
                        print(f"Warning: Failed to process icon for {density} with PIL: {e}")
                        print(f"  Falling back to direct copy")
                        shutil.copy(icon_img, mipmap_dir / "ic_launcher.png")
                        shutil.copy(icon_img, mipmap_dir / "ic_launcher_round.png")
                else:
                    # 没有 PIL，直接复制
                    shutil.copy(icon_img, mipmap_dir / "ic_launcher.png")
                    shutil.copy(icon_img, mipmap_dir / "ic_launcher_round.png")
            
            if PIL_AVAILABLE:
                print(f"Processed and copied: {icon_img} -> mipmap directories")
            else:
                print(f"Copied: {icon_img} -> mipmap directories (PIL not available)")
        elif icon_config:
            print(f"Warning: App icon not found: {icon_config}")
        
        # 复制iOS资源
        ios_assets_dir = self.ios_dir / "WebViewApp" / "Assets.xcassets"
        
        # 复制loading图片
        if loading_img and loading_img.exists():
            loading_imageset = ios_assets_dir / "loading.imageset"
            loading_imageset.mkdir(parents=True, exist_ok=True)
            shutil.copy(loading_img, loading_imageset / "loading.png")
            
            # 创建Contents.json
            contents_json = loading_imageset / "Contents.json"
            with open(contents_json, 'w', encoding='utf-8') as f:
                f.write('''{
  "images" : [
    {
      "filename" : "loading.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}''')
            print(f"Copied: {loading_img} -> {loading_imageset / 'loading.png'}")
        
        # 复制应用图标到AppIcon.appiconset
        if icon_img and icon_img.exists():
            appicon_dir = ios_assets_dir / "AppIcon.appiconset"
            appicon_dir.mkdir(parents=True, exist_ok=True)
            
            target_icon = appicon_dir / "AppIcon.png"
            
            # iOS 要求图标必须是 1024x1024
            if PIL_AVAILABLE:
                try:
                    img = Image.open(icon_img)
                    # 转换为 RGB（移除透明通道，iOS 要求不透明）
                    if img.mode in ('RGBA', 'LA', 'P'):
                        # 创建白色背景
                        background = Image.new('RGB', img.size, (255, 255, 255))
                        if img.mode == 'P':
                            img = img.convert('RGBA')
                        background.paste(img, mask=img.split()[-1] if img.mode in ('RGBA', 'LA') else None)
                        img = background
                    elif img.mode != 'RGB':
                        img = img.convert('RGB')
                    
                    # 调整尺寸为 1024x1024
                    if img.size != (1024, 1024):
                        print(f"  Resizing icon from {img.size} to (1024, 1024)")
                        img = img.resize((1024, 1024), Image.Resampling.LANCZOS)
                    
                    # 保存
                    img.save(target_icon, 'PNG', quality=100)
                    print(f"Copied and resized: {icon_img} -> {target_icon} (1024x1024, RGB)")
                except Exception as e:
                    print(f"Warning: Failed to process icon with PIL: {e}")
                    print(f"  Falling back to direct copy")
                    shutil.copy(icon_img, target_icon)
            else:
                # 没有 PIL，直接复制（可能会有尺寸问题）
                shutil.copy(icon_img, target_icon)
                print(f"Warning: Copied icon without resizing (PIL not available)")
                print(f"  Please ensure {icon_img} is exactly 1024x1024 and RGB format")
            
            # 创建/更新 Contents.json
            contents_json = appicon_dir / "Contents.json"
            with open(contents_json, 'w', encoding='utf-8') as f:
                f.write('''{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}''')
            print(f"Created: {contents_json}")
    
    def configure_android(self, app_name):
        """配置Android项目"""
        print("\n=== Configuring Android ===")
        
        package_name = self.config.get('appId', 'com.mywebviewapp')
        package_path = package_name.replace('.', '/')
        
        # 准备替换映射
        replacements = {
            '__APP_ID__': package_name,
            '__PACKAGE_NAME__': package_name,
            '__APP_NAME__': self.config.get('appName', 'MyWebView'),
            '__APP_DISPLAY_NAME__': self.config.get('appDisplayName', 'MyWebView'),
            '__APP_VERSION__': self.config.get('appVersion', '1.0.0'),
            '__BUILD_NUMBER__': self.config.get('buildNumber', '1'),
            '__COMPILE_SDK_VERSION__': self.config.get('androidCompileSdkVersion', '34'),
            '__MIN_SDK_VERSION__': self.config.get('androidMinSdkVersion', '21'),
            '__TARGET_SDK_VERSION__': self.config.get('androidTargetSdkVersion', '34'),
            '__VERSION_CODE__': self.config.get('androidVersionCode', '1'),
            '__VERSION_NAME__': self.config.get('androidVersionName', '1.0.0'),
            '__KEYSTORE_FILE__': self.config.get('androidKeystoreFile', 'devdroid.jks'),
            '__STORE_PASSWORD__': self.config.get('androidStorePassword', 'PLACEHOLDER_STORE_PASSWORD'),
            '__KEY_ALIAS__': self.config.get('androidKeyAlias', 'PLACEHOLDER_KEY_ALIAS'),
            '__KEY_PASSWORD__': self.config.get('androidKeyPassword', 'PLACEHOLDER_KEY_PASSWORD'),
            '__USES_CLEARTEXT_TRAFFIC__': 'true' if not self.parse_boolean(self.config.get('enableHttps', 'true')) else 'false',
            
            # WebView配置
            '__LOAD_URL__': self.config.get('loadUrl', 'https://www.baidu.com'),
            '__IS_WEB_LOCAL__': str(self.parse_boolean(self.config.get('isWebLocal', 'false'))).lower(),
            '__ENABLE_JAVASCRIPT__': str(self.parse_boolean(self.config.get('enableJavaScript', 'true'))).lower(),
            '__ENABLE_DOM_STORAGE__': str(self.parse_boolean(self.config.get('enableDOMStorage', 'true'))).lower(),
            '__ENABLE_CACHE__': str(self.parse_boolean(self.config.get('enableCache', 'true'))).lower(),
            '__ALLOW_FILE_ACCESS__': str(self.parse_boolean(self.config.get('allowFileAccess', 'false'))).lower(),
            '__ALLOW_CONTENT_ACCESS__': str(self.parse_boolean(self.config.get('allowContentAccess', 'false'))).lower(),
            '__MIXED_CONTENT_MODE__': self.config.get('mixedContentMode', 'NEVER'),
            '__USER_AGENT_STRING__': self.config.get('userAgentString', ''),
            
            # Loading配置
            '__LOADING_DURATION__': self.config.get('loadingDuration', '1000'),
            '__LOADING_BACKGROUND_COLOR__': self.config.get('loadingBackgroundColor', '#4A90E2'),
            '__LOADING_TEXT_COLOR__': self.config.get('loadingTextColor', '#FFFFFF'),
            '__LOADING_TEXT__': self.config.get('loadingText', '加载中...'),
            
            # UI配置
            '__SHOW_LOADING_PROGRESS__': str(self.parse_boolean(self.config.get('showLoadingProgress', 'true'))).lower(),
            '__SHOW_ERROR_PAGE__': str(self.parse_boolean(self.config.get('showErrorPage', 'true'))).lower(),
            '__ERROR_PAGE_TITLE__': self.config.get('errorPageTitle', '加载失败'),
            '__ERROR_PAGE_MESSAGE__': self.config.get('errorPageMessage', '页面加载失败，请检查网络连接'),
            '__ERROR_BUTTON_TEXT__': self.config.get('errorButtonText', '重试'),
            
            # 高级配置
            '__ENABLE_DEBUGGING__': str(self.parse_boolean(self.config.get('enableDebugging', 'true'))).lower(),
            '__CLEAR_CACHE_ON_START__': str(self.parse_boolean(self.config.get('clearCacheOnStart', 'false'))).lower(),
            '__ENABLE_ZOOM__': str(self.parse_boolean(self.config.get('enableZoom', 'true'))).lower(),
            '__ENABLE_BUILT_IN_ZOOM_CONTROLS__': str(self.parse_boolean(self.config.get('enableBuiltInZoomControls', 'false'))).lower(),
            '__SUPPORT_MULTIPLE_WINDOWS__': str(self.parse_boolean(self.config.get('supportMultipleWindows', 'false'))).lower(),
        }
        
        # 先替换旧位置的 Kotlin 文件（在移动之前）
        old_package_dir = self.android_dir / "app" / "src" / "main" / "java" / "com" / "mywebviewapp"
        if old_package_dir.exists():
            print(f"Replacing placeholders in Kotlin files at: {old_package_dir}")
            for kt_file in old_package_dir.glob("*.kt"):
                print(f"  Processing: {kt_file.name}")
                self.replace_file_content(kt_file, replacements)
        
        # 创建目标包目录
        src_dir = self.android_dir / "app" / "src" / "main" / "java" / package_path
        src_dir.mkdir(parents=True, exist_ok=True)
        
        # 移动Kotlin文件到正确的包目录
        if old_package_dir.exists() and old_package_dir != src_dir:
            print(f"Moving Kotlin files from {old_package_dir} to {src_dir}")
            for kt_file in old_package_dir.glob("*.kt"):
                dest_file = src_dir / kt_file.name
                if dest_file.exists():
                    dest_file.unlink()  # 删除已存在的文件
                shutil.move(str(kt_file), str(dest_file))
                print(f"  Moved: {kt_file.name}")
            # 删除旧目录树
            try:
                # 从 com 开始删除整个目录树
                com_dir = self.android_dir / "app" / "src" / "main" / "java" / "com"
                if com_dir.exists():
                    # 只删除 mywebviewapp 包
                    mywebviewapp_dir = com_dir / "mywebviewapp"
                    if mywebviewapp_dir.exists() and not mywebviewapp_dir.exists():
                        shutil.rmtree(old_package_dir.parent.parent)
                        print(f"  Removed old package directory")
            except Exception as e:
                print(f"  Warning: Could not remove old directory: {e}")
        
        # 替换其他文件
        files_to_replace = [
            self.android_dir / "app" / "build.gradle",
            self.android_dir / "app" / "src" / "main" / "AndroidManifest.xml",
            self.android_dir / "app" / "src" / "main" / "res" / "values" / "strings.xml",
        ]
        
        for file_path in files_to_replace:
            self.replace_file_content(file_path, replacements)
    
    def configure_ios(self, app_name):
        """配置iOS项目"""
        print("\n=== Configuring iOS ===")
        
        team_id = self.config.get('iosTeamId', '')
        
        # 清理 Team ID
        if team_id == 'PLACEHOLDER_TEAM_ID' or not team_id:
            team_id = ''
        
        replacements = {
            '__APP_NAME__': self.config.get('appName', 'MyWebView'),
            '__APP_DISPLAY_NAME__': self.config.get('iosBundleDisplayName', self.config.get('appDisplayName', 'MyWebView')),
            '__APP_ID__': self.config.get('appId', 'com.mywebviewapp'),
            '__APP_VERSION__': self.config.get('appVersion', '1.0.0'),
            '__BUILD_NUMBER__': self.config.get('iosBuildNumber', self.config.get('buildNumber', '1')),
            '__BUNDLE_ID__': self.config.get('iosBundleId', self.config.get('appId', 'com.mywebviewapp')),
            '__VERSION__': self.config.get('iosBundleVersion', self.config.get('appVersion', '1.0.0')),
            '__IOS_DEPLOYMENT_TARGET__': self.config.get('iosDeploymentTarget', '13.0'),
            '__TEAM_ID__': team_id,
            '__ALLOWS_ARBITRARY_LOADS__': 'true' if not self.parse_boolean(self.config.get('enableHttps', 'true')) else 'false',
            
            # WebView配置 (与Android相同)
            '__LOAD_URL__': self.config.get('loadUrl', 'https://www.baidu.com'),
            '__IS_WEB_LOCAL__': str(self.parse_boolean(self.config.get('isWebLocal', 'false'))).lower(),
            '__ENABLE_JAVASCRIPT__': str(self.parse_boolean(self.config.get('enableJavaScript', 'true'))).lower(),
            '__ENABLE_DOM_STORAGE__': str(self.parse_boolean(self.config.get('enableDOMStorage', 'true'))).lower(),
            '__ENABLE_CACHE__': str(self.parse_boolean(self.config.get('enableCache', 'true'))).lower(),
            '__ALLOW_FILE_ACCESS__': str(self.parse_boolean(self.config.get('allowFileAccess', 'false'))).lower(),
            '__MIXED_CONTENT_MODE__': self.config.get('mixedContentMode', 'NEVER'),
            '__USER_AGENT_STRING__': self.config.get('userAgentString', ''),
            
            # Loading配置
            '__LOADING_DURATION__': self.config.get('loadingDuration', '1000'),
            '__LOADING_BACKGROUND_COLOR__': self.config.get('loadingBackgroundColor', '#4A90E2'),
            '__LOADING_TEXT_COLOR__': self.config.get('loadingTextColor', '#FFFFFF'),
            '__LOADING_TEXT__': self.config.get('loadingText', '加载中...'),
            
            # UI配置
            '__SHOW_LOADING_PROGRESS__': str(self.parse_boolean(self.config.get('showLoadingProgress', 'true'))).lower(),
            '__SHOW_ERROR_PAGE__': str(self.parse_boolean(self.config.get('showErrorPage', 'true'))).lower(),
            '__ERROR_PAGE_TITLE__': self.config.get('errorPageTitle', '加载失败'),
            '__ERROR_PAGE_MESSAGE__': self.config.get('errorPageMessage', '页面加载失败，请检查网络连接'),
            '__ERROR_BUTTON_TEXT__': self.config.get('errorButtonText', '重试'),
            
            # 高级配置
            '__ENABLE_DEBUGGING__': str(self.parse_boolean(self.config.get('enableDebugging', 'true'))).lower(),
            '__CLEAR_CACHE_ON_START__': str(self.parse_boolean(self.config.get('clearCacheOnStart', 'false'))).lower(),
            '__ENABLE_ZOOM__': str(self.parse_boolean(self.config.get('enableZoom', 'true'))).lower(),
            '__SUPPORT_MULTIPLE_WINDOWS__': str(self.parse_boolean(self.config.get('supportMultipleWindows', 'false'))).lower(),
        }
        
        # 替换文件
        files_to_replace = [
            self.ios_dir / "WebViewApp.xcodeproj" / "project.pbxproj",
            self.ios_dir / "WebViewApp" / "Info.plist",
            self.ios_dir / "WebViewApp" / "AppConfig.swift",
            self.ios_dir / "WebViewApp" / "AppDelegate.swift",
            self.ios_dir / "WebViewApp" / "SceneDelegate.swift",
            self.ios_dir / "WebViewApp" / "LoadingViewController.swift",
            self.ios_dir / "WebViewApp" / "MainViewController.swift",
        ]
        
        for file_path in files_to_replace:
            self.replace_file_content(file_path, replacements)
    
    def build(self):
        """执行构建配置"""
        print("=" * 50)
        print("WebView App Configuration Builder")
        print("=" * 50)
        
        # 读取build.app
        app_name = self.read_build_app()
        print(f"\nApp Name: {app_name}")
        
        # 读取配置文件
        self.config = self.read_config(app_name)
        print(f"Config loaded from: assets/{app_name}/app.cfg")
        print(f"Total config items: {len(self.config)}")
        
        # 复制资源文件
        print("\n=== Copying Resources ===")
        self.copy_resources(app_name)
        
        # 配置Android
        if self.parse_boolean(self.config.get('buildAndroid', 'true')):
            self.configure_android(app_name)
        else:
            print("\n=== Skipping Android (buildAndroid=false) ===")
        
        # 配置iOS
        if self.parse_boolean(self.config.get('buildIOS', 'true')):
            self.configure_ios(app_name)
        else:
            print("\n=== Skipping iOS (buildIOS=false) ===")
        
        print("\n" + "=" * 50)
        print("Configuration completed successfully!")
        print("=" * 50)


def main():
    if len(sys.argv) > 1:
        workspace_root = sys.argv[1]
    else:
        workspace_root = os.getcwd()
    
    try:
        builder = ConfigBuilder(workspace_root)
        builder.build()
        sys.exit(0)
    except Exception as e:
        print(f"\nError: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
