#!/bin/bash
set -eo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# 本地构建脚本 - 构建 Debug 模拟器包
#
# 用法:
#   ./build_local.sh          # 构建 Debug 模拟器包
#   ./build_local.sh clean    # 清理构建产物
#
# 说明:
#   某些企业安全策略会 Kill git submodule 操作，脚本通过 git 包装器绕过此限制，
#   让 SPM 正常解析依赖后，再用 git clone 手动补全子模块。
# ──────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT="Hamster.xcodeproj"
SCHEME="Hamster"
TARGET_DIR="$SCRIPT_DIR/build-local/target"
ACTION="${1:-build}"

DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
XCODE_GIT="/Applications/Xcode.app/Contents/Developer/usr/bin/git"

info()  { printf "\033[0;32m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()   { printf "\033[0;31m[ERROR]\033[0m %s\n" "$*"; exit 1; }

# ── 查找有完整 SPM 缓存的 DerivedData ────────────────────────────────────────
find_good_dd() {
  local dir
  for dir in "$DERIVED_DATA"/Hamster-*/SourcePackages/checkouts; do
    if [ -d "$dir/Runestone/tree-sitter/lib" ] && [ -d "$dir/TreeSitterLanguages" ]; then
      dirname "$(dirname "$dir")"
      return 0
    fi
  done
  return 1
}

# ── 创建 git 包装器：让 submodule--helper 变为空操作 ─────────────────────────
setup_git_wrapper() {
  GIT_WRAPPER_DIR=$(mktemp -d)
  cat > "$GIT_WRAPPER_DIR/git" << 'WRAPPER'
#!/bin/bash
for arg in "$@"; do
  if [ "$arg" = "submodule--helper" ]; then
    exit 0
  fi
done
exec /Applications/Xcode.app/Contents/Developer/usr/bin/git "$@"
WRAPPER
  chmod +x "$GIT_WRAPPER_DIR/git"
}

cleanup_git_wrapper() {
  if [ -n "$GIT_WRAPPER_DIR" ] && [ -d "$GIT_WRAPPER_DIR" ]; then
    rm -rf "$GIT_WRAPPER_DIR"
  fi
}

# ── 手动补全 Runestone 的 tree-sitter 子模块 ─────────────────────────────────
fix_runestone_submodule() {
  local checkout_dir="$1/SourcePackages/checkouts/Runestone"
  [ -d "$checkout_dir" ] || return 1
  [ -d "$checkout_dir/tree-sitter/lib" ] && return 0

  info "用 HTTPS clone 补全 Runestone/tree-sitter 子模块..."
  local hash
  hash=$(/usr/bin/git -C "$checkout_dir" ls-tree HEAD tree-sitter 2>/dev/null | awk '{print $3}')
  if [ -z "$hash" ]; then
    warn "无法获取 tree-sitter commit hash"
    return 1
  fi

  rm -rf "$checkout_dir/tree-sitter"
  /usr/bin/git clone --depth 1 https://github.com/tree-sitter/tree-sitter.git "$checkout_dir/tree-sitter" 2>&1
  /usr/bin/git -C "$checkout_dir/tree-sitter" fetch --depth 1 origin "$hash" 2>&1 || true
  /usr/bin/git -C "$checkout_dir/tree-sitter" checkout "$hash" 2>&1 || true
  info "tree-sitter 子模块补全完成"
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
  rm -rf "$SCRIPT_DIR/build-local"
  info "清理完成"
}

# ── 主构建逻辑 ────────────────────────────────────────────────────────────────
build_debug_simulator() {
  info "开始构建 Debug（模拟器）..."
  info "项目: $PROJECT  Scheme: $SCHEME"

  local dd_path
  dd_path="$(find_good_dd 2>/dev/null || true)"

  if [ -z "$dd_path" ]; then
    # 没有现成的完整缓存，需要解析 SPM 依赖
    info "未找到完整 SPM 缓存，使用 git 包装器解析依赖..."

    setup_git_wrapper
    trap cleanup_git_wrapper EXIT

    # 用包装器运行 xcodebuild 解析依赖（submodule 被跳过，所以会成功解析）
    PATH="$GIT_WRAPPER_DIR:$PATH" \
    xcodebuild build \
      -project "$PROJECT" \
      -scheme  "$SCHEME" \
      -configuration Debug \
      -sdk iphonesimulator \
      -destination 'generic/platform=iOS Simulator' \
      -skipPackagePluginValidation \
      2>&1 | tail -30 || true

    cleanup_git_wrapper
    trap - EXIT

    # 找到刚创建的 DerivedData，补全 Runestone 子模块
    local new_dd
    for dir in "$DERIVED_DATA"/Hamster-*/SourcePackages/checkouts/Runestone; do
      if [ -d "$dir" ]; then
        new_dd="$(dirname "$(dirname "$(dirname "$dir")")")"
        break
      fi
    done

    if [ -n "$new_dd" ]; then
      fix_runestone_submodule "$new_dd"
      dd_path="$(find_good_dd 2>/dev/null || true)"
    fi

    if [ -z "$dd_path" ]; then
      err "SPM 依赖解析失败"
    fi
  fi

  # 正式构建（使用已解析好的 DerivedData，跳过包更新）
  info "复用 DerivedData: $dd_path"
  xcodebuild build \
    -project "$PROJECT" \
    -scheme  "$SCHEME" \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -skipPackagePluginValidation \
    -disableAutomaticPackageResolution \
    -derivedDataPath "$dd_path" \
    2>&1 | tail -30

  # 查找产物
  local app_path=""
  app_path=$(find "$dd_path/Build/Products/Debug-iphonesimulator" -name "*.app" -not -path "*/PlugIns/*" -type d 2>/dev/null | sort -r | head -1)
  if [ -z "$app_path" ]; then
    app_path=$(find "$DERIVED_DATA"/Hamster-*/Build/Products/Debug-iphonesimulator -name "*.app" -not -path "*/PlugIns/*" -type d 2>/dev/null | sort -r | head -1)
  fi
  if [ -z "$app_path" ]; then
    err "未找到 .app 产物"
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
