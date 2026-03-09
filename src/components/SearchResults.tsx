import React from 'react';
import type { Character } from '../types';

interface SearchResultsProps {
  results: Character[];
  onSelectCharacter: (character: Character) => void;
}

const SearchResults: React.FC<SearchResultsProps> = ({ results, onSelectCharacter }) => {
  if (results.length === 0) {
    return <div className="text-center py-8 text-gray-500 dark:text-gray-400">没有找到结果</div>;
  }

  return (
    <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-3">
      {results.map((character) => (
        <div
          key={character.id}
          className="flex flex-col items-center p-3 bg-[#FFFBF0] dark:bg-gray-800 rounded-lg hover:shadow-md cursor-pointer transition-all"
          onClick={() => onSelectCharacter(character)}
        >
          <span className="text-3xl font-bold mb-1 text-[#3E2723] dark:text-white">{character.character}</span>
          <span className="text-xs text-gray-600 dark:text-gray-300">{character.pinyin.join(', ')}</span>
        </div>
      ))}
    </div>
  );
};

export default SearchResults;
