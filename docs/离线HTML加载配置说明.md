# 离线HTML加载配置说明

## 功能概述

本功能允许将在线HTML页面下载到本地，与Android/iOS应用一起打包，实现离线访问。当设备没有网络连接时，应用仍然可以正常使用。

## 配置方法

### 1. 在 app.cfg 中启用离线模式

在您的应用配置文件 `assets/appName/app.cfg` 中添加或修改以下配置：

```ini
# 是否使用本地HTML文件（离线模式）
# true: 将loadUrl的HTML下载到本地并打包，支持离线使用
# false: 直接加载在线URL（默认）
isWebLocal=false
```

将 `isWebLocal` 设置为 `true` 即可启用离线模式。

### 2. 运行构建脚本

当 `isWebLocal=true` 时，运行构建配置脚本：

```bash
python3 scripts/build_config.py
```

脚本将自动：
1. 从 `loadUrl` 指定的在线地址下载HTML文件
2. 解析HTML并下载所有依赖资源（CSS、JS、图片等）
3. 将资源路径转换为本地相对路径
4. 将所有资源复制到Android和iOS项目中

### 3. Android配置

对于Android项目，Web内容会被自动复制到：
```
android/app/src/main/assets/webapp/
```

应用启动时会从这个位置加载本地HTML文件。

### 4. iOS配置

对于iOS项目，Web内容会被自动复制到：
```
ios/WebViewApp/webapp/
```

**重要：** 首次启用离线模式后，需要在Xcode中进行以下操作：

1. 打开 `WebViewApp.xcodeproj`
2. 右键点击项目导航器中的 `WebViewApp` 文件夹
3. 选择 "Add Files to WebViewApp..."
4. 选择 `webapp` 文件夹
5. **重要：** 在添加对话框中，确保选择 "Create folder references"（蓝色文件夹图标）
6. 点击 "Add"

这样，webapp目录中的所有文件都会被包含在应用bundle中。

## 工作原理

### Android

- 当 `isWebLocal=true` 时，MainActivity会加载：
  ```kotlin
  webView.loadUrl("file:///android_asset/webapp/index.html")
  ```

- 当 `isWebLocal=false` 时，加载在线URL：
  ```kotlin
  webView.loadUrl(AppConfig.LOAD_URL)
  ```

### iOS

- 当 `isWebLocal=true` 时，MainViewController会从Bundle加载本地HTML：
  ```swift
  let htmlPath = Bundle.main.path(forResource: "webapp/index", ofType: "html")
  webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
  ```

- 当 `isWebLocal=false` 时，加载在线URL：
  ```swift
  let request = URLRequest(url: URL(string: AppConfig.loadUrl))
  webView.load(request)
  ```

## 注意事项

1. **资源下载限制**
   - 脚本只能下载HTML中直接引用的资源
   - 动态加载的资源（通过JavaScript加载）可能无法被自动下载
   - 需要确保所有资源URL都是可访问的

2. **跨域问题**
   - 本地HTML加载时，某些CORS限制可能不适用
   - 但与外部API的交互仍需要网络连接

3. **更新策略**
   - 每次运行构建脚本时，都会重新下载最新版本的Web内容
   - 已安装的应用不会自动更新本地内容，需要发布新版本

4. **文件访问权限**
   - Android：自动配置文件访问权限
   - iOS：通过 `loadFileURL` 方法正确处理文件访问权限

5. **调试建议**
   - 开发阶段建议使用 `isWebLocal=false` 以便快速迭代
   - 发布前测试 `isWebLocal=true` 确保所有资源都正确打包

## 故障排除

### HTML文件无法加载

**Android:**
- 检查 `android/app/src/main/assets/webapp/index.html` 是否存在
- 查看Logcat日志确认错误信息

**iOS:**
- 确认webapp文件夹已作为folder reference添加到Xcode项目
- 检查Build Phases中是否包含webapp目录
- 查看Xcode控制台确认错误信息

### 资源文件缺失

- 检查原始网页是否包含动态加载的资源
- 可以手动将额外的资源文件添加到webapp目录
- 确保所有资源路径使用相对路径

### 样式或脚本未生效

- 检查HTML中的资源引用路径是否正确
- 确认所有资源文件都被正确下载和打包
- 检查WebView的JavaScript和文件访问设置

## 示例配置

### 完整的app.cfg示例

```ini
appName=MyOfflineApp
appDisplayName=My Offline App
appId=com.example.offlineapp
appVersion=1.0.0
buildNumber=1

# 在线HTML地址
loadUrl=https://example.com/myapp/index.html

# 启用离线模式
isWebLocal=true

# WebView配置
enableJavaScript=true
enableDOMStorage=true
enableCache=true

# 其他配置...
```

使用这个配置并运行构建脚本后，应用将包含完整的离线HTML内容，无需网络即可运行。
