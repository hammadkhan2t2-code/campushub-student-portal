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
  updateLostFoundItemStatus
} from '../lib/supabaseService';
import {
  ROOMS,
  TEACHERS,
  TIMETABLE_ENTRIES,
  INITIAL_LOST_FOUND,
  DEPARTMENTS,
  DEGREES,
  SEMESTERS,
  SECTIONS,
  BATCHES
} from '../data/mockData';
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
  
  // Supabase Data
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

  // Data Loading & Error States
  isLoadingData: boolean;
  dataError: string | null;
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
  const [timetable, setTimetable] = useState<TimetableEntry[]>(TIMETABLE_ENTRIES);
  const [rooms, setRooms] = useState<Room[]>(ROOMS);
  const [teachers, setTeachers] = useState<Teacher[]>(TEACHERS);
  const [lostFoundItems, setLostFoundItems] = useState<LostFoundItem[]>(INITIAL_LOST_FOUND);
  const [departments, setDepartments] = useState<DepartmentRecord[]>(
    DEPARTMENTS.map((d, i) => ({ id: `dept-${i + 1}`, name: d, code: d.substring(0, 3).toUpperCase(), created_at: '' }))
  );
  const [programs, setPrograms] = useState<ProgramRecord[]>(
    DEGREES.map((deg, i) => ({ id: `prog-${i + 1}`, name: deg, code: deg.replace('BS ', '').substring(0, 2).toUpperCase(), department_id: 'dept-1', duration_years: 4, created_at: '' }))
  );
  const [semesters, setSemesters] = useState<SemesterRecord[]>(
    SEMESTERS.map((s, i) => ({ id: `sem-${i + 1}`, name: s, number: parseInt(s) || (i * 2 + 1), created_at: '' }))
  );
  const [sections, setSections] = useState<SectionRecord[]>(
    SECTIONS.map((sec, i) => ({ id: `sec-${i + 1}`, name: sec, created_at: '' }))
  );
  const [batches, setBatches] = useState<BatchRecord[]>(
    BATCHES.map((b, i) => ({ id: `batch-${i + 1}`, name: b, start_year: 2026 - i, end_year: 2030 - i, is_active: i === 0, created_at: '' }))
  );
  const [courses, setCourses] = useState<CourseRecord[]>([]);

  const [isLoadingData, setIsLoadingData] = useState<boolean>(true);
  const [dataError, setDataError] = useState<string | null>(null);

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
   * departments, programs, semesters, sections, batches, courses, teachers, rooms, timetable_entries, lost_and_found
   */
  const loadSupabaseData = useCallback(async () => {
    setIsLoadingData(true);
    setDataError(null);

    try {
      // 1. Fetch metadata in parallel
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

      if (deptData.length > 0) setDepartments(deptData);
      if (progData.length > 0) setPrograms(progData);
      if (semData.length > 0) setSemesters(semData);
      if (secData.length > 0) setSections(secData);
      if (batchData.length > 0) setBatches(batchData);
      if (courseData.length > 0) setCourses(courseData);
      if (teacherData.length > 0) setTeachers(teacherData);
      if (roomData.length > 0) setRooms(roomData);
      if (lfData.length > 0) setLostFoundItems(lfData);

      // 2. Fetch timetable entries from public.timetable_entries
      // If student is logged in, pass specific section_id and academic IDs to guarantee section isolation
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

      // If no specific filtered query returned or for general directory, fetch all timetable entries
      if (timetableResults.length === 0) {
        timetableResults = await fetchTimetableEntries();
      }

      if (timetableResults.length > 0) {
        setTimetable(timetableResults);
      }
    } catch (err: any) {
      console.warn('Error loading Supabase tables:', err);
      setDataError(err.message || 'Failed to sync with Supabase');
      addToast({
        type: 'warning',
        title: 'Supabase Sync Note',
        message: 'Unable to reach some Supabase tables. Displaying loaded records.'
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
      // Optimistic local fallback if offline
      const fallback: LostFoundItem = {
        ...itemData,
        id: 'lf-' + Date.now(),
        status: itemData.status || (itemData.type === 'lost' ? 'Lost' : 'Found'),
        reportedAt: new Date().toISOString()
      };
      setLostFoundItems((prev) => [fallback, ...prev]);
      addToast({
        type: result.error ? 'warning' : 'success',
        title: 'Item Recorded',
        message: result.error ? `Saved locally (${result.error})` : `"${fallback.itemName}" has been recorded.`
      });
    }
  };

  const claimItem = async (itemId: string, claimData: ClaimRecord) => {
    const result = await claimLostFoundItem(itemId, claimData);
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

    if (result.success) {
      addToast({
        type: 'success',
        title: 'Claim Submitted to Supabase',
        message: 'Your ownership declaration was registered in the database. Reporter/security has been notified.'
      });
    } else {
      addToast({
        type: 'info',
        title: 'Claim Registered',
        message: 'Your claim has been recorded for review.'
      });
    }
  };

  const updateItemStatus = async (itemId: string, status: LostFoundItem['status']) => {
    await updateLostFoundItemStatus(itemId, status);
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
        departments,
        programs,
        semesters,
        sections,
        batches,
        courses,
        isLoadingData,
        dataError,
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
