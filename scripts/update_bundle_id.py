"""
替换 Hamster 工程中所有与 Bundle ID / App Group 相关的硬编码标识符。

替换范围:
  - project.pbxproj      PRODUCT_BUNDLE_IDENTIFIER
  - *.entitlements        App Group ID
  - HamsterConstants.swift  appGroupName / keyboardBundleID

用法:
    python3 scripts/update_bundle_id.py <hamster_dir> <bundle_id> <bundle_id_keyboard>

示例:
    python3 scripts/update_bundle_id.py Hamster com.xlab.aiime com.xlab.aiime.HamsterKeyboard
"""

import sys
import pathlib

# 替换规则：(旧值, 类型)
# 类型: main=用 bundle_id 替换, keyboard=用 bundle_id_keyboard 替换,
#       group=用 group.{bundle_id} 替换
# 顺序：先长后短，避免部分匹配
REPLACEMENTS = [
    ("group.dev2.fuxiao.app.Hamster2", "group"),
    ("group.dev.fuxiao.app.Hamster",   "group"),
    ("dev2.fuxiao.app.Hamster2.HamsterKeyboard", "keyboard"),
    ("dev.fuxiao.app.Hamster.HamsterKeyboard",   "keyboard"),
    ("dev2.fuxiao.app.Hamster2", "main"),
    ("dev.fuxiao.app.Hamster",   "main"),
]

# 需要处理的文件（相对于 hamster_dir）
TARGET_FILES = [
    "Hamster.xcodeproj/project.pbxproj",
    "Hamster/Hamster.entitlements",
    "Hamster/HamsterDebug.entitlements",
    "HamsterKeyboard/HamsterKeyboard.entitlements",
    "HamsterKeyboard/HamsterKeyboardDebug.entitlements",
    "Packages/HamsterKit/Sources/Constants/HamsterConstants.swift",
]


def update_file(path: pathlib.Path, target_map: dict[str, str]) -> bool:
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


def main():
    if len(sys.argv) != 4:
        print(f"用法: python3 {sys.argv[0]} <hamster_dir> <bundle_id> <bundle_id_keyboard>")
        sys.exit(1)

    hamster_dir = pathlib.Path(sys.argv[1])
    bundle_id = sys.argv[2]
    bundle_id_keyboard = sys.argv[3]
    app_group = f"group.{bundle_id}"

    target_map = {
        "main": bundle_id,
        "keyboard": bundle_id_keyboard,
        "group": app_group,
    }

    print(f"Bundle ID:          {bundle_id}")
    print(f"Bundle ID Keyboard: {bundle_id_keyboard}")
    print(f"App Group:          {app_group}")
    print()

    # 替换前：显示当前标识符
    pbxproj = hamster_dir / "Hamster.xcodeproj/project.pbxproj"
    if pbxproj.exists():
        print("替换前的 Bundle ID (pbxproj):")
        for line in pbxproj.read_text().splitlines():
            if "PRODUCT_BUNDLE_IDENTIFIER" in line:
                print(f"  {line.strip()}")
        print()

    # 逐文件替换
    print("开始替换:")
    updated = 0
    for rel_path in TARGET_FILES:
        path = hamster_dir / rel_path
        if update_file(path, target_map):
            updated += 1

    # 替换后：显示最终标识符
    print()
    if pbxproj.exists():
        print("替换后的 Bundle ID (pbxproj):")
        for line in pbxproj.read_text().splitlines():
            if "PRODUCT_BUNDLE_IDENTIFIER" in line:
                print(f"  {line.strip()}")

    print(f"\n✅ 完成，共更新 {updated} 个文件")


if __name__ == "__main__":
    main()
