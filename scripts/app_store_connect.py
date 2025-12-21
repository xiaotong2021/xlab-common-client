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
    
    def find_bundle_id(self, identifier):
        """
        查找 Bundle ID
        
        Args:
            identifier: Bundle ID 标识符 (如 com.example.app)
            
        Returns:
            Bundle ID 信息，如果不存在则返回 None
        """
        print(f"🔍 查找 Bundle ID: {identifier}")
        
        try:
            # 使用 filter 查询 Bundle ID
            params = {"filter[identifier]": identifier}
            result = self.make_request("GET", "bundleIds", params=params)
            
            if result and result.get("data") and len(result["data"]) > 0:
                bundle_id_info = result["data"][0]
                print(f"✅ 找到 Bundle ID: {bundle_id_info['id']}")
                return bundle_id_info
            else:
                print(f"❌ 未找到 Bundle ID: {identifier}")
                return None
        except Exception as e:
            print(f"⚠️  查找 Bundle ID 失败: {e}")
            return None
    
    def create_bundle_id(self, identifier, name, platform="IOS"):
        """
        创建 Bundle ID
        
        Args:
            identifier: Bundle ID 标识符 (如 com.example.app)
            name: 显示名称
            platform: 平台 (IOS, MAC_OS)
            
        Returns:
            创建的 Bundle ID 信息
        """
        print(f"🆔 创建 Bundle ID: {name} ({identifier})")
        
        data = {
            "data": {
                "type": "bundleIds",
                "attributes": {
                    "identifier": identifier,
                    "name": name,
                    "platform": platform
                }
            }
        }
        
        try:
            result = self.make_request("POST", "bundleIds", data=data)
            print(f"✅ Bundle ID 创建成功: {result['data']['id']}")
            return result["data"]
        except Exception as e:
            print(f"❌ Bundle ID 创建失败: {e}")
            raise
    
    def get_or_create_bundle_id(self, identifier, name):
        """
        获取或创建 Bundle ID
        
        Args:
            identifier: Bundle ID 标识符
            name: 显示名称
            
        Returns:
            Bundle ID 信息
        """
        bundle_id = self.find_bundle_id(identifier)
        
        if bundle_id is None:
            print(f"📝 Bundle ID 不存在，尝试创建...")
            bundle_id = self.create_bundle_id(identifier, name)
        
        return bundle_id
    
    def create_app(self, bundle_id, name, primary_locale, sku):
        """
        创建新应用
        
        注意：创建应用前，必须先确保 Bundle ID 已在 Apple Developer Portal 中注册
        
        Args:
            bundle_id: Bundle ID
            name: 应用名称
            primary_locale: 主要语言 (如: zh-Hans, en-US)
            sku: SKU (唯一标识符)
            
        Returns:
            创建的应用信息
        """
        print()
        print("=" * 60)
        print("步骤 1/2: 检查/注册 Bundle ID")
        print("=" * 60)
        
        # 先确保 Bundle ID 存在
        try:
            self.get_or_create_bundle_id(bundle_id, name)
        except Exception as e:
            print(f"⚠️  Bundle ID 处理失败: {e}")
            print(f"提示: 请在 Apple Developer Portal 手动注册 Bundle ID")
            print(f"     或检查 API 密钥是否有 'Admin' 或 'Account Holder' 权限")
            # 继续尝试创建应用（Bundle ID 可能已在开发者门户手动创建）
        
        print()
        print("=" * 60)
        print("步骤 2/2: 创建 App Store Connect 应用")
        print("=" * 60)
        print(f"🚀 创建应用: {name} ({bundle_id})")
        
        data = {
            "data": {
                "type": "apps",
                "attributes": {
                    "bundleId": bundle_id,
                    "name": name,
                    "primaryLocale": primary_locale,
                    "sku": sku
                }
            }
        }
        
        try:
            result = self.make_request("POST", "apps", data=data)
            print(f"✅ 应用创建成功!")
            return result["data"]
        except Exception as e:
            print(f"❌ 应用创建失败: {e}")
            raise
    
    def get_or_create_app(self, bundle_id, name, primary_locale, sku):
        """
        获取或创建应用
        
        Args:
            bundle_id: Bundle ID
            name: 应用名称
            primary_locale: 主要语言
            sku: SKU
            
        Returns:
            应用信息
        """
        app = self.find_app_by_bundle_id(bundle_id)
        
        if app is None:
            app = self.create_app(bundle_id, name, primary_locale, sku)
        
        return app
    
    def get_app_info(self, app_id):
        """
        获取应用详细信息
        
        Args:
            app_id: 应用 ID
            
        Returns:
            应用信息
        """
        return self.make_request("GET", f"apps/{app_id}")
    
    def create_or_update_app_info(self, app_id, version_string, locale_data):
        """
        创建或更新应用版本信息
        
        Args:
            app_id: 应用 ID
            version_string: 版本号
            locale_data: 本地化数据字典，包含：
                - description: 应用描述
                - keywords: 关键词
                - releaseNotes: 更新说明
                - supportUrl: 技术支持网址
                - marketingUrl: 营销网址
                - promotionalText: 推广文本
                
        Returns:
            版本信息
        """
        print(f"📝 更新应用版本信息: {version_string}")
        
        # 通过 app 的关系获取版本列表
        # 注意：不能直接查询 appStoreVersions 集合，需要通过 app 的关系
        try:
            result = self.make_request("GET", f"apps/{app_id}/appStoreVersions")
            
            # 查找匹配的版本
            version_id = None
            if result and result.get("data"):
                for version in result["data"]:
                    if (version["attributes"].get("versionString") == version_string and
                        version["attributes"].get("platform") == "IOS"):
                        version_id = version["id"]
                        print(f"✅ 找到现有版本: {version_id}")
                        break
            
            # 如果没找到，创建新版本
            if not version_id:
                print(f"🆕 创建新版本: {version_string}")
                data = {
                    "data": {
                        "type": "appStoreVersions",
                        "attributes": {
                            "platform": "IOS",
                            "versionString": version_string
                        },
                        "relationships": {
                            "app": {
                                "data": {
                                    "type": "apps",
                                    "id": app_id
                                }
                            }
                        }
                    }
                }
                try:
                    result = self.make_request("POST", "appStoreVersions", data=data)
                    version_id = result["data"]["id"]
                    print(f"✅ 版本创建成功: {version_id}")
                except Exception as e:
                    print(f"⚠️  创建版本失败: {e}")
                    print(f"提示: 版本可能已存在或应用状态不允许创建新版本")
                    
                    # 尝试再次查找版本（可能版本在创建失败前已存在）
                    print(f"🔍 尝试查找现有版本...")
                    try:
                        result = self.make_request("GET", f"apps/{app_id}/appStoreVersions")
                        if result and result.get("data"):
                            # 查找所有状态的版本
                            for version in result["data"]:
                                if version["attributes"].get("versionString") == version_string:
                                    version_id = version["id"]
                                    version_state = version["attributes"].get("appStoreState", "UNKNOWN")
                                    print(f"✅ 找到现有版本: {version_id} (状态: {version_state})")
                                    break
                    except Exception as retry_error:
                        print(f"⚠️  查找版本失败: {retry_error}")
                    
                    if not version_id:
                        print(f"❌ 无法获取版本信息，跳过版本更新")
                        return None
            
            # 更新本地化信息
            if version_id:
                self.update_version_localizations(version_id, locale_data)
            
            return {"id": version_id}
            
        except Exception as e:
            print(f"⚠️  无法访问应用版本信息: {e}")
            print(f"提示: 这可能是因为应用还没有任何版本，或者 API 权限不足")
            print(f"建议: 在 App Store Connect 手动创建第一个版本后再使用此功能")
            return None
    
    def update_version_localizations(self, version_id, locale_data):
        """
        更新版本本地化信息
        
        Args:
            version_id: 版本 ID
            locale_data: 本地化数据字典，key为语言代码
        """
        for locale, data in locale_data.items():
            print(f"🌐 更新本地化信息: {locale}")
            
            # 查找现有本地化（通过版本的关系）
            result = self.make_request("GET", f"appStoreVersions/{version_id}/appStoreVersionLocalizations")
            
            localization_data = {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "attributes": {
                        "locale": locale
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
            
            if result and result.get("data"):
                # 更新现有本地化
                loc_id = result["data"][0]["id"]
                # 注意：UPDATE 请求中不能包含 locale 属性
                update_data = {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": loc_id,
                        "attributes": {}
                    }
                }
                
                # 只包含需要更新的属性（不包括 locale）
                if "description" in data:
                    update_data["data"]["attributes"]["description"] = data["description"]
                if "keywords" in data:
                    update_data["data"]["attributes"]["keywords"] = data["keywords"]
                if "releaseNotes" in data:
                    update_data["data"]["attributes"]["whatsNew"] = data["releaseNotes"]
                if "supportUrl" in data:
                    update_data["data"]["attributes"]["supportUrl"] = data["supportUrl"]
                if "marketingUrl" in data:
                    update_data["data"]["attributes"]["marketingUrl"] = data["marketingUrl"]
                if "promotionalText" in data:
                    update_data["data"]["attributes"]["promotionalText"] = data["promotionalText"]
                
                self.make_request("PATCH", f"appStoreVersionLocalizations/{loc_id}", data=update_data)
            else:
                # 创建新本地化
                localization_data["data"]["relationships"] = {
                    "appStoreVersion": {
                        "data": {
                            "type": "appStoreVersions",
                            "id": version_id
                        }
                    }
                }
                self.make_request("POST", "appStoreVersionLocalizations", data=localization_data)
            
            print(f"✅ 本地化信息已更新: {locale}")
    
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
        
        # 查找或创建截图集
        params = {
            "filter[appStoreVersionLocalization]": version_localization_id,
            "filter[screenshotDisplayType]": display_type
        }
        
        result = self.make_request("GET", "appScreenshotSets", params=params)
        
        if result and result.get("data"):
            screenshot_set_id = result["data"][0]["id"]
            print(f"✅ 找到现有截图集: {screenshot_set_id}")
        else:
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
        
        # 获取版本的本地化信息（通过版本的关系）
        result = self.make_request("GET", f"appStoreVersions/{version_id}/appStoreVersionLocalizations")
        
        if not result or not result.get("data"):
            print(f"⚠️  未找到版本本地化信息")
            return
        
        # 为每个本地化上传截图
        for localization in result["data"]:
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
                except Exception as e:
                    print(f"❌ 上传截图失败 ({device_type}): {e}")
                    continue


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
    enable_create_app = config.get('enableCreateApp', 'true').lower() == 'true'
    enable_update_metadata = config.get('enableUpdateMetadata', 'true').lower() == 'true'
    
    print(f"配置: enableCreateApp={enable_create_app}, enableUpdateMetadata={enable_update_metadata}")
    print()
    
    # 获取或创建应用
    primary_locale = config.get('iosPrimaryLocale', 'zh-Hans')
    
    # 首先尝试查找应用
    app = api.find_app_by_bundle_id(bundle_id)
    
    if app is None:
        # 应用不存在
        if enable_create_app:
            print(f"📱 应用不存在，尝试创建...")
            try:
                app = api.create_app(bundle_id, app_display_name, primary_locale, sku)
            except Exception as e:
                print(f"❌ 应用创建失败: {e}")
                print(f"提示: 请检查 Bundle ID 是否已被使用，或在 App Store Connect 手动创建应用")
                sys.exit(1)
        else:
            print(f"❌ 应用不存在，且 enableCreateApp=false")
            print(f"提示: 请在 App Store Connect 手动创建应用，或设置 enableCreateApp=true")
            sys.exit(1)
    
    app_id = app['id']
    
    print()
    print(f"✅ 应用准备完成 (ID: {app_id})")
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
    
    # 根据配置决定是否更新元数据
    if enable_update_metadata:
        print()
        print("🔄 更新元数据已启用")
        
        # 更新版本信息
        if locale_data:
            try:
                version_result = api.create_or_update_app_info(app_id, app_version, locale_data)
                if not version_result:
                    print()
                    print("⚠️  版本信息更新失败，但不影响后续流程")
                    print("提示: 可以在 App Store Connect 手动添加版本信息")
            except Exception as e:
                print(f"⚠️  版本信息更新异常: {e}")
                print("提示: 继续后续流程...")
        
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
            except Exception as e:
                print(f"⚠️  应用元数据更新异常: {e}")
                print("提示: 继续后续流程...")
    else:
        print()
        print("ℹ️  元数据更新已禁用 (enableUpdateMetadata=false)")
        print("提示: 如需更新应用元数据，请在 app.cfg 中设置 enableUpdateMetadata=true")
    
    # 上传截图（如果启用）
    enable_screenshots = config.get('enableScreenshotUpload', 'false').lower() == 'true'
    
    if enable_screenshots:
        print()
        print("📸 准备上传截图...")
        
        # 检查截图目录
        screenshots_dir = os.path.join(workspace_path, "screenshots", app_name)
        screenshots_json = os.path.join(screenshots_dir, "screenshots.json")
        
        if os.path.exists(screenshots_json):
            print(f"✅ 找到截图列表: {screenshots_json}")
            
            # 读取截图映射
            with open(screenshots_json, 'r') as f:
                screenshot_mapping = json.load(f)
            
            # 获取版本 ID（通过 app 的关系）
            print(f"🔍 查找版本 {app_version} 用于上传截图...")
            result = api.make_request("GET", f"apps/{app_id}/appStoreVersions")
            
            version_id = None
            version_state = None
            if result and result.get("data"):
                # 查找匹配的版本（任何状态）
                for version in result["data"]:
                    if version["attributes"].get("versionString") == app_version:
                        version_id = version["id"]
                        version_state = version["attributes"].get("appStoreState", "UNKNOWN")
                        print(f"✅ 找到版本: {version_id} (状态: {version_state})")
                        break
            
            if not version_id:
                print(f"⚠️  未找到版本 {app_version}，跳过截图上传")
                print(f"提示: 请确保版本已在 App Store Connect 中创建")
            elif version_id:
                
                # 将截图文件名映射转换为完整路径映射
                screenshot_files = {}
                for device_type, filename in screenshot_mapping.items():
                    screenshot_files[device_type] = os.path.basename(filename)
                
                # 上传截图
                try:
                    api.upload_screenshots_for_version(version_id, screenshots_dir, screenshot_files)
                    print(f"✅ 截图上传完成")
                except Exception as e:
                    print(f"⚠️  截图上传失败: {e}")
                    print(f"提示: 截图上传失败不影响应用创建，可以稍后在 App Store Connect 手动上传")
        else:
            print(f"⚠️  未找到截图文件: {screenshots_json}")
            print(f"提示: 如需上传截图，请先运行 generate_app_screenshots.py 生成截图")
    else:
        print()
        print("ℹ️  截图上传已禁用 (enableScreenshotUpload=false)")
    
    print()
    print("=" * 60)
    print("✅ 所有操作完成!")
    print("=" * 60)


if __name__ == "__main__":
    main()

