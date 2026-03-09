import { useState, Suspense, lazy, useEffect } from 'react';
import SearchBar from './components/SearchBar';
import SearchResults from './components/SearchResults';
import IdiomList from './components/IdiomList';
import XiehouyuList from './components/XiehouyuList';
import type { Character, Idiom, Xiehouyu } from './types';
import { addToHistory } from './utils/storage';

// 懒加载组件
const CharacterDetail = lazy(() => import('./components/CharacterDetail'));
const History = lazy(() => import('./components/History'));
const Favorites = lazy(() => import('./components/Favorites'));

function App() {
  const [searchResults, setSearchResults] = useState<Character[]>([]);
  const [idiomResults, setIdiomResults] = useState<Idiom[]>([]);
  const [xiehouyuResults, setXiehouyuResults] = useState<Xiehouyu[]>([]);
  const [selectedCharacter, setSelectedCharacter] = useState<Character | null>(null);
  const [theme, setTheme] = useState<'light' | 'dark' | 'sepia'>('light');
  const [searchMode, setSearchMode] = useState<'character' | 'idiom' | 'xiehouyu'>('character');

  useEffect(() => {
    // 应用主题
    document.documentElement.classList.remove('dark', 'sepia');
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else if (theme === 'sepia') {
      document.documentElement.classList.add('sepia');
    }
  }, [theme]);

  const handleSearch = (results: Character[]) => {
    setSearchResults(results);
    setIdiomResults([]);
    setXiehouyuResults([]);
    setSelectedCharacter(null);
    setSearchMode('character');
  };

  const handleIdiomSearch = (results: Idiom[]) => {
    setIdiomResults(results);
    setSearchResults([]);
    setXiehouyuResults([]);
    setSelectedCharacter(null);
    setSearchMode('idiom');
  };

  const handleXiehouyuSearch = (results: Xiehouyu[]) => {
    setXiehouyuResults(results);
    setSearchResults([]);
    setIdiomResults([]);
    setSelectedCharacter(null);
    setSearchMode('xiehouyu');
  };

  const handleSelectCharacter = async (character: Character) => {
    setSelectedCharacter(character);
    await addToHistory(character.character);
  };

  return (
    <div className="min-h-screen bg-[#F5F1E8] dark:bg-[#2C2416] transition-colors duration-300">
      {/* AppBar: 米黄色背景+深棕色文字，与Flutter原版一致 */}
      <header className="bg-[#F5F1E8] dark:bg-[#2C2416] border-b border-[#8D6E63]/30 py-4 px-4">
        <div className="max-w-4xl mx-auto flex justify-between items-center">
          <h1 className="text-xl font-medium text-[#3E2723] dark:text-[#E8DCC8]" style={{fontFamily: 'STKaiti, serif'}}>小方新华字典</h1>
          <div className="flex gap-2">
            <button onClick={() => setTheme('light')} className={`px-3 py-1 rounded text-sm ${theme === 'light' ? 'bg-[#D32F2F] text-white' : 'text-[#3E2723] dark:text-[#E8DCC8]'}`}>经典</button>
            <button onClick={() => setTheme('dark')} className={`px-3 py-1 rounded text-sm ${theme === 'dark' ? 'bg-[#FF6B6B] text-white' : 'text-[#3E2723] dark:text-[#E8DCC8]'}`}>深色</button>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 py-6">
        <SearchBar
          onSearch={handleSearch}
          onIdiomSearch={handleIdiomSearch}
          onXiehouyuSearch={handleXiehouyuSearch}
        />

        {!selectedCharacter && searchResults.length === 0 && idiomResults.length === 0 && xiehouyuResults.length === 0 && (
          <div className="flex flex-col items-center justify-center py-16">
            <span className="text-6xl mb-4" style={{color: '#3E2723'}}>���</span>
            <h2 className="text-2xl font-bold text-[#3E2723] dark:text-[#E8DCC8] mb-2" style={{fontFamily: 'STKaiti, serif'}}>小方新华字典</h2>
            <p className="text-[#8D6E63] dark:text-[#E8DCC8]/60">16,142字 · 30,895成语 · 14,032歇后语</p>
          </div>
        )}

        {searchMode === 'character' && !selectedCharacter && searchResults.length > 0 && (
          <SearchResults results={searchResults} onSelectCharacter={handleSelectCharacter} />
        )}

        {searchMode === 'character' && selectedCharacter && (
          <Suspense fallback={<div className="text-center py-16 text-[#3E2723]">加载中...</div>}>
            <CharacterDetail character={selectedCharacter} />
          </Suspense>
        )}

        {searchMode === 'idiom' && <IdiomList idioms={idiomResults} />}
        {searchMode === 'xiehouyu' && <XiehouyuList xiehouyuList={xiehouyuResults} />}

        <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
          <Suspense fallback={<div className="text-center py-4">加载中...</div>}>
            <History onSelectCharacter={handleSelectCharacter} />
          </Suspense>
          <Suspense fallback={<div className="text-center py-4">加载中...</div>}>
            <Favorites onSelectCharacter={handleSelectCharacter} />
          </Suspense>
        </div>
      </div>
    </div>
  );
}

export default App;
