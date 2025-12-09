# iOS 打包说明

本文档详细说明如何获取和配置 iOS 应用打包所需的证书、描述文件等。

---

## 目录

1. [注册 Apple Developer 账号](#1-注册-apple-developer-账号)
2. [创建 App ID](#2-创建-app-id)
3. [生成证书](#3-生成证书)
4. [创建 Provisioning Profile](#4-创建-provisioning-profile)
5. [配置 GitHub Secrets](#5-配置-github-secrets)
6. [本地打包测试](#6-本地打包测试)
7. [上架 App Store](#7-上架-app-store)

---

## 1. 注册 Apple Developer 账号

### 1.1 账号类型

| 类型             | 费用       | 用途                          |
|------------------|-----------|-------------------------------|
| 个人账号         | $99/年    | 个人开发者，以个人名义上架     |
| 公司账号         | $99/年    | 企业开发者,以公司名义上架     |
| 企业账号         | $299/年   | 仅供内部分发，不能上架商店     |

### 1.2 注册步骤

1. 访问 [Apple Developer](https://developer.apple.com/)
2. 点击 **Account** > **Join the Apple Developer Program**
3. 使用 Apple ID 登录
4. 选择账号类型（个人或组织）
5. 填写个人/公司信息
6. 支付费用（$99 或 $299）
7. 等待审核（个人账号通常几小时，公司账号可能需要几天）

### 1.3 准备材料

**个人账号：**
- Apple ID
- 信用卡（支持 Visa、MasterCard 等）
- 有效身份证件

**公司账号：**
- Apple ID
- 公司营业执照
- 邓白氏编码（D-U-N-S Number）
- 公司法人信息
- 信用卡

---

## 2. 创建 App ID

### 2.1 什么是 App ID？

App ID 是应用的唯一标识符，格式为：`com.yourcompany.appname`

### 2.2 创建步骤

1. 登录 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** > 点击 **+** 按钮
4. 选择 **App IDs** > 点击 **Continue**
5. 选择 **App**
6. 填写信息：
   - **Description**：应用描述（如 MyWebView App）
   - **Bundle ID**：选择 **Explicit**，输入 `com.yourcompany.appname`
7. 选择 Capabilities（应用能力）：
   - 如果需要推送通知，勾选 **Push Notifications**
   - 如果需要内购，勾选 **In-App Purchase**
8. 点击 **Continue** > **Register**

### 2.3 配置文件更新

在 `assets/app1/app.cfg` 中更新：

```properties
appId=com.yourcompany.appname
iosBundleId=com.yourcompany.appname
```

---

## 3. 生成证书

iOS 开发需要两种证书：
- **Development Certificate**：用于开发和测试
- **Distribution Certificate**：用于发布到 App Store

### 3.1 生成 Certificate Signing Request (CSR)

在 Mac 上：

1. 打开 **Keychain Access**（钥匙串访问）
2. 菜单栏 > **Keychain Access** > **Certificate Assistant** > **Request a Certificate From a Certificate Authority**
3. 填写信息：
   - **User Email Address**：你的邮箱
   - **Common Name**：你的名字或公司名
   - **CA Email Address**：留空
   - 选择 **Saved to disk**
4. 点击 **Continue**，保存 CSR 文件（如 `CertificateSigningRequest.certSigningRequest`）

### 3.2 创建 Distribution Certificate

1. 登录 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Certificates** > 点击 **+** 按钮
4. 选择 **Apple Distribution** > 点击 **Continue**
5. 上传之前生成的 CSR 文件
6. 点击 **Continue**
7. 下载生成的证书（`.cer` 文件）

### 3.3 安装证书

1. 双击下载的 `.cer` 文件
2. 证书会自动安装到 Keychain Access
3. 在 Keychain Access 中，找到证书，右键选择 **Export**
4. 导出为 `.p12` 文件，设置密码（**重要：记住这个密码**）

### 3.4 获取证书名称

在 Keychain Access 中：
1. 找到你的证书（通常以 "Apple Distribution" 或 "iPhone Distribution" 开头）
2. 记录完整的证书名称，例如：
   - `Apple Distribution: Your Name (TEAM_ID)`
   - `iPhone Distribution: Your Company Name`

---

## 4. 创建 Provisioning Profile

Provisioning Profile 关联了 App ID、证书和设备（可选），用于应用签名。

### 4.1 创建 App Store Profile

1. 登录 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Profiles** > 点击 **+** 按钮
4. 选择 **App Store** > 点击 **Continue**
5. 选择之前创建的 **App ID**
6. 选择 **Distribution Certificate**
7. 输入 Profile 名称（如 `MyWebView App Store Profile`）
8. 点击 **Generate**
9. 下载生成的 `.mobileprovision` 文件

### 4.2 获取 Team ID

1. 登录 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Membership** 页面
3. 查找 **Team ID**（10 位字符，如 `ABCDE12345`）

---

## 5. 配置 GitHub Secrets

### 5.1 转换文件为 Base64

**证书（.p12）：**

```bash
base64 -i certificate.p12 -o certificate.p12.base64
# 或者直接输出到剪贴板（MacOS）
base64 -i certificate.p12 | pbcopy
```

**Provisioning Profile（.mobileprovision）：**

```bash
base64 -i profile.mobileprovision -o profile.mobileprovision.base64
# 或者直接输出到剪贴板（MacOS）
base64 -i profile.mobileprovision | pbcopy
```

### 5.2 在 GitHub 仓库中设置 Secrets

1. 进入你的 GitHub 仓库
2. 点击 **Settings** > **Secrets and variables** > **Actions**
3. 点击 **New repository secret**，添加以下 Secrets：

| Secret 名称                          | 说明                               | 示例值                          |
|-------------------------------------|------------------------------------|---------------------------------|
| `IOS_CERTIFICATE_BASE64`            | 证书（.p12）的 Base64 编码          | （Base64 字符串）                |
| `IOS_CERTIFICATE_PASSWORD`          | 导出 .p12 时设置的密码              | `your_certificate_password`      |
| `IOS_PROVISIONING_PROFILE_BASE64`   | Provisioning Profile 的 Base64 编码 | （Base64 字符串）                |
| `IOS_TEAM_ID`                       | Apple Developer Team ID            | `ABCDE12345`                    |
| `IOS_EXPORT_METHOD`                 | 导出方式                           | `app-store`（或 `ad-hoc`、`development`）|
| `KEYCHAIN_PASSWORD`                 | 临时 Keychain 密码（可随意设置）    | `temp_keychain_password`         |

### 5.3 配置文件更新

在 `assets/app1/app.cfg` 中更新：

```properties
# iOS特定配置
iosTeamId=ABCDE12345
iosCertificateName=Apple Distribution: Your Name (ABCDE12345)
iosProvisioningProfile=UUID_OF_PROFILE
iosExportMethod=app-store
```

**获取 Provisioning Profile UUID：**

```bash
# 在 Mac 上
security cms -D -i profile.mobileprovision | grep UUID -A 1
```

---

## 6. 本地打包测试

### 6.1 配置本地环境

在本地打包前，需要先运行配置脚本：

```bash
# 确保 Python 已安装
python3 scripts/build_config.py
```

### 6.2 使用 Xcode 打包

1. 打开 Xcode
2. 打开项目：`ios/WebViewApp.xcodeproj`
3. 选择目标设备：**Any iOS Device (arm64)**
4. 配置签名：
   - 选择 Target > **Signing & Capabilities**
   - **Team**：选择你的 Team
   - **Bundle Identifier**：确认与 App ID 一致
   - **Provisioning Profile**：选择对应的 Profile
5. 菜单栏 > **Product** > **Archive**
6. 等待 Archive 完成
7. 在 Organizer 中选择 Archive，点击 **Distribute App**
8. 选择分发方式：
   - **App Store Connect**：上传到 App Store
   - **Ad Hoc**：用于测试分发
   - **Development**：用于开发测试

### 6.3 使用命令行打包

**Debug 构建（用于模拟器）：**

```bash
cd ios
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build
```

**Release 构建并导出 IPA：**

```bash
cd ios

# 1. Archive
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/WebViewApp.xcarchive \
  archive

# 2. 创建 exportOptions.plist
cat > exportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>ABCDE12345</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

# 3. 导出 IPA
xcodebuild -exportArchive \
  -archivePath build/WebViewApp.xcarchive \
  -exportPath build/output \
  -exportOptionsPlist exportOptions.plist
```

生成的 IPA 位于：`ios/build/output/WebViewApp.ipa`

---

## 7. 上架 App Store

### 7.1 前置条件

1. Apple Developer 账号（$99/年）
2. 已完成应用打包
3. 准备应用资源

### 7.2 创建 App Store Connect 记录

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 点击 **我的 App** > **+** 按钮
3. 选择 **新建 App**
4. 填写信息：
   - **平台**：iOS
   - **名称**：应用名称（与 App ID 对应）
   - **主要语言**：简体中文或英语
   - **套装 ID**：选择之前创建的 App ID
   - **SKU**：唯一标识符（如 `mywebview-001`）
   - **用户访问权限**：选择访问权限

### 7.3 填写 App 信息

#### 7.3.1 App 信息

- **名称**：最多 30 字符
- **副标题**：最多 30 字符（可选）
- **类别**：主要类别和次要类别
- **内容版权**：如 `2025 Your Company Name`
- **隐私政策 URL**：必填

#### 7.3.2 定价与销售范围

- **价格**：选择免费或付费
- **销售范围**：选择可用的国家和地区

#### 7.3.3 App 隐私

1. 点击 **开始**
2. 回答问卷：
   - 应用是否收集数据？
   - 收集哪些数据类型？
   - 数据用于什么目的？
3. 提交隐私信息

### 7.4 准备版本信息

进入 **App Store** 标签页，创建新版本：

#### 7.4.1 版本信息

- **版本号**：如 `1.0.0`
- **版本说明**：描述此版本的新功能和改进
- **关键词**：最多 100 字符，用逗号分隔

#### 7.4.2 截图和预览

**必需截图尺寸：**

| 设备                  | 尺寸（像素）           | 数量      |
|-----------------------|------------------------|-----------|
| 6.7" Display (iPhone 14 Pro Max) | 1290 x 2796    | 至少 1 张 |
| 6.5" Display (iPhone 11 Pro Max) | 1284 x 2778    | 至少 1 张 |
| 5.5" Display (iPhone 8 Plus)     | 1242 x 2208    | 至少 1 张 |

**可选但推荐：**
- 12.9" iPad Pro (第 3 代)：2048 x 2732
- 12.9" iPad Pro (第 2 代)：2048 x 2732

**截图要求：**
- 格式：JPG 或 PNG
- 色彩空间：RGB
- 最多 10 张

**应用预览视频（可选）：**
- 长度：15-30 秒
- 格式：M4V、MP4 或 MOV
- 分辨率：与截图设备匹配

#### 7.4.3 推广文本（可选）

- 最多 170 字符
- 可随时更新，无需审核

#### 7.4.4 描述

- 最多 4000 字符
- 详细描述应用的功能和特点

#### 7.4.5 联系信息

- **支持 URL**：用户获取支持的网址
- **营销 URL**：应用营销页面（可选）

#### 7.4.6 版本信息

- **版权**：如 `© 2025 Your Company Name`
- **App 图标**：1024 x 1024 PNG（不带透明度）

### 7.5 上传构建版本

#### 方法 1：使用 Xcode

1. 在 Xcode Organizer 中选择 Archive
2. 点击 **Distribute App**
3. 选择 **App Store Connect**
4. 点击 **Upload**
5. 等待上传完成

#### 方法 2：使用 Transporter

1. 下载 [Transporter](https://apps.apple.com/app/transporter/id1450874784)（Mac App Store）
2. 打开 Transporter
3. 拖入 IPA 文件
4. 点击 **Deliver**
5. 输入 Apple ID 和密码
6. 等待上传完成

#### 方法 3：使用命令行（altool）

```bash
xcrun altool --upload-app \
  --type ios \
  --file "WebViewApp.ipa" \
  --username "your@email.com" \
  --password "app-specific-password"
```

**注意：** 需要生成 App 专用密码（App-Specific Password）：
1. 访问 [appleid.apple.com](https://appleid.apple.com/)
2. 登录 Apple ID
3. 进入 **安全** 部分
4. 点击 **生成密码**
5. 输入标签（如 "Transporter"）
6. 复制生成的密码

### 7.6 选择构建版本

1. 构建版本上传后，等待处理（通常需要 5-10 分钟）
2. 在 App Store Connect 的版本信息页面，点击 **构建版本** 旁的 **+** 按钮
3. 选择刚上传的构建版本
4. 添加导出合规信息（如果应用使用加密）

### 7.7 提交审核

1. 确认所有必填项已完成
2. 点击 **添加以供审核**（或 **提交审核**）
3. 回答审核相关问题：
   - 内容权利
   - 政府限制
   - 广告标识符（IDFA）使用
4. 点击 **提交**

### 7.8 审核流程

| 状态                  | 说明                              | 预计时间    |
|-----------------------|-----------------------------------|-------------|
| 等待审核              | 应用在队列中等待                  | 几小时-几天 |
| 正在审核              | 审核团队正在审核                  | 24-48 小时  |
| 待开发者发布          | 审核通过，等待你发布              | -           |
| 可供销售              | 应用已在 App Store 上架           | -           |
| 被拒绝                | 审核未通过，需要修改后重新提交    | -           |

### 7.9 审核被拒后的处理

1. 在 App Store Connect 中查看拒绝原因
2. 根据反馈修改应用或提供解释
3. 重新提交审核

**常见拒绝原因：**
- 应用崩溃或功能不完整
- 隐私政策不符合要求
- 应用内容违反 App Store 审核指南
- 元数据（截图、描述）与应用功能不符
- 缺少必要的权限说明

---

## 8. 常见问题

### 8.1 证书问题

**问题：** `Code signing error: No certificate for team 'XXX'`

**解决方案：**
- 在 Keychain Access 中确认证书已安装
- 在 Xcode 中重新登录 Apple ID
- 下载并安装最新的证书

### 8.2 Provisioning Profile 问题

**问题：** `Provisioning profile doesn't include the currently selected device`

**解决方案：**
- 确保设备已添加到 Apple Developer 账号
- 重新生成 Provisioning Profile，包含该设备
- 在 Xcode 中刷新 Provisioning Profiles

### 8.3 构建版本不可用

**问题：** 上传的构建版本在 App Store Connect 中不显示

**解决方案：**
- 等待处理完成（5-15 分钟）
- 检查邮件，查看是否有错误通知
- 确保 Bundle ID 和版本号正确

### 8.4 导出合规

**问题：** 提示需要提供导出合规信息

**解决方案：**
- 如果应用使用 HTTPS，需要声明加密使用情况
- 通常选择 "否"（除非使用了自定义加密算法）
- 或者在 Info.plist 中添加：

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## 9. 调试模式说明

### 9.1 Debug 模式（isDebug=true）

**特点：**
- 不需要正式证书
- 使用自动签名（Automatic Signing）
- 仅用于模拟器或已注册的测试设备
- 无法上架 App Store

**GitHub Actions 配置：**
```properties
# assets/app1/app.cfg
isDebug=true
buildIOS=true
```

### 9.2 Release 模式（isDebug=false）

**特点：**
- 需要正式 Distribution 证书
- 需要 Provisioning Profile
- 可以上架 App Store
- 启用优化

**GitHub Actions 配置：**
```properties
# assets/app1/app.cfg
isDebug=false
buildIOS=true
```

---

## 10. 最佳实践

### 10.1 证书管理

- ✅ **妥善保存证书（.p12）和密码**
- ✅ **备份证书**：证书丢失后无法找回
- ✅ **使用团队共享证书**：避免每个人创建单独的证书
- ✅ **证书过期前更新**：证书通常有效期 1 年

### 10.2 版本管理

- ✅ **使用语义化版本号**：如 1.0.0、1.1.0、2.0.0
- ✅ **每次提交审核前增加版本号**
- ✅ **保持 Build Number 递增**

### 10.3 测试

- ✅ **使用 TestFlight**：邀请用户进行 Beta 测试
- ✅ **内部测试**：先在团队内部测试
- ✅ **外部测试**：公开 Beta 测试

### 10.4 审核

- ✅ **仔细阅读 App Store 审核指南**
- ✅ **确保应用功能完整**：避免 "Minimum Functionality" 拒绝
- ✅ **提供详细的审核说明**：特别是需要登录或特殊权限的功能
- ✅ **准备 Demo 账号**：方便审核团队测试

---

## 11. 参考链接

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight 文档](https://developer.apple.com/testflight/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**最后更新：** 2025-12-09
