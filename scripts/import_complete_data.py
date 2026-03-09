#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""完整数据导入：中文释义、正确笔画数、成语例句、精选词语"""
import json
import sqlite3
from pathlib import Path

db_path = Path(__file__).parent.parent / 'assets/db/xinhua_dict.db'
word_json = Path(__file__).parent.parent / 'temp_data/word.json'
ci_json = Path(__file__).parent.parent / 'temp_data/ci.json'
idiom_json = Path(__file__).parent.parent / 'temp_data/idiom.json'

conn = sqlite3.connect(str(db_path))
cursor = conn.cursor()

# 1. 导入汉字基础数据（中文释义、正确笔画数）
print("导入汉字基础数据...")
with open(word_json, 'r', encoding='utf-8') as f:
    words = json.load(f)

word_dict = {}
for item in words:
    char = item.get('word', '')
    if char:
        word_dict[char] = {
            'explanation': item.get('explanation', ''),
            'strokes': int(item.get('strokes', 0)) if item.get('strokes', '').isdigit() else 0,
            'radicals': item.get('radicals', '')
        }

updated_chars = 0
for char, data in word_dict.items():
    cursor.execute('''
        UPDATE characters
        SET definitions = ?, stroke_count = ?, radical = ?
        WHERE char = ?
    ''', (data['explanation'], data['strokes'], data['radicals'], char))
    if cursor.rowcount > 0:
        updated_chars += 1

print(f"✓ 更新了 {updated_chars} 个汉字的基础数据")

# 2. 导入精选词语（适合小学生）
print("导入精选词语...")
with open(ci_json, 'r', encoding='utf-8') as f:
    ci_data = json.load(f)

# 筛选常用词语（长度2-4字）
ci_by_char = {}
for item in ci_data:
    ci_text = item.get('ci', '')
    if ci_text and 2 <= len(ci_text) <= 4:
        first_char = ci_text[0]
        if first_char not in ci_by_char:
            ci_by_char[first_char] = []
        if len(ci_by_char[first_char]) < 15:  # 每个字最多15个词
            ci_by_char[first_char].append(ci_text)

# 3. 导入完整成语数据（包含例句）
print("导入完整成语数据...")
with open(idiom_json, 'r', encoding='utf-8') as f:
    idioms = json.load(f)

idiom_by_char = {}
for item in idioms:
    word = item.get('word', '')
    if word and len(word) > 0:
        first_char = word[0]
        if first_char not in idiom_by_char:
            idiom_by_char[first_char] = []
        # 格式：成语|解释|例句
        explanation = item.get('explanation', '')
        example = item.get('example', '')
        idiom_str = f"{word}|{explanation}|{example}"
        if len(idiom_by_char[first_char]) < 8:  # 每个字最多8个成语
            idiom_by_char[first_char].append(idiom_str)

# 4. 更新词语和成语
print("更新词语和成语...")
cursor.execute("SELECT char FROM characters")
chars = [row[0] for row in cursor.fetchall()]

updated_words = 0
for char in chars:
    words_list = ci_by_char.get(char, [])
    idioms_list = idiom_by_char.get(char, [])

    if words_list or idioms_list:
        words_str = '|'.join(words_list) if words_list else None
        examples_str = '###'.join(idioms_list) if idioms_list else None

        cursor.execute('''
            UPDATE characters
            SET words = ?, examples = ?
            WHERE char = ?
        ''', (words_str, examples_str, char))

        if cursor.rowcount > 0:
            updated_words += 1

conn.commit()
conn.close()

print(f"✓ 更新了 {updated_words} 个汉字的词语和成语")
print("✓ 数据导入完成！")
