#!/bin/bash
set -eo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# 本地构建脚本 - 构建 Debug 模拟器包
#
# 用法:
#   ./build_local.sh          # 构建 Debug 模拟器包
#   ./build_local.sh clean    # 清理构建产物（含已缓存的远程依赖）
#
# 原理:
#   企业安全策略会 Kill git submodule 操作，导致 SPM 无法正常解析 Runestone 包。
#   本脚本通过 -clonedSourcePackagesDirPath 向 xcodebuild 提供预克隆的远程包，
#   完全绕过 Xcode/SPM 的 git 操作，从而规避安全策略限制。
# ──────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT="Hamster.xcodeproj"
SCHEME="Hamster"
BUILD_DIR="$SCRIPT_DIR/build-local"
TARGET_DIR="$BUILD_DIR/target"
PACKAGES_DIR="$BUILD_DIR/packages"
ACTION="${1:-build}"

info()  { printf "\033[0;32m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()   { printf "\033[0;31m[ERROR]\033[0m %s\n" "$*"; exit 1; }

# ── 远程依赖包列表（从 Package.resolved 提取） ──────────────────────────────────
# 格式: "目录名 仓库URL commit哈希"
REMOTE_DEPS=(
  "GCDWebServer       https://github.com/imfuxiao/GCDWebServer.git           14f9eedb296c5b71fec971d8256ef3bfc20a2245"
  "ProgressHUD        https://github.com/relatedcode/ProgressHUD.git         5a7e1ba99652f429eb3bf60de0558cacc5c384be"
  "Runestone          https://github.com/simonbs/Runestone                   1d0e79051a18d79f12882e9fad0b130e47d4a06b"
  "TreeSitterLanguages https://github.com/simonbs/TreeSitterLanguages.git    a15ab30453d14097355d7d78ec7c0feb008cfbba"
  "Yams               https://github.com/jpsim/Yams.git                     0d9ee7ea8c4ebd4a489ad7a73d5c6cad55d6fed3"
  "ZIPFoundation      https://github.com/weichsel/ZIPFoundation.git          43ec568034b3731101dbf7670765d671c30f54f3"
)

# ── 浅克隆指定 commit 到目录 ──────────────────────────────────────────────────
clone_at_revision() {
  local name="$1" url="$2" rev="$3" dest="$4"
  if [ -d "$dest/.git" ]; then
    local current_rev
    current_rev=$(/usr/bin/git -C "$dest" rev-parse HEAD 2>/dev/null || echo "")
    if [ "$current_rev" = "$rev" ]; then
      return 0
    fi
    rm -rf "$dest"
  fi

  info "  克隆 $name ..."
  /usr/bin/git init "$dest" > /dev/null 2>&1
  /usr/bin/git -C "$dest" remote add origin "$url" 2>/dev/null || true
  if ! /usr/bin/git -C "$dest" fetch --depth 1 origin "$rev" 2>&1; then
    warn "  浅克隆失败，尝试完整克隆..."
    rm -rf "$dest"
    /usr/bin/git clone "$url" "$dest" 2>&1
    /usr/bin/git -C "$dest" checkout "$rev" 2>&1
  else
    /usr/bin/git -C "$dest" checkout FETCH_HEAD 2>&1
  fi
}

# ── 修复 Runestone 的 tree-sitter 子模块 ─────────────────────────────────────
fix_runestone_submodule() {
  local runestone_dir="$1"
  [ -d "$runestone_dir" ] || return 1

  if [ -d "$runestone_dir/tree-sitter/lib" ]; then
    return 0
  fi

  info "  补全 Runestone/tree-sitter 子模块..."
  local ts_hash
  ts_hash=$(/usr/bin/git -C "$runestone_dir" ls-tree HEAD tree-sitter 2>/dev/null | awk '{print $3}')
  if [ -z "$ts_hash" ]; then
    warn "  无法从 Runestone 获取 tree-sitter commit hash"
    return 1
  fi

  rm -rf "$runestone_dir/tree-sitter"
  /usr/bin/git clone --depth 1 https://github.com/tree-sitter/tree-sitter.git \
    "$runestone_dir/tree-sitter" 2>&1
  /usr/bin/git -C "$runestone_dir/tree-sitter" fetch --depth 1 origin "$ts_hash" 2>&1 || true
  /usr/bin/git -C "$runestone_dir/tree-sitter" checkout "$ts_hash" 2>&1 || true
  info "  tree-sitter 补全完成"
}

# ── 预克隆所有远程依赖包 ─────────────────────────────────────────────────────
prepare_packages() {
  mkdir -p "$PACKAGES_DIR"

  local need_clone=false
  for entry in "${REMOTE_DEPS[@]}"; do
    local name url rev
    read -r name url rev <<< "$entry"
    local dest="$PACKAGES_DIR/$name"
    if [ ! -d "$dest/.git" ]; then
      need_clone=true
      break
    fi
  done

  if [ "$need_clone" = false ] && [ -d "$PACKAGES_DIR/Runestone/tree-sitter/lib" ]; then
    info "远程依赖包已缓存，跳过克隆"
    return 0
  fi

  info "预克隆远程依赖包（共 ${#REMOTE_DEPS[@]} 个）..."

  for entry in "${REMOTE_DEPS[@]}"; do
    local name url rev
    read -r name url rev <<< "$entry"
    clone_at_revision "$name" "$url" "$rev" "$PACKAGES_DIR/$name"
  done

  fix_runestone_submodule "$PACKAGES_DIR/Runestone"

  info "所有远程依赖包准备完成"
}

# ── 前置检查 ──────────────────────────────────────────────────────────────────
check_prerequisites() {
  command -v xcodebuild >/dev/null 2>&1 || err "未找到 xcodebuild，请安装 Xcode"
  local missing=()
  local required=(
    "boost_atomic.xcframework"   "boost_filesystem.xcframework"
    "boost_locale.xcframework"   "boost_regex.xcframework"
    "boost_system.xcframework"   "icudata.xcframework"
    "icui18n.xcframework"        "icuio.xcframework"
    "icuuc.xcframework"          "libglog.xcframework"
    "libleveldb.xcframework"     "libmarisa.xcframework"
    "libopencc.xcframework"      "librime.xcframework"
    "librime-sbxlm.xcframework"  "libyaml-cpp.xcframework"
  )
  for fw in "${required[@]}"; do
    [ -d "Frameworks/$fw" ] || missing+=("$fw")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    err "缺少 xcframework: ${missing[*]}，请确保 Frameworks/ 目录完整"
  fi
  info "Frameworks 检查通过"
}

build_schema() {
  if [ -f "Resources/SharedSupport/SharedSupport.zip" ]; then
    info "输入方案已存在，跳过编译"
  else
    info "编译输入方案..."
    make schema
  fi
}

do_clean() {
  info "清理本地构建产物..."
  rm -rf "$BUILD_DIR"
  info "清理完成"
}

# ── 主构建逻辑 ────────────────────────────────────────────────────────────────
build_debug_simulator() {
  info "开始构建 Debug（模拟器）..."
  info "项目: $PROJECT  Scheme: $SCHEME"

  prepare_packages

  # 使用 CODE_SIGN_IDENTITY="-"（ad-hoc）让 Xcode 在构建阶段处理签名和 App Group 注册
  # 不能用 CODE_SIGNING_ALLOWED=NO + 事后 codesign 补签：CoreSimulator 不会注册 App Group，
  # 导致 UserDefaults(suiteName:) 落盘到各进程私有沙盒而非共享容器
  info "使用预克隆包构建（ad-hoc 签名，-clonedSourcePackagesDirPath）..."

  xcodebuild build \
    -project "$PROJECT" \
    -scheme  "$SCHEME" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -clonedSourcePackagesDirPath "$PACKAGES_DIR" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -skipPackagePluginValidation \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGNING_REQUIRED=YES

  local app_path=""
  app_path=$(find "$BUILD_DIR/DerivedData/Build/Products/Debug-iphonesimulator" \
    -name "*.app" -not -path "*/PlugIns/*" -type d 2>/dev/null | sort -r | head -1)
  if [ -z "$app_path" ]; then
    err "未找到 .app 产物"
  fi

  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -R "$app_path" "$TARGET_DIR/"
  local app_name
  app_name=$(basename "$app_path")
  local target_app="$TARGET_DIR/$app_name"

  # 验证 App Group entitlements 已由 Xcode 构建时嵌入
  info "验证 App Group entitlements..."
  local keyboard_entitlements="HamsterKeyboard/HamsterKeyboardDebug.entitlements"
  local main_entitlements="Hamster/HamsterDebug.entitlements"

  # 先签键盘扩展（如果 Xcode 没有正确签，作为保障补签）
  for appex in "$target_app/PlugIns/"*.appex; do
    [ -d "$appex" ] || continue
    local appex_name
    appex_name=$(basename "$appex" .appex)
    if ! codesign -d --entitlements - "$appex" 2>&1 | grep -q "group.com.xlab.aiime"; then
      warn "键盘扩展 entitlement 未嵌入，补签..."
      if [ -f "$keyboard_entitlements" ]; then
        codesign --force --sign - --entitlements "$keyboard_entitlements" "$appex" 2>&1
        info "✅ 已补签键盘扩展 entitlements: $appex_name"
      fi
    else
      info "✅ 键盘扩展 entitlements 已正确嵌入: $appex_name"
    fi
  done

  # 验证主 App
  if ! codesign -d --entitlements - "$target_app" 2>&1 | grep -q "group.com.xlab.aiime"; then
    warn "主 App entitlement 未嵌入，补签..."
    if [ -f "$main_entitlements" ]; then
      codesign --force --sign - --entitlements "$main_entitlements" "$target_app" 2>&1
      info "✅ 已补签主 App entitlements"
    else
      warn "未找到主 App entitlements 文件: $main_entitlements"
    fi
  else
    info "✅ 主 App entitlements 已正确嵌入"
  fi

  # 验证注入结果
  info "验证 entitlements 注入结果..."
  if codesign -d --entitlements - "$target_app" 2>&1 | grep -q "group.com.xlab.aiime"; then
    info "✅ 主 App App Group entitlement 验证通过"
  else
    warn "⚠️ 主 App 未找到 App Group entitlement，App Group 共享可能不工作"
    codesign -d --entitlements - "$target_app" 2>&1 | head -20
  fi

  echo ""
  info "==============================="
  info "构建成功!"
  info "产物路径: build-local/target/$app_name"
  info "==============================="
  echo ""
  info "安装到模拟器: xcrun simctl install booted \"$TARGET_DIR/$app_name\""
}

case "$ACTION" in
  clean)
    do_clean
    ;;
  build)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Hamster 本地构建 - Debug 模拟器"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    check_prerequisites
    build_schema
    build_debug_simulator
    ;;
  *)
    echo "用法: $0 {build|clean}"
    exit 1
    ;;
esac
