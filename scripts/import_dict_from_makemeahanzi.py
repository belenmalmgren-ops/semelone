#!/usr/bin/env python3
"""
词库导入脚本 - 从 makemeahanzi 导入完整词库
数据源：makemeahanzi dictionary.txt (JSON 格式)
"""

import sqlite3
import json
from pathlib import Path

# 输出路径
DB_PATH = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db/xinhua_dict.db")
DICT_FILE = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/strokes/temp/makemeahanzi-master/dictionary.txt")


def create_connection():
    """创建数据库连接"""
    conn = sqlite3.connect(DB_PATH)
    return conn


def get_existing_chars(conn):
    """获取已存在的汉字"""
    cursor = conn.cursor()
    cursor.execute("SELECT char FROM characters")
    return set(row[0] for row in cursor.fetchall())


def parse_dictionary():
    """解析 makemeahanzi dictionary.txt (JSON 格式)"""
    print("[1/3] 解析 makemeahanzi dictionary.txt...")

    characters = {}

    with open(DICT_FILE, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            try:
                data = json.loads(line)
                char = data.get("character", "")

                if not char:
                    continue

                # 获取拼音（取第一个）
                pinyin_list = data.get("pinyin", [])
                pinyin = pinyin_list[0] if pinyin_list else ""

                # 获取部首
                radical = data.get("radical", "")

                # 获取笔画数（从 decomposition 估算）
                decomposition = data.get("decomposition", "")
                stroke_count = len([c for c in decomposition if c != "？" and c != "⿰" and c != "⿱" and c != "⿲" and c != "⿳" and c != "⿴" and c != "⿵" and c != "⿶" and c != "⿷" and c != "⿸" and c != "⿹" and c != "⿺" and c != "⿻"])

                # 获取释义
                definition = data.get("definition", "")

                characters[char] = {
                    'pinyin': pinyin,
                    'radical': radical,
                    'stroke_count': stroke_count if stroke_count > 0 else None,
                    'definition': definition if definition else None
                }
            except (json.JSONDecodeError, KeyError, TypeError):
                continue

    print(f"  ✓ 解析完成：{len(characters)} 个汉字")
    return characters


def import_characters(conn, characters):
    """导入汉字数据"""
    print("[2/3] 导入汉字数据到数据库...")

    existing = get_existing_chars(conn)
    cursor = conn.cursor()

    count = 0
    updated = 0

    for char, data in characters.items():
        if char in existing:
            # 更新已有记录
            cursor.execute('''
                UPDATE characters
                SET pinyin = ?, radical = ?, stroke_count = ?, definitions = ?
                WHERE char = ?
            ''', (data['pinyin'], data['radical'], data['stroke_count'],
                  data['definition'], char))
            updated += 1
        else:
            # 插入新记录
            cursor.execute('''
                INSERT INTO characters
                (char, pinyin, radical, stroke_count, structure, definitions, words, examples, origin, stroke_order)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (char, data['pinyin'], data['radical'], data['stroke_count'],
                  None, data['definition'], None, None, None, None))
            count += 1

        if (count + updated) % 1000 == 0:
            conn.commit()
            print(f"    已处理 {count + updated} 字...")

    conn.commit()
    print(f"  ✓ 新增：{count} 字")
    print(f"  ✓ 更新：{updated} 字")
    return count, updated


def get_stats(conn):
    """获取词库统计"""
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM characters")
    total = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM characters WHERE pinyin != '' AND pinyin IS NOT NULL")
    with_pinyin = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT radical) FROM characters WHERE radical IS NOT NULL")
    with_radical = cursor.fetchone()[0]

    return {
        'total': total,
        'with_pinyin': with_pinyin,
        'with_radical': with_radical
    }


if __name__ == "__main__":
    print("=" * 60)
    print("词库导入脚本 - makemeahanzi (JSON 格式)")
    print("=" * 60)

    # 检查数据文件
    if not DICT_FILE.exists():
        print(f"错误：数据文件不存在：{DICT_FILE}")
        print("请先下载 makemeahanzi 数据")
        exit(1)

    conn = create_connection()

    # 解析字典
    characters = parse_dictionary()

    # 导入数据
    import_characters(conn, characters)

    # 统计
    stats = get_stats(conn)
    print(f"\n✅ 词库导入完成！")
    print(f"   总字数：{stats['total']}")
    print(f"   有拼音：{stats['with_pinyin']}")
    print(f"   有部首：{stats['with_radical']}")

    conn.close()
    print("=" * 60)
