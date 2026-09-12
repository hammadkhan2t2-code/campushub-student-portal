import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '../types';
import { supabase } from '../lib/supabase';
import {
  fetchProfileById,
  mapProfileRecordToUser,
  updateSupabaseProfile,
  fetchDepartments,
  fetchPrograms,
  fetchSemesters,
  fetchSections,
  fetchBatches
} from '../lib/supabaseService';
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
  isSubmitting: boolean;
  signIn: (identifier: string, password: string) => Promise<{ success: boolean; error?: string }>;
  signUp: (data: RegisterData) => Promise<{ success: boolean; error?: string }>;
  signOut: () => Promise<void>;
  resetPassword: (emailOrRoll: string, newPassword?: string) => Promise<{ success: boolean; message: string }>;
  updateProfile: (updatedData: Partial<User>) => Promise<{ success: boolean; error?: string }>;
  isAuthModalOpen: boolean;
  authModalMode: 'signin' | 'signup' | 'reset';
  openAuthModal: (mode?: 'signin' | 'signup' | 'reset') => void;
  closeAuthModal: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authModalMode, setAuthModalMode] = useState<'signin' | 'signup' | 'reset'>('signin');

  // Listen to Supabase Auth state changes & load user profile from public.profiles
  useEffect(() => {
    let isMounted = true;

    async function initializeAuth() {
      try {
        const { data: { session }, error } = await supabase.auth.getSession();
        if (error) {
          console.warn('Supabase getSession error:', error.message);
        }

        if (session?.user && isMounted) {
          await loadUserProfile(session.user.id, session.user);
        } else if (isMounted) {
          setCurrentUser(null);
        }
      } catch (err) {
        console.warn('Error in initializeAuth:', err);
      } finally {
        if (isMounted) setIsLoading(false);
      }
    }

    initializeAuth();

    // Subscribe to auth state updates (sign in, sign out, token refresh)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      if (!isMounted) return;

      if (session?.user) {
        await loadUserProfile(session.user.id, session.user);
      } else {
        setCurrentUser(null);
      }
      setIsLoading(false);
    });

    return () => {
      isMounted = false;
      subscription.unsubscribe();
    };
  }, []);

  /**
   * Loads the student's profile from public.profiles with metadata fallback
   */
  const loadUserProfile = async (userId: string, authUser?: any) => {
    try {
      const profile = await fetchProfileById(userId);
      if (profile) {
        setCurrentUser(profile);
        return;
      }

      // If database trigger has not finished or profile row is empty, construct from authUser metadata
      if (authUser?.user_metadata) {
        const meta = authUser.user_metadata;
        const fallbackUser: User = {
          id: userId,
          firstName: meta.first_name || meta.firstName || 'Student',
          lastName: meta.last_name || meta.lastName || '',
          rollNumber: meta.roll_number || meta.rollNumber || '',
          email: authUser.email || meta.email || '',
          department: meta.department_name || meta.department || 'Computer Science',
          degree: meta.program_name || meta.degree || 'BS Computer Science',
          semester: meta.semester_name || meta.semester || '1st',
          section: meta.section_name || meta.section || 'A',
          admissionBatch: meta.batch_name || meta.admission_batch || meta.admissionBatch || 'Fall 2026 – 2030',
          admissionYear: Number(meta.admission_year || meta.admissionYear) || 2026,
          expectedGraduationYear: Number(meta.expected_graduation_year || meta.expectedGraduationYear) || 2030,
          avatarColor: meta.avatar_color || '#0F172A',
          phone: meta.phone,
          bio: meta.bio,
          departmentId: meta.department_id,
          programId: meta.program_id,
          semesterId: meta.semester_id,
          sectionId: meta.section_id,
          batchId: meta.batch_id
        };
        setCurrentUser(fallbackUser);
      }
    } catch (err) {
      console.warn('Failed to load user profile:', err);
    }
  };

  const openAuthModal = (mode: 'signin' | 'signup' | 'reset' = 'signin') => {
    setAuthModalMode(mode);
    setIsAuthModalOpen(true);
  };

  const closeAuthModal = () => {
    setIsAuthModalOpen(false);
  };

  /**
   * Student Login through Supabase Auth
   * Supports both direct email or student roll number by querying public.profiles
   */
  const signIn = async (identifier: string, password: string): Promise<{ success: boolean; error?: string }> => {
    const cleanId = identifier.trim();
    if (!cleanId || !password) {
      return { success: false, error: 'Please enter both your email or roll number and password.' };
    }

    setIsSubmitting(true);
    try {
      let targetEmail = cleanId;

      // If identifier is not an email, find student's email from public.profiles by roll number
      if (!cleanId.includes('@')) {
        const cleanRoll = cleanId.toLowerCase();
        const { data: profileMatch, error: searchErr } = await supabase
          .from('profiles')
          .select('email, roll_number')
          .ilike('roll_number', `%${cleanRoll}%`)
          .limit(1)
          .maybeSingle();

        if (profileMatch?.email) {
          targetEmail = profileMatch.email;
        } else {
          // If no profile found by roll number, show friendly message
          setIsSubmitting(false);
          return {
            success: false,
            error: searchErr
              ? 'Database error checking roll number. Please try signing in with your student email.'
              : `No registered student profile found with roll number "${cleanId}". Please check or use your email.`
          };
        }
      }

      // Supabase Auth sign in
      const { data, error } = await supabase.auth.signInWithPassword({
        email: targetEmail.toLowerCase(),
        password
      });

      if (error) {
        setIsSubmitting(false);
        return { success: false, error: error.message };
      }

      if (data.user) {
        await loadUserProfile(data.user.id, data.user);
        closeAuthModal();
        setIsSubmitting(false);
        return { success: true };
      }

      setIsSubmitting(false);
      return { success: false, error: 'Authentication failed. Please try again.' };
    } catch (err: any) {
      setIsSubmitting(false);
      return { success: false, error: err.message || 'An unexpected error occurred during sign in.' };
    }
  };

  /**
   * Student Registration:
   * Creates real Supabase Auth account and passes student's academic information as user metadata
   * so the database trigger can create the corresponding profile in public.profiles.
   */
  const signUp = async (data: RegisterData): Promise<{ success: boolean; error?: string }> => {
    if (!data.firstName.trim() || !data.lastName.trim()) {
      return { success: false, error: 'First name and Last name are required.' };
    }
    if (!data.rollNumber.trim()) {
      return { success: false, error: 'Roll number is required (e.g. 25-048).' };
    }
    if (!data.email.trim() || !data.email.includes('@')) {
      return { success: false, error: 'Please provide a valid student email address.' };
    }
    if (!data.password || data.password.length < 6) {
      return { success: false, error: 'Password must be at least 6 characters long.' };
    }
    if (!data.department || !data.degree || !data.semester || !data.section) {
      return { success: false, error: 'Please fill in all academic department, program, semester, and section fields.' };
    }

    setIsSubmitting(true);
    try {
      const formattedRoll = formatRollNumber(data.rollNumber, data.degree || data.department);

      // Resolve relational foreign key IDs from Supabase tables (departments, programs, semesters, sections, batches)
      const [deptList, progList, semList, secList, batchList] = await Promise.all([
        fetchDepartments(),
        fetchPrograms(),
        fetchSemesters(),
        fetchSections(),
        fetchBatches()
      ]);

      const matchedDept = deptList.find(
        (d) => d.name.toLowerCase() === data.department.toLowerCase()
      );
      const matchedProg = progList.find(
        (p) => p.name.toLowerCase() === data.degree.toLowerCase()
      );
      const matchedSem = semList.find(
        (s) => s.name.toLowerCase() === data.semester.toLowerCase()
      );
      const matchedSec = secList.find(
        (s) => s.name.toUpperCase() === data.section.toUpperCase()
      );
      const matchedBatch = batchList.find(
        (b) => b.name.toLowerCase().includes(String(data.admissionYear)) || b.name.toLowerCase() === data.admissionBatch.toLowerCase()
      );

      // Metadata passed to Supabase Auth so trigger creates the profile in public.profiles
      const academicMetadata = {
        first_name: data.firstName.trim(),
        last_name: data.lastName.trim(),
        full_name: `${data.firstName.trim()} ${data.lastName.trim()}`,
        roll_number: formattedRoll,
        phone: data.phone?.trim() || null,
        bio: data.bio?.trim() || `Student of ${data.degree} at Peshawar University.`,
        
        // Relational IDs
        department_id: matchedDept?.id || null,
        program_id: matchedProg?.id || null,
        semester_id: matchedSem?.id || null,
        section_id: matchedSec?.id || null,
        batch_id: matchedBatch?.id || null,

        // Academic names
        department: data.department,
        department_name: data.department,
        degree: data.degree,
        program: data.degree,
        program_name: data.degree,
        semester: data.semester,
        semester_name: data.semester,
        section: data.section,
        section_name: data.section,
        admission_batch: data.admissionBatch,
        batch_name: data.admissionBatch,
        admission_year: Number(data.admissionYear) || 2026,
        expected_graduation_year: Number(data.expectedGraduationYear) || 2030,
        avatar_color: '#0F172A'
      };

      // Real Supabase Auth signUp
      const { data: authResult, error: signUpError } = await supabase.auth.signUp({
        email: data.email.trim().toLowerCase(),
        password: data.password,
        options: {
          data: academicMetadata
        }
      });

      if (signUpError) {
        setIsSubmitting(false);
        return { success: false, error: signUpError.message };
      }

      if (authResult.user) {
        // Also ensure public.profiles row is verified or upserted in case trigger is disabled or delayed
        try {
          await supabase.from('profiles').upsert({
            id: authResult.user.id,
            first_name: academicMetadata.first_name,
            last_name: academicMetadata.last_name,
            full_name: academicMetadata.full_name,
            roll_number: academicMetadata.roll_number,
            email: data.email.trim().toLowerCase(),
            phone: academicMetadata.phone,
            bio: academicMetadata.bio,
            department_id: academicMetadata.department_id,
            program_id: academicMetadata.program_id,
            semester_id: academicMetadata.semester_id,
            section_id: academicMetadata.section_id,
            batch_id: academicMetadata.batch_id,
            department: academicMetadata.department,
            degree: academicMetadata.degree,
            semester: academicMetadata.semester,
            section: academicMetadata.section,
            admission_batch: academicMetadata.admission_batch,
            admission_year: academicMetadata.admission_year,
            expected_graduation_year: academicMetadata.expected_graduation_year,
            avatar_color: academicMetadata.avatar_color
          }, { onConflict: 'id' });
        } catch (profileErr) {
          console.warn('Profile upsert note:', profileErr);
        }

        await loadUserProfile(authResult.user.id, authResult.user);
        closeAuthModal();
        setIsSubmitting(false);
        return { success: true };
      }

      setIsSubmitting(false);
      return { success: false, error: 'Registration incomplete. Please check your inputs.' };
    } catch (err: any) {
      setIsSubmitting(false);
      return { success: false, error: err.message || 'Failed to create student account.' };
    }
  };

  /**
   * Sign out via Supabase Auth
   */
  const signOut = async () => {
    try {
      await supabase.auth.signOut();
    } catch (err) {
      console.warn('Sign out error:', err);
    } finally {
      setCurrentUser(null);
    }
  };

  /**
   * Password reset via Supabase Auth
   */
  const resetPassword = async (emailOrRoll: string): Promise<{ success: boolean; message: string }> => {
    if (!emailOrRoll.trim()) {
      return { success: false, message: 'Please enter your registered student email or roll number.' };
    }

    try {
      let targetEmail = emailOrRoll.trim();

      if (!targetEmail.includes('@')) {
        const { data: profileMatch } = await supabase
          .from('profiles')
          .select('email')
          .ilike('roll_number', `%${targetEmail}%`)
          .limit(1)
          .maybeSingle();

        if (profileMatch?.email) {
          targetEmail = profileMatch.email;
        } else {
          return {
            success: false,
            message: `No student profile found with roll number "${emailOrRoll}". Please provide your email address.`
          };
        }
      }

      const { error } = await supabase.auth.resetPasswordForEmail(targetEmail, {
        redirectTo: window.location.origin
      });

      if (error) {
        return { success: false, message: error.message };
      }

      return {
        success: true,
        message: `Password reset instructions have been sent to ${targetEmail}. Please check your inbox.`
      };
    } catch (err: any) {
      return { success: false, message: err.message || 'Failed to request password reset.' };
    }
  };

  /**
   * Update student profile in public.profiles and local state
   */
  const updateProfile = async (updatedData: Partial<User>): Promise<{ success: boolean; error?: string }> => {
    if (!currentUser) return { success: false, error: 'No authenticated student.' };

    setIsSubmitting(true);
    try {
      let rollFormatted = updatedData.rollNumber;
      if (rollFormatted) {
        rollFormatted = formatRollNumber(
          rollFormatted,
          updatedData.degree || currentUser.degree || currentUser.department
        );
      }

      // If user changed password
      if (updatedData.password) {
        const { error: pwdErr } = await supabase.auth.updateUser({
          password: updatedData.password
        });
        if (pwdErr) {
          setIsSubmitting(false);
          return { success: false, error: pwdErr.message };
        }
      }

      // If academic department, program, semester, section, batch changed, resolve new IDs
      let departmentId = currentUser.departmentId;
      let programId = currentUser.programId;
      let semesterId = currentUser.semesterId;
      let sectionId = currentUser.sectionId;
      let batchId = currentUser.batchId;

      if (
        updatedData.department ||
        updatedData.degree ||
        updatedData.semester ||
        updatedData.section ||
        updatedData.admissionBatch
      ) {
        const [deptList, progList, semList, secList, batchList] = await Promise.all([
          fetchDepartments(),
          fetchPrograms(),
          fetchSemesters(),
          fetchSections(),
          fetchBatches()
        ]);

        if (updatedData.department) {
          departmentId = deptList.find((d) => d.name.toLowerCase() === updatedData.department?.toLowerCase())?.id || departmentId;
        }
        if (updatedData.degree) {
          programId = progList.find((p) => p.name.toLowerCase() === updatedData.degree?.toLowerCase())?.id || programId;
        }
        if (updatedData.semester) {
          semesterId = semList.find((s) => s.name.toLowerCase() === updatedData.semester?.toLowerCase())?.id || semesterId;
        }
        if (updatedData.section) {
          sectionId = secList.find((s) => s.name.toUpperCase() === updatedData.section?.toUpperCase())?.id || sectionId;
        }
        if (updatedData.admissionBatch) {
          batchId = batchList.find((b) => b.name.toLowerCase() === updatedData.admissionBatch?.toLowerCase())?.id || batchId;
        }
      }

      const updates: any = {
        phone: updatedData.phone !== undefined ? updatedData.phone : currentUser.phone,
        bio: updatedData.bio !== undefined ? updatedData.bio : currentUser.bio,
        roll_number: rollFormatted || currentUser.rollNumber,
        department: updatedData.department || currentUser.department,
        degree: updatedData.degree || currentUser.degree,
        semester: updatedData.semester || currentUser.semester,
        section: updatedData.section || currentUser.section,
        admission_batch: updatedData.admissionBatch || currentUser.admissionBatch,
        admission_year: updatedData.admissionYear || currentUser.admissionYear,
        expected_graduation_year: updatedData.expectedGraduationYear || currentUser.expectedGraduationYear,
        department_id: departmentId,
        program_id: programId,
        semester_id: semesterId,
        section_id: sectionId,
        batch_id: batchId
      };

      const result = await updateSupabaseProfile(currentUser.id, updates);
      if (!result.success) {
        setIsSubmitting(false);
        return { success: false, error: result.error };
      }

      // Update local state
      const updatedUser: User = {
        ...currentUser,
        ...updatedData,
        rollNumber: rollFormatted || currentUser.rollNumber,
        departmentId,
        programId,
        semesterId,
        sectionId,
        batchId
      };
      setCurrentUser(updatedUser);
      setIsSubmitting(false);
      return { success: true };
    } catch (err: any) {
      setIsSubmitting(false);
      return { success: false, error: err.message || 'Failed to update student profile.' };
    }
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        isAuthenticated: !!currentUser,
        isLoading,
        isSubmitting,
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
