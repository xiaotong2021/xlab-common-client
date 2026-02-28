#!/bin/bash
set -euo pipefail

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

# Xcode 默认 DerivedData 路径
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

# 查找已有完整 SPM 包缓存的 DerivedData 目录（Runestone submodule 已初始化）
find_spm_cache() {
  local dir
  for dir in "$DERIVED_DATA"/Hamster-*/SourcePackages/checkouts; do
    if [ -d "$dir/Runestone/tree-sitter/lib" ] && [ -d "$dir/TreeSitterLanguages" ]; then
      echo "$(dirname "$dir")"
      return 0
    fi
  done
  return 1
}

SPM_CACHE_DIR="$(find_spm_cache 2>/dev/null || echo "")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

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
    error "缺少 xcframework: ${missing[*]}\n请确保 Frameworks/ 目录完整"
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

build_debug_simulator() {
  info "开始构建 Debug（模拟器）..."
  info "项目: $PROJECT  Scheme: $SCHEME"

  # 查找已有完整 SPM 缓存的 DerivedData 目录
  local dd_path=""
  if [ -n "$SPM_CACHE_DIR" ]; then
    dd_path="$(dirname "$SPM_CACHE_DIR")"
    info "复用 Xcode DerivedData: $dd_path"
  fi

  local dd_args=()
  if [ -n "$dd_path" ]; then
    dd_args+=(-derivedDataPath "$dd_path")
  fi

  xcodebuild build \
    -project "$PROJECT" \
    -scheme  "$SCHEME" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -skipPackagePluginValidation \
    -disableAutomaticPackageResolution \
    "${dd_args[@]}" \
    2>&1 | tail -50

  # 查找产物
  local search_dir="${dd_path:-$DERIVED_DATA/Hamster-*}"
  local app_path
  app_path=$(find $search_dir/Build/Products/Debug-iphonesimulator -name "*.app" -not -path "*/PlugIns/*" -type d 2>/dev/null | sort -r | head -1)
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
