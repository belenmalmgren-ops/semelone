#!/usr/bin/env python3
"""导入近反义词数据"""
import sqlite3
import requests
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "assets/db/xinhua_dict.db"

def download_word_data():
    """从GitHub下载词语数据（包含近反义词）"""
    url = "https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/master/data/word.json"
    print(f"下载词语数据: {url}")
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()

def import_synonyms_antonyms():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    words_data = download_word_data()
    print(f"获取到 {len(words_data)} 个词语")

    updated = 0
    for word in words_data:
        word_text = word.get('word', '')
        if len(word_text) == 1:  # 只处理单字
            synonyms = word.get('tongyi', '')
            antonyms = word.get('fanyi', '')

            if synonyms or antonyms:
                cursor.execute("""
                    UPDATE characters
                    SET synonyms = ?, antonyms = ?
                    WHERE char = ?
                """, (synonyms, antonyms, word_text))
                if cursor.rowcount > 0:
                    updated += 1

    conn.commit()
    conn.close()
    print(f"✅ 成功更新 {updated} 个汉字的近反义词")

if __name__ == "__main__":
    import_synonyms_antonyms()
