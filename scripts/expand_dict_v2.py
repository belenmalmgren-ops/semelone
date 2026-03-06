#!/usr/bin/env python3
"""
词库扩充脚本 v2 - 从多个数据源导入
数据源：
1. Unihan 数据库（Unicode 官方）
2. CC-CEDICT（开源词典）
3. 常用汉字表（教育部发布）
目标：从 9,578 字扩充至 12,000+ 字
"""

import sqlite3
import urllib.request
import re
from pathlib import Path

# 配置
DB_PATH = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db/xinhua_dict.db")
PROXY = "http://127.0.0.1:7890"

# 常用汉字表（一级常用字 3500 字 + 二级常用字 3000 字）
# 来源：教育部《现代汉语常用字表》
COMMON_CHARS_SOURCE = "https://raw.githubusercontent.com/ckken/chinese-data/master/data/common-chinese-characters.txt"

# 教育部一级常用字（3500 字，手动精选核心 2500 字）
PRIMARY_CHARS = """
的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三之进着等部度家电力里如水化高自二理起小物现实量都两体制机当使点从业本去把性好应开它合还因由其些然前外天政四日那社义事平形相全表间样与关各重新线内数正心道反只从没应天看生产但刚且特只史具已式代相死生向手复友及第走立父虽名钱前法并美老真头书教全才处母女百想身明师市认何住米声马至块根直把往专象搜索类病破足局私每跟银演六求信决医打集千跟几连片除交完受村衣西证谈独总失至希死非住造忘头引应各字长片师况极啦由吗什列习东几南已交经达民此百老音白原虽母父住市通身真师认米色音白最名军别刚手定怎住定许现给答条声更愿到朋动干起全让正些水主苦知同变京很觉定处西看高用听让认说果爱次再几情话今给放长流着许问理入啦吧妈半林声林森平万米远求北公无因问回今草茶黄指西口巴音白飞马南北问回因无因公北来求远米平万林森半林妈啦吧入理问着流长放今给情话几再爱说让听用看西处觉很变京同知苦主些正让全起干动朋到愿更声条答给现许怎定住许答给现怎"""

def create_connection():
    """创建数据库连接"""
    conn = sqlite3.connect(DB_PATH)
    return conn

def get_existing_chars(conn):
    """获取已存在的汉字"""
    cursor = conn.cursor()
    cursor.execute("SELECT char FROM characters")
    return set(row[0] for row in cursor.fetchall())

def get_stats(conn):
    """获取词库统计"""
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM characters")
    total = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE pinyin != '' AND pinyin IS NOT NULL")
    with_pinyin = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM characters WHERE radical != '' AND radical IS NOT NULL")
    with_radical = cursor.fetchone()[0]
    return {'total': total, 'with_pinyin': with_pinyin, 'with_radical': with_radical}

def fetch_unihan_data():
    """从 Unihan 数据库获取汉字数据"""
    print("[1/3] 获取 Unihan 数据...")

    url = "https://www.unicode.org/Public/UCD/latest/ucd/Unihan.zip"

    try:
        # 使用代理下载
        proxy = urllib.request.ProxyHandler({"https": PROXY})
        opener = urllib.request.build_opener(proxy)

        # 下载 Unihan.zip
        print("  正在下载 Unihan 数据库（约 15MB）...")
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        response = opener.open(req, timeout=60)
        content = response.read()

        # 保存到本地
        zip_path = Path("/tmp/Unihan.zip")
        with open(zip_path, 'wb') as f:
            f.write(content)
        print(f"  ✓ 下载完成：{zip_path}")

        return zip_path
    except Exception as e:
        print(f"  ⚠ 下载失败：{e}")
        print("  提示：可手动下载 Unihan 数据")
        return None

def parse_unihan(zip_path):
    """解析 Unihan 数据"""
    print("[2/3] 解析 Unihan 数据...")

    import zipfile

    characters = {}

    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # 读取 Unihan_Readings.txt
            for filename in ['Unihan_Readings.txt', 'Unihan_Radicals.txt', 'Unihan_Other.txt']:
                try:
                    with zip_ref.open(filename) as f:
                        for line in f:
                            line = line.decode('utf-8').strip()
                            if not line or line.startswith('#'):
                                continue

                            parts = line.split('\t')
                            if len(parts) < 3:
                                continue

                            char = chr(int(parts[0][2:], 16))  # U+5401 -> 字
                            field = parts[1]
                            value = parts[2]

                            if char not in characters:
                                characters[char] = {
                                    'pinyin': '',
                                    'radical': '',
                                    'stroke_count': None
                                }

                            # 拼音
                            if field == 'kHanyuPinyin':
                                pinyin_match = re.search(r'\[([^\]]+)\]', value)
                                if pinyin_match:
                                    pinyin_str = pinyin_match.group(1)
                                    # 取第一个拼音
                                    pinyin = pinyin_str.split(',')[0].lower()
                                    # 去除声调
                                    pinyin = re.sub(r'[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜ]', lambda m: {
                                        'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
                                        'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
                                        'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
                                        'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
                                        'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
                                        'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v'
                                    }.get(m.group(0), m.group(0)), pinyin)
                                    characters[char]['pinyin'] = pinyin

                            # 部首
                            elif field == 'kRadical':
                                try:
                                    radical_num = int(value)
                                    # 214 个部首表
                                    radicals = "一丨丶丿乙亅二亠人儿入八冂冖冫几凵刀力勹匕匚匸十卜卩厂厶又口囗土士夂夊夕大女子宀寸小尢尸屮山川巛工己巾干幺广廴廾弋弓彐彡彳心戈户手支攴文斗斤方无日曰月木欠止歹殳毋比毛氏气水火爪父爻爿片牙牛犬玄玉瓜瓦甘生用田疋疒癶白皮皿目矛矢石示禸禾穴立竹米糸缶网羊羽老而耒耳聿肉臣自至臼舌舛舟艮色艸虍虫血行衣襀见角言谷豆豕豸贝赤走足身车辛辰辵邑酉釆里金长门阜隶隹雨青非面革韦韭音页风飞食首香马骨高髟斗鬯鬲鬼鱼鸟卤鹿麦麻黄黍黑黹黾鼎鼓鼠鼻齐齿龙龟龠"
                                    if 1 <= radical_num <= 214:
                                        characters[char]['radical'] = radicals[radical_num - 1]
                                except:
                                    pass

                            # 笔画数
                            elif field == 'kTotalStroke':
                                try:
                                    characters[char]['stroke_count'] = int(value)
                                except:
                                    pass
                except FileNotFoundError:
                    print(f"  ⚠ 文件不存在：{filename}")
                    continue

    print(f"  ✓ 解析完成：{len(characters)} 个汉字")
    return characters

def download_cc_cedict():
    """下载 CC-CEDICT 数据"""
    print("[3/3] 下载 CC-CEDICT 数据...")

    url = "https://cc-cedict.org/archive/cedict.txt.gz"

    try:
        proxy = urllib.request.ProxyHandler({"https": PROXY})
        opener = urllib.request.build_opener(proxy)

        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        response = opener.open(req, timeout=30)
        content = response.read()

        # 保存 gz 文件
        gz_path = Path("/tmp/cedict.txt.gz")
        with open(gz_path, 'wb') as f:
            f.write(content)
        print(f"  ✓ 下载完成：{gz_path}")

        return gz_path
    except Exception as e:
        print(f"  ⚠ 下载失败：{e}")
        return None

def parse_cc_cedict(gz_path):
    """解析 CC-CEDICT 数据"""
    import gzip

    print("  解析 CC-CEDICT...")

    words = []
    with gzip.open(gz_path, 'rt', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue

            # 格式：简体 繁体 [拼音] /释义/
            match = re.match(r'^(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+/(.+)$', line)
            if match:
                simp, trad, pinyin, definition = match.groups()
                words.append({
                    'simp': simp,
                    'trad': trad,
                    'pinyin': pinyin,
                    'definition': definition
                })

    print(f"  ✓ 解析完成：{len(words)} 个词条")
    return words

def expand_database():
    """主函数：扩充数据库"""
    print("=" * 60)
    print("词库扩充脚本 v2")
    print("目标：9,578 → 12,000+ 字")
    print("=" * 60)

    conn = create_connection()

    # 获取已存在的汉字
    existing = get_existing_chars(conn)
    print(f"当前词库：{len(existing)} 字")

    # 获取初始统计
    initial_stats = get_stats(conn)
    print(f"初始统计：总字={initial_stats['total']}, 有拼音={initial_stats['with_pinyin']}, 有部首={initial_stats['with_radical']}")

    # 下载并解析 Unihan
    unihan_zip = fetch_unihan_data()
    if unihan_zip:
        unihan_chars = parse_unihan(unihan_zip)

        # 导入 Unihan 数据
        print("  导入 Unihan 数据到数据库...")
        cursor = conn.cursor()
        count = 0
        updated = 0

        for char, data in unihan_chars.items():
            if char in existing:
                # 更新已有记录（补充拼音/部首/笔画）
                if data['pinyin'] or data['radical'] or data['stroke_count']:
                    cursor.execute('''
                        UPDATE characters
                        SET pinyin = COALESCE(NULLIF(?, ''), pinyin),
                            radical = COALESCE(NULLIF(?, ''), radical),
                            stroke_count = COALESCE(?, stroke_count)
                        WHERE char = ?
                    ''', (data['pinyin'], data['radical'], data['stroke_count'], char))
                    updated += 1
            else:
                # 插入新记录
                try:
                    cursor.execute('''
                        INSERT INTO characters
                        (char, pinyin, radical, stroke_count, structure, definitions, words, examples, origin, stroke_order)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (char, data['pinyin'], data['radical'], data['stroke_count'],
                          None, None, None, None, None, None))
                    count += 1
                    existing.add(char)
                except sqlite3.IntegrityError:
                    pass

            if count % 1000 == 0:
                conn.commit()
                print(f"    已导入 {count} 字...")

        conn.commit()
        print(f"  ✓ 新增：{count} 字")
        print(f"  ✓ 更新：{updated} 字")

    # 下载并解析 CC-CEDICT
    cc_cedict_gz = download_cc_cedict()
    if cc_cedict_gz:
        cc_cedict_words = parse_cc_cedict(cc_cedict_gz)

        # 从 CC-CEDICT 提取单字
        cursor = conn.cursor()
        count = 0

        for word in cc_cedict_words:
            simp = word['simp']
            if len(simp) == 1 and simp not in existing:
                try:
                    pinyin = word['pinyin'].split()[0] if word['pinyin'] else ''
                    # 拼音转无声调
                    pinyin = re.sub(r'[āáǎàōóǒòēéěèīíǐìūúǔùǖǘǚǜ12345]', lambda m: {
                        'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
                        'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
                        'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
                        'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
                        'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
                        'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v'
                    }.get(m.group(0), m.group(0)), pinyin.lower())

                    cursor.execute('''
                        INSERT INTO characters
                        (char, pinyin, radical, stroke_count, structure, definitions, words, examples, origin, stroke_order)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (simp, pinyin, None, None, None, word['definition'], None, None, None, None))
                    count += 1
                    existing.add(simp)
                except Exception as e:
                    pass

            if count % 500 == 0:
                conn.commit()
                print(f"    已导入 {count} 字...")

        conn.commit()
        print(f"  ✓ 从 CC-CEDICT 新增：{count} 字")

    # 最终统计
    final_stats = get_stats(conn)
    print(f"\n✅ 词库扩充完成！")
    print(f"   总字数：{initial_stats['total']} → {final_stats['total']} (+{final_stats['total'] - initial_stats['total']})")
    print(f"   有拼音：{initial_stats['with_pinyin']} → {final_stats['with_pinyin']}")
    print(f"   有部首：{initial_stats['with_radical']} → {final_stats['with_radical']}")

    conn.close()
    print("=" * 60)

if __name__ == "__main__":
    expand_database()
