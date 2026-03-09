import React, { useState, useEffect } from 'react';
import type { SearchHistory } from '../types';
import { getHistory, clearHistory } from '../utils/storage';
import { searchByCharacter } from '../utils/search';

interface HistoryProps {
  onSelectCharacter: (character: any) => void;
}

const History: React.FC<HistoryProps> = ({ onSelectCharacter }) => {
  const [history, setHistory] = useState<SearchHistory[]>([]);

  useEffect(() => {
    loadHistory();
  }, []);

  const loadHistory = async () => {
    const historyData = await getHistory();
    setHistory(historyData);
  };

  const handleClearHistory = async () => {
    await clearHistory();
    setHistory([]);
  };

  const handleSelectCharacter = async (char: string) => {
    const character = await searchByCharacter(char);
    if (character) {
      onSelectCharacter(character);
    }
  };

  if (history.length === 0) {
    return <div className="text-center py-4 text-gray-500 dark:text-gray-400">暂无搜索历史</div>;
  }

  return (
    <div className="bg-[#FFFBF0] dark:bg-gray-800 rounded-lg shadow p-4">
      <div className="flex justify-between items-center mb-3">
        <h3 className="text-base font-semibold text-[#3E2723] dark:text-white">搜索历史</h3>
        <button onClick={handleClearHistory} className="text-xs text-gray-500 dark:text-gray-400 hover:text-[#D32F2F]">
          清除
        </button>
      </div>
      <div className="flex flex-wrap gap-2">
        {history.map((item, index) => (
          <span
            key={index}
            className="px-2 py-1 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded text-sm cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-600"
            onClick={() => handleSelectCharacter(item.character)}
          >
            {item.character}
          </span>
        ))}
      </div>
    </div>
  );
};

export default History;
