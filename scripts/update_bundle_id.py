"""
替换 Xcode 工程 (project.pbxproj) 中的 Bundle ID。

用法:
    python3 scripts/update_bundle_id.py <pbxproj_path> <bundle_id> <bundle_id_keyboard>

示例:
    python3 scripts/update_bundle_id.py \
        Hamster/Hamster.xcodeproj/project.pbxproj \
        com.xlab.aiime \
        com.xlab.aiime.HamsterKeyboard
"""

import sys
import pathlib

# 原始 Bundle ID（Hamster 工程默认值）
# 顺序：先长后短，避免短字符串误匹配到长字符串的前缀
ORIGINAL_BUNDLE_IDS = [
    ("dev2.fuxiao.app.Hamster2.HamsterKeyboard", "keyboard"),
    ("dev.fuxiao.app.Hamster.HamsterKeyboard",   "keyboard"),
    ("dev2.fuxiao.app.Hamster2",                 "main"),
    ("dev.fuxiao.app.Hamster",                   "main"),
]


def update_bundle_ids(pbxproj_path: str, bundle_id: str, bundle_id_keyboard: str):
    path = pathlib.Path(pbxproj_path)
    if not path.exists():
        print(f"❌ 文件不存在: {path}")
        sys.exit(1)

    content = path.read_text()

    print("替换前的 Bundle ID:")
    for line in content.splitlines():
        if "PRODUCT_BUNDLE_IDENTIFIER" in line:
            print(f"  {line.strip()}")

    target_map = {"main": bundle_id, "keyboard": bundle_id_keyboard}
    for original, kind in ORIGINAL_BUNDLE_IDS:
        content = content.replace(original, target_map[kind])

    path.write_text(content)

    print("\n替换后的 Bundle ID:")
    for line in content.splitlines():
        if "PRODUCT_BUNDLE_IDENTIFIER" in line:
            print(f"  {line.strip()}")

    print(f"\n✅ Bundle ID 替换完成: {path}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"用法: python3 {sys.argv[0]} <pbxproj_path> <bundle_id> <bundle_id_keyboard>")
        sys.exit(1)

    update_bundle_ids(sys.argv[1], sys.argv[2], sys.argv[3])
