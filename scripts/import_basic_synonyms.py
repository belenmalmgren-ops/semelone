#!/usr/bin/env python3
"""导入常用字近反义词"""
import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "assets/db/xinhua_dict.db"

# 常用字近反义词数据
SYNONYMS_ANTONYMS = [
    # 格式：(汉字, 近义词, 反义词)
    ('大', '巨,宏,广', '小,微,细'),
    ('小', '微,细,少', '大,巨,宏'),
    ('多', '众,繁,丰', '少,寡,稀'),
    ('少', '寡,稀,缺', '多,众,繁'),
    ('好', '佳,优,善', '坏,劣,恶'),
    ('坏', '劣,恶,差', '好,佳,优'),
    ('高', '昂,耸,峻', '低,矮,下'),
    ('低', '矮,下,浅', '高,昂,耸'),
    ('长', '久,远,延', '短,暂,促'),
    ('短', '暂,促,简', '长,久,远'),
    ('快', '速,疾,迅', '慢,缓,迟'),
    ('慢', '缓,迟,徐', '快,速,疾'),
    ('新', '鲜,崭,初', '旧,陈,老'),
    ('旧', '陈,老,故', '新,鲜,崭'),
    ('美', '丽,靓,俏', '丑,陋,恶'),
    ('丑', '陋,恶,劣', '美,丽,靓'),
    ('强', '壮,健,劲', '弱,软,柔'),
    ('弱', '软,柔,脆', '强,壮,健'),
    ('冷', '寒,凉,冰', '热,暖,温'),
    ('热', '暖,温,炎', '冷,寒,凉'),
    ('明', '亮,光,清', '暗,昏,黑'),
    ('暗', '昏,黑,幽', '明,亮,光'),
    ('轻', '薄,软,飘', '重,厚,沉'),
    ('重', '厚,沉,浓', '轻,薄,软'),
    ('远', '遥,辽,深', '近,邻,接'),
    ('近', '邻,接,临', '远,遥,辽'),
]

def import_data():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    updated = 0

    for char, synonyms, antonyms in SYNONYMS_ANTONYMS:
        cursor.execute("""
            UPDATE characters
            SET synonyms = ?, antonyms = ?
            WHERE char = ?
        """, (synonyms, antonyms, char))
        if cursor.rowcount > 0:
            updated += 1

    conn.commit()
    conn.close()
    print(f"✅ 成功更新 {updated} 个汉字的近反义词")

if __name__ == "__main__":
    import_data()
