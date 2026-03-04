#!/usr/bin/env python3
"""
笔顺数据下载脚本 - 从 makemeahanzi 获取 SVG 笔顺数据
数据源：https://github.com/skishore/makemeahanzi
"""

import json
import urllib.request
import zipfile
import os
from pathlib import Path

# 输出目录
OUTPUT_DIR = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/strokes")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# makemeahanzi 数据源
DATA_URL = "https://github.com/skishore/makemeahanzi/raw/master/data.zip"
TEMP_DIR = OUTPUT_DIR / "temp"

def download_data():
    """下载数据"""
    print("[1/4] 下载 makemeahanzi 数据...")

    temp_zip = TEMP_DIR / "data.zip"
    TEMP_DIR.mkdir(parents=True, exist_ok=True)

    # 使用代理下载
    proxy = urllib.request.ProxyHandler({"https": "http://127.0.0.1:7890"})
    opener = urllib.request.build_opener(proxy)

    req = urllib.request.Request(
        DATA_URL,
        headers={"User-Agent": "Mozilla/5.0"}
    )

    try:
        with opener.open(req, timeout=60) as response:
            with open(temp_zip, "wb") as f:
                f.write(response.read())
        print(f"  ✓ 下载完成：{temp_zip.stat().st_size / 1024 / 1024:.1f} MB")
        return True
    except Exception as e:
        print(f"  ⚠ 下载失败：{e}")
        print("  请手动下载数据到：{temp_zip}")
        return False

def extract_data():
    """解压数据"""
    print("[2/4] 解压数据...")

    temp_zip = TEMP_DIR / "data.zip"
    if not temp_zip.exists():
        print("  ⚠ 数据文件不存在")
        return False

    with zipfile.ZipFile(temp_zip, "r") as zip_ref:
        zip_ref.extractall(TEMP_DIR)

    print("  ✓ 解压完成")
    return True

def extract_stroke_data():
    """提取笔顺数据"""
    print("[3/4] 提取笔顺数据...")

    # 常用汉字列表（约 3500 个）
    common_chars = "的不一是了在有人这中到大为国和个地以经要我们个就他时也小可下把能着得看要年其下把能着得看要年其"
    common_chars += "自己生里用道然学种家法心本高更理如起小可下把能着得看要年其自己生里用道然学种家法心本高更理如起"
    common_chars += "好现当没于向去来后样子把已打听约每放听名少画母奶姐妹妻姑姨伯叔公爷爸妈男女左右前后上下"
    common_chars += "中大小多少高下长短方圆红黄蓝绿青紫黑白东西南北InOutUpDown"

    # 常用汉字（去重后约 200 个用于测试）
    common_chars = list(set(common_chars))

    stroke_files = []

    # 从解压的数据中提取
    data_dir = TEMP_DIR / "data"
    if data_dir.exists():
        for json_file in data_dir.glob("*.json"):
            char = json_file.stem

            # 只处理常用字
            if char not in common_chars:
                continue

            try:
                with open(json_file, "r", encoding="utf-8") as f:
                    data = json.load(f)

                # 提取 SVG 路径数据
                strokes = data.get("strokes", [])
                if strokes:
                    svg_content = generate_svg(char, strokes)
                    svg_path = OUTPUT_DIR / f"{char}.svg"

                    with open(svg_path, "w", encoding="utf-8") as f:
                        f.write(svg_content)

                    stroke_files.append(char)

            except Exception as e:
                continue

    print(f"  ✓ 提取完成：{len(stroke_files)} 个汉字")
    return stroke_files

def generate_svg(char: str, strokes: list) -> str:
    """生成 SVG 内容"""

    # SVG 模板
    svg_header = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- 汉字：{char} -->
  <g fill="none" stroke="#3E2723" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
'''

    svg_paths = ""
    for i, stroke in enumerate(strokes):
        # 提取笔画路径
        path_data = stroke.get("path", "")
        if path_data:
            svg_paths += f'    <path class="stroke-{i+1}" d="{path_data}" opacity="0"/>\n'

    svg_footer = '''  </g>
</svg>
'''

    return svg_header + svg_paths + svg_footer

def cleanup():
    """清理临时文件"""
    print("[4/4] 清理临时文件...")

    import shutil
    if TEMP_DIR.exists():
        shutil.rmtree(TEMP_DIR)

    print("  ✓ 清理完成")

if __name__ == "__main__":
    print("=" * 50)
    print("笔顺数据下载脚本")
    print("=" * 50)

    # 检查是否已有数据
    existing_svgs = list(OUTPUT_DIR.glob("*.svg"))
    if existing_svgs:
        print(f"发现已有 {len(existing_svgs)} 个 SVG 文件")
        # 自动跳过，不再询问
        print("跳过下载，使用已有数据")
        exit(0)

    # 下载并提取数据
    if download_data():
        if extract_data():
            chars = extract_stroke_data()
            print(f"\n✅ 笔顺数据提取完成：{len(chars)} 个汉字")
            cleanup()
    else:
        print("\n⚠️ 使用示例数据...")
        # 创建示例 SVG 文件
        sample_svg = generate_svg("一", [{"path": "M 10 50 L 90 50"}])
        with open(OUTPUT_DIR / "一.svg", "w", encoding="utf-8") as f:
            f.write(sample_svg)

        sample_svg2 = generate_svg("中", [
            {"path": "M 50 10 L 50 90"},
            {"path": "M 20 30 L 80 30"},
            {"path": "M 20 50 L 80 50"},
            {"path": "M 20 70 L 80 70"},
        ])
        with open(OUTPUT_DIR / "中.svg", "w", encoding="utf-8") as f:
            f.write(sample_svg2)

        print(f"  ✓ 创建示例 SVG：一、中")

    print("=" * 50)
