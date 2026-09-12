import React, { useState } from 'react';
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
  Loader2
} from 'lucide-react';
import { useAuth, RegisterData } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';
import { DEPARTMENTS, DEGREES, SEMESTERS, SECTIONS, BATCHES } from '../../data/mockData';
import { RollNumberInput } from '../common/RollNumberInput';
import { formatRollNumber } from '../../utils/rollNumberUtils';

export const AuthModal: React.FC = () => {
  const {
    isAuthModalOpen,
    authModalMode,
    closeAuthModal,
    openAuthModal,
    signIn,
    signUp,
    resetPassword
  } = useAuth();
  const { departments, programs, semesters, sections, batches } = useApp();

  // Dynamic dropdown lists loaded from Supabase tables with fallback
  const departmentOptions = departments.length > 0 ? departments.map((d) => d.name) : DEPARTMENTS;
  const degreeOptions = programs.length > 0 ? programs.map((p) => p.name) : DEGREES;
  const semesterOptions = semesters.length > 0 ? semesters.map((s) => s.name) : SEMESTERS;
  const sectionOptions = sections.length > 0 ? sections.map((s) => s.name) : SECTIONS;
  const batchOptions = batches.length > 0 ? batches.map((b) => b.name) : BATCHES;

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
                  Sign in with your campus roll number or student email address.
                </p>
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
                        onChange={(e) => {
                          const newDeg = e.target.value;
                          const dept = newDeg.includes('Software')
                            ? 'Software Engineering'
                            : newDeg.includes('Artificial')
                            ? 'Artificial Intelligence'
                            : 'Computer Science';
                          setRegData({
                            ...regData,
                            degree: newDeg,
                            department: dept,
                            rollNumber: formatRollNumber(regData.rollNumber, newDeg)
                          });
                        }}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none font-medium h-[42px]"
                      >
                        {degreeOptions.map((deg) => (
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
                        onChange={(e) => setRegData({ ...regData, department: e.target.value })}
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
                        onChange={(e) => setRegData({ ...regData, degree: e.target.value })}
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
        </div>
      </div>
    </div>
  );
};
