#!/usr/bin/env python3
"""
词库扩充脚本 v3 - 简化版
从 Unihan 和 CC-CEDICT 导入数据
目标：从 9,578 字扩充至 12,000+ 字
"""

import sqlite3
import urllib.request
import gzip
import re
from pathlib import Path

# 配置
DB_PATH = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db/xinhua_dict.db")
PROXY = "http://127.0.0.1:7890"

# 214 个部首
RADICALS = "一丨丶丿乙亅二亠人儿入八冂冖冫几凵刀力勹匕匚匸十卜卩厂厶又口囗土士夂夊夕大女子宀寸小尢尸屮山川巛工己巾干幺广廴廾弋弓彐彡彳心戈户手支攴文斗斤方无日曰月木欠止歹殳毋比毛氏气水火爪父爻爿片牙牛犬玄玉瓜瓦甘生用田疋疒癶白皮皿目矛矢石示禸禾穴立竹米糸缶网羊羽老而耒耳聿肉臣自至臼舌舛舟艮色艸虍虫血行衣襀见角言谷豆豕豸贝赤走足身车辛辰辵邑酉釆里金长门阜隶隹雨青非面革韦韭音页风飞食首香马骨高髟斗鬯鬲鬼鱼鸟卤鹿麦麻黄黍黑黹黾鼎鼓鼠鼻齐齿龙龟龠"

def create_connection():
    conn = sqlite3.connect(DB_PATH)
    return conn

def get_existing_chars(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT char FROM characters")
    return set(row[0] for row in cursor.fetchall())

def get_stats(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM characters")
    total = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE pinyin != '' AND pinyin IS NOT NULL")
    with_pinyin = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE radical != '' AND radical IS NOT NULL")
    with_radical = cursor.fetchone()[0]
    return {'total': total, 'with_pinyin': with_pinyin, 'with_radical': with_radical}

def download_unihan():
    """下载 Unihan 数据库"""
    print("[1/2] 下载 Unihan 数据库...")
    url = "https://www.unicode.org/Public/UCD/latest/ucd/Unihan.zip"
    try:
        proxy = urllib.request.ProxyHandler({"https": PROXY})
        opener = urllib.request.build_opener(proxy)
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        response = opener.open(req, timeout=120)
        content = response.read()
        zip_path = Path("/tmp/Unihan.zip")
        with open(zip_path, 'wb') as f:
            f.write(content)
        print(f"  ✓ 下载完成：{zip_path}")
        return zip_path
    except Exception as e:
        print(f"  ⚠ 下载失败：{e}")
        return None

def parse_unihan(zip_path):
    """解析 Unihan ZIP 文件"""
    print("[2/2] 解析 Unihan 数据...")
    import zipfile

    characters = {}
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            with zip_ref.open('Unihan_Readings.txt') as f:
                for line in f:
                    line = line.decode('utf-8').strip()
                    if not line or line.startswith('#'):
                        continue
                    parts = line.split('\t')
                    if len(parts) < 3:
                        continue
                    try:
                        char = chr(int(parts[0][2:], 16))
                        field = parts[1]
                        value = parts[2]

                        if char not in characters:
                            characters[char] = {'pinyin': '', 'radical': '', 'stroke_count': None}

                        if field == 'kHanyuPinyin' and not characters[char]['pinyin']:
                            match = re.search(r'\[([^\]]+)\]', value)
                            if match:
                                pinyin = match.group(1).split(',')[0].lower()
                                pinyin = re.sub(r'[1-5]', '', pinyin)
                                characters[char]['pinyin'] = pinyin

                        elif field == 'kRadical' and not characters[char]['radical']:
                            try:
                                num = int(value)
                                if 1 <= num <= 214:
                                    characters[char]['radical'] = RADICALS[num - 1]
                            except:
                                pass

                        elif field == 'kTotalStroke' and characters[char]['stroke_count'] is None:
                            try:
                                characters[char]['stroke_count'] = int(value)
                            except:
                                pass
                    except:
                        continue
    except Exception as e:
        print(f"  ⚠ 解析失败：{e}")
        return {}

    print(f"  ✓ 解析完成：{len(characters)} 个汉字")
    return characters

def download_cc_cedict():
    """下载 CC-CEDICT 词典"""
    print("[1/2] 下载 CC-CEDICT 词典...")
    url = "https://cc-cedict.org/archive/cedict.txt.gz"
    try:
        proxy = urllib.request.ProxyHandler({"https": PROXY})
        opener = urllib.request.build_opener(proxy)
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        response = opener.open(req, timeout=60)
        content = response.read()
        gz_path = Path("/tmp/cedict.txt.gz")
        with open(gz_path, 'wb') as f:
            f.write(content)
        print(f"  ✓ 下载完成：{gz_path}")
        return gz_path
    except Exception as e:
        print(f"  ⚠ 下载失败：{e}")
        return None

def parse_cc_cedict(gz_path):
    """解析 CC-CEDICT 提取单字"""
    print("[2/2] 解析 CC-CEDICT 提取单字...")
    chars = {}
    with gzip.open(gz_path, 'rt', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            match = re.match(r'^(\S+)\s+\S+\s+\[([^\]]+)\]', line)
            if match:
                simp = match.group(1)
                pinyin = match.group(2)
                if len(simp) == 1:
                    if simp not in chars:
                        pinyin_clean = re.sub(r'[1-5]', '', pinyin.split()[0].lower()) if pinyin else ''
                        chars[simp] = pinyin_clean
    print(f"  ✓ 提取单字：{len(chars)} 个")
    return chars

def expand_database():
    """主函数"""
    print("=" * 60)
    print("词库扩充脚本 v3")
    print("目标：9,578 → 12,000+ 字")
    print("=" * 60)

    conn = create_connection()
    existing = get_existing_chars(conn)
    initial = get_stats(conn)

    print(f"\n初始状态：总字={initial['total']}, 有拼音={initial['with_pinyin']}, 有部首={initial['with_radical']}")
    print(f"已存在汉字：{len(existing)} 个\n")

    # 处理 Unihan
    unihan_zip = download_unihan()
    if unihan_zip:
        unihan_chars = parse_unihan(unihan_zip)
        cursor = conn.cursor()
        count, updated = 0, 0

        for char, data in unihan_chars.items():
            if char in existing:
                if data['pinyin'] or data['radical'] or data['stroke_count']:
                    cursor.execute('''UPDATE characters SET
                        pinyin = COALESCE(NULLIF(?, ''), pinyin),
                        radical = COALESCE(NULLIF(?, ''), radical),
                        stroke_count = COALESCE(?, stroke_count)
                        WHERE char = ?''',
                        (data['pinyin'], data['radical'], data['stroke_count'], char))
                    updated += 1
            else:
                try:
                    cursor.execute('''INSERT INTO characters
                        (char, pinyin, radical, stroke_count, structure, definitions, words, examples, origin, stroke_order)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                        (char, data['pinyin'], data['radical'], data['stroke_count'],
                         None, None, None, None, None, None))
                    count += 1
                    existing.add(char)
                except sqlite3.IntegrityError:
                    pass
            if count % 1000 == 0:
                conn.commit()
                print(f"  Unihan: 已导入 {count} 字...")

        conn.commit()
        print(f"  ✓ Unihan: 新增={count}, 更新={updated}")

    # 处理 CC-CEDICT
    cc_cedict_gz = download_cc_cedict()
    if cc_cedict_gz:
        cc_chars = parse_cc_cedict(cc_cedict_gz)
        cursor = conn.cursor()
        count = 0

        for char, pinyin in cc_chars.items():
            if char not in existing:
                try:
                    cursor.execute('''INSERT INTO characters
                        (char, pinyin, radical, stroke_count, structure, definitions, words, examples, origin, stroke_order)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                        (char, pinyin, None, None, None, None, None, None, None, None))
                    count += 1
                    existing.add(char)
                except:
                    pass
            if count % 500 == 0:
                conn.commit()
                print(f"  CC-CEDICT: 已导入 {count} 字...")

        conn.commit()
        print(f"  ✓ CC-CEDICT: 新增={count}")

    # 最终统计
    final = get_stats(conn)
    print(f"\n✅ 词库扩充完成！")
    print(f"   总字数：{initial['total']} → {final['total']} (+{final['total'] - initial['total']})")
    print(f"   有拼音：{initial['with_pinyin']} → {final['with_pinyin']}")
    print(f"   有部首：{initial['with_radical']} → {final['with_radical']}")

    conn.close()
    print("=" * 60)

if __name__ == "__main__":
    expand_database()
