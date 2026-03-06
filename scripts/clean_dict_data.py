#!/usr/bin/env python3
"""
词库数据清洗脚本
目标：过滤生僻字，保留 12,000-15,000 常用字
"""

import sqlite3
from pathlib import Path

DB_PATH = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db/xinhua_dict.db")

def create_connection():
    return sqlite3.connect(DB_PATH)

def get_stats(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM characters")
    total = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE pinyin != '' AND pinyin IS NOT NULL")
    with_pinyin = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE radical != '' AND radical IS NOT NULL")
    with_radical = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE stroke_count IS NOT NULL")
    with_stroke = cursor.fetchone()[0]
    return {'total': total, 'with_pinyin': with_pinyin, 'with_radical': with_radical, 'with_stroke': with_stroke}

def clean_database(conn):
    """删除无拼音/部首的生僻字，保留常用字"""
    print("开始数据清洗...")
    cursor = conn.cursor()

    # 备份有数据的字
    cursor.execute('''
        SELECT char FROM characters
        WHERE pinyin != '' AND pinyin IS NOT NULL
           OR radical != '' AND radical IS NOT NULL
           OR stroke_count IS NOT NULL
    ''')
    valid_chars = set(row[0] for row in cursor.fetchall())
    print(f"  有效汉字（有拼音/部首/笔画）：{len(valid_chars)} 个")

    # 删除无效字
    cursor.execute('''
        DELETE FROM characters
        WHERE (pinyin = '' OR pinyin IS NULL)
          AND (radical = '' OR radical IS NULL)
          AND stroke_count IS NULL
    ''')
    deleted = cursor.rowcount
    conn.commit()

    print(f"  删除无效字：{deleted} 个")
    return deleted

def main():
    print("=" * 60)
    print("词库数据清洗脚本")
    print("目标：过滤生僻字，保留常用字")
    print("=" * 60)

    conn = create_connection()

    print("\n清洗前：")
    stats = get_stats(conn)
    print(f"  总字数：{stats['total']:,}")
    print(f"  有拼音：{stats['with_pinyin']:,}")
    print(f"  有部首：{stats['with_radical']:,}")
    print(f"  有笔画：{stats['with_stroke']:,}")

    # 清洗
    clean_database(conn)

    print("\n清洗后：")
    stats = get_stats(conn)
    print(f"  总字数：{stats['total']:,}")
    print(f"  有拼音：{stats['with_pinyin']:,} ({stats['with_pinyin']/stats['total']*100:.1f}%)")
    print(f"  有部首：{stats['with_radical']:,} ({stats['with_radical']/stats['total']*100:.1f}%)")
    print(f"  有笔画：{stats['with_stroke']:,} ({stats['with_stroke']/stats['total']*100:.1f}%)")

    conn.close()
    print("\n" + "=" * 60)
    print("✅ 数据清洗完成！")
    print("=" * 60)

if __name__ == "__main__":
    main()
