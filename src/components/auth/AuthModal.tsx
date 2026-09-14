import React, { useState, useMemo } from 'react';
import {
  X,
  Lock,
  Mail,
  User,
  GraduationCap,
  Calendar,
  Building,
  KeyRound,
  Eye,
  EyeOff,
  Sparkles,
  ArrowRight,
  ShieldCheck,
  Check,
  Loader2,
  CheckCircle2
} from 'lucide-react';
import { useAuth, RegisterData } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';
import { RollNumberInput } from '../common/RollNumberInput';
import { formatRollNumber } from '../../utils/rollNumberUtils';

const GoogleIcon: React.FC<{ className?: string }> = ({ className = 'w-4 h-4' }) => (
  <svg className={className} viewBox="0 0 24 24">
    <path
      fill="#4285F4"
      d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.665-5.17 3.665-9.17z"
    />
    <path
      fill="#34A853"
      d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.33 24 12 24z"
    />
    <path
      fill="#FBBC05"
      d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.98 0 12s.45 3.82 1.25 5.42l4.03-3.15z"
    />
    <path
      fill="#EA4335"
      d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z"
    />
  </svg>
);

export const AuthModal: React.FC = () => {
  const {
    isAuthModalOpen,
    authModalMode,
    closeAuthModal,
    openAuthModal,
    signIn,
    signInWithGoogle,
    signUp,
    resetPassword,
    emailConfirmationPending
  } = useAuth();
  const { departments, programs, semesters, sections, batches } = useApp();

  // Dynamic dropdown lists loaded exclusively from Supabase tables
  const departmentOptions = departments.map((d) => d.name);
  const semesterOptions = semesters.map((s) => s.name);
  const sectionOptions = sections.map((s) => s.name);
  const batchOptions = batches.map((b) => b.name);

  // Sign In Form State - Clean empty state
  const [signInIdentifier, setSignInIdentifier] = useState('');
  const [signInPassword, setSignInPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [signInError, setSignInError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Register Form State (All 12 fields)
  const [regData, setRegData] = useState<RegisterData>({
    firstName: '',
    lastName: '',
    rollNumber: '',
    email: '',
    password: '',
    department: 'Computer Science',
    degree: 'BS Computer Science',
    semester: '1st',
    section: 'A',
    admissionBatch: 'Fall 2026 – 2030',
    admissionYear: 2026,
    expectedGraduationYear: 2030,
    phone: '',
    bio: ''
  });
  const [regStep, setRegStep] = useState<1 | 2>(1);
  const [regError, setRegError] = useState('');

  // Find currently selected department record and its department_id from Supabase departments table
  const selectedDepartmentRecord = useMemo(() => {
    return departments.find(
      (d) => d.name.toLowerCase() === regData.department.toLowerCase() || d.id === regData.department
    );
  }, [departments, regData.department]);

  const selectedDepartmentId = selectedDepartmentRecord?.id;

  // Filter programs from Supabase programs table using the selected department's department_id
  const filteredProgramsForDept = useMemo(() => {
    const matched = programs.filter((p) => {
      if (selectedDepartmentId && p.department_id) {
        return p.department_id === selectedDepartmentId;
      }
      const progDept = (p as any).department;
      if (progDept && selectedDepartmentRecord) {
        return progDept.toLowerCase() === selectedDepartmentRecord.name.toLowerCase();
      }
      if (regData.department === 'Computer Science') return p.name === 'BS Computer Science';
      if (regData.department === 'Software Engineering') return p.name === 'BS Software Engineering';
      if (regData.department === 'Artificial Intelligence') return p.name === 'BS Artificial Intelligence';
      return false;
    });

    if (matched.length > 0) return matched;

    // Guaranteed canonical fallback mapping
    const fallbackName =
      regData.department === 'Software Engineering'
        ? 'BS Software Engineering'
        : regData.department === 'Artificial Intelligence'
        ? 'BS Artificial Intelligence'
        : 'BS Computer Science';

    return [{ id: `prog-${regData.department}`, name: fallbackName, department_id: selectedDepartmentId }];
  }, [programs, selectedDepartmentId, selectedDepartmentRecord, regData.department]);

  const degreeOptions = useMemo(() => {
    return filteredProgramsForDept.map((p) => p.name);
  }, [filteredProgramsForDept]);

  // All canonical programs list for initial step selection
  const allProgramOptions = useMemo(() => {
    const names = programs.map((p) => p.name);
    return names.length > 0 ? names : ['BS Computer Science', 'BS Software Engineering', 'BS Artificial Intelligence'];
  }, [programs]);

  const handleDepartmentChange = (newDept: string) => {
    // Lookup department record
    const deptMatch = departments.find(
      (d) => d.name.toLowerCase() === newDept.toLowerCase() || d.id === newDept
    );
    const deptId = deptMatch?.id;

    // Find program filtered by selected department's department_id
    const matchingPrograms = programs.filter((p) => {
      if (deptId && p.department_id) {
        return p.department_id === deptId;
      }
      const progDept = (p as any).department;
      if (progDept && deptMatch) {
        return progDept.toLowerCase() === deptMatch.name.toLowerCase();
      }
      if (newDept === 'Computer Science') return p.name === 'BS Computer Science';
      if (newDept === 'Software Engineering') return p.name === 'BS Software Engineering';
      if (newDept === 'Artificial Intelligence') return p.name === 'BS Artificial Intelligence';
      return false;
    });

    const nextDegree = matchingPrograms.length > 0
      ? matchingPrograms[0].name
      : newDept === 'Software Engineering'
      ? 'BS Software Engineering'
      : newDept === 'Artificial Intelligence'
      ? 'BS Artificial Intelligence'
      : 'BS Computer Science';

    setRegData((prev) => ({
      ...prev,
      department: newDept,
      degree: nextDegree,
      rollNumber: formatRollNumber(prev.rollNumber, nextDegree)
    }));
  };

  const handleDegreeChange = (newDeg: string) => {
    // Find the program record from Supabase programs
    const progMatch = programs.find((p) => p.name.toLowerCase() === newDeg.toLowerCase());
    let associatedDept = regData.department;
    if (progMatch?.department_id) {
      const dMatch = departments.find((d) => d.id === progMatch.department_id);
      if (dMatch) associatedDept = dMatch.name;
    } else {
      associatedDept = newDeg.includes('Software')
        ? 'Software Engineering'
        : newDeg.includes('Artificial')
        ? 'Artificial Intelligence'
        : 'Computer Science';
    }

    setRegData((prev) => ({
      ...prev,
      degree: newDeg,
      department: associatedDept,
      rollNumber: formatRollNumber(prev.rollNumber, newDeg)
    }));
  };

  // Reset Password State
  const [resetIdentifier, setResetIdentifier] = useState('');
  const [resetStep, setResetStep] = useState<'request' | 'verify' | 'done'>('request');
  const [resetCode, setResetCode] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [resetMessage, setResetMessage] = useState('');

  if (!isAuthModalOpen) return null;

  const handleSignInSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSignInError('');
    setIsSubmitting(true);
    try {
      const result = await signIn(signInIdentifier, signInPassword);
      if (!result.success && result.error) {
        setSignInError(result.error);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleGoogleSignIn = async () => {
    setSignInError('');
    setRegError('');
    setIsSubmitting(true);
    try {
      const result = await signInWithGoogle();
      if (!result.success && result.error) {
        setSignInError(result.error);
        setRegError(result.error);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setRegError('');
    setIsSubmitting(true);
    try {
      const result = await signUp(regData);
      if (!result.success && result.error) {
        setRegError(result.error);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleResetSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!resetIdentifier.trim()) {
      setResetMessage('Please enter your roll number or university email.');
      return;
    }
    setIsSubmitting(true);
    try {
      const result = await resetPassword(resetIdentifier);
      setResetMessage(result.message);
      if (result.success) {
        setResetStep('done');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-6 overflow-y-auto animate-in fade-in duration-200"
      onClick={closeAuthModal}
    >
      <div
        className="w-full max-w-xl bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col my-auto animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header Ribbon */}
        <div className="bg-[#0F172A] text-white p-6 pb-5 relative">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-[40px] h-[40px] flex items-center justify-center shrink-0">
                <img
                  src="/campushub-logo.svg"
                  alt="CampusHub Logo"
                  className="w-full h-full object-contain select-none"
                  referrerPolicy="no-referrer"
                />
              </div>
              <div>
                <h2 className="text-lg font-bold tracking-tight">CampusHub Portal</h2>
                <p className="text-xs text-slate-400">Peshawar University Academic Access</p>
              </div>
            </div>
            <button
              onClick={closeAuthModal}
              className="p-1.5 rounded-full text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
              aria-label="Close auth dialog"
            >
              <X size={18} />
            </button>
          </div>

          {/* Mode Switcher Tabs */}
          <div className="flex items-center mt-5 p-1 bg-slate-900/80 rounded-xl border border-slate-800 text-xs font-semibold">
            <button
              type="button"
              onClick={() => openAuthModal('signin')}
              className={`flex-1 py-2 rounded-lg transition-all ${
                authModalMode === 'signin'
                  ? 'bg-[#C5A059] text-[#0F172A] shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Sign In
            </button>
            <button
              type="button"
              onClick={() => openAuthModal('signup')}
              className={`flex-1 py-2 rounded-lg transition-all ${
                authModalMode === 'signup'
                  ? 'bg-[#C5A059] text-[#0F172A] shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Create Account
            </button>
            <button
              type="button"
              onClick={() => openAuthModal('reset')}
              className={`flex-1 py-2 rounded-lg transition-all ${
                authModalMode === 'reset'
                  ? 'bg-[#C5A059] text-[#0F172A] shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Reset Password
            </button>
          </div>
        </div>

        {/* Content Body */}
        <div className="p-6 sm:p-8 max-h-[75vh] overflow-y-auto">
          {/* 1. SIGN IN MODE */}
          {authModalMode === 'signin' && (
            <form onSubmit={handleSignInSubmit} className="space-y-4">
              <div className="text-center pb-2">
                <h3 className="text-base font-bold text-slate-900">Student Sign In</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Sign in with your Google account, campus roll number, or student email.
                </p>
              </div>

              {/* Google OAuth Fast Sign-in */}
              <button
                type="button"
                onClick={handleGoogleSignIn}
                disabled={isSubmitting}
                className="w-full py-2.5 px-4 bg-white hover:bg-slate-50 active:bg-slate-100 border border-slate-300 hover:border-slate-400 text-slate-700 rounded-xl text-xs font-bold shadow-sm transition-all flex items-center justify-center gap-2.5 disabled:opacity-60 cursor-pointer"
              >
                <GoogleIcon className="w-4 h-4 shrink-0" />
                <span>Continue with Google</span>
              </button>

              <div className="relative my-3">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-slate-200" />
                </div>
                <div className="relative flex justify-center text-[11px] uppercase">
                  <span className="bg-white px-2.5 text-slate-400 font-semibold tracking-wider">
                    or sign in with roll number / email
                  </span>
                </div>
              </div>

              {signInError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
                  {signInError}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Email or Roll Number
                </label>
                <div className="relative">
                  <Mail size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input
                    type="text"
                    required
                    value={signInIdentifier}
                    onChange={(e) => setSignInIdentifier(e.target.value)}
                    placeholder="e.g. your roll number or student email"
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 focus:border-[#C5A059] outline-none transition-all"
                  />
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="block text-xs font-semibold text-slate-700">
                    Password
                  </label>
                  <button
                    type="button"
                    onClick={() => openAuthModal('reset')}
                    className="text-xs text-[#B38E46] hover:underline font-medium"
                  >
                    Forgot password?
                  </button>
                </div>
                <div className="relative">
                  <Lock size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required
                    value={signInPassword}
                    onChange={(e) => setSignInPassword(e.target.value)}
                    placeholder="Enter account password"
                    className="w-full pl-10 pr-10 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 focus:border-[#C5A059] outline-none transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={isSubmitting}
                className="w-full py-3 px-4 bg-[#0F172A] hover:bg-slate-800 disabled:opacity-60 text-white rounded-xl text-sm font-bold shadow-md hover:shadow-lg transition-all mt-2 flex items-center justify-center gap-2"
              >
                {isSubmitting && <Loader2 size={16} className="animate-spin text-[#C5A059]" />}
                <span>{isSubmitting ? 'Authenticating with Supabase...' : 'Sign In to CampusHub'}</span>
              </button>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-center">
                <button
                  type="button"
                  onClick={() => openAuthModal('signup')}
                  className="text-xs text-slate-500 hover:text-slate-800 font-medium"
                >
                  Need a new account? <span className="text-[#C5A059] font-bold">Register</span>
                </button>
              </div>
            </form>
          )}

          {/* 2. REGISTRATION MODE - All 12 Fields */}
          {authModalMode === 'signup' && (
            <form onSubmit={handleRegisterSubmit} className="space-y-4">
              <div className="pb-2 border-b border-slate-100">
                <h3 className="text-base font-bold text-slate-900">Student Account Registration</h3>
                <p className="text-xs text-slate-500">
                  Step {regStep} of 2: {regStep === 1 ? 'Personal & Security' : 'Academic Enrollment'}
                </p>
              </div>

              {regError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
                  {regError}
                </div>
              )}

              {/* STEP 1: Personal & Account Credentials */}
              {regStep === 1 && (
                <div className="space-y-3.5 animate-in fade-in duration-150">
                  {/* Google OAuth Option */}
                  <button
                    type="button"
                    onClick={handleGoogleSignIn}
                    disabled={isSubmitting}
                    className="w-full py-2.5 px-4 bg-white hover:bg-slate-50 active:bg-slate-100 border border-slate-300 hover:border-slate-400 text-slate-700 rounded-xl text-xs font-bold shadow-sm transition-all flex items-center justify-center gap-2.5 disabled:opacity-60 cursor-pointer"
                  >
                    <GoogleIcon className="w-4 h-4 shrink-0" />
                    <span>Quick Sign Up with Google</span>
                  </button>

                  <div className="relative my-2">
                    <div className="absolute inset-0 flex items-center">
                      <div className="w-full border-t border-slate-200" />
                    </div>
                    <div className="relative flex justify-center text-[11px] uppercase">
                      <span className="bg-white px-2.5 text-slate-400 font-semibold tracking-wider">
                        or register with student email
                      </span>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        First Name *
                      </label>
                      <input
                        type="text"
                        required
                        value={regData.firstName}
                        onChange={(e) => setRegData({ ...regData, firstName: e.target.value })}
                        placeholder="First name"
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Last Name *
                      </label>
                      <input
                        type="text"
                        required
                        value={regData.lastName}
                        onChange={(e) => setRegData({ ...regData, lastName: e.target.value })}
                        placeholder="Last name"
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                    </div>
                  </div>

                  {/* Program and Auto-prefixed Roll Number */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Program / Degree *
                      </label>
                      <select
                        value={regData.degree}
                        onChange={(e) => handleDegreeChange(e.target.value)}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none font-medium h-[42px]"
                      >
                        {allProgramOptions.map((deg) => (
                          <option key={deg} value={deg}>
                            {deg}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Roll Number *
                      </label>
                      <RollNumberInput
                        degree={regData.degree}
                        value={regData.rollNumber}
                        onChange={(fullRoll) => setRegData({ ...regData, rollNumber: fullRoll })}
                        placeholder="e.g. 25-001"
                        className="h-[42px]"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Campus Email *
                    </label>
                    <input
                      type="email"
                      required
                      value={regData.email}
                      onChange={(e) => setRegData({ ...regData, email: e.target.value })}
                      placeholder="student@campushub.pk"
                      className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Password * (min 6 chars)
                    </label>
                    <div className="relative">
                      <input
                        type={showPassword ? 'text' : 'password'}
                        required
                        value={regData.password}
                        onChange={(e) => setRegData({ ...regData, password: e.target.value })}
                        placeholder="Create secure portal password"
                        className="w-full pl-3 pr-10 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                      >
                        {showPassword ? <EyeOff size={15} /> : <Eye size={15} />}
                      </button>
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Contact Mobile (Optional)
                    </label>
                    <input
                      type="text"
                      value={regData.phone}
                      onChange={(e) => setRegData({ ...regData, phone: e.target.value })}
                      placeholder="e.g. +92 300 1234567"
                      className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                    />
                  </div>

                  <button
                    type="button"
                    onClick={() => {
                      if (!regData.firstName || !regData.lastName || !regData.rollNumber || !regData.email || !regData.password) {
                        setRegError('Please complete all required fields in Step 1 before continuing.');
                        return;
                      }
                      setRegError('');
                      setRegStep(2);
                    }}
                    className="w-full py-2.5 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 mt-2"
                  >
                    <span>Proceed to Academic Fields</span>
                    <ArrowRight size={14} />
                  </button>
                </div>
              )}

              {/* STEP 2: Academic Program, Department, Semester, Batch, Years */}
              {regStep === 2 && (
                <div className="space-y-3.5 animate-in fade-in duration-150">
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Department *
                      </label>
                      <select
                        value={regData.department}
                        onChange={(e) => handleDepartmentChange(e.target.value)}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      >
                        {departmentOptions.map((dept) => (
                          <option key={dept} value={dept}>
                            {dept}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Degree / Program *
                      </label>
                      <select
                        value={regData.degree}
                        onChange={(e) => handleDegreeChange(e.target.value)}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      >
                        {degreeOptions.map((deg) => (
                          <option key={deg} value={deg}>
                            {deg}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Current Semester *
                      </label>
                      <select
                        value={regData.semester}
                        onChange={(e) => setRegData({ ...regData, semester: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      >
                        {semesterOptions.map((sem) => (
                          <option key={sem} value={sem}>
                            {sem} Semester
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Section *
                      </label>
                      <select
                        value={regData.section}
                        onChange={(e) => setRegData({ ...regData, section: e.target.value })}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      >
                        {sectionOptions.map((sec) => (
                          <option key={sec} value={sec}>
                            Section {sec}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Admission Batch *
                    </label>
                    <select
                      value={regData.admissionBatch}
                      onChange={(e) => {
                        const val = e.target.value;
                        const match = val.match(/(\d{4})/);
                        const startYr = match ? parseInt(match[1]) : 2026;
                        setRegData({
                          ...regData,
                          admissionBatch: val,
                          admissionYear: startYr,
                          expectedGraduationYear: startYr + 4
                        });
                      }}
                      className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                    >
                      {batchOptions.map((b) => (
                        <option key={b} value={b}>
                          {b}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Admission Year *
                      </label>
                      <input
                        type="number"
                        min="2018"
                        max="2035"
                        required
                        value={regData.admissionYear}
                        onChange={(e) =>
                          setRegData({ ...regData, admissionYear: parseInt(e.target.value) || 2026 })
                        }
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1">
                        Expected Graduation Year *
                      </label>
                      <input
                        type="number"
                        min="2022"
                        max="2038"
                        required
                        value={regData.expectedGraduationYear}
                        onChange={(e) =>
                          setRegData({
                            ...regData,
                            expectedGraduationYear: parseInt(e.target.value) || 2030
                          })
                        }
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                    </div>
                  </div>

                  <div className="flex gap-2 pt-2">
                    <button
                      type="button"
                      disabled={isSubmitting}
                      onClick={() => setRegStep(1)}
                      className="py-2.5 px-4 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition-all"
                    >
                      Back
                    </button>
                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="flex-1 py-2.5 bg-[#0F172A] hover:bg-slate-800 disabled:opacity-60 text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center justify-center gap-2"
                    >
                      {isSubmitting && <Loader2 size={15} className="animate-spin text-[#C5A059]" />}
                      <span>{isSubmitting ? 'Registering with Supabase...' : 'Complete Registration & Sign In'}</span>
                    </button>
                  </div>
                </div>
              )}

              <div className="pt-2 text-center">
                <button
                  type="button"
                  onClick={() => openAuthModal('signin')}
                  className="text-xs text-slate-500 hover:text-slate-800 font-medium"
                >
                  Already have an account? <span className="text-[#C5A059] font-bold">Sign In</span>
                </button>
              </div>
            </form>
          )}

          {/* 3. RESET PASSWORD WORKFLOW */}
          {authModalMode === 'reset' && (
            <div className="space-y-4">
              <div className="text-center pb-2">
                <h3 className="text-base font-bold text-slate-900">Account Password Reset</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Secure recovery for Peshawar university student portal accounts.
                </p>
              </div>

              {resetMessage && (
                <div className="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs font-medium">
                  {resetMessage}
                </div>
              )}

              {resetStep === 'request' && (
                <form onSubmit={handleResetSubmit} className="space-y-3">
                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Campus Roll Number or Email
                    </label>
                    <input
                      type="text"
                      required
                      value={resetIdentifier}
                      onChange={(e) => setResetIdentifier(e.target.value)}
                      placeholder="e.g. your roll number or campus email"
                      className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                    />
                  </div>
                  <button
                    type="submit"
                    className="w-full py-2.5 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all"
                  >
                    Send Verification Token
                  </button>
                </form>
              )}

              {resetStep === 'verify' && (
                <form onSubmit={handleResetSubmit} className="space-y-3">
                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      Verification Security Code
                    </label>
                    <input
                      type="text"
                      required
                      value={resetCode}
                      onChange={(e) => setResetCode(e.target.value)}
                      placeholder="Enter 6-digit code (e.g. 492810)"
                      className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-mono text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-slate-700 mb-1">
                      New Account Password
                    </label>
                    <input
                      type="password"
                      required
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="Enter new password (min 6 chars)"
                      className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                    />
                  </div>
                  <button
                    type="submit"
                    className="w-full py-2.5 bg-[#047857] hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition-all"
                  >
                    Confirm & Update Password
                  </button>
                </form>
              )}

              {resetStep === 'done' && (
                <div className="text-center py-4 space-y-3">
                  <div className="w-12 h-12 bg-emerald-100 text-emerald-700 rounded-full flex items-center justify-center mx-auto">
                    <Check size={24} />
                  </div>
                  <p className="text-sm font-bold text-slate-900">Password Reset Complete</p>
                  <p className="text-xs text-slate-500">
                    Your account password has been updated. You can now sign in with your new credentials.
                  </p>
                  <button
                    type="button"
                    onClick={() => openAuthModal('signin')}
                    className="py-2 px-4 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all"
                  >
                    Proceed to Sign In
                  </button>
                </div>
              )}

              <div className="pt-2 text-center">
                <button
                  type="button"
                  onClick={() => openAuthModal('signin')}
                  className="text-xs text-[#C5A059] font-bold hover:underline"
                >
                  Return to Sign In
                </button>
              </div>
            </div>
          )}

          {/* 4. EMAIL CONFIRMATION SENT VIEW */}
          {authModalMode === 'confirmation-sent' && (
            <div className="text-center py-3 space-y-4 animate-in fade-in duration-200">
              <div className="w-16 h-16 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-600 flex items-center justify-center mx-auto shadow-sm">
                <Mail size={32} />
              </div>
              <div className="space-y-2">
                <h3 className="text-base font-bold text-slate-900">Check Your Student Inbox</h3>
                <p className="text-xs text-slate-600 max-w-sm mx-auto leading-relaxed">
                  We have dispatched an official email verification link to:
                </p>
                <div className="py-1 px-3 bg-slate-100 border border-slate-200 rounded-lg inline-block font-mono text-xs font-semibold text-slate-800">
                  {emailConfirmationPending || regData.email}
                </div>
                <p className="text-xs text-slate-500 max-w-sm mx-auto pt-2 leading-relaxed">
                  Please open the confirmation email and click <span className="font-bold text-slate-800">Confirm your mail</span>. CampusHub will automatically activate your profile and redirect you directly to your class timetable.
                </p>
              </div>

              <div className="pt-2 flex flex-col gap-2 max-w-xs mx-auto">
                <button
                  type="button"
                  onClick={() => openAuthModal('signin')}
                  className="w-full py-2.5 px-4 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all shadow-sm"
                >
                  Return to Sign In
                </button>
                <button
                  type="button"
                  onClick={closeAuthModal}
                  className="w-full py-2 px-4 text-xs font-medium text-slate-500 hover:text-slate-700 transition-colors"
                >
                  Dismiss
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
