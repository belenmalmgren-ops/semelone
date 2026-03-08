#!/usr/bin/env python3
"""导入古诗词数据"""
import sqlite3
import requests
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "assets/db/xinhua_dict.db"

def download_poems():
    """从GitHub下载古诗词数据"""
    url = "https://raw.githubusercontent.com/chinese-poetry/chinese-poetry/master/全唐诗/poet.tang.0.json"
    print(f"下载唐诗数据: {url}")
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()

def import_poems():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    poems_data = download_poems()
    print(f"获取到 {len(poems_data)} 首诗")

    imported = 0
    for poem in poems_data:
        try:
            cursor.execute("""
                INSERT OR IGNORE INTO poems (title, author, dynasty, content)
                VALUES (?, ?, ?, ?)
            """, (
                poem.get('title', ''),
                poem.get('author', ''),
                '唐',
                '\n'.join(poem.get('paragraphs', []))
            ))
            if cursor.rowcount > 0:
                imported += 1
        except Exception as e:
            print(f"导入失败: {e}")

    conn.commit()
    conn.close()
    print(f"✅ 成功导入 {imported} 首诗")

if __name__ == "__main__":
    import_poems()
