import { loadIdioms, loadXiehouyu } from './dataLoader';
import type { Idiom, Xiehouyu } from '../types';

export const searchIdioms = async (query: string): Promise<Idiom[]> => {
  if (!query) return [];

  const idioms = await loadIdioms();
  const normalizedQuery = query.toLowerCase().trim();

  const results = idioms.filter((item: any) => {
    return item.word?.includes(query) ||
           item.pinyin?.toLowerCase().includes(normalizedQuery) ||
           item.explanation?.includes(query);
  });

  return results.slice(0, 30).map((item: any) => ({
    word: item.word || '',
    pinyin: item.pinyin || '',
    explanation: item.explanation || '',
    derivation: item.derivation,
    example: item.example
  }));
};

export const searchXiehouyu = async (query: string): Promise<Xiehouyu[]> => {
  if (!query) return [];

  const xiehouyuList = await loadXiehouyu();

  const results = xiehouyuList.filter((item: any) => {
    return item.riddle?.includes(query) || item.answer?.includes(query);
  });

  return results.slice(0, 30).map((item: any) => ({
    riddle: item.riddle || '',
    answer: item.answer || ''
  }));
};
