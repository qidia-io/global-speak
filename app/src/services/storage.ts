// Local storage service for translation history

export interface HistoryItem {
  id: string;
  timestamp: number;
  fromLang: string;
  toLang: string;
  sourceText: string;
  translatedText: string;
  ttsAudioRef?: string;
  mode: 'voice' | 'text';
}

const HISTORY_KEY = 'global_translator_history';
const MAX_HISTORY_ITEMS = 100;

// Generate unique ID
const generateId = (): string => {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};

// Get all history items
export const getHistory = (): HistoryItem[] => {
  try {
    const stored = localStorage.getItem(HISTORY_KEY);
    if (!stored) return [];
    return JSON.parse(stored);
  } catch (error) {
    console.error('Failed to load history:', error);
    return [];
  }
};

// Add a new history item
export const addHistoryItem = (
  item: Omit<HistoryItem, 'id' | 'timestamp'>
): HistoryItem => {
  const newItem: HistoryItem = {
    ...item,
    id: generateId(),
    timestamp: Date.now(),
  };
  
  try {
    const history = getHistory();
    const updated = [newItem, ...history].slice(0, MAX_HISTORY_ITEMS);
    localStorage.setItem(HISTORY_KEY, JSON.stringify(updated));
  } catch (error) {
    console.error('Failed to save history item:', error);
  }
  
  return newItem;
};

// Remove a history item
export const removeHistoryItem = (id: string): void => {
  try {
    const history = getHistory();
    const updated = history.filter(item => item.id !== id);
    localStorage.setItem(HISTORY_KEY, JSON.stringify(updated));
  } catch (error) {
    console.error('Failed to remove history item:', error);
  }
};

// Clear all history
export const clearHistory = (): void => {
  try {
    localStorage.removeItem(HISTORY_KEY);
  } catch (error) {
    console.error('Failed to clear history:', error);
  }
};

// Update a history item (e.g., to add TTS audio reference)
export const updateHistoryItem = (
  id: string,
  updates: Partial<HistoryItem>
): void => {
  try {
    const history = getHistory();
    const updated = history.map(item => 
      item.id === id ? { ...item, ...updates } : item
    );
    localStorage.setItem(HISTORY_KEY, JSON.stringify(updated));
  } catch (error) {
    console.error('Failed to update history item:', error);
  }
};

// Get history item by ID
export const getHistoryItem = (id: string): HistoryItem | undefined => {
  const history = getHistory();
  return history.find(item => item.id === id);
};

// Format timestamp
export const formatTimestamp = (timestamp: number): string => {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  
  return date.toLocaleDateString();
};
