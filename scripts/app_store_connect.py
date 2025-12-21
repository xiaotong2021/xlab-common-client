#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
App Store Connect API 管理脚本
用于检查和创建应用、上传元数据等
"""

import os
import sys
import json
import time
import jwt
import requests
from datetime import datetime, timedelta, timezone
from pathlib import Path


class AppStoreConnectAPI:
    """App Store Connect API 客户端"""
    
    BASE_URL = "https://api.appstoreconnect.apple.com/v1"
    
    def __init__(self, key_id, issuer_id, private_key_path):
        """
        初始化 API 客户端
        
        Args:
            key_id: API Key ID
            issuer_id: Issuer ID
            private_key_path: 私钥文件路径
        """
        self.key_id = key_id
        self.issuer_id = issuer_id
        self.private_key_path = private_key_path
        self.token = None
        self.token_exp = None
        
    def generate_token(self):
        """生成 JWT Token"""
        # Token 有效期20分钟
        exp = datetime.now(timezone.utc) + timedelta(minutes=20)
        
        with open(self.private_key_path, 'r') as f:
            private_key = f.read()
        
        headers = {
            "alg": "ES256",
            "kid": self.key_id,
            "typ": "JWT"
        }
        
        payload = {
            "iss": self.issuer_id,
            "exp": int(exp.timestamp()),
            "aud": "appstoreconnect-v1"
        }
        
        token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
        self.token = token
        self.token_exp = exp
        return token
    
    def get_token(self):
        """获取有效的 Token"""
        if self.token is None or datetime.now(timezone.utc) >= self.token_exp:
            return self.generate_token()
        return self.token
    
    def make_request(self, method, endpoint, data=None, params=None):
        """
        发送 API 请求
        
        Args:
            method: HTTP 方法 (GET, POST, PATCH, etc.)
            endpoint: API 端点
            data: 请求数据
            params: URL 参数
            
        Returns:
            响应 JSON
        """
        url = f"{self.BASE_URL}/{endpoint}"
        headers = {
            "Authorization": f"Bearer {self.get_token()}",
            "Content-Type": "application/json"
        }
        
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=headers,
                json=data,
                params=params
            )
            response.raise_for_status()
            return response.json() if response.text else None
        except requests.exceptions.HTTPError as e:
            print(f"API 请求失败: {e}")
            if response.text:
                print(f"错误详情: {response.text}")
            raise
    
    def find_app_by_bundle_id(self, bundle_id):
        """
        根据 Bundle ID 查找应用
        
        Args:
            bundle_id: 应用的 Bundle ID
            
        Returns:
            应用信息，如果不存在返回 None
        """
        print(f"🔍 查找应用: {bundle_id}")
        
        params = {
            "filter[bundleId]": bundle_id
        }
        
        result = self.make_request("GET", "apps", params=params)
        
        if result and result.get("data"):
            app = result["data"][0]
            print(f"✅ 找到应用: {app['attributes']['name']} (ID: {app['id']})")
            return app
        else:
            print(f"❌ 未找到应用: {bundle_id}")
            return None
    
    def get_app_info(self, app_id):
        """
        获取应用详细信息
        
        Args:
            app_id: 应用 ID
            
        Returns:
            应用信息
        """
        return self.make_request("GET", f"apps/{app_id}")
    
    def get_latest_app_version(self, app_id):
        """
        获取应用的最新版本（优先获取编辑中或待提交的版本）
        
        Args:
            app_id: 应用 ID
                
        Returns:
            版本信息字典，包含 id 和 versionString，如果没有找到返回 None
        """
        print(f"🔍 查找应用的现有版本...")
        
        try:
            result = self.make_request("GET", f"apps/{app_id}/appStoreVersions")
            
            if result and result.get("data"):
                # 优先查找状态为 PREPARE_FOR_SUBMISSION 或 DEVELOPER_REJECTED 的版本
                for version in result["data"]:
                    if version["attributes"].get("platform") == "IOS":
                        state = version["attributes"].get("appStoreState", "")
                        if state in ["PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED"]:
                            version_id = version["id"]
                            version_string = version["attributes"].get("versionString")
                            print(f"✅ 找到可编辑版本: {version_string} (ID: {version_id}, 状态: {state})")
                            return {"id": version_id, "versionString": version_string}
                
                # 如果没有可编辑的版本，返回第一个版本
                for version in result["data"]:
                    if version["attributes"].get("platform") == "IOS":
                        version_id = version["id"]
                        version_string = version["attributes"].get("versionString")
                        state = version["attributes"].get("appStoreState", "UNKNOWN")
                        print(f"✅ 找到现有版本: {version_string} (ID: {version_id}, 状态: {state})")
                        print(f"⚠️  当前版本状态为 {state}，可能无法编辑元数据")
                        return {"id": version_id, "versionString": version_string}
            
            print(f"❌ 未找到任何版本")
            return None
            
        except Exception as e:
            print(f"❌ 查询版本失败: {e}")
            return None
    
    def update_app_version_info(self, version_id, version_string, locale_data):
        """
        更新应用版本信息（不创建新版本，只更新现有版本）
        
        Args:
            version_id: 版本 ID
            version_string: 版本号（用于显示）
            locale_data: 本地化数据字典，包含：
                - description: 应用描述
                - keywords: 关键词
                - releaseNotes: 更新说明
                - supportUrl: 技术支持网址
                - marketingUrl: 营销网址
                - promotionalText: 推广文本
                
        Returns:
            字典，包含成功更新的locale和对应的数据: {locale: data, ...}
        """
        print(f"📝 更新应用版本信息: {version_string}")
        
        try:
            # 更新本地化信息
            updated_locales = self.update_version_localizations(version_id, locale_data)
            return updated_locales
            
        except Exception as e:
            print(f"⚠️  更新版本信息失败: {e}")
            return {}
    
    def update_version_localizations(self, version_id, locale_data):
        """
        更新版本本地化信息
        
        Args:
            version_id: 版本 ID
            locale_data: 本地化数据字典，key为语言代码
            
        Returns:
            成功更新的locale字典: {locale: data, ...}
        """
        updated_locales = {}
        
        for locale, data in locale_data.items():
            print(f"🌐 更新本地化信息: {locale}")
            
            # 查找现有本地化（通过版本的关系）
            result = self.make_request("GET", f"appStoreVersions/{version_id}/appStoreVersionLocalizations")
            
            if result and result.get("data"):
                # 更新现有本地化
                loc_id = None
                for loc in result["data"]:
                    if loc["attributes"].get("locale") == locale:
                        loc_id = loc["id"]
                        break
                
                if loc_id:
                    # 尝试更新，使用更智能的错误处理
                    update_data = {
                        "data": {
                            "type": "appStoreVersionLocalizations",
                            "id": loc_id,
                            "attributes": {}
                        }
                    }
                    
                    # 分别尝试更新每个字段，如果某个字段失败则跳过
                    fields_to_update = []
                    if "description" in data:
                        fields_to_update.append(("description", data["description"]))
                    if "keywords" in data:
                        fields_to_update.append(("keywords", data["keywords"]))
                    if "supportUrl" in data:
                        fields_to_update.append(("supportUrl", data["supportUrl"]))
                    if "marketingUrl" in data:
                        fields_to_update.append(("marketingUrl", data["marketingUrl"]))
                    if "promotionalText" in data:
                        fields_to_update.append(("promotionalText", data["promotionalText"]))
                    
                    # 先尝试更新基本字段
                    if fields_to_update:
                        for field_name, field_value in fields_to_update:
                            update_data["data"]["attributes"][field_name] = field_value
                        
                        try:
                            self.make_request("PATCH", f"appStoreVersionLocalizations/{loc_id}", data=update_data)
                            print(f"  ✓ 已更新: {', '.join([f[0] for f in fields_to_update])}")
                        except Exception as e:
                            print(f"  ⚠️ 部分字段更新失败: {e}")
                    
                    # whatsNew (releaseNotes) 单独处理，因为它可能在某些状态下无法编辑
                    if "releaseNotes" in data:
                        whatsNew_data = {
                            "data": {
                                "type": "appStoreVersionLocalizations",
                                "id": loc_id,
                                "attributes": {
                                    "whatsNew": data["releaseNotes"]
                                }
                            }
                        }
                        try:
                            self.make_request("PATCH", f"appStoreVersionLocalizations/{loc_id}", data=whatsNew_data)
                            print(f"  ✓ 已更新: whatsNew")
                        except Exception as e:
                            if "whatsNew" in str(e) or "cannot be edited" in str(e):
                                print(f"  ⚠️ whatsNew 字段当前无法编辑（版本状态限制）")
                            else:
                                print(f"  ⚠️ whatsNew 更新失败: {e}")
                    
                    print(f"✅ 本地化信息已更新: {locale}")
                    updated_locales[locale] = data
                else:
                    # 创建新本地化
                    localization_data = {
                        "data": {
                            "type": "appStoreVersionLocalizations",
                            "attributes": {
                                "locale": locale
                            },
                            "relationships": {
                                "appStoreVersion": {
                                    "data": {
                                        "type": "appStoreVersions",
                                        "id": version_id
                                    }
                                }
                            }
                        }
                    }
                    
                    # 添加可选字段
                    if "description" in data:
                        localization_data["data"]["attributes"]["description"] = data["description"]
                    if "keywords" in data:
                        localization_data["data"]["attributes"]["keywords"] = data["keywords"]
                    if "releaseNotes" in data:
                        localization_data["data"]["attributes"]["whatsNew"] = data["releaseNotes"]
                    if "supportUrl" in data:
                        localization_data["data"]["attributes"]["supportUrl"] = data["supportUrl"]
                    if "marketingUrl" in data:
                        localization_data["data"]["attributes"]["marketingUrl"] = data["marketingUrl"]
                    if "promotionalText" in data:
                        localization_data["data"]["attributes"]["promotionalText"] = data["promotionalText"]
                    
                    self.make_request("POST", "appStoreVersionLocalizations", data=localization_data)
                    print(f"✅ 本地化信息已创建: {locale}")
                    updated_locales[locale] = data
            else:
                # 没有找到任何本地化，创建新的
                localization_data = {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "attributes": {
                            "locale": locale
                        },
                        "relationships": {
                            "appStoreVersion": {
                                "data": {
                                    "type": "appStoreVersions",
                                    "id": version_id
                                }
                            }
                        }
                    }
                }
                
                # 添加可选字段
                if "description" in data:
                    localization_data["data"]["attributes"]["description"] = data["description"]
                if "keywords" in data:
                    localization_data["data"]["attributes"]["keywords"] = data["keywords"]
                if "releaseNotes" in data:
                    localization_data["data"]["attributes"]["whatsNew"] = data["releaseNotes"]
                if "supportUrl" in data:
                    localization_data["data"]["attributes"]["supportUrl"] = data["supportUrl"]
                if "marketingUrl" in data:
                    localization_data["data"]["attributes"]["marketingUrl"] = data["marketingUrl"]
                if "promotionalText" in data:
                    localization_data["data"]["attributes"]["promotionalText"] = data["promotionalText"]
                
                self.make_request("POST", "appStoreVersionLocalizations", data=localization_data)
                print(f"✅ 本地化信息已创建: {locale}")
                updated_locales[locale] = data
        
        return updated_locales
    
    def update_app_info_metadata(self, app_id, metadata):
        """
        更新应用元数据（不依赖版本的信息）
        
        Args:
            app_id: 应用 ID
            metadata: 元数据字典，包含：
                - primaryLocale: 主要语言
                - name: 应用名称
                - privacyPolicyUrl: 隐私政策URL
                - privacyPolicyText: 隐私政策文本
        """
        print(f"📋 更新应用元数据")
        
        # 获取应用信息本地化
        for locale in metadata.get("locales", ["zh-Hans", "en-US"]):
            locale_metadata = metadata.get("locale_data", {}).get(locale, {})
            
            if not locale_metadata:
                continue
            
            # 获取应用信息 ID
            app_info_result = self.make_request("GET", f"apps/{app_id}/appInfos")
            if not app_info_result or not app_info_result.get("data"):
                print(f"⚠️  无法获取应用信息")
                continue
            
            app_info_id = app_info_result["data"][0]["id"]
            
            # 查找现有本地化（通过 appInfo 的关系）
            result = self.make_request("GET", f"appInfos/{app_info_id}/appInfoLocalizations")
            
            data = {
                "data": {
                    "type": "appInfoLocalizations",
                    "attributes": {
                        "locale": locale
                    }
                }
            }
            
            # 添加可选字段
            if "name" in locale_metadata:
                data["data"]["attributes"]["name"] = locale_metadata["name"]
            if "privacyPolicyText" in locale_metadata:
                data["data"]["attributes"]["privacyPolicyText"] = locale_metadata["privacyPolicyText"]
            if "privacyPolicyUrl" in locale_metadata:
                data["data"]["attributes"]["privacyPolicyUrl"] = locale_metadata["privacyPolicyUrl"]
            if "subtitle" in locale_metadata:
                data["data"]["attributes"]["subtitle"] = locale_metadata["subtitle"]
            
            # 查找匹配的本地化
            loc_id = None
            if result and result.get("data"):
                for loc in result["data"]:
                    if loc["attributes"].get("locale") == locale:
                        loc_id = loc["id"]
                        break
            
            if loc_id:
                # 更新现有本地化
                # 注意：UPDATE 请求中不能包含 locale 属性
                update_data = {
                    "data": {
                        "type": "appInfoLocalizations",
                        "id": loc_id,
                        "attributes": {}
                    }
                }
                
                # 只包含需要更新的属性（不包括 locale）
                if "name" in locale_metadata:
                    update_data["data"]["attributes"]["name"] = locale_metadata["name"]
                if "privacyPolicyText" in locale_metadata:
                    update_data["data"]["attributes"]["privacyPolicyText"] = locale_metadata["privacyPolicyText"]
                if "privacyPolicyUrl" in locale_metadata:
                    update_data["data"]["attributes"]["privacyPolicyUrl"] = locale_metadata["privacyPolicyUrl"]
                if "subtitle" in locale_metadata:
                    update_data["data"]["attributes"]["subtitle"] = locale_metadata["subtitle"]
                
                self.make_request("PATCH", f"appInfoLocalizations/{loc_id}", data=update_data)
            else:
                # 创建新本地化
                # 注意：创建时 name 属性是必需的
                if "name" not in data["data"]["attributes"]:
                    print(f"⚠️  创建本地化时缺少 name 属性，跳过: {locale}")
                    continue
                
                data["data"]["relationships"] = {
                    "appInfo": {
                        "data": {
                            "type": "appInfos",
                            "id": app_info_id
                        }
                    }
                }
                self.make_request("POST", "appInfoLocalizations", data=data)
            
            print(f"✅ 应用元数据已更新: {locale}")
    
    def upload_screenshot(self, version_localization_id, screenshot_path, display_type):
        """
        上传截图
        
        Args:
            version_localization_id: 版本本地化 ID
            screenshot_path: 截图文件路径
            display_type: 显示类型 (如 APP_IPHONE_67, APP_IPAD_PRO_3GEN_129)
            
        Returns:
            截图信息
        """
        import os
        
        file_size = os.path.getsize(screenshot_path)
        filename = os.path.basename(screenshot_path)
        
        print(f"📤 上传截图: {filename} ({display_type}, {file_size} bytes)")
        
        # 步骤 1: 创建截图保留位置
        create_data = {
            "data": {
                "type": "appScreenshotSets",
                "attributes": {
                    "screenshotDisplayType": display_type
                },
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {
                            "type": "appStoreVersionLocalizations",
                            "id": version_localization_id
                        }
                    }
                }
            }
        }
        
        # 查找或创建截图集（通过 appStoreVersionLocalization 的关系）
        screenshot_set_id = None
        
        try:
            # 通过关系端点获取现有的截图集
            result = self.make_request("GET", f"appStoreVersionLocalizations/{version_localization_id}/appScreenshotSets")
            
            if result and result.get("data"):
                # 查找匹配的显示类型
                for screenshot_set in result["data"]:
                    if screenshot_set["attributes"].get("screenshotDisplayType") == display_type:
                        screenshot_set_id = screenshot_set["id"]
                        print(f"✅ 找到现有截图集: {screenshot_set_id}")
                        break
        except Exception as e:
            print(f"⚠️ 查询截图集失败: {e}")
        
        # 如果没有找到，创建新的截图集
        if not screenshot_set_id:
            result = self.make_request("POST", "appScreenshotSets", data=create_data)
            screenshot_set_id = result["data"]["id"]
            print(f"✅ 创建截图集: {screenshot_set_id}")
        
        # 步骤 2: 创建截图并获取上传 URL
        screenshot_data = {
            "data": {
                "type": "appScreenshots",
                "attributes": {
                    "fileName": filename,
                    "fileSize": file_size
                },
                "relationships": {
                    "appScreenshotSet": {
                        "data": {
                            "type": "appScreenshotSets",
                            "id": screenshot_set_id
                        }
                    }
                }
            }
        }
        
        result = self.make_request("POST", "appScreenshots", data=screenshot_data)
        screenshot_id = result["data"]["id"]
        upload_operations = result["data"]["attributes"]["uploadOperations"]
        
        print(f"✅ 创建截图记录: {screenshot_id}")
        
        # 步骤 3: 上传截图文件
        with open(screenshot_path, 'rb') as f:
            file_data = f.read()
        
        for operation in upload_operations:
            method = operation["method"]
            url = operation["url"]
            headers = {header["name"]: header["value"] for header in operation.get("requestHeaders", [])}
            
            print(f"📤 上传文件数据...")
            response = requests.request(method, url, headers=headers, data=file_data)
            response.raise_for_status()
        
        # 步骤 4: 确认上传完成
        commit_data = {
            "data": {
                "type": "appScreenshots",
                "id": screenshot_id,
                "attributes": {
                    "uploaded": True,
                    "sourceFileChecksum": self._calculate_md5(screenshot_path)
                }
            }
        }
        
        self.make_request("PATCH", f"appScreenshots/{screenshot_id}", data=commit_data)
        
        print(f"✅ 截图上传成功: {filename}")
        
        return result["data"]
    
    def _calculate_md5(self, file_path):
        """计算文件的 MD5 校验和"""
        import hashlib
        
        md5 = hashlib.md5()
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b""):
                md5.update(chunk)
        return md5.hexdigest()
    
    def upload_screenshots_for_version(self, version_id, screenshots_dir, device_screenshot_mapping):
        """
        为指定版本上传截图
        
        Args:
            version_id: 版本 ID
            screenshots_dir: 截图目录
            device_screenshot_mapping: 设备类型到截图文件的映射
                格式: {'iPhone_6.7': 'screenshot_iPhone_6.7.png', ...}
                
        Returns:
            成功上传的截图字典: {'device_type': 'filename', ...}
        """
        # 设备类型映射
        DEVICE_TYPE_MAPPING = {
            'iPhone_6.7': 'APP_IPHONE_67',
            'iPhone_6.5': 'APP_IPHONE_65',
            'iPhone_5.5': 'APP_IPHONE_55',
            'iPad_12.9_3rd': 'APP_IPAD_PRO_3GEN_129',
            'iPad_12.9_2nd': 'APP_IPAD_PRO_129',
        }
        
        print(f"📸 上传版本截图")
        
        # 记录成功上传的截图
        uploaded_screenshots = {}
        
        # 获取版本的本地化信息（通过版本的关系）
        result = self.make_request("GET", f"appStoreVersions/{version_id}/appStoreVersionLocalizations")
        
        if not result or not result.get("data"):
            print(f"⚠️  未找到版本本地化信息")
            return uploaded_screenshots
        
        # 只为第一个本地化上传截图（通常截图对所有语言是相同的）
        localization = result["data"][0]
        localization_id = localization["id"]
        locale = localization["attributes"]["locale"]
        
        print(f"📱 上传截图 - 语言: {locale}")
        
        # 上传每个设备类型的截图
        for device_type, screenshot_filename in device_screenshot_mapping.items():
            screenshot_path = os.path.join(screenshots_dir, screenshot_filename)
            
            if not os.path.exists(screenshot_path):
                print(f"⚠️  截图不存在: {screenshot_path}")
                continue
            
            # 将设备类型映射到 App Store Connect 的显示类型
            display_type = DEVICE_TYPE_MAPPING.get(device_type)
            
            if not display_type:
                print(f"⚠️  未知的设备类型: {device_type}")
                continue
            
            try:
                self.upload_screenshot(localization_id, screenshot_path, display_type)
                # 只有成功上传才记录
                uploaded_screenshots[device_type] = screenshot_filename
                print(f"✅ {device_type} 截图上传成功")
            except Exception as e:
                print(f"❌ 上传截图失败 ({device_type}): {e}")
                continue
        
        return uploaded_screenshots


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


def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python app_store_connect.py <workspace_path>")
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
    
    # 获取必要的配置
    bundle_id = config.get('appId')
    app_display_name = config.get('appDisplayName', app_name)
    
    # 获取英文应用名称（用于创建 Bundle ID）
    # Bundle ID 名称不支持中文，优先使用英文名称
    app_display_name_en = config.get('appDisplayName_en_US', 
                                     config.get('appDisplayName_en', 
                                     app_display_name))
    
    app_version = config.get('appVersion', '1.0.0')
    sku = config.get('iosSku', bundle_id.replace('.', '-'))
    
    # App Store Connect API 凭证
    api_key_id = os.environ.get('APP_STORE_API_KEY_ID')
    api_issuer_id = os.environ.get('APP_STORE_API_ISSUER_ID')
    api_key_path = os.path.expanduser('~/.appstoreconnect/private_keys/AuthKey_' + api_key_id + '.p8')
    
    if not api_key_id or not api_issuer_id:
        print("❌ 错误: 未设置 APP_STORE_API_KEY_ID 或 APP_STORE_API_ISSUER_ID 环境变量")
        sys.exit(1)
    
    if not os.path.exists(api_key_path):
        print(f"❌ 错误: API 密钥文件不存在: {api_key_path}")
        sys.exit(1)
    
    print(f"Bundle ID: {bundle_id}")
    print(f"应用名称: {app_display_name}")
    print(f"版本: {app_version}")
    print(f"SKU: {sku}")
    print()
    
    # 初始化 API 客户端
    api = AppStoreConnectAPI(api_key_id, api_issuer_id, api_key_path)
    
    # 检查配置
    enable_update_metadata = config.get('enableUpdateMetadata', 'true').lower() == 'true'
    
    print(f"配置: enableUpdateMetadata={enable_update_metadata}")
    print()
    
    # 查找应用（只查找，不创建）
    primary_locale = config.get('iosPrimaryLocale', 'zh-Hans')
    app = api.find_app_by_bundle_id(bundle_id)
    
    if app is None:
        # 应用不存在
        print(f"❌ 应用不存在: {bundle_id}")
        print()
        print("=" * 60)
        print("⚠️  请先在 App Store Connect 手动创建应用")
        print("=" * 60)
        print()
        print("操作步骤：")
        print()
        print("1. 登录 App Store Connect")
        print("   https://appstoreconnect.apple.com/")
        print()
        print("2. 点击「我的 App」→「+」→「新建 App」")
        print()
        print("3. 填写应用信息：")
        print(f"   - 平台: iOS")
        print(f"   - 名称: {app_display_name}")
        print(f"   - 主要语言: {primary_locale}")
        print(f"   - Bundle ID: {bundle_id}")
        print(f"   - SKU: {sku}")
        print()
        print("4. 创建完成后，重新运行构建")
        print()
        print("=" * 60)
        print()
        print("注意: Apple 不支持通过 API 创建新应用")
        print("=" * 60)
        sys.exit(1)
    
    app_id = app['id']
    
    print()
    print(f"✅ 找到应用 (ID: {app_id})")
    print()
    
    # 准备本地化数据
    locale_data = {}
    
    # 支持的语言
    locales = config.get('iosLocales', 'zh-Hans,en-US').split(',')
    
    for locale in locales:
        locale = locale.strip()
        locale_prefix = locale.replace('-', '_')
        
        locale_info = {}
        
        # 应用描述
        if config.get(f'appDescription_{locale_prefix}'):
            locale_info['description'] = config[f'appDescription_{locale_prefix}']
        elif config.get('appDescription'):
            locale_info['description'] = config['appDescription']
        
        # 关键词
        if config.get(f'appKeywords_{locale_prefix}'):
            locale_info['keywords'] = config[f'appKeywords_{locale_prefix}']
        elif config.get('appKeywords'):
            locale_info['keywords'] = config['appKeywords']
        
        # 技术支持网址
        if config.get('appSupportUrl'):
            locale_info['supportUrl'] = config['appSupportUrl']
        
        # 营销网址
        if config.get('appMarketingUrl'):
            locale_info['marketingUrl'] = config['appMarketingUrl']
        
        # 推广文本
        if config.get(f'appPromotionalText_{locale_prefix}'):
            locale_info['promotionalText'] = config[f'appPromotionalText_{locale_prefix}']
        elif config.get('appPromotionalText'):
            locale_info['promotionalText'] = config['appPromotionalText']
        
        # 更新说明
        if config.get(f'appReleaseNotes_{locale_prefix}'):
            locale_info['releaseNotes'] = config[f'appReleaseNotes_{locale_prefix}']
        elif config.get('appReleaseNotes'):
            locale_info['releaseNotes'] = config['appReleaseNotes']
        
        if locale_info:
            locale_data[locale] = locale_info
    
    # 初始化更新汇总
    update_summary = {
        "app_name": app_name,
        "bundle_id": bundle_id,
        "app_id": app_id,
        "version": None,
        "version_localizations": {},
        "app_info_localizations": {},
        "screenshots": {},
        "errors": []
    }
    
    # 获取应用现有版本信息
    version_info = api.get_latest_app_version(app_id)
    
    if not version_info:
        print()
        print("⚠️  无法获取应用版本信息")
        print("提示: 请先在 App Store Connect 手动创建第一个版本")
        print("继续尝试更新应用元数据...")
        version_id = None
        current_version = None
        update_summary["errors"].append("无法获取应用版本信息")
    else:
        version_id = version_info["id"]
        current_version = version_info["versionString"]
        update_summary["version"] = current_version
        print(f"ℹ️  将使用现有版本: {current_version}")
    
    # 根据配置决定是否更新元数据
    if enable_update_metadata:
        print()
        print("🔄 更新元数据已启用")
        
        # 更新版本信息
        if version_id and locale_data:
            try:
                updated_locales = api.update_app_version_info(version_id, current_version, locale_data)
                if updated_locales:
                    # 记录成功更新的版本本地化信息
                    for locale, data in updated_locales.items():
                        update_summary["version_localizations"][locale] = {
                            "description": data.get("description", ""),
                            "keywords": data.get("keywords", ""),
                            "releaseNotes": data.get("releaseNotes", ""),
                            "promotionalText": data.get("promotionalText", ""),
                            "supportUrl": data.get("supportUrl", ""),
                            "marketingUrl": data.get("marketingUrl", "")
                        }
                    print()
                    print(f"✅ 版本本地化信息已更新 ({len(updated_locales)}/{len(locale_data)} 个语言)")
                    
                    # 记录失败的locale
                    failed_locales = set(locale_data.keys()) - set(updated_locales.keys())
                    if failed_locales:
                        for locale in failed_locales:
                            update_summary["errors"].append(f"版本本地化更新失败: {locale}")
                else:
                    print()
                    print("⚠️  版本信息更新失败，但不影响后续流程")
                    print("提示: 可以在 App Store Connect 手动添加版本信息")
                    update_summary["errors"].append("所有版本本地化更新失败")
            except Exception as e:
                print(f"⚠️  版本信息更新异常: {e}")
                print("提示: 继续后续流程...")
                update_summary["errors"].append(f"版本信息更新异常: {str(e)}")
        elif not version_id:
            print()
            print("⚠️  跳过版本信息更新（未找到版本）")
            update_summary["errors"].append("跳过版本信息更新（未找到版本）")
        
        # 更新应用元数据
        metadata = {
            "locales": locales,
            "locale_data": {}
        }
        
        for locale in locales:
            locale = locale.strip()
            locale_prefix = locale.replace('-', '_')
            
            locale_metadata = {}
            
            # name 是必需的，优先使用特定语言的 appDisplayName，否则使用通用的
            if config.get(f'appDisplayName_{locale_prefix}'):
                locale_metadata['name'] = config[f'appDisplayName_{locale_prefix}']
            elif config.get('appDisplayName'):
                locale_metadata['name'] = config['appDisplayName']
            
            if config.get('appPrivacyPolicyUrl'):
                locale_metadata['privacyPolicyUrl'] = config['appPrivacyPolicyUrl']
            
            if config.get(f'appSubtitle_{locale_prefix}'):
                locale_metadata['subtitle'] = config[f'appSubtitle_{locale_prefix}']
            elif config.get('appSubtitle'):
                locale_metadata['subtitle'] = config['appSubtitle']
            
            # 只有当有 name 属性时才添加到 locale_data（因为创建时 name 是必需的）
            if locale_metadata and 'name' in locale_metadata:
                metadata["locale_data"][locale] = locale_metadata
            elif locale_metadata:
                print(f"⚠️  跳过本地化 {locale}，缺少应用名称 (appDisplayName)")

        
        if metadata["locale_data"]:
            try:
                api.update_app_info_metadata(app_id, metadata)
                # 记录更新的应用信息本地化
                for locale, data in metadata["locale_data"].items():
                    update_summary["app_info_localizations"][locale] = {
                        "name": data.get("name", ""),
                        "subtitle": data.get("subtitle", ""),
                        "privacyPolicyUrl": data.get("privacyPolicyUrl", "")
                    }
            except Exception as e:
                print(f"⚠️  应用元数据更新异常: {e}")
                print("提示: 继续后续流程...")
                update_summary["errors"].append(f"应用元数据更新异常: {str(e)}")
    else:
        print()
        print("ℹ️  元数据更新已禁用 (enableUpdateMetadata=false)")
        print("提示: 如需更新应用元数据，请在 app.cfg 中设置 enableUpdateMetadata=true")
    
    # 上传截图（如果启用）
    enable_screenshots = config.get('enableScreenshotUpload', 'false').lower() == 'true'
    
    if enable_screenshots:
        print()
        print("📸 准备上传截图...")
        
        if not version_id:
            print(f"⚠️  无法上传截图：未找到应用版本")
            print(f"提示: 请先在 App Store Connect 中创建版本")
            update_summary["errors"].append("无法上传截图：未找到应用版本")
        else:
            # 检查截图目录
            screenshots_dir = os.path.join(workspace_path, "screenshots", app_name)
            screenshots_json = os.path.join(screenshots_dir, "screenshots.json")
            
            if os.path.exists(screenshots_json):
                print(f"✅ 找到截图列表: {screenshots_json}")
                print(f"🔍 使用版本 {current_version} (ID: {version_id}) 上传截图...")
                
                # 读取截图映射
                with open(screenshots_json, 'r') as f:
                    screenshot_mapping = json.load(f)
                
                # 将截图文件名映射转换为完整路径映射
                screenshot_files = {}
                for device_type, filename in screenshot_mapping.items():
                    screenshot_files[device_type] = os.path.basename(filename)
                
                # 上传截图
                try:
                    uploaded_screenshots = api.upload_screenshots_for_version(version_id, screenshots_dir, screenshot_files)
                    
                    # 记录成功上传的截图
                    if uploaded_screenshots:
                        for device_type, filename in uploaded_screenshots.items():
                            update_summary["screenshots"][device_type] = filename
                        print(f"✅ 截图上传完成 ({len(uploaded_screenshots)}/{len(screenshot_files)})")
                    else:
                        print(f"⚠️  所有截图上传失败")
                        update_summary["errors"].append("所有截图上传失败")
                    
                    # 记录失败的截图
                    failed_screenshots = set(screenshot_files.keys()) - set(uploaded_screenshots.keys())
                    if failed_screenshots:
                        for device_type in failed_screenshots:
                            update_summary["errors"].append(f"截图上传失败: {device_type}")
                        
                except Exception as e:
                    print(f"⚠️  截图上传异常: {e}")
                    print(f"提示: 截图上传失败不影响应用创建，可以稍后在 App Store Connect 手动上传")
                    update_summary["errors"].append(f"截图上传异常: {str(e)}")
            else:
                print(f"⚠️  未找到截图文件: {screenshots_json}")
                print(f"提示: 如需上传截图，请先运行 generate_app_screenshots.py 生成截图")
                update_summary["errors"].append("未找到截图文件")
    else:
        print()
        print("ℹ️  截图上传已禁用 (enableScreenshotUpload=false)")
    
    # 打印详细的更新汇总
    print()
    print("=" * 80)
    print("📊 元数据更新汇总报告")
    print("=" * 80)
    print()
    
    # 基本信息
    print("📱 应用信息:")
    print(f"  • 应用名称: {update_summary['app_name']}")
    print(f"  • Bundle ID: {update_summary['bundle_id']}")
    print(f"  • App ID: {update_summary['app_id']}")
    if update_summary['version']:
        print(f"  • 版本号: {update_summary['version']}")
    else:
        print(f"  • 版本号: ⚠️ 未获取到版本信息")
    print()
    
    # 版本本地化信息
    if update_summary['version_localizations']:
        print("📝 版本本地化信息更新:")
        for locale, data in update_summary['version_localizations'].items():
            print(f"  🌐 {locale}:")
            if data.get('description'):
                desc_preview = data['description'][:60] + "..." if len(data['description']) > 60 else data['description']
                print(f"    ✓ 应用描述: {desc_preview}")
            if data.get('keywords'):
                print(f"    ✓ 关键词: {data['keywords']}")
            if data.get('releaseNotes'):
                notes_preview = data['releaseNotes'][:60] + "..." if len(data['releaseNotes']) > 60 else data['releaseNotes']
                print(f"    ✓ 更新说明: {notes_preview}")
            if data.get('promotionalText'):
                promo_preview = data['promotionalText'][:60] + "..." if len(data['promotionalText']) > 60 else data['promotionalText']
                print(f"    ✓ 推广文本: {promo_preview}")
            if data.get('supportUrl'):
                print(f"    ✓ 技术支持网址: {data['supportUrl']}")
            if data.get('marketingUrl'):
                print(f"    ✓ 营销网址: {data['marketingUrl']}")
        print()
    else:
        if enable_update_metadata and version_id:
            print("⚠️  版本本地化信息: 未更新")
            print()
    
    # 应用信息本地化
    if update_summary['app_info_localizations']:
        print("ℹ️  应用信息本地化更新:")
        for locale, data in update_summary['app_info_localizations'].items():
            print(f"  🌐 {locale}:")
            if data.get('name'):
                print(f"    ✓ 应用名称: {data['name']}")
            if data.get('subtitle'):
                print(f"    ✓ 副标题: {data['subtitle']}")
            if data.get('privacyPolicyUrl'):
                print(f"    ✓ 隐私政策网址: {data['privacyPolicyUrl']}")
        print()
    else:
        if enable_update_metadata:
            print("⚠️  应用信息本地化: 未更新")
            print()
    
    # 截图上传
    if update_summary['screenshots']:
        print("📸 截图上传:")
        for device_type, filename in update_summary['screenshots'].items():
            print(f"  ✓ {device_type}: {filename}")
        print()
    else:
        if enable_screenshots:
            print("⚠️  截图: 未上传")
            print()
    
    # 错误和警告
    if update_summary['errors']:
        print("⚠️  警告/错误:")
        for error in update_summary['errors']:
            print(f"  • {error}")
        print()
    
    # 配置状态
    print("⚙️  配置状态:")
    print(f"  • App Store Connect: {'✅ 已启用' if config.get('enableAppStoreConnect', 'false').lower() == 'true' else '❌ 已禁用'}")
    print(f"  • 元数据更新: {'✅ 已启用' if enable_update_metadata else '❌ 已禁用'}")
    print(f"  • 截图上传: {'✅ 已启用' if enable_screenshots else '❌ 已禁用'}")
    print()
    
    print("=" * 80)
    print("✅ 所有操作完成!")
    print("=" * 80)


if __name__ == "__main__":
    main()

