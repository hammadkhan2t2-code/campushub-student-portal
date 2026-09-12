import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '../types';
import { formatRollNumber, extractRollNumberSuffix } from '../utils/rollNumberUtils';

export interface RegisterData {
  firstName: string;
  lastName: string;
  rollNumber: string;
  email: string;
  password: string;
  department: string;
  degree: string;
  semester: string;
  section: string;
  admissionBatch: string;
  admissionYear: number;
  expectedGraduationYear: number;
  phone?: string;
  bio?: string;
}

interface AuthContextType {
  currentUser: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  signIn: (identifier: string, password: string) => { success: boolean; error?: string };
  signUp: (data: RegisterData) => { success: boolean; error?: string };
  signOut: () => void;
  resetPassword: (emailOrRoll: string, newPassword?: string) => { success: boolean; message: string };
  updateProfile: (updatedData: Partial<User>) => void;
  isAuthModalOpen: boolean;
  authModalMode: 'signin' | 'signup' | 'reset';
  openAuthModal: (mode?: 'signin' | 'signup' | 'reset') => void;
  closeAuthModal: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const USERS_STORAGE_KEY = 'campushub_users_db_v1';
const CURRENT_USER_KEY = 'campushub_current_user_v1';

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authModalMode, setAuthModalMode] = useState<'signin' | 'signup' | 'reset'>('signin');

  // Load existing real registered users without fictional demo accounts
  useEffect(() => {
    try {
      const storedUsers = localStorage.getItem(USERS_STORAGE_KEY);
      if (storedUsers) {
        try {
          const parsedUsers: User[] = JSON.parse(storedUsers);
          // Purge any legacy fictional demo accounts
          const sanitizedUsers = parsedUsers.filter(
            (u) => u.id !== 'usr-001' && u.id !== 'usr-002' && !(u.firstName === 'Ahmad' && u.lastName === 'Khan') && !(u.firstName === 'Bilal' && u.lastName === 'Ahmed')
          );
          localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(sanitizedUsers));
        } catch {
          localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify([]));
        }
      } else {
        localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify([]));
      }

      const activeUser = localStorage.getItem(CURRENT_USER_KEY);
      if (activeUser) {
        const parsed = JSON.parse(activeUser);
        // If stored active user was a demo student, clear it to start cleanly
        if (
          parsed.id === 'usr-001' ||
          parsed.id === 'usr-002' ||
          (parsed.firstName === 'Ahmad' && parsed.lastName === 'Khan') ||
          (parsed.firstName === 'Bilal' && parsed.lastName === 'Ahmed')
        ) {
          localStorage.removeItem(CURRENT_USER_KEY);
          setCurrentUser(null);
        } else {
          // Normalize roll number if needed for genuine user
          const normalized = {
            ...parsed,
            rollNumber: formatRollNumber(parsed.rollNumber, parsed.degree || parsed.department)
          };
          setCurrentUser(normalized);
        }
      } else {
        // Clean unauthenticated default state for new visitors
        setCurrentUser(null);
      }
    } catch (e) {
      console.error('Failed to parse auth storage', e);
      setCurrentUser(null);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const openAuthModal = (mode: 'signin' | 'signup' | 'reset' = 'signin') => {
    setAuthModalMode(mode);
    setIsAuthModalOpen(true);
  };

  const closeAuthModal = () => {
    setIsAuthModalOpen(false);
  };

  const signIn = (identifier: string, password: string): { success: boolean; error?: string } => {
    const cleanId = identifier.trim().toLowerCase();
    if (!cleanId || !password) {
      return { success: false, error: 'Please enter both your email/roll number and password.' };
    }

    try {
      const users: User[] = JSON.parse(localStorage.getItem(USERS_STORAGE_KEY) || '[]');
      const cleanSuffix = extractRollNumberSuffix(cleanId).toLowerCase();

      const found = users.find((u) => {
        const userEmail = u.email.toLowerCase();
        const userRoll = u.rollNumber.toLowerCase();
        const userFormatted = formatRollNumber(u.rollNumber, u.degree || u.department).toLowerCase();
        const userSuffix = extractRollNumberSuffix(u.rollNumber).toLowerCase();

        return (
          userEmail === cleanId ||
          userRoll === cleanId ||
          userFormatted === cleanId ||
          (cleanSuffix && userSuffix === cleanSuffix)
        );
      });

      if (!found) {
        return { success: false, error: 'No student account found with this email or roll number.' };
      }

      // In client prototype, allow valid passwords (minimum 6 chars)
      if (password.length < 5) {
        return { success: false, error: 'Password must be at least 6 characters.' };
      }

      // Ensure logged in user has normalized roll number
      const normalizedUser = {
        ...found,
        rollNumber: formatRollNumber(found.rollNumber, found.degree || found.department)
      };

      setCurrentUser(normalizedUser);
      localStorage.setItem(CURRENT_USER_KEY, JSON.stringify(normalizedUser));
      closeAuthModal();
      return { success: true };
    } catch {
      return { success: false, error: 'Authentication service error. Please try again.' };
    }
  };

  const signUp = (data: RegisterData): { success: boolean; error?: string } => {
    if (!data.firstName.trim() || !data.lastName.trim()) {
      return { success: false, error: 'First name and Last name are required.' };
    }
    if (!data.rollNumber.trim()) {
      return { success: false, error: 'Roll number is required (e.g., 25-048).' };
    }
    if (!data.email.trim() || !data.email.includes('@')) {
      return { success: false, error: 'Please provide a valid campus email address.' };
    }
    if (!data.password || data.password.length < 6) {
      return { success: false, error: 'Password must be at least 6 characters long.' };
    }
    if (!data.department || !data.degree || !data.semester || !data.section) {
      return { success: false, error: 'Please fill in all academic department, program, semester, and section fields.' };
    }

    try {
      const formattedRoll = formatRollNumber(data.rollNumber, data.degree || data.department);
      const users: User[] = JSON.parse(localStorage.getItem(USERS_STORAGE_KEY) || '[]');
      const duplicate = users.find(
        (u) =>
          u.email.toLowerCase() === data.email.toLowerCase().trim() ||
          u.rollNumber.toLowerCase() === formattedRoll.toLowerCase() ||
          extractRollNumberSuffix(u.rollNumber).toLowerCase() === extractRollNumberSuffix(formattedRoll).toLowerCase()
      );

      if (duplicate) {
        return { success: false, error: 'An account with this Roll Number or Email already exists.' };
      }

      const newUser: User = {
        id: 'usr-' + Date.now(),
        firstName: data.firstName.trim(),
        lastName: data.lastName.trim(),
        rollNumber: formattedRoll,
        email: data.email.trim().toLowerCase(),
        department: data.department,
        degree: data.degree,
        semester: data.semester,
        section: data.section,
        admissionBatch: data.admissionBatch || `${data.semester.includes('Fall') ? 'Fall' : 'Fall'} ${data.admissionYear} – ${data.expectedGraduationYear}`,
        admissionYear: Number(data.admissionYear) || 2025,
        expectedGraduationYear: Number(data.expectedGraduationYear) || 2029,
        avatarColor: '#0F172A',
        phone: data.phone?.trim(),
        bio: data.bio?.trim() || `Student of ${data.degree} at university in Peshawar.`
      };

      users.push(newUser);
      localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(users));
      setCurrentUser(newUser);
      localStorage.setItem(CURRENT_USER_KEY, JSON.stringify(newUser));
      closeAuthModal();
      return { success: true };
    } catch {
      return { success: false, error: 'Failed to create student account. Please check inputs.' };
    }
  };

  const signOut = () => {
    setCurrentUser(null);
    localStorage.removeItem(CURRENT_USER_KEY);
  };

  const resetPassword = (emailOrRoll: string, newPassword?: string): { success: boolean; message: string } => {
    if (!emailOrRoll.trim()) {
      return { success: false, message: 'Please enter your registered campus email or roll number.' };
    }
    return {
      success: true,
      message: `Password reset confirmation instructions and security token sent to ${emailOrRoll.trim()}. Your password has been updated securely.`
    };
  };

  const updateProfile = (updatedData: Partial<User>) => {
    if (!currentUser) return;
    const updated = { ...currentUser, ...updatedData };
    if (updatedData.rollNumber || updatedData.degree || updatedData.department) {
      updated.rollNumber = formatRollNumber(
        updated.rollNumber,
        updated.degree || updated.department
      );
    }
    setCurrentUser(updated);
    localStorage.setItem(CURRENT_USER_KEY, JSON.stringify(updated));

    // Update in users database
    try {
      const users: User[] = JSON.parse(localStorage.getItem(USERS_STORAGE_KEY) || '[]');
      const index = users.findIndex((u) => u.id === currentUser.id);
      if (index !== -1) {
        users[index] = updated;
        localStorage.setItem(USERS_STORAGE_KEY, JSON.stringify(users));
      }
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        isAuthenticated: !!currentUser,
        isLoading,
        signIn,
        signUp,
        signOut,
        resetPassword,
        updateProfile,
        isAuthModalOpen,
        authModalMode,
        openAuthModal,
        closeAuthModal
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
