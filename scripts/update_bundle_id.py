"""
替换 Hamster 工程中所有与 Bundle ID / App Group / iCloud / URL Scheme 相关的硬编码标识符，
并修复 App Group 在无签名环境下的崩溃问题。

替换范围:
  - project.pbxproj               PRODUCT_BUNDLE_IDENTIFIER
  - *.entitlements                 App Group / iCloud container ID
  - HamsterConstants.swift         appGroupName / keyboardBundleID / iCloudID / appURL
  - Info.plist (主 App)            CFBundleURLName / iCloud container
  - FileManager+.swift             shareURL 强制解包 + iCloud 路径检测
  - UserDefaults+.swift            UserDefaults.hamster 强制解包
  - PersistentController.swift     CoreData storeURL 强制解包
  - UserManager.swift              fatalError → 安全回退
  - KeyboardToolbarView.swift      URL scheme
  - KeyboardSettingsViewModel.swift  iCloud 路径检测
  - RimeViewModel.swift            iCloud 同步路径

用法:
    python3 scripts/update_bundle_id.py <hamster_dir> <bundle_id> <bundle_id_keyboard>

示例:
    python3 scripts/update_bundle_id.py Hamster com.xlab.aiime com.xlab.aiime.HamsterKeyboard
"""

import sys
import pathlib


# ── 替换规则 ─────────────────────────────────────────────────────────────────
# (旧值, 类型) — 顺序至关重要：先长后短，避免部分匹配
#
# 类型映射:
#   main        → bundle_id
#   keyboard    → bundle_id_keyboard
#   group       → group.{bundle_id}
#   icloud      → iCloud.{bundle_id}
#   icloud_path → iCloud~{bundle_id 中 . 替换为 ~}

REPLACEMENTS = [
    # ── App Group ──
    ("group.dev2.fuxiao.app.Hamster2",                "group"),
    ("group.dev.fuxiao.app.Hamster",                  "group"),

    # ── iCloud container ID (点号分隔, 用于 entitlements / Info.plist / 代码常量) ──
    ("iCloud.dev.fuxiao.app.hamsterapp",              "icloud"),

    # ── iCloud 文件路径 (波浪号分隔, iOS 文件系统中的实际路径) ──
    ("iCloud~dev~fuxiao~app~hamsterapp",              "icloud_path"),

    # ── 键盘扩展 Bundle ID (必须在主 Bundle ID 之前) ──
    ("dev2.fuxiao.app.Hamster2.HamsterKeyboard",      "keyboard"),
    ("dev.fuxiao.app.Hamster.HamsterKeyboard",        "keyboard"),

    # ── 主 Bundle ID (大写 H — Xcode 项目配置) ──
    ("dev2.fuxiao.app.Hamster2",                      "main"),
    ("dev.fuxiao.app.Hamster",                        "main"),

    # ── URL host / CFBundleURLName (小写 h — 必须在大写版本之后，避免误替换) ──
    # 注: "dev.fuxiao.app.hamsterapp" 已被上面的 iCloud 规则处理,
    #     此处只匹配不带 "app" 后缀的 "dev.fuxiao.app.hamster"
    ("dev.fuxiao.app.hamster",                        "main"),
]


# ── 需要进行标识符替换的文件 ─────────────────────────────────────────────────
TARGET_FILES = [
    # Xcode project
    "Hamster.xcodeproj/project.pbxproj",

    # Entitlements — App Group + iCloud
    "Hamster/Hamster.entitlements",
    "Hamster/HamsterDebug.entitlements",
    "HamsterKeyboard/HamsterKeyboard.entitlements",
    "HamsterKeyboard/HamsterKeyboardDebug.entitlements",

    # 核心常量 — appGroupName / keyboardBundleID / iCloudID / appURL
    "Packages/HamsterKit/Sources/Constants/HamsterConstants.swift",

    # 主 App Info.plist — CFBundleURLName / iCloud container
    "Hamster/Info.plist",

    # 键盘工具栏 — URL scheme (打开主 App)
    "Packages/HamsterKeyboardKit/Sources/View/KeyboardToolbarView.swift",

    # 文件管理 — iCloud 路径检测
    "Packages/HamsterKit/Sources/Extensions/FileManager+.swift",

    # 键盘设置 — iCloud 路径检测
    "Packages/HamsteriOS/Sources/ViewModel/Keyboard/KeyboardSettingsViewModel.swift",

    # RIME 同步 — iCloud 同步路径示例
    "Packages/HamsteriOS/Sources/ViewModel/RIME/RimeViewModel.swift",
]


# ── App Group 强制解包 / fatalError 修复补丁 ──────────────────────────────────
# (相对路径, 旧代码, 新代码)
APP_GROUP_PATCHES = [
    # 1. FileManager+.swift — shareURL 强制解包
    (
        "Packages/HamsterKit/Sources/Extensions/FileManager+.swift",
        (
            '  static var shareURL: URL {\n'
            '    FileManager.default.containerURL(\n'
            '      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)!\n'
            '      .appendingPathComponent("InputSchema")\n'
            '  }'
        ),
        (
            '  static var shareURL: URL {\n'
            '    let base = FileManager.default.containerURL(\n'
            '      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)\n'
            '      ?? sandboxDirectory.appendingPathComponent("AppGroupFallback")\n'
            '    return base.appendingPathComponent("InputSchema")\n'
            '  }'
        ),
    ),

    # 2. UserDefaults+.swift — UserDefaults.hamster 强制解包
    (
        "Packages/HamsterKit/Sources/Extensions/UserDefaults+.swift",
        '  static let hamster = UserDefaults(suiteName: HamsterConstants.appGroupName)!',
        '  static let hamster = UserDefaults(suiteName: HamsterConstants.appGroupName) ?? .standard',
    ),

    # 3. PersistentController.swift — CoreData storeURL 强制解包
    (
        "Packages/HamsterKit/Sources/Persistent/PersistentController.swift",
        (
            '    let storeURL = FileManager.default.containerURL(\n'
            '      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)!\n'
            '      .appendingPathComponent("\\(name).sqlite")'
        ),
        (
            '    let groupURL = FileManager.default.containerURL(\n'
            '      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)\n'
            '    let baseURL = groupURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!\n'
            '    let storeURL = baseURL.appendingPathComponent("\\(name).sqlite")'
        ),
    ),

    # 4. UserManager.swift — fatalError 当 App Group 不可用时崩溃
    (
        "Packages/HamsteriOS/Sources/Services/UserManager.swift",
        (
            '    guard let sharedUserDefaults = UserDefaults(suiteName: HamsterConstants.appGroupName) else {\n'
            '      fatalError("UserManager: 无法初始化 AppGroup 共享存储，AppGroup 名称: \\(HamsterConstants.appGroupName)")\n'
            '    }\n'
            '    self.sharedDefaults = sharedUserDefaults'
        ),
        '    self.sharedDefaults = UserDefaults(suiteName: HamsterConstants.appGroupName) ?? .standard',
    ),
]


def update_file(path: pathlib.Path, target_map: dict[str, str]) -> bool:
    """对单个文件执行所有替换规则。"""
    if not path.exists():
        print(f"  ⚠️  文件不存在，跳过: {path}")
        return False

    content = path.read_text()
    original = content

    for old, kind in REPLACEMENTS:
        content = content.replace(old, target_map[kind])

    if content == original:
        print(f"  - {path.name}: 无需替换")
        return False

    path.write_text(content)
    print(f"  ✅ {path.name}: 已替换")
    return True


def apply_patches(hamster_dir: pathlib.Path) -> int:
    """修复所有 App Group 强制解包 / fatalError 崩溃。"""
    patched = 0
    for rel_path, old_code, new_code in APP_GROUP_PATCHES:
        path = hamster_dir / rel_path
        if not path.exists():
            print(f"  ⚠️  文件不存在，跳过: {path.name}")
            continue

        content = path.read_text()
        if old_code not in content:
            print(f"  - {path.name}: 已修复或格式不匹配，跳过")
            continue

        content = content.replace(old_code, new_code)
        path.write_text(content)
        print(f"  ✅ {path.name}: 强制解包/fatalError 已修复")
        patched += 1
    return patched


def verify_no_remnants(hamster_dir: pathlib.Path) -> list[str]:
    """扫描所有源码文件，检查是否还有残留的旧标识符。"""
    remnant_patterns = [
        "dev.fuxiao.app.Hamster",
        "dev2.fuxiao.app.Hamster2",
        "dev.fuxiao.app.hamster",
        "iCloud.dev.fuxiao.app.hamsterapp",
        "iCloud~dev~fuxiao~app~hamsterapp",
    ]
    scan_extensions = {".swift", ".plist", ".entitlements", ".pbxproj", ".xcconfig"}
    warnings = []

    for ext in scan_extensions:
        for path in hamster_dir.rglob(f"*{ext}"):
            if ".build/" in str(path) or "DerivedData" in str(path):
                continue
            try:
                content = path.read_text()
            except Exception:
                continue
            for pattern in remnant_patterns:
                if pattern in content:
                    rel = path.relative_to(hamster_dir)
                    warnings.append(f"  ⚠️  残留发现: {rel} 中仍包含 '{pattern}'")

    return warnings


def main():
    if len(sys.argv) != 4:
        print(f"用法: python3 {sys.argv[0]} <hamster_dir> <bundle_id> <bundle_id_keyboard>")
        sys.exit(1)

    hamster_dir = pathlib.Path(sys.argv[1])
    bundle_id = sys.argv[2]
    bundle_id_keyboard = sys.argv[3]
    app_group = f"group.{bundle_id}"
    icloud_id = f"iCloud.{bundle_id}"
    icloud_path = f"iCloud~{bundle_id.replace('.', '~')}"

    target_map = {
        "main":        bundle_id,
        "keyboard":    bundle_id_keyboard,
        "group":       app_group,
        "icloud":      icloud_id,
        "icloud_path": icloud_path,
    }

    print(f"Bundle ID:          {bundle_id}")
    print(f"Bundle ID Keyboard: {bundle_id_keyboard}")
    print(f"App Group:          {app_group}")
    print(f"iCloud ID:          {icloud_id}")
    print(f"iCloud Path:        {icloud_path}")
    print()

    # ── 替换前：显示当前标识符 ──
    pbxproj = hamster_dir / "Hamster.xcodeproj/project.pbxproj"
    if pbxproj.exists():
        print("替换前的 Bundle ID (pbxproj):")
        for line in pbxproj.read_text().splitlines():
            if "PRODUCT_BUNDLE_IDENTIFIER" in line:
                print(f"  {line.strip()}")
        print()

    # ── 逐文件替换标识符 ──
    print("开始替换标识符:")
    updated = 0
    for rel_path in TARGET_FILES:
        path = hamster_dir / rel_path
        if update_file(path, target_map):
            updated += 1

    # ── 修复 App Group 强制解包 / fatalError 崩溃 ──
    print("\n修复 App Group 强制解包 / fatalError:")
    updated += apply_patches(hamster_dir)

    # ── 替换后：显示最终标识符 ──
    print()
    if pbxproj.exists():
        print("替换后的 Bundle ID (pbxproj):")
        for line in pbxproj.read_text().splitlines():
            if "PRODUCT_BUNDLE_IDENTIFIER" in line:
                print(f"  {line.strip()}")

    # ── 验证关键常量 ──
    constants_file = hamster_dir / "Packages/HamsterKit/Sources/Constants/HamsterConstants.swift"
    if constants_file.exists():
        print("\n替换后的关键常量 (HamsterConstants.swift):")
        for line in constants_file.read_text().splitlines():
            stripped = line.strip()
            if any(k in stripped for k in
                   ["appGroupName", "iCloudID", "keyboardBundleID", "appURL"]):
                print(f"  {stripped}")

    # ── 残留检查 ──
    print("\n检查残留的旧标识符:")
    warnings = verify_no_remnants(hamster_dir)
    if warnings:
        for w in warnings:
            print(w)
        print(f"\n⚠️  发现 {len(warnings)} 处残留，请手动检查（可能是注释/文档）")
    else:
        print("  ✅ 未发现残留的旧标识符")

    print(f"\n✅ 完成，共更新 {updated} 个文件")


if __name__ == "__main__":
    main()
