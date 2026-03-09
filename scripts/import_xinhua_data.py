#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
导入新华字典数据到SQLite数据库
从 https://github.com/pwxcoo/chinese-xinhua 获取的数据
"""
import json
import sqlite3
import sys
from pathlib import Path

def import_data(db_path, word_json, ci_json, idiom_json):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 加载word.json（汉字数据）
    print(f"加载 {word_json}...")
    with open(word_json, 'r', encoding='utf-8') as f:
        words = json.load(f)

    # 加载ci.json（词语数据）
    print(f"加载 {ci_json}...")
    with open(ci_json, 'r', encoding='utf-8') as f:
        ci_data = json.load(f)

    # 创建词语索引（按汉字）
    ci_by_char = {}
    for item in ci_data:
        ci_text = item.get('ci', '')
        if ci_text and len(ci_text) > 0:
            first_char = ci_text[0]
            if first_char not in ci_by_char:
                ci_by_char[first_char] = []
            ci_by_char[first_char].append(ci_text)

    # 加载idiom.json（成语数据）
    print(f"加载 {idiom_json}...")
    with open(idiom_json, 'r', encoding='utf-8') as f:
        idioms = json.load(f)

    # 创建成语索引（按首字）
    idiom_by_char = {}
    for item in idioms:
        word = item.get('word', '')
        if word and len(word) > 0:
            first_char = word[0]
            if first_char not in idiom_by_char:
                idiom_by_char[first_char] = []
            idiom_by_char[first_char].append(word)

    # 更新数据库
    updated = 0
    for word_data in words:
        char = word_data.get('word', '')
        if not char:
            continue

        # 提取字段
        pinyin = word_data.get('pinyin', '')
        radical = word_data.get('radicals', '')
        strokes = word_data.get('strokes', 0)
        explanation = word_data.get('explanation', '')

        # 获取相关词语
        related_words = ci_by_char.get(char, [])[:20]  # 最多20个
        words_str = '|'.join(related_words) if related_words else None

        # 获取相关成语
        related_idioms = idiom_by_char.get(char, [])[:10]  # 最多10个
        examples_str = '|'.join(related_idioms) if related_idioms else None

        # 更新数据库
        cursor.execute('''
            UPDATE characters
            SET definitions = ?,
                words = ?,
                examples = ?,
                radical = COALESCE(radical, ?),
                stroke_count = COALESCE(stroke_count, ?)
            WHERE char = ?
        ''', (explanation, words_str, examples_str, radical, strokes, char))

        if cursor.rowcount > 0:
            updated += 1

        if updated % 100 == 0:
            print(f"已更新 {updated} 个汉字...")

    conn.commit()
    conn.close()

    print(f"✓ 完成！共更新 {updated} 个汉字")

if __name__ == '__main__':
    base_dir = Path(__file__).parent.parent
    db_path = base_dir / 'assets/db/xinhua_dict.db'
    data_dir = base_dir / 'temp_data/chinese-xinhua/data'

    # 如果仓库数据不存在，使用直接下载的文件
    if not data_dir.exists():
        data_dir = base_dir / 'temp_data'

    word_json = data_dir / 'word.json'
    ci_json = data_dir / 'ci.json'
    idiom_json = data_dir / 'idiom.json'

    if not all([word_json.exists(), ci_json.exists(), idiom_json.exists()]):
        print("错误：数据文件不存在")
        sys.exit(1)

    import_data(str(db_path), str(word_json), str(ci_json), str(idiom_json))
