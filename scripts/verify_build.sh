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
    LOAD_URL=$(grep '^loadUrl=' "$CONFIG_FILE" | cut -d'=' -f2)
    NEED_DEBUG=$(grep '^needDebug=' "$CONFIG_FILE" | cut -d'=' -f2)
    
    echo "   App ID: $APP_ID"
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

# 检查 iOS 文件
echo "3. Checking iOS files..."
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

echo ""
echo "=== Verification Complete ==="

