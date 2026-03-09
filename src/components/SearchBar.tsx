import React, { useState } from 'react';
import type { SearchMode } from '../types';
import { searchByPinyin, searchByRadical, searchByStroke } from '../utils/search';
import { searchIdioms, searchXiehouyu } from '../utils/idiomSearch';
import type { Character, Idiom, Xiehouyu } from '../types';

interface SearchBarProps {
  onSearch: (results: Character[]) => void;
  onIdiomSearch: (results: Idiom[]) => void;
  onXiehouyuSearch: (results: Xiehouyu[]) => void;
}

const SearchBar: React.FC<SearchBarProps> = ({ onSearch, onIdiomSearch, onXiehouyuSearch }) => {
  const [searchMode, setSearchMode] = useState<SearchMode>('pinyin');
  const [searchQuery, setSearchQuery] = useState('');
  const [strokeCount, setStrokeCount] = useState(0);
  const [selectedRadical, setSelectedRadical] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [showSearchInput, setShowSearchInput] = useState(false);

  const handleSearch = async () => {
    setIsLoading(true);
    try {
      if (searchMode === 'idiom') {
        const results = await searchIdioms(searchQuery);
        onIdiomSearch(results);
      } else if (searchMode === 'xiehouyu') {
        const results = await searchXiehouyu(searchQuery);
        onXiehouyuSearch(results);
      } else {
        let results: Character[] = [];
        switch (searchMode) {
          case 'pinyin':
            results = await searchByPinyin(searchQuery);
            break;
          case 'radical':
            results = await searchByRadical(selectedRadical, strokeCount || undefined);
            break;
          case 'stroke':
            results = await searchByStroke(strokeCount);
            break;
        }
        onSearch(results);
      }
    } catch (error) {
      console.error('搜索失败:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleModeClick = (mode: SearchMode) => {
    setSearchMode(mode);
    setShowSearchInput(true);
  };

  return (
    <div className="mb-6">
      {/* 搜索输入框 */}
      <div className="mb-4">
        <input
          type="text"
          placeholder="输入拼音、汉字或部首..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
          className="w-full px-4 py-3 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#3E2723] dark:text-white"
        />
      </div>

      {/* 四个检索按钮 - 原版：深棕色#3E2723底色+白色图标 */}
      <div className="grid grid-cols-4 gap-3 mb-4">
        {([
          { mode: 'pinyin', label: '拼音', icon: '⌨️' },
          { mode: 'radical', label: '部首', icon: '⊞' },
          { mode: 'stroke', label: '笔画', icon: '✏️' },
          { mode: 'idiom', label: '成语', icon: '📚' },
        ] as const).map(({ mode, label, icon }) => (
          <button key={mode} onClick={() => handleModeClick(mode)} className="flex flex-col items-center gap-1">
            <div className={`w-14 h-14 rounded-xl flex items-center justify-center text-2xl transition-colors ${
              searchMode === mode ? 'bg-[#D32F2F]' : 'bg-[#3E2723] dark:bg-[#3E2723]'
            } text-white`}>
              {icon}
            </div>
            <span className="text-xs text-[#3E2723] dark:text-[#E8DCC8]">{label}</span>
          </button>
        ))}
      </div>

      {/* 搜索选项 */}
      {showSearchInput && (
        <div className="bg-[#FFFBF0] dark:bg-[#2C2416] rounded-lg p-4 border border-[#8D6E63]/30">
          {searchMode === 'radical' && (
            <div className="flex gap-2">
              <select value={selectedRadical} onChange={(e) => setSelectedRadical(e.target.value)} className="flex-1 px-3 py-2 border border-[#8D6E63]/40 bg-white dark:bg-[#3E2723]/30 text-[#3E2723] dark:text-[#E8DCC8] rounded-md">
                <option value="">选择部首</option>
                <option value="亻">亻</option>
                <option value="女">���</option>
                <option value="子">子</option>
                <option value="丨">丨</option>
                <option value="囗">囗</option>
              </select>
              <input type="number" placeholder="笔画数" value={strokeCount || ''} onChange={(e) => setStrokeCount(Number(e.target.value))} className="w-24 px-3 py-2 border border-[#8D6E63]/40 bg-white dark:bg-[#3E2723]/30 text-[#3E2723] dark:text-[#E8DCC8] rounded-md" />
              <button onClick={handleSearch} disabled={isLoading} className="px-4 py-2 bg-[#D32F2F] text-white rounded-md hover:bg-[#B71C1C]">
                {isLoading ? '...' : '搜索'}
              </button>
            </div>
          )}
          {searchMode === 'stroke' && (
            <div className="flex gap-2">
              <input type="number" placeholder="输入笔画数" value={strokeCount || ''} onChange={(e) => setStrokeCount(Number(e.target.value))} className="flex-1 px-3 py-2 border border-[#8D6E63]/40 bg-white dark:bg-[#3E2723]/30 text-[#3E2723] dark:text-[#E8DCC8] rounded-md" />
              <button onClick={handleSearch} disabled={isLoading} className="px-4 py-2 bg-[#D32F2F] text-white rounded-md hover:bg-[#B71C1C]">
                {isLoading ? '...' : '搜索'}
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default SearchBar;
