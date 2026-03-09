import React from 'react';
import type { Idiom } from '../types';

interface IdiomListProps {
  idioms: Idiom[];
}

const IdiomList: React.FC<IdiomListProps> = ({ idioms }) => {
  if (idioms.length === 0) {
    return <div className="text-center py-8 text-gray-500 dark:text-gray-400">暂无结果</div>;
  }

  return (
    <div className="space-y-4">
      {idioms.map((idiom, index) => (
        <div key={index} className="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
          <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
            {idiom.word}
            <span className="text-sm text-gray-500 dark:text-gray-400 ml-2">({idiom.pinyin})</span>
          </h3>
          <p className="text-gray-700 dark:text-gray-300">{idiom.explanation}</p>
          {idiom.derivation && (
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
              <strong>出处：</strong>{idiom.derivation}
            </p>
          )}
          {idiom.example && (
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
              <strong>例句：</strong>{idiom.example}
            </p>
          )}
        </div>
      ))}
    </div>
  );
};

export default IdiomList;
