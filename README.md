# 跨平台 WebView 应用框架

一个基于配置的跨平台 WebView 应用框架，支持 Android 和 iOS 平台。通过简单的配置文件即可快速构建和打包不同的 WebView 应用。

---

## ✨ 特性

- 🚀 **快速构建**：通过配置文件快速生成不同的应用
- 📱 **跨平台支持**：同时支持 Android (Kotlin) 和 iOS (Swift)
- ⚙️ **高度可配置**：应用名称、图标、WebView URL 等均可配置
- 🔄 **自动化打包**：GitHub Actions 自动构建和发布
- 🎨 **自定义 UI**：支持自定义启动页、加载动画等
- 🔐 **Debug/Release 模式**：支持调试和生产两种构建模式
- 📦 **资源管理**：统一管理应用图标、启动图等资源
- 📴 **离线支持**：可将在线HTML下载打包，支持无网络环境使用

---

## 📋 目录

- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [配置说明](#配置说明)
- [构建应用](#构建应用)
- [GitHub Actions 自动打包](#github-actions-自动打包)
- [文档](#文档)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd <your-repo-name>
```

### 2. 配置应用

编辑 `assets/build.app`，指定要构建的应用：

```properties
appName=app1
```

编辑 `assets/app1/app.cfg`，配置应用信息：

```properties
# 应用基本信息
appName=我的WebView
appDisplayName=MyWebView
appId=com.mywebviewapp
appVersion=1.0.0
buildNumber=1

# 更多配置见配置文件...
```

### 3. 准备资源文件

将应用资源放入 `assets/app1/` 目录：

```
assets/app1/
├── app.cfg           # 配置文件
├── icon.png          # 应用图标
├── loading.png       # 启动页图片
└── splash.png        # 闪屏图片
```

### 4. 运行配置脚本

```bash
python3 scripts/build_config.py
```

### 5. 构建应用

**Android:**

```bash
cd android
./gradlew assembleDebug  # Debug 版本
./gradlew assembleRelease  # Release 版本
```

**iOS:**

```bash
cd ios
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Debug \
  -sdk iphonesimulator
```

---

## 📁 项目结构

```
.
├── android/                    # Android 项目
│   ├── app/
│   │   ├── build.gradle        # Android 构建配置
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── java/       # Kotlin 源代码
│   │           └── res/        # Android 资源
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradlew                 # Gradle 包装器
│
├── ios/                        # iOS 项目
│   ├── WebViewApp.xcodeproj/   # Xcode 项目
│   └── WebViewApp/
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       ├── LoadingViewController.swift
│       ├── MainViewController.swift
│       ├── AppConfig.swift
│       ├── Info.plist
│       └── Assets.xcassets/    # iOS 资源
│
├── assets/                     # 应用配置和资源
│   ├── build.app               # 指定要构建的应用
│   └── app1/                   # 应用1的配置
│       ├── app.cfg             # 配置文件
│       ├── icon.png            # 应用图标
│       ├── loading.png         # 启动页图片
│       └── splash.png          # 闪屏图片
│
├── scripts/                    # 构建脚本
│   └── build_config.py         # 配置替换脚本
│
├── docs/                       # 文档
│   ├── Android打包说明.md
│   └── iOS打包说明.md
│
├── .github/
│   └── workflows/
│       └── build.yml           # GitHub Actions 工作流
│
└── README.md                   # 项目说明
```

---

## ⚙️ 配置说明

### assets/build.app

指定要构建的应用名称：

```properties
appName=app1
```

### assets/app1/app.cfg

应用配置文件，支持以下配置项：

#### 应用基本信息

```properties
appName=我的WebView               # 应用名称
appDisplayName=MyWebView          # 显示名称
appId=com.mywebviewapp            # Bundle ID / Package Name
appVersion=1.0.0                  # 版本号
buildNumber=1                     # 构建号
```

#### 构建配置

```properties
buildAndroid=true                 # 是否构建 Android
buildIOS=true                     # 是否构建 iOS
isDebug=true                      # Debug 模式（true）或 Release 模式（false）
```

#### WebView 配置

```properties
loadUrl=https://www.baidu.com     # 要加载的 URL
isWebLocal=false                  # 是否使用本地HTML（离线模式）
enableJavaScript=true             # 启用 JavaScript
enableDOMStorage=true             # 启用 DOM 存储
enableCache=true                  # 启用缓存
allowFileAccess=false             # 允许文件访问
mixedContentMode=NEVER            # 混合内容模式
userAgentString=                  # 自定义 User Agent
```

**离线模式说明：**
- 当 `isWebLocal=true` 时，构建脚本会自动下载 `loadUrl` 指定的HTML及其所有资源
- 下载的内容会与应用一起打包，支持无网络环境下使用
- 详细配置请参考 [离线HTML加载配置说明](docs/离线HTML加载配置说明.md)

#### Loading 页面配置

```properties
loadingDuration=1000              # 启动页持续时间（毫秒）
loadingBackgroundColor=#4A90E2    # 背景颜色
loadingTextColor=#FFFFFF          # 文字颜色
loadingText=加载中...             # 加载文字
```

#### Android 特定配置

```properties
androidMinSdkVersion=21           # 最低 SDK 版本
androidTargetSdkVersion=34        # 目标 SDK 版本
androidCompileSdkVersion=34       # 编译 SDK 版本
androidKeyAlias=myapp             # 密钥别名
androidKeyPassword=***            # 密钥密码（占位符）
androidStorePassword=***          # 密钥库密码（占位符）
androidKeystoreFile=devdroid.jks  # 密钥库文件名
```

#### iOS 特定配置

```properties
iosDeploymentTarget=13.0          # 最低系统版本
iosBundleId=com.mywebviewapp      # Bundle ID
iosTeamId=PLACEHOLDER_TEAM_ID     # Team ID
iosCertificateName=***            # 证书名称（占位符）
iosProvisioningProfile=***        # Provisioning Profile（占位符）
iosExportMethod=app-store         # 导出方式
```

#### UI 配置

```properties
showLoadingProgress=true          # 显示加载进度
showErrorPage=true                # 显示错误页面
errorPageTitle=加载失败           # 错误页面标题
errorPageMessage=页面加载失败...  # 错误信息
errorButtonText=重试              # 错误页面按钮文字
```

#### 高级配置

```properties
enableDebugging=true              # 启用调试
clearCacheOnStart=false           # 启动时清除缓存
enableZoom=true                   # 启用缩放
supportMultipleWindows=false      # 支持多窗口
```

---

## 🔨 构建应用

### 方式 1：本地构建

#### Android

```bash
# 1. 运行配置脚本
python3 scripts/build_config.py

# 2. 构建 APK
cd android

# Debug 版本
./gradlew assembleDebug

# Release 版本（需要配置签名）
./gradlew assembleRelease

# 输出路径
# Debug: android/app/build/outputs/apk/debug/app-debug.apk
# Release: android/app/build/outputs/apk/release/app-release.apk
```

#### iOS

```bash
# 1. 运行配置脚本
python3 scripts/build_config.py

# 2. 使用 Xcode 构建
open ios/WebViewApp.xcodeproj

# 或者使用命令行
cd ios

# Debug 版本（模拟器）
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build

# Release 版本（需要证书）
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/WebViewApp.xcarchive \
  archive
```

### 方式 2：GitHub Actions 自动构建

推送带 `v*` 前缀的标签即可触发自动构建：

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动：
1. 读取配置文件
2. 根据配置决定构建哪些平台
3. 构建 Android APK 和/或 iOS IPA
4. 创建 GitHub Release 并上传构建产物

---

## 🤖 GitHub Actions 自动打包

### 配置 GitHub Secrets

#### Android Secrets（Release 模式需要）

| Secret 名称                    | 说明                        |
|-------------------------------|----------------------------|
| `ANDROID_KEYSTORE_BASE64`     | Keystore 文件的 Base64 编码 |
| `ANDROID_KEYSTORE_FILE`       | Keystore 文件名             |
| `ANDROID_KEYSTORE_PASSWORD`   | Keystore 密码               |
| `ANDROID_KEY_ALIAS`           | 密钥别名                    |
| `ANDROID_KEY_PASSWORD`        | 密钥密码                    |

#### iOS Secrets（Release 模式需要）

| Secret 名称                          | 说明                               |
|-------------------------------------|-----------------------------------|
| `IOS_CERTIFICATE_BASE64`            | 证书（.p12）的 Base64 编码          |
| `IOS_CERTIFICATE_PASSWORD`          | 证书密码                           |
| `IOS_PROVISIONING_PROFILE_BASE64`   | Provisioning Profile 的 Base64 编码 |
| `IOS_TEAM_ID`                       | Apple Developer Team ID            |
| `IOS_EXPORT_METHOD`                 | 导出方式（app-store / ad-hoc）     |
| `KEYCHAIN_PASSWORD`                 | 临时 Keychain 密码                 |

### 触发构建

```bash
# 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

### 构建流程

1. **Prepare**：读取配置，确定构建目标
2. **Build Android**：构建 Android APK（如果启用）
3. **Build iOS**：构建 iOS IPA（如果启用）
4. **Release**：创建 GitHub Release 并上传构建产物

---

## 📚 文档

详细文档请参考：

- [快速开始指南](docs/快速开始指南.md)
  - 基础配置
  - 资源准备
  - 构建流程

- [配置文件说明](docs/配置文件说明.md)
  - 完整配置项说明
  - 最佳实践

- [离线HTML加载配置说明](docs/离线HTML加载配置说明.md)
  - 启用离线模式
  - Web内容下载
  - 故障排除

- **[证书和密钥配置指南](docs/证书和密钥配置指南.md)** ⭐️ **推荐阅读**
  - Android Keystore 创建和配置
  - iOS 证书和 Provisioning Profile 获取
  - GitHub Secrets 配置完整教程
  - 应用上架 Google Play 和 App Store 流程
  - 常见问题解答

- [Android 打包说明](docs/Android打包说明.md)
  - 生成签名密钥库
  - 配置 GitHub Secrets
  - 本地打包测试
  - 上架 Google Play
  
- [iOS 打包说明](docs/iOS打包说明.md)
  - 注册 Apple Developer 账号
  - 创建证书和 Provisioning Profile
  - 配置 GitHub Secrets
  - 上架 App Store

- [快速开始指南](docs/快速开始指南.md)
  - 项目初始化
  - 配置文件说明
  - 本地开发调试

- [配置文件说明](docs/配置文件说明.md)
  - 完整的配置项列表
  - 配置示例
  - 最佳实践

---

## 🎯 使用场景

### 场景 1：快速构建测试应用

1. 修改 `assets/app1/app.cfg`，设置 `isDebug=true`
2. 运行 `python3 scripts/build_config.py`
3. 构建 Debug 版本进行测试

### 场景 2：为不同客户构建应用

1. 复制 `assets/app1/` 为 `assets/app2/`
2. 修改 `assets/app2/app.cfg`，更新应用信息和 URL
3. 修改 `assets/build.app`，设置 `appName=app2`
4. 运行构建脚本

### 场景 3：自动发布生产版本

1. 配置 GitHub Secrets（证书、密钥等）
2. 设置 `isDebug=false`
3. 提交代码并打标签 `v1.0.0`
4. GitHub Actions 自动构建并创建 Release

---

## 🔧 常见问题

### 1. Python 脚本执行失败

**问题：** `python3: command not found`

**解决：** 安装 Python 3

```bash
# macOS
brew install python3

# Ubuntu/Debian
sudo apt-get install python3

# Windows
# 从 python.org 下载安装
```

### 2. Android 构建失败

**问题：** `JAVA_HOME is not set`

**解决：** 安装并配置 JDK 17

```bash
# macOS
brew install openjdk@17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Ubuntu/Debian
sudo apt-get install openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### 3. iOS 构建失败

**问题：** `Command PhaseScriptExecution failed with a nonzero exit code`

**解决：**
- 确保 Xcode 已安装
- 运行 `xcode-select --install`
- 打开 Xcode，同意许可协议

### 4. 配置未生效

**问题：** 修改配置后没有变化

**解决：** 确保运行了配置脚本

```bash
python3 scripts/build_config.py
```

### 5. GitHub Actions 构建失败

**问题：** Actions 日志显示证书或密钥错误

**解决：**
- 检查 GitHub Secrets 是否正确配置
- 确保 Base64 编码正确
- 验证证书和密钥的有效期

---

## 📝 最佳实践

### 1. 版本管理

- 使用语义化版本号（如 1.0.0、1.1.0、2.0.0）
- 每次发布前增加版本号
- 保持 `buildNumber` / `versionCode` 递增

### 2. 配置管理

- 为不同应用创建独立的配置目录
- 不要在配置文件中保存真实的密码和密钥
- 使用 GitHub Secrets 存储敏感信息

### 3. 资源优化

- 优化图片资源大小
- 使用适当的图片格式（PNG、JPG、WebP）
- 提供多种分辨率的图标

### 4. 测试

- 在多种设备上测试应用
- 使用 TestFlight（iOS）和内部测试（Android）
- 收集用户反馈后再正式发布

### 5. 安全

- 定期更新依赖库
- 启用 ProGuard/R8（Android）
- 使用 HTTPS 保护网络通信
- 遵循最小权限原则

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License

---

## 📮 联系方式

如有问题或建议，请通过以下方式联系：

- GitHub Issues: [提交 Issue](../../issues)
- Email: your-email@example.com

---

**最后更新：** 2025-12-09
