import localforage from 'localforage';
import type { SearchHistory, Favorite } from '../types';

const HISTORY_KEY = 'search_history';
const FAVORITES_KEY = 'favorites';

export const addToHistory = async (character: string): Promise<void> => {
  try {
    const history = await getHistory();
    const newHistory: SearchHistory = {
      character,
      timestamp: Date.now()
    };
    
    // Remove existing entry if it exists
    const filteredHistory = history.filter(item => item.character !== character);
    
    // Add new entry to the beginning
    const updatedHistory = [newHistory, ...filteredHistory].slice(0, 10); // Keep only last 10 entries
    
    await localforage.setItem(HISTORY_KEY, updatedHistory);
  } catch (error) {
    console.error('Error adding to history:', error);
  }
};

export const getHistory = async (): Promise<SearchHistory[]> => {
  try {
    const history = await localforage.getItem<SearchHistory[]>(HISTORY_KEY);
    return history || [];
  } catch (error) {
    console.error('Error getting history:', error);
    return [];
  }
};

export const clearHistory = async (): Promise<void> => {
  try {
    await localforage.removeItem(HISTORY_KEY);
  } catch (error) {
    console.error('Error clearing history:', error);
  }
};

export const addToFavorites = async (character: string, category: string = 'default'): Promise<void> => {
  try {
    const favorites = await getFavorites();
    const newFavorite: Favorite = {
      character,
      category,
      timestamp: Date.now()
    };
    
    // Remove existing entry if it exists
    const filteredFavorites = favorites.filter(item => item.character !== character);
    
    // Add new entry
    const updatedFavorites = [...filteredFavorites, newFavorite];
    
    await localforage.setItem(FAVORITES_KEY, updatedFavorites);
  } catch (error) {
    console.error('Error adding to favorites:', error);
  }
};

export const removeFromFavorites = async (character: string): Promise<void> => {
  try {
    const favorites = await getFavorites();
    const filteredFavorites = favorites.filter(item => item.character !== character);
    await localforage.setItem(FAVORITES_KEY, filteredFavorites);
  } catch (error) {
    console.error('Error removing from favorites:', error);
  }
};

export const getFavorites = async (): Promise<Favorite[]> => {
  try {
    const favorites = await localforage.getItem<Favorite[]>(FAVORITES_KEY);
    return favorites || [];
  } catch (error) {
    console.error('Error getting favorites:', error);
    return [];
  }
};

export const isFavorite = async (character: string): Promise<boolean> => {
  try {
    const favorites = await getFavorites();
    return favorites.some(item => item.character === character);
  } catch (error) {
    console.error('Error checking favorite:', error);
    return false;
  }
};
