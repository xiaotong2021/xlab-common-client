"""
替换 Hamster 工程中所有与 Bundle ID / App Group / iCloud / URL Scheme 相关的硬编码标识符，
修复 App Group 崩溃问题，并注入诊断日志帮助排查数据共享问题。

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
REPLACEMENTS = [
    # App Group
    ("group.dev2.fuxiao.app.Hamster2",                "group"),
    ("group.dev.fuxiao.app.Hamster",                  "group"),

    # iCloud container ID
    ("iCloud.dev.fuxiao.app.hamsterapp",              "icloud"),

    # iCloud 文件路径 (波浪号分隔)
    ("iCloud~dev~fuxiao~app~hamsterapp",              "icloud_path"),

    # 键盘扩展 Bundle ID
    ("dev2.fuxiao.app.Hamster2.HamsterKeyboard",      "keyboard"),
    ("dev.fuxiao.app.Hamster.HamsterKeyboard",        "keyboard"),

    # 主 Bundle ID (大写 H)
    ("dev2.fuxiao.app.Hamster2",                      "main"),
    ("dev.fuxiao.app.Hamster",                        "main"),

    # URL host (小写 h，在大写版本之后)
    ("dev.fuxiao.app.hamster",                        "main"),
]


# ── 需要进行标识符替换的文件 ─────────────────────────────────────────────────
TARGET_FILES = [
    "Hamster.xcodeproj/project.pbxproj",
    "Hamster/Hamster.entitlements",
    "Hamster/HamsterDebug.entitlements",
    "HamsterKeyboard/HamsterKeyboard.entitlements",
    "HamsterKeyboard/HamsterKeyboardDebug.entitlements",
    "Packages/HamsterKit/Sources/Constants/HamsterConstants.swift",
    "Hamster/Info.plist",
    "Packages/HamsterKeyboardKit/Sources/View/KeyboardToolbarView.swift",
    "Packages/HamsterKit/Sources/Extensions/FileManager+.swift",
    "Packages/HamsteriOS/Sources/ViewModel/Keyboard/KeyboardSettingsViewModel.swift",
    "Packages/HamsteriOS/Sources/ViewModel/RIME/RimeViewModel.swift",
]


# ── 代码修复 + 诊断日志补丁 ──────────────────────────────────────────────────
# (相对路径, 旧代码, 新代码)
CODE_PATCHES = [
    # ────────────────────────────────────────────────────────────────────────
    # 1. FileManager+.swift — shareURL 强制解包 → 安全回退 + 诊断日志
    # ────────────────────────────────────────────────────────────────────────
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
            '    let groupURL = FileManager.default.containerURL(\n'
            '      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)\n'
            '    if let groupURL = groupURL {\n'
            '      Logger.statistics.info("[AppGroup] shareURL: containerURL=\\(groupURL.path), appGroupName=\\(HamsterConstants.appGroupName)")\n'
            '      return groupURL.appendingPathComponent("InputSchema")\n'
            '    }\n'
            '    Logger.statistics.error("[AppGroup] shareURL: containerURL 返回 nil! appGroupName=\\(HamsterConstants.appGroupName), 回退到沙盒")\n'
            '    return sandboxDirectory.appendingPathComponent("AppGroupFallback/InputSchema")\n'
            '  }'
        ),
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 2. UserDefaults+.swift — UserDefaults.hamster 强制解包
    # ────────────────────────────────────────────────────────────────────────
    (
        "Packages/HamsterKit/Sources/Extensions/UserDefaults+.swift",
        '  static let hamster = UserDefaults(suiteName: HamsterConstants.appGroupName)!',
        '  static let hamster = UserDefaults(suiteName: HamsterConstants.appGroupName) ?? .standard',
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 3. PersistentController.swift — CoreData storeURL 强制解包 + 日志
    # ────────────────────────────────────────────────────────────────────────
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
            '    let storeURL = baseURL.appendingPathComponent("\\(name).sqlite")\n'
            '    print("[AppGroup] PersistentController: groupURL=\\(groupURL?.path ?? "nil"), storeURL=\\(storeURL.path)")'
        ),
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 4. UserManager.swift — fatalError → 安全回退 + 诊断日志
    # ────────────────────────────────────────────────────────────────────────
    (
        "Packages/HamsteriOS/Sources/Services/UserManager.swift",
        (
            '    // 初始化 AppGroup 共享存储，使用 HamsterConstants 中定义的 appGroupName\n'
            '    guard let sharedUserDefaults = UserDefaults(suiteName: HamsterConstants.appGroupName) else {\n'
            '      fatalError("UserManager: 无法初始化 AppGroup 共享存储，AppGroup 名称: \\(HamsterConstants.appGroupName)")\n'
            '    }\n'
            '    self.sharedDefaults = sharedUserDefaults'
        ),
        (
            '    // 初始化 AppGroup 共享存储\n'
            '    if let shared = UserDefaults(suiteName: HamsterConstants.appGroupName) {\n'
            '      self.sharedDefaults = shared\n'
            '      Logger.statistics.info("[AppGroup] UserManager: 共享存储初始化成功, appGroupName=\\(HamsterConstants.appGroupName)")\n'
            '    } else {\n'
            '      self.sharedDefaults = .standard\n'
            '      Logger.statistics.error("[AppGroup] UserManager: 共享存储初始化失败! 回退到 .standard, appGroupName=\\(HamsterConstants.appGroupName)")\n'
            '    }'
        ),
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 5. RimeContext.start — 注入 RIME 启动路径诊断日志
    # ────────────────────────────────────────────────────────────────────────
    (
        "Packages/HamsterKeyboardKit/Sources/RimeContext/RimeContext.swift",
        (
            '  func start(hasFullAccess: Bool) async {\n'
            '    Rime.shared.setNotificationDelegate(self)\n'
            '\n'
            '    // 启动\n'
            '    Rime.shared.start(Rime.createTraits(\n'
            '      sharedSupportDir: FileManager.appGroupSharedSupportDirectoryURL.path,\n'
            '      userDataDir: hasFullAccess ? FileManager.appGroupUserDataDirectoryURL.path : FileManager.sandboxUserDataDirectory.path\n'
            '    ))'
        ),
        (
            '  func start(hasFullAccess: Bool) async {\n'
            '    Rime.shared.setNotificationDelegate(self)\n'
            '\n'
            '    let sharedSupportPath = FileManager.appGroupSharedSupportDirectoryURL.path\n'
            '    let userDataPath = hasFullAccess ? FileManager.appGroupUserDataDirectoryURL.path : FileManager.sandboxUserDataDirectory.path\n'
            '    let ssExists = FileManager.default.fileExists(atPath: sharedSupportPath)\n'
            '    let udExists = FileManager.default.fileExists(atPath: userDataPath)\n'
            '    Logger.statistics.info("[RIME] start: shareURL=\\(FileManager.shareURL.path)")\n'
            '    Logger.statistics.info("[RIME] start: sharedSupport=\\(sharedSupportPath) exists=\\(ssExists)")\n'
            '    Logger.statistics.info("[RIME] start: userData=\\(userDataPath) exists=\\(udExists)")\n'
            '    Logger.statistics.info("[RIME] start: hasFullAccess=\\(hasFullAccess), appGroupName=\\(HamsterConstants.appGroupName)")\n'
            '\n'
            '    // 启动\n'
            '    Rime.shared.start(Rime.createTraits(\n'
            '      sharedSupportDir: sharedSupportPath,\n'
            '      userDataDir: userDataPath\n'
            '    ))'
        ),
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 6. KeyboardContext — 配置加载路径诊断日志
    # ────────────────────────────────────────────────────────────────────────
    (
        "Packages/HamsterKeyboardKit/Sources/KeyboardKit/Keyboard/KeyboardContext.swift",
        (
            '      // plist 格式大约 28.48 ms/ 27.59 ms\n'
            '      let data = try Data(contentsOf: FileManager.appGroupUserDataDirectoryURL.appendingPathComponent("/build/hamster.plist"))\n'
            '      self.hamsterConfiguration = try PropertyListDecoder().decode(HamsterConfiguration.self, from: data)'
        ),
        (
            '      // plist 格式大约 28.48 ms/ 27.59 ms\n'
            '      let configURL = FileManager.appGroupUserDataDirectoryURL.appendingPathComponent("/build/hamster.plist")\n'
            '      let configExists = FileManager.default.fileExists(atPath: configURL.path)\n'
            '      Logger.statistics.info("[KeyboardConfig] path=\\(configURL.path) exists=\\(configExists) appGroup=\\(HamsterConstants.appGroupName)")\n'
            '      let data = try Data(contentsOf: configURL)\n'
            '      self.hamsterConfiguration = try PropertyListDecoder().decode(HamsterConfiguration.self, from: data)\n'
            '      Logger.statistics.info("[KeyboardConfig] 配置加载成功")'
        ),
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 7. RimeContext.deployment — 同步到 AppGroup 后增加诊断日志
    # ────────────────────────────────────────────────────────────────────────
    (
        "Packages/HamsterKeyboardKit/Sources/RimeContext/RimeContext.swift",
        (
            '    // 将 Sandbox 目录下方案复制到AppGroup下\n'
            '    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)\n'
            '    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)\n'
            '  }\n'
            '\n'
            '  /// RIME 同步\n'
            '  /// 注意：仅可用于主 App 调用'
        ),
        (
            '    // 将 Sandbox 目录下方案复制到AppGroup下\n'
            '    Logger.statistics.info("[Deploy] 开始同步 Sandbox→AppGroup: sandbox=\\(FileManager.sandboxSharedSupportDirectory.path) → appGroup=\\(FileManager.appGroupSharedSupportDirectoryURL.path)")\n'
            '    try FileManager.syncSandboxSharedSupportDirectoryToAppGroup(override: true)\n'
            '    try FileManager.syncSandboxUserDataDirectoryToAppGroup(override: true)\n'
            '    let plistPath = FileManager.appGroupUserDataDirectoryURL.appendingPathComponent("/build/hamster.plist").path\n'
            '    Logger.statistics.info("[Deploy] 同步完成: hamster.plist exists=\\(FileManager.default.fileExists(atPath: plistPath))")\n'
            '  }\n'
            '\n'
            '  /// RIME 同步\n'
            '  /// 注意：仅可用于主 App 调用'
        ),
    ),

    # ────────────────────────────────────────────────────────────────────────
    # 8. SharedUserManager — 登录状态读取诊断日志
    #    注意：该文件已有基本日志，此补丁在初始化时增加 App Group 可用性检查
    # ────────────────────────────────────────────────────────────────────────
    (
        "Packages/HamsterKeyboardKit/Sources/Services/SharedUserManager.swift",
        (
            '  private init() {\n'
            '    Logger.statistics.info("SharedUserManager: 初始化跨target用户管理器，AppGroup: \\(HamsterConstants.appGroupName)")\n'
            '  }'
        ),
        (
            '  private init() {\n'
            '    let testGroupURL = FileManager.default.containerURL(\n'
            '      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)\n'
            '    Logger.statistics.info("[SharedUser] init: appGroupName=\\(HamsterConstants.appGroupName)")\n'
            '    Logger.statistics.info("[SharedUser] init: containerURL=\\(testGroupURL?.path ?? "nil")")\n'
            '    Logger.statistics.info("[SharedUser] init: sharedDefaults suiteName=\\(HamsterConstants.appGroupName)")\n'
            '    if let testData = self.sharedDefaults.data(forKey: self.userDefaultsKey) {\n'
            '      Logger.statistics.info("[SharedUser] init: 发现已存储的用户数据, size=\\(testData.count) bytes")\n'
            '    } else {\n'
            '      Logger.statistics.warning("[SharedUser] init: 未找到用户数据 (key=\\(self.userDefaultsKey))")\n'
            '    }\n'
            '  }'
        ),
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
    """应用所有代码修复补丁和诊断日志注入。"""
    patched = 0
    for rel_path, old_code, new_code in CODE_PATCHES:
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
        print(f"  ✅ {path.name}: 已修复 + 注入诊断日志")
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
    skip_patterns = {".build/", "DerivedData", ".git/", "Package.resolved"}
    warnings = []

    for ext in scan_extensions:
        for path in hamster_dir.rglob(f"*{ext}"):
            str_path = str(path)
            if any(skip in str_path for skip in skip_patterns):
                continue
            try:
                content = path.read_text()
            except Exception:
                continue
            for pattern in remnant_patterns:
                if pattern in content:
                    rel = path.relative_to(hamster_dir)
                    lines = [
                        f"    L{i+1}: {line.strip()}"
                        for i, line in enumerate(content.splitlines())
                        if pattern in line
                    ]
                    detail = "\n".join(lines[:5])
                    warnings.append(f"  ⚠️  {rel} 中残留 '{pattern}':\n{detail}")

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

    # ── 应用代码修复 + 诊断日志注入 ──
    print("\n应用代码修复 + 诊断日志:")
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

    # ── 验证关键 entitlements ──
    for ent_file in ["Hamster/Hamster.entitlements", "HamsterKeyboard/HamsterKeyboard.entitlements",
                     "Hamster/HamsterDebug.entitlements", "HamsterKeyboard/HamsterKeyboardDebug.entitlements"]:
        path = hamster_dir / ent_file
        if path.exists():
            content = path.read_text()
            groups = [line.strip() for line in content.splitlines()
                      if "group." in line and "<string>" in line]
            if groups:
                print(f"\n{ent_file} App Group: {', '.join(groups)}")

    # ── 残留检查 ──
    print("\n检查残留的旧标识符:")
    warnings = verify_no_remnants(hamster_dir)
    if warnings:
        for w in warnings:
            print(w)
        print(f"\n⚠️  发现 {len(warnings)} 处残留")
    else:
        print("  ✅ 未发现残留的旧标识符")

    print(f"\n✅ 完成，共更新 {updated} 个文件")


if __name__ == "__main__":
    main()
