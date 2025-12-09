# Android 打包说明

本文档详细说明如何获取和配置 Android 应用打包所需的证书、密钥等文件。

---

## 目录

1. [生成 Android 签名密钥库（Keystore）](#1-生成-android-签名密钥库keystore)
2. [配置 GitHub Secrets](#2-配置-github-secrets)
3. [本地打包测试](#3-本地打包测试)
4. [上架 Google Play](#4-上架-google-play)

---

## 1. 生成 Android 签名密钥库（Keystore）

### 1.1 什么是 Keystore？

Keystore 是一个包含私钥和证书的二进制文件，用于对 Android 应用进行签名。每个 Android 应用在发布时都必须使用唯一的签名，以确保应用的真实性和完整性。

### 1.2 使用 keytool 生成 Keystore

打开终端或命令提示符，执行以下命令：

```bash
keytool -genkey -v -keystore devdroid.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias myapp
```

**参数说明：**
- `-keystore devdroid.jks`：生成的密钥库文件名
- `-keyalg RSA`：使用 RSA 算法
- `-keysize 2048`：密钥大小为 2048 位
- `-validity 10000`：证书有效期为 10000 天（约 27 年）
- `-alias myapp`：密钥别名

**执行过程中需要输入：**
1. **密钥库密码（Keystore Password）**：至少 6 个字符，请妥善保存
2. **密钥密码（Key Password）**：通常与密钥库密码相同
3. **个人/组织信息**：
   - 姓名（CN）：你的名字或公司名称
   - 组织单位（OU）：部门名称
   - 组织（O）：公司名称
   - 城市（L）：城市
   - 省/州（ST）：省份或州
   - 国家代码（C）：两位国家代码，如 CN（中国）、US（美国）

### 1.3 查看 Keystore 信息

```bash
keytool -list -v -keystore devdroid.jks
```

输入密钥库密码后，可以查看证书的详细信息，包括：
- MD5 指纹
- SHA1 指纹
- SHA256 指纹（Google Play 需要）

---

## 2. 配置 GitHub Secrets

为了在 GitHub Actions 中使用 Keystore，需要将其转换为 Base64 编码并存储为 Secret。

### 2.1 将 Keystore 转换为 Base64

**在 Linux/MacOS 上：**
```bash
base64 -i devdroid.jks -o devdroid.jks.base64
# 或者直接输出到剪贴板（MacOS）
base64 -i devdroid.jks | pbcopy
```

**在 Windows 上：**
```powershell
certutil -encode devdroid.jks devdroid.jks.base64
```

然后打开 `devdroid.jks.base64` 文件，复制其中的内容（去掉首尾的 `-----BEGIN CERTIFICATE-----` 和 `-----END CERTIFICATE-----` 行）。

### 2.2 在 GitHub 仓库中设置 Secrets

1. 进入你的 GitHub 仓库
2. 点击 **Settings** > **Secrets and variables** > **Actions**
3. 点击 **New repository secret**，添加以下 Secrets：

| Secret 名称                    | 说明                          | 示例值                |
|-------------------------------|-------------------------------|-----------------------|
| `ANDROID_KEYSTORE_BASE64`     | Keystore 文件的 Base64 编码    | （Base64 字符串）      |
| `ANDROID_KEYSTORE_FILE`       | Keystore 文件名                | `devdroid.jks`        |
| `ANDROID_KEYSTORE_PASSWORD`   | Keystore 密码                  | `your_password`       |
| `ANDROID_KEY_ALIAS`           | 密钥别名                       | `myapp`               |
| `ANDROID_KEY_PASSWORD`        | 密钥密码                       | `your_key_password`   |

### 2.3 配置文件更新

在 `assets/app1/app.cfg` 中，确保以下配置正确：

```properties
# Android特定配置
androidKeyAlias=myapp
androidKeyPassword=PLACEHOLDER_KEY_PASSWORD
androidStorePassword=PLACEHOLDER_STORE_PASSWORD
androidKeystoreFile=devdroid.jks
```

**注意：**
- 配置文件中的密码字段使用占位符，实际密码存储在 GitHub Secrets 中
- GitHub Actions 构建时会自动替换这些占位符

---

## 3. 本地打包测试

### 3.1 配置本地环境

在本地打包前，需要先运行配置脚本：

```bash
# 确保 Python 已安装
python3 scripts/build_config.py
```

### 3.2 本地构建 Debug 版本

```bash
cd android
./gradlew assembleDebug
```

生成的 APK 位于：`android/app/build/outputs/apk/debug/app-debug.apk`

### 3.3 本地构建 Release 版本

1. 将 Keystore 文件放到 `android/app/` 目录
2. 临时修改 `android/app/build.gradle`，将密码占位符替换为实际密码
3. 执行构建：

```bash
cd android
./gradlew assembleRelease
```

生成的 APK 位于：`android/app/build/outputs/apk/release/app-release.apk`

### 3.4 验证签名

```bash
# 查看 APK 签名信息
keytool -printcert -jarfile app-release.apk
```

---

## 4. 上架 Google Play

### 4.1 前置条件

1. 注册 [Google Play Console](https://play.google.com/console) 开发者账号（一次性费用 $25）
2. 准备应用资源：
   - 应用图标（512x512 PNG）
   - 功能图片（1024x500 JPG/PNG）
   - 应用截图（至少 2 张，推荐 4-8 张）
   - 应用描述（简短描述和完整描述）

### 4.2 创建应用

1. 登录 Google Play Console
2. 点击 **创建应用**
3. 填写应用基本信息：
   - 应用名称
   - 默认语言
   - 应用类型（应用或游戏）
   - 免费或付费

### 4.3 完成应用设置

在应用控制台中，需要完成以下设置：

#### 4.3.1 应用内容

- **隐私政策**：提供隐私政策 URL
- **应用访问权限**：说明应用需要的权限
- **广告**：声明应用是否包含广告
- **内容分级**：填写问卷以获取内容分级
- **目标受众**：选择目标用户年龄段
- **新闻应用**：声明是否为新闻应用

#### 4.3.2 商店详情

- **应用名称**：最多 50 字符
- **简短描述**：最多 80 字符
- **完整描述**：最多 4000 字符
- **应用图标**：512x512 PNG，32 位，最大 1MB
- **功能图片**：1024x500 JPG/PNG
- **手机截图**：至少 2 张，最多 8 张
  - 尺寸：320-3840 像素
  - 纵横比：16:9 或 9:16

#### 4.3.3 应用完整性

- **应用类别**：选择合适的类别
- **联系方式**：电子邮件地址
- **外部营销**：是否允许 Google 使用应用信息进行营销

### 4.4 上传 APK/AAB

1. 进入 **发布** > **生产**（或测试轨道）
2. 点击 **创建新版本**
3. 上传 APK 或 AAB 文件

**推荐使用 Android App Bundle (AAB)：**

```bash
cd android
./gradlew bundleRelease
```

生成的 AAB 位于：`android/app/build/outputs/bundle/release/app-release.aab`

### 4.5 Google Play 应用签名

**强烈推荐启用 Google Play 应用签名：**

1. 进入 **发布** > **设置** > **应用完整性**
2. 选择 **使用 Google Play 应用签名**
3. 上传上传密钥证书（Upload Key Certificate）

**获取上传密钥的 SHA256 指纹：**

```bash
keytool -list -v -keystore devdroid.jks -alias myapp
```

复制 SHA256 指纹并提交给 Google Play。

### 4.6 发布审核

1. 完成所有必填项
2. 点击 **发布到生产轨道**（或测试轨道）
3. 等待 Google 审核（通常需要几小时到几天）

### 4.7 更新应用

每次更新应用时：
1. 增加 `versionCode`（在 `app.cfg` 中的 `androidVersionCode`）
2. 更新 `versionName`（在 `app.cfg` 中的 `androidVersionName`）
3. 重新构建并上传新的 APK/AAB
4. 填写更新说明（What's New）

---

## 5. 常见问题

### 5.1 签名错误

**问题：** `jarsigner: Certificate chain not found for: myapp`

**解决方案：**
- 检查 Keystore 文件路径是否正确
- 确认密钥别名是否正确
- 验证 Keystore 密码和密钥密码

### 5.2 版本冲突

**问题：** Google Play 提示版本号冲突

**解决方案：**
- 确保新的 `versionCode` 大于之前所有版本
- `versionCode` 必须是整数且递增

### 5.3 权限问题

**问题：** 应用需要额外权限但未声明

**解决方案：**
- 在 `AndroidManifest.xml` 中添加所需权限
- 在应用描述中说明权限用途

### 5.4 APK 过大

**问题：** APK 文件超过 100MB

**解决方案：**
- 使用 AAB 格式（Google Play 会自动优化）
- 启用 ProGuard 进行代码混淆和压缩
- 使用 APK 扩展文件（OBB）

---

## 6. 最佳实践

### 6.1 密钥管理

- ✅ **妥善保存 Keystore 文件**：丢失后无法更新应用
- ✅ **备份 Keystore**：至少保存两份备份
- ✅ **使用密码管理器**：存储密码和别名
- ✅ **不要提交 Keystore 到版本控制系统**

### 6.2 版本管理

- ✅ **使用语义化版本号**：如 1.0.0、1.1.0、2.0.0
- ✅ **保持 versionCode 递增**：每次发布都要增加
- ✅ **维护更新日志**：记录每个版本的变更

### 6.3 测试

- ✅ **使用内部测试轨道**：先进行小范围测试
- ✅ **Beta 测试**：邀请用户参与测试
- ✅ **分阶段发布**：逐步向所有用户推送更新

### 6.4 安全

- ✅ **启用 ProGuard**：代码混淆和优化
- ✅ **使用 HTTPS**：保护网络通信
- ✅ **最小权限原则**：仅请求必要的权限
- ✅ **定期更新依赖**：修复安全漏洞

---

## 7. 调试模式说明

### 7.1 Debug 模式（isDebug=true）

**特点：**
- 不需要签名证书
- 使用 Debug 签名（自动生成）
- 无法上架应用商店
- 适用于开发和测试

**GitHub Actions 配置：**
```properties
# assets/app1/app.cfg
isDebug=true
```

**本地构建：**
```bash
./gradlew assembleDebug
```

### 7.2 Release 模式（isDebug=false）

**特点：**
- 需要正式签名证书
- 可以上架应用商店
- 启用代码优化
- 生产环境使用

**GitHub Actions 配置：**
```properties
# assets/app1/app.cfg
isDebug=false
```

**本地构建：**
```bash
./gradlew assembleRelease
```

---

## 8. 参考链接

- [Android 开发者文档 - 应用签名](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console 帮助中心](https://support.google.com/googleplay/android-developer)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [Google Play 应用签名](https://support.google.com/googleplay/android-developer/answer/9842756)

---

**最后更新：** 2025-12-09
