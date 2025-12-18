# 离线HTML加载功能更新日志

## 版本: 2025-12-18

### 新增功能

#### 1. 离线HTML加载支持

新增 `isWebLocal` 配置项，支持将在线HTML页面及其所有资源下载到本地，与应用一起打包，实现完全离线使用。

### 修改的文件

#### 1. 配置文件
- **assets/app1/app.cfg**
  - 新增 `isWebLocal=false` 配置项
  - 默认值为 `false`，保持原有在线加载模式

#### 2. 构建脚本
- **scripts/build_config.py**
  - 新增 `HTMLResourceParser` 类：解析HTML并提取所有资源链接
  - 新增 `download_web_content()` 方法：下载HTML及其依赖资源
  - 修改 `copy_resources()` 方法：当 `isWebLocal=true` 时自动下载并打包Web内容
  - 修改 `configure_android()` 和 `configure_ios()` 方法：添加 `__IS_WEB_LOCAL__` 占位符替换
  - 自动将下载的Web内容复制到：
    - Android: `android/app/src/main/assets/webapp/`
    - iOS: `ios/WebViewApp/webapp/`

#### 3. Android代码修改
- **android/app/src/main/java/com/mywebviewapp/AppConfig.kt**
  - 新增 `IS_WEB_LOCAL` 常量

- **android/app/src/main/java/com/mywebviewapp/MainActivity.kt**
  - 新增 `loadContent()` 方法：根据配置加载在线或本地内容
  - 修改 `initWebView()` 方法：当离线模式时自动启用文件访问权限
  - 修改 `showErrorDialog()` 方法：重试时调用 `loadContent()`
  - 本地模式加载路径：`file:///android_asset/webapp/index.html`

#### 4. iOS代码修改
- **ios/WebViewApp/AppConfig.swift**
  - 新增 `isWebLocal` 静态属性

- **ios/WebViewApp/MainViewController.swift**
  - 修改 `loadURL()` 方法：根据配置加载在线或本地内容
  - 修改 `showErrorAlert()` 方法：重试时调用 `loadURL()`
  - 本地模式使用 `loadFileURL()` 方法，正确处理文件访问权限

#### 5. 文档
- **docs/离线HTML加载配置说明.md** (新增)
  - 详细的功能说明
  - 配置步骤
  - Android和iOS的实现原理
  - 故障排除指南
  - 使用示例

- **README.md**
  - 在特性列表中新增离线支持说明
  - 在WebView配置部分添加 `isWebLocal` 说明
  - 在文档列表中添加离线HTML加载配置说明链接

### 使用方法

#### 启用离线模式

1. 编辑 `assets/app1/app.cfg`，设置：
   ```ini
   isWebLocal=true
   ```

2. 运行构建配置脚本：
   ```bash
   python3 scripts/build_config.py
   ```

3. 脚本将自动：
   - 从 `loadUrl` 下载HTML
   - 解析并下载所有依赖资源（CSS、JS、图片等）
   - 转换资源链接为本地路径
   - 复制到Android和iOS项目目录

4. **iOS额外步骤**：首次使用时需要在Xcode中将 `webapp` 文件夹作为 folder reference 添加到项目中

#### 构建应用

- **Android**: 正常构建即可，assets目录会自动打包
- **iOS**: 确保webapp文件夹已添加到Xcode项目后正常构建

### 技术实现

#### HTML资源下载
- 使用 `HTMLParser` 解析HTML标签
- 支持的资源标签：link、script、img、source、video、audio、embed、object、iframe
- 自动处理相对路径和绝对路径
- 保留原始目录结构

#### 路径转换
- 下载的资源保持原URL的路径结构
- HTML中的链接自动转换为相对路径
- 支持处理 srcset 等复杂属性

#### Android实现
- 使用 `file:///android_asset/` 协议加载本地文件
- 自动启用必要的文件访问权限
- 资源打包在APK的assets目录中

#### iOS实现
- 使用 `Bundle.main.path()` 查找本地资源
- 使用 `loadFileURL(_:allowingReadAccessTo:)` 加载文件
- 正确处理文件访问权限和安全域

### 注意事项

1. **资源完整性**
   - 脚本只能下载HTML中静态引用的资源
   - 动态加载的资源需要手动添加或修改HTML

2. **网络请求**
   - 本地HTML中的API调用仍需网络连接
   - 纯展示类页面可完全离线使用

3. **更新机制**
   - 本地内容不会自动更新
   - 需要发布新版本应用来更新内容

4. **iOS配置**
   - 首次使用需要手动添加webapp文件夹到Xcode项目
   - 必须使用 folder reference 方式添加

### 兼容性

- ✅ 完全向后兼容
- ✅ 默认值 `isWebLocal=false` 保持原有行为
- ✅ 不影响现有项目配置
- ✅ Android API 21+ 支持
- ✅ iOS 13.0+ 支持

### 测试建议

1. 测试在线模式（`isWebLocal=false`）
2. 测试离线模式（`isWebLocal=true`）
3. 测试飞行模式下应用是否正常运行
4. 验证所有资源是否正确加载
5. 测试重试和错误处理逻辑

### 已知限制

1. 不支持动态加载的资源
2. 需要HTML页面所有资源都可公开访问
3. iOS需要手动配置Xcode项目
4. 不支持自动更新本地内容

### 未来改进

- [ ] 支持增量更新本地内容
- [ ] 添加资源完整性校验
- [ ] 自动处理动态资源
- [ ] iOS自动化项目配置
- [ ] 混合模式（本地+在线）
