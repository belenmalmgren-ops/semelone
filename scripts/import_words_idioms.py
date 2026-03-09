#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""导入词语和成语数据"""
import json
import sqlite3
from pathlib import Path

db_path = Path(__file__).parent.parent / 'assets/db/xinhua_dict.db'
ci_json = Path(__file__).parent.parent / 'temp_data/ci.json'
idiom_json = Path(__file__).parent.parent / 'temp_data/idiom.json'

conn = sqlite3.connect(str(db_path))
cursor = conn.cursor()

# 加载词语
print("加载词语数据...")
with open(ci_json, 'r', encoding='utf-8') as f:
    ci_data = json.load(f)

ci_by_char = {}
for item in ci_data:
    ci_text = item.get('ci', '')
    if ci_text and len(ci_text) > 0:
        first_char = ci_text[0]
        if first_char not in ci_by_char:
            ci_by_char[first_char] = []
        ci_by_char[first_char].append(ci_text)

# 加载成语
print("加载成语数据...")
with open(idiom_json, 'r', encoding='utf-8') as f:
    idioms = json.load(f)

idiom_by_char = {}
for item in idioms:
    word = item.get('word', '')
    if word and len(word) > 0:
        first_char = word[0]
        if first_char not in idiom_by_char:
            idiom_by_char[first_char] = []
        idiom_by_char[first_char].append(word)

# 更新数据库
print("更新数据库...")
cursor.execute("SELECT char FROM characters")
chars = [row[0] for row in cursor.fetchall()]

updated = 0
for char in chars:
    words = ci_by_char.get(char, [])[:20]
    idioms_list = idiom_by_char.get(char, [])[:10]

    if words or idioms_list:
        words_str = '|'.join(words) if words else None
        examples_str = '|'.join(idioms_list) if idioms_list else None

        cursor.execute('''
            UPDATE characters
            SET words = ?, examples = ?
            WHERE char = ?
        ''', (words_str, examples_str, char))

        if cursor.rowcount > 0:
            updated += 1

    if updated % 100 == 0:
        print(f"已更新 {updated} 个汉字...")

conn.commit()
conn.close()
print(f"✓ 完成！共更新 {updated} 个汉字")
