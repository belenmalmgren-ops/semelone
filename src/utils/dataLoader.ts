import type { Character } from '../types';

let wordCache: any[] | null = null;
let idiomCache: any[] | null = null;
let xiehouyuCache: any[] | null = null;

export const loadWords = async (): Promise<any[]> => {
  if (wordCache) return wordCache;
  const response = await fetch('/data/word.json');
  wordCache = await response.json();
  return wordCache || [];
};

export const loadIdioms = async (): Promise<any[]> => {
  if (idiomCache) return idiomCache;
  const response = await fetch('/data/idiom.json');
  idiomCache = await response.json();
  return idiomCache || [];
};

export const loadXiehouyu = async (): Promise<any[]> => {
  if (xiehouyuCache) return xiehouyuCache;
  const response = await fetch('/data/xiehouyu.json');
  xiehouyuCache = await response.json();
  return xiehouyuCache || [];
};

export const convertToCharacter = (item: any): Character => {
  const pinyinList = item.pinyin ? item.pinyin.split(',').map((p: string) => p.trim()) : [];

  return {
    id: item.word || '',
    character: item.word || '',
    pinyin: pinyinList,
    radical: item.radicals || '',
    strokes: parseInt(item.strokes) || 0,
    definition: item.explanation ? [item.explanation] : ['暂无释义'],
    phrases: [],
    idioms: [],
    synonyms: [],
    antonyms: [],
    examples: [],
    structure: '',
    etymology: '',
    partOfSpeech: []
  };
};
