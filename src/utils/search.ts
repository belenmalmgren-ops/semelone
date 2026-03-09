import type { Character } from '../types';
import { loadWords, convertToCharacter } from './dataLoader';
import { radicals } from '../data/dictionary';
import { removeToneMarks } from './pinyinUtils';

export const searchByPinyin = async (query: string): Promise<Character[]> => {
  if (!query) return [];

  const words = await loadWords();
  const normalizedQuery = removeToneMarks(query.trim());

  const results = words.filter((item: any) => {
    if (!item.pinyin) return false;
    const pinyinNormalized = removeToneMarks(item.pinyin);
    return pinyinNormalized.includes(normalizedQuery);
  });

  return results.slice(0, 50).map(convertToCharacter);
};

export const searchByRadical = async (radical: string, strokeCount?: number): Promise<Character[]> => {
  const words = await loadWords();
  let results = words.filter((item: any) => item.radicals === radical);

  if (strokeCount) {
    results = results.filter((item: any) => parseInt(item.strokes) === strokeCount);
  }

  return results.slice(0, 50).map(convertToCharacter);
};

export const searchByStroke = async (strokeCount: number): Promise<Character[]> => {
  const words = await loadWords();
  const results = words.filter((item: any) => parseInt(item.strokes) === strokeCount);
  return results.slice(0, 50).map(convertToCharacter);
};

export const searchByCharacter = async (char: string): Promise<Character | undefined> => {
  const words = await loadWords();
  const found = words.find((item: any) => item.word === char);
  return found ? convertToCharacter(found) : undefined;
};

export const getRadicalsByStroke = (strokeCount: number) => {
  return radicals.filter((radical: any) => radical.strokes === strokeCount);
};
