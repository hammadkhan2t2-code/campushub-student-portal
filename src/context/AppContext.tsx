import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  ActiveTab,
  TimetableEntry,
  Room,
  Teacher,
  LostFoundItem,
  ClaimRecord
} from '../types';
import {
  TIMETABLE_ENTRIES,
  ROOMS,
  TEACHERS,
  INITIAL_LOST_FOUND
} from '../data/mockData';

export interface ToastMessage {
  id: string;
  type: 'success' | 'info' | 'warning' | 'error';
  title: string;
  message: string;
}

interface AppContextType {
  activeTab: ActiveTab;
  setActiveTab: (tab: ActiveTab) => void;
  timetable: TimetableEntry[];
  rooms: Room[];
  teachers: Teacher[];
  lostFoundItems: LostFoundItem[];
  
  // Modals & Selection
  selectedRoom: Room | null;
  setSelectedRoom: (room: Room | null) => void;
  selectedTeacher: Teacher | null;
  setSelectedTeacher: (teacher: Teacher | null) => void;
  selectedItemForClaim: LostFoundItem | null;
  setSelectedItemForClaim: (item: LostFoundItem | null) => void;
  
  // Lost & Found Actions
  addLostFoundItem: (item: Omit<LostFoundItem, 'id' | 'reportedAt' | 'status'> & { status?: LostFoundItem['status'] }) => void;
  claimItem: (itemId: string, claimData: ClaimRecord) => void;
  updateItemStatus: (itemId: string, status: LostFoundItem['status']) => void;
  
  // Global Search
  isSearchOpen: boolean;
  setIsSearchOpen: (open: boolean) => void;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  
  // Feedback
  toasts: ToastMessage[];
  addToast: (toast: Omit<ToastMessage, 'id'>) => void;
  removeToast: (id: string) => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

const LF_STORAGE_KEY = 'campushub_lostfound_v2';

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [activeTab, setActiveTab] = useState<ActiveTab>('home');
  const [timetable] = useState<TimetableEntry[]>(TIMETABLE_ENTRIES);
  const [rooms] = useState<Room[]>(ROOMS);
  const [teachers] = useState<Teacher[]>(TEACHERS);
  
  const [lostFoundItems, setLostFoundItems] = useState<LostFoundItem[]>(() => {
    try {
      // Clear legacy storage containing demo records
      localStorage.removeItem('campushub_lostfound_v1');
      const stored = localStorage.getItem(LF_STORAGE_KEY);
      if (stored) {
        const parsed: LostFoundItem[] = JSON.parse(stored);
        // Exclude any legacy demo records
        return parsed.filter(
          (item) => !item.id.startsWith('lf-00') && item.itemName !== 'HP Blue Backpack with USB & Notebooks'
        );
      }
    } catch (e) {
      console.error('Failed to parse lost & found storage', e);
    }
    return INITIAL_LOST_FOUND;
  });

  const [selectedRoom, setSelectedRoom] = useState<Room | null>(null);
  const [selectedTeacher, setSelectedTeacher] = useState<Teacher | null>(null);
  const [selectedItemForClaim, setSelectedItemForClaim] = useState<LostFoundItem | null>(null);

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  // Sync lostFoundItems to localStorage
  useEffect(() => {
    try {
      localStorage.setItem(LF_STORAGE_KEY, JSON.stringify(lostFoundItems));
    } catch (e) {
      console.error(e);
    }
  }, [lostFoundItems]);

  const addToast = (toast: Omit<ToastMessage, 'id'>) => {
    const id = 'toast-' + Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { ...toast, id }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4500);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const addLostFoundItem = (itemData: Omit<LostFoundItem, 'id' | 'reportedAt' | 'status'> & { status?: LostFoundItem['status'] }) => {
    const newItem: LostFoundItem = {
      ...itemData,
      id: 'lf-' + Date.now(),
      status: itemData.status || (itemData.type === 'lost' ? 'Lost' : 'Found'),
      reportedAt: new Date().toISOString()
    };

    setLostFoundItems((prev) => [newItem, ...prev]);
    addToast({
      type: 'success',
      title: itemData.type === 'lost' ? 'Lost Item Reported' : 'Found Item Reported',
      message: `"${newItem.itemName}" has been added to the campus lost & found registry.`
    });
  };

  const claimItem = (itemId: string, claimData: ClaimRecord) => {
    setLostFoundItems((prev) =>
      prev.map((item) => {
        if (item.id === itemId) {
          return {
            ...item,
            status: 'Claimed',
            claimRecord: claimData
          };
        }
        return item;
      })
    );
    addToast({
      type: 'success',
      title: 'Claim Submitted Successfully',
      message: 'Your ownership declaration was registered. The reporter/security office has been notified.'
    });
  };

  const updateItemStatus = (itemId: string, status: LostFoundItem['status']) => {
    setLostFoundItems((prev) =>
      prev.map((item) => {
        if (item.id === itemId) {
          return { ...item, status };
        }
        return item;
      })
    );
    addToast({
      type: 'info',
      title: 'Status Updated',
      message: `Item status has been changed to "${status}".`
    });
  };

  return (
    <AppContext.Provider
      value={{
        activeTab,
        setActiveTab,
        timetable,
        rooms,
        teachers,
        lostFoundItems,
        selectedRoom,
        setSelectedRoom,
        selectedTeacher,
        setSelectedTeacher,
        selectedItemForClaim,
        setSelectedItemForClaim,
        addLostFoundItem,
        claimItem,
        updateItemStatus,
        isSearchOpen,
        setIsSearchOpen,
        searchQuery,
        setSearchQuery,
        toasts,
        addToast,
        removeToast
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = (): AppContextType => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
