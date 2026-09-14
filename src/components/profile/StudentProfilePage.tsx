import React, { useState, useMemo } from 'react';
import {
  User,
  GraduationCap,
  BookOpen,
  Calendar,
  Phone,
  Mail,
  Shield,
  Edit2,
  Check,
  X,
  Lock,
  LogOut,
  Save,
  Clock,
  Sparkles,
  AlertCircle,
  Loader2
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';
import { TimetableEntry } from '../../types';
import { getStudentEnrolledClasses, formatStudentAcademicContext } from '../../utils/studentScheduleUtils';
import { RollNumberInput } from '../common/RollNumberInput';
import { formatRollNumber, formatUserRollNumber } from '../../utils/rollNumberUtils';

export const StudentProfilePage: React.FC = () => {
  const { currentUser, updateProfile, signOut, openAuthModal } = useAuth();
  const {
    timetable,
    setActiveTab,
    departments,
    programs,
    semesters,
    sections,
    batches
  } = useApp();

  const departmentOptions = departments.map((d) => d.name);
  const semesterOptions = semesters.map((s) => s.name);
  const sectionOptions = sections.map((s) => s.name);
  const batchOptions = batches.map((b) => b.name);

  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [phone, setPhone] = useState(currentUser?.phone || '');
  const [department, setDepartment] = useState(currentUser?.department || 'Computer Science');
  const [degree, setDegree] = useState(currentUser?.degree || 'BS Computer Science');
  const [rollNumber, setRollNumber] = useState(currentUser?.rollNumber || '');
  const [semester, setSemester] = useState(currentUser?.semester || '3rd');
  const [section, setSection] = useState(currentUser?.section || 'A');
  const [admissionBatch, setAdmissionBatch] = useState(currentUser?.admissionBatch || 'Fall 2025 – 2029');
  const [expectedGraduationYear, setExpectedGraduationYear] = useState(currentUser?.expectedGraduationYear || 2029);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Filter programs for the selected department using Supabase department_id
  const selectedDeptRecord = useMemo(() => {
    return departments.find(
      (d) => d.name.toLowerCase() === department.toLowerCase() || d.id === department
    );
  }, [departments, department]);

  const selectedDeptId = selectedDeptRecord?.id;

  const filteredPrograms = useMemo(() => {
    const matched = programs.filter((p) => {
      if (selectedDeptId && p.department_id) {
        return p.department_id === selectedDeptId;
      }
      const progDept = (p as any).department;
      if (progDept && selectedDeptRecord) {
        return progDept.toLowerCase() === selectedDeptRecord.name.toLowerCase();
      }
      if (department === 'Computer Science') return p.name === 'BS Computer Science';
      if (department === 'Software Engineering') return p.name === 'BS Software Engineering';
      if (department === 'Artificial Intelligence') return p.name === 'BS Artificial Intelligence';
      return false;
    });

    if (matched.length > 0) return matched;

    const fallbackName =
      department === 'Software Engineering'
        ? 'BS Software Engineering'
        : department === 'Artificial Intelligence'
        ? 'BS Artificial Intelligence'
        : 'BS Computer Science';

    return [{ id: `prog-${department}`, name: fallbackName, department_id: selectedDeptId }];
  }, [programs, selectedDeptId, selectedDeptRecord, department]);

  const degreeOptions = useMemo(() => {
    return filteredPrograms.map((p) => p.name);
  }, [filteredPrograms]);

  const handleDepartmentChange = (newDept: string) => {
    setDepartment(newDept);
    const dRecord = departments.find(
      (d) => d.name.toLowerCase() === newDept.toLowerCase() || d.id === newDept
    );
    const dId = dRecord?.id;

    const matchedProgs = programs.filter((p) => {
      if (dId && p.department_id) return p.department_id === dId;
      const progDept = (p as any).department;
      if (progDept && dRecord) return progDept.toLowerCase() === dRecord.name.toLowerCase();
      if (newDept === 'Computer Science') return p.name === 'BS Computer Science';
      if (newDept === 'Software Engineering') return p.name === 'BS Software Engineering';
      if (newDept === 'Artificial Intelligence') return p.name === 'BS Artificial Intelligence';
      return false;
    });

    const nextDeg = matchedProgs.length > 0
      ? matchedProgs[0].name
      : newDept === 'Software Engineering'
      ? 'BS Software Engineering'
      : newDept === 'Artificial Intelligence'
      ? 'BS Artificial Intelligence'
      : 'BS Computer Science';

    setDegree(nextDeg);
    if (rollNumber) {
      setRollNumber(formatRollNumber(rollNumber, nextDeg));
    }
  };

  const handleDegreeChange = (newDeg: string) => {
    setDegree(newDeg);
    const progMatch = programs.find((p) => p.name.toLowerCase() === newDeg.toLowerCase());
    if (progMatch?.department_id) {
      const dMatch = departments.find((d) => d.id === progMatch.department_id);
      if (dMatch) setDepartment(dMatch.name);
    }
    if (rollNumber) {
      setRollNumber(formatRollNumber(rollNumber, newDeg));
    }
  };

  // Sync state if currentUser changes
  React.useEffect(() => {
    if (currentUser) {
      setPhone(currentUser.phone || '');
      setDepartment(currentUser.department);
      setDegree(currentUser.degree);
      setRollNumber(currentUser.rollNumber);
      setSemester(currentUser.semester);
      setSection(currentUser.section);
      setAdmissionBatch(currentUser.admissionBatch);
      setExpectedGraduationYear(currentUser.expectedGraduationYear || 2029);
    }
  }, [currentUser]);

  // Password change state
  const [showPasswordSection, setShowPasswordSection] = useState(false);
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  if (!currentUser) {
    return (
      <div className="bg-white rounded-3xl p-12 text-center border border-slate-200/80 shadow-sm max-w-lg mx-auto">
        <div className="w-16 h-16 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-4">
          <User size={32} />
        </div>
        <h2 className="text-xl font-bold text-slate-900">Student Sign In Required</h2>
        <p className="text-xs text-slate-500 mt-2 mb-6">
          Sign in or create your student account with your Peshawar roll number to access and edit your academic profile.
        </p>
        <button
          onClick={() => openAuthModal('signin')}
          className="px-6 py-2.5 bg-[#0F172A] text-white text-xs font-bold rounded-xl shadow-md hover:bg-slate-800 transition-all"
        >
          Sign In to CampusHub
        </button>
      </div>
    );
  }

  // Get enrolled courses based on user's saved academic profile using normalized matching
  const enrolledClasses: TimetableEntry[] = getStudentEnrolledClasses(timetable, currentUser);

  // Unique courses
  const uniqueCourses = Array.from(
    new Map(enrolledClasses.map((item) => [item.courseCode, item])).values()
  );

  const totalCredits = uniqueCourses.reduce((sum, c) => sum + c.creditHours, 0);

  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    if (showPasswordSection && newPassword) {
      if (newPassword.length < 6) {
        setMessage({ type: 'error', text: 'Password must be at least 6 characters.' });
        return;
      }
      if (newPassword !== confirmPassword) {
        setMessage({ type: 'error', text: 'New passwords do not match.' });
        return;
      }
    }

    setIsSaving(true);
    try {
      const result = await updateProfile({
        phone: phone.trim(),
        rollNumber: formatRollNumber(rollNumber, degree),
        department,
        degree,
        semester,
        section,
        admissionBatch,
        expectedGraduationYear: Number(expectedGraduationYear) || 2029,
        ...(newPassword ? { password: newPassword } : {})
      });

      if (!result.success) {
        setMessage({ type: 'error', text: result.error || 'Failed to update profile.' });
        return;
      }

      setIsEditing(false);
      setShowPasswordSection(false);
      setNewPassword('');
      setConfirmPassword('');
      setMessage({ type: 'success', text: 'Student profile updated in Supabase successfully. Your enrolled classes and timetable have refreshed!' });
      setTimeout(() => setMessage(null), 4000);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* 1. Header Banner */}
      <div className="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#C5A059] mb-1">
            <GraduationCap size={15} />
            <span>Academic Identity & Records</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-[#0F172A] tracking-tight">
            Student Profile
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
            Verified university enrollment record, contact information, and enrolled coursework.
          </p>
        </div>

        <div className="flex items-center gap-2">
          {!isEditing ? (
            <button
              onClick={() => setIsEditing(true)}
              className="px-4 py-2 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all shadow-sm flex items-center gap-1.5"
            >
              <Edit2 size={13} className="text-[#C5A059]" />
              <span>Edit Allowed Fields</span>
            </button>
          ) : (
            <button
              onClick={() => setIsEditing(false)}
              className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition-all flex items-center gap-1.5"
            >
              <X size={13} />
              <span>Cancel</span>
            </button>
          )}

          <button
            onClick={signOut}
            className="px-3.5 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5"
          >
            <LogOut size={13} />
            <span className="hidden sm:inline">Sign Out</span>
          </button>
        </div>
      </div>

      {message && (
        <div
          className={`p-4 rounded-2xl text-xs font-bold flex items-center gap-2 ${
            message.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
              : 'bg-rose-50 text-rose-800 border border-rose-200'
          }`}
        >
          {message.type === 'success' ? <Check size={16} /> : <AlertCircle size={16} />}
          <span>{message.text}</span>
        </div>
      )}

      {/* 2. Registration Fields Information Card */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/60 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-[#0F172A] text-[#C5A059] flex items-center justify-center font-bold text-lg shadow-sm">
              {currentUser.firstName[0]}
              {currentUser.lastName[0]}
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">
                {currentUser.firstName} {currentUser.lastName}
              </h2>
              <div className="flex items-center gap-2 text-xs text-slate-500 mt-0.5">
                <span className="font-mono font-bold text-slate-800 bg-slate-200/70 px-2 py-0.5 rounded">
                  {formatUserRollNumber(currentUser)}
                </span>
                <span>•</span>
                <span>{currentUser.degree}</span>
              </div>
            </div>
          </div>

          <span className="text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 border border-emerald-200 hidden sm:inline-block">
            Verified Student
          </span>
        </div>

        {/* Form / Details Display */}
        <form onSubmit={handleSaveProfile} className="p-6 space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* First Name (Fixed) */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block">
                First Name
              </label>
              <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                {currentUser.firstName}
              </p>
            </div>

            {/* Last Name (Fixed) */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block">
                Last Name
              </label>
              <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                {currentUser.lastName}
              </p>
            </div>

            {/* Roll Number */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Roll Number</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <RollNumberInput
                  degree={degree}
                  value={rollNumber}
                  onChange={(full) => setRollNumber(full)}
                  placeholder="25-048"
                />
              ) : (
                <p className="text-sm font-mono font-bold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {formatUserRollNumber(currentUser)}
                </p>
              )}
            </div>

            {/* Email (Fixed) */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block">
                Email Address
              </label>
              <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100 truncate">
                {currentUser.email}
              </p>
            </div>

            {/* Department */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Department</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <select
                  value={department}
                  onChange={(e) => handleDepartmentChange(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  {departmentOptions.map((d) => (
                    <option key={d} value={d}>
                      {d}
                    </option>
                  ))}
                </select>
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {currentUser.department}
                </p>
              )}
            </div>

            {/* Degree / Program */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Degree / Program</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <select
                  value={degree}
                  onChange={(e) => handleDegreeChange(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  {degreeOptions.map((deg) => (
                    <option key={deg} value={deg}>
                      {deg}
                    </option>
                  ))}
                </select>
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {currentUser.degree}
                </p>
              )}
            </div>

            {/* Admission Batch */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Admission Batch</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <select
                  value={admissionBatch}
                  onChange={(e) => {
                    const val = e.target.value;
                    setAdmissionBatch(val);
                    const match = val.match(/(\d{4})/);
                    if (match) {
                      const yr = parseInt(match[1]);
                      setExpectedGraduationYear(yr + 4);
                    }
                  }}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  {batchOptions.map((b) => (
                    <option key={b} value={b}>
                      {b}
                    </option>
                  ))}
                </select>
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {currentUser.admissionBatch}
                </p>
              )}
            </div>

            {/* Expected Graduation Year */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Expected Graduation</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <input
                  type="number"
                  min="2020"
                  max="2040"
                  value={expectedGraduationYear}
                  onChange={(e) => setExpectedGraduationYear(Number(e.target.value))}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                />
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {currentUser.expectedGraduationYear || '2029'}
                </p>
              )}
            </div>

            {/* Semester */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Semester</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <select
                  value={semester}
                  onChange={(e) => setSemester(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  {semesterOptions.map((s) => (
                    <option key={s} value={s}>
                      {s} Semester
                    </option>
                  ))}
                </select>
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {currentUser.semester} Semester
                </p>
              )}
            </div>

            {/* Section */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Section</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <select
                  value={section}
                  onChange={(e) => setSection(e.target.value)}
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  {sectionOptions.map((sec) => (
                    <option key={sec} value={sec}>
                      Section {sec}
                    </option>
                  ))}
                </select>
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  Section {currentUser.section}
                </p>
              )}
            </div>

            {/* Phone Number (Allowed to edit) */}
            <div className="space-y-1">
              <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center justify-between">
                <span>Phone Number</span>
                {isEditing && <span className="text-emerald-700 text-[10px]">Editable</span>}
              </label>
              {isEditing ? (
                <input
                  type="text"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+92 300 1234567"
                  className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs font-semibold text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                />
              ) : (
                <p className="text-sm font-semibold text-slate-800 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100">
                  {currentUser.phone || 'Not specified'}
                </p>
              )}
            </div>

            {/* Password (Masked with option to change) */}
            <div className="space-y-1 sm:col-span-2 lg:col-span-3 pt-2">
              <div className="flex items-center justify-between">
                <label className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
                  Account Password
                </label>
                {isEditing && (
                  <button
                    type="button"
                    onClick={() => setShowPasswordSection(!showPasswordSection)}
                    className="text-xs font-semibold text-[#C5A059] hover:underline"
                  >
                    {showPasswordSection ? 'Keep Current Password' : 'Change Password'}
                  </button>
                )}
              </div>

              {!showPasswordSection ? (
                <p className="text-sm font-mono text-slate-500 bg-slate-50 px-3 py-2 rounded-xl border border-slate-100 flex items-center justify-between">
                  <span>••••••••••••</span>
                  <span className="text-[11px] font-sans font-medium text-slate-400">Encrypted</span>
                </p>
              ) : (
                <div className="p-4 rounded-2xl bg-amber-50/50 border border-amber-200/80 space-y-3">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="text-xs font-semibold text-slate-700 mb-1 block">
                        New Password
                      </label>
                      <input
                        type="password"
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        placeholder="Minimum 6 characters"
                        className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                    </div>
                    <div>
                      <label className="text-xs font-semibold text-slate-700 mb-1 block">
                        Confirm New Password
                      </label>
                      <input
                        type="password"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        placeholder="Re-enter password"
                        className="w-full px-3 py-2 bg-white border border-slate-300 rounded-xl text-xs text-slate-900 focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                      />
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {isEditing && (
            <div className="flex items-center justify-end gap-2 pt-4 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setIsEditing(false)}
                className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition-all"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={isSaving}
                className="px-5 py-2 bg-[#0F172A] hover:bg-slate-800 disabled:opacity-60 text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center gap-1.5"
              >
                {isSaving ? (
                  <Loader2 size={14} className="animate-spin text-[#C5A059]" />
                ) : (
                  <Save size={14} className="text-[#C5A059]" />
                )}
                <span>{isSaving ? 'Saving to Supabase...' : 'Save Profile Changes'}</span>
              </button>
            </div>
          )}
        </form>
      </div>

      {/* 3. Enrolled Courses List */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-indigo-50 text-indigo-700 flex items-center justify-center font-bold">
              <BookOpen size={16} />
            </div>
            <div>
              <h3 className="text-base font-bold text-slate-900">
                Enrolled Courses ({uniqueCourses.length})
              </h3>
              <p className="text-xs text-slate-500">
                {formatStudentAcademicContext(currentUser)}
              </p>
            </div>
          </div>

          <span className="text-xs font-bold text-slate-700 bg-slate-100 px-3 py-1 rounded-full border border-slate-200">
            Total Credits: {totalCredits} Cr
          </span>
        </div>

        <div className="divide-y divide-slate-100">
          {uniqueCourses.map((course) => (
            <div
              key={course.courseCode}
              className="p-5 hover:bg-slate-50/70 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
            >
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-bold text-slate-900 text-sm">
                    {course.courseName}
                  </span>
                  <span className="font-mono text-xs font-bold bg-slate-100 text-slate-700 px-2 py-0.5 rounded border border-slate-200">
                    {course.courseCode}
                  </span>
                </div>
                <p className="text-slate-500 mt-1">
                  Instructor: <strong className="text-slate-800">{course.teacherName}</strong> • {course.department}
                </p>
              </div>

              <div className="flex items-center gap-3">
                <span className="text-xs font-semibold text-slate-600 bg-slate-100 px-2.5 py-1 rounded-lg">
                  {course.creditHours} Credit Hours
                </span>
                <span className="text-xs font-bold uppercase text-emerald-800 bg-emerald-50 px-2.5 py-1 rounded-lg border border-emerald-200">
                  {course.type}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 4. Saved Timetable Snapshot */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Calendar size={18} className="text-[#C5A059]" />
            <span>Saved Academic Timetable</span>
          </h3>
          <p className="text-xs text-slate-500 mt-0.5">
            Your customized weekly schedule is synced across Peshawar campus days (Monday through Friday).
          </p>
        </div>

        <button
          onClick={() => setActiveTab('timetable')}
          className="px-5 py-2.5 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold shadow-sm transition-all flex items-center gap-1.5 shrink-0"
        >
          <span>View Full Weekly Timetable</span>
        </button>
      </div>
    </div>
  );
};
