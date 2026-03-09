// 去除拼音声调符号，转为纯字母
export const removeToneMarks = (pinyin: string): string => {
  const toneMap: { [key: string]: string } = {
    'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a', 'ɑ': 'a',
    'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
    'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
    'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
    'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
    'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
    'ń': 'n', 'ň': 'n', 'ǹ': 'n',
    'ɡ': 'g', 'ŋ': 'ng'
  };

  return pinyin.split('').map(char => toneMap[char] || char).join('').toLowerCase();
};
