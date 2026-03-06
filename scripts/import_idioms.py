#!/usr/bin/env python3
"""
成语词典导入脚本
从多个数据源导入 30,000+ 成语词条
目标：新建 idioms 表，导入成语数据
"""

import sqlite3
import json
from pathlib import Path

DB_PATH = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db/xinhua_dict.db")

# 常用成语数据（约 30,000 条，此处为示例数据，实际需要完整数据源）
# 数据来源：开源成语词典
IDIOMS = [
    # A 开头
    {"idiom": "安安稳稳", "pinyin": "an an wen wen", "definition": "形容十分安定稳当", "example": "日子过得安安稳稳"},
    {"idiom": "安分守己", "pinyin": "an fen shou ji", "definition": "规矩老实，守本分", "example": "他是个安分守己的人"},
    {"idiom": "安居乐业", "pinyin": "an ju le ye", "definition": "安定地生活，愉快地工作", "example": "人民安居乐业"},
    {"idiom": "安身立命", "pinyin": "an shen li ming", "definition": "生活有着落，精神有寄托", "example": "安身立命之所"},
    {"idiom": "安然无恙", "pinyin": "an ran wu yang", "definition": "平安无事，没有遭受损害", "example": "地震后安然无恙"},
    {"idiom": "按兵不动", "pinyin": "an bing bu dong", "definition": "暂时不行动，等待时机", "example": "敌军按兵不动"},
    {"idiom": "按部就班", "pinyin": "an bu jiu ban", "definition": "按照一定的条理，遵循一定的程序", "example": "按部就班地学习"},
    {"idiom": "唉声叹气", "pinyin": "ai sheng tan qi", "definition": "因伤感、烦闷或痛苦而发出叹息", "example": "整天唉声叹气"},
    {"idiom": "爱不释手", "pinyin": "ai bu shi shou", "definition": "喜爱得舍不得放手", "example": "这本书让人爱不释手"},
    {"idiom": "爱屋及乌", "pinyin": "ai wu ji wu", "definition": "爱一个人而连带爱他屋上的乌鸦，比喻爱一个人而连带地关心到与他有关的人或物", "example": "爱屋及乌的情谊"},

    # B 开头
    {"idiom": "拔苗助长", "pinyin": "ba miao zhu zhang", "definition": "比喻违反事物发展的客观规律，急于求成，反而把事情弄糟", "example": "教育孩子不能拔苗助长"},
    {"idiom": "跋山涉水", "pinyin": "ba shan she shui", "definition": "翻山越岭，趟水过河，形容走远路的艰苦", "example": "跋山涉水来到此地"},
    {"idiom": "白手起家", "pinyin": "bai shou qi jia", "definition": "形容原来没有基础或条件很差而创立起一番事业", "example": "他白手起家创建了公司"},
    {"idiom": "百折不挠", "pinyin": "bai zhe bu nao", "definition": "比喻意志坚强，无论受到多少次挫折，毫不动摇退缩", "example": "百折不挠的精神"},
    {"idiom": "班门弄斧", "pinyin": "ban men nong fu", "definition": "在鲁班门前舞弄斧子，比喻在行家面前卖弄本领", "example": "在专家面前发言，真是班门弄斧"},
    {"idiom": "半途而废", "pinyin": "ban tu er fei", "definition": "指做事不能坚持到底，中途停顿，有始无终", "example": "学习不能半途而废"},
    {"idiom": "包罗万象", "pinyin": "bao luo wan xiang", "definition": "形容内容丰富，应有尽有", "example": "这部百科全书包罗万象"},
    {"idiom": "饱经风霜", "pinyin": "bao jing feng shuang", "definition": "形容经历过长期的艰难困苦的生活和斗争", "example": "老人饱经风霜的脸上写满了沧桑"},
    {"idiom": "抱薪救火", "pinyin": "bao xin jiu huo", "definition": "抱着柴草去救火，比喻用错误的方法去消除灾祸，结果使灾祸反而扩大", "example": "这种做法无异于抱薪救火"},
    {"idiom": "暴跳如雷", "pinyin": "bao tiao ru lei", "definition": "急怒叫跳，像打雷一样猛烈，形容又急又怒，大发脾气的样子", "example": "他气得暴跳如雷"},

    # C 开头
    {"idiom": "才疏学浅", "pinyin": "cai shu xue qian", "definition": "才学不高，学识不深", "example": "我才疏学浅，还请多多指教"},
    {"idiom": "财源广进", "pinyin": "cai yuan guang jin", "definition": "四面八方，财运无穷", "example": "祝您财源广进"},
    {"idiom": "惨淡经营", "pinyin": "can dan jing ying", "definition": "费尽心思辛辛苦苦地经营筹划", "example": "公司惨淡经营多年终于盈利"},
    {"idiom": "草木皆兵", "pinyin": "cao mu jie bing", "definition": "把山上的草木都当做敌兵，形容人在惊慌时疑神疑鬼", "example": "敌军草木皆兵，惊慌失措"},
    {"idiom": "层出不穷", "pinyin": "ceng chu bu qiong", "definition": "接连不断地出现，没有穷尽", "example": "新事物层出不穷"},
    {"idiom": "插科打诨", "pinyin": "cha ke da hun", "definition": "指演剧中插入一些滑稽幽默的动作和台词", "example": "相声演员插科打诨逗乐观众"},
    {"idiom": "察言观色", "pinyin": "cha yan guan se", "definition": "观察别人的说话脸色，揣度对方的心意", "example": "他善于察言观色"},
    {"idiom": "差强人意", "pinyin": "cha qiang ren yi", "definition": "大体上还能使人满意", "example": "这次考试结果差强人意"},
    {"idiom": "缠绵悱恻", "pinyin": "chan mian fei ce", "definition": "形容内心悲苦难以排遣，也形容诗文情感婉转凄凉", "example": "缠绵悱恻的爱情故事"},
    {"idiom": "畅所欲言", "pinyin": "chang suo yu yan", "definition": "痛痛快快地把要说的话都说出来", "example": "会议上大家畅所欲言"},

    # D 开头
    {"idiom": "大刀阔斧", "pinyin": "da dao kuo fu", "definition": "比喻办事果断而有魄力", "example": "公司大刀阔斧地改革"},
    {"idiom": "大器晚成", "pinyin": "da qi wan cheng", "definition": "指能担当重任的人物要经过长期的锻炼，所以成就较晚", "example": "他大器晚成，中年后才取得成功"},
    {"idiom": "大智若愚", "pinyin": "da zhi ruo yu", "definition": "才智出众的人表面看来好像愚笨", "example": "他大智若愚，深藏不露"},
    {"idiom": "旦夕祸福", "pinyin": "dan xi huo fu", "definition": "早晚之间灾祸和福气就会到来，形容变化无常", "example": "人生旦夕祸福，难以预料"},
    {"idiom": "当机立断", "pinyin": "dang ji li duan", "definition": "抓住时机，立刻决断", "example": "他当机立断解决了危机"},
    {"idiom": "道听途说", "pinyin": "dao ting tu shuo", "definition": "路上听来的话，指没有根据的传闻", "example": "这些都是道听途说的消息"},
    {"idiom": "得陇望蜀", "pinyin": "de long wang shu", "definition": "已经取得陇右，还想攻取西蜀，比喻贪得无厌", "example": "他得陇望蜀，永不满足"},
    {"idiom": "得天独厚", "pinyin": "de tian du hou", "definition": "具备的条件特别优越，所处环境特别好", "example": "这里得天独厚的自然条件"},
    {"idiom": "德才兼备", "pinyin": "de cai jian bei", "definition": "既有好的思想品质，又有工作的才干和能力", "example": "他是一位德才兼备的干部"},
    {"idiom": "滴水穿石", "pinyin": "di shui chuan shi", "definition": "水不断下滴，可以滴穿石头，比喻只要有恒心，不断努力，事情一定成功", "example": "滴水穿石的精神值得学习"},

    # E 开头
    {"idiom": "尔虞我诈", "pinyin": "er yu wo zha", "definition": "互相猜疑，互相欺骗", "example": "商场中尔虞我诈的现象"},
    {"idiom": "耳濡目染", "pinyin": "er ru mu ran", "definition": "耳朵经常听到，眼睛经常看到，不知不觉地受到影响", "example": "他耳濡目染，也爱上了音乐"},
    {"idiom": "耳熟能详", "pinyin": "er shu neng xiang", "definition": "听得多了，能够说得很清楚", "example": "这是一个耳熟能详的故事"},
    {"idiom": "耳提面命", "pinyin": "er ti mian ming", "definition": "不仅是当面告诉他，而且是提着他的耳朵向他讲，形容长辈教导热心恳切", "example": "老师的耳提面命让他受益匪浅"},
    {"idiom": "二桃杀三士", "pinyin": "er tao sha san shi", "definition": "比喻用计谋借刀杀人", "example": "这是二桃杀三士的计谋"},

    # F 开头
    {"idiom": "发奋图强", "pinyin": "fa fen tu qiang", "definition": "下定决心，努力谋求强盛", "example": "发奋图强，振兴中华"},
    {"idiom": "发扬光大", "pinyin": "fa yang guang da", "definition": "使好的作风、传统等得到发展和提高", "example": "发扬光大优良传统"},
    {"idiom": "翻山越岭", "pinyin": "fan shan yue ling", "definition": "翻过不少山头，形容野外工作或旅途的辛苦", "example": "翻山越岭来到此地"},
    {"idiom": "反败为胜", "pinyin": "fan bai wei sheng", "definition": "扭转败局，变为胜利", "example": "球队反败为胜"},
    {"idiom": "方兴未艾", "pinyin": "fang xing wei ai", "definition": "事物正在发展，尚未达到止境", "example": "人工智能产业方兴未艾"},
    {"idiom": "防微杜渐", "pinyin": "fang wei du jian", "definition": "在坏思想、坏事或错误刚冒头时就加以防止、杜绝", "example": "防微杜渐，防患于未然"},
    {"idiom": "飞扬跋扈", "pinyin": "fei yang ba hu", "definition": "骄横放肆，目中无人", "example": "此人飞扬跋扈，令人讨厌"},
    {"idiom": "废寝忘食", "pinyin": "fei qin wang shi", "definition": "顾不得睡觉，忘记了吃饭，形容专心努力", "example": "他废寝忘食地工作"},
    {"idiom": "分道扬镳", "pinyin": "fen dao yang biao", "definition": "比喻目标不同，各走各的路或各干各的事", "example": "两人理念不合，最终分道扬镳"},
    {"idiom": "奋不顾身", "pinyin": "fen bu gu shen", "definition": "奋勇向前，不考虑个人安危", "example": "他奋不顾身地救人"},

    # G 开头
    {"idiom": "改过自新", "pinyin": "gai guo zi xin", "definition": "改正错误，重新做起", "example": "他改过自新，重新做人"},
    {"idiom": "改头换面", "pinyin": "gai tou huan mian", "definition": "比喻只改形式，不变内容", "example": "产品改头换面重新上市"},
    {"idiom": "盖世无双", "pinyin": "gai shi wu shuang", "definition": "才能或武艺当代第一，没有人能比得上", "example": "盖世无双的英雄"},
    {"idiom": "甘拜下风", "pinyin": "gan bai xia feng", "definition": "表示真心佩服，自认不如", "example": "他的棋艺让我甘拜下风"},
    {"idiom": "肝脑涂地", "pinyin": "gan nao tu di", "definition": "形容惨死，也形容竭尽忠诚，任何牺牲都在所不惜", "example": "愿为事业肝脑涂地"},
    {"idiom": "感激涕零", "pinyin": "gan ji ti ling", "definition": "感激得掉下眼泪，形容极度感激", "example": "对他的帮助感激涕零"},
    {"idiom": "高歌猛进", "pinyin": "gao ge meng jin", "definition": "高声歌唱，勇猛前进，形容在前进的道路上斗志昂扬", "example": "公司高歌猛进，业绩翻倍"},
    {"idiom": "高瞻远瞩", "pinyin": "gao zhan yuan zhu", "definition": "站得高，看得远，比喻眼光远大", "example": "领导高瞻远瞩，制定长远规划"},
    {"idiom": "歌功颂德", "pinyin": "ge gong song de", "definition": "颂扬功绩和德行", "example": "歌功颂德的文章"},
    {"idiom": "各得其所", "pinyin": "ge de qi suo", "definition": "每个人或事物都得到恰当的位置或安排", "example": "大家各得其所，皆大欢喜"},

    # H 开头
    {"idiom": "海阔天空", "pinyin": "hai kuo tian kong", "definition": "像大海一样辽阔，像天空一样无边无际，形容大自然的广阔，也比喻言谈议论等漫无边际", "example": "两人海阔天空地聊着"},
    {"idiom": "含辛茹苦", "pinyin": "han xin ru ku", "definition": "形容忍受辛苦或吃尽辛苦", "example": "母亲含辛茹苦把我养大"},
    {"idiom": "汗马功劳", "pinyin": "han ma gong lao", "definition": "指在战场上建立战功，现指辛勤工作做出的贡献", "example": "为公司立下汗马功劳"},
    {"idiom": "沆瀣一气", "pinyin": "hang xie yi qi", "definition": "比喻臭味相投的人结合在一起", "example": "这帮人沆瀣一气，狼狈为奸"},
    {"idiom": "好高骛远", "pinyin": "hao gao wu yuan", "definition": "比喻不切实际地追求过高过远的目标", "example": "学习要好高骛远，脚踏实地"},
    {"idiom": "好逸恶劳", "pinyin": "hao yi wu lao", "definition": "贪图安逸，厌恶劳动", "example": "他好逸恶劳，一事无成"},
    {"idiom": "合情合理", "pinyin": "he qing he li", "definition": "符合情理", "example": "这个要求合情合理"},
    {"idiom": "和蔼可亲", "pinyin": "he ai ke qin", "definition": "态度温和，容易接近", "example": "老师和蔼可亲"},
    {"idiom": "和风细雨", "pinyin": "he feng xi yu", "definition": "比喻方式和缓，不粗暴", "example": "和风细雨式的教育"},
    {"idiom": "鹤立鸡群", "pinyin": "he li ji qun", "definition": "像鹤站在鸡群中一样，比喻一个人的仪表或才能在周围一群人里显得很突出", "example": "他在人群中鹤立鸡群"},

    # J 开头
    {"idiom": "机不可失", "pinyin": "ji bu ke shi", "definition": "机会难得，不可错过", "example": "机不可失，时不再来"},
    {"idiom": "积劳成疾", "pinyin": "ji lao cheng ji", "definition": "因长期工作劳累而生病", "example": "他积劳成疾，住进了医院"},
    {"idiom": "积少成多", "pinyin": "ji shao cheng duo", "definition": "积累少的可以变成多的", "example": " savings 积少成多"},
    {"idiom": "集思广益", "pinyin": "ji si guang yi", "definition": "集中众人的智慧，广泛吸收有益的意见", "example": "会议集思广益，效果很好"},
    {"idiom": "家喻户晓", "pinyin": "jia yu hu xiao", "definition": "家家户户都知道，形容人所共知", "example": "家喻户晓的名人"},
    {"idiom": "坚不可摧", "pinyin": "jian bu ke cui", "definition": "非常坚固，摧毁不了", "example": "坚不可摧的友谊"},
    {"idiom": "见义勇为", "pinyin": "jian yi yong wei", "definition": "看到正义的事，就勇敢地去做", "example": "他见义勇为，救下了落水儿童"},
    {"idiom": "见异思迁", "pinyin": "jian yi si qian", "definition": "看见另一个事物就想改变原来的主意，指意志不坚定，喜爱不专一", "example": "他见异思迁，频繁跳槽"},
    {"idiom": "剑拔弩张", "pinyin": "jian ba nu zhang", "definition": "形容形势紧张，一触即发", "example": "双方剑拔弩张，大战一触即发"},
    {"idiom": "健步如飞", "pinyin": "jian bu ru fei", "definition": "步伐矫健，跑得飞快", "example": "老人健步如飞"},
]


def create_connection():
    return sqlite3.connect(DB_PATH)


def create_idioms_table(conn):
    """创建成语表"""
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS idioms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idiom TEXT UNIQUE NOT NULL,
            pinyin TEXT NOT NULL,
            definition TEXT,
            example TEXT,
            tags TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    # 创建索引
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_idiom_pinyin ON idioms(pinyin)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_idiom_first_char ON idioms(substring(idiom, 1, 1))')
    conn.commit()
    print("✓ 成语表创建完成")


def get_existing_idioms(conn):
    """获取已存在的成语"""
    cursor = conn.cursor()
    cursor.execute("SELECT idiom FROM idioms")
    return set(row[0] for row in cursor.fetchall())


def import_idioms(conn, idioms):
    """导入成语数据"""
    cursor = conn.cursor()
    existing = get_existing_idioms(conn)

    count = 0
    updated = 0
    for item in idioms:
        if item['idiom'] not in existing:
            try:
                cursor.execute('''
                    INSERT INTO idioms (idiom, pinyin, definition, example, tags)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
                    item['idiom'],
                    item['pinyin'],
                    item['definition'],
                    item.get('example', ''),
                    item.get('tags', '')
                ))
                count += 1
                existing.add(item['idiom'])
            except sqlite3.IntegrityError:
                pass
        else:
            # 更新已有成语
            cursor.execute('''
                UPDATE idioms
                SET pinyin = ?, definition = ?, example = ?, tags = ?
                WHERE idiom = ?
            ''', (
                item['pinyin'],
                item['definition'],
                item.get('example', ''),
                item.get('tags', ''),
                item['idiom']
            ))
            updated += 1

    conn.commit()
    print(f"✓ 导入 {count} 个成语，更新 {updated} 个成语")
    return count, updated


def get_stats(conn):
    """获取统计数据"""
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM idioms")
    total = cursor.fetchone()[0]
    return {'total': total}


def main():
    print("=" * 60)
    print("成语词典导入脚本")
    print("目标：导入 30,000+ 成语词条")
    print("=" * 60)

    conn = create_connection()

    # 创建表
    create_idioms_table(conn)

    print("\n导入前：")
    stats = get_stats(conn)
    print(f"  成语总数：{stats['total']:,}")

    # 导入成语
    import_idioms(conn, IDIOMS)

    print("\n导入后：")
    stats = get_stats(conn)
    print(f"  成语总数：{stats['total']:,}")

    conn.close()
    print("\n" + "=" * 60)
    print("✅ 成语导入完成！")
    print("=" * 60)


if __name__ == "__main__":
    main()
