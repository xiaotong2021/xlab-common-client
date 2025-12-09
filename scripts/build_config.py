#!/usr/bin/env python3
"""
配置文件读取和替换脚本
用于从 assets 目录读取配置并替换项目文件中的占位符
"""

import os
import sys
import re
import shutil
from pathlib import Path


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
    
    def copy_resources(self, app_name):
        """复制资源文件到项目目录"""
        app_assets_dir = self.assets_dir / app_name
        
        # 复制Android资源
        android_res_dir = self.android_dir / "app" / "src" / "main" / "res"
        
        # 复制loading图片到drawable
        loading_img = app_assets_dir / self.config.get('loadingImage', 'loading.png')
        if loading_img.exists():
            drawable_dir = android_res_dir / "drawable"
            drawable_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy(loading_img, drawable_dir / "loading.png")
            print(f"Copied: {loading_img} -> {drawable_dir / 'loading.png'}")
        
        # 复制iOS资源
        ios_assets_dir = self.ios_dir / "WebViewApp" / "Assets.xcassets"
        
        # 复制loading图片
        if loading_img.exists():
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
    
    def configure_android(self, app_name):
        """配置Android项目"""
        print("\n=== Configuring Android ===")
        
        # 准备替换映射
        is_debug = self.parse_boolean(self.config.get('isDebug', 'true'))
        package_name = self.config.get('appId', 'com.mywebviewapp')
        package_path = package_name.replace('.', '/')
        
        # 创建包目录
        src_dir = self.android_dir / "app" / "src" / "main" / "java" / package_path
        src_dir.mkdir(parents=True, exist_ok=True)
        
        # 移动Kotlin文件到正确的包目录
        old_package_dir = self.android_dir / "app" / "src" / "main" / "java" / "com" / "mywebviewapp"
        if old_package_dir.exists() and old_package_dir != src_dir:
            for kt_file in old_package_dir.glob("*.kt"):
                shutil.move(str(kt_file), str(src_dir / kt_file.name))
            # 删除旧目录
            try:
                shutil.rmtree(old_package_dir.parent.parent)
            except:
                pass
        
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
            '__SIGNING_CONFIG__': 'signingConfig signingConfigs.release' if not is_debug else 'signingConfig null',
            '__USES_CLEARTEXT_TRAFFIC__': 'true' if not self.parse_boolean(self.config.get('enableHttps', 'true')) else 'false',
            
            # WebView配置
            '__LOAD_URL__': self.config.get('loadUrl', 'https://www.baidu.com'),
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
        
        # 替换文件
        files_to_replace = [
            self.android_dir / "app" / "build.gradle",
            self.android_dir / "app" / "src" / "main" / "AndroidManifest.xml",
            self.android_dir / "app" / "src" / "main" / "res" / "values" / "strings.xml",
        ]
        
        for kt_file in src_dir.glob("*.kt"):
            files_to_replace.append(kt_file)
        
        for file_path in files_to_replace:
            self.replace_file_content(file_path, replacements)
    
    def configure_ios(self, app_name):
        """配置iOS项目"""
        print("\n=== Configuring iOS ===")
        
        is_debug = self.parse_boolean(self.config.get('isDebug', 'true'))
        
        replacements = {
            '__APP_NAME__': self.config.get('appName', 'MyWebView'),
            '__APP_DISPLAY_NAME__': self.config.get('iosBundle DisplayName', self.config.get('appDisplayName', 'MyWebView')),
            '__APP_ID__': self.config.get('appId', 'com.mywebviewapp'),
            '__APP_VERSION__': self.config.get('appVersion', '1.0.0'),
            '__BUILD_NUMBER__': self.config.get('iosBuildNumber', self.config.get('buildNumber', '1')),
            '__BUNDLE_ID__': self.config.get('iosBundleId', self.config.get('appId', 'com.mywebviewapp')),
            '__VERSION__': self.config.get('iosBundleVersion', self.config.get('appVersion', '1.0.0')),
            '__IOS_DEPLOYMENT_TARGET__': self.config.get('iosDeploymentTarget', '13.0'),
            '__TEAM_ID__': self.config.get('iosTeamId', 'PLACEHOLDER_TEAM_ID') if not is_debug else '',
            '__CERTIFICATE_NAME__': self.config.get('iosCertificateName', 'PLACEHOLDER_CERTIFICATE_NAME'),
            '__PROVISIONING_PROFILE__': self.config.get('iosProvisioningProfile', 'PLACEHOLDER_PROVISIONING_PROFILE'),
            '__CODE_SIGN_STYLE__': 'Manual' if not is_debug else 'Automatic',
            '__ALLOWS_ARBITRARY_LOADS__': 'true' if not self.parse_boolean(self.config.get('enableHttps', 'true')) else 'false',
            
            # WebView配置 (与Android相同)
            '__LOAD_URL__': self.config.get('loadUrl', 'https://www.baidu.com'),
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
