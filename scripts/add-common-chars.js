import fs from 'fs';

// 常用姓氏（百家姓前50个）
const commonSurnames = ['赵', '钱', '孙', '李', '周', '吴', '郑', '王', '冯', '陈',
  '褚', '卫', '蒋', '沈', '韩', '杨', '朱', '秦', '尤', '许',
  '何', '吕', '施', '张', '孔', '曹', '严', '华', '金', '魏',
  '陶', '姜', '戚', '谢', '邹', '喻', '柏', '水', '窦', '章',
  '云', '苏', '潘', '葛', '奚', '范', '彭', '郎', '鲁', '韦',
  '刘', '林', '黄', '马', '梁'];

// 读取原始数据
const wordData = JSON.parse(fs.readFileSync('/Volumes/E/daima/zidian/chinese-xinhua/data/word.json', 'utf-8'));

// 查找这些姓氏字
const foundChars = [];
for (const surname of commonSurnames) {
  const found = wordData.find(item => item.word === surname);
  if (found) {
    foundChars.push({
      id: String(2000 + foundChars.length + 1),
      character: found.word || '',
      pinyin: found.pinyin ? found.pinyin.split(',').map(p => p.trim()) : [],
      radical: found.radicals || '',
      strokes: parseInt(found.strokes) || 0,
      definition: found.explanation ? [found.explanation.substring(0, 200)] : [],
      phrases: [],
      idioms: [],
      synonyms: [],
      antonyms: [],
      examples: [],
      structure: '',
      etymology: '',
      partOfSpeech: []
    });
  }
}

console.log(`找到 ${foundChars.length} 个常用姓氏字`);
console.log('包含:', foundChars.map(c => c.character).join('、'));

// 读取现有数据
const existingData = fs.readFileSync('/Volumes/E/daima/zidian/zidian/src/data/dictionary.ts', 'utf-8');

// 提取现有的字符数组
const match = existingData.match(/export const dictionary: Character\[\] = (\[[\s\S]*?\]);/);
if (match) {
  const existingChars = JSON.parse(match[1]);

  // 合并数据
  const mergedChars = [...existingChars, ...foundChars];

  // 生成新文件
  const newContent = existingData.replace(
    /export const dictionary: Character\[\] = \[[\s\S]*?\];/,
    `export const dictionary: Character[] = ${JSON.stringify(mergedChars, null, 2)};`
  );

  fs.writeFileSync('/Volumes/E/daima/zidian/zidian/src/data/dictionary.ts', newContent, 'utf-8');
  console.log('常用姓氏字已添加到字典数据中！');
}
