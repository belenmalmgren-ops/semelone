import React, { useState, useEffect } from 'react';
import type { Favorite } from '../types';
import { getFavorites } from '../utils/storage';
import { searchByCharacter } from '../utils/search';

interface FavoritesProps {
  onSelectCharacter: (character: any) => void;
}

const Favorites: React.FC<FavoritesProps> = ({ onSelectCharacter }) => {
  const [favorites, setFavorites] = useState<Favorite[]>([]);

  useEffect(() => {
    loadFavorites();
  }, []);

  const loadFavorites = async () => {
    const favoritesData = await getFavorites();
    setFavorites(favoritesData);
  };

  const handleSelectCharacter = async (char: string) => {
    const character = await searchByCharacter(char);
    if (character) {
      onSelectCharacter(character);
    }
  };

  if (favorites.length === 0) {
    return <div className="text-center py-4 text-gray-500 dark:text-gray-400">暂无收藏</div>;
  }

  return (
    <div className="bg-[#FFFBF0] dark:bg-gray-800 rounded-lg shadow p-4">
      <h3 className="text-base font-semibold mb-3 text-[#3E2723] dark:text-white">收藏夹</h3>
      <div className="flex flex-wrap gap-2">
        {favorites.map((item, index) => (
          <span
            key={index}
            className="px-2 py-1 bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 rounded text-sm cursor-pointer hover:bg-yellow-200 dark:hover:bg-yellow-800"
            onClick={() => handleSelectCharacter(item.character)}
          >
            {item.character}
          </span>
        ))}
      </div>
    </div>
  );
};

export default Favorites;
