#!/bin/bash
# 验证构建配置脚本

echo "=== Build Configuration Verification ==="
echo ""

# 检查 app.cfg
echo "1. Checking app.cfg..."
CONFIG_FILE="assets/app1/app.cfg"

if [ -f "$CONFIG_FILE" ]; then
    echo "✅ app.cfg found"
    APP_ID=$(grep '^appId=' "$CONFIG_FILE" | cut -d'=' -f2)
    APP_DISPLAY_NAME=$(grep '^appDisplayName=' "$CONFIG_FILE" | cut -d'=' -f2)
    LOAD_URL=$(grep '^loadUrl=' "$CONFIG_FILE" | cut -d'=' -f2)
    NEED_DEBUG=$(grep '^needDebug=' "$CONFIG_FILE" | cut -d'=' -f2)
    
    echo "   App ID: $APP_ID"
    echo "   App Display Name: $APP_DISPLAY_NAME"
    echo "   Load URL: $LOAD_URL"
    echo "   Need Debug: $NEED_DEBUG"
else
    echo "❌ app.cfg not found"
    exit 1
fi

echo ""

# 检查 Android 文件
echo "2. Checking Android files..."
PACKAGE_PATH="${APP_ID//./\/}"
ANDROID_SRC="android/app/src/main/java/$PACKAGE_PATH"

echo "   Expected package path: $ANDROID_SRC"

if [ -d "$ANDROID_SRC" ]; then
    echo "✅ Package directory exists"
    
    # 检查 Kotlin 文件
    FILES=("AppConfig.kt" "MainActivity.kt" "LoadingActivity.kt")
    for file in "${FILES[@]}"; do
        if [ -f "$ANDROID_SRC/$file" ]; then
            echo "   ✅ $file found"
            
            # 检查包名
            PACKAGE_LINE=$(grep "^package " "$ANDROID_SRC/$file" | head -1)
            if [[ "$PACKAGE_LINE" == *"__PACKAGE_NAME__"* ]]; then
                echo "      ❌ Contains placeholder: __PACKAGE_NAME__"
            elif [[ "$PACKAGE_LINE" == "package $APP_ID" ]]; then
                echo "      ✅ Package name correct: $APP_ID"
            else
                echo "      ⚠️  Package name: $PACKAGE_LINE"
            fi
        else
            echo "   ❌ $file not found"
        fi
    done
else
    echo "❌ Package directory not found"
    
    # 检查旧位置
    OLD_DIR="android/app/src/main/java/com/mywebviewapp"
    if [ -d "$OLD_DIR" ]; then
        echo "   ⚠️  Files still in old location: $OLD_DIR"
    fi
fi

echo ""

# 检查 Android 资源文件
echo "3. Checking Android resources..."
STRINGS_XML="android/app/src/main/res/values/strings.xml"

if [ -f "$STRINGS_XML" ]; then
    echo "✅ strings.xml found"
    
    # 检查应用名称
    APP_NAME_LINE=$(grep 'name="app_name"' "$STRINGS_XML")
    if [[ "$APP_NAME_LINE" == *"__APP_DISPLAY_NAME__"* ]]; then
        echo "   ❌ Contains placeholder: __APP_DISPLAY_NAME__"
    elif [[ "$APP_NAME_LINE" == *"$APP_DISPLAY_NAME"* ]]; then
        echo "   ✅ App name correct: $APP_DISPLAY_NAME"
    else
        echo "   ⚠️  App name: $APP_NAME_LINE"
    fi
else
    echo "❌ strings.xml not found"
fi

# 检查 Android 图标
ICON_CHECK="android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"
if [ -f "$ICON_CHECK" ]; then
    echo "✅ Android icon found (mipmap-xhdpi)"
else
    echo "⚠️  Android icon not found in mipmap-xhdpi"
fi

echo ""

# 检查 iOS 文件
echo "4. Checking iOS files..."
IOS_CONFIG="ios/WebViewApp/AppConfig.swift"

if [ -f "$IOS_CONFIG" ]; then
    echo "✅ AppConfig.swift found"
    
    # 检查 loadUrl
    LOAD_URL_LINE=$(grep 'static let loadUrl' "$IOS_CONFIG")
    if [[ "$LOAD_URL_LINE" == *"__LOAD_URL__"* ]]; then
        echo "   ❌ Contains placeholder: __LOAD_URL__"
    elif [[ "$LOAD_URL_LINE" == *"$LOAD_URL"* ]]; then
        echo "   ✅ Load URL correct: $LOAD_URL"
    else
        echo "   ⚠️  Load URL: $LOAD_URL_LINE"
    fi
else
    echo "❌ AppConfig.swift not found"
fi

# 检查 iOS Info.plist
INFO_PLIST="ios/WebViewApp/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo "✅ Info.plist found"
    
    # 检查应用名称
    DISPLAY_NAME_LINE=$(grep -A1 'CFBundleDisplayName' "$INFO_PLIST" | tail -1)
    if [[ "$DISPLAY_NAME_LINE" == *"__APP_DISPLAY_NAME__"* ]]; then
        echo "   ❌ Contains placeholder: __APP_DISPLAY_NAME__"
    elif [[ "$DISPLAY_NAME_LINE" == *"$APP_DISPLAY_NAME"* ]]; then
        echo "   ✅ Display name correct: $APP_DISPLAY_NAME"
    else
        echo "   ⚠️  Display name: $DISPLAY_NAME_LINE"
    fi
else
    echo "❌ Info.plist not found"
fi

# 检查 iOS 图标
IOS_ICON="ios/WebViewApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
if [ -f "$IOS_ICON" ]; then
    echo "✅ iOS icon found (AppIcon.appiconset)"
else
    echo "⚠️  iOS icon not found in AppIcon.appiconset"
fi

echo ""

# 检查 WebViewApp.entitlements 占位符是否已替换
echo "5. Checking WebViewApp entitlements..."
ENTITLEMENTS="ios/WebViewApp/WebViewApp.entitlements"

if [ -f "$ENTITLEMENTS" ]; then
    echo "✅ WebViewApp.entitlements found"
    
    if grep -q '__BUNDLE_ID__' "$ENTITLEMENTS"; then
        echo "   ❌ Contains unreplaced placeholder: __BUNDLE_ID__"
    else
        APP_GROUP=$(grep -A1 'application-groups' "$ENTITLEMENTS" | grep '<string>' | head -1 | sed 's/.*<string>//;s/<\/string>.*//' | tr -d '\t')
        echo "   ✅ App Group: $APP_GROUP"
        
        ICLOUD=$(grep -A1 'icloud-container-identifiers' "$ENTITLEMENTS" | grep '<string>' | head -1 | sed 's/.*<string>//;s/<\/string>.*//' | tr -d '\t')
        echo "   ✅ iCloud Container: $ICLOUD"
    fi
else
    echo "❌ WebViewApp.entitlements not found"
fi

echo ""

# 检查 Hamster 包名同步
echo "6. Checking Hamster bundle ID sync..."
HAMSTER_DIR="Hamster"

if [ -d "$HAMSTER_DIR" ]; then
    HAMSTER_ENTITLEMENTS="$HAMSTER_DIR/Hamster/Hamster.entitlements"
    KEYBOARD_ENTITLEMENTS="$HAMSTER_DIR/HamsterKeyboard/HamsterKeyboard.entitlements"
    
    if [ -f "$HAMSTER_ENTITLEMENTS" ]; then
        if grep -q 'dev.fuxiao.app' "$HAMSTER_ENTITLEMENTS"; then
            echo "   ⚠️  Hamster.entitlements still uses original bundle ID (dev.fuxiao.app.*)"
        else
            HAMSTER_GROUP=$(grep -A1 'application-groups' "$HAMSTER_ENTITLEMENTS" | grep '<string>' | head -1 | sed 's/.*<string>//;s/<\/string>.*//' | tr -d '\t')
            echo "   ✅ Hamster App Group: $HAMSTER_GROUP"
        fi
    fi
    
    if [ -f "$KEYBOARD_ENTITLEMENTS" ]; then
        if grep -q 'dev.fuxiao.app' "$KEYBOARD_ENTITLEMENTS"; then
            echo "   ⚠️  HamsterKeyboard.entitlements still uses original bundle ID (dev.fuxiao.app.*)"
        else
            KB_GROUP=$(grep -A1 'application-groups' "$KEYBOARD_ENTITLEMENTS" | grep '<string>' | head -1 | sed 's/.*<string>//;s/<\/string>.*//' | tr -d '\t')
            echo "   ✅ HamsterKeyboard App Group: $KB_GROUP"
        fi
    fi
else
    echo "   ⚠️  Hamster directory not found, skipping check"
fi

echo ""
echo "=== Verification Complete ==="

