#!/usr/bin/env python3
"""
新华字典词库数据清洗脚本 - 简化版
创建示例数据库用于测试
"""

import sqlite3
import os
from pathlib import Path

OUTPUT_DIR = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
DB_PATH = OUTPUT_DIR / "xinhua_dict.db"

def create_database():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS characters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            char TEXT UNIQUE NOT NULL,
            pinyin TEXT NOT NULL,
            radical TEXT,
            stroke_count INTEGER,
            structure TEXT,
            definitions TEXT,
            words TEXT,
            examples TEXT,
            origin TEXT,
            stroke_order TEXT
        )
    ''')
    
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_pinyin ON characters(pinyin)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_radical ON characters(radical)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_stroke ON characters(stroke_count)')
    
    conn.commit()
    return conn

def create_sample_data(conn):
    cursor = conn.cursor()
    
    sample_chars = [
        ("的", "de", "白", 8, "左右结构", "助词|所属关系", "我的|好的", None, None, None),
        ("一", "yi", "一", 1, "独体字", "数词|最小正整数", "一个|一起", None, "指事字", None),
        ("是", "shi", "日", 9, "上下结构", "表示存在|解释", "不是|是的", None, "会意字", None),
        ("不", "bu", "一", 4, "独体字", "表示否定", "不是|不好", None, "指事字", None),
        ("了", "le", "乛", 2, "独体字", "助词|完成", "好了|来了", None, "象形字", None),
        ("人", "ren", "人", 2, "独体字", "高等动物", "人民|人类", None, "象形字", None),
        ("我", "wo", "戈", 7, "左右结构", "称自己", "我们|我的", None, "会意字", None),
        ("有", "you", "月", 6, "上下结构", "存在|拥有", "没有|有请", None, "会意字", None),
        ("在", "zai", "土", 6, "左右结构", "存在|位置", "现在|正在", None, "形声字", None),
        ("这", "zhe", "辶", 7, "半包围", "指示代词", "这个|这里", None, "形声字", None),
        ("中", "zhong", "丨", 4, "独体字", "中间|中国", "中国|中心", None, "指事字", None),
        ("国", "guo", "囗", 8, "全包围", "国家", "中国|国际", None, "形声字", None),
        ("大", "da", "大", 3, "独体字", "超过一般", "大家|大小", None, "象形字", None),
        ("家", "jia", "宀", 10, "上下结构", "家庭|住所", "家人|国家", None, "形声字", None),
        ("学", "xue", "子", 8, "上下结构", "学习", "学生|学校", None, "形声字", None),
        ("好", "hao", "女", 6, "左右结构", "优点多|使人满意", "好人|正好", None, "会意字", None),
        ("爱", "ai", "爫", 10, "上下结构", "对人或事物有深厚感情", "爱好|爱护", None, "形声字", None),
        ("小", "xiao", "小", 3, "独体字", "不大", "大小|小孩", None, "象形字", None),
        ("多", "duo", "夕", 6, "上下结构", "数量大", "多少|许多", None, "会意字", None),
        ("少", "shao", "小", 4, "独体字", "数量小", "少数|缺少", None, "指事字", None),
    ]
    
    for char_data in sample_chars:
        try:
            cursor.execute('''
                INSERT OR REPLACE INTO characters
                (char, pinyin, radical, stroke_count, structure, definitions, words, examples, origin, stroke_order)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', char_data)
        except sqlite3.Error as e:
            print(f"⚠ 插入失败 {char_data[0]}: {e}")
    
    conn.commit()
    cursor.execute('SELECT COUNT(*) FROM characters')
    count = cursor.fetchone()[0]
    print(f"✓ 示例数据完成：共 {count} 个汉字")
    return count

if __name__ == "__main__":
    print("=" * 50)
    print("新华字典数据库创建脚本")
    print("=" * 50)
    
    conn = create_database()
    print("✓ 数据库创建完成")
    
    create_sample_data(conn)
    
    conn.close()
    print(f"\n✅ 数据库已保存到：{DB_PATH}")
    print("=" * 50)
