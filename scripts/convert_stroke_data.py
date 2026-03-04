#!/usr/bin/env python3
"""
笔顺数据转换脚本 - 将 makemeahanzi 的 SVG 文件转换为汉字命名
"""

import os
import shutil
from pathlib import Path

# 源目录和目标目录
SOURCE_DIR = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/strokes/temp/makemeahanzi-master/svgs")
TARGET_DIR = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/strokes")

# 常用汉字范围（CJK Unified Ideographs）
CJK_START = 0x4E00  # 一
CJK_END = 0x9FFF    # 龿

def convert_svg_files():
    """转换 SVG 文件为汉字命名"""
    print("[1/2] 开始转换 makemeahanzi SVG 文件...")

    converted = 0
    skipped = 0

    for svg_file in SOURCE_DIR.glob("*.svg"):
        try:
            # 文件名为 Unicode 码位（十进制）
            codepoint = int(svg_file.stem)

            # 检查是否在 CJK 范围内
            if CJK_START <= codepoint <= CJK_END:
                # 转换为汉字
                char = chr(codepoint)

                # 复制到目标目录
                target_file = TARGET_DIR / f"{char}.svg"
                shutil.copy2(svg_file, target_file)
                converted += 1
            else:
                skipped += 1
        except (ValueError, OSError) as e:
            skipped += 1
            continue

    print(f"  ✓ 转换完成：{converted} 个汉字")
    print(f"  - 跳过：{skipped} 个（非 CJK 字符或错误）")
    return converted

def cleanup_temp():
    """清理临时文件"""
    print("[2/2] 清理临时文件...")
    temp_dir = TARGET_DIR / "temp"
    if temp_dir.exists():
        shutil.rmtree(temp_dir)
    print("  ✓ 清理完成")

if __name__ == "__main__":
    print("=" * 50)
    print("笔顺数据转换脚本")
    print("=" * 50)

    # 确保目标目录存在
    TARGET_DIR.mkdir(parents=True, exist_ok=True)

    # 转换文件
    converted = convert_svg_files()

    # 清理
    cleanup_temp()

    print()
    print(f"✅ 全部完成！共 {converted} 个汉字的笔顺数据")
    print("=" * 50)
