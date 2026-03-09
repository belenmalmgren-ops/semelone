import React from 'react';
import type { Xiehouyu } from '../types';

interface XiehouyuListProps {
  xiehouyuList: Xiehouyu[];
}

const XiehouyuList: React.FC<XiehouyuListProps> = ({ xiehouyuList }) => {
  if (xiehouyuList.length === 0) {
    return <div className="text-center py-8 text-gray-500 dark:text-gray-400">暂无结果</div>;
  }

  return (
    <div className="space-y-3">
      {xiehouyuList.map((item, index) => (
        <div key={index} className="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
          <p className="text-gray-900 dark:text-white">
            <span className="font-semibold">{item.riddle}</span>
            <span className="text-gray-500 dark:text-gray-400 mx-2">——</span>
            <span className="text-blue-600 dark:text-blue-400">{item.answer}</span>
          </p>
        </div>
      ))}
    </div>
  );
};

export default XiehouyuList;
