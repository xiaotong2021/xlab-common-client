#!/bin/bash
set -eo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# 本地构建脚本 - 构建 Debug 模拟器包
#
# 用法:
#   ./build_local.sh          # 构建 Debug 模拟器包
#   ./build_local.sh clean    # 清理构建产物
# ──────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT="Hamster.xcodeproj"
SCHEME="Hamster"
TARGET_DIR="$SCRIPT_DIR/build-local/target"
ACTION="${1:-build}"

DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { printf "${GREEN}[INFO]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*"; exit 1; }

# 查找已有完整 SPM 包缓存的 DerivedData 目录（Runestone submodule 已初始化）
find_spm_cache_dd() {
  local dir
  for dir in "$DERIVED_DATA"/Hamster-*/SourcePackages/checkouts; do
    if [ -d "$dir/Runestone/tree-sitter/lib" ] && [ -d "$dir/TreeSitterLanguages" ]; then
      dirname "$(dirname "$dir")"
      return 0
    fi
  done
  return 1
}

# 查找有 Runestone checkout 但 submodule 未初始化的 DerivedData 目录
find_broken_spm_dd() {
  local dir
  for dir in "$DERIVED_DATA"/Hamster-*/SourcePackages/checkouts; do
    if [ -d "$dir/Runestone" ] && [ ! -d "$dir/Runestone/tree-sitter/lib" ]; then
      dirname "$(dirname "$dir")"
      return 0
    fi
  done
  return 1
}

# 用系统 git 手动修复 Runestone 的 tree-sitter submodule
fix_runestone_submodule() {
  local dd_path="$1"
  local checkout_dir="$dd_path/SourcePackages/checkouts/Runestone"

  if [ ! -d "$checkout_dir" ]; then
    return 1
  fi

  if [ -d "$checkout_dir/tree-sitter/lib" ]; then
    info "Runestone tree-sitter submodule 已就绪"
    return 0
  fi

  info "使用系统 git 初始化 Runestone tree-sitter submodule..."

  cd "$checkout_dir"

  # 用系统 git（/usr/bin/git）而不是 Xcode 内置的 git
  if /usr/bin/git submodule update --init --recursive 2>&1; then
    info "submodule 初始化成功"
    cd "$SCRIPT_DIR"
    return 0
  fi

  # 如果 git submodule 也被拦截，改用 HTTPS 直接 clone
  warn "git submodule 初始化失败，尝试 HTTPS 直接下载..."
  local tree_sitter_hash
  tree_sitter_hash=$(/usr/bin/git ls-tree HEAD tree-sitter | awk '{print $3}')

  if [ -n "$tree_sitter_hash" ]; then
    rm -rf tree-sitter
    /usr/bin/git clone --depth 1 https://github.com/tree-sitter/tree-sitter.git tree-sitter 2>&1
    cd tree-sitter
    /usr/bin/git fetch --depth 1 origin "$tree_sitter_hash" 2>&1 || true
    /usr/bin/git checkout "$tree_sitter_hash" 2>&1 || true
    cd "$checkout_dir"
    info "tree-sitter 下载完成"
    cd "$SCRIPT_DIR"
    return 0
  fi

  cd "$SCRIPT_DIR"
  return 1
}

check_prerequisites() {
  command -v xcodebuild >/dev/null 2>&1 || error "未找到 xcodebuild，请安装 Xcode"

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
    error "缺少 xcframework: ${missing[*]}，请确保 Frameworks/ 目录完整"
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
  rm -rf "$SCRIPT_DIR/build-local"
  info "清理完成"
}

run_xcodebuild() {
  local dd_path="$1"
  xcodebuild build \
    -project "$PROJECT" \
    -scheme  "$SCHEME" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -skipPackagePluginValidation \
    -disableAutomaticPackageResolution \
    -derivedDataPath "$dd_path" \
    2>&1 | tail -50
}

build_debug_simulator() {
  info "开始构建 Debug（模拟器）..."
  info "项目: $PROJECT  Scheme: $SCHEME"

  # Step 1: 尝试找到已有的完整 SPM 缓存
  local dd_path
  dd_path="$(find_spm_cache_dd 2>/dev/null || true)"

  if [ -n "$dd_path" ]; then
    info "复用 Xcode DerivedData: $dd_path"
    run_xcodebuild "$dd_path"
  else
    # Step 2: 没有完整缓存，先让 xcodebuild 解析依赖（允许失败）
    warn "未找到完整 SPM 缓存，开始解析远程依赖..."
    xcodebuild build \
      -project "$PROJECT" \
      -scheme  "$SCHEME" \
      -configuration Debug \
      -sdk iphonesimulator \
      -destination 'generic/platform=iOS Simulator' \
      -skipPackagePluginValidation \
      2>&1 | tail -20 || true

    # Step 3: 检查是否有 Runestone submodule 未初始化的情况
    local broken_dd
    broken_dd="$(find_broken_spm_dd 2>/dev/null || true)"

    if [ -n "$broken_dd" ]; then
      warn "检测到 Runestone submodule 未初始化（Xcode git 被系统拦截），手动修复中..."
      if fix_runestone_submodule "$broken_dd"; then
        info "修复完成，重新构建..."
        run_xcodebuild "$broken_dd"
      else
        error "无法修复 Runestone submodule，请手动在 Xcode 中打开项目构建一次"
      fi
    else
      # Step 4: 再次检查是否已经构建成功了
      dd_path="$(find_spm_cache_dd 2>/dev/null || true)"
      if [ -n "$dd_path" ]; then
        info "SPM 解析成功，开始构建..."
        run_xcodebuild "$dd_path"
      else
        error "SPM 依赖解析失败，请先在 Xcode 中打开项目构建一次以初始化 SPM 缓存"
      fi
    fi
  fi

  # 查找产物
  local app_path=""
  for search in "$DERIVED_DATA"/Hamster-*/Build/Products/Debug-iphonesimulator; do
    local found
    found=$(find "$search" -name "*.app" -not -path "*/PlugIns/*" -type d 2>/dev/null | sort -r | head -1)
    if [ -n "$found" ]; then
      app_path="$found"
      break
    fi
  done
  if [ -z "$app_path" ]; then
    error "未找到 .app 产物"
  fi

  # 拷贝到 build-local/target
  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -R "$app_path" "$TARGET_DIR/"
  local app_name
  app_name=$(basename "$app_path")

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
