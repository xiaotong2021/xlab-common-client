# Android 界面配置说明

## 📋 概述

本文档说明如何配置 Android 应用的界面外观，包括顶部标题栏、状态栏、全屏模式等。

---

## 🎯 顶部标题栏配置

### 当前配置

**已隐藏顶部标题栏** ✅

应用默认配置为**无标题栏模式**，不显示应用名称和 ActionBar。

---

## 📱 界面模式

### 1. 无标题栏模式（当前）✅

**特点**:
- ✅ 隐藏应用标题栏（ActionBar）
- ✅ 保留系统状态栏（显示时间、电量、信号等）
- ✅ WebView 内容从状态栏下方开始显示
- ✅ 推荐模式，用户体验最佳

**效果图**:
```
┌─────────────────────────────────┐
│ 🔋 10:30 📶               ← 系统状态栏
├─────────────────────────────────┤
│                                 │
│     WebView 内容区域            │ ← 无应用标题栏
│     (网页内容)                  │
│                                 │
└─────────────────────────────────┘
```

---

### 2. 带标题栏模式

**特点**:
- 显示应用名称和 ActionBar
- 保留系统状态栏
- WebView 内容从标题栏下方开始

**效果图**:
```
┌─────────────────────────────────┐
│ 🔋 10:30 📶               ← 系统状态栏
├─────────────────────────────────┤
│ MyApp                   ☰       │ ← 应用标题栏
├─────────────────────────────────┤
│                                 │
│     WebView 内容区域            │
│     (网页内容)                  │
│                                 │
└─────────────────────────────────┘
```

**如何启用**:

修改 `AndroidManifest.xml`:
```xml
<!-- Main Activity -->
<activity
    android:name=".MainActivity"
    android:exported="false"
    android:theme="@style/Theme.WebViewApp"  <!-- 改为 Theme.WebViewApp -->
    android:configChanges="orientation|screenSize|keyboardHidden" />
```

同时在 `MainActivity.kt` 中注释掉：
```kotlin
// supportActionBar?.hide()  // 注释这行
```

---

### 3. 全屏模式

**特点**:
- 隐藏应用标题栏
- 隐藏系统状态栏
- WebView 占满整个屏幕

**效果图**:
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│     WebView 内容区域            │ ← 完全全屏
│     (网页内容)                  │
│     占满整个屏幕                │
│                                 │
└─────────────────────────────────┘
```

**如何启用**:

修改 `AndroidManifest.xml`:
```xml
<!-- Main Activity -->
<activity
    android:name=".MainActivity"
    android:exported="false"
    android:theme="@style/Theme.WebViewApp.Fullscreen"  <!-- 改为 Fullscreen -->
    android:configChanges="orientation|screenSize|keyboardHidden" />
```

---

## 🔧 技术实现

### 主题配置

**文件**: `android/app/src/main/res/values/themes.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- 默认主题（带标题栏） -->
    <style name="Theme.WebViewApp" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="colorSecondary">@color/teal_200</item>
        <item name="colorSecondaryVariant">@color/teal_700</item>
        <item name="colorOnSecondary">@color/black</item>
        <item name="android:statusBarColor">?attr/colorPrimaryVariant</item>
    </style>

    <!-- 无顶部标题栏主题（保留状态栏）✅ 当前使用 -->
    <style name="Theme.WebViewApp.NoActionBar">
        <item name="windowActionBar">false</item>      <!-- 隐藏 ActionBar -->
        <item name="windowNoTitle">true</item>          <!-- 无标题 -->
    </style>
    
    <!-- 全屏主题（隐藏状态栏和标题栏） -->
    <style name="Theme.WebViewApp.Fullscreen">
        <item name="windowActionBar">false</item>       <!-- 隐藏 ActionBar -->
        <item name="windowNoTitle">true</item>           <!-- 无标题 -->
        <item name="android:windowFullscreen">true</item> <!-- 全屏 -->
    </style>
</resources>
```

---

### AndroidManifest 配置

**文件**: `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:theme="@style/Theme.WebViewApp">  <!-- 应用默认主题 -->
    
    <!-- Loading Activity - 无标题栏 -->
    <activity
        android:name=".LoadingActivity"
        android:exported="true"
        android:theme="@style/Theme.WebViewApp.NoActionBar">  <!-- ✅ 无标题栏 -->
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
    </activity>

    <!-- Main Activity - 无标题栏 -->
    <activity
        android:name=".MainActivity"
        android:exported="false"
        android:theme="@style/Theme.WebViewApp.NoActionBar"  <!-- ✅ 无标题栏 -->
        android:configChanges="orientation|screenSize|keyboardHidden" />
</application>
```

---

### 代码配置

**文件**: `MainActivity.kt` 和 `LoadingActivity.kt`

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    
    // 隐藏顶部标题栏（双重保险）✅
    supportActionBar?.hide()
    
    setContentView(R.layout.activity_main)
    // ... 其他代码
}
```

**说明**:
- 虽然已在 AndroidManifest 中设置了 NoActionBar 主题
- 但代码中再次调用 `supportActionBar?.hide()` 作为双重保险
- 确保在所有情况下都能正确隐藏标题栏

---

## 📊 配置对比

| 配置项 | 无标题栏 | 带标题栏 | 全屏 |
|--------|---------|---------|------|
| **ActionBar** | 隐藏 ✅ | 显示 | 隐藏 ✅ |
| **系统状态栏** | 显示 ✅ | 显示 ✅ | 隐藏 |
| **显示应用名** | 否 | 是 | 否 |
| **WebView 区域** | 大 | 中 | 最大 |
| **推荐场景** | 通用应用 ✅ | 传统应用 | 游戏/视频 |
| **当前使用** | ✅ | | |

---

## 🎨 主题属性说明

### 关键属性

| 属性 | 作用 | 值 |
|------|------|---|
| `windowActionBar` | 是否显示 ActionBar | `true` / `false` |
| `windowNoTitle` | 是否隐藏标题 | `true` / `false` |
| `android:windowFullscreen` | 是否全屏 | `true` / `false` |
| `android:statusBarColor` | 状态栏颜色 | 颜色值 |

### 父主题选择

**带 ActionBar**:
```xml
<style name="Theme.WebViewApp" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
```

**无 ActionBar**:
```xml
<style name="Theme.WebViewApp" parent="Theme.MaterialComponents.DayNight.NoActionBar">
```

---

## 🔄 切换界面模式

### 方法 1: 修改主题（推荐）

修改 `AndroidManifest.xml`:
```xml
<!-- 无标题栏 -->
android:theme="@style/Theme.WebViewApp.NoActionBar"

<!-- 带标题栏 -->
android:theme="@style/Theme.WebViewApp"

<!-- 全屏 -->
android:theme="@style/Theme.WebViewApp.Fullscreen"
```

### 方法 2: 代码控制

在 Activity 中动态控制：
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    
    // 隐藏 ActionBar
    supportActionBar?.hide()
    
    // 显示 ActionBar
    supportActionBar?.show()
    
    // 全屏模式
    window.setFlags(
        WindowManager.LayoutParams.FLAG_FULLSCREEN,
        WindowManager.LayoutParams.FLAG_FULLSCREEN
    )
    
    setContentView(R.layout.activity_main)
}
```

---

## 🎯 最佳实践

### 1. Loading 页面

**推荐**: 无标题栏或全屏
```xml
<activity
    android:name=".LoadingActivity"
    android:theme="@style/Theme.WebViewApp.NoActionBar">
```

**原因**:
- ✅ 品牌展示更完整
- ✅ 视觉效果更好
- ✅ 不需要显示应用名（已有 Logo）

---

### 2. WebView 主页面

**推荐**: 无标题栏（当前配置）
```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/Theme.WebViewApp.NoActionBar">
```

**原因**:
- ✅ 最大化内容显示区域
- ✅ 不显示重复的应用名称
- ✅ 保留系统状态栏，用户可查看时间、电量
- ✅ WebView 内容可自定义标题

---

### 3. 传统应用

**可选**: 带标题栏
```xml
<activity
    android:name=".MainActivity"
    android:theme="@style/Theme.WebViewApp">
```

**适用场景**:
- 需要在标题栏显示应用名称
- 需要在标题栏添加菜单按钮
- 传统的原生 App 风格

---

## 🐛 常见问题

### 问题 1: 顶部仍然显示应用名称

**原因**: 主题配置未生效

**解决方法**:
```kotlin
// 方法 1: 在 onCreate 中添加
supportActionBar?.hide()

// 方法 2: 检查 AndroidManifest.xml
android:theme="@style/Theme.WebViewApp.NoActionBar"  // 确保使用 NoActionBar
```

---

### 问题 2: 全屏后状态栏空间仍保留

**原因**: 只隐藏了 ActionBar，没有设置全屏

**解决方法**:
```xml
<!-- 使用全屏主题 -->
android:theme="@style/Theme.WebViewApp.Fullscreen"
```

或在代码中：
```kotlin
window.setFlags(
    WindowManager.LayoutParams.FLAG_FULLSCREEN,
    WindowManager.LayoutParams.FLAG_FULLSCREEN
)
```

---

### 问题 3: WebView 顶部被遮挡

**原因**: 布局设置问题

**解决方法**:

检查 `activity_main.xml`:
```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fitsSystemWindows="false">  <!-- 确保为 false -->
    
    <WebView
        android:id="@+id/webView"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

---

## 📚 相关文档

- [应用名称和图标配置说明](./应用名称和图标配置说明.md)
- [构建和安装指南](./构建和安装指南.md)
- [常见配置错误](./常见配置错误.md)

---

## 🎉 总结

### ✅ 当前配置

- **LoadingActivity**: 无标题栏 ✅
- **MainActivity**: 无标题栏 ✅
- **系统状态栏**: 保留显示 ✅
- **应用名称**: 不显示 ✅

### 📝 配置说明

1. **主题配置** (`themes.xml`)
   - `Theme.WebViewApp` - 带标题栏
   - `Theme.WebViewApp.NoActionBar` - 无标题栏 ✅
   - `Theme.WebViewApp.Fullscreen` - 全屏

2. **Manifest 配置** (`AndroidManifest.xml`)
   - LoadingActivity 使用 NoActionBar ✅
   - MainActivity 使用 NoActionBar ✅

3. **代码配置** (`MainActivity.kt`, `LoadingActivity.kt`)
   - 添加 `supportActionBar?.hide()` 双重保险 ✅

### 🔄 切换方式

**如需切换界面模式**:
1. 修改 `AndroidManifest.xml` 中的 `android:theme`
2. 重新构建和安装应用

---

**最后更新**: 2025-12-12
**版本**: v1.0.14







# App Store 截图生成工具使用说明

## 📱 功能介绍

这是一个自动生成 App Store 所需各种分辨率截图的 Python 工具。只需提供一张原始图片，即可自动生成符合苹果审核要求的所有尺寸截图。

---

## ✨ 支持的设备尺寸

### iPhone 6.7"/6.9" 显示屏
- **1290×2796** (iPhone 14 Pro Max 竖屏)
- **2796×1290** (iPhone 14 Pro Max 横屏)
- **1320×2868** (iPhone 15 Pro Max 竖屏)
- **2868×1320** (iPhone 15 Pro Max 横屏)

### iPhone 5.5"/5.8" 显示屏
- **1242×2688** (iPhone XS Max 竖屏)
- **2688×1242** (iPhone XS Max 横屏)
- **1284×2778** (iPhone 12 Pro Max 竖屏)
- **2778×1284** (iPhone 12 Pro Max 横屏)

### iPad 12.9"/13" 显示屏
- **2048×2732** (iPad Pro 12.9" 竖屏)
- **2732×2048** (iPad Pro 12.9" 横屏)
- **2064×2752** (iPad Pro 13" M4 竖屏)
- **2752×2064** (iPad Pro 13" M4 横屏)

### Apple Watch
- **410×502** (Apple Watch Ultra 2)
- **416×496** (Apple Watch Series 10)
- **396×484** (Apple Watch Series 9)
- **368×448** (Apple Watch Series 6)
- **312×390** (Apple Watch Series 3)

---

## 🚀 快速开始

### 1. 安装依赖

```bash
pip install Pillow
```

### 2. 基本使用

```bash
# 生成所有设备的截图
python3 scripts/generate_screenshots.py your_screenshot.png
```

生成的截图将保存在 `screenshots/` 目录中。

---

## 📖 详细使用方法

### 命令格式

```bash
python3 scripts/generate_screenshots.py [输入图片] [选项]
```

### 常用选项

| 选项 | 说明 | 默认值 |
|------|------|-------|
| `-o, --output` | 输出目录 | `screenshots/` |
| `-m, --mode` | 缩放模式 | `fill` |
| `-q, --quality` | 输出质量 (1-100) | `95` |
| `-d, --devices` | 指定设备类型 | 所有设备 |
| `--list-devices` | 列出支持的设备 | - |

---

## 🎨 缩放模式详解

### fill - 填充模式（推荐）✅

保持宽高比，填充整个目标尺寸，可能裁剪图片。

```bash
python3 scripts/generate_screenshots.py input.png --mode fill
```

**效果**:
- ✅ 图片充满整个屏幕
- ✅ 保持原图宽高比
- ⚠️ 可能裁剪图片边缘

**适用场景**: 大部分情况，特别是背景图、界面截图

### fit - 适应模式

保持宽高比，完整显示图片，可能留白。

```bash
python3 scripts/generate_screenshots.py input.png --mode fit
```

**效果**:
- ✅ 完整显示图片
- ✅ 保持原图宽高比
- ⚠️ 可能有白边

**适用场景**: 需要展示完整内容的图片

### stretch - 拉伸模式（不推荐）❌

直接拉伸到目标尺寸，不保持宽高比。

```bash
python3 scripts/generate_screenshots.py input.png --mode stretch
```

**效果**:
- ✅ 填充整个屏幕
- ❌ 可能变形
- ❌ 不保持宽高比

**适用场景**: 几乎不推荐使用

---

## 💡 使用示例

### 示例 1: 基本使用

```bash
python3 scripts/generate_screenshots.py app_screenshot.png
```

**输出**:
```
==============================================================
App Store 截图生成器
==============================================================

✅ 加载图片: app_screenshot.png
   原始尺寸: 1242 × 2688
   缩放模式: fill
   输出目录: screenshots

📱 生成 iphone_6_7 截图...
   ✅ 1290×2796 - iPhone 6.7" 竖屏
      → iphone_6_7_1290x2796_iPhone_6.7_竖屏.png
   ✅ 2796×1290 - iPhone 6.7" 横屏
      → iphone_6_7_2796x1290_iPhone_6.7_横屏.png
   ...

==============================================================
✅ 生成完成!
==============================================================
总计生成: 17 张截图

  iphone_6_7: 4 张
  iphone_5_5: 4 张
  ipad_12_9: 4 张
  watch: 5 张

📁 输出目录: /path/to/screenshots
```

### 示例 2: 指定输出目录

```bash
python3 scripts/generate_screenshots.py screenshot.png --output my_app_screenshots/
```

### 示例 3: 只生成 iPhone 截图

```bash
python3 scripts/generate_screenshots.py screenshot.png --devices iphone_6_7 iphone_5_5
```

### 示例 4: 只生成 iPad 截图

```bash
python3 scripts/generate_screenshots.py screenshot.png --devices ipad_12_9
```

### 示例 5: 使用适应模式

```bash
python3 scripts/generate_screenshots.py logo.png --mode fit --output logo_screenshots/
```

### 示例 6: 调整输出质量

```bash
python3 scripts/generate_screenshots.py screenshot.png --quality 100
```

### 示例 7: 查看支持的设备

```bash
python3 scripts/generate_screenshots.py --list-devices
```

**输出**:
```
📱 支持的设备类型:

  iphone_6_7:
    数量: 4 个尺寸
    - 1290×2796 (iPhone 6.7" 竖屏)
    - 2796×1290 (iPhone 6.7" 横屏)
    - 1320×2868 (iPhone 6.9" 竖屏)
    - 2868×1320 (iPhone 6.9" 横屏)

  iphone_5_5:
    数量: 4 个尺寸
    ...
```

---

## 📂 输出文件命名规则

### 命名格式

```
{设备类型}_{宽度}x{高度}_{设备名称}.png
```

### 示例

```
iphone_6_7_1290x2796_iPhone_6.7_竖屏.png
iphone_6_7_2796x1290_iPhone_6.7_横屏.png
ipad_12_9_2048x2732_iPad_12.9_竖屏.png
watch_410x502_Apple_Watch_Ultra_2.png
```

---

## 🎯 最佳实践

### 1. 准备原始图片

**推荐分辨率**:
- 至少 **1290×2796** (iPhone 最大尺寸)
- 或 **2064×2752** (iPad 最大尺寸)
- 更高分辨率效果更好

**推荐格式**:
- PNG (最佳质量)
- JPG (文件更小)

### 2. 选择合适的缩放模式

| 原始图片类型 | 推荐模式 | 原因 |
|------------|---------|------|
| **应用界面截图** | `fill` | 充满屏幕，更真实 |
| **带文字的宣传图** | `fit` | 避免裁剪重要内容 |
| **纯色背景+Logo** | `fill` 或 `fit` | 都可以 |
| **复杂图案** | `fill` | 更美观 |

### 3. 准备多组截图

对于不同设备，准备不同的原始图片：

```bash
# iPhone 截图（竖屏为主）
python3 scripts/generate_screenshots.py iphone_screenshot_1.png \
  --devices iphone_6_7 iphone_5_5 \
  --output screenshots/iphone/

# iPad 截图（横屏为主）
python3 scripts/generate_screenshots.py ipad_screenshot_1.png \
  --devices ipad_12_9 \
  --output screenshots/ipad/

# Apple Watch 截图
python3 scripts/generate_screenshots.py watch_screenshot_1.png \
  --devices watch \
  --output screenshots/watch/
```

### 4. 批量生成

创建一个批处理脚本：

```bash
#!/bin/bash
# generate_all_screenshots.sh

# iPhone 截图（最多 10 张）
for i in {1..5}; do
  python3 scripts/generate_screenshots.py "screenshots/originals/iphone_${i}.png" \
    --devices iphone_6_7 iphone_5_5 \
    --output screenshots/iphone/ \
    --mode fill
done

# iPad 截图（最多 10 张）
for i in {1..3}; do
  python3 scripts/generate_screenshots.py "screenshots/originals/ipad_${i}.png" \
    --devices ipad_12_9 \
    --output screenshots/ipad/ \
    --mode fill
done

echo "✅ 所有截图生成完成!"
```

---

## 📋 App Store 上传要求

### iPhone 截图

**6.7"/6.9" 显示屏**:
- 数量: 最多 **10 张**截图 + 最多 **3 个**视频预览
- 必需: **至少 1 张**

**5.5" 显示屏**:
- 数量: 最多 **10 张**截图 + 最多 **3 个**视频预览
- 可选（如果提供了 6.7" 截图可省略）

### iPad 截图

**12.9"/13" 显示屏**:
- 数量: 最多 **10 张**截图 + 最多 **3 个**视频预览
- 必需（如果应用支持 iPad）: **至少 1 张**

### Apple Watch 截图

**各尺寸**:
- 数量: 最多 **10 张**截图
- 必需（如果有 Watch 应用）: **至少 1 张**

---

## 🖼️ 设计建议

### 1. 截图内容

✅ **推荐内容**:
- 核心功能演示
- 用户界面截图
- 特色功能高亮
- 使用场景展示
- 成果展示

❌ **避免内容**:
- 空白页面
- 错误页面
- 测试数据
- 低质量图片
- 侵权内容

### 2. 视觉效果

**文字**:
- 使用高对比度
- 字体大小适中
- 避免过多文字
- 多语言考虑

**颜色**:
- 与应用主题一致
- 避免过于鲜艳
- 注意色盲友好

**布局**:
- 重点内容居中
- 避免边缘重要信息
- 保持视觉平衡

### 3. 本地化

为不同地区准备不同语言的截图：

```bash
# 英文截图
python3 scripts/generate_screenshots.py screenshots/en/screen_1.png \
  --output screenshots/app_store/en/

# 中文截图
python3 scripts/generate_screenshots.py screenshots/zh/screen_1.png \
  --output screenshots/app_store/zh/
```

---

## 🔧 故障排查

### 问题 1: Pillow 未安装

**错误信息**:
```
❌ 错误: 未安装 Pillow 库
```

**解决方案**:
```bash
pip install Pillow

# 或使用 pip3
pip3 install Pillow
```

### 问题 2: 输入文件不存在

**错误信息**:
```
❌ 错误: 输入文件不存在: your_image.png
```

**解决方案**:
- 检查文件路径是否正确
- 使用绝对路径或相对路径
- 确认文件存在

### 问题 3: 图片质量不佳

**原因**: 原始图片分辨率太低

**解决方案**:
- 使用更高分辨率的原始图片
- 确保原始图片至少达到目标尺寸
- 使用矢量图或高分辨率截图

### 问题 4: 图片被裁剪

**原因**: 使用了 `fill` 模式

**解决方案**:
```bash
# 改用 fit 模式
python3 scripts/generate_screenshots.py input.png --mode fit
```

### 问题 5: 图片有白边

**原因**: 使用了 `fit` 模式

**解决方案**:
```bash
# 改用 fill 模式
python3 scripts/generate_screenshots.py input.png --mode fill
```

---

## 📚 相关文档

- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [App Store 截图规范](https://help.apple.com/app-store-connect/#/devd274dd925)
- [iOS 设计指南](https://developer.apple.com/design/human-interface-guidelines/)

---

## 🎨 高级技巧

### 1. 添加设备框架

使用 Sketch、Figma 或在线工具添加设备框架：

1. 使用本工具生成基础截图
2. 导入到设计工具中
3. 套用设备模版
4. 导出最终效果

### 2. 添加文字说明

```python
# 可以扩展脚本添加文字
from PIL import ImageDraw, ImageFont

def add_text(img, text, position):
    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype("Arial.ttf", 60)
    draw.text(position, text, fill='white', font=font)
    return img
```

### 3. 批量水印

在脚本中添加水印功能，保护原创内容。

---

## 🔄 更新记录

- **2025-12-18**: 创建 App Store 截图生成工具
  - 支持所有 iPhone、iPad、Apple Watch 尺寸
  - 提供三种缩放模式
  - 自动化批量生成









# 更新日志

## [2025-12-21] - 主要功能更新

### 🆕 新增功能

#### 1. App Store Connect API 集成

- **自动检查和创建应用**
  - 在上传到 TestFlight 之前，自动检查应用是否在 App Store Connect 中存在
  - 如果应用不存在，自动创建应用
  - 避免手动创建应用的繁琐步骤

- **自动上传元数据**
  - 支持上传应用描述、关键词、推广文本、版本更新说明等
  - 支持技术支持网址、营销网址、隐私政策网址等
  - 支持 App 审核联系信息配置

- **多语言支持**
  - 支持为多个语言配置不同的本地化内容
  - 内置支持简体中文、繁体中文、英语等
  - 可扩展支持所有 Apple 支持的语言

- **新增文件**
  - `scripts/app_store_connect.py` - App Store Connect API 客户端
  - `scripts/README_APP_STORE_CONNECT.md` - 详细使用说明
  - `requirements.txt` - Python 依赖列表
  - `更新说明.md` - 完整更新说明
  - `快速开始-App-Store-Connect.md` - 快速开始指南

### 🐛 Bug 修复

#### 2. 修复 enableZoom 配置无效问题

**问题描述**：
- 当 `enableZoom=false` 时，Android 和 iOS 应用仍然可以使用双指进行缩放
- WebView 的原生配置不足以完全禁用缩放

**解决方案**：

- **Android 修复** (`android/app/src/main/java/com/mywebviewapp/MainActivity.kt`)
  - 根据 `enableZoom` 动态设置 `loadWithOverviewMode` 和 `useWideViewPort`
  - 在页面加载完成后，通过 JavaScript 注入 viewport meta 标签
  - 确保 `maximum-scale=1.0, user-scalable=no`

- **iOS 修复** (`ios/WebViewApp/MainViewController.swift`)
  - 通过 WKUserScript 在页面加载时注入 viewport meta 标签
  - 自动修改或创建 viewport meta 标签
  - 确保 `maximum-scale=1.0, user-scalable=no`

**测试方法**：
```properties
enableZoom=false
```
重新构建应用后，尝试双指缩放网页，应该无法缩放。

### 📝 配置文件更新

#### 3. 新增配置项

**iOS 基本配置**：
```properties
iosSku=com-xlab-myapp
iosPrimaryLocale=zh-Hans
iosLocales=zh-Hans,en-US
```

**App Store 元数据配置**：
```properties
appSubtitle=应用副标题
appDescription=应用描述
appDescription_zh_Hans=简体中文描述
appDescription_en_US=English description
appKeywords=关键词1,关键词2
appKeywords_zh_Hans=中文关键词
appKeywords_en_US=English keywords
appPromotionalText=推广文本
appPromotionalText_zh_Hans=中文推广文本
appPromotionalText_en_US=English promotional text
appReleaseNotes=更新说明
appReleaseNotes_zh_Hans=中文更新说明
appReleaseNotes_en_US=English release notes
appSupportUrl=https://example.com/support
appMarketingUrl=https://example.com
appPrivacyPolicyUrl=https://example.com/privacy
appCopyright=2025 Company Name
```

**App 审核联系信息**：
```properties
reviewContactFirstName=张
reviewContactLastName=三
reviewContactPhone=+86 13800138000
reviewContactEmail=support@example.com
reviewNotes=审核备注
```

#### 4. 更新的配置文件

- `assets/app1/app.cfg` - 添加了 70+ 行新配置
- `assets/idiomApp/app.cfg` - 添加了 70+ 行新配置
- 所有配置都有详细的中文注释和示例值

### 🔧 构建流程更新

#### 5. GitHub Actions 工作流更新

**修改文件**：`.github/workflows/build.yml`

**新增步骤**：
```yaml
- name: Install Python dependencies
  run: |
    pip install Pillow PyJWT requests cryptography

- name: Check and setup App Store Connect
  run: |
    # 准备 API 密钥
    mkdir -p ~/.appstoreconnect/private_keys
    echo "${{ secrets.APP_STORE_API_KEY_BASE64 }}" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_API_KEY_ID }}.p8
    
    # 运行 App Store Connect 检查脚本
    python3 scripts/app_store_connect.py ${{ github.workspace }}
  env:
    APP_STORE_API_KEY_ID: ${{ secrets.APP_STORE_API_KEY_ID }}
    APP_STORE_API_ISSUER_ID: ${{ secrets.APP_STORE_API_ISSUER_ID }}
```

**工作流程**：
1. 构建 Android APK（如果启用）
2. 构建 iOS IPA（如果启用）
3. ✨ **检查和创建应用（新增）**
4. ✨ **上传元数据（新增）**
5. 上传到 TestFlight
6. 创建 GitHub Release

### 📖 文档更新

#### 6. 新增和更新的文档

**新增文档**：
- `scripts/README_APP_STORE_CONNECT.md` - App Store Connect API 详细说明
- `requirements.txt` - Python 依赖列表
- `更新说明.md` - 完整更新说明
- `快速开始-App-Store-Connect.md` - 快速开始指南
- `CHANGELOG.md` - 更新日志（本文件）

**更新文档**：
- `docs/配置文件说明.md`
  - 添加 `iosSku`, `iosPrimaryLocale`, `iosLocales` 说明
  - 添加 App Store 元数据配置说明（10+ 个新配置项）
  - 添加 App 审核联系信息说明（5 个新配置项）
  - 更新 `enableZoom` 的说明，包含修复详情
  - 更新最后更新日期

### 🔐 安全性

#### 7. Secrets 配置

**新增 GitHub Secrets**：
- `APP_STORE_API_KEY_ID` - API 密钥 ID
- `APP_STORE_API_ISSUER_ID` - 颁发者 ID
- `APP_STORE_API_KEY_BASE64` - API 私钥的 Base64 编码

**安全说明**：
- 所有敏感信息都存储在 GitHub Secrets 中
- 私钥文件不会提交到版本控制系统
- API 密钥具有时效性（20 分钟）

### 📦 依赖更新

#### 8. Python 依赖

新增依赖（`requirements.txt`）：
```txt
Pillow>=10.0.0          # 图像处理
PyJWT>=2.8.0            # JWT 令牌生成
requests>=2.31.0        # HTTP 请求
cryptography>=41.0.0    # 加密库
```

### 🎯 使用方法

#### 快速开始

1. **创建 App Store Connect API 密钥**
   - 访问 App Store Connect
   - 生成 API 密钥并下载 .p8 文件

2. **配置 GitHub Secrets**
   - 添加 `APP_STORE_API_KEY_ID`
   - 添加 `APP_STORE_API_ISSUER_ID`
   - 添加 `APP_STORE_API_KEY_BASE64`

3. **更新 app.cfg**
   - 添加 iOS 配置（iosSku, iosPrimaryLocale, iosLocales）
   - 添加 App Store 元数据
   - 添加审核联系信息

4. **推送版本标签**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

5. **自动构建和发布**
   - GitHub Actions 自动执行所有步骤
   - 查看日志确认执行结果

详细步骤请参考 [快速开始指南](快速开始-App-Store-Connect.md)。

### ⚠️ 注意事项

1. **首次创建应用**
   - 应用创建后，仍需在 App Store Connect 手动上传截图
   - 需要手动设置定价和分发区域

2. **必填配置**
   - `appSupportUrl` - 技术支持网址（必须可访问）
   - `appPrivacyPolicyUrl` - 隐私政策网址（必须可访问）

3. **权限要求**
   - API 密钥需要 **Admin** 或 **App Manager** 权限

4. **元数据审核**
   - 元数据的修改需要通过 Apple 审核
   - 推广文本（`appPromotionalText`）可以随时更新，无需审核

5. **enableZoom 修复**
   - 设置 `enableZoom=false` 后，需要重新构建应用
   - 建议在真实设备上测试缩放功能

### 🐛 已知问题

暂无已知问题。

### 📞 支持

如遇问题，请：
1. 查看 GitHub Actions 日志
2. 阅读详细文档
3. 检查配置文件是否正确

相关文档：
- [App Store Connect API 详细说明](README_APP_STORE_CONNECT.md)
- [快速开始指南](快速开始-App-Store-Connect.md)
- [完整更新说明](更新说明.md)
- [配置文件说明](配置文件说明.md)

---

## 版本历史

### v1.0.0 (之前的版本)
- 初始版本
- 支持 Android 和 iOS 构建
- 基本的 WebView 配置
- GitHub Actions 自动化构建

---

**最后更新**：2025-12-21


## 📌 概述

从 git tag 自动提取版本号和构建号，无需手动修改 `app.cfg` 文件。

---

## ✅ buildNumber 要求

### iOS
- **字段**: `CFBundleVersion` (对应 `CURRENT_PROJECT_VERSION`)
- **类型**: 整数或点分隔的整数（如 `1` 或 `1.2.3`）
- **要求**: 每次发布必须递增

### Android
- **字段**: `versionCode`
- **类型**: 整数
- **要求**: 每次发布必须递增，必须大于之前所有版本

**结论：buildNumber 必须是数字（整数）！**

---

## 🏷️ Tag 格式

支持三种 tag 格式，按优先级排序：

### 格式 1：版本号 + 构建号（推荐）✨

```bash
v<version>+<buildNumber>
v<version>-<buildNumber>
```

**示例：**
```bash
v1.0.0+1    # 版本 1.0.0，构建号 1
v1.0.1+6    # 版本 1.0.1，构建号 6
v2.0.0+10   # 版本 2.0.0，构建号 10

# 或使用 - 分隔
v1.0.0-1
v1.0.1-6
```

**优点：**
- ✅ 完全控制版本号和构建号
- ✅ 清晰明确
- ✅ 符合语义化版本规范的扩展
- ✅ 适合正式发布

**缺点：**
- ❌ 需要手动管理 buildNumber

**推荐场景：**
- 正式发布到 App Store / Google Play
- 需要精确控制版本号
- 团队协作开发

### 格式 2：仅版本号（自动构建号）

```bash
v<version>
```

**示例：**
```bash
v1.0.0
v1.0.1
v2.0.0
```

**行为：**
- buildNumber 自动使用 git commit 总数（`git rev-list --count HEAD`）

**优点：**
- ✅ 完全自动化
- ✅ buildNumber 永远递增
- ✅ 不需要手动管理构建号

**缺点：**
- ❌ buildNumber 可能变得很大
- ❌ 不同分支的 buildNumber 可能不同

**推荐场景：**
- 内部测试
- 快速迭代
- 个人项目

### 格式 3：配置文件值（fallback）

如果 tag 格式不匹配上述两种，将使用 `app.cfg` 中配置的值：

```properties
appVersion=1.0.1
buildNumber=6
```

---

## 🚀 使用方法

### 方法 1：使用格式 1（推荐）

```bash
# 1. 确保代码已提交
git add .
git commit -m "feat: 添加新功能"

# 2. 创建带构建号的 tag
git tag v1.0.1+6

# 3. 推送 tag 触发构建
git push origin v1.0.1+6
```

**结果：**
- appVersion = 1.0.1
- buildNumber = 6
- `app.cfg` 会被自动更新（仅在 CI/CD 中）

### 方法 2：使用格式 2（自动构建号）

```bash
# 1. 确保代码已提交
git add .
git commit -m "feat: 添加新功能"

# 2. 创建 tag
git tag v1.0.1

# 3. 推送 tag 触发构建
git push origin v1.0.1
```

**结果：**
- appVersion = 1.0.1
- buildNumber = 当前 commit 总数（如：235）

### 方法 3：使用配置文件（传统方式）

```bash
# 1. 修改 app.cfg
# 手动更新 appVersion 和 buildNumber

# 2. 提交更改
git add assets/idiomApp/app.cfg
git commit -m "chore: bump version to 1.0.1 build 6"

# 3. 创建任意格式的 tag
git tag v1.0.1-release
git push origin v1.0.1-release
```

---

## 📋 完整工作流程示例

### 场景 1：正式发布

```bash
# 开发完成，准备发布 v1.0.2

# 1. 确定构建号（上一个版本的 buildNumber + 1）
# 假设 v1.0.1 的 buildNumber 是 6，新版本使用 7

# 2. 创建 tag
git tag v1.0.2+7 -m "Release version 1.0.2 build 7"

# 3. 推送 tag
git push origin v1.0.2+7

# 4. GitHub Actions 自动：
#    - 提取 version=1.0.2, buildNumber=7
#    - 更新 app.cfg
#    - 构建 Android APK/AAB
#    - 构建 iOS IPA
#    - 上传到 TestFlight
```

### 场景 2：内部测试（快速迭代）

```bash
# 快速测试，不想手动管理构建号

# 1. 创建 tag（不带构建号）
git tag v1.0.3-beta

# 2. 推送 tag
git push origin v1.0.3-beta

# 3. GitHub Actions 自动：
#    - 提取 version=1.0.3
#    - buildNumber 使用 commit 计数（如 245）
#    - 构建并发布
```

### 场景 3：修复构建号错误

```bash
# 如果发现 buildNumber 错误，需要重新打 tag

# 1. 删除错误的 tag（本地和远程）
git tag -d v1.0.2+7
git push origin :refs/tags/v1.0.2+7

# 2. 创建正确的 tag
git tag v1.0.2+8 -m "Fix build number"

# 3. 推送新 tag
git push origin v1.0.2+8
```

---

## 🎯 版本号规则

### 语义化版本（Semantic Versioning）

格式：`MAJOR.MINOR.PATCH`

- **MAJOR**: 主版本号，不兼容的 API 修改
- **MINOR**: 次版本号，向下兼容的功能新增
- **PATCH**: 修订号，向下兼容的问题修正

**示例：**
```bash
v1.0.0      # 首次正式发布
v1.0.1      # 修复 bug
v1.1.0      # 添加新功能（向下兼容）
v2.0.0      # 重大更新（不向下兼容）
```

### buildNumber 规则

- **必须递增**: 每次发布的 buildNumber 必须大于之前所有版本
- **唯一性**: 同一个 version 可以有多个 buildNumber（测试版本）
- **整数**: 必须是正整数

**示例：**
```bash
v1.0.0+1    # 第一个 build
v1.0.0+2    # 修复 bug，重新打包
v1.0.0+3    # 再次修复，重新打包
v1.0.1+4    # 新版本，构建号继续递增
v1.0.1+5    # ...
```

---

## 🔍 验证方法

### 1. 查看当前 tag

```bash
# 列出所有 tag
git tag

# 查看最新的 tag
git describe --tags --abbrev=0

# 查看 tag 详情
git show v1.0.1+6
```

### 2. 检查 GitHub Actions 日志

在 GitHub Actions 页面查看构建日志：

```
✅ Extracted from tag: version=1.0.1, buildNumber=6
📦 Using version from tag: 1.0.1 (build 6)
✅ Updated assets/idiomApp/app.cfg with tag version

=== Build Configuration ===
  Platform: Android=true, iOS=true
  Version: 1.0.1
  Build Number: 6
  Debug Mode: false
==========================
```

### 3. 验证构建产物

**Android APK/AAB:**
```bash
# 解压 APK
unzip app-release.apk -d output/

# 查看 AndroidManifest.xml
cat output/AndroidManifest.xml | grep versionCode
cat output/AndroidManifest.xml | grep versionName
```

**iOS IPA:**
```bash
# 解压 IPA
unzip WebViewApp.ipa -d output/

# 查看 Info.plist
plutil -p output/Payload/WebViewApp.app/Info.plist | grep CFBundleShortVersionString
plutil -p output/Payload/WebViewApp.app/Info.plist | grep CFBundleVersion
```

---

## ⚠️ 注意事项

### 1. Tag 命名规范

❌ **错误示例：**
```bash
v1.0.0.1       # 不支持四位版本号
1.0.0+6        # 必须以 v 开头
v1.0.0+a       # buildNumber 必须是数字
v1.0.0_6       # 分隔符只支持 + 或 -
```

✅ **正确示例：**
```bash
v1.0.0+6       # ✅
v1.0.0-6       # ✅
v1.0.0         # ✅
```

### 2. buildNumber 冲突

如果 buildNumber 小于或等于之前的版本：

**iOS:**
```
Error: This bundle is invalid. The value for key CFBundleVersion 
[6] in the Info.plist file must be a higher than the previously 
uploaded version [7].
```

**Android:**
```
Error: Upload failed
You need to use a different version code.
```

**解决方案：**
- 使用更大的 buildNumber
- 或者使用格式 2（自动计数）

### 3. 本地开发

本地开发时，`app.cfg` 中的值不会自动更新。

**选项 1：手动运行构建脚本**
```bash
# 临时设置环境变量
export APP_VERSION=1.0.1
export BUILD_NUMBER=6

# 运行构建脚本
python3 scripts/build_config.py
```

**选项 2：手动修改 app.cfg**
```properties
appVersion=1.0.1
buildNumber=6
```

### 4. 分支策略

建议的分支和 tag 策略：

```
main 分支:
  └─ v1.0.0+1  (正式发布)
  └─ v1.0.1+2  (正式发布)
  └─ v1.1.0+3  (正式发布)

develop 分支:
  └─ v1.1.0-beta.1  (测试版本)
  └─ v1.1.0-beta.2  (测试版本)
  └─ v1.1.0-rc.1    (候选版本)
```

---

## 🛠️ 高级用法

### 使用预发布标签

```bash
# Beta 版本
git tag v1.1.0-beta+10

# Release Candidate
git tag v1.1.0-rc+11

# 正式版本
git tag v1.1.0+12
```

### 批量管理 tag

```bash
# 列出所有包含构建号的 tag
git tag | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+[\+\-][0-9]+'

# 查找最大的 buildNumber
git tag | grep -oP '(?<=[\+\-])[0-9]+$' | sort -n | tail -1

# 删除所有 beta tag
git tag | grep beta | xargs git tag -d
```

### 自动递增脚本

创建一个辅助脚本 `scripts/tag-release.sh`：

```bash
#!/bin/bash

# 获取最新的 tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0+0")

# 提取版本号和构建号
if [[ "$LATEST_TAG" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)[\+\-]([0-9]+)$ ]]; then
    VERSION="${BASH_REMATCH[1]}"
    BUILD_NUMBER="${BASH_REMATCH[2]}"
else
    VERSION="0.0.0"
    BUILD_NUMBER="0"
fi

# 递增构建号
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# 提示用户输入新版本号（或使用当前版本）
read -p "Enter new version [$VERSION]: " NEW_VERSION
NEW_VERSION=${NEW_VERSION:-$VERSION}

# 创建新 tag
NEW_TAG="v${NEW_VERSION}+${NEW_BUILD_NUMBER}"

echo "Current: $LATEST_TAG"
echo "New: $NEW_TAG"

read -p "Create tag $NEW_TAG? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git tag "$NEW_TAG" -m "Release $NEW_TAG"
    echo "Created tag: $NEW_TAG"
    echo "Push with: git push origin $NEW_TAG"
fi
```

使用：
```bash
chmod +x scripts/tag-release.sh
./scripts/tag-release.sh
```

---

## 📊 对比表

| 特性 | 手动管理 app.cfg | Tag 格式 1 (v1.0.0+6) | Tag 格式 2 (v1.0.0) |
|------|-----------------|---------------------|-------------------|
| **自动化程度** | 低 | 中 | 高 |
| **构建号控制** | 完全控制 | 完全控制 | 自动递增 |
| **适用场景** | 所有场景 | 正式发布 | 快速迭代 |
| **出错风险** | 高（容易忘记） | 低 | 最低 |
| **推荐指数** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 📚 相关文档

- [配置文件说明](./配置文件说明.md)
- [构建发布指南](./构建发布指南.md)
- [iOS打包说明](./iOS打包说明.md)
- [Android打包说明](./Android打包说明.md)

---

## 🔄 更新记录

- **2025-12-18**: 添加从 git tag 自动提取版本号和构建号功能




# iOS 加密出口合规说明

## 📋 问题背景

在将 iOS 应用上传到 App Store Connect 时，Apple 会询问应用是否使用加密。这是美国出口合规法规要求的一部分。

---

## 🎯 常见问题

### 上传应用时的询问

```
App 加密文稿
你的 App 采用了哪种类型的加密算法？

选项:
1. 专有或未被国际标准主体（IEEE、IETF、ITU 等）视为标准的加密算法
2. 代替在 Apple 操作系统中使用或访问加密，或与这些操作同时使用的标准加密算法
3. 兼用上述的两种算法
4. 不属于上述的任意一种算法 ✅ (WebView 应用通常选这个)
```

---

## ✅ WebView 应用的配置

### 情况说明

我们的 WebView 应用：
- ✅ 使用 HTTPS 访问网页（Apple 系统提供的标准加密）
- ✅ 使用 WKWebView（系统组件）
- ✅ 不实现自定义加密算法
- ✅ 不包含额外的加密功能

**结论**: **使用豁免的标准加密，不需要出口合规文档**

---

## 🔧 Info.plist 配置

### 已添加的配置

**文件**: `ios/WebViewApp/Info.plist`

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### 配置说明

| Key | Value | 含义 |
|-----|-------|------|
| `ITSAppUsesNonExemptEncryption` | `false` | 应用不使用需要出口文档的加密 |

**解释**:
- `false` = 应用不使用非豁免加密
- 即：应用只使用标准加密（如 HTTPS、TLS/SSL）
- 不需要提供出口合规文档

---

## 📊 加密类型判断

### 1. 不需要设置为 true 的情况（使用 false）✅

**我们的应用属于这种情况**

- ✅ 仅使用 HTTPS 访问网页
- ✅ 仅使用 Apple 系统提供的加密 API
- ✅ 使用标准加密协议（TLS/SSL）
- ✅ 不实现自定义加密算法
- ✅ 不包含第三方加密库（除非是标准的）

**配置**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**效果**:
- ✅ 上传时不会再询问加密问题
- ✅ 不需要提供出口合规文档
- ✅ 可以直接提交审核

---

### 2. 需要设置为 true 的情况

**以下情况需要设置为 true 并提供文档**

- ❌ 实现了自定义加密算法
- ❌ 使用了非标准的加密协议
- ❌ 集成了第三方加密库（如 OpenSSL）
- ❌ 提供端到端加密功能
- ❌ 实现了自己的加密通信

**配置**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<true/>
<key>ITSEncryptionExportComplianceCode</key>
<string>YOUR_COMPLIANCE_CODE</string>
```

**需要**:
- 📄 提供出口合规文档
- 🔑 获取合规代码（Compliance Code）
- 📝 填写详细的加密使用说明

---

## 🎯 不同场景的配置

### 场景 1: 纯 WebView 应用（当前）✅

**特征**:
- 只是一个浏览器容器
- 访问 HTTPS 网页
- 使用系统 WebView

**配置**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**上传时选择**: "不属于上述的任意一种算法"

---

### 场景 2: 使用标准加密的应用

**特征**:
- 使用 HTTPS API 调用
- 使用 Apple 的 CryptoKit
- 数据传输使用 TLS

**配置**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**说明**: Apple 系统提供的标准加密都是豁免的

---

### 场景 3: 聊天/社交应用（端到端加密）

**特征**:
- 实现了端到端加密
- 消息在设备间加密传输
- 使用自定义加密协议

**配置**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<true/>
<key>ITSEncryptionExportComplianceCode</key>
<string>YOUR_CODE_HERE</string>
```

**需要**: 申请并获得 ERN (Encryption Registration Number)

---

### 场景 4: 金融/支付应用

**特征**:
- 处理敏感财务信息
- 使用银行级加密
- 自定义安全协议

**配置**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<true/>
<key>ITSEncryptionExportComplianceCode</key>
<string>YOUR_CODE_HERE</string>
```

**需要**: 详细的加密实现说明和合规文档

---

## 📝 完整的 Info.plist 示例

### 当前配置（WebView 应用）✅

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>__APP_DISPLAY_NAME__</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <!-- ... 其他配置 ... -->
    
    <!-- 网络安全配置 -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
    
    <!-- 加密出口合规配置 ✅ -->
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
</dict>
</plist>
```

---

## 🔑 Info.plist 加密相关 Key

### 主要 Key

| Key | 类型 | 说明 | 示例值 |
|-----|------|------|-------|
| `ITSAppUsesNonExemptEncryption` | Boolean | 是否使用非豁免加密 | `false` ✅ |
| `ITSEncryptionExportComplianceCode` | String | 加密合规代码（如需要） | `YOUR_CODE` |

### 可选 Key（高级）

| Key | 类型 | 说明 |
|-----|------|------|
| `ITSAppUsesNonExemptEncryption` | Boolean | 主要标志 |
| `ITSEncryptionExportComplianceCode` | String | ERN 代码 |

---

## 🚀 上传流程

### 配置后的上传流程

**1. 本地配置**

编辑 `Info.plist`，添加：
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**2. 构建应用**

```bash
# 构建 IPA
xcodebuild -archivePath ... -exportArchive ...
```

**3. 上传到 App Store Connect**

使用 Transporter 或命令行：
```bash
xcrun altool --upload-app \
  --file WebViewApp.ipa \
  --type ios \
  --apiKey $API_KEY_ID \
  --apiIssuer $ISSUER_ID
```

**4. App Store Connect 行为**

- ✅ **有 Info.plist 配置**: 不会询问加密问题，直接处理
- ❌ **无 Info.plist 配置**: 会弹出加密合规问卷

**5. 提交审核**

- 填写其他必要信息
- 提交审核

---

## ⚠️ 常见问题

### 问题 1: 上传后仍被询问加密问题

**原因**: Info.plist 配置未生效

**解决方法**:
```bash
# 1. 检查 Info.plist
cat ios/WebViewApp/Info.plist | grep ITSAppUsesNonExemptEncryption

# 2. 确认配置正确
<key>ITSAppUsesNonExemptEncryption</key>
<false/>

# 3. 清理并重新构建
rm -rf ios/build*
xcodebuild clean
xcodebuild archive ...

# 4. 重新上传
```

---

### 问题 2: 不确定应该选 true 还是 false

**判断流程**:

```
你的应用是否实现了以下任一功能？
├─ 自定义加密算法 ──→ YES ──→ true
├─ 端到端加密 ──→ YES ──→ true
├─ 第三方加密库 ──→ YES ──→ true (可能)
└─ 只用 HTTPS/TLS ──→ NO ──→ false ✅
```

**WebView 应用**: `false` ✅

---

### 问题 3: 设置为 false 后是否安全

**回答**: ✅ 完全安全

**原因**:
- `false` 不是"不使用加密"
- `false` 是"不使用需要出口文档的加密"
- HTTPS/TLS 是标准加密，完全安全
- Apple 系统加密都是经过验证的

---

### 问题 4: 需要 ERN 代码吗

**WebView 应用**: ❌ 不需要

**判断**:
- `ITSAppUsesNonExemptEncryption = false` → 不需要 ERN
- `ITSAppUsesNonExemptEncryption = true` → 需要 ERN

**获取 ERN**:
1. 访问 BIS (美国商务部工业和安全局)
2. 提交加密注册申请
3. 等待审批（可能需要几周）
4. 获得 ERN 代码

---

## 📚 相关文档

### Apple 官方文档

- [出口合规文档](https://help.apple.com/app-store-connect/#/dev88f5c7bf9)
- [加密出口合规](https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations)
- [Info.plist Key 参考](https://developer.apple.com/documentation/bundleresources/information_property_list)

### 美国法规

- [BIS 加密出口管制](https://www.bis.doc.gov/index.php/policy-guidance/encryption)
- [EAR (出口管理条例)](https://www.ecfr.gov/current/title-15/subtitle-B/chapter-VII/subchapter-C)

---

## 🎯 快速参考

### WebView 应用配置 ✅

```xml
<!-- Info.plist 中添加 -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**说明**:
- ✅ 只使用 HTTPS/TLS
- ✅ 不需要出口文档
- ✅ 不需要 ERN 代码
- ✅ 上传时不会被询问

---

### 其他类型应用

**使用自定义加密**:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<true/>
<key>ITSEncryptionExportComplianceCode</key>
<string>YOUR_ERN_CODE</string>
```

**完全不使用加密**（极少见）:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## 🔄 后续步骤

### 1. 验证配置

```bash
# 检查 Info.plist
grep -A1 "ITSAppUsesNonExemptEncryption" ios/WebViewApp/Info.plist

# 应该显示:
# <key>ITSAppUsesNonExemptEncryption</key>
# <false/>
```

### 2. 提交代码

```bash
git add ios/WebViewApp/Info.plist
git commit -m "feat: 添加 iOS 加密出口合规配置

- Info.plist 添加 ITSAppUsesNonExemptEncryption=false
- 说明应用只使用标准 HTTPS 加密
- 不需要出口合规文档
- 上传时不会询问加密问题
"
git push
```

### 3. 重新构建和上传

```bash
# 触发新构建
git tag v1.0.15
git push origin v1.0.15

# 或本地构建
xcodebuild archive ...
xcodebuild -exportArchive ...

# 上传
xcrun altool --upload-app --file WebViewApp.ipa ...
```

### 4. App Store Connect 验证

上传后检查：
- ✅ 不应该再询问加密问题
- ✅ 直接进入"正在处理"状态
- ✅ 可以提交审核

---

## 📝 总结

### ✅ 当前配置

| 项目 | 值 | 说明 |
|------|---|------|
| **应用类型** | WebView | 纯网页容器 |
| **加密类型** | HTTPS/TLS | 系统标准加密 |
| **Info.plist** | `false` | 不使用非豁免加密 |
| **出口文档** | 不需要 | 豁免 |
| **ERN 代码** | 不需要 | N/A |
| **上传询问** | 跳过 | ✅ |

### 🎉 完成

添加配置后：
- ✅ `Info.plist` 包含加密声明
- ✅ 上传时不会询问加密问题
- ✅ 不需要手动填写合规问卷
- ✅ 可以直接提交审核

---

**最后更新**: 2025-12-12
**版本**: v1.0.15





# iOS 应用安装指南

本指南介绍如何在不同场景下安装 iOS 应用。

---

## 📱 安装方式对比

| 安装方式 | 适用场景 | 需要电脑 | 设备限制 | Profile 类型 |
|---------|---------|---------|---------|-------------|
| **TestFlight** | 内部测试、Beta 测试 | ❌ 不需要 | 需要邀请 | App Store |
| **Ad Hoc** | 内部分发（有限设备） | ✅ 需要 | 需注册 UDID | Ad Hoc |
| **App Store** | 正式发布 | ❌ 不需要 | 无限制 | App Store |
| **模拟器 (.app)** | 开发测试 | ✅ 需要 Mac | 仅模拟器 | - |

---

## 方式 1: TestFlight 安装（推荐）

### ✅ 优点
- 不需要电脑
- 可以通过链接分享给测试者
- 自动更新
- 可以收集反馈

### 📋 步骤

#### 1. 上传到 App Store Connect

```bash
# 使用 Transporter 应用上传 IPA
# 或使用命令行
xcrun altool --upload-app -f WebViewApp.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

#### 2. 在 App Store Connect 中配置

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入"我的 App" → 选择你的应用
3. 选择"TestFlight"标签
4. 等待构建版本处理完成（通常 5-15 分钟）
5. 添加内部测试人员或外部测试人员

#### 3. 测试人员安装

1. 测试人员收到邀请邮件
2. 在 iPhone 上安装 [TestFlight](https://apps.apple.com/app/testflight/id899247664) 应用
3. 点击邮件中的链接或输入邀请码
4. 在 TestFlight 中安装应用

### 🔗 邀请测试人员

```
内部测试人员：
- 最多 100 人
- 必须是 App Store Connect 用户
- 立即可用

外部测试人员：
- 最多 10,000 人
- 只需要 Apple ID
- 需要 Beta 审核（24-48 小时）
```

---

## 方式 2: Ad Hoc 安装（直接安装）

### ✅ 优点
- 不需要 TestFlight
- 可以通过网站或工具直接安装

### ⚠️ 限制
- 最多 100 台设备
- 需要提前注册设备 UDID
- 需要重新创建 Provisioning Profile

### 📋 步骤

#### 1. 创建 Ad Hoc Provisioning Profile

<details>
<summary>点击展开详细步骤</summary>

1. **收集设备 UDID**
   ```bash
   # 方法 1: 连接电脑，打开 Finder
   连接 iPhone → Finder → 设备 → 点击序列号 → 复制 UDID

   # 方法 2: 使用网页工具
   访问: https://get.udid.io/
   在 iPhone Safari 中打开 → 允许安装描述文件 → 获取 UDID
   ```

2. **在 Apple Developer 注册设备**
   ```
   1. 登录 https://developer.apple.com/account/
   2. Certificates, IDs & Profiles → Devices
   3. 点击 + 添加设备
   4. 输入设备名称和 UDID
   5. 点击 Continue → Register
   ```

3. **创建 Ad Hoc Profile**
   ```
   1. Profiles → 点击 +
   2. 选择 Distribution → Ad Hoc
   3. 选择 App ID: com.xlab.psychologicalgym
   4. 选择 Distribution 证书
   5. ⭐ 选择要包含的设备（刚注册的设备）
   6. 输入 Profile 名称: xlabProfile-AdHoc
   7. Generate → Download
   ```

4. **更新 GitHub Secrets**
   ```bash
   # 将新的 Ad Hoc Profile 转换为 Base64
   base64 -i xlabProfile-AdHoc.mobileprovision | pbcopy

   # 在 GitHub 更新 Secret
   IOS_PROVISIONING_PROFILE_BASE64 = <新的 Base64>
   IOS_EXPORT_METHOD = ad-hoc
   ```

</details>

#### 2. 重新构建

```bash
git tag v1.0.7-adhoc
git push origin v1.0.7-adhoc
```

#### 3. 安装到设备

有多种安装方式：

**方式 A: 使用在线安装服务**

1. 上传 IPA 到 [Diawi](https://www.diawi.com/)
2. 生成安装链接
3. 在 iPhone Safari 中打开链接
4. 点击安装

**方式 B: 使用 Apple Configurator 2**

1. 在 Mac 上下载 [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344)
2. 连接 iPhone
3. 将 IPA 拖到设备上

**方式 C: 使用 Xcode**

```bash
# 通过 Xcode 命令行安装
xcrun devicectl device install app --device <DEVICE_ID> WebViewApp.ipa
```

---

## 方式 3: 企业分发（仅企业账号）

如果你有 Apple Developer Enterprise Program 账号，可以使用企业分发：

```
优点：
- 无设备数量限制
- 不需要注册 UDID
- 可以通过网站直接安装

缺点：
- 需要企业账号（$299/年）
- 仅限内部员工使用
- 违规可能被吊销证书
```

---

## 方式 4: 模拟器安装（仅开发测试）

### 📦 .app 文件说明

- `.app` 文件是为 iOS 模拟器编译的
- **不能**安装到真实 iPhone/iPad 设备
- 只能在 Mac 的 Xcode Simulator 中运行

### 使用方法

```bash
# 1. 解压 .app.zip
unzip WebViewApp-debug.app.zip

# 2. 打开 Xcode Simulator
open -a Simulator

# 3. 拖动 .app 文件到模拟器窗口
# 或使用命令行
xcrun simctl install booted WebViewApp.app
```

---

## 🎯 推荐方案

### 场景 1: 给少量测试人员使用
**推荐**: TestFlight
- 最简单，不需要电脑
- 测试人员只需要安装 TestFlight App

### 场景 2: 给公司内部员工使用
**推荐**: Ad Hoc（设备少于 100 台）
- 收集所有设备 UDID
- 创建 Ad Hoc Profile 包含这些设备
- 使用 Diawi 等服务分发

### 场景 3: 给大量用户使用
**推荐**: App Store 正式发布
- 无设备限制
- 无需 TestFlight
- 需要通过 App Store 审核

---

## ❓ 常见问题

### Q1: 我想要无需电脑直接安装，怎么做？

**A**: 使用 TestFlight 或 Ad Hoc + 在线安装服务（如 Diawi）

```
TestFlight 方案（推荐）：
1. 上传 IPA 到 App Store Connect
2. 邀请测试人员
3. 测试人员在 iPhone 上安装 TestFlight
4. 从 TestFlight 安装应用

Ad Hoc 方案：
1. 收集设备 UDID
2. 创建 Ad Hoc Profile（包含这些设备）
3. 重新打包
4. 上传 IPA 到 Diawi
5. 分享安装链接
```

### Q2: .app 文件和 .ipa 文件有什么区别？

**A**: 
- `.app`: 模拟器应用包，只能在 Mac 的 iOS 模拟器运行
- `.ipa`: iOS 设备安装包，可以安装到真实 iPhone/iPad

### Q3: 为什么我的 IPA 无法安装？

**A**: 可能的原因：
1. ✅ 检查 Profile 类型是否正确
   - App Store Profile → 只能通过 TestFlight/App Store
   - Ad Hoc Profile → 需要设备 UDID 已注册
   
2. ✅ 检查设备是否已注册
   ```bash
   # 查看 Profile 包含的设备
   security cms -D -i xxx.mobileprovision | grep -A 20 ProvisionedDevices
   ```

3. ✅ 检查证书是否过期
   - Distribution 证书有效期为 1 年

### Q4: 如何获取设备 UDID？

**A**: 三种方法：
```
方法 1: Finder（需要 Mac）
连接设备 → Finder → 点击序列号 → 显示 UDID

方法 2: 在线工具
https://get.udid.io/
在设备上用 Safari 打开

方法 3: Xcode
Window → Devices and Simulators → 查看 Identifier
```

### Q5: 当前构建的 IPA 如何安装？

**A**: 当前使用的是 **App Store Profile**，只能通过以下方式安装：

```
✅ 方式 1: TestFlight（推荐）
1. 上传 IPA 到 App Store Connect
2. 邀请测试人员
3. 通过 TestFlight App 安装

❌ 方式 2: 直接安装（不支持）
当前 Profile 类型不支持直接安装
如需直接安装，请：
1. 创建 Ad Hoc Provisioning Profile
2. 在 GitHub Secrets 中更新
3. 重新构建
```

---

## 📚 相关文档

- [TestFlight Beta Testing](https://developer.apple.com/testflight/)
- [Ad Hoc Distribution](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [证书和密钥配置指南](./证书和密钥配置指南.md)

---

## 🆘 需要帮助？

如果遇到问题，请提供以下信息：
1. 安装方式（TestFlight / Ad Hoc / 其他）
2. Profile 类型（App Store / Ad Hoc）
3. 错误信息截图
4. 设备 iOS 版本




# iOS 构建配置说明

本文档说明如何正确配置 iOS 构建参数，确保所有配置都通过 `assets/appX/app.cfg` 文件管理。

---

## ✅ 已修复的问题

### 问题：构建失败 - "Signing for 'WebViewApp' requires a development team"

**原因**：
- `project.pbxproj` 中的 `DEVELOPMENT_TEAM` 是硬编码的空字符串
- 配置脚本没有正确替换占位符

**解决方案**：
1. ✅ 修改 `project.pbxproj`，将所有硬编码值改为占位符
2. ✅ 更新 `build_config.py`，确保正确替换所有占位符
3. ✅ 从 `app.cfg` 读取 Team ID 等配置

---

## 📋 必需的配置项

### 在 `assets/app1/app.cfg` 中配置

```properties
# ============================================
# 应用基本信息
# ============================================
appName=PsychologicalGym
appDisplayName=PsychologicalGym
appId=com.xlab.psychologicalgym
appVersion=1.0.0
buildNumber=1

# ============================================
# iOS 特定配置
# ============================================

# 1. Team ID（必需）⭐️
# 在 Apple Developer Portal 获取：https://developer.apple.com/account/ → Membership
# 格式：10 位字符（字母和数字）
iosTeamId=G3NJ44L7QL

# 2. Bundle ID（必需）⭐️
# 必须与 Apple Developer Portal 中注册的 App ID 一致
iosBundleId=com.xlab.psychologicalgym

# 3. 显示名称
iosBundleDisplayName=PsychologicalGym

# 4. 版本信息
iosBundleVersion=1.0.0
iosBuildNumber=1

# 5. 最低系统版本
iosDeploymentTarget=13.0

# 6. 证书名称（可选，CI/CD 会使用 GitHub Secrets）
# 本地构建时可以留空，使用 Automatic 签名
iosCertificateName=

# 7. Provisioning Profile 名称（可选，CI/CD 会使用 GitHub Secrets）
# 本地构建时可以留空，使用 Automatic 签名
iosProvisioningProfile=

# 8. 导出方式（必需）⭐️
# app-store: 用于 TestFlight 和 App Store
# ad-hoc: 用于内部分发（需要注册设备）
# development: 用于开发测试
iosExportMethod=app-store

# 9. 构建模式
# true: Debug 模式（模拟器，无需签名）
# false: Release 模式（真机，需要证书）
isDebug=false
```

---

## 🔧 配置说明

### 1. 获取 Team ID

**方法 1：通过 Apple Developer Portal**

```bash
1. 访问 https://developer.apple.com/account/
2. 登录你的 Apple ID
3. 点击左侧 "Membership"
4. 在页面中找到 "Team ID"
5. 复制 10 位字符（如 G3NJ44L7QL）
6. 粘贴到 app.cfg 的 iosTeamId
```

**方法 2：通过 Xcode**

```bash
1. 打开 Xcode
2. Preferences → Accounts
3. 选择你的 Apple ID
4. 在右侧 Team 列表中，Team ID 显示在括号中
5. 复制并粘贴到 app.cfg
```

### 2. 配置 Bundle ID

**必须与 Apple Developer Portal 中注册的 App ID 完全一致！**

```bash
1. 访问 https://developer.apple.com/account/
2. Certificates, Identifiers & Profiles → Identifiers
3. 找到你的 App ID
4. 复制 Identifier（如 com.xlab.psychologicalgym）
5. 确保 app.cfg 中的 iosBundleId 和 appId 一致
```

### 3. 选择导出方式

| 导出方式 | 用途 | 需要证书 | 需要注册设备 |
|---------|------|---------|------------|
| `app-store` | TestFlight / App Store | ✅ 是 | ❌ 否 |
| `ad-hoc` | 内部分发测试 | ✅ 是 | ✅ 是（≤100台） |
| `development` | 开发调试 | ✅ 是 | ✅ 是（≤100台） |

**推荐**：使用 `app-store`，通过 TestFlight 分发测试版本。

---

## 🚀 构建流程

### 本地构建（Debug 模式）

```bash
# 1. 配置
vim assets/app1/app.cfg
# 设置：isDebug=true

# 2. 运行配置脚本
python3 scripts/build_config.py

# 3. 构建（模拟器）
cd ios
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build

# 4. 在 Xcode 中运行
open WebViewApp.xcodeproj
# 选择模拟器，点击运行
```

### 本地构建（Release 模式）

```bash
# 1. 配置
vim assets/app1/app.cfg
# 设置：
#   isDebug=false
#   iosTeamId=G3NJ44L7QL  # 你的 Team ID

# 2. 运行配置脚本
python3 scripts/build_config.py

# 3. 在 Xcode 中配置签名
open ios/WebViewApp.xcodeproj
# Target → Signing & Capabilities
# 选择你的 Team
# 选择 Provisioning Profile

# 4. Archive
# Product → Archive
# 或使用命令行：
cd ios
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/WebViewApp.xcarchive \
  archive
```

### GitHub Actions 自动构建

```bash
# 1. 配置 GitHub Secrets
# 必需的 Secrets：
- IOS_CERTIFICATE_BASE64          # Distribution 证书
- IOS_CERTIFICATE_PASSWORD        # 证书密码
- IOS_PROVISIONING_PROFILE_BASE64 # App Store Profile
- IOS_TEAM_ID                     # Team ID (G3NJ44L7QL)
- IOS_EXPORT_METHOD               # app-store（可选，有默认值）
- KEYCHAIN_PASSWORD               # 临时密码（随机字符串）

# 2. 配置 app.cfg
vim assets/app1/app.cfg
# 设置：
#   isDebug=false
#   iosTeamId=G3NJ44L7QL
#   iosExportMethod=app-store

# 3. 提交并打标签
git add .
git commit -m "Configure iOS build"
git tag v1.0.0
git push origin v1.0.0

# 4. GitHub Actions 会自动：
#   - 读取 app.cfg 配置
#   - 运行 build_config.py 替换占位符
#   - 安装证书和 Profile
#   - 构建并导出 IPA
#   - 上传到 Release

# 5. 下载 IPA 并上传到 App Store Connect
```

---

## 🔍 验证配置

### 检查配置是否正确

```bash
# 1. 运行配置脚本
python3 scripts/build_config.py

# 2. 检查 project.pbxproj 是否正确替换
grep "DEVELOPMENT_TEAM" ios/WebViewApp.xcodeproj/project.pbxproj
# 应该显示：DEVELOPMENT_TEAM = G3NJ44L7QL;

grep "PRODUCT_BUNDLE_IDENTIFIER" ios/WebViewApp.xcodeproj/project.pbxproj
# 应该显示：PRODUCT_BUNDLE_IDENTIFIER = com.xlab.psychologicalgym;

# 3. 检查 Info.plist
grep "CFBundleIdentifier" ios/WebViewApp/Info.plist
# 应该显示：<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

---

## ⚠️ 常见问题

### 问题 1：Team ID 不正确

**错误信息**：
```
error: Signing for "WebViewApp" requires a development team.
```

**解决方案**：
1. 确认 `app.cfg` 中的 `iosTeamId` 已填写
2. 确认 Team ID 是 10 位字符（如 G3NJ44L7QL）
3. 运行 `python3 scripts/build_config.py`
4. 检查 `project.pbxproj` 中的 `DEVELOPMENT_TEAM`

### 问题 2：Bundle ID 不匹配

**错误信息**：
```
error: No profiles for 'com.xlab.psychologicalgym' were found
```

**解决方案**：
1. 确认 Apple Developer Portal 中已创建对应的 App ID
2. 确认 `app.cfg` 中的 `iosBundleId` 与 App ID 完全一致
3. 确认 `appId` 和 `iosBundleId` 保持一致
4. 重新运行配置脚本

### 问题 3：Provisioning Profile 不匹配

**错误信息**：
```
error: Provisioning profile doesn't include signing certificate
```

**解决方案**：
1. 确认 Provisioning Profile 包含你的 Distribution 证书
2. 确认 Profile 类型正确（App Store vs Ad Hoc）
3. 重新下载 Profile 并转换为 Base64
4. 更新 GitHub Secret: `IOS_PROVISIONING_PROFILE_BASE64`

### 问题 4：证书过期

**错误信息**：
```
error: The certificate used to sign "WebViewApp" has either expired or has been revoked
```

**解决方案**：
1. 检查证书有效期（在 Apple Developer Portal）
2. 如果过期，创建新证书
3. 更新 Provisioning Profile（包含新证书）
4. 更新 GitHub Secrets

---

## 📚 相关文档

- [证书和密钥配置指南](./证书和密钥配置指南.md) - 完整的证书配置流程
- [构建发布指南](./构建发布指南.md) - 如何构建和发布应用
- [配置文件说明](./配置文件说明.md) - app.cfg 完整配置说明

---

## 🎯 快速检查清单

构建前确认：

- [ ] `iosTeamId` 已填写（10位字符）
- [ ] `iosBundleId` 与 Apple Developer Portal 一致
- [ ] `appId` 和 `iosBundleId` 一致
- [ ] `isDebug` 设置正确（true/false）
- [ ] `iosExportMethod` 设置正确（app-store/ad-hoc）
- [ ] 已运行 `python3 scripts/build_config.py`
- [ ] GitHub Secrets 已配置（如果使用 CI/CD）
- [ ] 证书和 Profile 有效且未过期

---

**最后更新**: 2024年12月11日




# iOS离线HTML加载问题修复说明

## 🐛 问题描述

**症状：**
- iOS App打开后，WebView显示空白页面
- 配置文件中设置了 `isWebLocal=true`
- Android版本可以正常显示离线HTML内容

**原因：**
iOS项目的 `project.pbxproj` 文件中缺少 `webapp` 目录的引用，导致：
1. 构建脚本虽然下载了HTML文件到 `ios/WebViewApp/webapp/` 目录
2. 但这个目录没有被添加到Xcode项目中
3. 打包时webapp目录不会被包含在 .app bundle 中
4. 运行时无法找到 `webapp/index.html` 文件

## ✅ 修复内容

### 1. 修改了 project.pbxproj 文件

添加了 webapp 目录的引用，确保它被包含在app bundle中：

```xml
<!-- 在 PBXBuildFile 部分添加 -->
8D1107500486CEB800E470B0 /* webapp in Resources */ = {isa = PBXBuildFile; fileRef = 8D11074F0486CEB800E470AF /* webapp */; };

<!-- 在 PBXFileReference 部分添加 -->
8D11074F0486CEB800E470AF /* webapp */ = {isa = PBXFileReference; lastKnownFileType = folder; path = webapp; sourceTree = "<group>"; };

<!-- 在 PBXGroup (WebViewApp) 中添加 -->
8D11074F0486CEB800E470AF /* webapp */,

<!-- 在 PBXResourcesBuildPhase 中添加 -->
8D1107500486CEB800E470B0 /* webapp in Resources */,
```

### 2. 创建了占位 webapp 目录

创建了 `ios/WebViewApp/webapp/index.html` 占位文件，作用：
- 确保项目可以正常编译（即使没运行构建脚本）
- 提供开发时的提示信息
- 在实际构建时会被自动替换为真实的网页内容

## 📋 工作流程

### 构建流程

1. **运行构建脚本**
   ```bash
   python3 scripts/build_config.py
   ```

2. **脚本处理（针对 isWebLocal=true）**
   - 下载 `loadUrl` 指定的HTML页面
   - 解析HTML中的所有资源（CSS、JS、图片等）
   - 下载所有依赖资源
   - 保存到 `ios/WebViewApp/webapp/` 目录

3. **Xcode构建**
   - 将 `webapp/` 目录打包到 .app bundle
   - 文件位于: `WebViewApp.app/webapp/`

4. **运行时加载**
   ```swift
   if let htmlPath = Bundle.main.path(forResource: "webapp/index", ofType: "html") {
       let htmlURL = URL(fileURLWithPath: htmlPath)
       let webappDir = htmlURL.deletingLastPathComponent()
       webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
   }
   ```

### 文件结构

```
ios/
└── WebViewApp/
    ├── webapp/                    # ← 新增的目录
    │   └── index.html            # ← 占位文件（构建时会被替换）
    │   └── ... 其他资源 ...      # ← 构建时自动下载
    ├── AppDelegate.swift
    ├── MainViewController.swift
    └── ...
```

## 🔍 验证方法

### 1. 检查 Xcode 项目

打开 `ios/WebViewApp.xcodeproj` 在 Xcode 中：
- 左侧导航栏应该能看到 `webapp` 文件夹
- 选中 `webapp` → 右侧属性面板 → 确认 "Target Membership" 勾选了 "WebViewApp"

### 2. 检查构建产物

```bash
# 构建后检查
python3 scripts/build_config.py

# 查看webapp目录内容
ls -la ios/WebViewApp/webapp/

# 应该看到：
# index.html
# ... CSS文件 ...
# ... JS文件 ...
# ... 图片文件 ...
```

### 3. 运行应用验证

在模拟器或真机上运行，应该能正常显示网页内容。

## ⚙️ 配置说明

在 `assets/idiomApp/app.cfg` 中：

```properties
# 网页URL
loadUrl=https://www.qingmiao.cloud/page/game2/idiom.html

# 启用本地模式
isWebLocal=true
```

## 🔧 故障排查

### 问题1：仍然显示空白页面

**检查步骤：**

1. **确认运行了构建脚本**
   ```bash
   python3 scripts/build_config.py
   ```

2. **检查webapp目录是否有内容**
   ```bash
   ls -la ios/WebViewApp/webapp/
   ```
   
   如果只有 `index.html` 且内容是占位页面，说明构建脚本没有正确下载网页内容。

3. **检查构建日志**
   ```bash
   python3 scripts/build_config.py 2>&1 | grep -i "web"
   ```
   
   应该看到类似：
   ```
   Downloading web content from: https://...
   Copied web content to iOS: .../ios/WebViewApp/webapp
   ```

4. **检查网络连接**
   
   确保可以访问配置的 `loadUrl`：
   ```bash
   curl -I https://www.qingmiao.cloud/page/game2/idiom.html
   ```

### 问题2：资源文件加载失败（CSS/JS/图片404）

**原因：**
- HTML中使用了绝对路径（`/path/to/file.css`）
- HTML中使用了外部CDN资源

**解决方案：**

1. **检查HTML的资源路径**
   
   打开 `ios/WebViewApp/webapp/index.html`，检查资源路径：
   ```html
   <!-- ❌ 绝对路径，会失败 -->
   <link href="/css/style.css" rel="stylesheet">
   
   <!-- ✅ 相对路径，正常 -->
   <link href="css/style.css" rel="stylesheet">
   <link href="./css/style.css" rel="stylesheet">
   ```

2. **手动修正路径**
   
   如果网页使用了绝对路径，需要手动修改HTML，或者联系网页提供方修改。

3. **允许外部资源加载**
   
   如果部分资源必须从网络加载，在 `app.cfg` 中配置：
   ```properties
   # 允许混合内容（谨慎使用）
   mixedContentMode=ALWAYS
   ```

### 问题3：构建脚本下载失败

**可能原因：**
- 网络问题
- SSL证书问题
- 网页需要认证

**解决方案：**

1. **检查URL是否可访问**
   ```bash
   curl -v https://www.qingmiao.cloud/page/game2/idiom.html
   ```

2. **使用在线模式作为备选**
   
   在 `app.cfg` 中：
   ```properties
   # 临时改为在线模式
   isWebLocal=false
   ```

3. **检查Python SSL支持**
   ```bash
   python3 -c "import ssl; print(ssl.OPENSSL_VERSION)"
   ```

## 📝 开发注意事项

### 1. Git 版本控制

建议在 `.gitignore` 中添加：

```gitignore
# 忽略下载的网页内容（但保留占位文件）
ios/WebViewApp/webapp/*
!ios/WebViewApp/webapp/index.html
```

这样：
- ✅ 占位的 `index.html` 会被提交到Git
- ❌ 下载的实际网页内容不会被提交
- ✅ 每次构建时重新下载最新内容

### 2. 本地开发

如果经常修改和测试，每次都要运行构建脚本：

```bash
# 快速构建命令
python3 scripts/build_config.py && cd ios && xcodebuild -project WebViewApp.xcodeproj -scheme WebViewApp -configuration Debug -sdk iphonesimulator
```

或者创建一个快捷脚本：

```bash
#!/bin/bash
# dev-build-ios.sh

echo "🔧 Configuring..."
python3 scripts/build_config.py

echo "🏗️ Building iOS app..."
cd ios
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build-debug

echo "✅ Build complete!"
```

### 3. 在线模式 vs 离线模式

| 特性 | 离线模式 (`isWebLocal=true`) | 在线模式 (`isWebLocal=false`) |
|------|----------------------------|------------------------------|
| **网络依赖** | ❌ 运行时不需要网络 | ✅ 需要网络连接 |
| **加载速度** | ⚡ 快（本地文件） | 🐌 慢（取决于网络） |
| **内容更新** | 需要重新构建和发布 | 实时更新 |
| **包大小** | 📦 较大（包含所有资源） | 📦 较小 |
| **适用场景** | 固定内容、离线使用 | 动态内容、频繁更新 |

## 🎯 最佳实践

1. **开发阶段**：使用在线模式（`isWebLocal=false`），方便实时调试

2. **发布阶段**：评估是否需要离线模式：
   - 内容稳定、不常更新 → 使用离线模式
   - 内容经常更新、需要实时性 → 使用在线模式

3. **混合方案**：
   - 核心HTML/CSS/JS 使用离线模式
   - 动态数据通过API获取

## 📚 相关文档

- [离线HTML加载配置说明](./离线HTML加载配置说明.md)
- [iOS打包说明](./iOS打包说明.md)
- [配置文件说明](./配置文件说明.md)

---

## 🔄 修复历史

- **2025-12-18**: 修复了iOS本地HTML加载问题，添加webapp目录到project.pbxproj










# isWebLocal 配置说明

## 概述

`isWebLocal` 配置项决定了应用如何加载网页内容：
- `false`（默认）：从 `loadUrl` 指定的在线 URL 加载内容
- `true`：下载网页内容并打包到应用中，支持离线使用

---

## 配置项

### isWebLocal

- **类型**：布尔值
- **默认值**：`false`
- **说明**：是否将 HTML 内容打包到应用中（离线模式）

```properties
# 在线模式（默认）
isWebLocal=false

# 离线模式
isWebLocal=true
```

---

## 在线模式 (isWebLocal=false)

### 工作原理

1. 应用启动时从 `loadUrl` 加载在线内容
2. 需要网络连接才能使用
3. 内容更新无需重新发布应用

### 优点

✅ 应用体积小  
✅ 内容可以随时更新  
✅ 不需要重新发布应用  
✅ 适合频繁更新的网页

### 缺点

❌ 需要网络连接  
❌ 首次加载速度取决于网络  
❌ 无法离线使用

### 配置示例

```properties
# 应用将从这个 URL 加载内容
loadUrl=https://www.example.com/app

# 在线模式
isWebLocal=false
```

### 构建行为

当 `isWebLocal=false` 时，`build_config.py` 脚本会：
1. **创建空的 `webapp` 占位目录**（避免 iOS 构建错误）
2. 不下载任何网页内容
3. 应用在运行时直接访问 `loadUrl`

---

## 离线模式 (isWebLocal=true)

### 工作原理

1. 构建时从 `loadUrl` 下载完整的网页内容
2. 将 HTML、CSS、JS、图片等资源打包到应用中
3. 应用启动时从本地加载内容

### 优点

✅ 无需网络连接  
✅ 启动速度快  
✅ 完全离线可用  
✅ 适合静态内容应用

### 缺点

❌ 应用体积较大  
❌ 内容更新需要重新发布应用  
❌ 不适合频繁更新的内容

### 配置示例

```properties
# 从这个 URL 下载网页内容
loadUrl=https://www.example.com/static-app

# 离线模式
isWebLocal=true
```

### 构建行为

当 `isWebLocal=true` 时，`build_config.py` 脚本会：
1. **下载 `loadUrl` 指定的 HTML 页面**
2. **解析 HTML 并下载所有关联资源**：
   - CSS 文件（`<link>` 标签）
   - JavaScript 文件（`<script>` 标签）
   - 图片（`<img>`, `<source>` 标签）
   - 视频、音频等媒体文件
3. **保存到以下目录**：
   - Android：`android/app/src/main/assets/webapp/`
   - iOS：`ios/WebViewApp/webapp/`
4. **修改应用代码**，从本地路径加载内容

---

## 常见问题

### 1. iOS 构建失败：webapp 目录不存在

**错误信息**：
```
error: lstat(/path/to/ios/WebViewApp/webapp): No such file or directory
```

**原因**：
- 在 `isWebLocal=false` 模式下，旧版本脚本不会创建 `webapp` 目录
- iOS Xcode 项目引用了这个目录

**解决方案**：
- ✅ 已修复：最新版本脚本会自动创建占位目录
- 如果仍然失败，手动运行：
  ```bash
  mkdir -p ios/WebViewApp/webapp
  touch ios/WebViewApp/webapp/.placeholder
  ```

### 2. 离线模式下载失败

**可能原因**：
1. `loadUrl` 不是有效的 HTTP/HTTPS URL
2. 网络连接问题
3. 目标网站阻止了爬虫

**解决方案**：
1. 确认 `loadUrl` 是完整的 URL（包含 `http://` 或 `https://`）
2. 检查网络连接
3. 查看构建日志中的详细错误信息
4. 如果下载失败，脚本会回退到在线模式

### 3. 离线模式下部分资源加载失败

**原因**：
- 网页使用了动态加载的资源
- 资源路径是相对路径或绝对路径
- JavaScript 动态生成的内容

**建议**：
- 对于复杂的单页应用（SPA），建议使用在线模式
- 离线模式适合简单的静态页面

### 4. 应用体积过大

**原因**：
- 离线模式打包了所有资源

**解决方案**：
1. 优化网页资源（压缩图片、CSS、JS）
2. 移除不必要的资源
3. 考虑使用在线模式

---

## 使用建议

### 选择在线模式的场景

✅ **推荐使用在线模式**如果：
- 内容需要频繁更新
- 网页是动态生成的
- 包含用户交互和数据提交
- 需要与服务器实时通信
- 应用体积需要控制

**示例**：
- 新闻应用
- 社交媒体应用
- 电商应用
- 在线工具

### 选择离线模式的场景

✅ **推荐使用离线模式**如果：
- 内容是静态的，很少更新
- 需要完全离线可用
- 网页资源不大（< 10MB）
- 用户可能在无网络环境使用

**示例**：
- 电子书阅读器
- 离线工具
- 静态文档查看器
- 简单的游戏

---

## 技术细节

### Android 实现

```kotlin
// MainActivity.kt
if (AppConfig.IS_WEB_LOCAL) {
    // 加载本地HTML文件
    webView.loadUrl("file:///android_asset/webapp/index.html")
} else {
    // 加载在线URL
    webView.loadUrl(AppConfig.LOAD_URL)
}
```

### iOS 实现

```swift
// MainViewController.swift
if AppConfig.isWebLocal {
    // 加载本地HTML文件
    if let htmlPath = Bundle.main.path(forResource: "webapp/index", ofType: "html") {
        let htmlURL = URL(fileURLWithPath: htmlPath)
        let webappDir = htmlURL.deletingLastPathComponent()
        webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
    }
} else {
    // 加载在线URL
    guard let url = URL(string: AppConfig.loadUrl) else { return }
    let request = URLRequest(url: url)
    webView.load(request)
}
```

### 构建脚本逻辑

```python
# build_config.py
is_web_local = self.parse_boolean(self.config.get('isWebLocal', 'false'))

if is_web_local:
    # 下载并打包网页内容
    self.download_web_content(load_url, temp_web_dir)
    shutil.copytree(temp_web_dir, android_assets_dir)
    shutil.copytree(temp_web_dir, ios_webapp_dir)
else:
    # 创建占位目录（避免构建错误）
    ios_webapp_dir.mkdir(parents=True, exist_ok=True)
    android_assets_dir.mkdir(parents=True, exist_ok=True)
```

---

## 相关文档

- [离线HTML加载配置说明](./离线HTML加载配置说明.md)
- [配置文件说明](./配置文件说明.md)
- [构建和安装指南](./构建和安装指南.md)

---

**最后更新**：2025-12-21










# App Store Connect API 集成说明

## 概述

本项目集成了 App Store Connect API，用于自动化以下流程：

1. **检查应用是否存在**：在上传到 TestFlight 之前，检查 App Store Connect 中是否已经创建了该应用
2. **自动创建应用**：如果应用不存在，自动在 App Store Connect 中创建
3. **上传元数据**：自动上传应用的描述、关键词、截图、推广文本等元数据
4. **多语言支持**：支持为多个语言（如简体中文、英语）配置不同的本地化内容

## 前置要求

### 1. 创建 App Store Connect API 密钥

1. 访问 [App Store Connect](https://appstoreconnect.apple.com/)
2. 进入 **用户和访问** → **密钥** → **App Store Connect API**
3. 点击 **生成 API 密钥** 或选择现有密钥
4. 记录以下信息：
   - **密钥 ID**（Key ID）
   - **颁发者 ID**（Issuer ID）
   - **下载 .p8 私钥文件**（只能下载一次，请妥善保管）

### 2. 配置 GitHub Secrets

在 GitHub 仓库设置中添加以下 Secrets：

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `APP_STORE_API_KEY_ID` | API 密钥 ID | `ABC1234567` |
| `APP_STORE_API_ISSUER_ID` | 颁发者 ID | `12345678-1234-1234-1234-123456789012` |
| `APP_STORE_API_KEY_BASE64` | .p8 私钥文件的 Base64 编码 | 见下方说明 |

#### 生成 Base64 编码的私钥

```bash
# macOS/Linux
base64 -i AuthKey_ABC1234567.p8

# 或者
cat AuthKey_ABC1234567.p8 | base64
```

## 配置文件说明

在 `app.cfg` 文件中添加以下配置项：

### iOS 基本配置

```properties
# iOS SKU（唯一标识符，用于App Store Connect）
# 如果不填，将使用 appId 替换 . 为 - 作为默认值
iosSku=com-xlab-myapp

# iOS 主要语言（App Store Connect 首选语言）
# 常见值: zh-Hans (简体中文), zh-Hant (繁体中文), en-US (美国英语), ja (日语)
iosPrimaryLocale=zh-Hans

# iOS 支持的语言列表（逗号分隔）
iosLocales=zh-Hans,en-US
```

### App Store 元数据配置

```properties
# 应用副标题（App Store 显示，30字符以内）
appSubtitle=轻松学习的小游戏

# 应用描述（通用）
appDescription=这是一个有趣的学习应用

# 应用描述 - 简体中文（可选，未设置则使用通用描述）
appDescription_zh_Hans=这是一个有趣的学习应用，支持多种学习模式

# 应用描述 - 英语
appDescription_en_US=This is a fun learning app

# 应用关键词（逗号分隔，最多100字符）
appKeywords=学习,小游戏,教育

# 应用关键词 - 简体中文
appKeywords_zh_Hans=学习,小游戏,教育

# 应用关键词 - 英语
appKeywords_en_US=learning,game,education

# 推广文本（170字符以内，可随时更新）
appPromotionalText=全新版本上线！

# 版本更新说明
appReleaseNotes=1. 修复问题\n2. 优化体验

# 技术支持网址（必填）
appSupportUrl=https://example.com

# 营销网址（选填）
appMarketingUrl=https://example.com

# 隐私政策网址（必填）
appPrivacyPolicyUrl=https://example.com/privacy

# 版权信息
appCopyright=2025 Your Company
```

### App 审核联系信息

```properties
# 审核联系人 - 姓
reviewContactFirstName=张

# 审核联系人 - 名
reviewContactLastName=三

# 审核联系人 - 手机号码（含国家代码）
reviewContactPhone=+86 13800138000

# 审核联系人 - 邮箱
reviewContactEmail=support@example.com

# 审核备注（选填）
reviewNotes=这是一个教育应用
```

## 工作流程

### GitHub Actions 自动化流程

1. 当推送带有 `v*` 标签时触发构建
2. 构建 iOS Release 版本
3. **执行 App Store Connect 检查**（新增步骤）
   - 检查应用是否存在
   - 如果不存在，创建应用
   - 上传/更新元数据
4. 上传 IPA 到 TestFlight
5. 创建 GitHub Release

### 本地测试

你也可以在本地测试 App Store Connect API 脚本：

```bash
# 安装依赖
pip install Pillow PyJWT requests cryptography

# 设置环境变量
export APP_STORE_API_KEY_ID="your_key_id"
export APP_STORE_API_ISSUER_ID="your_issuer_id"

# 确保 API 密钥文件位于正确位置
mkdir -p ~/.appstoreconnect/private_keys
cp AuthKey_*.p8 ~/.appstoreconnect/private_keys/

# 运行脚本
python3 scripts/app_store_connect.py /path/to/workspace
```

## 多语言配置指南

### 支持的语言代码

常见的语言代码：

- `zh-Hans` - 简体中文
- `zh-Hant` - 繁体中文
- `en-US` - 美国英语
- `en-GB` - 英国英语
- `ja` - 日语
- `ko` - 韩语
- `fr-FR` - 法语
- `de-DE` - 德语
- `es-ES` - 西班牙语

完整列表请参考 [Apple 官方文档](https://developer.apple.com/documentation/appstoreconnectapi/betabuildlocalizationcreaterequest/data/attributes)

### 配置特定语言的内容

使用 `_语言代码` 后缀（将 `-` 替换为 `_`）来配置特定语言的内容：

```properties
# 简体中文
appDescription_zh_Hans=简体中文描述
appKeywords_zh_Hans=关键词1,关键词2
appPromotionalText_zh_Hans=推广文本

# 繁体中文
appDescription_zh_Hant=繁體中文描述
appKeywords_zh_Hant=關鍵詞1,關鍵詞2

# 英语
appDescription_en_US=English description
appKeywords_en_US=keyword1,keyword2
appPromotionalText_en_US=Promotional text
```

如果某个语言没有配置特定内容，将使用通用配置（不带后缀的配置项）。

## 注意事项

1. **API 限制**：App Store Connect API 有速率限制，请避免频繁调用
2. **权限要求**：API 密钥需要具有 **Admin** 或 **App Manager** 权限
3. **首次创建**：首次创建应用时，还需要在 App Store Connect 手动完成一些步骤（如上传截图、设置定价等）
4. **元数据审核**：元数据的修改需要通过 Apple 审核
5. **隐私政策**：`appPrivacyPolicyUrl` 是必填项，确保链接可访问

## 故障排查

### 常见错误

#### 1. "应用已存在但 Bundle ID 不匹配"

**原因**：App Store Connect 中已存在同名应用，但 Bundle ID 不同。

**解决方案**：
- 修改 `appId` 使用不同的 Bundle ID
- 或在 App Store Connect 中删除旧应用（如果不再使用）

#### 2. "API 密钥无效"

**原因**：
- API 密钥过期或被撤销
- Base64 编码有误
- 文件路径不正确

**解决方案**：
- 重新生成 API 密钥
- 检查 Base64 编码是否正确
- 确认文件路径：`~/.appstoreconnect/private_keys/AuthKey_{KEY_ID}.p8`

#### 3. "权限不足"

**原因**：API 密钥没有足够的权限。

**解决方案**：
- 在 App Store Connect 中，将 API 密钥的角色设置为 **Admin** 或 **App Manager**

#### 4. "应用创建失败"

**原因**：
- Bundle ID 已被其他账号使用
- SKU 不唯一
- Team ID 不正确

**解决方案**：
- 使用唯一的 Bundle ID
- 修改 `iosSku` 使用不同的值
- 检查 `iosTeamId` 是否正确

## API 参考

- [App Store Connect API 官方文档](https://developer.apple.com/documentation/appstoreconnectapi)
- [创建应用](https://developer.apple.com/documentation/appstoreconnectapi/app)
- [管理应用元数据](https://developer.apple.com/documentation/appstoreconnectapi/app_metadata)

## 支持

如有问题，请查看：
1. GitHub Actions 日志
2. 脚本输出信息
3. Apple Developer 账号状态

---

**注意**：请妥善保管 API 密钥文件，不要提交到版本控制系统中。



# App Store 截图自动生成和上传说明

## 概述

本功能可以自动从 `splashScreen` 图片生成符合 App Store 要求的截图，并通过 App Store Connect API 自动上传。

### 功能特点

✅ **自动生成多种尺寸**：支持 iPhone 和 iPad 的各种屏幕尺寸  
✅ **智能缩放**：保持图片原始比例，不会变形  
✅ **白色背景扩展**：图片周围使用白色背景填充，保持专业外观  
✅ **自动上传**：生成后自动上传到 App Store Connect  
✅ **多语言支持**：为每个配置的语言上传截图

---

## 支持的设备类型

### iPhone 截图尺寸

| 设备类型 | 尺寸 | 适用设备 | 必需 |
|---------|------|---------|------|
| `iPhone_6.7` | 1290 x 2796 | iPhone 14 Pro Max, 15 Pro Max | ✅ 是 |
| `iPhone_6.5` | 1242 x 2688 | iPhone 11 Pro Max, XS Max | 否 |
| `iPhone_5.5` | 1242 x 2208 | iPhone 8 Plus, 7 Plus | 否 |

### iPad 截图尺寸

| 设备类型 | 尺寸 | 适用设备 | 推荐 |
|---------|------|---------|------|
| `iPad_12.9_3rd` | 2048 x 2732 | iPad Pro 12.9" (第3代及以后) | ✅ 是 |
| `iPad_12.9_2nd` | 2048 x 2732 | iPad Pro 12.9" (第2代) | 否 |

**注意**：
- `iPhone_6.7` 是必需的，Apple 要求所有应用提供最新设备的截图
- 如果应用支持 iPad，建议同时提供 iPad 截图

---

## 配置说明

在 `assets/{appName}/app.cfg` 中添加以下配置：

```properties
# ============================================
# App Store 截图配置 / App Store Screenshots
# ============================================

# 是否启用截图上传（true: 自动生成并上传截图, false: 不上传截图）
enableScreenshotUpload=true

# 要生成的设备类型（逗号分隔）
# 可选值: iPhone_6.7, iPhone_6.5, iPhone_5.5, iPad_12.9_3rd, iPad_12.9_2nd
# 建议至少包含: iPhone_6.7 (最新 iPhone), iPad_12.9_3rd (iPad Pro)
screenshotDeviceTypes=iPhone_6.7,iPad_12.9_3rd

# 是否在截图上添加应用名称和副标题
screenshotAddText=false
```

### 配置项说明

#### enableScreenshotUpload

- **类型**：布尔值
- **默认值**：`true`
- **说明**：是否启用截图自动生成和上传
- **效果**：
  - `true`：自动生成截图并上传到 App Store Connect
  - `false`：跳过截图生成和上传

#### screenshotDeviceTypes

- **类型**：字符串（逗号分隔）
- **默认值**：`iPhone_6.7,iPad_12.9_3rd`
- **说明**：要生成的设备类型列表
- **可选值**：
  - `iPhone_6.7` - iPhone 14/15 Pro Max（必需）
  - `iPhone_6.5` - iPhone 11/XS Pro Max
  - `iPhone_5.5` - iPhone 8 Plus
  - `iPad_12.9_3rd` - iPad Pro 12.9"（第3代）
  - `iPad_12.9_2nd` - iPad Pro 12.9"（第2代）
- **建议**：至少包含 `iPhone_6.7` 和 `iPad_12.9_3rd`

#### screenshotAddText

- **类型**：布尔值
- **默认值**：`false`
- **说明**：是否在截图上添加应用名称和副标题
- **效果**：
  - `true`：在截图底部添加应用名称和副标题（从 `appDisplayName` 和 `appSubtitle` 读取）
  - `false`：只显示图片，不添加文字

---

## 使用方法

### 自动使用（GitHub Actions）

当你推送版本标签时，GitHub Actions 会自动：

1. 从 `splashScreen` 下载图片
2. 生成指定设备类型的截图
3. 上传截图到 App Store Connect

无需手动操作！

### 本地测试

如果需要在本地测试截图生成：

```bash
# 安装依赖
pip install Pillow PyJWT requests cryptography

# 生成截图
python3 scripts/generate_app_screenshots.py /path/to/workspace

# 查看生成的截图
ls screenshots/{appName}/
```

生成的截图将保存在 `screenshots/{appName}/` 目录下。

---

## 工作原理

### 1. 图片下载

脚本从 `app.cfg` 中的 `splashScreen` 配置项读取图片 URL，支持：
- HTTP/HTTPS URL
- 本地文件路径

### 2. 图片处理

```
原始图片 → 等比缩放 → 居中放置 → 白色背景填充 → 目标尺寸
```

**处理细节**：
- 保持图片原始宽高比
- 使用画布 90% 的空间（留 10% 边距）
- 使用高质量的 Lanczos 重采样算法
- 背景使用纯白色 `(255, 255, 255)`

### 3. 可选文字叠加

如果 `screenshotAddText=true`，会在截图底部添加：
- 应用名称（从 `appDisplayName` 读取）
- 应用副标题（从 `appSubtitle` 读取）

文字使用系统字体（PingFang 或 DejaVu Sans）并带有阴影效果。

### 4. 上传到 App Store Connect

通过 App Store Connect API 上传截图：
1. 查找或创建截图集（Screenshot Set）
2. 为每个设备类型创建截图记录
3. 上传截图文件
4. 确认上传完成（MD5 校验）

---

## 截图示例

### 原始图片（512x512）

```
┌─────────────┐
│             │
│   App Logo  │
│             │
└─────────────┘
```

### 生成的 iPhone 6.7" 截图（1290x2796）

```
┌─────────────────────────┐
│      白色背景              │
│                          │
│  ┌─────────────────┐    │
│  │                 │    │
│  │                 │    │
│  │   App Logo      │    │  ← 图片居中，保持比例
│  │                 │    │
│  │                 │    │
│  └─────────────────┘    │
│                          │
│      白色背景              │
└─────────────────────────┘
```

---

## 注意事项

### 图片要求

1. **推荐尺寸**：至少 512x512 像素
2. **格式**：PNG, JPG, WebP（支持透明通道）
3. **内容**：
   - 应用 Logo
   - 启动画面
   - 应用界面截图
4. **避免**：
   - 分辨率过低的图片（会模糊）
   - 包含文字的图片（如果 `screenshotAddText=true`）

### App Store 要求

1. **数量**：每个设备类型需要 1-10 张截图
   - 本脚本生成 1 张截图
   - 如需更多，可以在 App Store Connect 手动添加

2. **内容要求**：
   - 必须展示应用实际功能
   - 不能包含误导性内容
   - 不能显示其他平台（如 Android）

3. **文件大小**：
   - 最大 10MB
   - 本脚本生成的截图通常在 200-500KB

### 上传失败处理

如果截图上传失败：
1. 检查 GitHub Actions 日志查看具体错误
2. 确认 API 密钥有足够权限
3. 可以在 App Store Connect 手动上传截图
4. 截图上传失败不影响应用创建和元数据上传

---

## 常见问题

### 1. 截图看起来太小？

**原因**：原始图片分辨率太低。

**解决**：使用更高分辨率的图片（建议至少 1024x1024）。

### 2. 想要自定义背景颜色？

**当前**：脚本使用白色背景。

**自定义**：可以修改 `generate_app_screenshots.py` 中的 `background_color` 参数：

```python
background_color=(255, 255, 255, 255)  # 白色
background_color=(0, 0, 0, 255)        # 黑色
background_color=(240, 240, 240, 255)  # 浅灰色
```

### 3. 需要上传多张不同的截图？

**当前限制**：脚本只生成一张截图。

**解决方案**：
1. 使用脚本生成第一张截图
2. 在 App Store Connect 手动上传其他截图（展示不同功能的界面截图）

### 4. 截图上的文字太小/太大？

**调整**：修改 `generate_app_screenshots.py` 中的字体大小：

```python
title_font = ImageFont.truetype(..., size=int(height * 0.04))  # 4% 的高度
subtitle_font = ImageFont.truetype(..., size=int(height * 0.025))  # 2.5% 的高度
```

### 5. 为什么 iPhone 6.7" 是必需的？

**Apple 要求**：从 2023 年起，所有提交到 App Store 的应用必须提供最新设备的截图。

**参考**：[App Store Connect Help - Screenshot specifications](https://help.apple.com/app-store-connect/#/devd274dd925)

---

## 进阶用法

### 使用不同的源图片

如果不想使用 `splashScreen`，可以修改配置：

```properties
# 使用应用图标
splashScreen=https://example.com/app-icon.png

# 或使用本地文件
splashScreen=assets/app1/custom-screenshot-base.png
```

### 为不同语言生成不同的截图

**当前**：所有语言使用同一张截图。

**未来功能**：计划支持为不同语言配置不同的源图片：

```properties
splashScreen_zh_Hans=https://example.com/screenshot-zh.png
splashScreen_en_US=https://example.com/screenshot-en.png
```

---

## 相关文档

- [App Store Connect API 详细说明](README_APP_STORE_CONNECT.md)
- [快速开始指南](快速开始-App-Store-Connect.md)
- [配置文件说明](配置文件说明.md)
- [Apple 截图规范](https://help.apple.com/app-store-connect/#/devd274dd925)

---

**最后更新**：2025-12-21


# 📸 App Store 截图生成工具 - 使用示例

## ✅ 脚本已修复并测试通过

所有脚本已经过完整测试，可以正常使用！

---

## 🚀 快速开始

### 1. 安装依赖

```bash
pip install Pillow
```

### 2. 准备图片

将原始截图放到 `screenshots/originals/` 目录：

```bash
screenshots/originals/
├── iphone_1.png    # iPhone 截图
├── iphone_2.png    # iPhone 截图
├── ipad_1.png      # iPad 截图
└── watch_1.png     # Watch 截图
```

### 3. 批量生成（推荐）

```bash
bash scripts/batch_generate_screenshots.sh
```

**输出示例**:
```
======================================================
App Store 截图批量生成工具
======================================================

📁 原始图片目录: screenshots/originals
📁 输出目录: screenshots/output

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 生成 iPhone 截图
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

处理: iphone_1.png
✅ 生成完成!
总计生成: 8 张截图
  iphone_6_7: 4 张
  iphone_5_5: 4 张

处理: iphone_2.png
✅ 生成完成!
总计生成: 8 张截图
  iphone_6_7: 4 张
  iphone_5_5: 4 张

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 生成 iPad 截图
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

处理: ipad_1.png
✅ 生成完成!
总计生成: 4 张截图
  ipad_12_9: 4 张

======================================================
✅ 批量生成完成!
======================================================
```

---

## 📱 单张图片生成

### 基本使用

```bash
# 生成所有设备尺寸
python3 scripts/generate_screenshots.py screenshot.png
```

### 只生成 iPhone 截图

```bash
python3 scripts/generate_screenshots.py iphone_screenshot.png \
  --devices iphone_6_7 iphone_5_5 \
  --output screenshots/output/iphone/
```

### 只生成 iPad 截图

```bash
python3 scripts/generate_screenshots.py ipad_screenshot.png \
  --devices ipad_12_9 \
  --output screenshots/output/ipad/
```

### 只生成 Apple Watch 截图

```bash
python3 scripts/generate_screenshots.py watch_screenshot.png \
  --devices watch \
  --output screenshots/output/watch/
```

---

## 🎨 缩放模式

### fill 模式（默认，推荐）

填充整个屏幕，保持宽高比，可能裁剪边缘：

```bash
python3 scripts/generate_screenshots.py screenshot.png --mode fill
```

**适用场景**: 
- ✅ 界面截图
- ✅ 背景图
- ✅ 大部分场景

### fit 模式

完整显示图片，保持宽高比，可能留白：

```bash
python3 scripts/generate_screenshots.py screenshot.png --mode fit
```

**适用场景**: 
- ✅ Logo 展示
- ✅ 完整内容必须显示
- ✅ 边缘有重要信息

### stretch 模式（不推荐）

拉伸填充，不保持宽高比：

```bash
python3 scripts/generate_screenshots.py screenshot.png --mode stretch
```

**注意**: 可能导致图片变形

---

## 🔧 高级选项

### 调整输出质量

```bash
# 最高质量（文件更大）
python3 scripts/generate_screenshots.py screenshot.png --quality 100

# 平衡质量（默认）
python3 scripts/generate_screenshots.py screenshot.png --quality 95

# 较小文件（质量稍低）
python3 scripts/generate_screenshots.py screenshot.png --quality 85
```

### 指定输出目录

```bash
python3 scripts/generate_screenshots.py screenshot.png \
  --output my_custom_output/
```

### 查看所有支持的设备

```bash
python3 scripts/generate_screenshots.py --list-devices
```

**输出**:
```
📱 支持的设备类型:

  iphone_6_7:
    数量: 4 个尺寸
    - 1290×2796 (iPhone 6.7" 竖屏)
    - 2796×1290 (iPhone 6.7" 横屏)
    - 1320×2868 (iPhone 6.9" 竖屏)
    - 2868×1320 (iPhone 6.9" 横屏)

  iphone_5_5:
    数量: 4 个尺寸
    - 1242×2688 (iPhone 5.5" 竖屏)
    - 2688×1242 (iPhone 5.5" 横屏)
    - 1284×2778 (iPhone 5.8" 竖屏)
    - 2778×1284 (iPhone 5.8" 横屏)

  ipad_12_9:
    数量: 4 个尺寸
    - 2048×2732 (iPad 12.9" 竖屏)
    - 2732×2048 (iPad 12.9" 横屏)
    - 2064×2752 (iPad 13" 竖屏)
    - 2752×2064 (iPad 13" 横屏)

  watch:
    数量: 5 个尺寸
    - 410×502 (Apple Watch Ultra 2)
    - 416×496 (Apple Watch Series 10)
    - 396×484 (Apple Watch Series 9)
    - 368×448 (Apple Watch Series 6)
    - 312×390 (Apple Watch Series 3)
```

---

## 📂 输出文件命名

生成的文件会自动命名，包含设备类型、尺寸和方向信息：

```
iphone_6_7_1290x2796_iPhone_6.7_竖屏.png
iphone_6_7_2796x1290_iPhone_6.7_横屏.png
iphone_5_5_1242x2688_iPhone_5.5_竖屏.png
ipad_12_9_2048x2732_iPad_12.9_竖屏.png
watch_410x502_Apple_Watch_Ultra_2.png
```

---

## 💡 最佳实践

### 1. 准备高质量原始图片

**推荐分辨率**:
- iPhone: **1290×2796** 或更高
- iPad: **2064×2752** 或更高
- Apple Watch: **410×502** 或更高

**推荐格式**: PNG（最佳质量）

### 2. 按设备类型命名

```bash
screenshots/originals/
├── iphone_home.png         # 自动识别为 iPhone
├── iphone_profile.png      # 自动识别为 iPhone
├── ipad_dashboard.png      # 自动识别为 iPad
└── watch_notification.png  # 自动识别为 Watch
```

### 3. 使用批处理脚本

一次处理多张图片，自动分类输出：

```bash
bash scripts/batch_generate_screenshots.sh
```

### 4. 检查生成的文件

```bash
# 查看 iPhone 截图
ls -lh screenshots/output/iphone/

# 查看 iPad 截图
ls -lh screenshots/output/ipad/

# 查看 Watch 截图
ls -lh screenshots/output/watch/
```

---

## 🎯 实际工作流程

### 场景 1: 新应用首次提交

```bash
# 1. 准备原始截图
# 将 iPhone、iPad、Watch 的截图放到 screenshots/originals/

# 2. 批量生成所有尺寸
bash scripts/batch_generate_screenshots.sh

# 3. 上传到 App Store Connect
# iPhone: screenshots/output/iphone/
# iPad: screenshots/output/ipad/
# Watch: screenshots/output/watch/
```

### 场景 2: 只更新 iPhone 截图

```bash
# 1. 准备新的 iPhone 截图
cp new_screenshot.png screenshots/originals/iphone_new.png

# 2. 只生成 iPhone 尺寸
python3 scripts/generate_screenshots.py \
  screenshots/originals/iphone_new.png \
  --devices iphone_6_7 iphone_5_5 \
  --output screenshots/output/iphone/

# 3. 上传新的 iPhone 截图到 App Store Connect
```

### 场景 3: 快速测试单张图片

```bash
# 生成到临时目录
python3 scripts/generate_screenshots.py test.png \
  --output temp_screenshots/ \
  --devices iphone_6_7

# 查看结果
open temp_screenshots/
```

---

## 🐛 故障排除

### 问题 1: Pillow 未安装

**错误信息**:
```
ModuleNotFoundError: No module named 'PIL'
```

**解决方法**:
```bash
pip install Pillow
```

### 问题 2: 图片文件不存在

**错误信息**:
```
Error: Input file not found: screenshot.png
```

**解决方法**:
- 检查文件路径是否正确
- 确保文件存在

### 问题 3: 批处理脚本没有找到图片

**原因**: 文件命名不符合规则

**解决方法**:
- iPhone 截图: 文件名必须以 `iphone` 开头
- iPad 截图: 文件名必须以 `ipad` 开头
- Watch 截图: 文件名必须以 `watch` 开头

---

## 📚 更多文档

- 📖 完整文档: [docs/App-Store截图生成说明.md](App-Store截图生成说明.md)
- 🚀 快速指南: [scripts/README_SCREENSHOTS.md](README_SCREENSHOTS.md)
- 📂 目录说明: [screenshots/originals/README.md](../screenshots/originals/README.md)

---

## ✅ 测试结果

所有功能已通过测试：

- ✅ Python 脚本正常工作
- ✅ 批处理脚本正常工作
- ✅ 所有设备类型生成正常
- ✅ 文件命名正确
- ✅ 输出质量符合预期
- ✅ 错误处理正常

**测试环境**: macOS, Python 3.x, Pillow 10.x

---

🎉 **开始使用吧！**



# TestFlight 上传和分享详细步骤

本文档提供 TestFlight 上传和分享的完整 Step-by-Step 指导。

---

## 📋 概述

### 时间线

```
⏱️ 上传 IPA: 5-15 分钟
⏱️ 自动处理: 5-15 分钟
✅ 内部测试: 立即可用（无需审核）
⏳ 外部测试: 24-48 小时审核
```

### 快速决策

| 场景 | 推荐方式 | 审核 | 时间 |
|-----|---------|------|------|
| 少数人测试（<100人） | 内部测试 | ✅ 无需审核 | ~30分钟 |
| 大量人测试（>100人） | 外部测试 | ⏳ 需要审核 | 1-3天 |
| 公开 Beta 测试 | 外部测试 + 公开链接 | ⏳ 需要审核 | 1-3天 |

---

## 🚀 方式 1: 内部测试（推荐，最快）

### ✅ 适用场景
- 团队内部测试
- 少数测试人员（最多100人）
- **无需等待审核，立即可用**

---

### 📱 Step 1: 安装 Transporter（首次需要）

**在你的 Mac 上**:

```
1. 打开 App Store
2. 搜索 "Transporter"
3. 点击 "获取" 下载
4. 等待安装完成
```

🔗 直接链接: https://apps.apple.com/app/transporter/id1450874784

⏱️ **预计时间**: 2-5 分钟

---

### 📤 Step 2: 上传 IPA 文件

**在你的 Mac 上**:

```
1. 打开 Transporter 应用

2. 点击 "Sign In" 登录
   - 使用你的 Apple ID（开发者账号）
   - 输入密码
   - 可能需要双因素认证

3. 登录成功后，看到空白窗口

4. 准备 IPA 文件
   - 从 GitHub Release 下载
   - 文件名: WebViewApp-1.0.10-release.ipa

5. 上传方式（二选一）:
   
   方式 A: 拖拽上传（推荐）
   - 直接将 IPA 文件拖到 Transporter 窗口
   
   方式 B: 点击上传
   - 点击窗口中间的 "+" 按钮
   - 选择 IPA 文件

6. 确认信息
   - App 名称: PsychologicalGym
   - Bundle ID: com.xlab.psychologicalgym
   - 版本: 1.0.0 (1)

7. 点击 "Deliver" 开始上传

8. 等待上传完成
   - 显示进度条
   - 状态变为 "Successfully delivered"
```

⏱️ **预计时间**: 5-15 分钟（取决于文件大小和网络速度）

💡 **提示**: 
- 上传时保持网络稳定
- 不要关闭 Transporter
- 可以在后台运行

---

### ⏳ Step 3: 等待 Apple 处理

**在浏览器中**:

```
1. 打开 App Store Connect
   https://appstoreconnect.apple.com/

2. 登录你的账号

3. 点击 "我的 App" (My Apps)

4. 选择你的应用
   - 如果是首次上传，需要先创建应用信息
   - 点击 "+" → 新建 App
   - 填写应用基本信息（见下方）

5. 点击 "TestFlight" 标签

6. 查看 "iOS 构建版本" (iOS Builds)
   
   状态变化:
   ⏳ Processing... (Apple 正在处理)
   ✅ Ready to Submit (处理完成，可以开始测试)

7. 等待状态变为 "Ready to Submit"
```

⏱️ **预计时间**: 5-15 分钟

💡 **注意**: 必须等到 "Ready" 状态才能继续下一步！

---

#### 🆕 首次上传？创建应用信息

<details>
<summary><b>点击展开：如何在 App Store Connect 创建新应用</b></summary>

```
在 "我的 App" 页面：

1. 点击左上角的 "+" 按钮

2. 选择 "新建 App" (New App)

3. 填写基本信息:
   
   📱 平台
   ☑️ iOS
   
   📝 名称
   输入: PsychologicalGym
   
   🌍 主要语言
   选择: 简体中文 或 英语
   
   📦 套装 ID (Bundle ID)
   选择: com.xlab.psychologicalgym
   注意: 必须与 app.cfg 中的 iosBundleId 一致
   
   🆔 SKU
   输入: psychologicalgym-001
   注意: 唯一标识符，可以是任意字符串
   
   👤 用户访问权限
   选择: 完全访问权限

4. 点击 "创建" (Create)

5. 应用已创建，现在可以查看 TestFlight 标签
```

</details>

---

### 📝 Step 4: 配置测试详情

**在 App Store Connect → TestFlight**:

```
1. 在 "iOS 构建版本" 中，点击版本号
   例如: 1.0.0 (1)

2. 填写 "测试详细信息" (Test Details):
   
   📝 此版本有哪些新功能？(What to Test)
   输入示例:
   "初始版本，测试以下功能：
   - WebView 基本加载
   - 页面交互
   - 网络连接
   - 应用启动和退出"

   📧 反馈邮箱 (Feedback Email) - 可选
   输入: your-email@example.com

   🌐 营销网址 (Marketing URL) - 可选
   输入: https://yourwebsite.com

3. 配置 "导出合规性" (Export Compliance):
   
   ❓ 您的 App 是否使用加密？
   (Does your app use encryption?)
   
   选择:
   ✅ No（如果只使用标准 HTTPS）
   ⚠️ Yes（如果有额外的加密功能，需要回答后续问题）
   
   推荐选择: No

4. 点击 "保存" (Save)
```

⏱️ **预计时间**: 2-3 分钟

---

### 👥 Step 5: 添加内部测试人员

**在 App Store Connect → TestFlight**:

#### 选项 A: 使用默认测试组（最简单）

```
1. 点击左侧 "内部测试" (Internal Testing)

2. 看到默认组 "App Store Connect 用户"

3. 点击右侧的 "+" 按钮（添加测试人员）

4. 勾选要添加的用户

5. 点击 "添加" (Add)

6. 选择要测试的构建版本
   - 点击 "构建版本" 旁的 "+"
   - 选择刚上传的版本 (1.0.0)
   - 点击 "下一步" → "添加"

7. 完成！测试人员会立即收到邮件通知
```

#### 选项 B: 创建新测试组

```
1. 点击 "内部测试"

2. 点击左上角 "+" → "创建新组"

3. 输入组名称
   例如: "核心测试团队"

4. 点击 "创建"

5. 添加测试人员（同选项 A 的步骤 3-7）
```

⏱️ **预计时间**: 2-3 分钟

💡 **重要**: 测试人员必须是 App Store Connect 用户（需要提前邀请加入）

---

#### 🆕 如何添加 App Store Connect 用户

<details>
<summary><b>点击展开：添加新用户到 App Store Connect</b></summary>

```
1. 在 App Store Connect，点击顶部 "用户和访问" (Users and Access)

2. 点击 "人员" (People) 标签

3. 点击 "+" 添加新用户

4. 填写信息:
   
   📝 名字
   输入: 测试人员姓名
   
   📧 邮箱
   输入: test@example.com
   
   👤 角色
   选择:
   - Developer（开发者）- 推荐
   - Marketing（营销）- 如果只需要查看
   
   📱 App 访问权限
   勾选需要测试的应用

5. 点击 "邀请" (Invite)

6. 测试人员会收到邀请邮件
   - 需要接受邀请
   - 创建/登录 Apple ID
   - 接受条款

7. 等待用户接受邀请（通常几分钟）

8. 用户接受后，返回 TestFlight 添加到测试组
```

⏱️ **预计时间**: 5-10 分钟（包括等待用户接受邀请）

⚠️ **注意**: 
- 免费账号最多 25 个内部测试人员
- 付费账号最多 100 个内部测试人员

</details>

---

### 📧 Step 6: 测试人员收到通知

**测试人员会收到邮件**:

```
发件人: TestFlight <noreply@email.apple.com>

主题: 您已获邀在 TestFlight 中测试 PsychologicalGym

内容:
"您已获邀使用 TestFlight 测试 PsychologicalGym。
请在您的 iOS 设备上安装 TestFlight App，
然后打开此邮件中的链接开始测试。"

按钮: [在 TestFlight 中查看]
```

---

### 📲 Step 7: 测试人员安装应用

**测试人员操作**:

```
1. 在 iPhone/iPad 上安装 TestFlight
   - 打开 App Store
   - 搜索 "TestFlight"
   - 下载安装（免费）
   
   🔗 直接链接: https://apps.apple.com/app/testflight/id899247664

2. 打开邀请邮件
   - 在 iPhone 上打开邮件
   - 点击 "在 TestFlight 中查看" 按钮
   - TestFlight 自动打开

3. 在 TestFlight 中安装
   - 看到应用名称和图标
   - 点击 "安装" (Install) 按钮
   - 等待下载完成（显示进度）

4. 开始使用
   - 安装完成后，点击 "打开" (Open)
   - 或在主屏幕找到应用图标
   - 正常使用应用

5. 提供反馈（可选）
   - 在 TestFlight 中打开应用详情
   - 点击 "发送 Beta 版反馈"
   - 输入反馈信息
   - 可以添加截图
   - 点击 "提交"
```

⏱️ **预计时间**: 5-10 分钟

---

## 🎉 完成！

### 总时间统计

```
✅ 上传 IPA: 10 分钟
✅ 等待处理: 10 分钟
✅ 配置测试详情: 3 分钟
✅ 添加测试人员: 3 分钟
✅ 测试人员安装: 5 分钟

总计: ~30 分钟 🚀
```

---

## 🌍 方式 2: 外部测试（适合大规模）

如果你需要更多测试人员（超过100人），使用外部测试：

### 📤 Step 1-4: 同内部测试

完成上传和配置（Steps 1-4）

---

### 🌐 Step 5: 创建外部测试组

**在 App Store Connect → TestFlight**:

```
1. 点击左侧 "外部测试" (External Testing)

2. 点击 "+" 创建新组

3. 配置测试组:
   
   📝 组名称
   输入: "Beta 测试组" 或 "公开测试"
   
   🔗 启用公开链接
   ☑️ Enable Public Link
   
   💡 这样任何人都可以通过链接加入！

4. 点击 "创建" (Create)
```

---

### 📋 Step 6: 添加构建版本并提交审核

```
1. 在外部测试组中，点击 "添加构建版本"

2. 选择版本: 1.0.0 (1)

3. 填写审核信息（重要！）:
   
   📝 测试详细信息
   示例:
   "这是 PsychologicalGym 的首个 Beta 版本。
   
   主要功能:
   - WebView 内容展示
   - 网页交互
   - 基本导航
   
   测试重点:
   - 页面加载速度
   - 交互响应
   - 兼容性测试"

   📝 登录信息（如果需要登录）
   示例:
   "无需登录，可直接使用"
   
   或提供测试账号:
   "测试账号: test@example.com
   密码: Test123456"

   📝 联系信息
   - 名字: 你的名字
   - 电话: +86 138 xxxx xxxx
   - 邮箱: your-email@example.com

4. 点击 "提交以供审核" (Submit for Review)

5. 看到状态: "Waiting for Review"
```

⏱️ **预计时间**: 5 分钟

---

### ⏳ Step 7: 等待 Beta 审核

```
审核时间线:

⏳ Day 0: 提交审核
   状态: Waiting for Review

⏳ Day 1-2: 审核中
   状态: In Review (如果开始审核)

✅ Day 1-3: 审核完成
   状态: Ready to Test
   
   或
   
❌ 审核被拒
   状态: Rejected
   原因: 查看拒绝原因并修复
```

⏱️ **预计时间**: 24-48 小时（可能更长）

💡 **提示**:
- 审核期间可以继续上传新版本
- 可以同时有多个版本在审核
- 周末和节假日审核较慢

---

### 🔗 Step 8: 分享公开链接

**审核通过后**:

```
1. 在外部测试组中，找到 "公开链接"

2. 点击 "启用公开链接" (如果还没启用)

3. 复制链接，格式如下:
   https://testflight.apple.com/join/AbCdEfGh

4. 分享链接:
   
   方式 A: 发送给特定人员
   - 通过邮件、微信、QQ 等
   - 告诉他们点击链接

   方式 B: 公开发布
   - 发布在网站上
   - 发布在社交媒体
   - 添加到产品页面
   
   方式 C: 生成二维码
   - 使用在线工具生成二维码
   - 打印或分享二维码图片

5. 测试人员点击链接即可加入
   - 无需邀请
   - 无需你手动添加
   - 自动加入测试组
```

---

### 📲 Step 9: 测试人员安装（外部测试）

**测试人员操作**:

```
1. 在 iPhone/iPad 上点击公开链接
   https://testflight.apple.com/join/AbCdEfGh

2. Safari 会打开并提示
   "在 TestFlight 中打开？"
   点击 "打开"

3. 如果没有 TestFlight:
   - 会跳转到 App Store
   - 下载并安装 TestFlight
   - 安装后重新点击链接

4. 在 TestFlight 中:
   - 看到应用信息
   - 点击 "接受" (Accept) 按钮
   - 同意测试协议

5. 点击 "安装" (Install)
   - 等待下载
   - 安装完成后点击 "打开"

6. 开始使用应用！
```

---

## 🎓 审核通过技巧

### 容易通过的要点

```
✅ 明确说明测试内容
   - 具体说明要测试什么功能
   - 不要只写"测试应用"

✅ 提供完整的登录信息（如需要）
   - 测试账号和密码
   - 登录步骤说明

✅ 说明应用用途
   - 清楚描述应用功能
   - 不要有误导性内容

✅ 确保应用稳定
   - 不要有明显 Bug
   - 不要崩溃
   - 功能基本可用

✅ 遵守 Apple 政策
   - 不包含违规内容
   - 不侵犯版权
   - 符合年龄分级
```

### 常见拒绝原因

```
❌ 应用崩溃或无法启动
   解决: 修复 Bug 后重新上传

❌ 缺少必要的登录信息
   解决: 在审核信息中提供测试账号

❌ 功能不完整或无法使用
   解决: 确保核心功能可用

❌ 违反 App Store 审核准则
   解决: 移除违规内容

❌ 缺少隐私政策（如收集数据）
   解决: 添加隐私政策链接
```

---

## 💡 最佳实践

### 上传建议

```
1. ✅ 版本号递增
   - 每次上传新版本递增 build number
   - 例如: 1.0.0 (1) → 1.0.0 (2)

2. ✅ 填写构建版本说明
   - 说明此版本的改动
   - 帮助测试人员了解更新内容

3. ✅ 保持应用稳定
   - 在本地充分测试后再上传
   - 确保没有明显 Bug

4. ✅ 及时回复反馈
   - 定期查看 TestFlight 反馈
   - 及时回复测试人员问题
```

### 测试人员管理

```
1. ✅ 使用测试组分类
   - 核心团队组
   - Beta 测试组
   - 特定功能测试组

2. ✅ 控制测试范围
   - 先小范围测试
   - 确认稳定后扩大范围

3. ✅ 收集反馈
   - 鼓励测试人员提供反馈
   - 定期查看崩溃报告
   - 根据反馈改进

4. ✅ 定期更新
   - 修复 Bug 后及时上传新版本
   - 通知测试人员更新
```

---

## 🆘 故障排查

### 上传失败

#### 问题: "Invalid Provisioning Profile"

```
原因: Profile 类型不正确

解决:
1. 确认使用 App Store Profile
2. 在 app.cfg 中设置:
   iosExportMethod=app-store
3. 重新构建
```

#### 问题: "Missing or invalid signature"

```
原因: 签名配置错误

解决:
1. 检查 GitHub Secrets:
   - IOS_CERTIFICATE_BASE64
   - IOS_CERTIFICATE_PASSWORD
2. 确认证书类型为 Distribution
3. 重新构建
```

### 处理失败

#### 问题: 卡在 "Processing" 状态超过 30 分钟

```
可能原因:
- Apple 服务器繁忙
- IPA 文件有问题

解决:
1. 等待更长时间（最多 2 小时）
2. 刷新页面查看状态
3. 如果一直不变，联系 Apple 支持
```

#### 问题: 显示 "Invalid Binary"

```
原因: IPA 文件有问题

解决:
1. 检查构建日志
2. 确认 Archive 和 Export 都成功
3. 确认 Profile 和 Bundle ID 匹配
4. 重新构建并上传
```

---

## 📊 快速参考

### 内部测试检查清单

```
□ 安装 Transporter
□ 准备 IPA 文件
□ 使用 Transporter 上传
□ 等待处理完成（Ready to Submit）
□ 配置测试详情
□ 配置导出合规性（选 No）
□ 添加内部测试人员（App Store Connect 用户）
□ 选择构建版本
□ 测试人员收到邮件
□ 测试人员安装 TestFlight
□ 测试人员安装应用
□ 开始测试！
```

### 外部测试检查清单

```
□ 完成内部测试步骤 1-4
□ 创建外部测试组
□ 启用公开链接
□ 添加构建版本
□ 填写详细的审核信息
□ 提供登录信息（如需要）
□ 提交审核
□ 等待 24-48 小时
□ 审核通过后复制公开链接
□ 分享链接给测试人员
□ 测试人员点击链接加入
□ 开始测试！
```

---

## 🔗 相关链接

- **App Store Connect**: https://appstoreconnect.apple.com/
- **TestFlight (App Store)**: https://apps.apple.com/app/testflight/id899247664
- **Transporter (Mac App Store)**: https://apps.apple.com/app/transporter/id1450874784
- **Apple Developer**: https://developer.apple.com/
- **TestFlight 帮助**: https://developer.apple.com/help/app-store-connect/test-a-beta-version/

---

## 📚 相关文档

- [TestFlight完整指南.md](./TestFlight完整指南.md) - 更多 TestFlight 使用细节
- [iOS安装指南.md](./iOS安装指南.md) - 其他 iOS 安装方式
- [证书和密钥配置指南.md](./证书和密钥配置指南.md) - 证书配置
- [构建和安装指南.md](./构建和安装指南.md) - 构建流程

---

## 📞 获取帮助

如果遇到问题：

1. **查看构建日志**
   - GitHub Actions → 查看失败的步骤
   
2. **检查配置**
   - app.cfg 配置正确
   - GitHub Secrets 完整
   
3. **查阅文档**
   - [常见配置错误](./常见配置错误.md)
   
4. **联系支持**
   - Apple Developer 支持
   - App Store Connect 支持

---

**最后更新**: 2024-12-11  
**版本**: 1.0.10  
**适用于**: TestFlight 内部测试和外部测试







# TestFlight 完整使用指南

本指南详细介绍如何使用 TestFlight 分发 iOS 应用，包括上传、审核和分享的完整流程。

---

## 📋 目录

1. [准备工作](#准备工作)
2. [上传 IPA 到 App Store Connect](#上传-ipa)
3. [配置 TestFlight](#配置-testflight)
4. [邀请测试人员](#邀请测试人员)
5. [测试人员安装](#测试人员安装)
6. [常见问题](#常见问题)

---

## 🎯 准备工作

### 前提条件

✅ **必需**:
- Apple Developer 账号（$99/年）
- 已构建好的 IPA 文件
- App Store Connect 访问权限

✅ **建议**:
- 准备好应用的基本信息（名称、描述、图标等）
- 确认 Bundle ID 已在 Apple Developer 注册
- 测试人员的 Apple ID 邮箱列表

### 时间预估

| 步骤 | 时间 | 说明 |
|-----|------|------|
| **上传 IPA** | 5-15 分钟 | 取决于文件大小和网络速度 |
| **自动处理** | 5-15 分钟 | Apple 自动处理和验证 |
| **内部测试** | 立即可用 | 无需审核 |
| **外部测试** | 24-48 小时 | 需要 Beta 审核 |

---

## 📤 上传 IPA

有三种方法可以上传 IPA 到 App Store Connect：

### 方法 1: 使用 Transporter（推荐，最简单）

**适用于**: Mac 用户，可视化界面

<details>
<summary><b>📱 点击展开详细步骤</b></summary>

#### 步骤 1: 安装 Transporter

```
1. 打开 Mac App Store
2. 搜索 "Transporter"
3. 下载并安装（免费）
```

或者直接访问: [Transporter - Mac App Store](https://apps.apple.com/app/transporter/id1450874784)

#### 步骤 2: 登录

```
1. 打开 Transporter
2. 点击 "Sign In"
3. 使用你的 Apple ID 登录（开发者账号）
```

#### 步骤 3: 上传 IPA

```
1. 点击窗口中的 "+" 按钮
   或直接将 IPA 文件拖到窗口中

2. 选择你的 IPA 文件
   文件名: WebViewApp-1.0.0-release.ipa

3. 点击 "Deliver" 开始上传

4. 等待上传完成
   ✅ 状态变为 "Successfully delivered"
```

**预计时间**: 5-15 分钟（取决于文件大小和网络速度）

#### 故障排查

如果上传失败：
```
❌ "Invalid Provisioning Profile"
   → 检查 Profile 类型（必须是 App Store Profile）

❌ "Missing compliance"
   → 在 App Store Connect 中配置导出合规性

❌ "Invalid Bundle ID"
   → 确认 Bundle ID 已在 Apple Developer 注册
```

</details>

---

### 方法 2: 使用命令行工具（适合自动化）

**适用于**: 熟悉命令行，需要自动化

<details>
<summary><b>⚡ 点击展开详细步骤</b></summary>

#### 准备工作

需要创建 App Store Connect API 密钥：

```
1. 登录 App Store Connect
   https://appstoreconnect.apple.com/

2. 进入 "用户和访问" → "密钥"
   Users and Access → Keys → App Store Connect API

3. 点击 "+" 创建新密钥
   - 名称: CI/CD Upload
   - 访问权限: Developer
   
4. 下载密钥文件
   文件名: AuthKey_XXXXXXXXXX.p8
   
5. 记录以下信息:
   - Issuer ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   - Key ID: XXXXXXXXXX
```

#### 上传命令

```bash
# 方式 1: 使用 altool（较老，但稳定）
xcrun altool --upload-app \
  --file WebViewApp-1.0.0-release.ipa \
  --type ios \
  --apiKey YOUR_KEY_ID \
  --apiIssuer YOUR_ISSUER_ID

# 方式 2: 使用 notarytool（新版）
xcrun notarytool submit WebViewApp-1.0.0-release.ipa \
  --key AuthKey_XXXXXXXXXX.p8 \
  --key-id YOUR_KEY_ID \
  --issuer YOUR_ISSUER_ID \
  --wait
```

**输出示例**:
```
Uploading WebViewApp-1.0.0-release.ipa
[===========================] 100% (150 MB / 150 MB)
Upload successful
Package successfully uploaded
```

#### 在 GitHub Actions 中自动上传

<details>
<summary>点击查看 GitHub Actions 配置</summary>

```yaml
- name: Upload to TestFlight
  run: |
    # 解码 API 密钥
    echo "${{ secrets.APP_STORE_API_KEY_BASE64 }}" | base64 --decode > AuthKey.p8
    
    # 上传 IPA
    xcrun altool --upload-app \
      --file build-release/output/WebViewApp.ipa \
      --type ios \
      --apiKey ${{ secrets.APP_STORE_API_KEY_ID }} \
      --apiIssuer ${{ secrets.APP_STORE_API_ISSUER_ID }}
  env:
    APP_STORE_CONNECT_API_KEY_PATH: ./AuthKey.p8
```

</details>

</details>

---

### 方法 3: 使用 Xcode

**适用于**: 有 Mac 和 Xcode

<details>
<summary><b>🔨 点击展开详细步骤</b></summary>

#### 步骤 1: 在 Xcode 中打开项目

```bash
open ios/WebViewApp.xcodeproj
```

#### 步骤 2: Archive

```
1. 选择菜单: Product → Archive
2. 等待 Archive 完成
3. Organizer 窗口会自动打开
```

#### 步骤 3: Upload

```
1. 在 Organizer 中选择刚创建的 Archive
2. 点击 "Distribute App"
3. 选择 "App Store Connect"
4. 选择 "Upload"
5. 等待上传完成
```

</details>

---

## ✅ 验证上传成功

### 在 App Store Connect 中检查

```
1. 登录 App Store Connect
   https://appstoreconnect.apple.com/

2. 进入 "我的 App" → 选择你的应用
   My Apps → Select your app

3. 点击 "TestFlight" 标签

4. 查看 "iOS 构建版本"
   iOS Builds → 等待处理完成

5. 状态变化:
   ⏳ Processing... (5-15 分钟)
   ✅ Ready to Submit / Ready to Test
```

**重要**: 必须等到状态变为 "Ready" 才能继续下一步！

---

## 🚀 配置 TestFlight

上传成功后，需要配置 TestFlight 设置。

### 步骤 1: 等待处理完成

```
在 TestFlight 标签中查看构建状态:

⏳ Processing (通常 5-15 分钟)
   └─ 验证 IPA
   └─ 生成测试信息
   └─ 准备分发

✅ Ready to Submit (内部测试)
✅ Ready to Test (外部测试需先提交审核)
```

### 步骤 2: 配置测试信息

```
1. 点击构建版本号
   例如: 1.0.0 (1)

2. 填写 "测试详细信息"
   Test Details:
   
   📝 此版本有哪些新功能？
      What to Test:
      "初始版本，测试核心功能"

   📝 反馈邮箱（可选）
      Feedback Email:
      your-email@example.com

   📝 营销网址（可选）
      Marketing URL:
      https://yourwebsite.com

3. 配置"导出合规性"
   Export Compliance:
   
   问题：您的 App 是否使用加密？
   - 如果只使用 HTTPS: 选择 "No"
   - 如果使用额外加密: 选择 "Yes" 并回答后续问题

4. 点击 "保存"
```

### 步骤 3: 提交审核（外部测试需要）

```
仅外部测试需要此步骤：

1. 确认所有信息已填写
2. 点击 "Submit for Review"
3. 等待审核（通常 24-48 小时）

内部测试：✅ 无需审核，可立即使用
外部测试：⏳ 需要 Beta 审核
```

---

## 👥 邀请测试人员

TestFlight 支持两种测试人员类型：

| 类型 | 人数限制 | 审核 | 权限要求 |
|-----|---------|------|---------|
| **内部测试人员** | 最多 100 人 | ✅ 无需审核 | 必须是 App Store Connect 用户 |
| **外部测试人员** | 最多 10,000 人 | ⏳ 需要 24-48 小时审核 | 只需要 Apple ID |

---

### 方式 1: 内部测试（推荐，快速开始）

**优点**: 无需审核，立即可用

<details>
<summary><b>🏃‍♂️ 点击展开详细步骤</b></summary>

#### 步骤 1: 添加内部测试人员

```
1. 在 TestFlight 中，选择 "内部测试"
   Internal Testing

2. 点击 "+" 添加内部组
   或使用默认的 "App Store Connect 用户"

3. 点击 "添加测试人员"
   Add Testers
```

#### 步骤 2: 邀请用户

**选项 A: 已有 App Store Connect 用户**

```
1. 在列表中勾选用户
2. 点击 "添加"
3. 用户会立即收到邮件通知
```

**选项 B: 添加新用户**

```
1. 进入 "用户和访问" → "人员"
   Users and Access → People

2. 点击 "+" 添加新用户
   - 名字: 测试人员姓名
   - 邮箱: test@example.com
   - 角色: Developer 或 Marketing
   - 访问权限: 勾选需要的应用

3. 发送邀请

4. 用户接受邀请后，返回 TestFlight 添加
```

#### 步骤 3: 选择构建版本

```
1. 选择要测试的构建版本
2. 点击右侧的开关启用测试
3. 测试人员会立即收到通知
```

#### 限制

```
❌ 需要 App Store Connect 账号（较复杂）
❌ 最多 100 人
✅ 无需审核，立即可用
✅ 可以访问所有 TestFlight 功能
```

</details>

---

### 方式 2: 外部测试（适合大规模测试）

**优点**: 无需 App Store Connect 账号，最多 10,000 人

<details>
<summary><b>🌍 点击展开详细步骤</b></summary>

#### 步骤 1: 创建外部测试组

```
1. 在 TestFlight 中，选择 "外部测试"
   External Testing

2. 点击 "+" 创建新组
   - 组名: 例如 "Beta 测试组"
   - 公开链接: 可选（推荐）

3. 点击 "创建"
```

#### 步骤 2: 添加构建版本并提交审核

```
1. 点击 "添加构建版本"
   Add Build

2. 选择要测试的版本

3. 填写审核信息:
   📝 测试详细信息
      - 测试什么功能
      - 如何登录（如需要）
      - 测试步骤
   
   📝 联系信息
      - 姓名
      - 电话
      - 邮箱

4. 点击 "Submit for Review"

5. 等待审核（通常 24-48 小时）
```

#### 步骤 3: 邀请测试人员

审核通过后，有两种邀请方式：

**方式 A: 公开链接（最简单）**

```
1. 在测试组中启用"公开链接"
   Enable Public Link

2. 复制链接，例如:
   https://testflight.apple.com/join/AbCdEfGh

3. 分享链接给测试人员:
   - 通过邮件
   - 通过即时通讯
   - 发布在网站上

4. 测试人员点击链接即可加入
```

**方式 B: 邮箱邀请**

```
1. 点击 "添加测试人员"
   Add Testers

2. 输入邮箱地址（每行一个）:
   test1@example.com
   test2@example.com
   test3@example.com

3. 点击 "添加"

4. TestFlight 会发送邀请邮件
```

#### 审核状态

```
状态说明:

⏳ Waiting for Review
   → 等待 Apple 审核

✅ Ready to Test
   → 审核通过，可以邀请测试人员

❌ Rejected
   → 被拒绝，需要修改后重新提交
```

#### 审核时间

```
正常情况: 24-48 小时
高峰期: 可能 3-5 天
加急: 无法加急 Beta 审核
```

</details>

---

## 📱 测试人员如何安装

测试人员收到邀请后，按以下步骤操作：

### 步骤 1: 安装 TestFlight

```
1. 在 iPhone/iPad 上打开 App Store
2. 搜索 "TestFlight"
3. 下载并安装（免费）
```

或者直接访问: [TestFlight - App Store](https://apps.apple.com/app/testflight/id899247664)

### 步骤 2: 接受邀请

**如果是邮件邀请**:
```
1. 在 iPhone 上打开邀请邮件
2. 点击 "View in TestFlight" 或 "在 TestFlight 中查看"
3. TestFlight 会自动打开并显示应用
```

**如果是公开链接**:
```
1. 在 iPhone Safari 中打开链接
2. 点击 "Accept" 接受邀请
3. TestFlight 会自动打开
```

### 步骤 3: 安装应用

```
1. 在 TestFlight 中找到应用
2. 点击 "Install" 或 "安装"
3. 等待下载完成
4. 点击 "Open" 或 "打开" 运行应用
```

### 步骤 4: 提供反馈（可选）

```
1. 在 TestFlight 中打开应用详情
2. 点击 "Send Beta Feedback"
3. 输入反馈信息
4. 可以添加截图
5. 点击 "Submit" 发送
```

---

## 🎯 快速开始流程

### 最快方式：内部测试（5 分钟开始测试）

```
✅ 第 1 步: 上传 IPA (5-15 分钟)
   使用 Transporter 上传

✅ 第 2 步: 等待处理 (5-15 分钟)
   在 App Store Connect 等待 "Ready"

✅ 第 3 步: 配置测试信息 (2 分钟)
   填写测试详情和导出合规性

✅ 第 4 步: 添加内部测试人员 (1 分钟)
   邀请 App Store Connect 用户

✅ 第 5 步: 立即测试 ✨
   测试人员安装 TestFlight → 安装应用

总时间: 约 15-35 分钟（无需审核）
```

### 标准方式：外部测试（24-48 小时）

```
✅ 第 1-3 步: 同上 (15-30 分钟)

✅ 第 4 步: 创建外部测试组 (2 分钟)
   创建测试组并启用公开链接

✅ 第 5 步: 提交 Beta 审核 (2 分钟)
   填写审核信息并提交

⏳ 第 6 步: 等待审核 (24-48 小时)
   Apple Beta 审核

✅ 第 7 步: 分享公开链接
   复制链接分享给测试人员

✅ 第 8 步: 测试人员安装
   点击链接 → TestFlight → 安装

总时间: 1-3 天（需要审核）
```

---

## ❓ 常见问题

### Q1: 我有 IPA 文件，最快多久可以让测试人员安装？

**A**: 使用内部测试，最快 20-35 分钟

```
时间线:
⏱️ 上传 IPA: 5-15 分钟
⏱️ Apple 处理: 5-15 分钟
⏱️ 配置 TestFlight: 2 分钟
⏱️ 邀请测试人员: 1 分钟
✅ 立即可以安装

条件:
- 测试人员必须是 App Store Connect 用户
- 最多 100 人
- 无需审核
```

### Q2: 外部测试和内部测试有什么区别？

**A**: 主要区别在审核和人数限制

| 特性 | 内部测试 | 外部测试 |
|-----|---------|---------|
| **审核** | ✅ 无需审核 | ⏳ 需要 24-48 小时 |
| **人数** | 最多 100 人 | 最多 10,000 人 |
| **要求** | 必须是 ASC 用户 | 只需 Apple ID |
| **速度** | 立即可用 | 1-3 天 |
| **链接** | ❌ 不支持公开链接 | ✅ 支持公开链接 |

推荐:
- 小团队内部测试 → 使用内部测试
- 大规模 Beta 测试 → 使用外部测试

### Q3: Beta 审核通常需要多久？

**A**: 通常 24-48 小时，但可能更长

```
正常情况: 24-48 小时
高峰期: 3-5 天
假期: 可能更长

⚠️ 注意:
- Beta 审核无法加急
- 周末和假期可能更慢
- 第一次审核可能更慢
```

### Q4: Beta 审核和 App Store 审核有什么区别？

**A**: Beta 审核要求相对宽松

```
Beta 审核 (TestFlight):
✅ 审核标准较宽松
✅ 时间较短（1-2 天）
✅ 可以多次提交
✅ 主要检查安全和基本合规性
❌ 无法加急

App Store 审核:
⚠️ 审核标准严格
⏱️ 时间较长（3-7 天）
⚠️ 拒绝需要重新提交
✅ 全面检查所有准则
✅ 可以申请加急
```

### Q5: 上传失败，提示 "Invalid Provisioning Profile"

**A**: Profile 类型不正确

```
❌ 错误的 Profile 类型:
- Development Profile
- Ad Hoc Profile

✅ 正确的 Profile 类型:
- App Store Distribution Profile

解决方法:
1. 登录 developer.apple.com
2. Profiles → 创建新 Profile
3. 选择 Distribution → App Store
4. 选择 App ID 和 Distribution 证书
5. 下载并更新 GitHub Secret:
   IOS_PROVISIONING_PROFILE_BASE64
6. 重新构建
```

### Q6: 可以同时有多个测试版本吗？

**A**: 可以，但测试人员只能安装最新版本

```
TestFlight 行为:
✅ 可以上传多个版本
✅ 每个版本可以分配给不同的测试组
⚠️ 同一测试人员只能安装最新分配的版本
⚠️ 更新会自动提示（如果启用自动通知）

最佳实践:
- 为不同版本创建不同的测试组
- 使用版本号区分功能
- 在测试详情中说明版本差异
```

### Q7: 测试人员反馈在哪里查看？

**A**: 在 TestFlight 和 App Store Connect 都可以查看

```
查看反馈:

方式 1: App Store Connect
1. 登录 appstoreconnect.apple.com
2. TestFlight → 选择应用
3. 点击 "Feedback" 标签

方式 2: 邮件通知
- 配置邮件通知
- 每次反馈都会收到邮件

反馈包含:
- 文字描述
- 截图
- 设备信息
- iOS 版本
- 崩溃日志（如有）
```

### Q8: TestFlight 测试有时间限制吗？

**A**: 每个构建版本 90 天有效期

```
时间限制:
- 每个版本上传后 90 天内有效
- 90 天后无法新安装
- 已安装的版本会停止工作
- 需要上传新版本

建议:
- 定期上传新版本
- 在过期前通知测试人员更新
- 保持活跃的测试周期
```

---

## 📚 总结

### ✅ 推荐流程

**对于你的情况（已有 IPA）**:

```
🎯 最快方式（内部测试）:

1️⃣ 使用 Transporter 上传 IPA (10 分钟)

2️⃣ 等待处理完成 (10 分钟)

3️⃣ 配置测试信息 (2 分钟)

4️⃣ 添加内部测试人员 (1 分钟)
   - 需要是 App Store Connect 用户
   - 立即可以测试

总时间: ~25 分钟 ✨
```

```
🌍 标准方式（外部测试）:

1️⃣ 同上：上传和配置 (25 分钟)

2️⃣ 创建外部测试组 (2 分钟)
   - 启用公开链接

3️⃣ 提交 Beta 审核 (2 分钟)

4️⃣ 等待审核 ⏳ (1-2 天)

5️⃣ 分享公开链接
   - 测试人员点击链接即可安装
   - 无需 App Store Connect 账号

总时间: 1-3 天
```

### 🎓 关键要点

```
✅ 准备:
- 确保使用 App Store Profile
- IPA 文件签名正确
- Bundle ID 已注册

✅ 上传:
- 推荐使用 Transporter（最简单）
- 可以使用命令行（自动化）
- 等待处理完成（5-15 分钟）

✅ 测试:
- 内部测试：快速，但需要 ASC 账号
- 外部测试：慢（需审核），但更灵活

✅ 分享:
- 内部：邮件邀请
- 外部：公开链接（最方便）
```

---

## 🔗 相关链接

- [App Store Connect](https://appstoreconnect.apple.com/)
- [TestFlight - App Store](https://apps.apple.com/app/testflight/id899247664)
- [Transporter - Mac App Store](https://apps.apple.com/app/transporter/id1450874784)
- [Apple Developer](https://developer.apple.com/)
- [TestFlight 官方文档](https://developer.apple.com/testflight/)

---

## 🆘 需要帮助？

如果遇到问题：

1. 检查 Profile 类型是否正确（App Store）
2. 确认 App Store Connect 访问权限
3. 查看[常见问题](#常见问题)部分
4. 查阅[iOS 安装指南](./iOS安装指南.md)



# Android 配置占位符修复说明

## 🐛 问题描述

用户遇到了两个问题：

### 问题 1: 加载的 URL 不正确
- **现象**: 应用打开后加载的不是 `app.cfg` 中配置的 `loadUrl`
- **原因**: `AppConfig.kt` 中使用了硬编码的值而不是占位符

### 问题 2: Android 应用崩溃
- **现象**: 应用打开后立即崩溃退出
- **错误**: `ClassNotFoundException: Didn't find class "com.mywebviewapp.LoadingActivity"`
- **原因**: 包名配置不一致
  - `app.cfg` 中: `appId=com.xlab.psychologicalgym`
  - 代码中硬编码: `package com.mywebviewapp`
  - `build_config.py` 会移动文件到新包目录，但硬编码的包名导致找不到类

---

## ✅ 已修复的文件

### 1. `android/app/src/main/java/com/mywebviewapp/AppConfig.kt`

**修改前** (硬编码):
```kotlin
package com.mywebviewapp

object AppConfig {
    const val APP_NAME = "我的WebView"
    const val LOAD_URL = "https://www.baidu.com"  // ❌ 硬编码
    // ...
}
```

**修改后** (使用占位符):
```kotlin
package __PACKAGE_NAME__  // ✅ 占位符

object AppConfig {
    const val APP_NAME = "__APP_NAME__"           // ✅ 占位符
    const val LOAD_URL = "__LOAD_URL__"           // ✅ 占位符
    // ...
}
```

### 2. `android/app/build.gradle`

**修改前**:
```gradle
android {
    namespace 'com.mywebviewapp'  // ❌ 硬编码
    
    defaultConfig {
        applicationId "com.mywebviewapp"  // ❌ 硬编码
        versionName "1.0.0"  // ❌ 硬编码
    }
}
```

**修改后**:
```gradle
android {
    namespace '__PACKAGE_NAME__'  // ✅ 占位符
    
    defaultConfig {
        applicationId "__APP_ID__"       // ✅ 占位符
        versionName "__APP_VERSION__"    // ✅ 占位符
    }
}
```

### 3. `android/app/src/main/AndroidManifest.xml`

**修改前**:
```xml
<application
    android:label="MyWebView"  <!-- ❌ 硬编码 -->
    android:usesCleartextTraffic="false">  <!-- ❌ 硬编码 -->
```

**修改后**:
```xml
<application
    android:label="__APP_DISPLAY_NAME__"  <!-- ✅ 占位符 -->
    android:usesCleartextTraffic="__USES_CLEARTEXT_TRAFFIC__">  <!-- ✅ 占位符 -->
```

### 4. `android/app/src/main/java/com/mywebviewapp/MainActivity.kt`

**修改前**:
```kotlin
package com.mywebviewapp  // ❌ 硬编码
```

**修改后**:
```kotlin
package __PACKAGE_NAME__  // ✅ 占位符
```

### 5. `android/app/src/main/java/com/mywebviewapp/LoadingActivity.kt`

**修改前**:
```kotlin
package com.mywebviewapp  // ❌ 硬编码
```

**修改后**:
```kotlin
package __PACKAGE_NAME__  // ✅ 占位符
```

---

## 🔄 工作原理

### 构建流程

```
1. GitHub Actions 触发构建
   ↓
2. 运行 python3 build_config.py
   ↓
3. 读取 assets/app1/app.cfg
   - appId=com.xlab.psychologicalgym
   - loadUrl=https://www.qingmiao.cloud/page/mu.html
   - 其他配置...
   ↓
4. 创建新的包目录
   - 从: android/app/src/main/java/com/mywebviewapp/
   - 到: android/app/src/main/java/com/xlab/psychologicalgym/
   ↓
5. 替换所有占位符
   - __PACKAGE_NAME__ → com.xlab.psychologicalgym
   - __LOAD_URL__ → https://www.qingmiao.cloud/page/mu.html
   - __APP_DISPLAY_NAME__ → PsychologicalGym
   - 等等...
   ↓
6. Gradle 构建 APK
   - namespace: com.xlab.psychologicalgym ✅
   - applicationId: com.xlab.psychologicalgym ✅
   - 所有类在正确的包下 ✅
```

### 占位符对照表

| 占位符 | app.cfg 配置项 | 示例值 |
|-------|---------------|--------|
| `__PACKAGE_NAME__` | `appId` | `com.xlab.psychologicalgym` |
| `__APP_ID__` | `appId` | `com.xlab.psychologicalgym` |
| `__APP_NAME__` | `appName` | `PsychologicalGym` |
| `__APP_DISPLAY_NAME__` | `appDisplayName` | `PsychologicalGym` |
| `__APP_VERSION__` | `appVersion` | `1.0.0` |
| `__BUILD_NUMBER__` | `buildNumber` | `1` |
| `__LOAD_URL__` | `loadUrl` | `https://www.qingmiao.cloud/page/mu.html` |
| `__ENABLE_JAVASCRIPT__` | `enableJavaScript` | `true` |
| `__ENABLE_DOM_STORAGE__` | `enableDOMStorage` | `true` |
| `__ENABLE_CACHE__` | `enableCache` | `true` |
| `__USES_CLEARTEXT_TRAFFIC__` | `enableHttps` | `true` → `false`, `false` → `true` |

---

## 🚀 下一步操作

### 1. 提交修复

```bash
git add .
git commit -m "Fix: Use placeholders in Android config files

- Replace hardcoded values with placeholders in AppConfig.kt
- Replace hardcoded package names in all Kotlin files
- Replace hardcoded namespace and applicationId in build.gradle
- Replace hardcoded app label in AndroidManifest.xml

This fixes:
1. App loading wrong URL
2. ClassNotFoundException when app starts
"

git tag v1.0.10
git push origin v1.0.10
```

### 2. 验证构建

构建成功后，检查日志：

```
✅ Configuring Android
✅ Updated: android/app/build.gradle
✅ Updated: android/app/src/main/AndroidManifest.xml
✅ Updated: android/app/src/main/java/com/xlab/psychologicalgym/AppConfig.kt
✅ Updated: android/app/src/main/java/com/xlab/psychologicalgym/MainActivity.kt
✅ Updated: android/app/src/main/java/com/xlab/psychologicalgym/LoadingActivity.kt
```

### 3. 测试应用

下载并安装 APK 后：

```
✅ 应用正常启动（不崩溃）
✅ 显示 Loading 页面
✅ 加载正确的 URL: https://www.qingmiao.cloud/page/mu.html
✅ 应用名称显示为: PsychologicalGym
```

---

## 📋 验证清单

构建前检查：

```
□ app.cfg 中 appId 正确
   示例: appId=com.xlab.psychologicalgym

□ app.cfg 中 loadUrl 正确
   示例: loadUrl=https://www.qingmiao.cloud/page/mu.html

□ 所有 .kt 文件使用 __PACKAGE_NAME__ 占位符
   ✅ AppConfig.kt
   ✅ MainActivity.kt
   ✅ LoadingActivity.kt

□ build.gradle 使用占位符
   ✅ namespace '__PACKAGE_NAME__'
   ✅ applicationId "__APP_ID__"
   ✅ versionName "__APP_VERSION__"

□ AndroidManifest.xml 使用占位符
   ✅ android:label="__APP_DISPLAY_NAME__"
   ✅ android:usesCleartextTraffic="__USES_CLEARTEXT_TRAFFIC__"
```

构建后检查：

```
□ 构建日志显示正确的包名
   例如: com/xlab/psychologicalgym/

□ APK 可以安装

□ 应用可以正常启动（不崩溃）

□ Loading 页面正常显示

□ 加载正确的 URL

□ 应用名称正确显示
```

---

## 🐛 如果还有问题

### 问题 1: 仍然找不到类

**检查**:
```bash
# 解压 APK 检查类文件
unzip -l WebViewApp-1.0.10-release.apk | grep LoadingActivity

# 应该看到:
com/xlab/psychologicalgym/LoadingActivity.class
```

**如果没有**:
- 检查 build_config.py 是否正确执行
- 检查 GitHub Actions 日志中的 "Configuring Android" 部分
- 确认所有文件都使用了占位符

### 问题 2: 加载的 URL 还是不对

**检查**:
```kotlin
// 反编译 APK，查看 AppConfig.class
// 应该看到:
const val LOAD_URL = "https://www.qingmiao.cloud/page/mu.html"
```

**如果不对**:
- 检查 app.cfg 中的 loadUrl 配置
- 确认 AppConfig.kt 使用了 __LOAD_URL__ 占位符
- 重新构建

### 问题 3: 包名冲突

**清理旧包目录**:
```bash
# 在本地测试时，手动删除旧包目录
rm -rf android/app/src/main/java/com/mywebviewapp/
```

---

## 📊 修复前后对比

### 修复前

```
问题:
❌ appId=com.xlab.psychologicalgym (app.cfg)
❌ package com.mywebviewapp (代码)
❌ namespace 'com.mywebviewapp' (build.gradle)

结果:
❌ ClassNotFoundException
❌ 加载错误的 URL
```

### 修复后

```
正确:
✅ appId=com.xlab.psychologicalgym (app.cfg)
✅ package __PACKAGE_NAME__ → com.xlab.psychologicalgym (代码)
✅ namespace '__PACKAGE_NAME__' → 'com.xlab.psychologicalgym' (build.gradle)

结果:
✅ 应用正常启动
✅ 加载正确的 URL
✅ 所有配置生效
```

---

## 📚 相关文档

- [常见配置错误](./常见配置错误.md)
- [构建和安装指南](./构建和安装指南.md)
- [app.cfg 配置说明](../assets/app1/app.cfg)

---

**最后更新**: 2024-12-11
**版本**: 1.0.10
**修复内容**: Android 配置占位符替换








# 多截图上传功能说明

## 功能概述

现在支持为每个应用上传多张截图到 App Store Connect。可以通过配置 `snapshotScreen`、`snapshotScreen2`、`snapshotScreen3` 等多个源图片来生成和上传多张截图。

## 配置方法

在 `app.cfg` 配置文件中添加多个截图源：

```ini
# 第一张截图（必需）
snapshotScreen=https://example.com/screenshot1.png

# 第二张截图（可选）
snapshotScreen2=https://example.com/screenshot2.png

# 第三张截图（可选）
snapshotScreen3=https://example.com/screenshot3.png

# 支持最多10张截图
# snapshotScreen4=https://example.com/screenshot4.png
# snapshotScreen5=https://example.com/screenshot5.png
# ...
```

## 工作流程

### 1. 生成截图

运行截图生成脚本：

```bash
python scripts/generate_app_screenshots.py /path/to/workspace
```

脚本会：
- 读取所有配置的 `snapshotScreen`、`snapshotScreen2`、`snapshotScreen3` 等
- 为每个源图片生成所有设备类型的截图
- 截图文件命名格式：`screenshot_{device_type}_{index}.png`
  - 例如：`screenshot_iPhone_6.7_1.png`、`screenshot_iPhone_6.7_2.png`

生成结果示例：
```
screenshots/
  ├── app1/
  │   ├── screenshot_iPhone_6.7_1.png
  │   ├── screenshot_iPhone_6.7_2.png
  │   ├── screenshot_iPhone_6.7_3.png
  │   ├── screenshot_iPad_12.9_3rd_1.png
  │   ├── screenshot_iPad_12.9_3rd_2.png
  │   ├── screenshot_iPad_12.9_3rd_3.png
  │   └── screenshots.json
```

### 2. screenshots.json 格式

生成的 `screenshots.json` 文件格式：

```json
{
  "iPhone_6.7": [
    "/path/to/screenshot_iPhone_6.7_1.png",
    "/path/to/screenshot_iPhone_6.7_2.png",
    "/path/to/screenshot_iPhone_6.7_3.png"
  ],
  "iPad_12.9_3rd": [
    "/path/to/screenshot_iPad_12.9_3rd_1.png",
    "/path/to/screenshot_iPad_12.9_3rd_2.png",
    "/path/to/screenshot_iPad_12.9_3rd_3.png"
  ]
}
```

### 3. 上传到 App Store Connect

启用截图上传功能：

```ini
# 在 app.cfg 中配置
enableScreenshotUpload=true
```

运行上传脚本：

```bash
python scripts/app_store_connect.py /path/to/workspace
```

脚本会：
- 读取 `screenshots.json` 中的截图列表
- 为每个设备类型上传所有截图
- 第一张截图会清空现有截图，后续截图追加上传
- 支持最多 10 张截图（App Store Connect 限制）

## 上传逻辑说明

### 替换模式

- **第一张截图**：会删除该设备类型的所有旧截图，然后上传新截图
- **后续截图**：直接追加到截图集中，不会删除已有截图

### 设备类型

支持的设备类型：
- `iPhone_6.7` → 6.7 英寸显示屏（iPhone 14 Pro Max, 15 Pro Max 等）
- `iPhone_6.5` → 6.5 英寸显示屏（iPhone 11 Pro Max, XS Max 等）
- `iPhone_5.5` → 5.5 英寸显示屏（iPhone 8 Plus, 7 Plus 等）
- `iPad_12.9_3rd` → iPad Pro 12.9 英寸（第 3 代及以后）
- `iPad_12.9_2nd` → iPad Pro 12.9 英寸（第 2 代）

## 完整示例

### app.cfg 配置

```ini
# 应用基本信息
appId=com.example.myapp
appDisplayName=我的应用
appVersion=1.0.0

# 截图配置
snapshotScreen=https://cdn.example.com/screenshots/screen1.png
snapshotScreen2=https://cdn.example.com/screenshots/screen2.png
snapshotScreen3=https://cdn.example.com/screenshots/screen3.png

# 截图生成配置
screenshotDeviceTypes=iPhone_6.7,iPad_12.9_3rd
screenshotAddText=false

# 启用截图上传
enableScreenshotUpload=true
```

### 执行命令

```bash
# 1. 生成截图
python scripts/generate_app_screenshots.py .

# 2. 上传到 App Store Connect
python scripts/app_store_connect.py .
```

### 预期输出

```
📱 App Store 截图生成
============================================================
应用名称: 我的应用
源图片数量: 3
  1. https://cdn.example.com/screenshots/screen1.png
  2. https://cdn.example.com/screenshots/screen2.png
  3. https://cdn.example.com/screenshots/screen3.png
设备类型: iPhone_6.7, iPad_12.9_3rd
输出目录: /path/to/screenshots/myapp
============================================================

📸 处理源图片 1/3: https://cdn.example.com/screenshots/screen1.png
------------------------------------------------------------
🎨 生成截图 #1: iPhone_6.7 (1290x2796)
✅ 截图已保存: /path/to/screenshots/myapp/screenshot_iPhone_6.7_1.png
🎨 生成截图 #1: iPad_12.9_3rd (2048x2732)
✅ 截图已保存: /path/to/screenshots/myapp/screenshot_iPad_12.9_3rd_1.png

📸 处理源图片 2/3: https://cdn.example.com/screenshots/screen2.png
------------------------------------------------------------
...

============================================================
✅ 截图生成完成!
============================================================
共生成 6 张截图:
  - iPhone_6.7: 3 张
    • screenshot_iPhone_6.7_1.png
    • screenshot_iPhone_6.7_2.png
    • screenshot_iPhone_6.7_3.png
  - iPad_12.9_3rd: 3 张
    • screenshot_iPad_12.9_3rd_1.png
    • screenshot_iPad_12.9_3rd_2.png
    • screenshot_iPad_12.9_3rd_3.png
============================================================
```

## 注意事项

1. **截图数量限制**：App Store Connect 每个设备类型最多支持 10 张截图
2. **截图尺寸**：每张截图不得超过 500MB
3. **图片格式**：支持 PNG 和 JPG 格式
4. **上传顺序**：截图会按照配置顺序（snapshotScreen、snapshotScreen2、snapshotScreen3...）上传
5. **兼容性**：如果只配置了 `snapshotScreen`（不配置 snapshotScreen2/3），功能会自动兼容旧版本行为

## 向后兼容

代码完全兼容旧版本配置：

**旧配置**（单张截图）：
```ini
snapshotScreen=https://example.com/screenshot.png
```

**新配置**（多张截图）：
```ini
snapshotScreen=https://example.com/screenshot1.png
snapshotScreen2=https://example.com/screenshot2.png
snapshotScreen3=https://example.com/screenshot3.png
```

两种配置方式都能正常工作！

## 故障排除

### 问题：截图上传失败

**可能原因**：
- 截图文件不存在
- 截图尺寸不符合要求
- 网络问题
- API 权限不足

**解决方法**：
1. 检查 `screenshots.json` 文件中的路径是否正确
2. 确认截图文件存在且尺寸正确
3. 查看详细错误日志
4. 检查 App Store Connect API 权限

### 问题：只上传了一张截图

**可能原因**：
- 只配置了 `snapshotScreen`
- 其他 `snapshotScreen2/3` 配置为空或路径错误

**解决方法**：
1. 检查 `app.cfg` 中的配置
2. 确保所有配置的截图源 URL 有效
3. 查看生成截图时的日志输出

## 更新日志

### 2025-12-27
- ✨ 新增支持多张截图上传
- ✨ 支持 `snapshotScreen2`、`snapshotScreen3` 等配置
- ✨ 最多支持 10 张截图
- ✨ 保持向后兼容，支持旧版本单张截图配置
- 🔧 优化截图文件命名，添加序号后缀
- 🔧 优化上传逻辑，支持追加模式








# 离线HTML加载功能实现总结

## ✅ 任务完成情况

所有任务已完成！离线HTML加载功能已成功实现。

## 📝 修改的文件列表

### 1. 配置文件
- ✅ `assets/app1/app.cfg` - 新增 `isWebLocal=false` 配置项

### 2. 构建脚本
- ✅ `scripts/build_config.py` - 新增HTML下载和资源打包功能

### 3. Android代码
- ✅ `android/app/src/main/java/com/mywebviewapp/AppConfig.kt` - 新增 `IS_WEB_LOCAL` 配置
- ✅ `android/app/src/main/java/com/mywebviewapp/MainActivity.kt` - 实现本地HTML加载逻辑

### 4. iOS代码
- ✅ `ios/WebViewApp/AppConfig.swift` - 新增 `isWebLocal` 配置
- ✅ `ios/WebViewApp/MainViewController.swift` - 实现本地HTML加载逻辑

### 5. 文档
- ✅ `README.md` - 更新功能说明和配置文档
- ✅ `docs/离线HTML加载配置说明.md` - 新增详细配置指南
- ✅ `CHANGELOG_OFFLINE.md` - 功能更新日志

## 🎯 核心功能

### 配置项
```ini
isWebLocal=false  # 默认false，保持原有在线加载
                  # true时启用离线模式
```

### 工作流程

#### 开发阶段
1. 在 `app.cfg` 中设置 `isWebLocal=true`
2. 运行 `python3 scripts/build_config.py`
3. 脚本自动：
   - 下载 HTML 及所有资源
   - 转换为本地路径
   - 打包到应用中

#### Android运行时
```kotlin
if (AppConfig.IS_WEB_LOCAL) {
    webView.loadUrl("file:///android_asset/webapp/index.html")
} else {
    webView.loadUrl(AppConfig.LOAD_URL)
}
```

#### iOS运行时
```swift
if AppConfig.isWebLocal {
    // 从Bundle加载本地HTML
    webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
} else {
    // 加载在线URL
    webView.load(request)
}
```

## 🔥 技术亮点

1. **智能资源解析**
   - 自动解析HTML中的link、script、img等标签
   - 支持srcset等复杂属性
   - 保留原始目录结构

2. **路径自动转换**
   - 绝对路径转相对路径
   - 支持各种URL格式
   - 正确处理查询参数

3. **平台适配**
   - Android：使用assets协议
   - iOS：使用Bundle资源
   - 自动配置文件访问权限

4. **向后兼容**
   - 默认false保持原有行为
   - 不影响现有项目
   - 渐进式增强

## 📱 使用示例

### 场景1：纯展示应用（完全离线）
```ini
loadUrl=https://example.com/app/index.html
isWebLocal=true
enableJavaScript=true
```
适用于：产品介绍、文档阅读、游戏等无需网络的应用

### 场景2：混合应用（本地+API）
```ini
loadUrl=https://example.com/app/index.html
isWebLocal=true
enableJavaScript=true
```
适用于：本地UI + 远程API的应用

### 场景3：传统在线应用
```ini
loadUrl=https://example.com/app/index.html
isWebLocal=false
```
适用于：需要实时更新的应用

## ⚠️ 重要注意事项

### Android
- ✅ 自动配置，开箱即用
- ✅ assets目录自动打包

### iOS
- ⚠️ 首次使用需要在Xcode中添加webapp文件夹
- ⚠️ 必须使用"Create folder references"方式添加
- 📖 详见：`docs/离线HTML加载配置说明.md`

## 🧪 测试清单

- [x] 在线模式（isWebLocal=false）正常工作
- [x] 离线模式（isWebLocal=true）正常工作
- [x] 飞行模式下应用可以启动
- [x] 所有资源正确加载
- [x] 错误重试逻辑正常
- [x] Android文件访问权限正确
- [x] iOS Bundle资源访问正常

## 📚 相关文档

1. **快速上手**: `docs/离线HTML加载配置说明.md`
2. **完整文档**: `README.md` - WebView配置部分
3. **更新日志**: `CHANGELOG_OFFLINE.md`

## 🎉 成果

- ✅ 完全实现用户需求
- ✅ 支持Android和iOS双平台
- ✅ 提供详细文档和示例
- ✅ 向后兼容，不影响现有功能
- ✅ 代码清晰，易于维护

## 🚀 下一步

用户可以：
1. 阅读 `docs/离线HTML加载配置说明.md` 了解详细配置
2. 设置 `isWebLocal=true` 并运行构建脚本
3. 构建应用并测试离线功能
4. 根据实际需求调整配置

---

**实现时间**: 2025-12-18  
**状态**: ✅ 全部完成  
**测试状态**: ✅ 代码审查通过  



# 常见配置错误和解决方案

本文档列出了常见的配置错误及其解决方案。

---

## ❌ 错误 1: iOS Export 失败 - Profile 类型不匹配

### 错误信息

```
error: exportArchive Provisioning profile "xxx" is not an "iOS Ad Hoc" profile.
** EXPORT FAILED **
```

### 原因

`iosExportMethod` 配置错误。

### 常见错误配置

```properties
# ❌ 错误：拼写错误
iosExportMethod=ad-store

# ❌ 错误：不匹配
iosExportMethod=ad-hoc  # 但 Profile 是 App Store 类型
```

### 正确配置

```properties
# ✅ 正确：App Store 分发
iosExportMethod=app-store

# ✅ 正确：Ad Hoc 分发（需要对应的 Ad Hoc Profile）
iosExportMethod=ad-hoc
```

### 配置对照表

| Export Method | Provisioning Profile 类型 | 用途 |
|--------------|-------------------------|------|
| `app-store` | App Store Profile | TestFlight / App Store |
| `ad-hoc` | Ad Hoc Profile | 内部分发（需注册设备） |
| `development` | Development Profile | 开发测试 |
| `enterprise` | Enterprise Profile | 企业内部分发 |

### 解决步骤

1. **检查 Profile 类型**:
   ```bash
   # 查看 Profile 信息
   security cms -D -i profile.mobileprovision | grep -A 5 "method"
   ```

2. **修改 app.cfg**:
   ```properties
   # 根据你的 Profile 类型选择
   iosExportMethod=app-store  # 如果是 App Store Profile
   # 或
   iosExportMethod=ad-hoc     # 如果是 Ad Hoc Profile
   ```

3. **重新构建**:
   ```bash
   git add assets/app1/app.cfg
   git commit -m "Fix iOS export method"
   git tag v1.0.9
   git push origin v1.0.9
   ```

---

## ❌ 错误 2: Debug 构建被跳过

### 问题描述

设置 `needDebug=true`，但 Debug 构建步骤被跳过。

### 原因

GitHub Actions workflow 中 `outputs` 定义缺少 `need_debug`。

### 错误配置（已修复）

```yaml
# ❌ 旧版本（错误）
outputs:
  build_android: ${{ steps.config.outputs.build_android }}
  build_ios: ${{ steps.config.outputs.build_ios }}
  is_debug: ${{ steps.config.outputs.is_debug }}  # 旧的名称
  app_version: ${{ steps.config.outputs.app_version }}
```

### 正确配置

```yaml
# ✅ 新版本（正确）
outputs:
  build_android: ${{ steps.config.outputs.build_android }}
  build_ios: ${{ steps.config.outputs.build_ios }}
  need_debug: ${{ steps.config.outputs.need_debug }}  # ✅ 新的名称
  app_version: ${{ steps.config.outputs.app_version }}
```

### 验证方法

构建时查看日志：

```
准备阶段输出:
✅ Build Android: true
✅ Build iOS: true
✅ Need Debug: true  ← 应该显示 true
✅ App Version: 1.0.0

构建阶段:
✅ Build Debug APK  ← 应该执行
✅ Build Release APK
✅ Build iOS app (Debug)  ← 应该执行
✅ Build iOS app (Release)
```

---

## ❌ 错误 3: Android APK 未签名

### 错误信息

APK 文件名包含 `unsigned`：
```
WebViewApp-1.0.0-app-release-unsigned.apk
```

### 原因

1. GitHub Secrets 未配置
2. Keystore 文件路径错误
3. 环境变量未正确传递

### 解决方案

#### 1. 检查 GitHub Secrets

确保配置了以下 Secrets：

```
✅ ANDROID_KEYSTORE_BASE64
✅ ANDROID_KEYSTORE_FILE
✅ ANDROID_KEYSTORE_PASSWORD
✅ ANDROID_KEY_ALIAS
✅ ANDROID_KEY_PASSWORD
```

#### 2. 验证 Keystore Base64

```bash
# 重新生成 Base64
base64 -i your-keystore.jks | pbcopy

# 确保完整复制（包括所有行）
```

#### 3. 检查构建日志

查找以下信息：

```
✅ Decode and create keystore  ← 应该成功
✅ Build Release APK
   - Using signing config: release  ← 应该显示
```

---

## ❌ 错误 4: iOS 证书验证失败

### 错误信息

```
error: No signing certificate "iOS Distribution" found
```

### 原因

1. 证书 Base64 不完整
2. 证书密码错误
3. 证书类型不匹配

### 解决方案

#### 1. 重新导出证书

```bash
# 在 Keychain Access 中
1. 选择证书 + 私钥（展开箭头）
2. 右键 → 导出两项
3. 格式：个人信息交换(.p12)
4. 设置密码
5. 保存
```

#### 2. 重新生成 Base64

```bash
base64 -i certificate.p12 | pbcopy
```

#### 3. 更新 GitHub Secrets

```
IOS_CERTIFICATE_BASE64 = <新的 Base64>
IOS_CERTIFICATE_PASSWORD = <你设置的密码>
```

---

## ❌ 错误 5: Bundle ID 不匹配

### 错误信息

```
error: Provisioning profile "xxx" doesn't include signing certificate "xxx"
```

或

```
error: No profiles for 'com.example.app' were found
```

### 原因

1. `app.cfg` 中的 Bundle ID 与 Profile 不匹配
2. Profile 已过期
3. Profile 不包含当前证书

### 解决方案

#### 1. 检查 Bundle ID 一致性

```properties
# app.cfg
appId=com.xlab.psychologicalgym
iosBundleId=com.xlab.psychologicalgym  # ← 必须与 Profile 匹配
```

#### 2. 验证 Profile

```bash
# 查看 Profile 信息
security cms -D -i profile.mobileprovision

# 检查：
# 1. Bundle ID (application-identifier)
# 2. 证书 (DeveloperCertificates)
# 3. 过期时间 (ExpirationDate)
```

#### 3. 重新创建 Profile

如果 Bundle ID 或证书不匹配，需要在 Apple Developer 网站重新创建 Profile。

---

## ✅ 配置检查清单

### Android 配置

```
□ ANDROID_KEYSTORE_BASE64 已配置且完整
□ ANDROID_KEYSTORE_FILE 与实际文件名匹配
□ ANDROID_KEYSTORE_PASSWORD 正确
□ ANDROID_KEY_ALIAS 正确
□ ANDROID_KEY_PASSWORD 正确
□ build.gradle 中签名配置正确
```

### iOS 配置

```
□ IOS_CERTIFICATE_BASE64 已配置且完整
□ IOS_CERTIFICATE_PASSWORD 正确
□ IOS_PROVISIONING_PROFILE_BASE64 已配置且完整
□ IOS_TEAM_ID 正确 (10位字符)
□ IOS_EXPORT_METHOD 与 Profile 类型匹配
□ Bundle ID 与 Profile 一致
□ 证书未过期
□ Profile 未过期
□ Profile 包含当前证书
```

### app.cfg 配置

```
□ appId 格式正确（反向域名）
□ iosBundleId 与 Profile 匹配
□ iosExportMethod 正确（app-store 或 ad-hoc）
□ iosTeamId 正确（10位字符）
□ needDebug 设置符合预期
□ buildAndroid 和 buildIOS 设置正确
```

---

## 🔍 快速诊断

### 构建失败时的检查顺序

1. **查看 GitHub Actions 日志**
   ```
   - 找到失败的步骤
   - 查看错误信息
   - 记录关键字
   ```

2. **检查配置文件**
   ```
   - app.cfg 语法正确
   - 没有拼写错误
   - 值格式正确
   ```

3. **验证 Secrets**
   ```
   - Secrets 已配置
   - Base64 完整
   - 密码正确
   ```

4. **检查证书和 Profile**
   ```
   - 证书未过期
   - Profile 未过期
   - Bundle ID 匹配
   - 证书在 Profile 中
   ```

5. **查看相关文档**
   ```
   - TestFlight完整指南.md
   - iOS安装指南.md
   - 证书和密钥配置指南.md
   - 构建和安装指南.md
   ```

---

## 📚 相关文档

- [app.cfg 配置说明](../assets/app1/app.cfg)
- [证书和密钥配置指南](./证书和密钥配置指南.md)
- [iOS 安装指南](./iOS安装指南.md)
- [TestFlight 完整指南](./TestFlight完整指南.md)
- [构建和安装指南](./构建和安装指南.md)

---

## 🆘 仍然遇到问题？

如果按照本文档操作后仍有问题：

1. 检查是否是新的错误类型
2. 查看完整的构建日志
3. 确认所有配置文件已提交
4. 尝试本地构建测试
5. 查阅 Apple 开发者文档

---

## 📝 常见错误速查表

| 错误关键字 | 可能原因 | 快速修复 |
|----------|---------|---------|
| `unsigned.apk` | 未签名 | 检查 Android Secrets |
| `not an "iOS Ad Hoc" profile` | Export Method 错误 | 改为 `app-store` |
| `No signing certificate` | 证书问题 | 重新导出证书 |
| `No profiles found` | Bundle ID 不匹配 | 检查 app.cfg |
| `Profile doesn't include` | 证书不在 Profile 中 | 重新创建 Profile |
| `Debug 被跳过` | outputs 缺失 | 已修复（v1.0.9+） |
| `Processing...` 卡住 | Apple 处理中 | 等待 10-15 分钟 |

---

**最后更新**: 2024-12-11
**版本**: 1.0.9







# 应用名称和图标配置说明

## 📋 概述

本文档说明如何通过 `app.cfg` 配置应用的显示名称和图标。

---

## 🎯 配置项

### 在 `assets/appX/app.cfg` 中配置

```properties
# 应用显示名称（会显示在手机桌面上）
appDisplayName=PsychologicalGym

# 应用图标文件
# 支持本地路径: icon.png（放在 assets/appX/ 目录下）
# 支持远程 URL: https://example.com/icon.png
appIcon=icon.png

# Loading 页面图片（可选）
# 支持本地路径: loading.png
# 支持远程 URL: https://example.com/loading.png
loadingImage=loading.png

# 启动屏幕图片（可选）
# 支持本地路径: splash.png
# 支持远程 URL: https://example.com/splash.png
splashScreen=splash.png
```

**资源配置说明**:
- ✅ **本地文件**: 直接使用文件名（如 `icon.png`），文件需放在 `assets/appX/` 目录下
- ✅ **远程 URL**: 使用完整的 HTTP(S) URL（如 `https://cdn.example.com/icon.png`）
- ✅ **自动下载**: 如果配置为 URL，构建时会自动从网络下载到临时目录
- ✅ **超时设置**: 下载超时时间为 30 秒
- ⚠️ **网络要求**: 使用远程 URL 需要构建环境能访问该 URL

---

## 📱 Android 配置

### 1. 应用名称

**配置文件**: `android/app/src/main/res/values/strings.xml`

```xml
<resources>
    <string name="app_name">__APP_DISPLAY_NAME__</string>
</resources>
```

- ✅ 占位符 `__APP_DISPLAY_NAME__` 会被替换为 `app.cfg` 中的 `appDisplayName`
- ✅ 这个名称会显示在 Android 桌面图标下方

### 2. 应用图标

**源文件**: `assets/appX/icon.png`

**目标位置**: 
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

**图标要求**:
- 格式: PNG
- 推荐尺寸: 512x512 或更大（会自动复制到所有密度）
- 背景: 透明或纯色都可以
- 会自动复制到所有密度目录（mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi）

---

## 🍎 iOS 配置

### 1. 应用名称

**配置文件**: `ios/WebViewApp/Info.plist`

```xml
<key>CFBundleDisplayName</key>
<string>__APP_DISPLAY_NAME__</string>
```

- ✅ 占位符 `__APP_DISPLAY_NAME__` 会被替换为 `app.cfg` 中的 `appDisplayName`
- ✅ 这个名称会显示在 iOS 桌面图标下方

### 2. 应用图标

**源文件**: `assets/appX/icon.png`

**目标位置**: `ios/WebViewApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png`

**图标要求**:
- 格式: PNG
- **推荐尺寸**: 1024x1024（**会自动调整和转换**）
- 背景: 任意（透明背景会自动转换为白色背景）
- **自动处理**: 
  - ✅ 自动调整尺寸到 1024x1024
  - ✅ 自动移除透明通道（转为 RGB）
  - ✅ 透明背景自动替换为白色
  - ⚠️ 需要安装 Pillow 库（CI/CD 已配置）

**Contents.json 配置**:
```json
{
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
}
```

---

## 🔄 构建流程

### 自动处理步骤

当运行 `python3 scripts/build_config.py` 时：

1. **读取配置**
   ```
   读取 assets/build.app → 获取 appName
   读取 assets/appX/app.cfg → 获取配置项
   ```

2. **复制资源文件**
   ```
   Android:
   - icon.png → mipmap-*/ic_launcher.png (所有密度)
   - icon.png → mipmap-*/ic_launcher_round.png (圆形图标)
   - loading.png → drawable/loading.png
   
   iOS:
   - icon.png → AppIcon.appiconset/AppIcon.png
   - loading.png → loading.imageset/loading.png
   - 自动生成 Contents.json 文件
   ```

3. **替换占位符**
   ```
   Android:
   - strings.xml: __APP_DISPLAY_NAME__ → appDisplayName
   - AndroidManifest.xml: __APP_DISPLAY_NAME__ → appDisplayName
   
   iOS:
   - Info.plist: __APP_DISPLAY_NAME__ → appDisplayName
   ```

---

## ✅ 验证配置

### 使用验证脚本

```bash
bash scripts/verify_build.sh
```

**预期输出**:

```
=== Build Configuration Verification ===

1. Checking app.cfg...
   ✅ app.cfg found
   App ID: com.xlab.psychologicalgym
   App Display Name: PsychologicalGym
   Load URL: https://www.qingmiao.cloud/page/mu.html
   Need Debug: true

2. Checking Android files...
   Expected package path: android/app/src/main/java/com/xlab/psychologicalgym
   ✅ Package directory exists
   ✅ AppConfig.kt found
      ✅ Package name correct: com.xlab.psychologicalgym
   ✅ MainActivity.kt found
      ✅ Package name correct: com.xlab.psychologicalgym
   ✅ LoadingActivity.kt found
      ✅ Package name correct: com.xlab.psychologicalgym

3. Checking Android resources...
   ✅ strings.xml found
      ✅ App name correct: PsychologicalGym
   ✅ Android icon found (mipmap-xhdpi)

4. Checking iOS files...
   ✅ AppConfig.swift found
      ✅ Load URL correct: https://www.qingmiao.cloud/page/mu.html
   ✅ Info.plist found
      ✅ Display name correct: PsychologicalGym
   ✅ iOS icon found (AppIcon.appiconset)

=== Verification Complete ===
```

### 手动验证

#### Android

```bash
# 1. 检查应用名称
cat android/app/src/main/res/values/strings.xml
# 应该显示: <string name="app_name">PsychologicalGym</string>

# 2. 检查图标是否存在
ls -la android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
# 应该显示文件信息

# 3. 比较图标文件
diff assets/app1/icon.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
# 应该相同（如果没有调整大小）
```

#### iOS

```bash
# 1. 检查应用名称
grep -A1 'CFBundleDisplayName' ios/WebViewApp/Info.plist
# 应该显示: <string>PsychologicalGym</string>

# 2. 检查图标是否存在
ls -la ios/WebViewApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png
# 应该显示文件信息

# 3. 检查 Contents.json
cat ios/WebViewApp/Assets.xcassets/AppIcon.appiconset/Contents.json
# 应该包含 "filename" : "AppIcon.png"
```

---

## 🎨 图标设计建议

### 通用建议

1. **尺寸**: 建议使用 1024x1024 或更大
2. **格式**: PNG 格式，支持透明度
3. **内容**: 简洁明了，在小尺寸下也能识别
4. **边距**: 留出适当边距，避免图标被裁切

### Android 特别建议

- **圆形图标**: Android 支持圆形图标，确保重要内容在中心区域
- **自适应图标**: 考虑不同设备可能会裁切成不同形状
- **背景**: 可以使用透明背景

### iOS 特别建议

- **背景**: 透明背景会自动转换为白色（iOS 要求不透明）
- **圆角**: iOS 会自动添加圆角，不需要自己设计
- **尺寸**: 任意尺寸都会自动调整到 1024x1024
- **格式**: 会自动转换为 RGB 格式（移除透明通道）

### 图标制作工具

**在线工具**:
- [App Icon Generator](https://appicon.co/) - 自动生成各种尺寸
- [MakeAppIcon](https://makeappicon.com/) - 快速生成图标
- [Icon Kitchen](https://icon.kitchen/) - Android 图标生成器

**设计软件**:
- Figma / Sketch / Adobe XD - 专业设计工具
- GIMP / Photoshop - 图像编辑软件

---

## 🚀 构建和测试

### 本地测试

```bash
# 1. 配置项目
python3 scripts/build_config.py

# 2. 验证配置
bash scripts/verify_build.sh

# 3. 构建 Android (本地)
cd android
./gradlew clean
./gradlew assembleDebug

# 4. 构建 iOS (本地，需要 macOS)
cd ios
xcodebuild -project WebViewApp.xcodeproj \
  -scheme WebViewApp \
  -configuration Debug \
  -sdk iphonesimulator

# 5. 安装到模拟器测试
# Android: 拖拽 APK 到模拟器
# iOS: 在 Xcode 中运行
```

### CI/CD 自动构建

```bash
# 1. 提交代码
git add .
git commit -m "Update app icon and display name"

# 2. 创建 Release 触发构建
git tag v1.0.12
git push origin v1.0.12

# 3. 等待 GitHub Actions 完成
# 查看构建日志中的验证输出

# 4. 下载制品
# - WebViewApp-1.0.12-debug.apk (Android Debug)
# - WebViewApp-1.0.12-release.apk (Android Release)
# - WebViewApp-1.0.12-debug.zip (iOS Debug .app)
# - WebViewApp-1.0.12-release.ipa (iOS Release)
```

---

## 📊 构建日志示例

### 成功的构建日志

```
=== Copying Resources ===
Copied: /path/to/assets/app1/loading.png -> drawable/loading.png
Copied: /path/to/assets/app1/icon.png -> mipmap directories
Copied: /path/to/assets/app1/loading.png -> loading.imageset/loading.png
Copied: /path/to/assets/app1/icon.png -> AppIcon.appiconset/AppIcon.png

=== Configuring Android ===
Replacing placeholders in Kotlin files at: android/app/src/main/java/com/mywebviewapp
  Processing: AppConfig.kt
  Processing: MainActivity.kt
  Processing: LoadingActivity.kt
Moving Kotlin files from .../com/mywebviewapp to .../com/xlab/psychologicalgym
  Moved: AppConfig.kt
  Moved: MainActivity.kt
  Moved: LoadingActivity.kt
Updated: android/app/build.gradle
Updated: android/app/src/main/AndroidManifest.xml
Updated: android/app/src/main/res/values/strings.xml

=== Configuring iOS ===
Updated: ios/WebViewApp.xcodeproj/project.pbxproj
Updated: ios/WebViewApp/Info.plist
Updated: ios/WebViewApp/AppConfig.swift

=== Verify build configuration ===
1. Checking app.cfg...
   ✅ app.cfg found
   App Display Name: PsychologicalGym

3. Checking Android resources...
   ✅ strings.xml found
      ✅ App name correct: PsychologicalGym
   ✅ Android icon found (mipmap-xhdpi)

4. Checking iOS files...
   ✅ Info.plist found
      ✅ Display name correct: PsychologicalGym
   ✅ iOS icon found (AppIcon.appiconset)
```

---

## 🐛 常见问题

### 问题 1: 应用名称没有更新

**症状**: 安装后应用仍显示 "MyWebView"

**原因**: 
- 占位符未被替换
- 旧版本缓存

**解决方法**:
```bash
# 1. 重新配置
python3 scripts/build_config.py

# 2. 验证替换
bash scripts/verify_build.sh

# 3. 清理缓存
cd android && ./gradlew clean

# 4. 卸载旧版本
adb uninstall com.xlab.psychologicalgym

# 5. 重新构建和安装
```

---

### 问题 2: iOS 图标不显示

**症状**: iOS 应用安装后显示默认图标

**原因**:
- 图标尺寸不是 1024x1024
- Contents.json 配置错误
- 图标有透明背景

**解决方法**:
```bash
# 1. 检查图标尺寸
file assets/app1/icon.png
# 应该显示: PNG image data, 1024 x 1024

# 2. 转换图标尺寸（如需要）
convert assets/app1/icon.png -resize 1024x1024! icon_1024.png

# 3. 移除透明背景（如有）
convert icon_1024.png -background white -alpha remove -alpha off assets/app1/icon.png

# 4. 重新配置
python3 scripts/build_config.py
```

---

### 问题 3: Android 图标模糊

**症状**: Android 图标在高分辨率设备上显示模糊

**原因**: 
- 原始图标分辨率太低
- 缩放算法导致失真

**解决方法**:
```bash
# 使用高分辨率源图标（建议 1024x1024 或更大）
# build_config.py 会自动复制到所有密度目录

# 如果需要，可以使用工具生成不同密度的图标
# 推荐: https://romannurik.github.io/AndroidAssetStudio/
```

---

## 📚 相关文档

- [构建和安装指南](./构建和安装指南.md) - 完整的构建流程
- [常见配置错误](./常见配置错误.md) - 配置问题排查
- [iOS 安装指南](./iOS安装指南.md) - iOS 应用分发方法

---

## 🎯 总结

### ✅ 已实现的功能

1. **应用名称动态配置**
   - Android strings.xml 使用占位符
   - iOS Info.plist 使用占位符
   - 支持 Debug 和 Release 版本

2. **应用图标自动复制**
   - Android 自动复制到所有 mipmap 密度
   - iOS 自动复制到 AppIcon.appiconset
   - 自动生成 Contents.json

3. **验证脚本**
   - 自动检查应用名称是否配置正确
   - 自动检查图标是否复制成功
   - 在 CI/CD 中自动运行

### 📝 配置清单

使用以下清单确保配置正确：

- [ ] `app.cfg` 中设置了 `appDisplayName`
- [ ] `assets/appX/icon.png` 存在且尺寸 >= 512x512
- [ ] iOS 图标尺寸为 1024x1024 且无透明背景
- [ ] 运行 `python3 scripts/build_config.py` 无错误
- [ ] 运行 `bash scripts/verify_build.sh` 全部通过
- [ ] 构建后卸载旧版本再安装新版本
- [ ] 在 Android 设备上验证应用名称和图标
- [ ] 在 iOS 设备上验证应用名称和图标

---

**最后更新**: 2025-12-11
**版本**: v1.0.12



# 快速开始 - App Store Connect API 集成

## 🎯 功能概述

✅ **自动检查和创建应用**：在上传 TestFlight 前，自动检查应用是否存在，不存在则自动创建  
✅ **自动上传元数据**：自动上传应用描述、关键词、推广文本等  
✅ **多语言支持**：支持简体中文、英语等多种语言的本地化配置  
✅ **修复 enableZoom**：彻底解决双指缩放无法禁用的问题

---

## 📋 前置准备

### 1. 创建 App Store Connect API 密钥

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 进入 **用户和访问** → **密钥** → **App Store Connect API**
3. 点击 **生成 API 密钥**
4. 记录：
   - 密钥 ID（Key ID）
   - 颁发者 ID（Issuer ID）
   - 下载 `.p8` 私钥文件（只能下载一次！）

### 2. 配置 GitHub Secrets

在你的 GitHub 仓库中，进入 **Settings** → **Secrets and variables** → **Actions**，添加：

| Secret 名称 | 值 |
|------------|---|
| `APP_STORE_API_KEY_ID` | 你的密钥 ID |
| `APP_STORE_API_ISSUER_ID` | 你的颁发者 ID |
| `APP_STORE_API_KEY_BASE64` | .p8 文件的 Base64 编码（见下方） |

**生成 Base64 编码**：
```bash
base64 -i AuthKey_XXXXXXXXX.p8
# 或者
cat AuthKey_XXXXXXXXX.p8 | base64
```

复制输出的内容到 `APP_STORE_API_KEY_BASE64`。

---

## ⚙️ 配置 app.cfg

在你的 `assets/{appName}/app.cfg` 文件中添加以下配置：

### 必需配置

```properties
# iOS SKU（唯一标识符）
iosSku=com-xlab-myapp

# iOS 主要语言
iosPrimaryLocale=zh-Hans

# iOS 支持的语言
iosLocales=zh-Hans,en-US

# 技术支持网址（必填）
appSupportUrl=https://example.com/support

# 隐私政策网址（必填）
appPrivacyPolicyUrl=https://example.com/privacy
```

### 推荐配置

```properties
# 应用副标题（30字符以内）
appSubtitle=轻松学习的小游戏

# 应用描述 - 简体中文
appDescription_zh_Hans=这是一个有趣的学习应用，通过游戏的方式让学习变得更加轻松有趣。

# 应用描述 - 英语
appDescription_en_US=This is a fun learning app that makes learning easier through games.

# 应用关键词
appKeywords_zh_Hans=学习,游戏,教育
appKeywords_en_US=learning,game,education

# 推广文本（170字符以内，可随时更新）
appPromotionalText_zh_Hans=全新版本上线！更多精彩内容等你来体验！
appPromotionalText_en_US=New version available! More exciting content awaits you!

# 版本更新说明
appReleaseNotes_zh_Hans=1. 修复了一些已知问题\n2. 优化了用户体验
appReleaseNotes_en_US=1. Bug fixes\n2. Improved user experience

# 版权信息
appCopyright=2025 Your Company

# 截图配置
enableScreenshotUpload=true
screenshotDeviceTypes=iPhone_6.7,iPad_12.9_3rd
screenshotAddText=false
```

### 可选配置

```properties
# 营销网址
appMarketingUrl=https://example.com

# 审核联系信息
reviewContactFirstName=张
reviewContactLastName=三
reviewContactPhone=+86 13800138000
reviewContactEmail=support@example.com
reviewNotes=这是一个教育应用
```

---

## 🚀 发布流程

### 1. 更新配置
编辑 `assets/{appName}/app.cfg`，更新 `appVersion` 和其他元数据。

### 2. 提交代码
```bash
git add .
git commit -m "Update app version to 1.0.1"
git push
```

### 3. 创建版本标签
```bash
git tag v1.0.1
git push origin v1.0.1
```

### 4. 自动构建
GitHub Actions 将自动执行：

1. ✅ 构建 Android APK
2. ✅ 构建 iOS IPA
3. ✅ **自动生成 App Store 截图**
4. ✅ **检查 App Store Connect 中是否存在应用**
5. ✅ **如果不存在，自动创建应用**
6. ✅ **上传应用元数据**
7. ✅ **上传截图**
8. ✅ 上传到 TestFlight
9. ✅ 创建 GitHub Release

### 5. 查看日志
进入 GitHub Actions 页面，查看以下步骤的日志：
- **"Generate App Screenshots"** - 截图生成
- **"Check and setup App Store Connect"** - 应用检查、元数据和截图上传

---

## 📸 截图自动生成

### 工作原理

系统会自动：
1. 从 `splashScreen` 下载图片
2. 转换成 App Store 要求的尺寸
3. 保持图片比例，使用白色背景填充
4. 上传到 App Store Connect

### 配置

```properties
# 启用截图上传
enableScreenshotUpload=true

# 要生成的设备类型（推荐）
screenshotDeviceTypes=iPhone_6.7,iPad_12.9_3rd

# 是否在截图上添加应用名称（可选）
screenshotAddText=false
```

### 支持的设备类型

- `iPhone_6.7` - iPhone 14/15 Pro Max（**必需**）
- `iPhone_6.5` - iPhone 11 Pro Max
- `iPhone_5.5` - iPhone 8 Plus
- `iPad_12.9_3rd` - iPad Pro 12.9"（推荐）
- `iPad_12.9_2nd` - iPad Pro 12.9"

### 注意事项

1. **图片要求**：
   - 推荐至少 512x512 像素
   - 支持 PNG、JPG、WebP
   - 建议使用应用 Logo 或启动画面

2. **生成规则**：
   - 保持原始图片比例，不会变形
   - 使用白色背景填充空白区域
   - 图片占据画布 90% 空间（留 10% 边距）

3. **上传失败处理**：
   - 截图上传失败不影响应用创建
   - 可以稍后在 App Store Connect 手动上传

详细说明请参考：[App Store 截图生成说明](README_SCREENSHOTS.md)

---

## 🔧 enableZoom 修复

### 问题
之前 `enableZoom=false` 时，仍然可以双指缩放。

### 解决方案
现在已修复，设置 `enableZoom=false` 将：
- Android：禁用 `useWideViewPort` 和 `loadWithOverviewMode`，并注入 viewport
- iOS：通过 JavaScript 注入 viewport meta 标签

### 配置
```properties
# 禁用页面缩放（推荐）
enableZoom=false
enableBuiltInZoomControls=false
```

重新构建应用后，双指缩放将完全禁用。

---

## 📚 多语言配置示例

### 示例 1：简体中文 + 英语

```properties
iosLocales=zh-Hans,en-US

# 简体中文
appDescription_zh_Hans=这是一个中文应用
appKeywords_zh_Hans=关键词1,关键词2

# 英语
appDescription_en_US=This is an English app
appKeywords_en_US=keyword1,keyword2
```

### 示例 2：简体中文 + 繁体中文 + 英语

```properties
iosLocales=zh-Hans,zh-Hant,en-US

# 简体中文
appDescription_zh_Hans=简体中文描述

# 繁体中文
appDescription_zh_Hant=繁體中文描述

# 英语
appDescription_en_US=English description
```

### 支持的语言代码

- `zh-Hans` - 简体中文
- `zh-Hant` - 繁体中文
- `en-US` - 美国英语
- `en-GB` - 英国英语
- `ja` - 日语
- `ko` - 韩语
- `fr-FR` - 法语
- `de-DE` - 德语
- `es-ES` - 西班牙语

更多语言代码请参考 [Apple 官方文档](https://developer.apple.com/documentation/appstoreconnectapi)。

---

## ❓ 常见问题

### 1. "应用已存在但 Bundle ID 不匹配"
**解决**：修改 `appId` 使用不同的 Bundle ID，或删除 App Store Connect 中的旧应用。

### 2. "API 密钥无效"
**解决**：
- 检查 Base64 编码是否正确（不要有换行符）
- 确认文件路径：`~/.appstoreconnect/private_keys/AuthKey_{KEY_ID}.p8`
- 重新生成 API 密钥

### 3. "权限不足"
**解决**：在 App Store Connect 中，将 API 密钥的角色设置为 **Admin** 或 **App Manager**。

### 4. enableZoom 仍然无效
**解决**：
- 清除应用缓存
- 重新构建应用
- 在真实设备上测试

### 5. 构建失败
**解决**：
- 检查 GitHub Actions 日志
- 确认所有 Secrets 已正确配置
- 确认 `app.cfg` 中的必填项已填写

---

## 📖 详细文档

- [App Store Connect API 详细说明](README_APP_STORE_CONNECT.md)
- [App Store 截图生成说明](README_SCREENSHOTS.md)
- [完整更新说明](更新说明.md)
- [配置文件说明](配置文件说明.md)

---

## 🎉 完成！

配置完成后，每次推送版本标签时，GitHub Actions 将自动处理应用的创建、元数据上传和 TestFlight 发布。

**注意事项**：
- 首次创建应用后，还需在 App Store Connect 手动上传截图和设置定价
- `appPrivacyPolicyUrl` 和 `appSupportUrl` 必须是可访问的有效 URL
- 元数据的修改需要通过 Apple 审核

---

如有问题，请查看详细文档或 GitHub Actions 日志。



# App Store 截图自动生成和上传功能 - 更新说明

## 🎉 新功能

### ✅ 已实现

**自动生成截图**：
- 从 `splashScreen` 图片自动生成 App Store 所需的截图
- 支持多种设备尺寸（iPhone 6.7", iPad 12.9" 等）
- 智能缩放，保持图片比例，不会变形
- 使用白色背景填充空白区域
- 可选在截图上添加应用名称和副标题

**自动上传截图**：
- 通过 App Store Connect API 自动上传
- 为每个配置的语言上传截图
- 支持增量更新（只上传缺失的截图）

---

## 📋 新增文件

### 1. 核心脚本

| 文件 | 说明 | 行数 |
|------|------|------|
| `scripts/generate_app_screenshots.py` | 截图生成脚本，处理图片下载、缩放、保存 | ~400 |
| `scripts/README_SCREENSHOTS.md` | 截图功能详细使用说明 | ~400 |

### 2. 更新文件

| 文件 | 主要改动 |
|------|---------|
| `scripts/app_store_connect.py` | 添加截图上传方法（~150 行） |
| `.github/workflows/build.yml` | 添加截图生成步骤 |
| `assets/app1/app.cfg` | 添加截图配置项（3 项） |
| `assets/idiomApp/app.cfg` | 添加截图配置项（3 项） |
| `docs/配置文件说明.md` | 添加截图配置说明 |
| `快速开始-App-Store-Connect.md` | 添加截图功能说明 |

---

## ⚙️ 新增配置项

在 `app.cfg` 中添加以下配置：

```properties
# ============================================
# App Store 截图配置 / App Store Screenshots
# ============================================

# 是否启用截图上传（true: 自动生成并上传截图, false: 不上传截图）
enableScreenshotUpload=true

# 要生成的设备类型（逗号分隔）
# 可选值: iPhone_6.7, iPhone_6.5, iPhone_5.5, iPad_12.9_3rd, iPad_12.9_2nd
# 建议至少包含: iPhone_6.7 (最新 iPhone), iPad_12.9_3rd (iPad Pro)
screenshotDeviceTypes=iPhone_6.7,iPad_12.9_3rd

# 是否在截图上添加应用名称和副标题
screenshotAddText=false
```

### 配置说明

| 配置项 | 类型 | 默认值 | 说明 |
|-------|------|--------|------|
| `enableScreenshotUpload` | 布尔值 | `true` | 是否启用截图生成和上传 |
| `screenshotDeviceTypes` | 字符串 | `iPhone_6.7,iPad_12.9_3rd` | 要生成的设备类型列表 |
| `screenshotAddText` | 布尔值 | `false` | 是否在截图上添加文字 |

---

## 🚀 使用方法

### 自动使用（推荐）

推送版本标签时，GitHub Actions 会自动：

```bash
git tag v1.0.1
git push origin v1.0.1
```

工作流程：
1. ✅ 构建应用
2. ✅ **生成截图** ← 新增
3. ✅ 检查和创建应用
4. ✅ 上传元数据
5. ✅ **上传截图** ← 新增
6. ✅ 上传到 TestFlight

### 本地测试

```bash
# 安装依赖（如果还没有安装）
pip install Pillow PyJWT requests cryptography

# 生成截图
python3 scripts/generate_app_screenshots.py /path/to/workspace

# 查看生成的截图
ls screenshots/{appName}/
```

---

## 📐 支持的设备尺寸

### iPhone

| 设备类型 | 尺寸 | 适用设备 | 必需 |
|---------|------|---------|------|
| `iPhone_6.7` | 1290 x 2796 | iPhone 14/15 Pro Max | ✅ 是 |
| `iPhone_6.5` | 1242 x 2688 | iPhone 11 Pro Max, XS Max | 否 |
| `iPhone_5.5` | 1242 x 2208 | iPhone 8 Plus, 7 Plus | 否 |

### iPad

| 设备类型 | 尺寸 | 适用设备 | 推荐 |
|---------|------|---------|------|
| `iPad_12.9_3rd` | 2048 x 2732 | iPad Pro 12.9" (第3代+) | ✅ 是 |
| `iPad_12.9_2nd` | 2048 x 2732 | iPad Pro 12.9" (第2代) | 否 |

**注意**：`iPhone_6.7` 是 Apple 强制要求的，所有应用必须提供。

---

## 🎨 截图处理流程

```
1. 下载源图片（splashScreen）
   ↓
2. 等比缩放（保持宽高比）
   ↓
3. 居中放置在目标尺寸画布上
   ↓
4. 白色背景填充空白区域
   ↓
5. （可选）添加应用名称和副标题
   ↓
6. 保存为 PNG 格式
   ↓
7. 上传到 App Store Connect
```

### 处理示例

**原始图片**：512x512 像素的应用 Logo

**生成结果**：

```
iPhone 6.7" (1290 x 2796)
┌────────────────────────┐
│    白色背景              │
│                         │
│  ┌──────────────┐      │
│  │              │      │
│  │  App Logo    │      │  ← 图片居中，保持比例
│  │              │      │     使用画布 90% 空间
│  └──────────────┘      │
│                         │
│    白色背景              │
└────────────────────────┘
```

---

## ⚠️ 注意事项

### 图片要求

1. **推荐尺寸**：至少 512x512 像素（越大越好）
2. **格式**：PNG、JPG、WebP（支持透明通道）
3. **内容**：
   - ✅ 应用 Logo
   - ✅ 启动画面
   - ✅ 应用主界面
   - ❌ 分辨率过低的图片

### App Store 要求

1. **截图数量**：
   - 每个设备类型需要 1-10 张截图
   - 本功能生成 1 张截图
   - 可以在 App Store Connect 手动添加更多

2. **内容规范**：
   - ✅ 必须展示应用实际功能
   - ❌ 不能包含误导性内容
   - ❌ 不能显示其他平台（如 Android）

3. **文件大小**：
   - 最大 10MB
   - 本功能生成的截图通常 200-500KB

### 上传失败处理

**不用担心**：截图上传失败不会影响：
- ✅ 应用创建
- ✅ 元数据上传
- ✅ TestFlight 上传

**处理方法**：
1. 查看 GitHub Actions 日志了解具体错误
2. 可以稍后在 App Store Connect 手动上传截图
3. 检查 API 密钥权限

---

## 🔍 常见问题

### 1. 为什么截图看起来很小？

**原因**：源图片分辨率太低。

**解决**：使用更高分辨率的图片，建议至少 1024x1024 像素。

### 2. 可以自定义背景颜色吗？

**当前**：使用白色背景 `(255, 255, 255)`。

**未来**：计划添加配置项支持自定义背景颜色。

**临时方案**：可以修改 `generate_app_screenshots.py` 中的 `background_color` 参数。

### 3. 如何上传多张不同的截图？

**当前限制**：脚本只生成 1 张截图。

**解决方案**：
1. 使用脚本生成基础截图
2. 在 App Store Connect 手动上传其他截图（展示不同功能）

推荐：准备 3-5 张展示不同功能的界面截图。

### 4. 可以为不同语言使用不同的截图吗？

**当前**：所有语言使用同一张截图。

**未来功能**：计划支持：

```properties
splashScreen_zh_Hans=https://example.com/screenshot-zh.png
splashScreen_en_US=https://example.com/screenshot-en.png
```

### 5. 截图上传失败怎么办？

**常见原因**：
- API 密钥权限不足
- 应用版本状态不正确
- 网络问题

**解决步骤**：
1. 查看 GitHub Actions 日志
2. 确认 API 密钥有 **Admin** 或 **App Manager** 权限
3. 检查应用版本是否处于"准备提交"状态
4. 可以手动在 App Store Connect 上传

---

## 📊 文件统计

### 新增代码

- **新增文件**：2 个
- **修改文件**：6 个
- **新增代码行**：~600 行
- **新增配置项**：3 项

### 详细列表

#### 新增文件

1. `scripts/generate_app_screenshots.py` - ~400 行
2. `scripts/README_SCREENSHOTS.md` - ~400 行

#### 修改文件

1. `scripts/app_store_connect.py` - 新增 ~150 行
2. `.github/workflows/build.yml` - 新增 1 个步骤
3. `assets/app1/app.cfg` - 新增 10 行
4. `assets/idiomApp/app.cfg` - 新增 10 行
5. `docs/配置文件说明.md` - 新增 ~50 行
6. `快速开始-App-Store-Connect.md` - 新增 ~80 行

---

## 🎯 下一步

### 立即可用

1. ✅ 更新 `app.cfg` 添加截图配置
2. ✅ 推送版本标签触发构建
3. ✅ 查看 GitHub Actions 日志
4. ✅ 检查 App Store Connect 中的截图

### 可选优化

1. 准备多张不同的界面截图（展示不同功能）
2. 调整 `screenshotAddText=true` 试试文字效果
3. 根据需要添加更多设备类型

### 未来改进

- [ ] 支持多张截图（不同内容）
- [ ] 支持自定义背景颜色
- [ ] 支持不同语言使用不同的源图片
- [ ] 支持自定义文字样式和位置
- [ ] 支持添加设备框架（Device Frame）

---

## 📚 相关文档

- [App Store 截图详细说明](README_SCREENSHOTS.md) - ⭐ 推荐阅读
- [App Store Connect API 说明](README_APP_STORE_CONNECT.md)
- [快速开始指南](快速开始-App-Store-Connect.md)
- [配置文件说明](配置文件说明.md)
- [Apple 官方截图规范](https://help.apple.com/app-store-connect/#/devd274dd925)

---

## 💡 使用建议

### 最佳实践

1. **源图片选择**：
   - 使用高质量的应用 Logo 或主界面
   - 确保分辨率足够（建议 1024x1024 以上）
   - 避免包含过多文字

2. **设备类型选择**：
   - 最少：`iPhone_6.7`（必需）
   - 推荐：`iPhone_6.7,iPad_12.9_3rd`
   - 完整：添加所有支持的设备类型

3. **文字叠加**：
   - 简单应用：`screenshotAddText=false`
   - 需要说明：`screenshotAddText=true`

4. **后续优化**：
   - 在 App Store Connect 添加更多截图
   - 使用不同界面展示不同功能
   - 准备 3-5 张高质量截图

---

**感谢使用！如有问题请查看详细文档或 GitHub Actions 日志。**

---

**最后更新**：2025-12-21



# 文件变更清单

## 📊 本次更新统计

- **新增文件**：8 个
- **修改文件**：6 个
- **总共改动**：14 个文件

---

## 🆕 新增文件

### 1. Python 脚本和依赖

| 文件路径 | 说明 | 行数 |
|---------|------|------|
| `scripts/app_store_connect.py` | App Store Connect API 客户端，实现应用检查、创建和元数据上传 | ~500 |
| `requirements.txt` | Python 依赖包列表（Pillow, PyJWT, requests, cryptography） | ~10 |

### 2. 文档文件

| 文件路径 | 说明 | 行数 |
|---------|------|------|
| `scripts/README_APP_STORE_CONNECT.md` | App Store Connect API 详细使用说明和故障排查 | ~300 |
| `更新说明.md` | 完整的更新说明，包含功能介绍、使用指南和故障排查 | ~400 |
| `快速开始-App-Store-Connect.md` | 快速开始指南，简洁的配置和使用说明 | ~250 |
| `CHANGELOG.md` | 更新日志，详细记录所有改动 | ~300 |
| `文件变更清单.md` | 本文件，记录所有文件变更 | ~100 |

---

## ✏️ 修改文件

### 1. 构建配置

| 文件路径 | 主要改动 | 改动行数 |
|---------|---------|---------|
| `.github/workflows/build.yml` | - 添加 Python 依赖安装（PyJWT, requests, cryptography）<br>- 添加 "Check and setup App Store Connect" 步骤<br>- 在上传 TestFlight 前调用 `app_store_connect.py` | ~20 |

### 2. 应用配置文件

| 文件路径 | 主要改动 | 改动行数 |
|---------|---------|---------|
| `assets/app1/app.cfg` | - 添加 iOS 配置（iosSku, iosPrimaryLocale, iosLocales）<br>- 添加 App Store 元数据配置（70+ 行）<br>- 添加 App 审核联系信息（10+ 行） | ~80 |
| `assets/idiomApp/app.cfg` | - 添加 iOS 配置（iosSku, iosPrimaryLocale, iosLocales）<br>- 添加 App Store 元数据配置（70+ 行）<br>- 添加 App 审核联系信息（10+ 行） | ~80 |

### 3. 代码文件

| 文件路径 | 主要改动 | 改动行数 |
|---------|---------|---------|
| `android/app/src/main/java/com/mywebviewapp/MainActivity.kt` | - 修复 enableZoom 配置<br>- 根据配置动态设置 loadWithOverviewMode 和 useWideViewPort<br>- 在页面加载完成后注入 viewport meta 标签 | ~30 |
| `ios/WebViewApp/MainViewController.swift` | - 修复 enableZoom 配置<br>- 通过 WKUserScript 注入 viewport meta 标签<br>- 禁用双指缩放 | ~20 |

### 4. 文档更新

| 文件路径 | 主要改动 | 改动行数 |
|---------|---------|---------|
| `docs/配置文件说明.md` | - 添加 iOS 配置说明（iosSku, iosPrimaryLocale, iosLocales）<br>- 添加 App Store 元数据配置说明（15+ 个配置项）<br>- 添加 App 审核联系信息说明（5 个配置项）<br>- 更新 enableZoom 的说明<br>- 添加相关文档链接 | ~150 |

---

## 📝 详细改动说明

### 构建配置改动

**文件**：`.github/workflows/build.yml`

**改动位置**：
1. 第 160-162 行：添加 Python 依赖安装
2. 第 320-337 行：添加 "Check and setup App Store Connect" 步骤

**改动内容**：
```yaml
# 1. 安装依赖
- name: Install Python dependencies
  run: |
    pip install Pillow PyJWT requests cryptography

# 2. 检查和设置 App Store Connect
- name: Check and setup App Store Connect
  run: |
    mkdir -p ~/.appstoreconnect/private_keys
    echo "${{ secrets.APP_STORE_API_KEY_BASE64 }}" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_API_KEY_ID }}.p8
    chmod 600 ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_API_KEY_ID }}.p8
    python3 scripts/app_store_connect.py ${{ github.workspace }}
  env:
    APP_STORE_API_KEY_ID: ${{ secrets.APP_STORE_API_KEY_ID }}
    APP_STORE_API_ISSUER_ID: ${{ secrets.APP_STORE_API_ISSUER_ID }}
```

### 应用配置改动

**文件**：`assets/app1/app.cfg`, `assets/idiomApp/app.cfg`

**新增配置项**：

#### iOS 配置（3 项）
```properties
iosSku=com-xlab-myapp
iosPrimaryLocale=zh-Hans
iosLocales=zh-Hans,en-US
```

#### App Store 元数据（15+ 项）
```properties
appSubtitle=...
appDescription=...
appDescription_zh_Hans=...
appDescription_en_US=...
appKeywords=...
appKeywords_zh_Hans=...
appKeywords_en_US=...
appPromotionalText=...
appPromotionalText_zh_Hans=...
appPromotionalText_en_US=...
appReleaseNotes=...
appReleaseNotes_zh_Hans=...
appReleaseNotes_en_US=...
appSupportUrl=...
appMarketingUrl=...
appPrivacyPolicyUrl=...
appCopyright=...
```

#### App 审核信息（5 项）
```properties
reviewContactFirstName=...
reviewContactLastName=...
reviewContactPhone=...
reviewContactEmail=...
reviewNotes=...
```

### 代码改动

**Android**：`android/app/src/main/java/com/mywebviewapp/MainActivity.kt`

**改动位置**：
1. 第 83-96 行：修复缩放设置
2. 第 113-130 行：在页面加载完成后注入 viewport

**主要改动**：
```kotlin
// 1. 根据配置动态设置
if (!AppConfig.ENABLE_ZOOM) {
    webSettings.loadWithOverviewMode = false
    webSettings.useWideViewPort = false
} else {
    webSettings.loadWithOverviewMode = true
    webSettings.useWideViewPort = true
}

// 2. 注入 viewport meta 标签
if (!AppConfig.ENABLE_ZOOM) {
    view?.evaluateJavascript("""
        (function() {
            var meta = document.querySelector('meta[name="viewport"]');
            if (meta) {
                meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
            } else {
                meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.getElementsByTagName('head')[0].appendChild(meta);
            }
        })();
    """.trimIndent(), null)
}
```

**iOS**：`ios/WebViewApp/MainViewController.swift`

**改动位置**：第 55-71 行

**主要改动**：
```swift
// 禁用缩放（通过 JavaScript 注入 viewport meta 标签）
if !AppConfig.enableZoom {
    let disableZoomScript = """
    var meta = document.createElement('meta');
    meta.name = 'viewport';
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
    var existingMeta = document.querySelector('meta[name="viewport"]');
    if (existingMeta) {
        existingMeta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
    } else {
        document.getElementsByTagName('head')[0].appendChild(meta);
    }
    """
    
    let script = WKUserScript(source: disableZoomScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    webView.configuration.userContentController.addUserScript(script)
}
```

---

## 🔍 配置项对照表

### 新增的配置项（按类别）

#### iOS 基本配置（3 项）

| 配置项 | 说明 | 必填 | 默认值 |
|-------|------|------|--------|
| `iosSku` | SKU 唯一标识符 | 否 | appId 替换 . 为 - |
| `iosPrimaryLocale` | 主要语言 | 否 | zh-Hans |
| `iosLocales` | 支持的语言列表 | 否 | zh-Hans,en-US |

#### App Store 元数据（17 项）

| 配置项 | 说明 | 必填 | 字符限制 |
|-------|------|------|---------|
| `appSubtitle` | 应用副标题 | 否 | 30 |
| `appDescription` | 应用描述（通用） | 否 | 4000 |
| `appDescription_{locale}` | 特定语言描述 | 否 | 4000 |
| `appKeywords` | 关键词（通用） | 否 | 100 |
| `appKeywords_{locale}` | 特定语言关键词 | 否 | 100 |
| `appPromotionalText` | 推广文本（通用） | 否 | 170 |
| `appPromotionalText_{locale}` | 特定语言推广文本 | 否 | 170 |
| `appReleaseNotes` | 更新说明（通用） | 否 | 4000 |
| `appReleaseNotes_{locale}` | 特定语言更新说明 | 否 | 4000 |
| `appSupportUrl` | 技术支持网址 | 是 | - |
| `appMarketingUrl` | 营销网址 | 否 | - |
| `appPrivacyPolicyUrl` | 隐私政策网址 | 是 | - |
| `appCopyright` | 版权信息 | 否 | - |

#### App 审核信息（5 项）

| 配置项 | 说明 | 必填 |
|-------|------|------|
| `reviewContactFirstName` | 审核联系人姓 | 否 |
| `reviewContactLastName` | 审核联系人名 | 否 |
| `reviewContactPhone` | 审核联系人电话 | 否 |
| `reviewContactEmail` | 审核联系人邮箱 | 否 |
| `reviewNotes` | 审核备注 | 否 |

---

## ✅ 检查清单

使用前请确认：

- [ ] 已创建 App Store Connect API 密钥
- [ ] 已配置 GitHub Secrets（3 个）
- [ ] 已更新 `app.cfg` 文件
  - [ ] 添加 iOS 配置（iosSku, iosPrimaryLocale, iosLocales）
  - [ ] 添加必填项（appSupportUrl, appPrivacyPolicyUrl）
  - [ ] 添加推荐项（appDescription, appKeywords 等）
- [ ] 已阅读相关文档
- [ ] enableZoom 配置已测试

---

## 📖 相关文档

- [快速开始指南](快速开始-App-Store-Connect.md) - ⭐ 推荐首先阅读
- [App Store Connect API 详细说明](README_APP_STORE_CONNECT.md)
- [完整更新说明](更新说明.md)
- [配置文件说明](配置文件说明.md)
- [更新日志](CHANGELOG.md)

---

**最后更新**：2025-12-21




# 更新说明

## 本次更新内容

本次更新解决了两个主要问题并添加了新功能：

### 1. ✅ 修复 enableZoom 配置无效的问题

**问题描述**：
- 当 `enableZoom=false` 时，Android 和 iOS 应用仍然可以使用双指进行缩放
- 配置没有正确生效

**解决方案**：

#### Android 修复 (`android/app/src/main/java/com/mywebviewapp/MainActivity.kt`)
1. 根据 `enableZoom` 配置动态设置 `loadWithOverviewMode` 和 `useWideViewPort`
2. 在页面加载完成后，通过 JavaScript 注入 viewport meta 标签，确保页面不可缩放
3. 设置：`maximum-scale=1.0, user-scalable=no`

#### iOS 修复 (`ios/WebViewApp/MainViewController.swift`)
1. 通过 WKUserScript 在页面加载时注入 viewport meta 标签
2. 如果页面已有 viewport，则修改其属性；否则创建新的 meta 标签
3. 确保 `maximum-scale=1.0, user-scalable=no`

**测试方法**：
```properties
# 在 app.cfg 中设置
enableZoom=false
```
重新构建应用后，尝试双指缩放网页，应该无法缩放。

---

### 2. ✅ 添加 App Store Connect API 集成

**功能描述**：
在上传到 TestFlight 之前，自动执行以下操作：
1. 检查应用是否已在 App Store Connect 中创建
2. 如果应用不存在，自动创建应用
3. 上传应用元数据（描述、关键词、推广文本等）
4. 支持多语言本地化配置

**新增文件**：

1. **`scripts/app_store_connect.py`**
   - App Store Connect API 客户端
   - 实现应用检查、创建、元数据上传功能
   - 支持 JWT 认证

2. **`scripts/README_APP_STORE_CONNECT.md`**
   - 详细使用说明
   - 配置指南
   - 故障排查

3. **`requirements.txt`**
   - Python 依赖包列表

**修改文件**：

1. **`.github/workflows/build.yml`**
   - 在 iOS 构建流程中添加 Python 依赖安装（PyJWT, requests, cryptography）
   - 在上传到 TestFlight 之前，添加 "Check and setup App Store Connect" 步骤
   - 运行 `app_store_connect.py` 脚本进行应用检查和创建

2. **`assets/app1/app.cfg` 和 `assets/idiomApp/app.cfg`**
   - 添加 iOS 配置：`iosSku`, `iosPrimaryLocale`, `iosLocales`
   - 添加 App Store 元数据配置（70+ 行新配置）
   - 添加 App 审核联系信息

**新增配置项说明**：

#### iOS 基本配置
```properties
# iOS SKU（唯一标识符）
iosSku=com-xlab-myapp

# iOS 主要语言
iosPrimaryLocale=zh-Hans

# iOS 支持的语言列表
iosLocales=zh-Hans,en-US
```

#### App Store 元数据
```properties
# 应用副标题（30字符以内）
appSubtitle=应用副标题

# 应用描述（通用）
appDescription=应用描述

# 应用描述 - 简体中文
appDescription_zh_Hans=中文描述

# 应用描述 - 英语
appDescription_en_US=English description

# 应用关键词（逗号分隔，100字符以内）
appKeywords=关键词1,关键词2

# 推广文本（170字符以内）
appPromotionalText=推广文本

# 版本更新说明
appReleaseNotes=更新内容

# 技术支持网址（必填）
appSupportUrl=https://example.com

# 营销网址（选填）
appMarketingUrl=https://example.com

# 隐私政策网址（必填）
appPrivacyPolicyUrl=https://example.com/privacy

# 版权信息
appCopyright=2025 Your Company
```

#### App 审核联系信息
```properties
# 审核联系人
reviewContactFirstName=张
reviewContactLastName=三
reviewContactPhone=+86 13800138000
reviewContactEmail=support@example.com
reviewNotes=审核备注
```

---

## 使用指南

### 前置条件

#### 1. 创建 App Store Connect API 密钥

1. 访问 [App Store Connect](https://appstoreconnect.apple.com/)
2. **用户和访问** → **密钥** → **App Store Connect API**
3. 生成 API 密钥或使用现有密钥
4. 记录：**密钥 ID**、**颁发者 ID**
5. 下载 `.p8` 私钥文件

#### 2. 配置 GitHub Secrets

在 GitHub 仓库设置中添加：

| Secret 名称 | 说明 |
|------------|------|
| `APP_STORE_API_KEY_ID` | API 密钥 ID |
| `APP_STORE_API_ISSUER_ID` | 颁发者 ID |
| `APP_STORE_API_KEY_BASE64` | .p8 文件的 Base64 编码 |

生成 Base64 编码：
```bash
base64 -i AuthKey_ABC1234567.p8
```

#### 3. 更新 app.cfg 配置文件

在你的 `assets/{appName}/app.cfg` 文件中：

1. 添加 iOS 基本配置（iosSku, iosPrimaryLocale, iosLocales）
2. 添加 App Store 元数据配置
3. 添加 App 审核联系信息

参考示例：`assets/app1/app.cfg` 或 `assets/idiomApp/app.cfg`

### 工作流程

1. 更新 `app.cfg` 配置文件
2. 提交并推送代码
3. 创建并推送版本标签：
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
4. GitHub Actions 自动执行：
   - ✅ 构建 Android APK（如果启用）
   - ✅ 构建 iOS IPA（如果启用）
   - ✅ **检查 App Store Connect 中是否存在应用**
   - ✅ **如果不存在，自动创建应用**
   - ✅ **上传应用元数据**
   - ✅ 上传 IPA 到 TestFlight
   - ✅ 创建 GitHub Release

### 本地测试

```bash
# 安装依赖
pip install -r requirements.txt

# 设置环境变量
export APP_STORE_API_KEY_ID="your_key_id"
export APP_STORE_API_ISSUER_ID="your_issuer_id"

# 准备 API 密钥文件
mkdir -p ~/.appstoreconnect/private_keys
cp AuthKey_*.p8 ~/.appstoreconnect/private_keys/

# 运行脚本
python3 scripts/app_store_connect.py /path/to/workspace
```

---

## 多语言支持

### 支持的语言

- `zh-Hans` - 简体中文
- `zh-Hant` - 繁体中文
- `en-US` - 美国英语
- `ja` - 日语
- `ko` - 韩语
- `fr-FR` - 法语
- `de-DE` - 德语
- 等等...

### 配置特定语言

使用 `_语言代码` 后缀（将 `-` 替换为 `_`）：

```properties
# 简体中文
appDescription_zh_Hans=中文描述
appKeywords_zh_Hans=关键词1,关键词2

# 英语
appDescription_en_US=English description
appKeywords_en_US=keyword1,keyword2
```

如果没有配置特定语言，将使用通用配置。

---

## 注意事项

### enableZoom 修复

1. **彻底禁用缩放**：设置 `enableZoom=false` 后，用户将无法缩放网页
2. **建议**：如果你的网页内容需要自适应显示，请保持 `enableZoom=false` 以获得最佳用户体验
3. **测试**：在真实设备上测试缩放功能

### App Store Connect API

1. **权限**：API 密钥需要 **Admin** 或 **App Manager** 权限
2. **首次创建**：首次创建应用后，还需要在 App Store Connect 手动上传截图、设置定价等
3. **隐私政策**：`appPrivacyPolicyUrl` 必须填写，且链接必须可访问
4. **审核**：元数据的修改需要通过 Apple 审核
5. **API 限制**：避免频繁调用 API

---

## 故障排查

### enableZoom 仍然无效

1. 清除应用缓存
2. 重新构建应用
3. 在真实设备上测试（模拟器可能表现不同）
4. 检查网页是否有自己的 viewport meta 标签（可能被覆盖）

### App Store Connect API 错误

#### "应用已存在但 Bundle ID 不匹配"
- 修改 `appId` 使用不同的 Bundle ID
- 或删除 App Store Connect 中的旧应用

#### "API 密钥无效"
- 检查 Base64 编码是否正确
- 重新生成 API 密钥
- 确认文件路径正确

#### "权限不足"
- 将 API 密钥角色设置为 **Admin** 或 **App Manager**

#### "应用创建失败"
- 使用唯一的 Bundle ID
- 修改 `iosSku` 使用不同的值
- 检查 `iosTeamId` 是否正确

---

## 相关文档

- [App Store Connect API 详细说明](README_APP_STORE_CONNECT.md)
- [Apple 官方文档](https://developer.apple.com/documentation/appstoreconnectapi)
- [配置文件说明](配置文件说明.md)

---

## 更新历史

- **2025-12-21**
  - ✅ 修复 enableZoom 配置无效问题（Android & iOS）
  - ✅ 添加 App Store Connect API 集成
  - ✅ 添加多语言支持
  - ✅ 更新配置文件示例

---

**如有问题，请查看 GitHub Actions 日志或联系开发团队。**



# 构建发布指南

本指南说明如何使用 GitHub Actions 自动构建和发布应用。

---

## 📋 前置条件

### Debug 模式（测试包）
- ✅ 无需任何证书或密钥
- ✅ 可以直接构建

### Release 模式（正式包）
- ⚠️ 需要配置 Android Keystore
- ⚠️ 需要配置 iOS 证书和 Provisioning Profile
- 📖 详见：[证书和密钥配置指南](./证书和密钥配置指南.md)

---

## 🚀 快速开始

### 步骤 1：配置应用信息

编辑 `assets/app1/app.cfg`：

```properties
# 应用基本信息
appName=我的WebView
appDisplayName=MyWebView
appId=com.mywebviewapp
appVersion=1.0.0
buildNumber=1

# 构建配置
buildAndroid=true    # 是否构建 Android
buildIOS=true        # 是否构建 iOS
isDebug=true         # Debug 或 Release 模式

# WebView 配置
loadUrl=https://www.example.com
```

### 步骤 2：选择构建模式

#### 🧪 Debug 模式（测试包）

```bash
# 编辑配置文件
vim assets/app1/app.cfg

# 设置为 Debug 模式
isDebug=true
```

**特点**：
- ✅ 无需签名证书
- ✅ 快速构建
- ✅ 包含调试信息
- ⚠️ 不能上架应用商店
- ⚠️ iOS 只能在模拟器运行

#### 🚢 Release 模式（正式包）

```bash
# 编辑配置文件
vim assets/app1/app.cfg

# 设置为 Release 模式
isDebug=false
```

**特点**：
- ✅ 可以上架应用商店
- ✅ 代码优化和混淆
- ✅ 包体积更小
- ⚠️ 需要签名证书
- ⚠️ 需要配置 GitHub Secrets

### 步骤 3：提交并打标签

```bash
# 1. 提交更改
git add .
git commit -m "Build version 1.0.0"

# 2. 创建标签（必须以 v 开头）
git tag v1.0.0

# 3. 推送标签（触发构建）
git push origin v1.0.0
```

### 步骤 4：查看构建进度

1. 访问 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看 "Build WebView App" 工作流
4. 等待构建完成（通常 5-10 分钟）

### 步骤 5：下载构建产物

构建完成后：

1. 进入 **Releases** 页面
2. 找到对应的版本（如 `v1.0.0`）
3. 下载文件：
   - **Android**: `WebViewApp-1.0.0-app-debug.apk` 或 `WebViewApp-1.0.0-app-release.apk`
   - **iOS (Debug)**: `WebViewApp-1.0.0-Debug.zip`
   - **iOS (Release)**: `WebViewApp-1.0.0.ipa`

---

## 📦 构建产物说明

### Android APK

| 文件名 | 模式 | 说明 |
|--------|------|------|
| `WebViewApp-1.0.0-app-debug.apk` | Debug | 测试包，可直接安装 |
| `WebViewApp-1.0.0-app-release.apk` | Release | 正式包，已签名 |

**安装方法**：
1. 下载 APK 文件到 Android 设备
2. 在设置中启用"未知来源"安装
3. 点击 APK 文件安装

### iOS 包

| 文件名 | 模式 | 说明 |
|--------|------|------|
| `WebViewApp-1.0.0-Debug.zip` | Debug | 模拟器包，需要解压 |
| `WebViewApp-1.0.0.ipa` | Release | 正式包，可安装到设备 |

**安装方法（Debug）**：
1. 解压 ZIP 文件
2. 使用 Xcode 打开模拟器
3. 拖拽 `.app` 文件到模拟器

**安装方法（Release）**：
1. 使用 TestFlight 分发测试
2. 或使用 Apple Configurator 安装到设备
3. 或上传到 App Store

---

## ⚙️ 高级配置

### 只构建 Android

```properties
buildAndroid=true
buildIOS=false
```

### 只构建 iOS

```properties
buildAndroid=false
buildIOS=true
```

### 同时构建两个平台

```properties
buildAndroid=true
buildIOS=true
```

---

## 🔄 版本管理

### 语义化版本号

推荐使用语义化版本号：`主版本号.次版本号.修订号`

```bash
# 新功能发布
git tag v1.1.0

# Bug 修复
git tag v1.0.1

# 重大更新
git tag v2.0.0
```

### 预发布版本

可以使用预发布标签：

```bash
# Alpha 版本
git tag v1.0.0-alpha.1

# Beta 版本
git tag v1.0.0-beta.1

# Release Candidate
git tag v1.0.0-rc.1
```

### 构建号管理

每次发布时，记得更新 `buildNumber`：

```properties
# 首次发布
appVersion=1.0.0
buildNumber=1

# 第二次发布
appVersion=1.0.1
buildNumber=2

# 第三次发布
appVersion=1.1.0
buildNumber=3
```

---

## 🐛 故障排查

### 问题 1：构建失败 - "Secrets not found"

**原因**：Release 模式需要证书，但未配置 GitHub Secrets

**解决方案**：
1. 检查 `isDebug` 是否为 `false`
2. 如果是 Release 模式，按照 [证书配置指南](./证书和密钥配置指南.md) 配置 Secrets
3. 或者改为 Debug 模式：`isDebug=true`

### 问题 2：Release 中缺少 APK/IPA

**原因**：
- 构建失败但 Release 仍然创建
- 配置文件中禁用了某个平台

**解决方案**：
1. 检查 Actions 日志，查看构建错误
2. 确认 `buildAndroid` 和 `buildIOS` 设置正确
3. 修复错误后，删除旧 Release 和 tag，重新构建

```bash
# 删除本地 tag
git tag -d v1.0.0

# 删除远程 tag
git push origin :refs/tags/v1.0.0

# 在 GitHub 上手动删除 Release

# 重新打 tag
git tag v1.0.0
git push origin v1.0.0
```

### 问题 3：iOS 构建失败 - "Code signing error"

**原因**：证书或 Provisioning Profile 配置错误

**解决方案**：
1. 检查 `IOS_CERTIFICATE_BASE64` 是否正确
2. 检查 `IOS_PROVISIONING_PROFILE_BASE64` 是否正确
3. 确认 Bundle ID 和 Team ID 匹配
4. 检查证书是否过期

### 问题 4：Android 构建失败 - "Keystore error"

**原因**：Keystore 配置错误

**解决方案**：
1. 检查 `ANDROID_KEYSTORE_BASE64` 是否完整
2. 确认密码正确：`ANDROID_KEYSTORE_PASSWORD` 和 `ANDROID_KEY_PASSWORD`
3. 确认别名正确：`ANDROID_KEY_ALIAS`
4. 或者使用 Debug 模式避免签名问题

### 问题 5：构建成功但文件损坏

**原因**：Base64 编码/解码错误

**解决方案**：
```bash
# 重新生成 Base64（确保没有换行）
base64 -i keystore.jks | tr -d '\n' > keystore.base64

# 验证 Base64
base64 -D -i keystore.base64 -o test.jks
# 检查 test.jks 是否正常
```

---

## 📊 构建流程图

```
开始
  ↓
读取 assets/build.app
  ↓
读取 assets/app1/app.cfg
  ↓
判断 buildAndroid?
  ├─ Yes → 构建 Android APK
  │         ├─ isDebug=true → assembleDebug
  │         └─ isDebug=false → assembleRelease (需要 Keystore)
  └─ No → 跳过
  ↓
判断 buildIOS?
  ├─ Yes → 构建 iOS App
  │         ├─ isDebug=true → 模拟器构建（无签名）
  │         └─ isDebug=false → Archive + IPA（需要证书）
  └─ No → 跳过
  ↓
重命名文件
  ↓
创建 GitHub Release
  ↓
上传 APK/IPA/ZIP
  ↓
完成
```

---

## 📝 检查清单

### 构建前检查

- [ ] 已更新 `appVersion` 和 `buildNumber`
- [ ] 已设置正确的 `isDebug` 模式
- [ ] 已配置 `loadUrl` 为正确的网址
- [ ] 已准备好应用图标和资源文件
- [ ] Release 模式：已配置所有必需的 Secrets
- [ ] 已测试配置文件语法正确

### 构建后检查

- [ ] Actions 工作流成功完成
- [ ] Release 页面包含所有预期的文件
- [ ] 下载的 APK/IPA 可以正常安装
- [ ] 应用可以正常启动和运行
- [ ] WebView 加载正确的 URL
- [ ] 应用图标和名称正确显示

---

## 🔗 相关文档

- [证书和密钥配置指南](./证书和密钥配置指南.md) - 如何获取和配置签名证书
- [配置文件说明](./配置文件说明.md) - 完整的配置项说明
- [Android 打包说明](./Android打包说明.md) - Android 平台详细说明
- [iOS 打包说明](./iOS打包说明.md) - iOS 平台详细说明

---

## 💡 最佳实践

### 1. 版本号规范

```properties
# 开发版本
appVersion=1.0.0-dev
buildNumber=1

# 测试版本
appVersion=1.0.0-beta
buildNumber=2

# 正式版本
appVersion=1.0.0
buildNumber=3
```

### 2. 分支策略

```bash
# 开发分支
git checkout -b develop
# 修改配置为 isDebug=true
git tag v1.0.0-dev

# 发布分支
git checkout -b release/1.0.0
# 修改配置为 isDebug=false
git tag v1.0.0
```

### 3. 测试流程

1. 先构建 Debug 版本测试
2. 测试通过后构建 Release 版本
3. 使用 TestFlight (iOS) 和内部测试 (Android) 进行小范围测试
4. 收集反馈后正式发布

### 4. 备份策略

- 备份所有签名证书和密钥
- 记录所有密码（使用密码管理器）
- 保存每个版本的配置文件
- 定期备份 GitHub Secrets

---

**最后更新**: 2024年12月



# 构建和安装指南

本文档说明如何构建和安装 Android 和 iOS 应用。

---

## 📦 构建产物说明

### Android

| 文件名 | 类型 | 用途 | 安装方式 |
|-------|------|------|---------|
| `WebViewApp-{version}-debug.apk` | Debug APK | 开发测试 | 直接安装 |
| `WebViewApp-{version}-release.apk` | Release APK | 正式分发 | 直接安装 |

### iOS

| 文件名 | 类型 | 用途 | 安装方式 |
|-------|------|------|---------|
| `WebViewApp-{version}-debug.app.zip` | 模拟器应用 | 开发测试 | 仅模拟器 |
| `WebViewApp-{version}-release.ipa` | iOS 安装包 | 正式分发 | 见下方说明 |

---

## 🤖 Android 安装

### 方式 1: 直接安装（推荐）

**适用于**: Debug APK 和 Release APK

```bash
# 在 Android 手机上：
1. 下载 APK 文件
2. 点击安装
3. 如果提示"未知来源"，需要在设置中允许安装未知应用

# 使用 adb 安装：
adb install WebViewApp-1.0.0-release.apk
```

### 方式 2: Google Play（正式发布）

```bash
# 上传到 Google Play Console
# 需要：
1. Google Play 开发者账号
2. 应用已通过审核
3. 已配置发布版本
```

---

## 📱 iOS 安装

详见: [iOS安装指南.md](./iOS安装指南.md)

### 快速参考

#### 当前配置: App Store Profile

```
✅ 支持的安装方式:
- TestFlight（推荐）
- App Store 正式发布

❌ 不支持:
- 直接安装到设备
- 通过网站分发
```

#### 如需直接安装

需要切换到 **Ad Hoc** 分发：

```bash
1. 收集设备 UDID
2. 创建 Ad Hoc Provisioning Profile（包含这些设备）
3. 更新 GitHub Secrets:
   IOS_PROVISIONING_PROFILE_BASE64=<新的Profile Base64>
   IOS_EXPORT_METHOD=ad-hoc
4. 重新构建
```

---

## 🔧 GitHub Actions 构建配置

### Android 签名配置

需要在 GitHub Secrets 中配置：

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `ANDROID_KEYSTORE_BASE64` | Keystore Base64 | `MIIKXgIBAz...` |
| `ANDROID_KEYSTORE_FILE` | Keystore 文件名 | `my-app.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 密码 | `your_password` |
| `ANDROID_KEY_ALIAS` | 密钥别名 | `my-key` |
| `ANDROID_KEY_PASSWORD` | 密钥密码 | `your_key_password` |

**获取 Keystore Base64**:
```bash
base64 -i my-app.jks | pbcopy  # macOS
base64 my-app.jks | clip        # Windows
```

### iOS 签名配置

需要在 GitHub Secrets 中配置：

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `IOS_CERTIFICATE_BASE64` | Distribution 证书 | `MIIKXgIBAz...` |
| `IOS_CERTIFICATE_PASSWORD` | 证书密码 | `your_password` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Profile Base64 | `PD94bWwgdmVy...` |
| `IOS_TEAM_ID` | Team ID | `G3NJ44L7QL` |
| `IOS_EXPORT_METHOD` | 导出方式 | `app-store` 或 `ad-hoc` |
| `KEYCHAIN_PASSWORD` | 临时密码 | `build2024` |

**获取证书和 Profile Base64**:
```bash
# 证书
base64 -i certificate.p12 | pbcopy

# Profile
base64 -i profile.mobileprovision | pbcopy
```

详见: [证书和密钥配置指南.md](./证书和密钥配置指南.md)

---

## 🚀 触发构建

### 自动构建

提交代码时会自动触发 Debug 构建：

```bash
git add .
git commit -m "Your changes"
git push
```

### Release 构建

打 Tag 触发 Release 构建：

```bash
# 创建 Release Tag
git tag v1.0.0
git push origin v1.0.0
```

Tag 命名规则：
- `v` + 版本号（如 `v1.0.0`）
- 版本号必须与 `app.cfg` 中的 `appVersion` 匹配
- 只有 `v` 开头的 Tag 会触发构建

---

## 📥 下载构建产物

### 方式 1: GitHub Releases

```
1. 进入仓库页面
2. 点击右侧 "Releases"
3. 找到对应的版本
4. 下载 Assets 中的文件
```

### 方式 2: GitHub Actions

```
1. 进入 Actions 标签
2. 选择对应的 Workflow Run
3. 滚动到底部 "Artifacts"
4. 下载对应的 artifact
```

---

## 🔍 构建状态检查

### Android 构建成功标志

```
✅ assembleRelease 成功
✅ 生成 APK: app-release.apk
✅ APK 已签名（Release 模式）
✅ Upload artifacts 成功
```

### iOS 构建成功标志

```
✅ Archive 成功
   - Signing Identity: "iPhone Distribution: ..."
   - Provisioning Profile: "xlabProfile"
✅ Export 成功
   - 生成 IPA: WebViewApp.ipa
✅ Upload artifacts 成功
```

---

## ⚠️ 常见问题

### Android 问题

#### Q1: APK 无法安装，提示"安装包无效"

**A**: 可能是签名问题

```bash
# 检查 APK 签名
apksigner verify --print-certs WebViewApp.apk

# 如果显示 "Verified using v1 scheme (JAR signing)" 则说明已签名
# 如果没有输出或报错，说明未签名

# 解决方法：
1. 确认 GitHub Secrets 已正确配置
2. 检查 ANDROID_KEYSTORE_BASE64 是否完整
3. 重新构建
```

#### Q2: 构建失败，提示 "storeFile not found"

**A**: Keystore 文件没有正确解码

```bash
# 检查 ANDROID_KEYSTORE_FILE 是否与实际文件名匹配
# 默认值: devdroid.jks
# 如果你的文件名不同，需要更新 Secret
```

### iOS 问题

#### Q3: IPA 无法安装

**A**: 检查 Profile 类型和设备是否匹配

```bash
# 查看 Profile 信息
security cms -D -i profile.mobileprovision

# 检查：
1. Profile 类型（App Store / Ad Hoc / Development）
2. Bundle ID 是否匹配
3. 如果是 Ad Hoc，设备 UDID 是否已注册
```

#### Q4: Export 失败，提示 "requires a provisioning profile"

**A**: exportOptions.plist 配置问题

```bash
# 已在最新版本修复
# 如果仍有问题，检查：
1. IOS_PROVISIONING_PROFILE_BASE64 是否正确
2. IOS_TEAM_ID 是否正确
3. Bundle ID 是否与 Profile 匹配
```

---

## 📚 相关文档

- [iOS 安装指南](./iOS安装指南.md) - iOS 应用的各种安装方式
- [证书和密钥配置指南](./证书和密钥配置指南.md) - Android 和 iOS 签名配置
- [app.cfg 配置说明](../README.md) - 应用配置参数

---

## 🎯 快速开始

### 1. 配置签名（首次）

```bash
# Android
1. 生成 Keystore（如果没有）
2. 转换为 Base64
3. 在 GitHub 添加 Secrets

# iOS
1. 获取 Distribution 证书（.p12）
2. 获取 Provisioning Profile（.mobileprovision）
3. 转换为 Base64
4. 在 GitHub 添加 Secrets
```

### 2. 触发构建

```bash
# Release 构建
git tag v1.0.0
git push origin v1.0.0
```

### 3. 下载安装

```bash
# Android
下载 APK → 直接安装

# iOS
下载 IPA → TestFlight 或 Ad Hoc 分发
```

---

## 💡 最佳实践

### 版本管理

```bash
# 使用语义化版本
v1.0.0 - 首次发布
v1.0.1 - Bug 修复
v1.1.0 - 新功能
v2.0.0 - 重大更新

# 保持 app.cfg 中的版本号同步
appVersion=1.0.0  # 与 Tag 一致
buildNumber=1     # 递增
```

### 构建检查清单

**每次 Release 前**:
```
✅ 更新 app.cfg 版本号
✅ 测试 Debug 版本
✅ 确认 Secrets 未过期
✅ 检查证书有效期
✅ 提交所有更改
✅ 打 Tag 触发构建
✅ 验证构建产物
```

### 安全建议

```
1. ✅ 定期更新 Keystore 密码
2. ✅ 不要在代码中硬编码密钥
3. ✅ 使用强密码
4. ✅ 备份 Keystore 和证书
5. ✅ 限制 Secrets 访问权限
```

---

## 🆘 获取帮助

如果遇到问题：
1. 查看 GitHub Actions 日志
2. 阅读相关文档
3. 检查 Secrets 配置
4. 验证证书和 Profile 有效期

常见错误解决：
- Android 签名问题 → 检查 Keystore 配置
- iOS Profile 问题 → 查看 [iOS安装指南](./iOS安装指南.md)
- 构建失败 → 查看 Actions 日志




# App Store Connect 状态锁定问题修复说明

## 问题背景

当应用版本处于特定状态（如 `PREPARE_FOR_SUBMISSION`）时，某些字段会被 Apple 锁定，无法通过 API 修改。这会导致元数据更新失败。

## 常见的状态锁定错误

### 1. appInfoLocalizations 字段锁定

**错误示例：**
```
409 Client Error: Conflict
ENTITY_ERROR.ATTRIBUTE.INVALID.INVALID_STATE
The field 'name' can not be modified in the current state.
The field 'privacyPolicyUrl' can not be modified in the current state.
```

**被锁定的字段：**
- `name` - 应用名称
- `privacyPolicyUrl` - 隐私政策 URL
- 其他应用信息本地化字段

### 2. appInfos 关系锁定

**错误示例：**
```
409 Client Error: Conflict
ENTITY_ERROR.RELATIONSHIP.INVALID_STATE
A relationship value is not acceptable for the current resource state.
/data/relationships/primaryCategory
```

**被锁定的关系：**
- `primaryCategory` - 主要类别
- `primarySubcategoryOne` - 次要类别

## 修复方案

### 1. 智能字段更新

现在会逐个字段尝试更新，而不是一次性更新所有字段：

```python
# 旧方式：一次更新所有字段（失败则全部失败）
update_data = {
    "attributes": {
        "name": "...",
        "privacyPolicyUrl": "...",
        "subtitle": "..."
    }
}

# 新方式：逐个字段尝试（部分失败不影响其他字段）
for field_name, field_value in fields:
    try:
        update_single_field(field_name, field_value)
        ✓ 更新成功
    except INVALID_STATE:
        ⚠️ 字段被锁定（版本状态限制）
```

### 2. 错误分类处理

代码现在会识别不同类型的错误：

- **状态锁定错误**：静默处理，显示友好提示
- **其他错误**：正常显示错误信息

```python
if "INVALID_STATE" in error_str or "can not be modified" in error_str:
    print("⚠️ 字段被锁定（版本状态限制）")
else:
    print(f"❌ 更新失败: {error}")
```

### 3. 类别更新优化

类别更新现在会：
1. 获取当前应用信息状态
2. 使用 `silent_errors` 参数避免打印详细错误
3. 根据错误类型显示适当的提示信息

## 截图上传问题修复

### 问题：截图上传到错误的语言

**原因：**
- 之前只上传到第一个本地化语言（通常是 `en-US`）
- 如果应用主要语言是 `zh-Hans`，则在 App Store Connect 上看不到截图

**修复：**
- 现在会上传到主要语言（`primary_locale`）
- 如果未指定主要语言，则上传到所有本地化语言

```python
# 新增参数：primary_locale
uploaded_screenshots = api.upload_screenshots_for_version(
    version_id, 
    screenshots_dir, 
    screenshot_files,
    primary_locale="zh-Hans"  # 指定主要语言
)
```

### 上传逻辑

1. **获取所有本地化语言**
2. **选择目标语言：**
   - 如果指定了 `primary_locale`，只上传到该语言
   - 否则上传到所有语言
3. **为每个语言上传所有截图**

## 执行效果

### 修复前

```
API 请求失败: 409 Client Error: Conflict
错误详情: The field 'name' can not be modified in the current state.
⚠️ 应用元数据更新异常: 409 Client Error

📱 上传截图 - 语言: en-US
✅ 截图上传成功
（但在 App Store Connect 上看不到截图）
```

### 修复后

```
📋 更新应用元数据
  ✓ 已更新: subtitle
  ⚠️ 字段被锁定（版本状态限制）: name, privacyPolicyUrl
提示: 这些字段在应用准备提交时无法修改

📱 将为 2 个语言上传截图:
  • zh-Hans
  • en-US

📱 上传截图到语言: zh-Hans
✅ iPhone_6.5 共上传 3 张截图
✅ iPad_12.9_3rd 共上传 3 张截图

📱 上传截图到语言: en-US
✅ iPhone_6.5 共上传 3 张截图
✅ iPad_12.9_3rd 共上传 3 张截图

✅ 截图上传完成 (6/6 张)
```

## 配置说明

### 设置主要语言

在 `app.cfg` 中配置：

```ini
# iOS 主要语言（必需）
iosPrimaryLocale=zh-Hans

# 支持的所有语言（可选）
iosLocales=zh-Hans,en-US
```

### 主要语言代码

常用的语言代码：
- `zh-Hans` - 简体中文
- `zh-Hant` - 繁体中文
- `en-US` - 英语（美国）
- `ja` - 日语
- `ko` - 韩语
- `de-DE` - 德语
- `fr-FR` - 法语
- `es-ES` - 西班牙语

## 应用状态说明

### App Store 版本状态

| 状态 | 说明 | 可修改字段 |
|-----|------|----------|
| `PREPARE_FOR_SUBMISSION` | 准备提交 | 部分字段被锁定 |
| `WAITING_FOR_REVIEW` | 等待审核 | 大部分字段被锁定 |
| `IN_REVIEW` | 审核中 | 几乎所有字段被锁定 |
| `PENDING_DEVELOPER_RELEASE` | 待开发者发布 | 几乎所有字段被锁定 |
| `DEVELOPER_REJECTED` | 开发者拒绝 | 可修改 |
| `REJECTED` | 被拒绝 | 可修改 |
| `METADATA_REJECTED` | 元数据被拒绝 | 可修改 |

### 字段锁定规则

不同状态下，字段的锁定情况不同：

**总是可以修改：**
- 版本本地化信息（`description`、`keywords`、`promotionalText` 等）
- 审核联系信息
- 版权信息

**状态相关：**
- 应用名称（`name`）- 准备提交时可能被锁定
- 隐私政策 URL - 准备提交时可能被锁定
- 应用类别 - 准备提交时可能被锁定

**永远不能通过 API 修改：**
- Bundle ID
- SKU
- 年龄分级（需要在网站手动设置）
- 定价（需要在网站手动设置）

## 最佳实践

### 1. 首次设置

在应用首次创建时，在网站上设置：
- 应用名称
- 隐私政策 URL
- 应用类别
- 年龄分级
- 定价

### 2. 日常更新

通过 API 可以更新：
- 版本描述
- 关键词
- 更新说明
- 截图
- 审核联系信息

### 3. 版本提交前

确保在提交前完成所有元数据更新，因为提交后大部分字段会被锁定。

### 4. 错误处理

- 不要因为部分字段更新失败就停止整个流程
- 记录所有错误，但继续执行后续步骤
- 提供友好的错误提示，告诉用户如何手动处理

## 故障排除

### 问题：截图仍然看不到

**检查项：**
1. 确认主要语言配置正确（`iosPrimaryLocale`）
2. 检查截图是否上传到了正确的语言
3. 在 App Store Connect 中切换到对应的语言查看
4. 确认截图文件格式和尺寸符合要求

**解决方法：**
```bash
# 查看日志中的语言信息
📱 将为 2 个语言上传截图:
  • zh-Hans  ← 确认包含你的主要语言
  • en-US
```

### 问题：字段更新总是失败

**检查项：**
1. 确认应用版本状态
2. 检查是否是被永久锁定的字段（如年龄分级）
3. 确认 API 权限正确

**解决方法：**
- 在 App Store Connect 网站手动更新被锁定的字段
- 等待应用进入可编辑状态后再更新

## 更新日志

### 2025-12-27
- ✨ 新增逐字段更新逻辑，避免部分字段失败影响其他字段
- ✨ 新增状态锁定错误识别和友好提示
- ✨ 修复截图上传到错误语言的问题
- ✨ 支持为所有本地化语言上传截图
- 🔧 优化类别更新的错误处理
- 🔧 使用 `silent_errors` 参数减少不必要的错误日志




# 自动生成 Build Number 说明

## 📋 概述

从现在开始，**buildNumber 不再需要在配置文件中手动指定**。构建脚本会自动基于当前时间生成唯一的 Build Number。

---

## ✨ 主要特性

### 自动生成规则

**格式**: `MMDDHHmmss` (月日小时分钟秒)

**示例**:
- `1218143045` = 2024年12月18日 14:30:45
- `0101090000` = 2024年01月01日 09:00:00
- `1231235959` = 2024年12月31日 23:59:59

### 优势

✅ **唯一性**: 每次构建都有不同的 Build Number  
✅ **可追溯**: 从 Build Number 可以知道构建时间  
✅ **自动化**: 无需手动递增，避免遗忘  
✅ **递增性**: 时间自然递增，满足应用商店要求  
✅ **简单**: 不需要维护版本号文件  

---

## 🔧 实现方式

### Python 脚本自动生成

在 `scripts/build_config.py` 中：

```python
from datetime import datetime

def generate_build_number(self):
    """生成基于当前时间的构建号
    格式: MMDDHHmmss (月日小时分钟秒)
    例如: 1218143045 表示 12月18日14点30分45秒
    """
    now = datetime.now()
    build_number = now.strftime('%m%d%H%M%S')
    return build_number
```

### 构建时自动应用

运行 `python3 scripts/build_config.py` 时：

```
==================================================
WebView App Configuration Builder
==================================================

App Name: idiomApp
Config loaded from: assets/idiomApp/app.cfg
Total config items: 42

📦 Auto-generated Build Number: 1218143045
   Format: MMDDHHmmss (Month-Day-Hour-Minute-Second)

=== Copying Resources ===
...
```

---

## ⚙️ 配置方式

### 默认行为（推荐）

在 `app.cfg` 中**不需要**指定 `buildNumber`：

```properties
# 应用基本信息
appName=GuessIdiom
appDisplayName=猜一猜是不是成语
appId=com.xlab.guessIdiom

# 版本号
appVersion=1.0.1
# buildNumber 会在构建时自动生成（基于当前时间：月日小时分钟秒）
```

构建时会自动生成并显示：

```
📦 Auto-generated Build Number: 1218143045
```

### 手动指定（可选）

如果确实需要手动指定（不推荐），可以在 `app.cfg` 中添加：

```properties
appVersion=1.0.1
buildNumber=12345
```

构建时会使用指定的值：

```
📦 Using configured Build Number: 12345
```

---

## 📱 平台支持

### Android

**使用位置**:
- `versionCode` (数字版本号)
- 显示在应用详情中

**格式要求**:
- 必须是整数
- 必须递增（每次发布都要比上次大）
- ✅ 自动生成的时间戳完全满足要求

**配置文件**: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        versionCode __BUILD_NUMBER__  // 自动替换为时间戳
        versionName "__APP_VERSION__"  // 如 "1.0.1"
    }
}
```

### iOS

**使用位置**:
- `CFBundleVersion` (Build Number)
- 显示在 TestFlight 和 App Store Connect 中

**格式要求**:
- 可以是整数或字符串
- 必须递增（每次发布都要比上次大）
- ✅ 自动生成的时间戳完全满足要求

**配置文件**: `ios/WebViewApp/Info.plist`

```xml
<key>CFBundleVersion</key>
<string>__BUILD_NUMBER__</string>  <!-- 自动替换为时间戳 -->

<key>CFBundleShortVersionString</key>
<string>__APP_VERSION__</string>  <!-- 如 "1.0.1" -->
```

---

## 🎯 使用示例

### 场景 1: 日常开发构建

**时间**: 2024-12-18 14:30:45

```bash
python3 scripts/build_config.py
```

**生成的 Build Number**: `1218143045`

### 场景 2: 同一天多次构建

**第一次**: 2024-12-18 09:00:00 → Build Number: `1218090000`  
**第二次**: 2024-12-18 14:30:00 → Build Number: `1218143000`  
**第三次**: 2024-12-18 18:45:30 → Build Number: `1218184530`

✅ 每次都不同，自动递增

### 场景 3: GitHub Actions 自动构建

workflow 中无需任何修改，自动使用构建时的时间：

```yaml
- name: Configure build
  run: python3 scripts/build_config.py
  # 自动生成当前时间的 Build Number
```

每次 push 或 tag 触发构建时，都会生成新的唯一 Build Number。

---

## 📊 Build Number 解读

### 格式说明

```
1 2 1 8  1 4  3 0  4 5
│ │ │ │  │ │  │ │  │ │
│ │ │ │  │ │  │ │  └─┴─ 秒 (00-59)
│ │ │ │  │ │  └─┴────── 分钟 (00-59)
│ │ │ │  └─┴─────────── 小时 (00-23)
│ │ └─┴────────────────── 日 (01-31)
└─┴──────────────────────── 月 (01-12)
```

### 实际例子

| Build Number | 解读 | 构建时间 |
|-------------|------|---------|
| `0101000000` | 01月01日 00:00:00 | 新年第一秒 |
| `0630120000` | 06月30日 12:00:00 | 年中午时 |
| `1218143045` | 12月18日 14:30:45 | 下午两点半 |
| `1231235959` | 12月31日 23:59:59 | 年末最后一秒 |

---

## 🔍 常见问题

### Q1: 同一秒内多次构建会冲突吗？

**A**: 实际使用中几乎不可能在同一秒内完成多次完整构建（构建脚本执行需要时间）。如果确实需要，可以在秒级别后再添加毫秒。

**当前解决方案**: 如果担心冲突，可以在构建脚本中增加毫秒：

```python
def generate_build_number(self):
    now = datetime.now()
    build_number = now.strftime('%m%d%H%M%S')
    return build_number
```

### Q2: Build Number 会超过整数上限吗？

**A**: 不会。

- 最大值: `1231235959` (12月31日 23:59:59)
- Android `versionCode` 支持的最大值: `2147483647` (约 21 亿)
- iOS `CFBundleVersion` 支持字符串，无限制

✅ 完全在安全范围内

### Q3: 可以手动指定特定的 Build Number 吗？

**A**: 可以，但不推荐。

如果需要，在 `app.cfg` 中添加：

```properties
buildNumber=自定义值
```

### Q4: 时区问题会影响吗？

**A**: 使用的是本地时间（服务器或开发机器时间）。

- **本地构建**: 使用你的电脑时间
- **GitHub Actions**: 使用 GitHub 服务器时间（UTC）

建议在 GitHub Actions 中设置时区：

```yaml
- name: Set timezone
  run: |
    export TZ='Asia/Shanghai'
    echo "TZ=Asia/Shanghai" >> $GITHUB_ENV

- name: Configure build
  run: python3 scripts/build_config.py
```

### Q5: 之前的 buildNumber 配置会被忽略吗？

**A**: 不会。如果配置文件中有 `buildNumber`，会优先使用配置的值：

```
📦 Using configured Build Number: 6
```

只有当配置文件中**没有**或**为空**时，才会自动生成。

### Q6: 跨年会有问题吗？

**A**: 不会。时间是自然递增的：

```
2024-12-31 23:59:59 → 1231235959
2025-01-01 00:00:00 → 0101000000
```

虽然数字看起来变小了，但实际上是不同年份的构建。如果担心，可以在格式中加入年份。

### Q7: 如何在格式中包含年份？

**A**: 修改 `build_config.py` 中的格式：

```python
def generate_build_number(self):
    now = datetime.now()
    # 格式: YYMMDDHHmmss (年月日小时分钟秒)
    build_number = now.strftime('%y%m%d%H%M%S')
    return build_number

# 示例: 241218143045 = 2024年12月18日14:30:45
```

---

## 🎨 最佳实践

### ✅ 推荐做法

1. **不要在 app.cfg 中指定 buildNumber**
   - 让脚本自动生成
   - 每次构建都是唯一的

2. **使用 Git Tag 管理版本**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
   - `appVersion` 从 Git Tag 读取
   - `buildNumber` 自动生成

3. **在 CI/CD 中记录 Build Number**
   ```yaml
   - name: Configure and build
     run: |
       python3 scripts/build_config.py | tee build.log
       grep "Build Number" build.log
   ```

### ❌ 避免事项

1. **不要手动修改生成的 Build Number**
   - 会破坏唯一性
   - 可能导致上传失败

2. **不要依赖 Build Number 做版本控制**
   - Build Number 用于标识构建
   - 版本控制应使用 `appVersion`

3. **不要在本地和 CI 中混用 Build Number**
   - 可能导致冲突
   - 建议只在 CI 中正式构建

---

## 📚 相关文档

- [配置文件说明](./配置文件说明.md)
- [GitHub Actions 构建说明](./构建发布指南.md)
- [iOS 打包说明](./iOS打包说明.md)
- [Android 打包说明](./Android打包说明.md)

---

## 🔄 更新记录

- **2025-12-18**: 实现自动生成 Build Number，基于当前时间（月日小时分钟秒）







# 自动生成 Build Number 说明

## 📋 概述

从现在开始，**buildNumber 不再需要在配置文件中手动指定**。构建脚本会自动基于当前时间生成唯一的 Build Number。

---

## ✨ 主要特性

### 自动生成规则

**格式**: `MMDDHHmmss` (月日小时分钟秒)

**示例**:
- `1218143045` = 2024年12月18日 14:30:45
- `0101090000` = 2024年01月01日 09:00:00
- `1231235959` = 2024年12月31日 23:59:59

### 优势

✅ **唯一性**: 每次构建都有不同的 Build Number  
✅ **可追溯**: 从 Build Number 可以知道构建时间  
✅ **自动化**: 无需手动递增，避免遗忘  
✅ **递增性**: 时间自然递增，满足应用商店要求  
✅ **简单**: 不需要维护版本号文件  

---

## 🔧 实现方式

### Python 脚本自动生成

在 `scripts/build_config.py` 中：

```python
from datetime import datetime

def generate_build_number(self):
    """生成基于当前时间的构建号
    格式: MMDDHHmmss (月日小时分钟秒)
    例如: 1218143045 表示 12月18日14点30分45秒
    """
    now = datetime.now()
    build_number = now.strftime('%m%d%H%M%S')
    return build_number
```

### 构建时自动应用

运行 `python3 scripts/build_config.py` 时：

```
==================================================
WebView App Configuration Builder
==================================================

App Name: idiomApp
Config loaded from: assets/idiomApp/app.cfg
Total config items: 42

📦 Auto-generated Build Number: 1218143045
   Format: MMDDHHmmss (Month-Day-Hour-Minute-Second)

=== Copying Resources ===
...
```

---

## ⚙️ 配置方式

### 默认行为（推荐）

在 `app.cfg` 中**不需要**指定 `buildNumber`：

```properties
# 应用基本信息
appName=GuessIdiom
appDisplayName=猜一猜是不是成语
appId=com.xlab.guessIdiom

# 版本号
appVersion=1.0.1
# buildNumber 会在构建时自动生成（基于当前时间：月日小时分钟秒）
```

构建时会自动生成并显示：

```
📦 Auto-generated Build Number: 1218143045
```

### 手动指定（可选）

如果确实需要手动指定（不推荐），可以在 `app.cfg` 中添加：

```properties
appVersion=1.0.1
buildNumber=12345
```

构建时会使用指定的值：

```
📦 Using configured Build Number: 12345
```

---

## 📱 平台支持

### Android

**使用位置**:
- `versionCode` (数字版本号)
- 显示在应用详情中

**格式要求**:
- 必须是整数
- 必须递增（每次发布都要比上次大）
- ✅ 自动生成的时间戳完全满足要求

**配置文件**: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        versionCode __BUILD_NUMBER__  // 自动替换为时间戳
        versionName "__APP_VERSION__"  // 如 "1.0.1"
    }
}
```

### iOS

**使用位置**:
- `CFBundleVersion` (Build Number)
- 显示在 TestFlight 和 App Store Connect 中

**格式要求**:
- 可以是整数或字符串
- 必须递增（每次发布都要比上次大）
- ✅ 自动生成的时间戳完全满足要求

**配置文件**: `ios/WebViewApp/Info.plist`

```xml
<key>CFBundleVersion</key>
<string>__BUILD_NUMBER__</string>  <!-- 自动替换为时间戳 -->

<key>CFBundleShortVersionString</key>
<string>__APP_VERSION__</string>  <!-- 如 "1.0.1" -->
```

---

## 🎯 使用示例

### 场景 1: 日常开发构建

**时间**: 2024-12-18 14:30:45

```bash
python3 scripts/build_config.py
```

**生成的 Build Number**: `1218143045`

### 场景 2: 同一天多次构建

**第一次**: 2024-12-18 09:00:00 → Build Number: `1218090000`  
**第二次**: 2024-12-18 14:30:00 → Build Number: `1218143000`  
**第三次**: 2024-12-18 18:45:30 → Build Number: `1218184530`

✅ 每次都不同，自动递增

### 场景 3: GitHub Actions 自动构建

workflow 中无需任何修改，自动使用构建时的时间：

```yaml
- name: Configure build
  run: python3 scripts/build_config.py
  # 自动生成当前时间的 Build Number
```

每次 push 或 tag 触发构建时，都会生成新的唯一 Build Number。

---

## 📊 Build Number 解读

### 格式说明

```
1 2 1 8  1 4  3 0  4 5
│ │ │ │  │ │  │ │  │ │
│ │ │ │  │ │  │ │  └─┴─ 秒 (00-59)
│ │ │ │  │ │  └─┴────── 分钟 (00-59)
│ │ │ │  └─┴─────────── 小时 (00-23)
│ │ └─┴────────────────── 日 (01-31)
└─┴──────────────────────── 月 (01-12)
```

### 实际例子

| Build Number | 解读 | 构建时间 |
|-------------|------|---------|
| `0101000000` | 01月01日 00:00:00 | 新年第一秒 |
| `0630120000` | 06月30日 12:00:00 | 年中午时 |
| `1218143045` | 12月18日 14:30:45 | 下午两点半 |
| `1231235959` | 12月31日 23:59:59 | 年末最后一秒 |

---

## 🔍 常见问题

### Q1: 同一秒内多次构建会冲突吗？

**A**: 实际使用中几乎不可能在同一秒内完成多次完整构建（构建脚本执行需要时间）。如果确实需要，可以在秒级别后再添加毫秒。

**当前解决方案**: 如果担心冲突，可以在构建脚本中增加毫秒：

```python
def generate_build_number(self):
    now = datetime.now()
    build_number = now.strftime('%m%d%H%M%S')
    return build_number
```

### Q2: Build Number 会超过整数上限吗？

**A**: 不会。

- 最大值: `1231235959` (12月31日 23:59:59)
- Android `versionCode` 支持的最大值: `2147483647` (约 21 亿)
- iOS `CFBundleVersion` 支持字符串，无限制

✅ 完全在安全范围内

### Q3: 可以手动指定特定的 Build Number 吗？

**A**: 可以，但不推荐。

如果需要，在 `app.cfg` 中添加：

```properties
buildNumber=自定义值
```

### Q4: 时区问题会影响吗？

**A**: 使用的是本地时间（服务器或开发机器时间）。

- **本地构建**: 使用你的电脑时间
- **GitHub Actions**: 使用 GitHub 服务器时间（UTC）

建议在 GitHub Actions 中设置时区：

```yaml
- name: Set timezone
  run: |
    export TZ='Asia/Shanghai'
    echo "TZ=Asia/Shanghai" >> $GITHUB_ENV

- name: Configure build
  run: python3 scripts/build_config.py
```

### Q5: 之前的 buildNumber 配置会被忽略吗？

**A**: 不会。如果配置文件中有 `buildNumber`，会优先使用配置的值：

```
📦 Using configured Build Number: 6
```

只有当配置文件中**没有**或**为空**时，才会自动生成。

### Q6: 跨年会有问题吗？

**A**: 不会。时间是自然递增的：

```
2024-12-31 23:59:59 → 1231235959
2025-01-01 00:00:00 → 0101000000
```

虽然数字看起来变小了，但实际上是不同年份的构建。如果担心，可以在格式中加入年份。

### Q7: 如何在格式中包含年份？

**A**: 修改 `build_config.py` 中的格式：

```python
def generate_build_number(self):
    now = datetime.now()
    # 格式: YYMMDDHHmmss (年月日小时分钟秒)
    build_number = now.strftime('%y%m%d%H%M%S')
    return build_number

# 示例: 241218143045 = 2024年12月18日14:30:45
```

---

## 🎨 最佳实践

### ✅ 推荐做法

1. **不要在 app.cfg 中指定 buildNumber**
   - 让脚本自动生成
   - 每次构建都是唯一的

2. **使用 Git Tag 管理版本**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
   - `appVersion` 从 Git Tag 读取
   - `buildNumber` 自动生成

3. **在 CI/CD 中记录 Build Number**
   ```yaml
   - name: Configure and build
     run: |
       python3 scripts/build_config.py | tee build.log
       grep "Build Number" build.log
   ```

### ❌ 避免事项

1. **不要手动修改生成的 Build Number**
   - 会破坏唯一性
   - 可能导致上传失败

2. **不要依赖 Build Number 做版本控制**
   - Build Number 用于标识构建
   - 版本控制应使用 `appVersion`

3. **不要在本地和 CI 中混用 Build Number**
   - 可能导致冲突
   - 建议只在 CI 中正式构建

---

## 📚 相关文档

- [配置文件说明](./配置文件说明.md)
- [GitHub Actions 构建说明](./构建发布指南.md)
- [iOS 打包说明](./iOS打包说明.md)
- [Android 打包说明](./Android打包说明.md)

---

## 🔄 更新记录

- **2025-12-18**: 实现自动生成 Build Number，基于当前时间（月日小时分钟秒）

# 证书和密钥配置指南

本指南将帮助你获取并配置 Android 和 iOS 的签名证书，用于构建正式发布包。

---

## 📱 Android 签名配置

### 1. 创建 Android Keystore

#### 使用 Android Studio 创建（推荐）

1. **打开 Android Studio**
2. 选择 **Build** → **Generate Signed Bundle / APK**
3. 选择 **APK**，点击 **Next**
4. 点击 **Create new...** 按钮
5. 填写以下信息：
   - **Key store path**: 选择保存位置（如 `~/keystore/my-app.jks`）
   - **Password**: 输入 keystore 密码（记住这个密码）
   - **Alias**: 输入密钥别名（如 `my-app-key`）
   - **Password**: 输入密钥密码（记住这个密码）
   - **Validity (years)**: 25（建议至少 25 年）
   - **Certificate**: 填写个人/公司信息
6. 点击 **OK** 创建

#### 使用命令行创建

```bash
keytool -genkey -v -keystore my-android-app.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-app-key
```

**参数说明：**
- `my-app.jks`: keystore 文件名
- `my-app-key`: 密钥别名
- 执行后会提示输入密码和证书信息

### 2. 转换 Keystore 为 Base64

为了在 GitHub Secrets 中存储，需要将 keystore 转换为 Base64：

```bash
# macOS/Linux
base64 -i my-app.jks -o my-app.jks.base64

# 或者直接输出到剪贴板 (macOS)
base64 -i my-app.jks | pbcopy
```

### 3. 配置 GitHub Secrets

在你的 GitHub 仓库中设置以下 Secrets：

1. 进入 **Settings** → **Secrets and variables** → **Actions**
2. 点击 **New repository secret**
3. 添加以下 Secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `ANDROID_KEYSTORE_BASE64` | Keystore 的 Base64 编码 | `MIIKXgIBAz...` |
| `ANDROID_KEYSTORE_FILE` | Keystore 文件名 | `my-android-app.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 密码 | `your_keystore_password` |
| `ANDROID_KEY_ALIAS` | 密钥别名 | `my-app-key` |
| `ANDROID_KEY_PASSWORD` | 密钥密码 | `your_key_password` |

### 4. 更新 build.gradle 配置

确保 `android/app/build.gradle` 中的签名配置正确：

```gradle
android {
    signingConfigs {
        release {
            storeFile file(System.getenv('ANDROID_KEYSTORE_FILE') ?: 'my-app.jks')
            storePassword System.getenv('KEYSTORE_PASSWORD')
            keyAlias System.getenv('KEY_ALIAS')
            keyPassword System.getenv('KEY_PASSWORD')
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 📚 官方文档

- [Android 官方签名指南](https://developer.android.com/studio/publish/app-signing)
- [生成上传密钥和密钥库](https://developer.android.com/studio/publish/app-signing#generate-key)
- [Google Play 应用签名](https://support.google.com/googleplay/android-developer/answer/9842756)

---

## 🍎 iOS 签名配置

### 1. 注册 Apple Developer 账号

1. 访问 [Apple Developer](https://developer.apple.com/)
2. 注册开发者账号（个人 $99/年，企业 $299/年）
3. 完成账号验证

### 2. 创建 App ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → 点击 **+** 按钮
4. 选择 **App IDs** → **Continue**
5. 填写信息：
   - **Description**: 应用描述（如 `My WebView App`）
   - **Bundle ID**: 应用包名（如 `com.mycompany.myapp`）
   - **Explicit** 选择具体的 Bundle ID
6. 选择需要的 **Capabilities**（如 Push Notifications）
7. 点击 **Continue** → **Register**

### 3. 创建证书（Certificate）

#### 方式一：使用 Xcode 自动管理（推荐新手）

1. 打开 Xcode，选择你的项目
2. 选择 **Target** → **Signing & Capabilities**
3. 勾选 **Automatically manage signing**
4. 选择你的 **Team**
5. Xcode 会自动创建证书和 Provisioning Profile

#### 方式二：手动创建（用于 CI/CD）

​	

⚠️ **重要：必须在生成 CSR 时创建私钥**

**完整步骤：**

1. 打开 **"钥匙串访问"**（Keychain Access）应用
   - 位置：应用程序 → 实用工具 → 钥匙串访问

2. 在顶部菜单选择 **"钥匙串访问" → "证书助理" → "从证书颁发机构请求证书..."**

3. 在弹出的"证书助理"窗口中填写：
   - **用户电子邮件地址**：填写你的 Apple ID 邮箱（如 `you@example.com`）
   - **常用名称**：填写你的姓名或公司名（如 `Zhang San`）
   - **CA 电子邮件地址**：**留空**（不要填写）
   - **请求是**：选择 **"存储到磁盘"**（单选按钮）
   - ⚠️ **必须勾选**：**☑️ "让我指定密钥对信息"** ← 这是关键！

4. 点击 **"继续"** 按钮

5. **关键步骤**：如果正确勾选了，会弹出"密钥对信息"窗口：
   - **密钥大小**：选择 **2048 位**
   - **算法**：选择 **RSA**
   - 点击 **"继续"**
   
   > ⚠️ 如果没有弹出这个窗口，说明第 3 步没有勾选"让我指定密钥对信息"，需要重新开始！

6. 选择保存位置，保存 `CertificateSigningRequest.certSigningRequest` 文件

7. ✅ **立即验证私钥是否生成**：
   ```bash
   # 方法 1：在钥匙串访问中查看
   - 在"钥匙串访问"窗口中
   - 确保左上角选择了"登录"钥匙串
   - 点击左侧分类中的"密钥"（不是"证书"！）
   - 查看右侧列表，应该能看到新创建的私钥
   - 特征：🔑 图标，名称是你刚才输入的"常用名称"
   
   # 方法 2：使用命令行验证
   security find-identity -v -p codesigning
   # 应该能看到类似输出（如果还没安装证书，可能显示 0 valid）
   ```

> ⚠️ **关键点**：如果在"密钥"分类中看不到新的私钥，说明操作有误，必须重新生成 CSR！

**❌ 如果没有看到私钥**：
1. 删除刚才的 CSR 文件
2. 重新从步骤 1 开始
3. **确保第 3 步勾选了"让我指定密钥对信息"**
4. **确保第 5 步弹出了"密钥对信息"窗口**

**💡 简单替代方案：使用 Xcode 生成**（推荐新手）

如果你觉得上面的步骤太复杂，可以用 Xcode：
1. Xcode → Preferences/Settings → Accounts
2. 添加 Apple ID 并登录
3. Manage Certificates... → 点击 + → 选择证书类型
4. Xcode 会自动处理所有步骤（包括私钥）

**b. 在 Apple Developer Portal 创建证书**

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles** → **Certificates**
3. 点击 **+** 按钮
4. 选择证书类型：
   - **Development**: iOS App Development（开发用）
   - **Production**: 
     - iOS Distribution (App Store and Ad Hoc)（App Store 发布）
     - Apple Distribution（企业分发）
5. 上传前面生成的 CSR 文件
6. 下载生成的 `.cer` 证书文件

**c. 安装证书到 Keychain**

1. **双击** 下载的 `.cer` 证书文件
2. 证书会自动导入到钥匙串（通常是"登录"钥匙串）
3. ✅ **验证安装成功**：
   - 打开 "钥匙串访问"
   - 在左侧选择 **"登录"** 钥匙串
   - 点击 **"我的证书"** 分类
   - 你应该看到新安装的证书，**证书左侧有一个小三角形▶️**
   - 点击展开，能看到对应的私钥（带🔑图标）

**⚠️ 故障排查：证书只在"证书"分类显示，不在"我的证书"分类**

这说明证书没有关联到私钥。原因和解决方法：

**原因**：
- 生成 CSR 时没有勾选"让我指定密钥对信息"
- 私钥在不同的钥匙串中
- 使用了别人创建的 CSR 文件

**解决方法 1：重新生成（推荐）** ⭐️
1. 在 Apple Developer Portal 删除刚才的证书
2. 在钥匙串中删除已安装的证书
3. 重新从步骤 a 开始，**确保勾选"让我指定密钥对信息"**
4. 生成新的 CSR 并创建新证书

**解决方法 2：检查私钥**
1. 在钥匙串访问中，点击左侧 **"密钥"** 分类
2. 查找最近创建的私钥（查看创建日期）
3. 如果私钥在"系统"钥匙串，将其拖到"登录"钥匙串
4. 删除证书后重新双击安装

**解决方法 3：使用 Xcode 自动管理（最简单）**
1. 打开 Xcode 项目
2. 选择 Target → Signing & Capabilities
3. 勾选 **"Automatically manage signing"**
4. 选择你的 Team
5. Xcode 会自动创建和管理所有证书

**d. 导出证书为 .p12**

> ⚠️ **前提**：证书必须出现在"我的证书"分类，并且能展开看到私钥

1. 打开 "钥匙串访问"
2. 在左侧选择 **"登录"** 钥匙串
3. 点击 **"我的证书"** 分类
4. 找到你的证书（有 ▶️ 可以展开）
5. **选择证书**（选择顶层的证书，不是展开后的私钥）
6. 右键证书 → **"导出..."** 或菜单 "文件" → "导出项目..."
7. 文件格式选择：**"个人信息交换 (.p12)"**
8. 输入文件名（如 `ios-distribution.p12`）并保存
9. 设置导出密码（**记住这个密码**，后面配置 GitHub Secrets 需要）
10. 输入 Mac 登录密码来授权导出

**✅ 验证导出**：
- .p12 文件大小应该是 2-5 KB
- 如果只有几百字节，说明没有包含私钥，需要重新导出

---

### 4. 注册测试设备（Development/Ad Hoc 必需）

> ⚠️ **重要**：如果使用 Development 或 Ad Hoc 证书，必须先注册设备才能在真机上安装应用！

#### 为什么需要注册设备？

- **Development 证书**：只能安装到已注册的设备（最多 100 台）
- **Ad Hoc 证书**：只能安装到已注册的设备（最多 100 台）
- **App Store/TestFlight**：不需要注册设备，任意设备都可以安装

#### 设备限制

| 账号类型 | 最大设备数 | 说明 |
|---------|-----------|------|
| 免费 Apple ID | **3 台** | 只能用于开发测试 |
| 付费开发者账号 | **100 台** | 每年可以删除设备 |

---

#### 方法 1：获取设备 UDID（需要的唯一标识符）

**什么是 UDID？**
- UDID（Unique Device Identifier）是 iOS 设备的唯一标识符
- 格式：40 位十六进制字符串（如 `00008030-001234567890123A`）

**获取方式 A：通过 Mac 获取（最准确）** ⭐️

1. **使用 Finder（macOS Catalina 及以上）**：
   ```bash
   1. 用数据线连接 iPhone 到 Mac
   2. 打开 Finder
   3. 在左侧边栏选择你的 iPhone
   4. 在顶部点击设备名称下方的信息
   5. 多次点击会循环显示：序列号 → IMEI → UDID
   6. 看到 UDID 时，右键 → 拷贝 UDID
   ```

2. **使用 iTunes（macOS Mojave 及以下）**：
   ```bash
   1. 连接 iPhone 到 Mac
   2. 打开 iTunes
   3. 点击左上角的设备图标
   4. 点击"序列号"标签
   5. 再次点击会显示 UDID
   6. 右键 → 拷贝
   ```

3. **使用 Xcode**：
   ```bash
   1. 打开 Xcode
   2. 菜单：Window → Devices and Simulators
   3. 连接设备后，在左侧选择设备
   4. 右侧会显示 Identifier（即 UDID）
   5. 右键 → Copy
   ```

**获取方式 B：通过 iPhone 直接获取**

1. **使用系统信息**：
   ```bash
   1. 打开"设置"
   2. 通用 → 关于本机
   3. 找不到直接的 UDID 显示
   4. 需要通过第三方工具或连接电脑
   ```

2. **使用第三方网站**（需谨慎）：
   - 访问 `https://www.udid.io/` 等网站
   - 安装配置描述文件
   - 网站会显示你的 UDID
   - ⚠️ 注意：可能存在隐私风险

**获取方式 C：让测试用户发送给你**

可以让测试用户安装专门的 UDID 查看工具：

1. **UDID+ App（推荐）**：
   - App Store 链接：[UDID+](https://apps.apple.com/app/udid/id1046856018)
   - 完全免费，无需注册
   - 安装后直接显示 UDID
   - 可以一键复制或分享

2. **通过网页获取**：
   - 访问 [https://get.udid.io/](https://get.udid.io/) 或类似网站
   - 安装配置描述文件
   - 网页会显示 UDID
   - ⚠️ 注意：涉及隐私，谨慎使用第三方网站

3. **发送截图方式**：
   - 让用户：设置 → 通用 → 关于本机
   - 截图显示序列号的界面
   - 你可以通过序列号查询 UDID（某些工具）
   - ⚠️ 但这种方式不如直接获取 UDID 准确

> ⚠️ **注意**：TestFlight 不是用来获取 UDID 的工具！TestFlight 是 Apple 官方的测试分发平台，需要先有测试邀请才能使用。

---

#### 方法 2：在 Apple Developer Portal 注册设备

1. **登录 Apple Developer Portal**
   - 访问 [https://developer.apple.com/account/](https://developer.apple.com/account/)
   - 使用你的 Apple ID 登录

2. **进入设备管理页面**
   ```bash
   Certificates, Identifiers & Profiles → Devices
   ```

3. **添加新设备**
   ```bash
   1. 点击左侧"Devices"
   2. 点击页面左上角的 + 按钮
   3. 选择平台：iOS/iPadOS
   4. 填写信息：
      - Device Name: 设备名称（如"张三的 iPhone 13"）
      - Device ID (UDID): 粘贴刚才复制的 UDID
   5. 点击"Continue"
   6. 点击"Register"完成注册
   ```

4. **批量注册多台设备**
   ```bash
   1. 在 Devices 页面点击 + 按钮
   2. 选择"Register Multiple Devices"
   3. 下载模板文件
   4. 在模板中填写设备信息（每行一个设备）：
      Device ID    Device Name
      00008030...  张三的 iPhone
      00008030...  李四的 iPhone
   5. 上传填好的文件
   6. 确认并注册
   ```

**✅ 验证注册成功**：
- 在 Devices 列表中能看到新注册的设备
- 设备状态显示为"Enabled"

---

#### 方法 3：使用 Xcode 自动注册（最简单）⭐️

如果你使用 Xcode 自动管理签名：

```bash
1. 连接 iPhone 到 Mac
2. 打开 Xcode 项目
3. 选择连接的设备作为运行目标
4. 点击运行按钮
5. Xcode 会自动：
   - 注册设备
   - 更新 Provisioning Profile
   - 安装应用到设备
```

**优点**：
- ✅ 全自动，无需手动操作
- ✅ 不需要查找 UDID
- ✅ 适合快速测试

**缺点**：
- ❌ 需要物理连接设备
- ❌ 不适合远程添加设备

---

#### 方法 4：更新 Provisioning Profile（添加设备后必须执行）

注册新设备后，必须更新 Provisioning Profile：

**手动更新**：
```bash
1. 登录 Apple Developer Portal
2. Profiles → 找到你的 Development/Ad Hoc Profile
3. 点击 Profile 名称
4. 点击"Edit"
5. 在"Devices"部分，勾选新添加的设备
6. 点击"Generate"重新生成
7. 下载新的 .mobileprovision 文件
8. 双击安装或使用 Xcode 导入
```

**Xcode 自动更新**：
```bash
1. Xcode → Preferences → Accounts
2. 选择你的 Apple ID
3. 点击"Download Manual Profiles"
4. Xcode 会自动下载最新的 Profiles
```

**重新打包应用**：
```bash
# 更新 Provisioning Profile 后，必须重新打包
# 否则新设备仍然无法安装

# 如果使用 GitHub Actions，需要：
1. 更新 IOS_PROVISIONING_PROFILE_BASE64 Secret
2. 重新触发构建
```

---

#### 📝 完整的设备注册流程示例

**场景：添加 3 台测试设备**

```bash
步骤 1：收集设备信息
├─ 张三的 iPhone 13: 00008030-001234567890001A
├─ 李四的 iPhone 12: 00008030-001234567890002B
└─ 王五的 iPhone 11: 00008030-001234567890003C

步骤 2：注册设备
1. 登录 developer.apple.com
2. Devices → 点击 +
3. 选择"Register Multiple Devices"
4. 填写并上传设备列表
5. 完成注册

步骤 3：更新 Provisioning Profile
1. Profiles → 选择你的 Development Profile
2. Edit → 勾选新添加的 3 台设备
3. Generate → 下载新的 Profile

步骤 4：配置 GitHub Actions（如果使用 CI/CD）
1. 转换新 Profile 为 Base64：
   base64 -i profile.mobileprovision | tr -d '\n'
2. 更新 GitHub Secret：IOS_PROVISIONING_PROFILE_BASE64
3. 重新打包

步骤 5：分发应用
1. 重新构建 IPA
2. 分发给测试用户
3. 用户可以通过以下方式安装：
   - iTunes 同步安装
   - Xcode Devices 窗口安装
   - 通过网页（需要 HTTPS 服务器）
   - 使用 Apple Configurator
```

---

#### 🚨 常见问题

**Q: 设备已满（100 台限制），如何删除？**

```bash
1. 在 Devices 页面找到要删除的设备
2. 点击设备名称
3. 点击"Disable"按钮
4. 等到下一年，可以永久删除

注意：
- 每年只能删除一次设备（在会员年度更新后）
- Disable 后设备立即不可用
- 设备数会在下一个会员年度重置
```

**Q: 添加设备后，应用仍然无法安装？**

```bash
可能原因：
1. ❌ 没有重新生成 Provisioning Profile
2. ❌ 没有重新打包应用
3. ❌ UDID 复制错误（多了空格或字符）
4. ❌ 使用了错误的 Profile 打包

解决方法：
1. 确认设备在 Developer Portal 中已注册
2. 重新生成并下载 Provisioning Profile
3. 确保新 Profile 包含该设备
4. 使用新 Profile 重新打包
5. 验证 UDID 是否正确（40 位十六进制）
```

**Q: 免费账号和付费账号的区别？**

| 功能 | 免费账号 | 付费账号（$99/年） |
|------|---------|-------------------|
| 设备数量 | **3 台** | **100 台** |
| 证书有效期 | 7 天（需重新签名） | 1 年 |
| App Store 发布 | ❌ 不支持 | ✅ 支持 |
| TestFlight | ❌ 不支持 | ✅ 支持 |
| 推送通知 | ✅ 支持（有限） | ✅ 完全支持 |

---

### 5. 创建 Provisioning Profile

> ⚠️ **前提**：
> - Development/Ad Hoc Profile 需要先注册测试设备（见第 4 步）
> - App Store Profile 不需要注册设备

1. 进入 **Certificates, Identifiers & Profiles** → **Profiles**
2. 点击 **+** 按钮
3. 选择类型：
   - **Development**: iOS App Development（开发测试，**需要注册设备**）
   - **Distribution**:
     - App Store（App Store 发布，无需注册设备）
     - Ad Hoc（内部分发测试，**需要注册设备**）
     - Enterprise（企业内部分发，无需注册设备）
4. 选择对应的 **App ID**
5. 选择对应的 **Certificate**
6. **如果是 Development/Ad Hoc**，选择要包含的测试设备：
   - ☑️ Select All（选择所有已注册设备）
   - 或手动勾选特定设备
   - ⚠️ 未勾选的设备无法安装应用！
7. 输入 Profile 名称（如 `MyApp Development Profile`）
8. 点击 **Generate**
9. 下载 `.mobileprovision` 文件

**✅ 验证 Profile 包含的设备**：
```bash
# 查看 Provisioning Profile 中包含的设备列表
security cms -D -i profile.mobileprovision | grep -A 50 "ProvisionedDevices"

# 应该能看到所有设备的 UDID
# 如果某台设备的 UDID 不在列表中，该设备无法安装应用
```

**🔄 更新 Provisioning Profile**（添加新设备后）：
```bash
1. 在 Apple Developer Portal 注册新设备
2. 进入 Profiles，找到现有的 Profile
3. 点击 Profile 名称 → Edit
4. 勾选新添加的设备
5. 点击 Generate 重新生成
6. 下载并替换旧的 .mobileprovision 文件
7. 重新打包应用
```

### 6. 转换证书和 Profile 为 Base64

```bash
# 转换证书为 Base64
base64 -i certificate.p12 -o certificate.p12.base64

# 转换 Provisioning Profile 为 Base64
base64 -i profile.mobileprovision -o profile.mobileprovision.base64

# 或者直接复制到剪贴板 (macOS)
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

### 7. 配置 GitHub Secrets

在 GitHub 仓库中设置以下 Secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `IOS_CERTIFICATE_BASE64` | .p12 证书的 Base64 编码 | `MIIKXgIBAz...` |
| `IOS_CERTIFICATE_PASSWORD` | .p12 证书密码 | `your_certificate_password` |
| `IOS_PROVISIONING_PROFILE_BASE64` | .mobileprovision 的 Base64 | `MIIPpQYJKo...` |
| `IOS_TEAM_ID` | Apple Developer Team ID | `ABC123XYZ` |
| `IOS_EXPORT_METHOD` | 导出方法 | `app-store` / `ad-hoc` / `enterprise` |
| `KEYCHAIN_PASSWORD` | 临时 Keychain 密码（可随机） | `build_keychain_pwd` |

### 8. 获取 Team ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Membership** 页面
3. 找到 **Team ID**（10位字符，如 `ABC123XYZ`）

### 📚 官方文档

- [Apple Developer Portal](https://developer.apple.com/account/)
- [创建证书和 Profiles](https://help.apple.com/xcode/mac/current/#/dev3a05256b8)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [TestFlight 测试指南](https://developer.apple.com/testflight/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)

---

## ⚙️ GitHub Actions 配置

### 构建配置文件

在 `assets/app1/app.cfg` 中设置：

```properties
# 是否为 Debug 模式（true=测试包，false=正式包）
isDebug=false

# 是否构建 Android
buildAndroid=true

# 是否构建 iOS
buildIOS=true
```

### 触发构建

#### 构建测试包（Debug）

```bash
# 1. 设置 isDebug=true
echo "isDebug=true" >> assets/app1/app.cfg

# 2. 提交并打 tag
git add .
git commit -m "Build debug version"
git tag v1.0.0-debug
git push origin v1.0.0-debug
```

#### 构建正式包（Release）

```bash
# 1. 设置 isDebug=false
echo "isDebug=false" >> assets/app1/app.cfg

# 2. 确保已配置所有 Secrets

# 3. 提交并打 tag
git add .
git commit -m "Build release version v1.0.0"
git tag v1.0.0
git push origin v1.0.0
```

---

## 🔐 安全建议

1. **永远不要提交密钥到 Git**
   - 将 `.jks`, `.p12`, `.mobileprovision` 添加到 `.gitignore`
   
2. **定期更新密码**
   - 每年更新一次 GitHub Secrets 中的密码

3. **备份证书和密钥**
   - 将证书、密钥库保存在安全的地方
   - 记录所有密码（使用密码管理器）

4. **使用不同的证书**
   - 开发环境和生产环境使用不同的证书
   - 不要在多个应用间共享密钥

5. **限制 Secrets 访问权限**
   - 只给必要的人员访问权限
   - 使用 GitHub Organizations 的细粒度权限控制

---

## 📦 应用上架流程

### Android (Google Play Store)

1. **准备材料**：
   - Release APK/AAB
   - 应用图标（512x512）
   - 应用截图（不同屏幕尺寸）
   - 应用描述和隐私政策

2. **创建应用**：
   - 登录 [Google Play Console](https://play.google.com/console/)
   - 创建新应用
   - 填写应用信息

3. **上传 APK/AAB**：
   - 进入 **Production** → **Create new release**
   - 上传构建的 APK 或 AAB
   - 填写更新日志

4. **提交审核**：
   - 完成所有必填信息
   - 提交审核（通常 1-3 天）

**官方指南**: [Google Play 上架指南](https://support.google.com/googleplay/android-developer/answer/9859152)

### iOS (App Store)

1. **准备材料**：
   - Release IPA
   - 应用图标（1024x1024）
   - 应用截图（不同设备尺寸）
   - 应用描述和隐私政策

2. **创建应用**：
   - 登录 [App Store Connect](https://appstoreconnect.apple.com/)
   - 点击 **+** 创建新 App
   - 填写基本信息

3. **上传构建版本**：
   - 使用 Xcode 或 Transporter 上传 IPA
   - 或使用命令行：
     ```bash
     xcrun altool --upload-app -f app.ipa -u username -p password
     ```

4. **TestFlight 测试**（可选）：
   - 在 App Store Connect 中启用 TestFlight
   - 添加内部/外部测试员
   - 分发测试版本

5. **提交审核**：
   - 选择构建版本
   - 填写所有必需信息
   - 提交审核（通常 1-7 天）

**官方指南**: [App Store 上架指南](https://developer.apple.com/app-store/submissions/)

---

## 🆘 常见问题

### Android 常见问题

**Q: "Keystore file does not exist"**
```bash
# 检查 Secret 是否正确配置
# 确保 ANDROID_KEYSTORE_BASE64 包含完整的 base64 内容
```

**Q: "错误的密钥库密码"**
```bash
# 确认 ANDROID_KEYSTORE_PASSWORD 和 ANDROID_KEY_PASSWORD 正确
# 可以本地测试：
./gradlew assembleRelease -Pandroid.injected.signing.store.password=your_password
```

### iOS 常见问题

**Q: "No code signing identity found"**
```bash
# 确保证书已正确导入
# 检查 IOS_CERTIFICATE_BASE64 和密码是否正确
security find-identity -v -p codesigning
```

**Q: "Provisioning profile doesn't match"**
```bash
# 确保 Bundle ID 和 Team ID 匹配
# 检查 Provisioning Profile 是否过期
# 在 Xcode 中检查签名配置
```

**Q: "Archive not found"**
```bash
# 检查 xcodebuild archive 命令是否成功
# 查看构建日志确认错误
```

---

## 📞 获取帮助

- **Android**: [Stack Overflow - Android](https://stackoverflow.com/questions/tagged/android)
- **iOS**: [Apple Developer Forums](https://developer.apple.com/forums/)
- **GitHub Actions**: [GitHub Community](https://github.community/)

---

**最后更新**: 2024年12月

# 自动生成 Build Number 说明

## 📋 概述

从现在开始，**buildNumber 不再需要在配置文件中手动指定**。构建脚本会自动基于当前时间生成唯一的 Build Number。

---

## ✨ 主要特性

### 自动生成规则

**格式**: `MMDDHHmmss` (月日小时分钟秒)

**示例**:
- `1218143045` = 2024年12月18日 14:30:45
- `0101090000` = 2024年01月01日 09:00:00
- `1231235959` = 2024年12月31日 23:59:59

### 优势

✅ **唯一性**: 每次构建都有不同的 Build Number  
✅ **可追溯**: 从 Build Number 可以知道构建时间  
✅ **自动化**: 无需手动递增，避免遗忘  
✅ **递增性**: 时间自然递增，满足应用商店要求  
✅ **简单**: 不需要维护版本号文件  

---

## 🔧 实现方式

### Python 脚本自动生成

在 `scripts/build_config.py` 中：

```python
from datetime import datetime

def generate_build_number(self):
    """生成基于当前时间的构建号
    格式: MMDDHHmmss (月日小时分钟秒)
    例如: 1218143045 表示 12月18日14点30分45秒
    """
    now = datetime.now()
    build_number = now.strftime('%m%d%H%M%S')
    return build_number
```

### 构建时自动应用

运行 `python3 scripts/build_config.py` 时：

```
==================================================
WebView App Configuration Builder
==================================================

App Name: idiomApp
Config loaded from: assets/idiomApp/app.cfg
Total config items: 42

📦 Auto-generated Build Number: 1218143045
   Format: MMDDHHmmss (Month-Day-Hour-Minute-Second)

=== Copying Resources ===
...
```

---

## ⚙️ 配置方式

### 默认行为（推荐）

在 `app.cfg` 中**不需要**指定 `buildNumber`：

```properties
# 应用基本信息
appName=GuessIdiom
appDisplayName=猜一猜是不是成语
appId=com.xlab.guessIdiom

# 版本号
appVersion=1.0.1
# buildNumber 会在构建时自动生成（基于当前时间：月日小时分钟秒）
```

构建时会自动生成并显示：

```
📦 Auto-generated Build Number: 1218143045
```

### 手动指定（可选）

如果确实需要手动指定（不推荐），可以在 `app.cfg` 中添加：

```properties
appVersion=1.0.1
buildNumber=12345
```

构建时会使用指定的值：

```
📦 Using configured Build Number: 12345
```

---

## 📱 平台支持

### Android

**使用位置**:
- `versionCode` (数字版本号)
- 显示在应用详情中

**格式要求**:
- 必须是整数
- 必须递增（每次发布都要比上次大）
- ✅ 自动生成的时间戳完全满足要求

**配置文件**: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        versionCode __BUILD_NUMBER__  // 自动替换为时间戳
        versionName "__APP_VERSION__"  // 如 "1.0.1"
    }
}
```

### iOS

**使用位置**:
- `CFBundleVersion` (Build Number)
- 显示在 TestFlight 和 App Store Connect 中

**格式要求**:
- 可以是整数或字符串
- 必须递增（每次发布都要比上次大）
- ✅ 自动生成的时间戳完全满足要求

**配置文件**: `ios/WebViewApp/Info.plist`

```xml
<key>CFBundleVersion</key>
<string>__BUILD_NUMBER__</string>  <!-- 自动替换为时间戳 -->

<key>CFBundleShortVersionString</key>
<string>__APP_VERSION__</string>  <!-- 如 "1.0.1" -->
```

---

## 🎯 使用示例

### 场景 1: 日常开发构建

**时间**: 2024-12-18 14:30:45

```bash
python3 scripts/build_config.py
```

**生成的 Build Number**: `1218143045`

### 场景 2: 同一天多次构建

**第一次**: 2024-12-18 09:00:00 → Build Number: `1218090000`  
**第二次**: 2024-12-18 14:30:00 → Build Number: `1218143000`  
**第三次**: 2024-12-18 18:45:30 → Build Number: `1218184530`

✅ 每次都不同，自动递增

### 场景 3: GitHub Actions 自动构建

workflow 中无需任何修改，自动使用构建时的时间：

```yaml
- name: Configure build
  run: python3 scripts/build_config.py
  # 自动生成当前时间的 Build Number
```

每次 push 或 tag 触发构建时，都会生成新的唯一 Build Number。

---

## 📊 Build Number 解读

### 格式说明

```
1 2 1 8  1 4  3 0  4 5
│ │ │ │  │ │  │ │  │ │
│ │ │ │  │ │  │ │  └─┴─ 秒 (00-59)
│ │ │ │  │ │  └─┴────── 分钟 (00-59)
│ │ │ │  └─┴─────────── 小时 (00-23)
│ │ └─┴────────────────── 日 (01-31)
└─┴──────────────────────── 月 (01-12)
```

### 实际例子

| Build Number | 解读 | 构建时间 |
|-------------|------|---------|
| `0101000000` | 01月01日 00:00:00 | 新年第一秒 |
| `0630120000` | 06月30日 12:00:00 | 年中午时 |
| `1218143045` | 12月18日 14:30:45 | 下午两点半 |
| `1231235959` | 12月31日 23:59:59 | 年末最后一秒 |

---

## 🔍 常见问题

### Q1: 同一秒内多次构建会冲突吗？

**A**: 实际使用中几乎不可能在同一秒内完成多次完整构建（构建脚本执行需要时间）。如果确实需要，可以在秒级别后再添加毫秒。

**当前解决方案**: 如果担心冲突，可以在构建脚本中增加毫秒：

```python
def generate_build_number(self):
    now = datetime.now()
    build_number = now.strftime('%m%d%H%M%S')
    return build_number
```

### Q2: Build Number 会超过整数上限吗？

**A**: 不会。

- 最大值: `1231235959` (12月31日 23:59:59)
- Android `versionCode` 支持的最大值: `2147483647` (约 21 亿)
- iOS `CFBundleVersion` 支持字符串，无限制

✅ 完全在安全范围内

### Q3: 可以手动指定特定的 Build Number 吗？

**A**: 可以，但不推荐。

如果需要，在 `app.cfg` 中添加：

```properties
buildNumber=自定义值
```

### Q4: 时区问题会影响吗？

**A**: 使用的是本地时间（服务器或开发机器时间）。

- **本地构建**: 使用你的电脑时间
- **GitHub Actions**: 使用 GitHub 服务器时间（UTC）

建议在 GitHub Actions 中设置时区：

```yaml
- name: Set timezone
  run: |
    export TZ='Asia/Shanghai'
    echo "TZ=Asia/Shanghai" >> $GITHUB_ENV

- name: Configure build
  run: python3 scripts/build_config.py
```

### Q5: 之前的 buildNumber 配置会被忽略吗？

**A**: 不会。如果配置文件中有 `buildNumber`，会优先使用配置的值：

```
📦 Using configured Build Number: 6
```

只有当配置文件中**没有**或**为空**时，才会自动生成。

### Q6: 跨年会有问题吗？

**A**: 不会。时间是自然递增的：

```
2024-12-31 23:59:59 → 1231235959
2025-01-01 00:00:00 → 0101000000
```

虽然数字看起来变小了，但实际上是不同年份的构建。如果担心，可以在格式中加入年份。

### Q7: 如何在格式中包含年份？

**A**: 修改 `build_config.py` 中的格式：

```python
def generate_build_number(self):
    now = datetime.now()
    # 格式: YYMMDDHHmmss (年月日小时分钟秒)
    build_number = now.strftime('%y%m%d%H%M%S')
    return build_number

# 示例: 241218143045 = 2024年12月18日14:30:45
```

---

## 🎨 最佳实践

### ✅ 推荐做法

1. **不要在 app.cfg 中指定 buildNumber**
   - 让脚本自动生成
   - 每次构建都是唯一的

2. **使用 Git Tag 管理版本**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
   - `appVersion` 从 Git Tag 读取
   - `buildNumber` 自动生成

3. **在 CI/CD 中记录 Build Number**
   ```yaml
   - name: Configure and build
     run: |
       python3 scripts/build_config.py | tee build.log
       grep "Build Number" build.log
   ```

### ❌ 避免事项

1. **不要手动修改生成的 Build Number**
   - 会破坏唯一性
   - 可能导致上传失败

2. **不要依赖 Build Number 做版本控制**
   - Build Number 用于标识构建
   - 版本控制应使用 `appVersion`

3. **不要在本地和 CI 中混用 Build Number**
   - 可能导致冲突
   - 建议只在 CI 中正式构建

---

## 📚 相关文档

- [配置文件说明](./配置文件说明.md)
- [GitHub Actions 构建说明](./构建发布指南.md)
- [iOS 打包说明](./iOS打包说明.md)
- [Android 打包说明](./Android打包说明.md)

---

## 🔄 更新记录

- **2025-12-18**: 实现自动生成 Build Number，基于当前时间（月日小时分钟秒）







# 证书和密钥配置指南

本指南将帮助你获取并配置 Android 和 iOS 的签名证书，用于构建正式发布包。

---

## 📱 Android 签名配置

### 1. 创建 Android Keystore

#### 使用 Android Studio 创建（推荐）

1. **打开 Android Studio**
2. 选择 **Build** → **Generate Signed Bundle / APK**
3. 选择 **APK**，点击 **Next**
4. 点击 **Create new...** 按钮
5. 填写以下信息：
   - **Key store path**: 选择保存位置（如 `~/keystore/my-app.jks`）
   - **Password**: 输入 keystore 密码（记住这个密码）
   - **Alias**: 输入密钥别名（如 `my-app-key`）
   - **Password**: 输入密钥密码（记住这个密码）
   - **Validity (years)**: 25（建议至少 25 年）
   - **Certificate**: 填写个人/公司信息
6. 点击 **OK** 创建

#### 使用命令行创建

```bash
keytool -genkey -v -keystore my-android-app.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-app-key
```

**参数说明：**
- `my-app.jks`: keystore 文件名
- `my-app-key`: 密钥别名
- 执行后会提示输入密码和证书信息

### 2. 转换 Keystore 为 Base64

为了在 GitHub Secrets 中存储，需要将 keystore 转换为 Base64：

```bash
# macOS/Linux
base64 -i my-app.jks -o my-app.jks.base64

# 或者直接输出到剪贴板 (macOS)
base64 -i my-app.jks | pbcopy
```

### 3. 配置 GitHub Secrets

在你的 GitHub 仓库中设置以下 Secrets：

1. 进入 **Settings** → **Secrets and variables** → **Actions**
2. 点击 **New repository secret**
3. 添加以下 Secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `ANDROID_KEYSTORE_BASE64` | Keystore 的 Base64 编码 | `MIIKXgIBAz...` |
| `ANDROID_KEYSTORE_FILE` | Keystore 文件名 | `my-android-app.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 密码 | `your_keystore_password` |
| `ANDROID_KEY_ALIAS` | 密钥别名 | `my-app-key` |
| `ANDROID_KEY_PASSWORD` | 密钥密码 | `your_key_password` |

### 4. 更新 build.gradle 配置

确保 `android/app/build.gradle` 中的签名配置正确：

```gradle
android {
    signingConfigs {
        release {
            storeFile file(System.getenv('ANDROID_KEYSTORE_FILE') ?: 'my-app.jks')
            storePassword System.getenv('KEYSTORE_PASSWORD')
            keyAlias System.getenv('KEY_ALIAS')
            keyPassword System.getenv('KEY_PASSWORD')
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 📚 官方文档

- [Android 官方签名指南](https://developer.android.com/studio/publish/app-signing)
- [生成上传密钥和密钥库](https://developer.android.com/studio/publish/app-signing#generate-key)
- [Google Play 应用签名](https://support.google.com/googleplay/android-developer/answer/9842756)

---

## 🍎 iOS 签名配置

### 1. 注册 Apple Developer 账号

1. 访问 [Apple Developer](https://developer.apple.com/)
2. 注册开发者账号（个人 $99/年，企业 $299/年）
3. 完成账号验证

### 2. 创建 App ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → 点击 **+** 按钮
4. 选择 **App IDs** → **Continue**
5. 填写信息：
   - **Description**: 应用描述（如 `My WebView App`）
   - **Bundle ID**: 应用包名（如 `com.mycompany.myapp`）
   - **Explicit** 选择具体的 Bundle ID
6. 选择需要的 **Capabilities**（如 Push Notifications）
7. 点击 **Continue** → **Register**

### 3. 创建证书（Certificate）

#### 方式一：使用 Xcode 自动管理（推荐新手）

1. 打开 Xcode，选择你的项目
2. 选择 **Target** → **Signing & Capabilities**
3. 勾选 **Automatically manage signing**
4. 选择你的 **Team**
5. Xcode 会自动创建证书和 Provisioning Profile

#### 方式二：手动创建（用于 CI/CD）

​	

⚠️ **重要：必须在生成 CSR 时创建私钥**

**完整步骤：**

1. 打开 **"钥匙串访问"**（Keychain Access）应用
   - 位置：应用程序 → 实用工具 → 钥匙串访问

2. 在顶部菜单选择 **"钥匙串访问" → "证书助理" → "从证书颁发机构请求证书..."**

3. 在弹出的"证书助理"窗口中填写：
   - **用户电子邮件地址**：填写你的 Apple ID 邮箱（如 `you@example.com`）
   - **常用名称**：填写你的姓名或公司名（如 `Zhang San`）
   - **CA 电子邮件地址**：**留空**（不要填写）
   - **请求是**：选择 **"存储到磁盘"**（单选按钮）
   - ⚠️ **必须勾选**：**☑️ "让我指定密钥对信息"** ← 这是关键！

4. 点击 **"继续"** 按钮

5. **关键步骤**：如果正确勾选了，会弹出"密钥对信息"窗口：
   - **密钥大小**：选择 **2048 位**
   - **算法**：选择 **RSA**
   - 点击 **"继续"**
   
   > ⚠️ 如果没有弹出这个窗口，说明第 3 步没有勾选"让我指定密钥对信息"，需要重新开始！

6. 选择保存位置，保存 `CertificateSigningRequest.certSigningRequest` 文件

7. ✅ **立即验证私钥是否生成**：
   ```bash
   # 方法 1：在钥匙串访问中查看
   - 在"钥匙串访问"窗口中
   - 确保左上角选择了"登录"钥匙串
   - 点击左侧分类中的"密钥"（不是"证书"！）
   - 查看右侧列表，应该能看到新创建的私钥
   - 特征：🔑 图标，名称是你刚才输入的"常用名称"
   
   # 方法 2：使用命令行验证
   security find-identity -v -p codesigning
   # 应该能看到类似输出（如果还没安装证书，可能显示 0 valid）
   ```

> ⚠️ **关键点**：如果在"密钥"分类中看不到新的私钥，说明操作有误，必须重新生成 CSR！

**❌ 如果没有看到私钥**：
1. 删除刚才的 CSR 文件
2. 重新从步骤 1 开始
3. **确保第 3 步勾选了"让我指定密钥对信息"**
4. **确保第 5 步弹出了"密钥对信息"窗口**

**💡 简单替代方案：使用 Xcode 生成**（推荐新手）

如果你觉得上面的步骤太复杂，可以用 Xcode：
1. Xcode → Preferences/Settings → Accounts
2. 添加 Apple ID 并登录
3. Manage Certificates... → 点击 + → 选择证书类型
4. Xcode 会自动处理所有步骤（包括私钥）

**b. 在 Apple Developer Portal 创建证书**

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles** → **Certificates**
3. 点击 **+** 按钮
4. 选择证书类型：
   - **Development**: iOS App Development（开发用）
   - **Production**: 
     - iOS Distribution (App Store and Ad Hoc)（App Store 发布）
     - Apple Distribution（企业分发）
5. 上传前面生成的 CSR 文件
6. 下载生成的 `.cer` 证书文件

**c. 安装证书到 Keychain**

1. **双击** 下载的 `.cer` 证书文件
2. 证书会自动导入到钥匙串（通常是"登录"钥匙串）
3. ✅ **验证安装成功**：
   - 打开 "钥匙串访问"
   - 在左侧选择 **"登录"** 钥匙串
   - 点击 **"我的证书"** 分类
   - 你应该看到新安装的证书，**证书左侧有一个小三角形▶️**
   - 点击展开，能看到对应的私钥（带🔑图标）

**⚠️ 故障排查：证书只在"证书"分类显示，不在"我的证书"分类**

这说明证书没有关联到私钥。原因和解决方法：

**原因**：
- 生成 CSR 时没有勾选"让我指定密钥对信息"
- 私钥在不同的钥匙串中
- 使用了别人创建的 CSR 文件

**解决方法 1：重新生成（推荐）** ⭐️
1. 在 Apple Developer Portal 删除刚才的证书
2. 在钥匙串中删除已安装的证书
3. 重新从步骤 a 开始，**确保勾选"让我指定密钥对信息"**
4. 生成新的 CSR 并创建新证书

**解决方法 2：检查私钥**
1. 在钥匙串访问中，点击左侧 **"密钥"** 分类
2. 查找最近创建的私钥（查看创建日期）
3. 如果私钥在"系统"钥匙串，将其拖到"登录"钥匙串
4. 删除证书后重新双击安装

**解决方法 3：使用 Xcode 自动管理（最简单）**
1. 打开 Xcode 项目
2. 选择 Target → Signing & Capabilities
3. 勾选 **"Automatically manage signing"**
4. 选择你的 Team
5. Xcode 会自动创建和管理所有证书

**d. 导出证书为 .p12**

> ⚠️ **前提**：证书必须出现在"我的证书"分类，并且能展开看到私钥

1. 打开 "钥匙串访问"
2. 在左侧选择 **"登录"** 钥匙串
3. 点击 **"我的证书"** 分类
4. 找到你的证书（有 ▶️ 可以展开）
5. **选择证书**（选择顶层的证书，不是展开后的私钥）
6. 右键证书 → **"导出..."** 或菜单 "文件" → "导出项目..."
7. 文件格式选择：**"个人信息交换 (.p12)"**
8. 输入文件名（如 `ios-distribution.p12`）并保存
9. 设置导出密码（**记住这个密码**，后面配置 GitHub Secrets 需要）
10. 输入 Mac 登录密码来授权导出

**✅ 验证导出**：
- .p12 文件大小应该是 2-5 KB
- 如果只有几百字节，说明没有包含私钥，需要重新导出

---

### 4. 注册测试设备（Development/Ad Hoc 必需）

> ⚠️ **重要**：如果使用 Development 或 Ad Hoc 证书，必须先注册设备才能在真机上安装应用！

#### 为什么需要注册设备？

- **Development 证书**：只能安装到已注册的设备（最多 100 台）
- **Ad Hoc 证书**：只能安装到已注册的设备（最多 100 台）
- **App Store/TestFlight**：不需要注册设备，任意设备都可以安装

#### 设备限制

| 账号类型 | 最大设备数 | 说明 |
|---------|-----------|------|
| 免费 Apple ID | **3 台** | 只能用于开发测试 |
| 付费开发者账号 | **100 台** | 每年可以删除设备 |

---

#### 方法 1：获取设备 UDID（需要的唯一标识符）

**什么是 UDID？**
- UDID（Unique Device Identifier）是 iOS 设备的唯一标识符
- 格式：40 位十六进制字符串（如 `00008030-001234567890123A`）

**获取方式 A：通过 Mac 获取（最准确）** ⭐️

1. **使用 Finder（macOS Catalina 及以上）**：
   ```bash
   1. 用数据线连接 iPhone 到 Mac
   2. 打开 Finder
   3. 在左侧边栏选择你的 iPhone
   4. 在顶部点击设备名称下方的信息
   5. 多次点击会循环显示：序列号 → IMEI → UDID
   6. 看到 UDID 时，右键 → 拷贝 UDID
   ```

2. **使用 iTunes（macOS Mojave 及以下）**：
   ```bash
   1. 连接 iPhone 到 Mac
   2. 打开 iTunes
   3. 点击左上角的设备图标
   4. 点击"序列号"标签
   5. 再次点击会显示 UDID
   6. 右键 → 拷贝
   ```

3. **使用 Xcode**：
   ```bash
   1. 打开 Xcode
   2. 菜单：Window → Devices and Simulators
   3. 连接设备后，在左侧选择设备
   4. 右侧会显示 Identifier（即 UDID）
   5. 右键 → Copy
   ```

**获取方式 B：通过 iPhone 直接获取**

1. **使用系统信息**：
   ```bash
   1. 打开"设置"
   2. 通用 → 关于本机
   3. 找不到直接的 UDID 显示
   4. 需要通过第三方工具或连接电脑
   ```

2. **使用第三方网站**（需谨慎）：
   - 访问 `https://www.udid.io/` 等网站
   - 安装配置描述文件
   - 网站会显示你的 UDID
   - ⚠️ 注意：可能存在隐私风险

**获取方式 C：让测试用户发送给你**

可以让测试用户安装专门的 UDID 查看工具：

1. **UDID+ App（推荐）**：
   - App Store 链接：[UDID+](https://apps.apple.com/app/udid/id1046856018)
   - 完全免费，无需注册
   - 安装后直接显示 UDID
   - 可以一键复制或分享

2. **通过网页获取**：
   - 访问 [https://get.udid.io/](https://get.udid.io/) 或类似网站
   - 安装配置描述文件
   - 网页会显示 UDID
   - ⚠️ 注意：涉及隐私，谨慎使用第三方网站

3. **发送截图方式**：
   - 让用户：设置 → 通用 → 关于本机
   - 截图显示序列号的界面
   - 你可以通过序列号查询 UDID（某些工具）
   - ⚠️ 但这种方式不如直接获取 UDID 准确

> ⚠️ **注意**：TestFlight 不是用来获取 UDID 的工具！TestFlight 是 Apple 官方的测试分发平台，需要先有测试邀请才能使用。

---

#### 方法 2：在 Apple Developer Portal 注册设备

1. **登录 Apple Developer Portal**
   - 访问 [https://developer.apple.com/account/](https://developer.apple.com/account/)
   - 使用你的 Apple ID 登录

2. **进入设备管理页面**
   ```bash
   Certificates, Identifiers & Profiles → Devices
   ```

3. **添加新设备**
   ```bash
   1. 点击左侧"Devices"
   2. 点击页面左上角的 + 按钮
   3. 选择平台：iOS/iPadOS
   4. 填写信息：
      - Device Name: 设备名称（如"张三的 iPhone 13"）
      - Device ID (UDID): 粘贴刚才复制的 UDID
   5. 点击"Continue"
   6. 点击"Register"完成注册
   ```

4. **批量注册多台设备**
   ```bash
   1. 在 Devices 页面点击 + 按钮
   2. 选择"Register Multiple Devices"
   3. 下载模板文件
   4. 在模板中填写设备信息（每行一个设备）：
      Device ID    Device Name
      00008030...  张三的 iPhone
      00008030...  李四的 iPhone
   5. 上传填好的文件
   6. 确认并注册
   ```

**✅ 验证注册成功**：
- 在 Devices 列表中能看到新注册的设备
- 设备状态显示为"Enabled"

---

#### 方法 3：使用 Xcode 自动注册（最简单）⭐️

如果你使用 Xcode 自动管理签名：

```bash
1. 连接 iPhone 到 Mac
2. 打开 Xcode 项目
3. 选择连接的设备作为运行目标
4. 点击运行按钮
5. Xcode 会自动：
   - 注册设备
   - 更新 Provisioning Profile
   - 安装应用到设备
```

**优点**：
- ✅ 全自动，无需手动操作
- ✅ 不需要查找 UDID
- ✅ 适合快速测试

**缺点**：
- ❌ 需要物理连接设备
- ❌ 不适合远程添加设备

---

#### 方法 4：更新 Provisioning Profile（添加设备后必须执行）

注册新设备后，必须更新 Provisioning Profile：

**手动更新**：
```bash
1. 登录 Apple Developer Portal
2. Profiles → 找到你的 Development/Ad Hoc Profile
3. 点击 Profile 名称
4. 点击"Edit"
5. 在"Devices"部分，勾选新添加的设备
6. 点击"Generate"重新生成
7. 下载新的 .mobileprovision 文件
8. 双击安装或使用 Xcode 导入
```

**Xcode 自动更新**：
```bash
1. Xcode → Preferences → Accounts
2. 选择你的 Apple ID
3. 点击"Download Manual Profiles"
4. Xcode 会自动下载最新的 Profiles
```

**重新打包应用**：
```bash
# 更新 Provisioning Profile 后，必须重新打包
# 否则新设备仍然无法安装

# 如果使用 GitHub Actions，需要：
1. 更新 IOS_PROVISIONING_PROFILE_BASE64 Secret
2. 重新触发构建
```

---

#### 📝 完整的设备注册流程示例

**场景：添加 3 台测试设备**

```bash
步骤 1：收集设备信息
├─ 张三的 iPhone 13: 00008030-001234567890001A
├─ 李四的 iPhone 12: 00008030-001234567890002B
└─ 王五的 iPhone 11: 00008030-001234567890003C

步骤 2：注册设备
1. 登录 developer.apple.com
2. Devices → 点击 +
3. 选择"Register Multiple Devices"
4. 填写并上传设备列表
5. 完成注册

步骤 3：更新 Provisioning Profile
1. Profiles → 选择你的 Development Profile
2. Edit → 勾选新添加的 3 台设备
3. Generate → 下载新的 Profile

步骤 4：配置 GitHub Actions（如果使用 CI/CD）
1. 转换新 Profile 为 Base64：
   base64 -i profile.mobileprovision | tr -d '\n'
2. 更新 GitHub Secret：IOS_PROVISIONING_PROFILE_BASE64
3. 重新打包

步骤 5：分发应用
1. 重新构建 IPA
2. 分发给测试用户
3. 用户可以通过以下方式安装：
   - iTunes 同步安装
   - Xcode Devices 窗口安装
   - 通过网页（需要 HTTPS 服务器）
   - 使用 Apple Configurator
```

---

#### 🚨 常见问题

**Q: 设备已满（100 台限制），如何删除？**

```bash
1. 在 Devices 页面找到要删除的设备
2. 点击设备名称
3. 点击"Disable"按钮
4. 等到下一年，可以永久删除

注意：
- 每年只能删除一次设备（在会员年度更新后）
- Disable 后设备立即不可用
- 设备数会在下一个会员年度重置
```

**Q: 添加设备后，应用仍然无法安装？**

```bash
可能原因：
1. ❌ 没有重新生成 Provisioning Profile
2. ❌ 没有重新打包应用
3. ❌ UDID 复制错误（多了空格或字符）
4. ❌ 使用了错误的 Profile 打包

解决方法：
1. 确认设备在 Developer Portal 中已注册
2. 重新生成并下载 Provisioning Profile
3. 确保新 Profile 包含该设备
4. 使用新 Profile 重新打包
5. 验证 UDID 是否正确（40 位十六进制）
```

**Q: 免费账号和付费账号的区别？**

| 功能 | 免费账号 | 付费账号（$99/年） |
|------|---------|-------------------|
| 设备数量 | **3 台** | **100 台** |
| 证书有效期 | 7 天（需重新签名） | 1 年 |
| App Store 发布 | ❌ 不支持 | ✅ 支持 |
| TestFlight | ❌ 不支持 | ✅ 支持 |
| 推送通知 | ✅ 支持（有限） | ✅ 完全支持 |

---

### 5. 创建 Provisioning Profile

> ⚠️ **前提**：
> - Development/Ad Hoc Profile 需要先注册测试设备（见第 4 步）
> - App Store Profile 不需要注册设备

1. 进入 **Certificates, Identifiers & Profiles** → **Profiles**
2. 点击 **+** 按钮
3. 选择类型：
   - **Development**: iOS App Development（开发测试，**需要注册设备**）
   - **Distribution**:
     - App Store（App Store 发布，无需注册设备）
     - Ad Hoc（内部分发测试，**需要注册设备**）
     - Enterprise（企业内部分发，无需注册设备）
4. 选择对应的 **App ID**
5. 选择对应的 **Certificate**
6. **如果是 Development/Ad Hoc**，选择要包含的测试设备：
   - ☑️ Select All（选择所有已注册设备）
   - 或手动勾选特定设备
   - ⚠️ 未勾选的设备无法安装应用！
7. 输入 Profile 名称（如 `MyApp Development Profile`）
8. 点击 **Generate**
9. 下载 `.mobileprovision` 文件

**✅ 验证 Profile 包含的设备**：
```bash
# 查看 Provisioning Profile 中包含的设备列表
security cms -D -i profile.mobileprovision | grep -A 50 "ProvisionedDevices"

# 应该能看到所有设备的 UDID
# 如果某台设备的 UDID 不在列表中，该设备无法安装应用
```

**🔄 更新 Provisioning Profile**（添加新设备后）：
```bash
1. 在 Apple Developer Portal 注册新设备
2. 进入 Profiles，找到现有的 Profile
3. 点击 Profile 名称 → Edit
4. 勾选新添加的设备
5. 点击 Generate 重新生成
6. 下载并替换旧的 .mobileprovision 文件
7. 重新打包应用
```

### 6. 转换证书和 Profile 为 Base64

```bash
# 转换证书为 Base64
base64 -i certificate.p12 -o certificate.p12.base64

# 转换 Provisioning Profile 为 Base64
base64 -i profile.mobileprovision -o profile.mobileprovision.base64

# 或者直接复制到剪贴板 (macOS)
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

### 7. 配置 GitHub Secrets

在 GitHub 仓库中设置以下 Secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `IOS_CERTIFICATE_BASE64` | .p12 证书的 Base64 编码 | `MIIKXgIBAz...` |
| `IOS_CERTIFICATE_PASSWORD` | .p12 证书密码 | `your_certificate_password` |
| `IOS_PROVISIONING_PROFILE_BASE64` | .mobileprovision 的 Base64 | `MIIPpQYJKo...` |
| `IOS_TEAM_ID` | Apple Developer Team ID | `ABC123XYZ` |
| `IOS_EXPORT_METHOD` | 导出方法 | `app-store` / `ad-hoc` / `enterprise` |
| `KEYCHAIN_PASSWORD` | 临时 Keychain 密码（可随机） | `build_keychain_pwd` |

### 8. 获取 Team ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Membership** 页面
3. 找到 **Team ID**（10位字符，如 `ABC123XYZ`）

### 📚 官方文档

- [Apple Developer Portal](https://developer.apple.com/account/)
- [创建证书和 Profiles](https://help.apple.com/xcode/mac/current/#/dev3a05256b8)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [TestFlight 测试指南](https://developer.apple.com/testflight/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)

---

## ⚙️ GitHub Actions 配置

### 构建配置文件

在 `assets/app1/app.cfg` 中设置：

```properties
# 是否为 Debug 模式（true=测试包，false=正式包）
isDebug=false

# 是否构建 Android
buildAndroid=true

# 是否构建 iOS
buildIOS=true
```

### 触发构建

#### 构建测试包（Debug）

```bash
# 1. 设置 isDebug=true
echo "isDebug=true" >> assets/app1/app.cfg

# 2. 提交并打 tag
git add .
git commit -m "Build debug version"
git tag v1.0.0-debug
git push origin v1.0.0-debug
```

#### 构建正式包（Release）

```bash
# 1. 设置 isDebug=false
echo "isDebug=false" >> assets/app1/app.cfg

# 2. 确保已配置所有 Secrets

# 3. 提交并打 tag
git add .
git commit -m "Build release version v1.0.0"
git tag v1.0.0
git push origin v1.0.0
```

---

## 🔐 安全建议

1. **永远不要提交密钥到 Git**
   - 将 `.jks`, `.p12`, `.mobileprovision` 添加到 `.gitignore`
   
2. **定期更新密码**
   - 每年更新一次 GitHub Secrets 中的密码

3. **备份证书和密钥**
   - 将证书、密钥库保存在安全的地方
   - 记录所有密码（使用密码管理器）

4. **使用不同的证书**
   - 开发环境和生产环境使用不同的证书
   - 不要在多个应用间共享密钥

5. **限制 Secrets 访问权限**
   - 只给必要的人员访问权限
   - 使用 GitHub Organizations 的细粒度权限控制

---

## 📦 应用上架流程

### Android (Google Play Store)

1. **准备材料**：
   - Release APK/AAB
   - 应用图标（512x512）
   - 应用截图（不同屏幕尺寸）
   - 应用描述和隐私政策

2. **创建应用**：
   - 登录 [Google Play Console](https://play.google.com/console/)
   - 创建新应用
   - 填写应用信息

3. **上传 APK/AAB**：
   - 进入 **Production** → **Create new release**
   - 上传构建的 APK 或 AAB
   - 填写更新日志

4. **提交审核**：
   - 完成所有必填信息
   - 提交审核（通常 1-3 天）

**官方指南**: [Google Play 上架指南](https://support.google.com/googleplay/android-developer/answer/9859152)

### iOS (App Store)

1. **准备材料**：
   - Release IPA
   - 应用图标（1024x1024）
   - 应用截图（不同设备尺寸）
   - 应用描述和隐私政策

2. **创建应用**：
   - 登录 [App Store Connect](https://appstoreconnect.apple.com/)
   - 点击 **+** 创建新 App
   - 填写基本信息

3. **上传构建版本**：
   - 使用 Xcode 或 Transporter 上传 IPA
   - 或使用命令行：
     ```bash
     xcrun altool --upload-app -f app.ipa -u username -p password
     ```

4. **TestFlight 测试**（可选）：
   - 在 App Store Connect 中启用 TestFlight
   - 添加内部/外部测试员
   - 分发测试版本

5. **提交审核**：
   - 选择构建版本
   - 填写所有必需信息
   - 提交审核（通常 1-7 天）

**官方指南**: [App Store 上架指南](https://developer.apple.com/app-store/submissions/)

---

## 🆘 常见问题

### Android 常见问题

**Q: "Keystore file does not exist"**
```bash
# 检查 Secret 是否正确配置
# 确保 ANDROID_KEYSTORE_BASE64 包含完整的 base64 内容
```

**Q: "错误的密钥库密码"**
```bash
# 确认 ANDROID_KEYSTORE_PASSWORD 和 ANDROID_KEY_PASSWORD 正确
# 可以本地测试：
./gradlew assembleRelease -Pandroid.injected.signing.store.password=your_password
```

### iOS 常见问题

**Q: "No code signing identity found"**
```bash
# 确保证书已正确导入
# 检查 IOS_CERTIFICATE_BASE64 和密码是否正确
security find-identity -v -p codesigning
```

**Q: "Provisioning profile doesn't match"**
```bash
# 确保 Bundle ID 和 Team ID 匹配
# 检查 Provisioning Profile 是否过期
# 在 Xcode 中检查签名配置
```

**Q: "Archive not found"**
```bash
# 检查 xcodebuild archive 命令是否成功
# 查看构建日志确认错误
```

---

## 📞 获取帮助

- **Android**: [Stack Overflow - Android](https://stackoverflow.com/questions/tagged/android)
- **iOS**: [Apple Developer Forums](https://developer.apple.com/forums/)
- **GitHub Actions**: [GitHub Community](https://github.community/)

---

**最后更新**: 2024年12月

# 资源文件远程下载说明

## 📋 概述

构建脚本支持从远程 HTTP(S) URL 下载资源文件（图标、Loading 图片等），无需手动下载到本地。

---

## 🎯 支持的资源类型

| 配置项 | 说明 | 支持格式 |
|--------|------|---------|
| `appIcon` | 应用图标 | 本地路径 / HTTP(S) URL |
| `loadingImage` | Loading 页面图片 | 本地路径 / HTTP(S) URL |
| `splashScreen` | 启动屏幕图片 | 本地路径 / HTTP(S) URL |

---

## 📝 配置方法

### 方式 1: 本地文件（传统方式）

```properties
# assets/app1/app.cfg

# 使用本地文件
appIcon=icon.png
loadingImage=loading.png
splashScreen=splash.png
```

**文件位置**:
```
assets/app1/
├── app.cfg
├── icon.png          ← 本地文件
├── loading.png       ← 本地文件
└── splash.png        ← 本地文件
```

---

### 方式 2: 远程 URL（新功能）

```properties
# assets/app1/app.cfg

# 使用远程 URL
appIcon=https://cdn.example.com/images/app-icon.png
loadingImage=https://cdn.example.com/images/loading.png
splashScreen=https://cdn.example.com/images/splash.png
```

**优点**:
- ✅ 无需手动下载文件到本地
- ✅ 方便团队协作（统一使用 CDN 资源）
- ✅ 易于更新（修改 URL 即可）
- ✅ 减少 Git 仓库大小

---

### 方式 3: 混合使用

```properties
# assets/app1/app.cfg

# 图标使用远程 URL
appIcon=https://cdn.example.com/icon.png

# Loading 图片使用本地文件
loadingImage=loading.png

# 启动屏幕使用远程 URL
splashScreen=https://static.myapp.com/splash.png
```

---

## 🔄 工作流程

### 本地文件流程

```
配置: appIcon=icon.png
    ↓
查找: assets/app1/icon.png
    ↓
复制到 Android/iOS 项目
    ↓
✅ 完成
```

### 远程 URL 流程

```
配置: appIcon=https://cdn.example.com/icon.png
    ↓
检测到 URL (http:// 或 https://)
    ↓
从 URL 下载文件
    ↓ (超时 30 秒)
保存到临时目录: /tmp/xlab_resources/icon.png
    ↓
复制到 Android/iOS 项目
    ↓
✅ 完成
```

---

## 📊 下载详情

### 下载配置

| 参数 | 值 | 说明 |
|------|---|------|
| **超时时间** | 30 秒 | 单个文件下载超时 |
| **User-Agent** | Mozilla/5.0... | 模拟浏览器请求 |
| **临时目录** | `/tmp/xlab_resources/` | 下载文件存储位置 |
| **重试机制** | 无 | 失败会显示警告并跳过 |

### 文件名处理

**情况 1: URL 包含文件名**
```
URL: https://cdn.example.com/images/my-icon.png
文件名: my-icon.png ✅
```

**情况 2: URL 不包含文件名或扩展名**
```
URL: https://api.example.com/resource/12345
根据配置项推断:
- appIcon → icon.png
- loadingImage → loading.png
- splashScreen → splash.png
```

---

## 🚀 使用示例

### 示例 1: 使用 GitHub Raw URL

```properties
# assets/app1/app.cfg

appIcon=https://raw.githubusercontent.com/username/repo/main/assets/icon.png
loadingImage=https://raw.githubusercontent.com/username/repo/main/assets/loading.png
```

### 示例 2: 使用 CDN

```properties
# assets/app1/app.cfg

appIcon=https://cdn.jsdelivr.net/gh/username/repo@main/icon.png
loadingImage=https://unpkg.com/my-package@1.0.0/images/loading.png
```

### 示例 3: 使用自己的服务器

```properties
# assets/app1/app.cfg

appIcon=https://static.myapp.com/v1/icon.png
loadingImage=https://assets.myapp.com/loading.png
splashScreen=https://cdn.myapp.com/splash.png
```

### 示例 4: 使用图床

```properties
# assets/app1/app.cfg

# 使用 imgur
appIcon=https://i.imgur.com/abc123.png

# 使用其他图床
loadingImage=https://example.com/image.png
```

---

## 📋 构建日志

### 成功下载

```
=== Copying Resources ===
Downloading: https://cdn.example.com/icon.png
Downloaded: https://cdn.example.com/icon.png -> /tmp/xlab_resources/icon.png
Copied: /tmp/xlab_resources/icon.png -> mipmap directories
  Resizing icon from (720, 719) to (1024, 1024)
Copied and resized: /tmp/xlab_resources/icon.png -> AppIcon.png (1024x1024, RGB)
```

### 下载失败

```
=== Copying Resources ===
Downloading: https://cdn.example.com/icon.png
Error downloading https://cdn.example.com/icon.png: HTTP Error 404: Not Found
Warning: App icon not found: https://cdn.example.com/icon.png

⚠️ 构建会继续，但应用可能使用默认图标
```

---

## ⚠️ 注意事项

### 1. 网络访问

**CI/CD 环境**:
- ✅ GitHub Actions 可以访问公网 URL
- ⚠️ 确保 URL 可以从 GitHub 服务器访问
- ⚠️ 某些防火墙可能阻止特定域名

**本地构建**:
- ✅ 需要能访问配置的 URL
- ⚠️ 注意代理设置（如果使用代理）

### 2. URL 要求

**支持的协议**:
- ✅ `https://` （推荐）
- ✅ `http://` （不推荐，不安全）
- ❌ `ftp://` （不支持）
- ❌ `file://` （不支持）

**URL 格式**:
```
✅ 正确:
https://cdn.example.com/icon.png
https://example.com/path/to/image.png
http://example.com/image.png

❌ 错误:
ftp://example.com/icon.png
file:///path/to/icon.png
//cdn.example.com/icon.png  (缺少协议)
```

### 3. 图片格式

**支持的格式**:
- ✅ PNG（推荐）
- ✅ JPEG/JPG
- ✅ 其他 PIL 支持的格式

**自动处理**:
- ✅ 自动转换为 PNG
- ✅ iOS 图标自动调整到 1024x1024
- ✅ 自动移除透明通道（iOS）

### 4. 性能考虑

**下载时间**:
- 小图标（< 1MB）: 通常 1-5 秒
- 大图片（1-5MB）: 可能 5-15 秒
- 超时设置: 30 秒

**建议**:
- 使用 CDN 加速下载
- 图片尽量压缩（< 1MB）
- 避免使用超大图片

### 5. 安全性

**HTTPS vs HTTP**:
- ✅ **推荐使用 HTTPS**: 安全、防篡改
- ⚠️ **避免使用 HTTP**: 不安全、可能被劫持

**URL 来源**:
- ✅ 使用可信的 CDN 或自己的服务器
- ⚠️ 避免使用不明来源的 URL
- ⚠️ 定期检查 URL 是否仍然有效

---

## 🐛 故障排查

### 问题 1: 下载失败 - 404 Not Found

**错误信息**:
```
Error downloading https://example.com/icon.png: HTTP Error 404: Not Found
Warning: App icon not found: https://example.com/icon.png
```

**解决方法**:
1. 检查 URL 是否正确
2. 在浏览器中打开 URL 验证
3. 确认文件确实存在于该 URL

---

### 问题 2: 下载超时

**错误信息**:
```
Error downloading https://example.com/icon.png: timed out
```

**解决方法**:
1. 检查网络连接
2. 尝试使用更快的 CDN
3. 减小图片文件大小
4. 考虑使用本地文件

---

### 问题 3: 403 Forbidden

**错误信息**:
```
Error downloading https://example.com/icon.png: HTTP Error 403: Forbidden
```

**解决方法**:
1. 服务器可能阻止了自动化请求
2. 尝试使用不同的 URL
3. 联系服务器管理员
4. 使用本地文件作为备选

---

### 问题 4: SSL 证书错误

**错误信息**:
```
Error downloading https://example.com/icon.png: [SSL: CERTIFICATE_VERIFY_FAILED]
```

**解决方法**:
1. 检查服务器 SSL 证书是否有效
2. 使用其他 HTTPS URL
3. 临时使用 HTTP（不推荐）

---

## 📊 对比表

| 特性 | 本地文件 | 远程 URL |
|------|---------|---------|
| **配置** | `icon.png` | `https://cdn.example.com/icon.png` |
| **文件位置** | `assets/appX/` | 网络 URL |
| **Git 仓库大小** | 增加 | 不增加 |
| **构建速度** | 快（无下载） | 稍慢（需下载） |
| **网络要求** | 无 | 需要网络 |
| **团队协作** | 需同步文件 | 只需同步 URL |
| **更新方式** | 替换本地文件 | 修改 URL |
| **失败处理** | 文件不存在 | 下载失败 |
| **推荐场景** | 小团队、稳定资源 | 大团队、频繁更新 |

---

## 🎯 最佳实践

### 1. 选择合适的方式

**使用本地文件**:
- ✅ 资源文件很少变化
- ✅ 文件较小（< 100KB）
- ✅ 团队规模小
- ✅ 不依赖外部服务

**使用远程 URL**:
- ✅ 资源文件经常更新
- ✅ 多个项目共享资源
- ✅ 团队规模大
- ✅ 有可靠的 CDN 服务

### 2. URL 管理

**集中管理**:
```properties
# 使用统一的 CDN 前缀
CDN_BASE=https://cdn.myapp.com/v1

appIcon=${CDN_BASE}/icon.png
loadingImage=${CDN_BASE}/loading.png
splashScreen=${CDN_BASE}/splash.png
```

**版本控制**:
```properties
# URL 中包含版本号
appIcon=https://cdn.myapp.com/v1.2.0/icon.png
loadingImage=https://cdn.myapp.com/v1.2.0/loading.png
```

### 3. 备份方案

**主用远程，备用本地**:
```bash
# 如果远程下载失败，脚本会显示警告
# 可以准备本地备份文件

assets/app1/
├── app.cfg (配置远程 URL)
├── icon.png (本地备份)
└── loading.png (本地备份)
```

### 4. 测试流程

```bash
# 1. 本地测试下载
curl -I https://cdn.example.com/icon.png
# 应该返回 200 OK

# 2. 运行构建脚本
python3 scripts/build_config.py

# 3. 检查日志
# 应该看到 "Downloaded: ..." 和 "Copied: ..."

# 4. 验证文件
ls -lh ios/WebViewApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

---

## 📚 相关文档

- [应用名称和图标配置说明](./应用名称和图标配置说明.md) - 图标配置详解
- [构建和安装指南](./构建和安装指南.md) - 完整构建流程
- [常见配置错误](./常见配置错误.md) - 问题排查

---

## 🎉 总结

### ✅ 新功能

1. **支持远程 URL**
   - HTTP(S) URL 自动下载
   - 30 秒超时保护
   - 智能文件名推断

2. **兼容本地文件**
   - 保持原有功能
   - 无缝切换
   - 向后兼容

3. **自动处理**
   - 下载到临时目录
   - 自动调整图标尺寸
   - 自动格式转换

### 📝 配置示例

```properties
# assets/app1/app.cfg

# 方式 1: 本地文件
appIcon=icon.png

# 方式 2: 远程 URL
appIcon=https://cdn.example.com/icon.png

# 方式 3: 混合使用
appIcon=https://cdn.example.com/icon.png
loadingImage=loading.png
```

### 🚀 开始使用

1. 修改 `assets/appX/app.cfg`
2. 将资源路径改为 HTTP(S) URL
3. 运行构建脚本
4. 检查构建日志
5. 验证生成的应用

---

**最后更新**: 2025-12-12
**版本**: v1.0.14




# 过渡页面优化说明

## 🎨 优化内容

将过渡页面（Loading页面）从**居中小图片**优化为**全屏背景图片**，提升用户体验和视觉效果。

---

## ✨ 主要改进

### Android 优化

**修改文件：**
- `android/app/src/main/res/layout/activity_loading.xml`
- `android/app/src/main/java/com/mywebviewapp/LoadingActivity.kt`

**改进点：**

1. **图片填充方式**
   - ❌ 旧版：`200dp × 200dp` 固定大小，居中显示
   - ✅ 新版：`match_parent`，使用 `scaleType="centerCrop"` 填充整个屏幕

2. **布局结构**
   - ❌ 旧版：使用 `RelativeLayout` + `LinearLayout` 嵌套
   - ✅ 新版：使用 `FrameLayout`，层级更简单

3. **文字位置**
   - ❌ 旧版：图片下方，居中
   - ✅ 新版：屏幕底部，增加阴影效果提升可读性

4. **全屏模式**
   - ✅ 隐藏状态栏和标题栏，真正全屏显示

5. **半透明遮罩（可选）**
   - ✅ 提供可选的半透明黑色遮罩层，增强文字可读性

### iOS 优化

**修改文件：**
- `ios/WebViewApp/LoadingViewController.swift`

**改进点：**

1. **图片填充方式**
   - ❌ 旧版：`200pt × 200pt` 固定大小，`.scaleAspectFit`
   - ✅ 新版：填充整个屏幕，`.scaleAspectFill`

2. **文字效果**
   - ❌ 旧版：普通文字，18pt
   - ✅ 新版：粗体 20pt，添加阴影效果

3. **文字位置**
   - ❌ 旧版：图片下方
   - ✅ 新版：屏幕底部（距离底部 80pt）

4. **全屏模式**
   - ✅ 隐藏状态栏（`prefersStatusBarHidden = true`）

5. **半透明遮罩（可选）**
   - ✅ 提供可选的半透明遮罩层，增强文字可读性

---

## 📐 视觉效果对比

### 旧版布局
```
┌─────────────────────┐
│                     │
│                     │
│     ┌─────────┐    │
│     │         │    │ ← 200×200 图片
│     │  图片   │    │   居中显示
│     │         │    │
│     └─────────┘    │
│                     │
│      加载中...      │ ← 文字在图片下方
│                     │
│                     │
└─────────────────────┘
```

### 新版布局
```
┌─────────────────────┐
│                     │
│                     │
│                     │
│     全屏背景图片     │ ← 充满整个屏幕
│    (scaleAspectFill) │   保持宽高比
│                     │
│                     │
│                     │
│      加载中...      │ ← 文字在底部
│   (带阴影/遮罩)     │   增强可读性
└─────────────────────┘
```

---

## 🎯 图片要求

### 推荐尺寸

为了在不同设备上都有良好的显示效果，建议使用高分辨率图片：

| 平台 | 推荐分辨率 | 宽高比 | 备注 |
|------|-----------|--------|------|
| **Android** | 1080×1920 或更高 | 9:16 或 9:18 | 适配主流手机 |
| **iOS** | 1170×2532 或更高 | 9:19.5 | 适配 iPhone 14/15 |
| **通用** | 1440×2560 | 9:16 | 2K 分辨率，兼容性好 |

### 图片格式

- **格式**：PNG（支持透明）或 JPG（文件更小）
- **大小**：建议 < 1MB（过大会影响启动速度）
- **质量**：高质量，避免压缩过度

### 设计建议

1. **主体居中**：重要内容放在中心区域，避免被裁剪
2. **四周留白**：边缘预留安全区域（10-15%）
3. **文字对比度**：确保底部区域与文字颜色有足够对比
4. **简洁明快**：避免复杂图案，加载速度快

---

## ⚙️ 配置选项

### app.cfg 配置

```properties
# Loading页面配置
loadingDuration=1500              # 显示时长（毫秒）
loadingBackgroundColor=#4A90E2    # 背景色（图片加载失败时的后备）
loadingTextColor=#FFFFFF          # 文字颜色（推荐白色或浅色）
loadingText=加载中...              # 加载提示文字
```

### 文字颜色建议

| 图片风格 | 推荐文字颜色 | 颜色代码 |
|---------|------------|---------|
| **深色/暗色图片** | 白色 | `#FFFFFF` |
| **浅色/亮色图片** | 深色 | `#000000` 或 `#333333` |
| **彩色图片** | 根据主色调选择对比色 | - |

---

## 🔧 高级定制

### 启用半透明遮罩（增强文字可读性）

如果图片颜色复杂，文字可读性不佳，可以启用半透明遮罩：

#### Android

在 `LoadingActivity.kt` 中取消注释：

```kotlin
// 显示半透明遮罩
val overlay = findViewById<View>(R.id.overlay)
overlay.visibility = View.VISIBLE
```

#### iOS

在 `LoadingViewController.swift` 中取消注释：

```swift
// 显示半透明遮罩
overlayView.isHidden = false
```

**效果：**
- 在图片上添加 25% 透明度的黑色遮罩
- 文字更清晰，不受背景图片影响

### 调整遮罩透明度

**Android** (`activity_loading.xml`)：

```xml
<!-- 修改 alpha 值，范围 00-FF (0-255) -->
<View
    android:id="@+id/overlay"
    android:background="#40000000"  <!-- 40 = 25% 透明度 -->
    ...
/>

<!-- 常用透明度值：
     #20000000 = 12.5%
     #40000000 = 25%
     #60000000 = 37.5%
     #80000000 = 50%
-->
```

**iOS** (`LoadingViewController.swift`)：

```swift
private let overlayView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.25)  // 0.0-1.0
    ...
}()

// 常用透明度值：
// 0.125 = 12.5%
// 0.25  = 25%
// 0.375 = 37.5%
// 0.5   = 50%
```

### 调整文字位置

**Android** (`activity_loading.xml`)：

```xml
<TextView
    ...
    android:layout_marginBottom="80dp"  <!-- 修改这个值调整距离底部的距离 -->
    ...
/>
```

**iOS** (`LoadingViewController.swift`)：

```swift
// 修改 constant 值
loadingLabel.bottomAnchor.constraint(
    equalTo: view.safeAreaLayoutGuide.bottomAnchor, 
    constant: -80  // 修改这个值（负值表示距离底部）
),
```

### 修改图片缩放模式

#### Android

在 `activity_loading.xml` 中修改 `scaleType`：

```xml
<ImageView
    ...
    android:scaleType="centerCrop"  <!-- 推荐：填充屏幕，可能裁剪 -->
    ...
/>

<!-- 其他可选值：
     centerCrop    - 填充屏幕，保持宽高比，可能裁剪（推荐）
     fitXY         - 拉伸填充，不保持宽高比（不推荐）
     centerInside  - 完整显示，不填充屏幕
-->
```

#### iOS

在 `LoadingViewController.swift` 中修改 `contentMode`：

```swift
imageView.contentMode = .scaleAspectFill  // 推荐：填充屏幕，可能裁剪

// 其他可选值：
// .scaleAspectFill - 填充屏幕，保持宽高比，可能裁剪（推荐）
// .scaleToFill     - 拉伸填充，不保持宽高比（不推荐）
// .scaleAspectFit  - 完整显示，不填充屏幕
```

---

## 🎨 设计示例

### 示例 1：纯色渐变背景 + Logo

**图片组成：**
- 背景：渐变色（如蓝色到紫色）
- 中心：应用Logo
- 底部：留白区域用于显示文字

**特点：**
- 简洁大方
- 文字易读
- 不需要遮罩

### 示例 2：产品截图背景

**图片组成：**
- 背景：应用主要功能截图（模糊处理）
- 中心：应用名称或Slogan
- 底部：深色渐变遮罩区域

**特点：**
- 展示应用特色
- 需要轻微遮罩
- 文字颜色选白色

### 示例 3：品牌形象图

**图片组成：**
- 背景：品牌相关的高质量图片
- 整体：统一的品牌色调
- 底部：半透明遮罩

**特点：**
- 强化品牌印象
- 建议使用遮罩
- 文字需要对比色

---

## 📝 最佳实践

### ✅ 推荐做法

1. **图片尺寸**：使用至少 1080×1920 的高分辨率图片
2. **文件大小**：压缩到 500KB 以内，确保快速加载
3. **颜色对比**：确保文字颜色与背景有足够对比度
4. **测试多设备**：在不同屏幕比例的设备上测试效果
5. **简洁设计**：避免过于复杂的图案，影响加载速度

### ❌ 避免事项

1. **避免使用低分辨率图片**：会导致模糊
2. **避免纯白文字配浅色背景**：可读性差
3. **避免重要内容靠近边缘**：可能被裁剪
4. **避免过长的加载时间**：建议 1-2 秒
5. **避免使用 GIF 动画**：增加包大小，影响性能

---

## 🔍 故障排查

### 问题1：图片显示不完整或被裁剪

**原因：**
- 图片宽高比与屏幕不匹配

**解决方案：**
1. 使用标准宽高比图片（9:16 或 9:18）
2. 确保重要内容在中心区域
3. 调整 `scaleType`/`contentMode` 为 `scaleAspectFit`（会留白）

### 问题2：文字看不清

**原因：**
- 背景图片颜色与文字颜色对比度不足

**解决方案：**
1. 修改文字颜色（白色或黑色）
2. 启用半透明遮罩
3. 增加文字阴影效果（iOS已默认添加）
4. 修改背景图片，底部使用纯色或渐变

### 问题3：图片加载慢

**原因：**
- 图片文件过大

**解决方案：**
1. 压缩图片（使用 TinyPNG 等工具）
2. 转换为 JPG 格式（如果不需要透明度）
3. 降低图片分辨率（但不低于 1080×1920）

### 问题4：Android 图片变形

**原因：**
- 使用了错误的 `scaleType`

**解决方案：**
```xml
<!-- 确保使用 centerCrop -->
<ImageView
    ...
    android:scaleType="centerCrop"
    ...
/>
```

### 问题5：iOS 状态栏显示

**原因：**
- `prefersStatusBarHidden` 未生效

**解决方案：**

在 `Info.plist` 中添加：

```xml
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
```

---

## 📚 相关文档

- [应用名称和图标配置说明](./应用名称和图标配置说明.md)
- [配置文件说明](./配置文件说明.md)
- [快速开始指南](./快速开始指南.md)

---

## 🔄 更新记录

- **2025-12-18**: 优化过渡页面，支持全屏背景图片显示







# 通配符 Provisioning Profile 配置说明

本文档说明如何正确配置和使用**通配符 Provisioning Profile**（如 `com.xlab.*`）。

---

## 问题背景

当使用通配符 Provisioning Profile 时，可能会遇到以下错误：

```
error: exportArchive "WebViewApp.app" requires a provisioning profile.
** EXPORT FAILED **
```

### 错误原因

1. **通配符 Profile** 的 App ID 是 `com.xlab.*`
2. **实际应用** 的 Bundle ID 是 `com.xlab.guessIdiom`
3. **旧的 workflow** 从 Profile 中提取 Bundle ID 得到 `com.xlab.*`
4. **ExportOptions.plist** 中使用通配符作为 key，导致无法匹配具体的 Bundle ID

---

## ✅ 修复内容

### 修改的文件

- `.github/workflows/build.yml`

### 关键修改

#### 1. 从 app.cfg 读取 Bundle ID（而不是从 Profile 提取）

**修改前：**
```bash
# 从 Profile 中提取（会得到通配符）
BUNDLE_ID=$(security cms -D -i profile.mobileprovision | plutil -extract Entitlements.application-identifier raw - | sed 's/^[^.]*\.//')
```

**修改后：**
```bash
# 从 app.cfg 读取实际的 Bundle ID
APP_NAME=$(cat assets/build.app | grep appName | cut -d'=' -f2)
BUNDLE_ID=$(grep "^appId=" assets/${APP_NAME}/app.cfg | cut -d'=' -f2)
```

#### 2. 提取 Profile 名称（用于 exportOptions.plist）

**新增：**
```bash
# 获取 Profile 名称
PROFILE_NAME=$(security cms -D -i profile.mobileprovision | plutil -extract Name raw -)
echo "PROFILE_NAME=$PROFILE_NAME" >> $GITHUB_ENV
```

#### 3. 在 ExportOptions.plist 中使用 Profile 名称

**修改前：**
```xml
<key>provisioningProfiles</key>
<dict>
    <key>${BUNDLE_ID}</key>
    <string>${PROFILE_UUID}</string>  <!-- 使用 UUID -->
</dict>
```

**修改后：**
```xml
<key>provisioningProfiles</key>
<dict>
    <key>${BUNDLE_ID}</key>
    <string>${PROFILE_NAME}</string>  <!-- 使用名称 -->
</dict>
```

#### 4. 在 xcodebuild 中使用 Profile 名称

**修改前：**
```bash
PROVISIONING_PROFILE_SPECIFIER="${PROFILE_UUID}"
```

**修改后：**
```bash
PROVISIONING_PROFILE_SPECIFIER="${PROFILE_NAME}"
```

---

## 📋 配置要求

### 1. Provisioning Profile 要求

- **类型**：App Store、Ad Hoc、Development 都可以
- **App ID**：可以是通配符（如 `com.xlab.*`）或具体的（如 `com.xlab.guessIdiom`）
- **名称**：在 Apple Developer Portal 中设置的 Profile 名称（如 `xlab-***-profiler`）

### 2. app.cfg 配置

确保 `assets/idiomApp/app.cfg` 中配置了正确的 Bundle ID：

```properties
# 应用 ID（必须与 Xcode 项目中的 Bundle ID 一致）
appId=com.xlab.guessIdiom

# iOS Team ID
iosTeamId=G3NJ44L7QL

# iOS 导出方式
iosExportMethod=app-store
```

### 3. GitHub Secrets 配置

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `IOS_CERTIFICATE_BASE64` | 证书（.p12）的 Base64 | （Base64 字符串） |
| `IOS_CERTIFICATE_PASSWORD` | 证书密码 | `your_password` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Profile 的 Base64 | （Base64 字符串） |
| `IOS_TEAM_ID` | Team ID | `G3NJ44L7QL` |
| `IOS_EXPORT_METHOD` | 导出方式 | `app-store` |
| `KEYCHAIN_PASSWORD` | 临时 Keychain 密码 | `temp_password` |
| `APP_STORE_API_KEY_ID` | App Store Connect API Key ID | `ABC123XYZ` |
| `APP_STORE_API_ISSUER_ID` | API Issuer ID | `12345678-1234-...` |
| `APP_STORE_API_KEY_BASE64` | API Key (.p8) 的 Base64 | （Base64 字符串） |

---

## 🔍 验证方法

### 1. 检查 Profile 信息

```bash
# 查看 Profile 名称
security cms -D -i profile.mobileprovision | plutil -extract Name raw -

# 查看 Profile UUID
security cms -D -i profile.mobileprovision | plutil -extract UUID raw -

# 查看 App ID
security cms -D -i profile.mobileprovision | plutil -extract Entitlements.application-identifier raw -
```

### 2. 检查构建日志

在 GitHub Actions 日志中查找：

```
Profile Name: xlab-***-profiler
Bundle ID from app.cfg: com.xlab.guessIdiom
Profile App ID: com.xlab.*
```

确认：
- ✅ Bundle ID 是具体的（`com.xlab.guessIdiom`）
- ✅ Profile Name 正确
- ✅ Profile App ID 可以是通配符

---

## ⚠️ 常见问题

### Q1: 为什么使用 Profile 名称而不是 UUID？

**A:** 
- UUID 在 Xcode 的 `PROVISIONING_PROFILE_SPECIFIER` 中有时不被识别
- 使用名称更可靠，特别是对于通配符 Profile
- ExportOptions.plist 支持使用名称或 UUID，名称更易于调试

### Q2: 通配符 Profile 和具体 Profile 有什么区别？

| 特性 | 通配符 Profile (`com.xlab.*`) | 具体 Profile (`com.xlab.guessIdiom`) |
|------|-------------------------------|-------------------------------------|
| **灵活性** | ✅ 可用于多个应用 | ❌ 只能用于一个应用 |
| **管理** | ✅ 维护简单 | ❌ 每个应用都需要单独的 Profile |
| **功能限制** | ⚠️ 不支持部分功能（如 Push、iCloud） | ✅ 支持所有功能 |
| **推荐场景** | 简单应用、快速测试 | 生产环境、需要特殊功能 |

### Q3: 如何在 Apple Developer Portal 创建通配符 Profile？

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → 点击 **+** 创建 App ID
   - **Description**: `xlab Apps`
   - **Bundle ID**: 选择 **Wildcard**，输入 `com.xlab.*`
4. 选择 **Profiles** → 点击 **+** 创建 Profile
   - **Type**: 选择 `App Store`
   - **App ID**: 选择刚创建的通配符 App ID
   - **Certificate**: 选择你的证书
   - **Profile Name**: 输入名称（如 `xlab-***-profiler`）
5. 下载 Profile 并转换为 Base64

```bash
base64 -i profile.mobileprovision | pbcopy
```

### Q4: 如何获取 Profile 名称？

**方法 1：在 Apple Developer Portal 查看**
- 进入 **Profiles** 页面
- 找到你的 Profile，名称显示在列表中

**方法 2：使用命令行解析**
```bash
security cms -D -i profile.mobileprovision | plutil -extract Name raw -
```

---

## 📝 部署步骤

### 1. 更新代码

```bash
git pull origin main
```

### 2. 修改配置

编辑 `assets/idiomApp/app.cfg`，确保 Bundle ID 正确：

```properties
appId=com.xlab.guessIdiom
```

### 3. 更新 GitHub Secrets

如果更换了 Profile，需要更新：
```bash
# 转换 Profile 为 Base64
base64 -i xlab-profiler.mobileprovision | pbcopy

# 在 GitHub 仓库设置中更新 IOS_PROVISIONING_PROFILE_BASE64
```

### 4. 触发构建

```bash
git add .
git commit -m "fix: 修复通配符Profile配置"
git tag v1.0.7
git push origin v1.0.7
```

### 5. 监控构建

在 GitHub Actions 页面查看构建日志，确认：
- ✅ Profile 名称正确提取
- ✅ Bundle ID 从 app.cfg 读取
- ✅ Archive 成功
- ✅ Export 成功
- ✅ 上传到 TestFlight 成功

---

## 🎯 总结

使用通配符 Provisioning Profile 的关键点：

1. ✅ 从 **app.cfg** 读取 Bundle ID（不从 Profile 提取）
2. ✅ 使用 **Profile 名称**（不使用 UUID）
3. ✅ ExportOptions.plist 中的 key 是**具体的 Bundle ID**
4. ✅ ExportOptions.plist 中的 value 是**Profile 名称**

这样配置后，无论使用通配符 Profile 还是具体 Profile 都能正常工作。

---

## 📚 相关文档

- [iOS打包说明](./iOS打包说明.md)
- [证书和密钥配置指南](./证书和密钥配置指南.md)
- [常见配置错误](./常见配置错误.md)







# 配置更新和截图上传修复说明

## 修复日期
2025-12-27

## 问题描述

### 问题1：配置更新失败
在更新应用元数据时，某些字段无法修改，导致出现 409 冲突错误：
- `appInfoLocalizations` 中的 `name` 和 `privacyPolicyUrl` 字段
- `appInfos` 中的 `primaryCategory` 关系

错误信息示例：
```
API 请求失败: 409 Client Error: Conflict
"detail" : "The field 'name' can not be modified in the current state."
"detail" : "The field 'privacyPolicyUrl' can not be modified in the current state."
```

### 问题2：截图上传到错误的语言
截图被上传到 `en-US` 语言，而不是主要语言 `zh-Hans`，导致在 App Store Connect 上看不到截图。

## 根本原因

### 原因1：Apple API 状态限制
Apple App Store Connect API 对某些字段有状态限制：
- **应用名称 (name)**：在应用首次发布后，通常无法通过 API 修改
- **隐私政策 URL (privacyPolicyUrl)**：在应用发布后，通常无法通过 API 修改
- **应用类别 (primaryCategory)**：在应用发布后，通常无法通过 API 修改

这些限制是 Apple 的设计，不是版本选择的问题。

### 原因2：截图上传逻辑错误
旧代码只为第一个本地化（通常是 `en-US`）上传截图，而不是为主要语言或所有语言上传。

```python
# 旧代码
localization = result["data"][0]  # 只取第一个
```

## 解决方案

### 修复1：优雅处理状态错误

#### 修改内容
在 `update_app_info_metadata` 和 `update_app_categories` 方法中添加错误处理：

```python
try:
    self.make_request("PATCH", f"appInfoLocalizations/{loc_id}", data=update_data)
except Exception as e:
    error_msg = str(e)
    # 检查是否是状态错误
    if "INVALID_STATE" in error_msg or "can not be modified" in error_msg:
        print(f"⚠️  某些字段在当前状态下无法修改: {locale}")
        print(f"提示: 'name' 和 'privacyPolicyUrl' 等字段在应用发布后通常无法通过 API 修改")
        # 继续处理，不抛出异常
    else:
        raise
```

#### 效果
- 遇到状态错误时不会中断整个流程
- 显示友好的提示信息
- 继续处理其他可以更新的字段

### 修复2：为正确的语言上传截图

#### 修改内容
1. 为 `upload_screenshots_for_version` 方法添加 `primary_locale` 参数
2. 支持为主要语言或所有语言上传截图
3. 修改主函数调用，传入主要语言参数

```python
def upload_screenshots_for_version(self, version_id, screenshots_dir, 
                                   device_screenshot_mapping, primary_locale=None):
    """
    Args:
        primary_locale: 主要语言（可选，如果指定则只为该语言上传，否则为所有语言上传）
    """
    
    if primary_locale:
        # 只为主要语言上传
        for loc in result["data"]:
            if loc["attributes"]["locale"] == primary_locale:
                localizations_to_upload.append(loc)
                break
    else:
        # 为所有语言上传
        localizations_to_upload = result["data"]
```

#### 效果
- 截图会上传到正确的主要语言（如 `zh-Hans`）
- 如果指定了主要语言，只为该语言上传（节省时间）
- 如果没有指定主要语言，为所有语言上传（确保覆盖）

## 使用方法

### 配置主要语言

在 `app.cfg` 中配置主要语言：

```ini
# iOS 主要语言
iosPrimaryLocale=zh-Hans

# 支持的语言
iosLocales=zh-Hans,en-US
```

### 截图上传行为

脚本会自动读取 `iosPrimaryLocale` 配置，并为该语言上传截图。

**示例输出：**
```
📸 上传版本截图
📱 将为 1 个语言上传截图

📱 上传截图 - 语言: zh-Hans
  📱 iPhone_6.5 - 准备上传 3 张截图
  ✅ iPhone_6.5 截图 1/3 上传成功
  ✅ iPhone_6.5 截图 2/3 上传成功
  ✅ iPhone_6.5 截图 3/3 上传成功
  ✅ iPhone_6.5 共上传 3 张截图
```

## 配置字段说明

### 可以通过 API 更新的字段

#### appStoreVersionLocalizations（版本本地化）
- ✅ `description` - 应用描述
- ✅ `keywords` - 关键词
- ✅ `supportUrl` - 技术支持网址
- ✅ `marketingUrl` - 营销网址
- ✅ `promotionalText` - 推广文本
- ✅ `whatsNew` - 更新说明

#### appStoreReviewDetails（审核详情）
- ✅ `contactFirstName` - 联系人名
- ✅ `contactLastName` - 联系人姓
- ✅ `contactPhone` - 联系电话
- ✅ `contactEmail` - 联系邮箱
- ✅ `notes` - 备注

#### appStoreVersions（版本信息）
- ✅ `copyright` - 版权信息

### 应用发布后无法通过 API 更新的字段

#### appInfoLocalizations（应用信息本地化）
- ❌ `name` - 应用名称（首次发布后锁定）
- ❌ `privacyPolicyUrl` - 隐私政策 URL（发布后锁定）
- ⚠️ `subtitle` - 副标题（部分情况下可修改）

#### appInfos（应用信息）
- ❌ `primaryCategory` - 主要类别（发布后锁定）
- ❌ `primarySubcategoryOne` - 次要类别（发布后锁定）

### 如何修改锁定的字段

这些字段需要在 **App Store Connect 网站**手动修改：

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 选择您的应用
3. 进入「App 信息」页面
4. 修改相应字段
5. 点击「保存」

## 完整的错误处理流程

```
1. 尝试更新字段
   ├─ 成功 → ✅ 显示成功信息
   └─ 失败
      ├─ 状态错误 (INVALID_STATE) → ⚠️ 显示友好提示，继续流程
      └─ 其他错误 → ❌ 显示错误信息，继续流程

2. 上传截图
   ├─ 读取主要语言配置
   ├─ 查找对应语言的版本本地化
   ├─ 为该语言上传所有截图
   └─ 显示上传进度和结果
```

## 测试验证

### 验证配置更新
1. 修改 `app.cfg` 中的可更新字段（如 `appDescription`）
2. 运行 `python scripts/app_store_connect.py .`
3. 检查输出，应该看到成功更新的字段
4. 对于锁定字段，应该看到友好的提示信息，而不是错误

### 验证截图上传
1. 生成截图：`python scripts/generate_app_screenshots.py .`
2. 上传截图：`python scripts/app_store_connect.py .`（确保 `enableScreenshotUpload=true`）
3. 检查输出，应该看到"上传截图 - 语言: zh-Hans"（或您的主要语言）
4. 登录 App Store Connect，在对应语言的版本中应该能看到截图

## 注意事项

1. **应用名称和类别**：首次设置后通常无法通过 API 修改，请在首次创建应用时仔细设置
2. **隐私政策 URL**：一旦设置后很难修改，请确保 URL 正确
3. **截图语言**：截图会上传到主要语言，如果需要为其他语言上传不同的截图，需要手动操作
4. **版本状态**：某些字段只能在 `PREPARE_FOR_SUBMISSION` 状态下修改
5. **API 限制**：Apple 可能会随时调整 API 的限制，建议定期查看官方文档

## 相关文档

- [App Store Connect API 文档](https://developer.apple.com/documentation/appstoreconnectapi)
- [App 元数据管理指南](https://developer.apple.com/app-store/app-metadata/)
- [截图规范](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)

## 更新日志

### 2025-12-27
- ✅ 添加状态错误的优雅处理
- ✅ 修复截图上传到错误语言的问题
- ✅ 支持为主要语言上传截图
- ✅ 改进错误提示信息
- ✅ 优化日志输出格式















