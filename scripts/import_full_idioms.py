#!/usr/bin/env python3
"""
扩充成语数据：从开源数据导入30,000+成语
数据源：chinese-xinhua (GitHub开源项目)
"""
import sqlite3
import json
import requests
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "assets/db/xinhua_dict.db"

def download_idiom_data():
    """从GitHub下载成语数据"""
    url = "https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/master/data/idiom.json"
    print(f"下载成语数据: {url}")
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()

def import_idioms():
    """导入成语数据到数据库"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # 下载数据
    idioms_data = download_idiom_data()
    print(f"获取到 {len(idioms_data)} 条成语")

    # 导入数据
    imported = 0
    for item in idioms_data:
        try:
            cursor.execute("""
                INSERT OR IGNORE INTO idioms (idiom, pinyin, definition, example)
                VALUES (?, ?, ?, ?)
            """, (
                item.get('word', ''),
                item.get('pinyin', ''),
                item.get('explanation', ''),
                item.get('example', '')
            ))
            if cursor.rowcount > 0:
                imported += 1
        except Exception as e:
            print(f"导入失败: {item.get('word')} - {e}")

    conn.commit()
    conn.close()
    print(f"✅ 成功导入 {imported} 条成语")

if __name__ == "__main__":
    import_idioms()
