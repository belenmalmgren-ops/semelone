import React, { useState, useEffect, useRef } from 'react';
import type { Character } from '../types';
import { addToFavorites, removeFromFavorites, isFavorite } from '../utils/storage';
import HanziWriter from 'hanzi-writer';

interface CharacterDetailProps {
  character: Character | null;
}

const CharacterDetail: React.FC<CharacterDetailProps> = ({ character }) => {
  const [isFav, setIsFav] = useState(false);
  const [hasStrokeData, setHasStrokeData] = useState(true);
  const writerRef = useRef<HTMLDivElement>(null);
  const writerInstance = useRef<any>(null);

  useEffect(() => {
    if (character) {
      checkFavoriteStatus();
      initStrokeAnimation();
    }
    return () => {
      if (writerInstance.current) {
        writerInstance.current = null;
      }
    };
  }, [character]);

  const initStrokeAnimation = () => {
    if (writerRef.current && character) {
      writerRef.current.innerHTML = '';
      try {
        writerInstance.current = HanziWriter.create(writerRef.current, character.character, {
          width: 200,
          height: 200,
          padding: 5,
          showOutline: true,
          strokeAnimationSpeed: 1,
          delayBetweenStrokes: 200,
          onLoadCharDataError: () => {
            setHasStrokeData(false);
          }
        });
        setHasStrokeData(true);
      } catch (error) {
        console.error('笔顺动画初始化失败:', error);
        setHasStrokeData(false);
      }
    }
  };

  const handleAnimate = () => {
    if (writerInstance.current) {
      writerInstance.current.animateCharacter();
    }
  };

  const handleQuiz = () => {
    if (writerInstance.current) {
      writerInstance.current.quiz();
    }
  };

  const checkFavoriteStatus = async () => {
    if (character) {
      const status = await isFavorite(character.character);
      setIsFav(status);
    }
  };

  const handleFavoriteToggle = async () => {
    if (character) {
      if (isFav) {
        await removeFromFavorites(character.character);
      } else {
        await addToFavorites(character.character);
      }
      setIsFav(!isFav);
    }
  };

  if (!character) {
    return <div className="text-center py-16 text-gray-500 dark:text-gray-400">请选择一个汉字查看详情</div>;
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 transition-colors">
      <div className="flex justify-between items-start mb-6">
        <div>
          <h2 className="text-4xl font-bold mb-2 text-gray-900 dark:text-white">{character.character}</h2>
          <p className="text-xl text-gray-600 dark:text-gray-300">{character.pinyin.join(', ')}</p>
        </div>
        <button
          onClick={handleFavoriteToggle}
          className={`p-2 rounded-full transition-colors ${isFav ? 'bg-yellow-400 text-white' : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-white'}`}
        >
          {isFav ? '★' : '☆'}
        </button>
      </div>

      <div className="mb-6">
        <h3 className="text-lg font-semibold mb-3 text-gray-900 dark:text-white">笔顺动画</h3>
        <div className="flex flex-col items-center bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
          <div ref={writerRef} className="mb-4"></div>
          {hasStrokeData ? (
            <div className="flex gap-3">
              <button
                onClick={handleAnimate}
                className="px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-md transition-colors"
              >
                演示笔顺
              </button>
              <button
                onClick={handleQuiz}
                className="px-4 py-2 bg-green-500 hover:bg-green-600 text-white rounded-md transition-colors"
              >
                练习书写
              </button>
            </div>
          ) : (
            <p className="text-gray-500 dark:text-gray-400 text-sm">
              该汉字暂无笔顺数据（生僻字或繁体字可能缺少笔顺信息）
            </p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">基本信息</h3>
          <ul className="space-y-2">
            <li className="text-gray-700 dark:text-gray-300"><strong>部首：</strong>{character.radical}</li>
            <li className="text-gray-700 dark:text-gray-300"><strong>笔画：</strong>{character.strokes}画</li>
            <li className="text-gray-700 dark:text-gray-300"><strong>结构：</strong>{character.structure}</li>
            <li className="text-gray-700 dark:text-gray-300"><strong>造字原理：</strong>{character.etymology}</li>
            <li className="text-gray-700 dark:text-gray-300"><strong>词性：</strong>{character.partOfSpeech.join('、')}</li>
          </ul>
        </div>

        <div>
          <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">释义</h3>
          <ul className="space-y-2">
            {character.definition.map((def, index) => (
              <li key={index} className="text-gray-700 dark:text-gray-300">{index + 1}. {def}</li>
            ))}
          </ul>
        </div>
      </div>

      <div className="mt-6">
        <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">常用组词</h3>
        <div className="flex flex-wrap gap-2">
          {character.phrases.map((phrase, index) => (
            <span key={index} className="px-3 py-1 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-full text-sm transition-colors">
              {phrase}
            </span>
          ))}
        </div>
      </div>

      <div className="mt-6">
        <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">相关成语</h3>
        <div className="flex flex-wrap gap-2">
          {character.idioms.map((idiom, index) => (
            <span key={index} className="px-3 py-1 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full text-sm transition-colors">
              {idiom}
            </span>
          ))}
        </div>
      </div>

      <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">近义词</h3>
          <div className="flex flex-wrap gap-2">
            {character.synonyms.length > 0 ? (
              character.synonyms.map((synonym, index) => (
                <span key={index} className="px-3 py-1 bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded-full text-sm transition-colors">
                  {synonym}
                </span>
              ))
            ) : (
              <span className="text-gray-500 dark:text-gray-400">暂无近义词</span>
            )}
          </div>
        </div>

        <div>
          <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">反义词</h3>
          <div className="flex flex-wrap gap-2">
            {character.antonyms.length > 0 ? (
              character.antonyms.map((antonym, index) => (
                <span key={index} className="px-3 py-1 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-full text-sm transition-colors">
                  {antonym}
                </span>
              ))
            ) : (
              <span className="text-gray-500 dark:text-gray-400">暂无反义词</span>
            )}
          </div>
        </div>
      </div>

      <div className="mt-6">
        <h3 className="text-lg font-semibold mb-2 text-gray-900 dark:text-white">典型例句</h3>
        <ul className="space-y-4">
          {character.examples.map((example, index) => (
            <li key={index} className="p-3 bg-gray-50 dark:bg-gray-700 rounded-md transition-colors">
              <p className="mb-1 text-gray-800 dark:text-gray-200">{example.sentence}</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">{example.source}</p>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default CharacterDetail;
