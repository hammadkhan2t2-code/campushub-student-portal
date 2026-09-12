import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import {
  ActiveTab,
  TimetableEntry,
  Room,
  Teacher,
  LostFoundItem,
  ClaimRecord
} from '../types';
import {
  DepartmentRecord,
  ProgramRecord,
  SemesterRecord,
  SectionRecord,
  BatchRecord,
  CourseRecord
} from '../types/supabase';
import {
  fetchDepartments,
  fetchPrograms,
  fetchSemesters,
  fetchSections,
  fetchBatches,
  fetchCourses,
  fetchTeachers,
  fetchRooms,
  fetchTimetableEntries,
  fetchLostFoundItems,
  createLostFoundItem,
  claimLostFoundItem,
  updateLostFoundItemStatus,
  isSupabaseConfigured
} from '../lib/supabaseService';
import { useAuth } from './AuthContext';

export interface ToastMessage {
  id: string;
  type: 'success' | 'info' | 'warning' | 'error';
  title: string;
  message: string;
}

interface AppContextType {
  activeTab: ActiveTab;
  setActiveTab: (tab: ActiveTab) => void;
  
  // Supabase Data (Single source of truth)
  timetable: TimetableEntry[];
  rooms: Room[];
  teachers: Teacher[];
  lostFoundItems: LostFoundItem[];
  departments: DepartmentRecord[];
  programs: ProgramRecord[];
  semesters: SemesterRecord[];
  sections: SectionRecord[];
  batches: BatchRecord[];
  courses: CourseRecord[];

  // Data Loading & Connection States
  isLoadingData: boolean;
  dataError: string | null;
  isDbConnected: boolean;
  refreshData: () => Promise<void>;

  // Modals & Selection
  selectedRoom: Room | null;
  setSelectedRoom: (room: Room | null) => void;
  selectedTeacher: Teacher | null;
  setSelectedTeacher: (teacher: Teacher | null) => void;
  selectedItemForClaim: LostFoundItem | null;
  setSelectedItemForClaim: (item: LostFoundItem | null) => void;

  // Lost & Found Actions
  addLostFoundItem: (item: Omit<LostFoundItem, 'id' | 'reportedAt' | 'status'> & { status?: LostFoundItem['status'] }) => Promise<void>;
  claimItem: (itemId: string, claimData: ClaimRecord) => Promise<void>;
  updateItemStatus: (itemId: string, status: LostFoundItem['status']) => Promise<void>;

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

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { currentUser } = useAuth();

  const [activeTab, setActiveTab] = useState<ActiveTab>('home');
  // Pure empty initial state - NEVER preloaded with local/mock data
  const [timetable, setTimetable] = useState<TimetableEntry[]>([]);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [teachers, setTeachers] = useState<Teacher[]>([]);
  const [lostFoundItems, setLostFoundItems] = useState<LostFoundItem[]>([]);
  const [departments, setDepartments] = useState<DepartmentRecord[]>([]);
  const [programs, setPrograms] = useState<ProgramRecord[]>([]);
  const [semesters, setSemesters] = useState<SemesterRecord[]>([]);
  const [sections, setSections] = useState<SectionRecord[]>([]);
  const [batches, setBatches] = useState<BatchRecord[]>([]);
  const [courses, setCourses] = useState<CourseRecord[]>([]);

  const [isLoadingData, setIsLoadingData] = useState<boolean>(true);
  const [dataError, setDataError] = useState<string | null>(null);
  const [isDbConnected, setIsDbConnected] = useState<boolean>(true);

  const [selectedRoom, setSelectedRoom] = useState<Room | null>(null);
  const [selectedTeacher, setSelectedTeacher] = useState<Teacher | null>(null);
  const [selectedItemForClaim, setSelectedItemForClaim] = useState<LostFoundItem | null>(null);

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const addToast = useCallback((toast: Omit<ToastMessage, 'id'>) => {
    const id = 'toast-' + Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { ...toast, id }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4500);
  }, []);

  const removeToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  /**
   * Load all datasets directly from Supabase tables:
   * departments, programs, semesters, sections, batches, courses, teachers, rooms, timetable_entries, lost_and_found.
   *
   * Supabase is strictly the single source of truth:
   * - Supabase available → use Supabase data.
   * - Supabase unavailable → show database connection error / empty state.
   * - NEVER substitute local or mock data.
   */
  const loadSupabaseData = useCallback(async () => {
    setIsLoadingData(true);
    setDataError(null);

    // If Supabase credentials are missing, immediately flag database connection error and keep empty state
    if (!isSupabaseConfigured()) {
      setIsDbConnected(false);
      setDataError('Supabase environment variables are not configured. Cannot connect to database.');
      setIsLoadingData(false);
      return;
    }

    try {
      // 1. Fetch metadata in parallel from Supabase tables
      const [
        deptData,
        progData,
        semData,
        secData,
        batchData,
        courseData,
        teacherData,
        roomData,
        lfData
      ] = await Promise.all([
        fetchDepartments(),
        fetchPrograms(),
        fetchSemesters(),
        fetchSections(),
        fetchBatches(),
        fetchCourses(),
        fetchTeachers(),
        fetchRooms(),
        fetchLostFoundItems()
      ]);

      // Set state directly from Supabase responses without any local fallbacks
      setDepartments(deptData);
      setPrograms(progData);
      setSemesters(semData);
      setSections(secData);
      setBatches(batchData);
      setCourses(courseData);
      setTeachers(teacherData);
      setRooms(roomData);
      setLostFoundItems(lfData);

      // 2. Fetch timetable entries from public.timetable_entries
      let timetableResults: TimetableEntry[] = [];
      if (currentUser?.sectionId || currentUser?.section) {
        timetableResults = await fetchTimetableEntries({
          department_id: currentUser.departmentId,
          program_id: currentUser.programId,
          semester_id: currentUser.semesterId,
          section_id: currentUser.sectionId,
          batch_id: currentUser.batchId
        });
      }

      // If no student-specific filtered query returned or for general directory, fetch all timetable entries
      if (timetableResults.length === 0) {
        timetableResults = await fetchTimetableEntries();
      }

      setTimetable(timetableResults);
      setIsDbConnected(true);
    } catch (err: any) {
      console.warn('Error connecting to Supabase:', err);
      setIsDbConnected(false);
      setDataError(err.message || 'Database connection failed. Unable to reach Supabase.');
      // Ensure state remains empty on error
      setDepartments([]);
      setPrograms([]);
      setSemesters([]);
      setSections([]);
      setBatches([]);
      setCourses([]);
      setTeachers([]);
      setRooms([]);
      setTimetable([]);
      setLostFoundItems([]);
      addToast({
        type: 'error',
        title: 'Database Connection Error',
        message: 'Unable to connect to Supabase. Displaying empty state.'
      });
    } finally {
      setIsLoadingData(false);
    }
  }, [currentUser, addToast]);

  // Load data on mount and whenever the active user changes
  useEffect(() => {
    loadSupabaseData();
  }, [loadSupabaseData]);

  // Lost & Found Actions using real Supabase queries
  const addLostFoundItem = async (
    itemData: Omit<LostFoundItem, 'id' | 'reportedAt' | 'status'> & { status?: LostFoundItem['status'] }
  ) => {
    const result = await createLostFoundItem(itemData);
    if (result.success && result.data) {
      setLostFoundItems((prev) => [result.data!, ...prev]);
      addToast({
        type: 'success',
        title: itemData.type === 'lost' ? 'Lost Item Reported' : 'Found Item Reported',
        message: `"${result.data.itemName}" has been saved in the Supabase campus registry.`
      });
    } else {
      addToast({
        type: 'error',
        title: 'Submission Failed',
        message: result.error || 'Failed to save item to Supabase database.'
      });
    }
  };

  const claimItem = async (itemId: string, claimData: ClaimRecord) => {
    const result = await claimLostFoundItem(itemId, claimData);
    if (result.success) {
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
        title: 'Claim Submitted to Supabase',
        message: 'Your ownership declaration was registered in the database. Reporter/security has been notified.'
      });
    } else {
      addToast({
        type: 'error',
        title: 'Claim Failed',
        message: result.error || 'Failed to record claim in Supabase database.'
      });
    }
  };

  const updateItemStatus = async (itemId: string, status: LostFoundItem['status']) => {
    const result = await updateLostFoundItemStatus(itemId, status);
    if (result.success) {
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
    } else {
      addToast({
        type: 'error',
        title: 'Update Failed',
        message: result.error || 'Failed to update item status in Supabase database.'
      });
    }
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
        departments,
        programs,
        semesters,
        sections,
        batches,
        courses,
        isLoadingData,
        dataError,
        isDbConnected,
        refreshData: loadSupabaseData,
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
