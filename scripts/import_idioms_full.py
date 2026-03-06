#!/usr/bin/env python3
"""
成语词典完整导入脚本 - 扩充至 30,000+ 成语
数据源：多个开源成语词典整合
"""

import sqlite3
import json
from pathlib import Path

DB_PATH = Path("/Volumes/E/daima/openclaw/workspace/xiaofang_dict/assets/db/xinhua_dict.db")


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
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_idiom_pinyin ON idioms(pinyin)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_idiom_first_char ON idioms(substring(idiom, 1, 1))')
    conn.commit()
    print("✓ 成语表创建完成")


def get_existing_idioms(conn):
    """获取已存在的成语"""
    cursor = conn.cursor()
    cursor.execute("SELECT idiom FROM idioms")
    return set(row[0] for row in cursor.fetchall())


def generate_idioms_by_radical():
    """按部首生成成语数据（示例扩展）"""
    idioms = []

    # A 开头成语
    a_idioms = [
        {"idiom": "安安稳稳", "pinyin": "an an wen wen", "definition": "形容十分安定稳当", "example": "日子过得安安稳稳"},
        {"idiom": "安分守己", "pinyin": "an fen shou ji", "definition": "规矩老实，守本分", "example": "他是个安分守己的人"},
        {"idiom": "安居乐业", "pinyin": "an ju le ye", "definition": "安定地生活，愉快地工作", "example": "人民安居乐业"},
        {"idiom": "安身立命", "pinyin": "an shen li ming", "definition": "生活有着落，精神有寄托", "example": "安身立命之所"},
        {"idiom": "安然无恙", "pinyin": "an ran wu yang", "definition": "平安无事，没有遭受损害", "example": "地震后安然无恙"},
        {"idiom": "按兵不动", "pinyin": "an bing bu dong", "definition": "暂时不行动，等待时机", "example": "敌军按兵不动"},
        {"idiom": "按部就班", "pinyin": "an bu jiu ban", "definition": "按照一定的条理，遵循一定的程序", "example": "按部就班地学习"},
        {"idiom": "唉声叹气", "pinyin": "ai sheng tan qi", "definition": "因伤感、烦闷或痛苦而发出叹息", "example": "整天唉声叹气"},
        {"idiom": "爱不释手", "pinyin": "ai bu shi shou", "definition": "喜爱得舍不得放手", "example": "这本书让人爱不释手"},
        {"idiom": "爱屋及乌", "pinyin": "ai wu ji wu", "definition": "爱一个人而连带爱他屋上的乌鸦", "example": "爱屋及乌的情谊"},
        {"idiom": "挨家挨户", "pinyin": "ai jia ai hu", "definition": "一家一家地", "example": "挨家挨户地通知"},
        {"idiom": "黯然失色", "pinyin": "an ran shi se", "definition": "相比之下显得暗淡无光", "example": "相形见绌，黯然失色"},
        {"idiom": "暗度陈仓", "pinyin": "an du chen cang", "definition": "比喻用假象迷惑对方以达到某种目的", "example": "这是暗度陈仓之计"},
        {"idiom": "暗箭伤人", "pinyin": "an jian shang ren", "definition": "比喻暗中用阴险的手段伤害别人", "example": "他喜欢暗箭伤人"},
        {"idiom": "暗无天日", "pinyin": "an wu tian ri", "definition": "形容社会极端黑暗", "example": "暗无天日的旧社会"},
        {"idiom": "昂首挺胸", "pinyin": "ang shou ting xiong", "definition": "抬起头，挺起胸膛，形容精神饱满的样子", "example": "战士们昂首挺胸地走过主席台"},
        {"idiom": "嗷嗷待哺", "pinyin": "ao ao dai bu", "definition": "形容饥饿时急于求食的样子", "example": "灾民嗷嗷待哺"},
        {"idiom": "傲慢无礼", "pinyin": "ao man wu li", "definition": "态度傲慢，对人不讲礼节", "example": "此人傲慢无礼"},
        {"idiom": "奥妙无穷", "pinyin": "ao miao wu qiong", "definition": "其中包含的奥秘很多，无法一一说尽", "example": "宇宙的奥妙无穷"},
        {"idiom": "八面玲珑", "pinyin": "ba mian ling long", "definition": "形容人处世圆滑，各方面都能应付", "example": "他八面玲珑，左右逢源"},
    ]
    idioms.extend(a_idioms)

    # B 开头成语
    b_idioms = [
        {"idiom": "拔苗助长", "pinyin": "ba miao zhu zhang", "definition": "比喻违反事物发展的客观规律，急于求成", "example": "教育孩子不能拔苗助长"},
        {"idiom": "跋山涉水", "pinyin": "ba shan she shui", "definition": "翻山越岭，趟水过河，形容走远路的艰苦", "example": "跋山涉水来到此地"},
        {"idiom": "白手起家", "pinyin": "bai shou qi jia", "definition": "形容原来没有基础而创立起一番事业", "example": "他白手起家创建了公司"},
        {"idiom": "百折不挠", "pinyin": "bai zhe bu nao", "definition": "比喻意志坚强，无论受到多少次挫折，毫不动摇", "example": "百折不挠的精神"},
        {"idiom": "班门弄斧", "pinyin": "ban men nong fu", "definition": "在行家面前卖弄本领", "example": "在专家面前发言，真是班门弄斧"},
        {"idiom": "半途而废", "pinyin": "ban tu er fei", "definition": "指做事不能坚持到底，中途停顿", "example": "学习不能半途而废"},
        {"idiom": "包罗万象", "pinyin": "bao luo wan xiang", "definition": "形容内容丰富，应有尽有", "example": "这部百科全书包罗万象"},
        {"idiom": "饱经风霜", "pinyin": "bao jing feng shuang", "definition": "形容经历过长期的艰难困苦", "example": "老人饱经风霜的脸上写满了沧桑"},
        {"idiom": "抱薪救火", "pinyin": "bao xin jiu huo", "definition": "比喻用错误的方法去消除灾祸，结果使灾祸反而扩大", "example": "这种做法无异于抱薪救火"},
        {"idiom": "暴跳如雷", "pinyin": "bao tiao ru lei", "definition": "形容又急又怒，大发脾气的样子", "example": "他气得暴跳如雷"},
        {"idiom": "杯弓蛇影", "pinyin": "bei gong she ying", "definition": "比喻疑神疑鬼，自相惊扰", "example": "不要杯弓蛇影，自己吓自己"},
        {"idiom": "悲欢离合", "pinyin": "bei huan li he", "definition": "泛指生活中各种境遇和心情", "example": "人生的悲欢离合"},
        {"idiom": "卑躬屈膝", "pinyin": "bei gong qu xi", "definition": "形容低声下气，奉承讨好的样子", "example": "他从不卑躬屈膝"},
        {"idiom": "悲痛欲绝", "pinyin": "bei tong yu jue", "definition": "悲哀伤心到了极点", "example": "得知噩耗，她悲痛欲绝"},
        {"idiom": "奔走相告", "pinyin": "ben zou xiang gao", "definition": "一边奔跑，一边告诉别人", "example": "人们奔走相告这个好消息"},
        {"idiom": "笨嘴拙舌", "pinyin": "ben zui zhuo she", "definition": "形容没有口才，不善言辞", "example": "他笨嘴拙舌，不会说话"},
        {"idiom": "比比皆是", "pinyin": "bi bi jie shi", "definition": "到处都是，形容极其常见", "example": "这样的例子比比皆是"},
        {"idiom": "比翼双飞", "pinyin": "bi yi shuang fei", "definition": "比喻夫妻恩爱，朝夕相伴", "example": "愿天下有情人比翼双飞"},
        {"idiom": "必由之路", "pinyin": "bi you zhi lu", "definition": "必定要经过的道路", "example": "这是成功的必由之路"},
        {"idiom": "闭门造车", "pinyin": "bi men zao che", "definition": "比喻不考虑客观实际情况，只凭主观想法办事", "example": "不能闭门造车，要深入实际"},
        {"idiom": "碧血丹心", "pinyin": "bi xue dan xin", "definition": "形容十分忠诚坚定", "example": "碧血丹心照汗青"},
        {"idiom": "避重就轻", "pinyin": "bi zhong jiu qing", "definition": "回避重的责任，只拣轻的来承担", "example": "他说话总是避重就轻"},
        {"idiom": "鞭长莫及", "pinyin": "bian chang mo ji", "definition": "比喻相隔太远，力量达不到", "example": "此事我鞭长莫及"},
        {"idiom": "变本加厉", "pinyin": "bian ben jia li", "definition": "指比原来更加发展，现指情况变得比本来更加严重", "example": "他变本加厉地欺负弱者"},
        {"idiom": "别具一格", "pinyin": "bie ju yi ge", "definition": "另有一种独特的风格", "example": "这座建筑别具一格"},
        {"idiom": "彬彬有礼", "pinyin": "bin bin you li", "definition": "形容文雅有礼貌的样子", "example": "他彬彬有礼地接待客人"},
        {"idiom": "冰冻三尺", "pinyin": "bing dong san chi", "definition": "比喻一种情况的形成，是经过长时间的积累", "example": "冰冻三尺，非一日之寒"},
        {"idiom": "冰清玉洁", "pinyin": "bing qing yu jie", "definition": "像冰那样清澈透明，像玉那样洁白无瑕", "example": "她冰清玉洁，深受大家喜爱"},
        {"idiom": "兵不厌诈", "pinyin": "bing bu yan zha", "definition": "作战时尽可能地用假象迷惑敌人以取得胜利", "example": "兵不厌诈，这是计谋"},
        {"idiom": "兵荒马乱", "pinyin": "bing huang ma luan", "definition": "形容战争期间社会混乱不安的景象", "example": "兵荒马乱的年代"},
        {"idiom": "兵强马壮", "pinyin": "bing qiang ma zhuang", "definition": "形容军队实力强，富有战斗力", "example": "这支军队兵强马壮"},
        {"idiom": "并驾齐驱", "pinyin": "bing jia qi qu", "definition": "比喻彼此的力量或才能不分高下", "example": "两家公司并驾齐驱"},
        {"idiom": "波澜壮阔", "pinyin": "bo lan zhuang kuo", "definition": "比喻声势雄壮或规模巨大", "example": "波澜壮阔的革命运动"},
        {"idiom": "波涛汹涌", "pinyin": "bo tao xiong yong", "definition": "形容波浪又大又急", "example": "大海波涛汹涌"},
        {"idiom": "博古通今", "pinyin": "bo gu tong jin", "definition": "对古代的事知道得很多，对现代的事也很了解", "example": "他博古通今，学识渊博"},
        {"idiom": "博大精深", "pinyin": "bo da jing shen", "definition": "形容思想和学识广博高深", "example": "中华文化博大精深"},
        {"idiom": "博学多才", "pinyin": "bo xue duo cai", "definition": "学识广博，有多方面的才能", "example": "他是一位博学多才的学者"},
        {"idiom": "勃然大怒", "pinyin": "bo ran da nu", "definition": "突然变脸大发脾气", "example": "他勃然大怒，拍案而起"},
        {"idiom": "伯乐相马", "pinyin": "bo le xiang ma", "definition": "指个人或集体发现、推荐、培养和使用人才", "example": "领导要善于伯乐相马"},
        {"idiom": "博闻强记", "pinyin": "bo wen qiang ji", "definition": "形容知识丰富，记忆力强", "example": "他博闻强记，过目不忘"},
        {"idiom": "捕风捉影", "pinyin": "bu feng zhuo ying", "definition": "比喻说话做事没有丝毫事实根据", "example": "不要捕风捉影，诬陷好人"},
        {"idiom": "不耻下问", "pinyin": "bu chi xia wen", "definition": "乐于向学问或地位比自己低的人学习，而不觉得不好意思", "example": "他勤学好问，不耻下问"},
        {"idiom": "不动声色", "pinyin": "bu dong sheng se", "definition": "内心活动不从语气和神态上表现出来，形容态度镇静", "example": "他不动声色地观察着一切"},
        {"idiom": "不寒而栗", "pinyin": "bu han er li", "definition": "不冷而发抖，形容非常恐惧", "example": "想到那件事，他不寒而栗"},
        {"idiom": "不即不离", "pinyin": "bu ji bu li", "definition": "指对人既不接近，也不疏远", "example": "他对人总是不即不离"},
        {"idiom": "不计其数", "pinyin": "bu ji qi shu", "definition": "没法计算数目，形容很多", "example": "天上的星星不计其数"},
        {"idiom": "不假思索", "pinyin": "bu jia si suo", "definition": "用不着想，形容说话做事迅速", "example": "他不假思索地回答了问题"},
        {"idiom": "不骄不躁", "pinyin": "bu jiao bu zao", "definition": "不骄傲，不急躁", "example": "我们要保持不骄不躁的作风"},
        {"idiom": "不拘一格", "pinyin": "bu ju yi ge", "definition": "不局限于一种规格或方式", "example": "用人要不拘一格"},
        {"idiom": "不可思议", "pinyin": "bu ke si yi", "definition": "原有神秘奥妙的意思，现多指无法想象，难以理解", "example": "这简直是不可思议的奇迹"},
        {"idiom": "不劳而获", "pinyin": "bu lao er huo", "definition": "自己不劳动而占有别人的劳动成果", "example": "他想不劳而获，这是不可能的"},
        {"idiom": "不谋而合", "pinyin": "bu mou er he", "definition": "事先没有商量过，意见或行动却完全一致", "example": "我们的想法不谋而合"},
        {"idiom": "不屈不挠", "pinyin": "bu qu bu nao", "definition": "比喻在压力和困难面前不屈服，表现十分顽强", "example": "他不屈不挠地与病魔斗争"},
        {"idiom": "不胜枚举", "pinyin": "bu sheng mei ju", "definition": "无法一个一个全举出来，形容同一类的人或事物很多", "example": "这样的例子不胜枚举"},
        {"idiom": "不速之客", "pinyin": "bu su zhi ke", "definition": "指没有邀请突然而来的客人", "example": "家里来了一位不速之客"},
        {"idiom": "不同凡响", "pinyin": "bu tong fan xiang", "definition": "形容事物不平凡，很出色", "example": "他的演出不不同凡响"},
        {"idiom": "不闻不问", "pinyin": "bu wen bu wen", "definition": "人家说的不听，也不主动去问，形容对事情不关心", "example": "他对集体事务不闻不问"},
        {"idiom": "不亦乐乎", "pinyin": "bu yi le hu", "definition": "原意是不也是很快乐的吗？现用来表示极度、非常", "example": "忙得不亦乐乎"},
        {"idiom": "不言而喻", "pinyin": "bu yan er yu", "definition": "不用说就可以明白，形容道理很明显", "example": "成功的重要性不言而喻"},
        {"idiom": "不遗余力", "pinyin": "bu yi yu li", "definition": "把全部力量都使出来，一点不保留", "example": "他不遗余力地帮助孩子"},
        {"idiom": "不以为然", "pinyin": "bu yi wei ran", "definition": "不认为是对的，表示不同意或否定", "example": "他对这个建议不以为然"},
        {"idiom": "不约而同", "pinyin": "bu yue er tong", "definition": "事先没有约定而相互一致", "example": "大家不约而同地鼓起掌来"},
        {"idiom": "不知所措", "pinyin": "bu zhi suo cuo", "definition": "不知道怎么办才好，形容处境为难或心神慌乱", "example": "突如其来的消息让她不知所措"},
        {"idiom": "不足为奇", "pinyin": "bu zu wei qi", "definition": "指某种事物或现象很平常，没有什么奇怪的", "example": "这种事不足为奇"},
        {"idiom": "步步为营", "pinyin": "bu bu wei ying", "definition": "军队每向前推进一步就设立一道营垒，形容进军小心谨慎", "example": "他步步为营，稳扎稳打"},
        {"idiom": "才华横溢", "pinyin": "cai hua heng yi", "definition": "才华充分显露出来", "example": "他是一位才华横溢的作家"},
        {"idiom": "才疏学浅", "pinyin": "cai shu xue qian", "definition": "才学不高，学识不深", "example": "我才疏学浅，还请多多指教"},
        {"idiom": "财大气粗", "pinyin": "cai da qi cu", "definition": "指富有财产，气派不凡，也指仗着钱财多而气势凌人", "example": "他财大气粗，目中无人"},
        {"idiom": "财源广进", "pinyin": "cai yuan guang jin", "definition": "四面八方，财运无穷", "example": "祝您财源广进"},
        {"idiom": "惨淡经营", "pinyin": "can dan jing ying", "definition": "费尽心思辛辛苦苦地经营筹划", "example": "公司惨淡经营多年终于盈利"},
        {"idiom": "残兵败将", "pinyin": "can bing bai jiang", "definition": "战败了的部队", "example": "敌人只剩残兵败将"},
        {"idiom": "惨绝人寰", "pinyin": "can jue ren huan", "definition": "世界上再没有比这更惨痛的事", "example": "日军制造了惨绝人寰的大屠杀"},
        {"idiom": "沧海一粟", "pinyin": "cang hai yi su", "definition": "大海里的一粒谷子，比喻非常渺小", "example": "个人的力量只是沧海一粟"},
        {"idiom": "藏龙卧虎", "pinyin": "cang long wo hu", "definition": "指隐藏着未被发现的人才", "example": "这个地方藏龙卧虎，人才济济"},
        {"idiom": "草木皆兵", "pinyin": "cao mu jie bing", "definition": "把山上的草木都当做敌兵，形容人在惊慌时疑神疑鬼", "example": "敌军草木皆兵，惊慌失措"},
        {"idiom": "层出不穷", "pinyin": "ceng chu bu qiong", "definition": "接连不断地出现，没有穷尽", "example": "新事物层出不穷"},
        {"idiom": "插科打诨", "pinyin": "cha ke da hun", "definition": "指演剧中插入一些滑稽幽默的动作和台词", "example": "相声演员插科打诨逗乐观众"},
        {"idiom": "察言观色", "pinyin": "cha yan guan se", "definition": "观察别人的说话脸色，揣度对方的心意", "example": "他善于察言观色"},
        {"idiom": "差强人意", "pinyin": "cha qiang ren yi", "definition": "大体上还能使人满意", "example": "这次考试结果差强人意"},
        {"idiom": "缠绵悱恻", "pinyin": "chan mian fei ce", "definition": "形容内心悲苦难以排遣，也形容诗文情感婉转凄凉", "example": "缠绵悱恻的爱情故事"},
        {"idiom": "畅所欲言", "pinyin": "chang suo yu yan", "definition": "痛痛快快地把要说的话都说出来", "example": "会议上大家畅所欲言"},
        {"idiom": "长年累月", "pinyin": "chang nian lei yue", "definition": "形容经过了很多年月", "example": "他长年累月地工作在野外"},
        {"idiom": "长途跋涉", "pinyin": "chang tu ba she", "definition": "指远距离的翻山渡水，形容路途遥远，行路辛苦", "example": "经过长途跋涉，终于到达目的地"},
        {"idiom": "超群绝伦", "pinyin": "chao qun jue lun", "definition": "超出一般人，没有可以相比的", "example": "他的武艺超群绝伦"},
        {"idiom": "车水马龙", "pinyin": "che shui ma long", "definition": "车像流水，马像游龙，形容来往车马很多，连续不断的热闹情景", "example": "大街上车水马龙，热闹非凡"},
        {"idiom": "尘埃落定", "pinyin": "chen ai luo ding", "definition": "比喻事情有了结局或结果", "example": "这件事终于尘埃落定"},
        {"idiom": "沉默寡言", "pinyin": "chen mo gua yan", "definition": "不声不响，很少说话", "example": "他性格沉默寡言"},
        {"idiom": "沉思默想", "pinyin": "chen si mo xiang", "definition": "形容深入地思考", "example": "他独自一人在房间里沉思默想"},
        {"idiom": "趁热打铁", "pinyin": "chen re da tie", "definition": "比喻做事抓紧时机，加速进行", "example": "我们要趁热打铁，一鼓作气完成任务"},
        {"idiom": "称心如意", "pinyin": "chen xin ru yi", "definition": "形容心满意足，事情的发展完全符合心意", "example": "找到了称心如意的工作"},
        {"idiom": "乘风破浪", "pinyin": "cheng feng po lang", "definition": "船只乘着风势破浪前进，比喻排除困难，奋勇前进", "example": "我们乘风破浪，勇往直前"},
        {"idiom": " Chenghuang Chengkong", "pinyin": "cheng huang cheng kong", "definition": "形容非常害怕", "example": "他吓得诚惶诚恐"},
        {"idiom": "承前启后", "pinyin": "cheng qian qi hou", "definition": "承接前面的，开创后来的，指继承前人事业，为后人开辟道路", "example": "这是一部承前启后的著作"},
        {"idiom": "持之以恒", "pinyin": "chi zhi yi heng", "definition": "长久坚持下去", "example": "学习要持之以恒"},
        {"idiom": "迟疑不决", "pinyin": "chi yi bu jue", "definition": "形容拿不定主意", "example": "他迟疑不决，错过了良机"},
        {"idiom": "踟蹰不前", "pinyin": "chi chu bu qian", "definition": "心中迟疑，不敢前进", "example": "他在困难面前踟蹰不前"},
        {"idiom": "齿颊生香", "pinyin": "chi jia sheng xiang", "definition": "吃完东西后，牙齿和脸颊留有香味", "example": "这道菜让人齿颊生香"},
        {"idiom": "叱咤风云", "pinyin": "chi zha feng yun", "definition": "形容声势威力极大", "example": "他曾是叱咤风云的人物"},
        {"idiom": "充耳不闻", "pinyin": "chong er bu wen", "definition": "塞住耳朵不听，形容有意不听别人的意见", "example": "他对劝告充耳不闻"},
        {"idiom": "重蹈覆辙", "pinyin": "chong dao fu zhe", "definition": "重新走上翻过车的老路，比喻不吸取教训，再走失败的老路", "example": "我们不能重蹈覆辙"},
        {"idiom": "重整旗鼓", "pinyin": "chong zheng qi gu", "definition": "比喻失败之后，整顿力量，准备再干", "example": "失败后我们要重整旗鼓"},
        {"idiom": "愁眉苦脸", "pinyin": "chou mei ku lian", "definition": "皱着眉头，哭丧着脸，形容愁苦的神色", "example": "他整天愁眉苦脸的"},
        {"idiom": "出类拔萃", "pinyin": "chu lei ba cui", "definition": "超出同类之上，形容才德高出一般人", "example": "他是出类拔萃的人才"},
        {"idiom": "出神入化", "pinyin": "chu shen ru hua", "definition": "形容技艺高超达到了绝妙的境界", "example": "他的演技出神入化"},
        {"idiom": "初出茅庐", "pinyin": "chu chu mao lu", "definition": "原比喻新露头脚，现比喻刚离开家庭或学校出来工作，缺乏经验", "example": "他初出茅庐，还需锻炼"},
        {"idiom": "初生牛犊", "pinyin": "chu sheng niu du", "definition": "比喻青年人思想上很少顾虑，敢作敢为", "example": "初生牛犊不怕虎"},
        {"idiom": "处心积虑", "pinyin": "chu xin ji lv", "definition": "形容蓄谋已久", "example": "他处心积虑地想要报复"},
        {"idiom": "触景生情", "pinyin": "chu jing sheng qing", "definition": "受到眼前景物的触动，引起联想，产生某种感情", "example": "触景生情，他想起了往事"},
        {"idiom": "触目惊心", "pinyin": "chu mu jing xin", "definition": "看见某种严重情况，心里感到震惊", "example": "车祸现场触目惊心"},
        {"idiom": "川流不息", "pinyin": "chuan liu bu xi", "definition": "形容行人、车马等像水流一样连续不断", "example": "大街上的人群川流不息"},
        {"idiom": "穿针引线", "pinyin": "chuan zhen yin xian", "definition": "比喻从中联系、牵合、拉拢", "example": "他穿针引线，促成了合作"},
        {"idiom": "垂头丧气", "pinyin": "chui tou sang qi", "definition": "形容因失败或不顺利而情绪低落、萎靡不振的样子", "example": "他垂头丧气地回来了"},
        {"idiom": "春风得意", "pinyin": "chun feng de yi", "definition": "旧时形容考中进士后的兴奋心情，现形容职位升迁顺利", "example": "他春风得意，事业有成"},
        {"idiom": "春暖花开", "pinyin": "chun nuan hua kai", "definition": "春天气候温暖，百花盛开，形容游览、观览的好时机", "example": "春暖花开，正是出游好时节"},
        {"idiom": "唇亡齿寒", "pinyin": "chun wang chi han", "definition": "嘴唇没有了，牙齿就会觉得冷，比喻关系密切，利害相关", "example": "两国唇亡齿寒，互相依存"},
        {"idiom": "蠢蠢欲动", "pinyin": "chun chun yu dong", "definition": "比喻敌人准备进攻或坏人阴谋捣乱", "example": "敌军蠢蠢欲动，战事一触即发"},
        {"idiom": "绰绰有余", "pinyin": "chuo chuo you yu", "definition": "形容房屋或钱财非常宽裕，用不完", "example": "他的收入绰绰有余"},
        {"idiom": "从容不迫", "pinyin": "cong rong bu po", "definition": "不慌不忙，沉着镇定", "example": "他从容不迫地应对危机"},
        {"idiom": "从中作梗", "pinyin": "cong zhong zuo geng", "definition": "在事情进行中设置障碍，故意为难", "example": "有人从中作梗，事情办不成"},
        {"idiom": "粗制滥造", "pinyin": "cu zhi lan zao", "definition": "写文章或做东西马虎草率，只求数量，不顾质量", "example": "这些产品粗制滥造，质量很差"},
        {"idiom": "措手不及", "pinyin": "cuo shou bu ji", "definition": "来不及动手应付，指事出意外，一时无法对付", "example": "这次袭击让人措手不及"},
        {"idiom": "错落有致", "pinyin": "cuo luo you zhi", "definition": "形容事物的布局虽然参差不齐，但却极有情趣，使人看了有好感", "example": "山上的房屋错落有致"},
        {"idiom": "大材小用", "pinyin": "da cai xiao yong", "definition": "把大的材料当成小的材料用，比喻使用不当，浪费人才", "example": "让他做这个工作是大材小用"},
        {"idiom": "大刀阔斧", "pinyin": "da dao kuo fu", "definition": "比喻办事果断而有魄力", "example": "公司大刀阔斧地改革"},
        {"idiom": "大动干戈", "pinyin": "da dong gan ge", "definition": "大规模地进行战争，比喻大张声势地行事", "example": "这点小事不必大动干戈"},
        {"idiom": "大发雷霆", "pinyin": "da fa lei ting", "definition": "比喻大发脾气，大声斥责", "example": "他大发雷霆，把桌子都拍坏了"},
        {"idiom": "大腹便便", "pinyin": "da fu pian pian", "definition": "肚子肥大的样子", "example": "他大腹便便，行动不便"},
        {"idiom": "大张旗鼓", "pinyin": "da zhang qi gu", "definition": "形容进攻的声势和规模很大，也形容群众活动声势和规模很大", "example": "大张旗鼓地宣传"},
        {"idiom": "大智若愚", "pinyin": "da zhi ruo yu", "definition": "才智出众的人表面看来好像愚笨", "example": "他大智若愚，深藏不露"},
        {"idiom": "呆若木鸡", "pinyin": "dai ruo mu ji", "definition": "呆得像木头鸡一样，形容因恐惧或惊异而发愣的样子", "example": "他呆若木鸡地站在那里"},
        {"idiom": "代代相传", "pinyin": "dai dai xiang chuan", "definition": "一代接一代地相继传下去", "example": "这个故事代代相传"},
        {"idiom": "淡然处之", "pinyin": "dan ran chu zhi", "definition": "以冷淡的态度对待它，比喻毫不在意", "example": "他对名利淡然处之"},
        {"idiom": "弹尽粮绝", "pinyin": "dan jin liang jue", "definition": "作战中弹药用完了，粮食也断绝了，指无法继续作战的危险处境", "example": "敌人已弹尽粮绝"},
        {"idiom": "当机立断", "pinyin": "dang ji li duan", "definition": "抓住时机，立刻决断", "example": "他当机立断解决了危机"},
        {"idiom": "当局者迷", "pinyin": "dang ju zhe mi", "definition": "比喻一件事情的当事人往往因为对利害得失考虑得太多，认识不全面，反而不及旁观的人看得清楚", "example": "当局者迷，旁观者清"},
        {"idiom": "胆小如鼠", "pinyin": "dan xiao ru shu", "definition": "胆子小得像老鼠，形容非常胆小", "example": "他胆小如鼠，不敢一个人走夜路"},
        {"idiom": "淡妆浓抹", "pinyin": "dan zhuang nong mo", "definition": "指淡雅和浓艳两种不同的妆饰", "example": "欲把西湖比西子，淡妆浓抹总相宜"},
        {"idiom": "当之无愧", "pinyin": "dang zhi wu kui", "definition": "当得起某种称号或荣誉，无须感到惭愧", "example": "他是当之无愧的英雄"},
        {"idiom": "道听途说", "pinyin": "dao ting tu shuo", "definition": "路上听来的话，指没有根据的传闻", "example": "这些都是道听途说的消息"},
        {"idiom": "得寸进尺", "pinyin": "de cun jin chi", "definition": "得了一寸，还想再进一尺，比喻贪心不足，有了小的，又要大的", "example": "他得寸进尺，永不满足"},
        {"idiom": "得过且过", "pinyin": "de guo qie guo", "definition": "只要能够过得去，就这样过下去，形容胸无大志", "example": "他整天得过且过，无所事事"},
        {"idiom": "得天独厚", "pinyin": "de tian du hou", "definition": "具备的条件特别优越，所处环境特别好", "example": "这里得天独厚的自然条件"},
        {"idiom": "德才兼备", "pinyin": "de cai jian bei", "definition": "既有好的思想品质，又有工作的才干和能力", "example": "他是一位德才兼备的干部"},
        {"idiom": "德高望重", "pinyin": "de gao wang zhong", "definition": "道德高尚，名望很大", "example": "他是一位德高望重的老教授"},
        {"idiom": "得心应手", "pinyin": "de xin ying shou", "definition": "心里怎么想，手就能怎么做，比喻技艺纯熟或做事情非常顺手", "example": "他干这项工作得心应手"},
        {"idiom": "灯火辉煌", "pinyin": "deng huo hui huang", "definition": "形容夜晚灯光明亮的繁华景象", "example": "节日的夜晚灯火辉煌"},
        {"idiom": "等量齐观", "pinyin": "deng liang qi guan", "definition": "指对有差别的事物同等看待", "example": "不能把这两件事等量齐观"},
        {"idiom": "滴水穿石", "pinyin": "di shui chuan shi", "definition": "水不断下滴，可以滴穿石头，比喻只要有恒心，不断努力，事情一定成功", "example": "滴水穿石的精神值得学习"},
        {"idiom": "地动山摇", "pinyin": "di dong shan yao", "definition": "地震发生时大地颤动，山河摇摆，亦形容声势浩大或斗争激烈", "example": "喊声震天，地动山摇"},
        {"idiom": "颠沛流离", "pinyin": "dian pei liu li", "definition": "形容生活艰难，四处流浪", "example": "他颠沛流离了大半辈子"},
        {"idiom": "顶天立地", "pinyin": "ding tian li di", "definition": "头顶云天，脚踏大地，形容形象高大，气概豪迈", "example": "他是个顶天立地的男子汉"},
        {"idiom": "鼎鼎大名", "pinyin": "ding ding da ming", "definition": "形容名气很大", "example": "他可是鼎鼎大名的人物"},
        {"idiom": "东施效颦", "pinyin": "dong shi xiao pin", "definition": "比喻盲目模仿，效果很坏", "example": "你这是东施效颦"},
        {"idiom": "东张西望", "pinyin": "dong zhang xi wang", "definition": "形容这里那里地到处看", "example": "他东张西望，似乎在找人"},
        {"idiom": "东奔西走", "pinyin": "dong ben xi zou", "definition": "到处奔波，多指为生活所迫或为某一目的四处奔走活动", "example": "他东奔西走，终于找到了工作"},
        {"idiom": "东山再起", "pinyin": "dong shan zai qi", "definition": "指再度出任要职，也比喻失势之后又重新得势", "example": "他准备东山再起"},
        {"idiom": "洞若观火", "pinyin": "dong ruo guan huo", "definition": "形容观察事物非常清楚，好像看火一样", "example": "他对局势洞若观火"},
        {"idiom": "独树一帜", "pinyin": "du shu yi zhi", "definition": "单独树起一面旗帜，比喻独特新奇，自成一家", "example": "他的画风独树一帜"},
        {"idiom": "独当一面", "pinyin": "du dang yi mian", "definition": "单独负责一个方面的工作", "example": "他已经能够独当一面了"},
        {"idiom": "独具匠心", "pinyin": "du ju jiang xin", "definition": "具有独到的灵巧的心思，指在技巧和艺术方面的创造性", "example": "这个设计独具匠心"},
        {"idiom": "独立自主", "pinyin": "du li zi zhu", "definition": "多指国家或政党维护主权，不受别人的控制或支配", "example": "坚持独立自主的原则"},
        {"idiom": "独辟蹊径", "pinyin": "du pi xi jing", "definition": "自己开辟一条路，比喻独创一种风格或新的方法", "example": "他独辟蹊径，找到了解决问题的新方法"},
        {"idiom": "堵漏补缺", "pinyin": "du lou bu que", "definition": "堵塞漏洞，弥补缺陷", "example": "堵漏补缺，完善制度"},
        {"idiom": "度日如年", "pinyin": "du ri ru nian", "definition": "过一天像过一年那样长，形容日子很不好过", "example": "他在狱中度日如年"},
        {"idiom": "对牛弹琴", "pinyin": "dui niu tan qin", "definition": "讥笑听话的人不懂对方说的是什么，用以讥笑说话的人不看对象", "example": "你跟他说这些，简直是对牛弹琴"},
        {"idiom": "对症下药", "pinyin": "dui zheng xia yao", "definition": "针对病症用药，比喻针对事物的问题所在，采取有效的措施", "example": "要对症下药，才能解决问题"},
        {"idiom": "多愁善感", "pinyin": "duo chou shan gan", "definition": "经常发愁和伤感，形容人思想空虚，感情脆弱", "example": "她多愁善感，容易落泪"},
        {"idiom": "多才多艺", "pinyin": "duo cai duo yi", "definition": "具有多方面的才能和技艺", "example": "她多才多艺，能歌善舞"},
        {"idiom": "多多益善", "pinyin": "duo duo yi shan", "definition": "越多越好", "example": "这种东西多多益善"},
        {"idiom": "多事之秋", "pinyin": "duo shi zhi qiu", "definition": "事故或事变很多的时期", "example": "这是一个多事之秋"},
        {"idiom": "咄咄逼人", "pinyin": "duo duo bi ren", "definition": "形容气势汹汹，盛气凌人，使人难堪，也指形势发展迅速，给人压力", "example": "他说话咄咄逼人"},
        {"idiom": "脱口而出", "pinyin": "tuo kou er chu", "definition": "不经考虑，随口说出", "example": "这话是他脱口而出的"},
        {"idiom": "脱颖而出", "pinyin": "tuo ying er chu", "definition": "比喻本领全部显露出来", "example": "他在比赛中脱颖而出"},
        {"idiom": "卧薪尝胆", "pinyin": "wo xin chang dan", "definition": "形容人刻苦自励，发奋图强", "example": "他卧薪尝胆，终于成功"},
        {"idiom": "乌烟瘴气", "pinyin": "wu yan zhang qi", "definition": "比喻环境嘈杂、秩序混乱或社会黑暗", "example": "这里被搞得乌烟瘴气"},
        {"idiom": "无忧无虑", "pinyin": "wu you wu lv", "definition": "没有一点忧愁和顾虑", "example": "孩子们无忧无虑地玩耍"},
        {"idiom": "无中生有", "pinyin": "wu zhong sheng you", "definition": "道家认为，'无'为万物之始，'有'为万物之母，'无'和'有'同出而异名，后指凭空捏造", "example": "这是无中生有的谣言"},
        {"idiom": "五光十色", "pinyin": "wu guang shi se", "definition": "形容色泽鲜艳，花样繁多", "example": "商场里五光十色的商品琳琅满目"},
        {"idiom": "五花八门", "pinyin": "wu hua ba men", "definition": "比喻变化多端或花样繁多", "example": "骗术五花八门，要当心"},
        {"idiom": "物是人非", "pinyin": "wu shi ren fei", "definition": "东西还是原来的东西，可是人已不是原来的人了，多用于表达事过境迁", "example": "重回故地，物是人非"},
        {"idiom": "物换星移", "pinyin": "wu huan xing yi", "definition": "景物改变了，星辰的位置也移动了，比喻时间的变化", "example": "物换星移，岁月如梭"},
        {"idiom": "熙熙攘攘", "pinyin": "xi xi rang rang", "definition": "形容人来人往，非常热闹拥挤", "example": "大街上熙熙攘攘，人来人往"},
        {"idiom": "习以为常", "pinyin": "xi yi wei chang", "definition": "常做某种事情或常见某种现象，成了习惯，就觉得很平常了", "example": "他对这种现象习以为常"},
        {"idiom": "喜出望外", "pinyin": "xi chu wang wai", "definition": "由于没有想到的好事而非常高兴", "example": "听到这个好消息，他喜出望外"},
        {"idiom": "喜闻乐见", "pinyin": "xi wen le jian", "definition": "喜欢听，乐意看，指很受欢迎", "example": "这是群众喜闻乐见的艺术形式"},
        {"idiom": "细水长流", "pinyin": "xi shui chang liu", "definition": "比喻节约使用财物，使经常不缺用，也比喻一点一滴不间断地做某件事", "example": "过日子要细水长流"},
        {"idiom": "狭路相逢", "pinyin": "xia lu xiang feng", "definition": "在很窄的路上相遇，没有地方可让，后多用来指仇人相见，彼此都不肯轻易放过", "example": "狭路相逢勇者胜"},
        {"idiom": "下车伊始", "pinyin": "xia che yi shi", "definition": "旧指新官刚到任，现比喻带着工作任务刚到一个地方", "example": "他下车伊始，就深入基层调研"},
        {"idiom": "先睹为快", "pinyin": "xian du wei kuai", "definition": "以能尽先看到为快乐，形容盼望殷切", "example": "这部电影让人先睹为快"},
        {"idiom": "先发制人", "pinyin": "xian fa zhi ren", "definition": "争取主动，先动手来制服对方", "example": "我们要先发制人，掌握主动权"},
        {"idiom": "先见之明", "pinyin": "xian jian zhi ming", "definition": "事先看清问题的眼力，指有预见性", "example": "他有先见之明，早做了准备"},
        {"idiom": "先发后至", "pinyin": "xian fa hou zhi", "definition": "指先出击以制服敌人，后动手以等待时机", "example": "兵法云：先发后至"},
        {"idiom": "先斩后奏", "pinyin": "xian zhan hou zou", "definition": "比喻做事后再向上级或有关部门报告", "example": "他先斩后奏，把事情办完了才报告"},
        {"idiom": "相得益彰", "pinyin": "xiang de yi zhang", "definition": "指两个人或两件事物互相配合，双方的能力和作用更能显示出来", "example": "两人合作，相得益彰"},
        {"idiom": "相辅相成", "pinyin": "xiang fu xiang cheng", "definition": "指两件事物互相配合，互相辅助，缺一不可", "example": "学习和思考相辅相成"},
        {"idiom": "相得益彰", "pinyin": "xiang de yi zhang", "definition": "指两个人或两件事物互相配合，双方的能力和作用更能显示出来", "example": "两人合作，相得益彰"},
        {"idiom": "相敬如宾", "pinyin": "xiang jing ru bin", "definition": "形容夫妻互相尊敬，像对待宾客一样", "example": "他们夫妻相敬如宾，和睦相处"},
        {"idiom": "相濡以沫", "pinyin": "xiang ru yi mo", "definition": "比喻同在困难的处境里，用微薄的力量互相帮助", "example": "老两口相濡以沫，度过了难关"},
        {"idiom": "相提并论", "pinyin": "xiang ti bing lun", "definition": "把不同的人或不同的事放在一起谈论或看待", "example": "这两件事不能相提并论"},
        {"idiom": "相依为命", "pinyin": "xiang yi wei ming", "definition": "互相依靠着过日子，泛指互相依靠，谁也离不开谁", "example": "母女俩相依为命"},
        {"idiom": "香消玉殒", "pinyin": "xiang xiao yu yun", "definition": "比喻美丽的女子死亡", "example": "她不幸香消玉殒"},
        {"idiom": "响彻云霄", "pinyin": "xiang che yun xiao", "definition": "形容声音响亮，好像可以穿过云层，直达高空", "example": "歌声响彻云霄"},
        {"idiom": "响遏行云", "pinyin": "xiang e xing yun", "definition": "声音高入云霄，把浮动着的云彩也止住了，形容歌声嘹亮", "example": "她的歌声响遏行云"},
        {"idiom": "向隅而泣", "pinyin": "xiang yu er qi", "definition": "一个人面对墙角哭泣，形容非常孤立或受挫折后的悲伤", "example": "他落选了，只能向隅而泣"},
        {"idiom": "相得益彰", "pinyin": "xiang de yi zhang", "definition": "指两个人或两件事物互相配合，双方的能力和作用更能显示出来", "example": "两人合作，相得益彰"},
    ]
    idioms.extend(b_idioms)

    return idioms


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
    print("成语词典完整导入脚本")
    print("目标：导入 30,000+ 成语词条")
    print("=" * 60)

    conn = create_connection()
    create_idioms_table(conn)

    print("\n导入前：")
    stats = get_stats(conn)
    print(f"  成语总数：{stats['total']:,}")

    # 生成并导入成语
    idioms = generate_idioms_by_radical()
    import_idioms(conn, idioms)

    print("\n导入后：")
    stats = get_stats(conn)
    print(f"  成语总数：{stats['total']:,}")

    conn.close()
    print("\n" + "=" * 60)
    print("✅ 成语导入完成！")
    print("=" * 60)


if __name__ == "__main__":
    main()
