import React, { useState } from 'react';
import {
  Calendar,
  Clock,
  DoorOpen,
  Users,
  Search,
  RotateCcw,
  Printer,
  Sparkles,
  SlidersHorizontal,
  Edit3,
  GraduationCap,
  Building2,
  BookOpen,
  ArrowRight,
  ShieldCheck
} from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { useAuth } from '../../context/AuthContext';
import { DayOfWeek, TimetableEntry } from '../../types';
import { DEPARTMENTS, DEGREES, SEMESTERS, SECTIONS, BATCHES } from '../../data/mockData';
import { formatRoomDisplay } from '../../utils/roomUtils';
import { getStudentEnrolledClasses, formatStudentAcademicContext } from '../../utils/studentScheduleUtils';
import { formatUserRollNumber } from '../../utils/rollNumberUtils';

const DAYS: DayOfWeek[] = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

export const TimetablePage: React.FC = () => {
  const {
    timetable,
    setSelectedRoom,
    setSelectedTeacher,
    setActiveTab,
    rooms,
    teachers,
    departments,
    programs,
    semesters,
    sections,
    batches
  } = useApp();
  const { currentUser, openAuthModal } = useAuth();

  const departmentOptions = departments.length > 0 ? departments.map((d) => d.name) : DEPARTMENTS;
  const degreeOptions = programs.length > 0 ? programs.map((p) => p.name) : DEGREES;
  const semesterOptions = semesters.length > 0 ? semesters.map((s) => s.name) : SEMESTERS;
  const sectionOptions = sections.length > 0 ? sections.map((s) => s.name) : SECTIONS;
  const batchOptions = batches.length > 0 ? batches.map((b) => b.name) : BATCHES;

  // Mode: 'enrolled' for student's auto-filtered classes, 'university' for campus-wide directory / admin
  const [viewMode, setViewMode] = useState<'enrolled' | 'university'>(currentUser ? 'enrolled' : 'university');

  // Selected Day tab ('All' for My Weekly Timetable or specific day)
  const [selectedDay, setSelectedDay] = useState<DayOfWeek | 'All'>('Monday');

  // University / Admin Directory Filters
  const [deptFilter, setDeptFilter] = useState<string>('All');
  const [programFilter, setProgramFilter] = useState<string>('All');
  const [semFilter, setSemFilter] = useState<string>('All');
  const [secFilter, setSecFilter] = useState<string>('All');
  const [batchFilter, setBatchFilter] = useState<string>('All');
  const [searchQuery, setSearchQuery] = useState<string>('');

  const resetAdminFilters = () => {
    setSelectedDay('Monday');
    setDeptFilter('All');
    setProgramFilter('All');
    setSemFilter('All');
    setSecFilter('All');
    setBatchFilter('All');
    setSearchQuery('');
  };

  // Base list of classes according to viewMode
  // If in 'enrolled' mode, automatically use the student's saved academic profile
  const baseEntries: TimetableEntry[] = (viewMode === 'enrolled' && currentUser)
    ? getStudentEnrolledClasses(timetable, currentUser)
    : timetable;

  // Filter base entries by day, admin filters (if university mode), and search query
  const filteredEntries = baseEntries.filter((entry) => {
    // Day filter
    if (selectedDay !== 'All' && entry.day !== selectedDay) return false;

    // In university mode, apply manual admin filters
    if (viewMode === 'university') {
      if (deptFilter !== 'All' && entry.department !== deptFilter) return false;
      if (semFilter !== 'All' && entry.semester !== semFilter) return false;
      if (secFilter !== 'All' && entry.section !== secFilter) return false;
      if (batchFilter !== 'All' && entry.batch !== batchFilter) return false;
    }

    // Search query applies within the currently active view
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const match =
        entry.courseName.toLowerCase().includes(q) ||
        entry.courseCode.toLowerCase().includes(q) ||
        entry.teacherName.toLowerCase().includes(q) ||
        entry.classroomNumber.toLowerCase().includes(q);
      if (!match) return false;
    }

    return true;
  });

  // Unique enrolled courses count and credit hours
  const studentTotalCourses = (viewMode === 'enrolled' && currentUser)
    ? Array.from(new Map(baseEntries.map((c) => [c.courseCode, c])).values())
    : [];
  const studentTotalCredits = studentTotalCourses.reduce((sum, c) => sum + c.creditHours, 0);

  // Group by day for 'All 5 Days' / Weekly Timetable
  const entriesByDay: Record<DayOfWeek, TimetableEntry[]> = {
    Monday: filteredEntries.filter((e) => e.day === 'Monday'),
    Tuesday: filteredEntries.filter((e) => e.day === 'Tuesday'),
    Wednesday: filteredEntries.filter((e) => e.day === 'Wednesday'),
    Thursday: filteredEntries.filter((e) => e.day === 'Thursday'),
    Friday: filteredEntries.filter((e) => e.day === 'Friday')
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* 1. Top Page Header */}
      <div className="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#C5A059] mb-1">
            <Calendar size={15} />
            <span>Academic Schedule • Fall 2026 • Peshawar Campus</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-[#0F172A] tracking-tight">
            {viewMode === 'enrolled' && currentUser ? 'My Enrolled Classes' : 'Campus Timetable'}
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
            {viewMode === 'enrolled' && currentUser
              ? 'Automatically synchronized with your verified student academic profile.'
              : 'University-wide directory of lectures, classroom allocations, and faculty timetables.'}
          </p>
        </div>

        {/* Header Actions */}
        <div className="flex flex-wrap items-center gap-2">
          {currentUser && (
            <div className="flex items-center bg-slate-100 p-1 rounded-2xl border border-slate-200">
              <button
                onClick={() => setViewMode('enrolled')}
                className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ${
                  viewMode === 'enrolled'
                    ? 'bg-[#0F172A] text-white shadow-sm'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <Sparkles size={13} className={viewMode === 'enrolled' ? 'text-[#C5A059]' : 'text-slate-400'} />
                <span>My Enrolled Classes</span>
              </button>

              <button
                onClick={() => setViewMode('university')}
                className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ${
                  viewMode === 'university'
                    ? 'bg-[#0F172A] text-white shadow-sm'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <SlidersHorizontal size={13} className={viewMode === 'university' ? 'text-[#C5A059]' : 'text-slate-400'} />
                <span>University Directory (Admin)</span>
              </button>
            </div>
          )}

          <button
            onClick={handlePrint}
            className="px-3.5 py-2 rounded-xl text-xs font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-all flex items-center gap-1.5"
            title="Print or export current timetable"
          >
            <Printer size={15} />
            <span className="hidden sm:inline">Print Schedule</span>
          </button>
        </div>
      </div>

      {/* 2. Student Context Summary Card (Read-only Academic Information Header) */}
      {viewMode === 'enrolled' && currentUser ? (
        <div className="bg-gradient-to-r from-[#0F172A] via-[#1E293B] to-[#0F172A] text-white rounded-3xl p-6 shadow-lg border border-slate-800 relative overflow-hidden">
          <div className="absolute right-0 top-0 bottom-0 w-1/3 bg-gradient-to-l from-white/5 to-transparent pointer-events-none" />
          
          <div className="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
            <div className="space-y-3">
              <div className="flex flex-wrap items-center gap-2">
                <span className="px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-400/30 text-[11px] font-bold uppercase tracking-wider flex items-center gap-1.5">
                  <ShieldCheck size={13} />
                  <span>Auto-Filtered to Profile</span>
                </span>
                <span className="text-slate-400 text-xs font-medium">
                  No manual filters needed
                </span>
              </div>

              {/* Exact Read-Only Format specified by user */}
              <div className="bg-slate-900/90 rounded-2xl p-4 border border-slate-700/80 backdrop-blur-sm">
                <div className="text-[11px] uppercase tracking-wider text-[#C5A059] font-bold mb-1">
                  My Enrolled Classes
                </div>
                <div className="text-sm sm:text-base font-bold text-white tracking-wide">
                  {currentUser.degree} · Semester {currentUser.semester.replace(/[^0-9]/g, '') || currentUser.semester} · Section {currentUser.section} · {currentUser.admissionBatch}
                </div>
                <div className="mt-2.5 pt-2 border-t border-slate-800/80 text-[11px] text-slate-300 font-mono flex flex-wrap items-center gap-x-2.5 gap-y-1">
                  <span className="text-[#C5A059]">Department:</span>
                  <strong className="text-white font-sans">{currentUser.department}</strong>
                  <span className="text-slate-600">|</span>
                  <span className="text-[#C5A059]">Section:</span>
                  <strong className="text-emerald-400 font-sans">Section {currentUser.section}</strong>
                  <span className="text-slate-600">|</span>
                  <span className="text-[#C5A059]">Roll No:</span>
                  <strong className="text-amber-200 font-sans">{formatUserRollNumber(currentUser)}</strong>
                </div>
              </div>

              <p className="text-xs text-slate-400">
                Logged in as <strong className="text-slate-200">{currentUser.firstName} {currentUser.lastName}</strong> (Roll No: <span className="font-mono text-amber-200">{formatUserRollNumber(currentUser)}</span>) • Expected Graduation: {currentUser.expectedGraduationYear || '2029'}
              </p>
            </div>

            {/* Quick stats & Profile update action */}
            <div className="flex flex-row lg:flex-col sm:items-end justify-between gap-4 pt-2 lg:pt-0 border-t lg:border-t-0 border-slate-800">
              <div className="text-left lg:text-right">
                <div className="text-xl font-extrabold text-[#C5A059]">
                  {studentTotalCourses.length} Courses • {studentTotalCredits} Credits
                </div>
                <div className="text-xs text-slate-400 mt-0.5">
                  {baseEntries.length} lecture & lab slots across the week
                </div>
              </div>

              <button
                onClick={() => setActiveTab('profile')}
                className="px-4 py-2 rounded-xl text-xs font-bold bg-[#FAF9F6] text-[#0F172A] hover:bg-white transition-all flex items-center gap-1.5 shadow-sm shrink-0"
              >
                <Edit3 size={13} className="text-[#C5A059]" />
                <span>Edit Academic Profile</span>
              </button>
            </div>
          </div>
        </div>
      ) : !currentUser ? (
        /* Guest prompt to sign in for auto-filtering */
        <div className="bg-amber-50/70 border border-amber-200/80 rounded-3xl p-5 sm:p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3.5">
            <div className="w-10 h-10 rounded-2xl bg-amber-100 text-amber-800 flex items-center justify-center font-bold shrink-0">
              <GraduationCap size={20} />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">
                Are you a Peshawar student?
              </h3>
              <p className="text-xs text-slate-600 mt-0.5">
                Sign in with your student account to automatically view &ldquo;My Enrolled Classes&rdquo; without repeatedly selecting Department, Program, Semester, Section, or Batch.
              </p>
            </div>
          </div>

          <button
            onClick={() => openAuthModal('signin')}
            className="px-4 py-2 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold shadow-sm transition-all whitespace-nowrap"
          >
            Sign In for Auto-Filter
          </button>
        </div>
      ) : null}

      {/* 3. Toolbar: Day Selector & Search Controls */}
      <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-sm space-y-4">
        {/* Day Selector Tabs */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-1.5 overflow-x-auto pb-1">
            {DAYS.map((day) => {
              const count = baseEntries.filter((e) => e.day === day).length;
              const isSelected = selectedDay === day;
              return (
                <button
                  key={day}
                  onClick={() => setSelectedDay(day)}
                  className={`px-4 py-2 rounded-xl text-xs font-bold tracking-tight whitespace-nowrap transition-all flex items-center gap-2 ${
                    isSelected
                      ? 'bg-[#0F172A] text-white shadow-md'
                      : 'bg-slate-100 text-slate-600 hover:bg-slate-200/80'
                  }`}
                >
                  <span>{day}</span>
                  <span
                    className={`text-[10px] px-1.5 py-0.2 rounded-full ${
                      isSelected ? 'bg-slate-800 text-amber-200' : 'bg-slate-200 text-slate-500'
                    }`}
                  >
                    {count}
                  </span>
                </button>
              );
            })}
            <button
              onClick={() => setSelectedDay('All')}
              className={`px-4 py-2 rounded-xl text-xs font-bold tracking-tight whitespace-nowrap transition-all flex items-center gap-1.5 ${
                selectedDay === 'All'
                  ? 'bg-[#0F172A] text-white shadow-md'
                  : 'bg-slate-100 text-slate-600 hover:bg-slate-200/80'
              }`}
            >
              <Calendar size={13} />
              <span>{viewMode === 'enrolled' ? 'My Weekly Timetable' : 'All 5 Days'}</span>
              <span
                className={`text-[10px] px-1.5 py-0.2 rounded-full ${
                  selectedDay === 'All' ? 'bg-slate-800 text-amber-200' : 'bg-slate-200 text-slate-500'
                }`}
              >
                {baseEntries.length}
              </span>
            </button>
          </div>

          {/* Quick Search within currently filtered classes */}
          <div className="relative w-full sm:w-72">
            <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={viewMode === 'enrolled' ? "Search enrolled courses or instructors..." : "Search courses, rooms, teachers..."}
              className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-800 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-slate-600"
              >
                ×
              </button>
            )}
          </div>
        </div>

        {/* 4. University / Admin Filter Dropdowns Row (ONLY rendered in University / Admin mode) */}
        {viewMode === 'university' && (
          <div className="pt-4 border-t border-slate-100 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-1.5">
                <SlidersHorizontal size={13} />
                <span>Admin / University Directory Filters</span>
              </span>
              <button
                onClick={resetAdminFilters}
                title="Reset all filters"
                className="text-xs text-[#C5A059] font-bold hover:underline flex items-center gap-1"
              >
                <RotateCcw size={12} />
                <span>Reset Filters</span>
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
              {/* Department Filter */}
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
                  Department
                </label>
                <select
                  value={deptFilter}
                  onChange={(e) => setDeptFilter(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  <option value="All">All Departments</option>
                  {departmentOptions.map((d) => (
                    <option key={d} value={d}>
                      {d}
                    </option>
                  ))}
                </select>
              </div>

              {/* Program / Degree Filter */}
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
                  Program / Degree
                </label>
                <select
                  value={programFilter}
                  onChange={(e) => setProgramFilter(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  <option value="All">All Programs</option>
                  {degreeOptions.map((deg) => (
                    <option key={deg} value={deg}>
                      {deg}
                    </option>
                  ))}
                </select>
              </div>

              {/* Semester Filter */}
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
                  Semester
                </label>
                <select
                  value={semFilter}
                  onChange={(e) => setSemFilter(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  <option value="All">All Semesters</option>
                  {semesterOptions.map((s) => (
                    <option key={s} value={s}>
                      {s} Semester
                    </option>
                  ))}
                </select>
              </div>

              {/* Section Filter */}
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
                  Section
                </label>
                <select
                  value={secFilter}
                  onChange={(e) => setSecFilter(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
                >
                  <option value="All">All Sections (A, B)</option>
                  {sectionOptions.map((sec) => (
                    <option key={sec} value={sec}>
                      Section {sec}
                    </option>
                  ))}
                </select>
              </div>

              {/* Batch Filter */}
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
                  Admission Batch
                </label>
                <select
                  value={batchFilter}
                  onChange={(e) => setBatchFilter(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-800 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none truncate"
                >
                  <option value="All">All Batches</option>
                  {batchOptions.map((b) => (
                    <option key={b} value={b}>
                      {b}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Active Admin Filter Pills */}
            {(deptFilter !== 'All' || semFilter !== 'All' || secFilter !== 'All' || batchFilter !== 'All' || programFilter !== 'All') && (
              <div className="flex flex-wrap items-center gap-2 pt-2 text-xs">
                <span className="text-slate-500 font-medium">Active Admin filters:</span>
                {deptFilter !== 'All' && (
                  <span className="px-2.5 py-1 rounded-full bg-slate-200 text-slate-800 font-semibold flex items-center gap-1">
                    Dept: {deptFilter}
                    <button onClick={() => setDeptFilter('All')} className="text-slate-500 hover:text-slate-900">×</button>
                  </span>
                )}
                {programFilter !== 'All' && (
                  <span className="px-2.5 py-1 rounded-full bg-slate-200 text-slate-800 font-semibold flex items-center gap-1">
                    Program: {programFilter}
                    <button onClick={() => setProgramFilter('All')} className="text-slate-500 hover:text-slate-900">×</button>
                  </span>
                )}
                {semFilter !== 'All' && (
                  <span className="px-2.5 py-1 rounded-full bg-slate-200 text-slate-800 font-semibold flex items-center gap-1">
                    Sem: {semFilter}
                    <button onClick={() => setSemFilter('All')} className="text-slate-500 hover:text-slate-900">×</button>
                  </span>
                )}
                {secFilter !== 'All' && (
                  <span className="px-2.5 py-1 rounded-full bg-slate-200 text-slate-800 font-semibold flex items-center gap-1">
                    Section: {secFilter}
                    <button onClick={() => setSecFilter('All')} className="text-slate-500 hover:text-slate-900">×</button>
                  </span>
                )}
                {batchFilter !== 'All' && (
                  <span className="px-2.5 py-1 rounded-full bg-slate-200 text-slate-800 font-semibold flex items-center gap-1">
                    Batch: {batchFilter}
                    <button onClick={() => setBatchFilter('All')} className="text-slate-500 hover:text-slate-900">×</button>
                  </span>
                )}
                <button
                  onClick={resetAdminFilters}
                  className="text-xs text-[#C5A059] font-bold hover:underline ml-1"
                >
                  Clear all
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* 5. Main Timetable Entries Display */}
      {filteredEntries.length === 0 ? (
        <div className="bg-white rounded-3xl p-12 text-center border border-slate-200/80 shadow-sm max-w-lg mx-auto">
          <div className="w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
            <Calendar size={28} />
          </div>
          <h3 className="text-base font-bold text-slate-900">
            {viewMode === 'enrolled'
              ? 'No classes found for your academic profile'
              : 'No classes match this criteria'}
          </h3>
          <p className="text-xs text-slate-500 mt-1">
            {viewMode === 'enrolled'
              ? 'No classes were found for your selected semester, department, or day. You can update your academic profile to change your semester or section.'
              : 'Try adjusting your department, semester, section, or day filters to view other scheduled lectures.'}
          </p>

          <div className="flex items-center justify-center gap-3 mt-5">
            {viewMode === 'enrolled' && currentUser ? (
              <button
                onClick={() => setActiveTab('profile')}
                className="px-4 py-2 bg-[#0F172A] text-white text-xs font-bold rounded-xl shadow-sm hover:bg-slate-800 transition-all flex items-center gap-1.5"
              >
                <Edit3 size={13} className="text-[#C5A059]" />
                <span>Update Academic Profile</span>
              </button>
            ) : (
              <button
                onClick={resetAdminFilters}
                className="px-4 py-2 bg-[#0F172A] text-white text-xs font-bold rounded-xl shadow-sm hover:bg-slate-800 transition-all"
              >
                Reset Filters
              </button>
            )}
          </div>
        </div>
      ) : selectedDay !== 'All' ? (
        /* Single Day List / Table */
        <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="p-5 border-b border-slate-100 bg-slate-50/60 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-[#047857]" />
              <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
                {selectedDay} Schedule ({filteredEntries.length} Classes)
              </h2>
            </div>
            <span className="text-xs font-medium text-slate-500">
              {viewMode === 'enrolled' && currentUser
                ? `${currentUser.degree} • Sec ${currentUser.section}`
                : 'Peshawar Academic Roster'}
            </span>
          </div>

          <div className="divide-y divide-slate-100">
            {filteredEntries.map((item) => (
              <div
                key={item.id}
                className="p-5 hover:bg-slate-50/70 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4 group"
              >
                {/* Time & Type */}
                <div className="md:w-48 shrink-0">
                  <div className="flex items-center gap-1.5 text-slate-900 font-mono font-bold text-sm">
                    <Clock size={15} className="text-[#C5A059]" />
                    <span>{item.startTime} – {item.endTime}</span>
                  </div>
                  <div className="flex items-center gap-1.5 mt-1">
                    <span
                      className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md ${
                        item.type === 'Lab'
                          ? 'bg-amber-100 text-amber-900'
                          : item.type === 'Tutorial'
                          ? 'bg-purple-100 text-purple-900'
                          : 'bg-emerald-100 text-emerald-900'
                      }`}
                    >
                      {item.type}
                    </span>
                    <span className="text-[11px] text-slate-500 font-medium">
                      {item.creditHours} Credits
                    </span>
                  </div>
                </div>

                {/* Course Name, Code, Dept, Sem, Sec */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <h3 className="text-sm sm:text-base font-extrabold text-slate-900 group-hover:text-indigo-950">
                      {item.courseName}
                    </h3>
                    <span className="font-mono text-xs font-bold text-slate-600 bg-slate-100 px-2 py-0.5 rounded border border-slate-200">
                      {item.courseCode}
                    </span>
                  </div>
                  <div className="flex flex-wrap items-center gap-y-1 gap-x-3 text-xs text-slate-500 mt-1">
                    <span>Dept: <strong className="text-slate-700">{item.department}</strong></span>
                    <span>•</span>
                    <span>Sem: <strong className="text-slate-700">{item.semester}</strong></span>
                    <span>•</span>
                    <span>Sec: <strong className="text-slate-700">{item.section}</strong></span>
                    <span>•</span>
                    <span className="text-slate-400 font-mono text-[11px]">{item.batch}</span>
                  </div>
                </div>

                {/* Classroom & Teacher Interactive Pills */}
                <div className="flex flex-wrap items-center gap-2.5 shrink-0 pt-2 md:pt-0">
                  <button
                    onClick={() => {
                      const r = rooms.find((rm) => rm.roomNumber === item.classroomNumber);
                      if (r) setSelectedRoom(r);
                      setActiveTab('rooms');
                    }}
                    className="px-3 py-1.5 rounded-xl bg-slate-100 hover:bg-emerald-50 hover:text-emerald-900 hover:border-emerald-200 border border-slate-200 text-xs font-semibold text-slate-800 transition-all flex items-center gap-1.5"
                    title="Inspect classroom directory"
                  >
                    <DoorOpen size={14} className="text-emerald-600" />
                    <span>{formatRoomDisplay(item.classroomNumber)}</span>
                  </button>

                  <button
                    onClick={() => {
                      const t = teachers.find((tch) => tch.id === item.teacherId);
                      if (t) setSelectedTeacher(t);
                      setActiveTab('teachers');
                    }}
                    className="px-3 py-1.5 rounded-xl bg-slate-100 hover:bg-indigo-50 hover:text-indigo-900 hover:border-indigo-200 border border-slate-200 text-xs font-semibold text-slate-800 transition-all flex items-center gap-1.5"
                    title="View teacher profile"
                  >
                    <Users size={14} className="text-indigo-600" />
                    <span>{item.teacherName}</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        /* All 5 Days / Weekly Timetable View */
        <div className="space-y-6">
          <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200/80 flex items-center justify-between text-xs text-slate-600">
            <span className="font-semibold text-slate-900">
              {viewMode === 'enrolled' ? 'Weekly Academic Schedule (Monday – Friday)' : 'Complete Campus Weekly Timetable'}
            </span>
            <span>{filteredEntries.length} total classes scheduled</span>
          </div>

          {DAYS.map((day) => {
            const dayEntries = entriesByDay[day];
            if (dayEntries.length === 0) return null;
            return (
              <div
                key={day}
                className="bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden"
              >
                <div className="p-4 sm:p-5 bg-slate-50/80 border-b border-slate-100 flex items-center justify-between">
                  <div className="flex items-center gap-2.5">
                    <div className="w-7 h-7 rounded-lg bg-[#0F172A] text-[#C5A059] flex items-center justify-center font-bold text-xs">
                      {day.slice(0, 2)}
                    </div>
                    <h3 className="font-bold text-sm text-slate-900">{day}</h3>
                  </div>
                  <span className="text-xs font-semibold text-slate-500">
                    {dayEntries.length} Classes
                  </span>
                </div>

                <div className="divide-y divide-slate-100">
                  {dayEntries.map((item) => (
                    <div
                      key={item.id}
                      className="p-4 sm:p-5 hover:bg-slate-50/60 transition-all flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs"
                    >
                      <div className="md:w-44 shrink-0 font-mono font-bold text-slate-900">
                        {item.startTime} – {item.endTime}
                        <span className="block text-[10px] font-sans font-medium text-slate-500 mt-0.5">
                          {item.type} • {item.creditHours} cr
                        </span>
                      </div>

                      <div className="flex-1">
                        <span className="font-bold text-slate-900 text-sm block">
                          {item.courseName}
                        </span>
                        <span className="text-[11px] text-slate-500">
                          {item.courseCode} • {item.department} (Sem {item.semester}, Sec {item.section})
                        </span>
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => {
                            const r = rooms.find((rm) => rm.roomNumber === item.classroomNumber);
                            if (r) setSelectedRoom(r);
                            setActiveTab('rooms');
                          }}
                          className="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-slate-200 font-mono font-medium text-slate-700 text-xs"
                        >
                          {formatRoomDisplay(item.classroomNumber)}
                        </button>
                        <button
                          onClick={() => {
                            const t = teachers.find((tch) => tch.id === item.teacherId);
                            if (t) setSelectedTeacher(t);
                            setActiveTab('teachers');
                          }}
                          className="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-slate-200 font-medium text-slate-700 text-xs"
                        >
                          {item.teacherName}
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
