export interface Character {
  id: string;
  character: string;
  pinyin: string[];
  radical: string;
  strokes: number;
  definition: string[];
  phrases: string[];
  idioms: string[];
  synonyms: string[];
  antonyms: string[];
  examples: {
    sentence: string;
    source: string;
  }[];
  structure: string;
  etymology: string;
  partOfSpeech: string[];
}

export interface SearchHistory {
  character: string;
  timestamp: number;
}

export interface Favorite {
  character: string;
  category: string;
  timestamp: number;
}

export type SearchMode = 'pinyin' | 'radical' | 'stroke' | 'handwriting' | 'idiom' | 'xiehouyu';

export interface Radical {
  id: string;
  character: string;
  strokes: number;
  characters: string[];
}

export interface Idiom {
  word: string;
  pinyin: string;
  explanation: string;
  derivation?: string;
  example?: string;
}

export interface Xiehouyu {
  riddle: string;
  answer: string;
}