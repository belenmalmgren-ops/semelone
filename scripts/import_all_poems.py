#!/usr/bin/env python3
"""导入全部古诗词（唐诗+宋词+元曲）"""
import sqlite3
import requests
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "assets/db/xinhua_dict.db"

POEM_FILES = [
    "全唐诗/poet.tang.0.json",
    "全唐诗/poet.tang.1000.json",
    "全唐诗/poet.tang.2000.json",
    "全唐诗/poet.tang.3000.json",
    "全唐诗/poet.tang.4000.json",
    "宋词/ci.song.0.json",
    "宋词/ci.song.1000.json",
    "宋词/ci.song.2000.json",
]

def import_poems():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    total = 0

    for file in POEM_FILES:
        url = f"https://raw.githubusercontent.com/chinese-poetry/chinese-poetry/master/{file}"
        try:
            print(f"下载: {file}")
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            poems = response.json()

            for poem in poems:
                try:
                    cursor.execute("""
                        INSERT OR IGNORE INTO poems (title, author, dynasty, content)
                        VALUES (?, ?, ?, ?)
                    """, (
                        poem.get('title', ''),
                        poem.get('author', ''),
                        '唐' if 'tang' in file else '宋',
                        '\n'.join(poem.get('paragraphs', []))
                    ))
                    if cursor.rowcount > 0:
                        total += 1
                except: pass
        except Exception as e:
            print(f"跳过 {file}: {e}")

    conn.commit()
    conn.close()
    print(f"✅ 总计导入 {total} 首诗词")

if __name__ == "__main__":
    import_poems()
