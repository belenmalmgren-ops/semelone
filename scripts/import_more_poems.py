#!/usr/bin/env python3
"""导入更多古诗词（扩展到50,000+）"""
import sqlite3
import requests
from pathlib import Path
import time

DB_PATH = Path(__file__).parent.parent / "assets/db/xinhua_dict.db"

# 更多诗词文件
POEM_FILES = [
    # 唐诗（约43,000首）
    *[f"全唐诗/poet.tang.{i*1000}.json" for i in range(43)],
    # 宋词（约21,000首）
    *[f"宋词/ci.song.{i*1000}.json" for i in range(21)],
    # 元曲
    "元曲/yuanqu.json",
]

def import_poems():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    total = 0
    failed = 0

    for file in POEM_FILES:
        url = f"https://raw.githubusercontent.com/chinese-poetry/chinese-poetry/master/{file}"
        try:
            print(f"下载: {file}")
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            poems = response.json()

            for poem in poems:
                try:
                    dynasty = '唐' if 'tang' in file else ('宋' if 'song' in file else '元')
                    cursor.execute("""
                        INSERT OR IGNORE INTO poems (title, author, dynasty, content)
                        VALUES (?, ?, ?, ?)
                    """, (
                        poem.get('title', ''),
                        poem.get('author', ''),
                        dynasty,
                        '\n'.join(poem.get('paragraphs', []))
                    ))
                    if cursor.rowcount > 0:
                        total += 1
                except: pass

            # 每10个文件提交一次
            if total % 10000 == 0:
                conn.commit()
                print(f"已导入 {total} 首")

            time.sleep(0.5)  # 避免请求过快
        except Exception as e:
            print(f"跳过 {file}: {e}")
            failed += 1
            if failed > 10:  # 连续失败超过10次则停止
                break

    conn.commit()
    conn.close()
    print(f"✅ 总计导入 {total} 首诗词")

if __name__ == "__main__":
    import_poems()
