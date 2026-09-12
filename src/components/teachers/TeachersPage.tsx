import React, { useState } from 'react';
import {
  Users,
  Search,
  Clock,
  BookOpen,
  ArrowRight,
  Sparkles,
  Calendar,
  CheckCircle2
} from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { TeacherDetailModal } from './TeacherDetailModal';
import { DEPARTMENTS } from '../../data/mockData';
import {
  UNIVERSITY_OPERATING_HOURS,
  getTeacherClasses,
  getTeacherClassesForDay
} from '../../utils/teacherUtils';

export const TeachersPage: React.FC = () => {
  const { teachers, timetable, selectedTeacher, setSelectedTeacher } = useApp();

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDept, setSelectedDept] = useState('All');

  const filteredTeachers = teachers.filter((teacher) => {
    if (selectedDept !== 'All' && teacher.department !== selectedDept) return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const match =
        teacher.name.toLowerCase().includes(q) ||
        teacher.department.toLowerCase().includes(q) ||
        teacher.specialization.toLowerCase().includes(q) ||
        teacher.courses.some((c) => c.toLowerCase().includes(q));
      if (!match) return false;
    }
    return true;
  });

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Top Banner with University Operating Hours */}
      <div className="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-indigo-600 mb-1">
            <Users size={15} />
            <span>Academic Faculty & Staff</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-[#0F172A] tracking-tight">
            Teacher Directory
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
            Faculty members, official university operating hours, and active teaching schedules.
          </p>
        </div>

        {/* University Operating Hours Badge */}
        <div className="flex flex-col items-start md:items-end gap-1.5 p-3.5 bg-slate-50 rounded-2xl border border-slate-200/80 text-xs">
          <div className="flex items-center gap-1.5 text-slate-900 font-bold">
            <Clock size={14} className="text-[#C5A059]" />
            <span>University Operating Hours</span>
          </div>
          <div className="text-[11px] text-slate-600 font-medium">
            <span className="font-semibold text-slate-800">Mon–Thu:</span> 8:00 AM – 4:00 PM
            <span className="mx-1.5 text-slate-300">|</span>
            <span className="font-semibold text-slate-800">Fri:</span> 8:00 AM – 3:00 PM
          </div>
        </div>
      </div>

      {/* Filter Toolbar */}
      <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-sm space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          {/* Search Box */}
          <div className="relative sm:col-span-2">
            <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search faculty by name, department, research area, or course..."
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            />
          </div>

          {/* Department Filter */}
          <div>
            <select
              value={selectedDept}
              onChange={(e) => setSelectedDept(e.target.value)}
              className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none truncate"
            >
              <option value="All">All Faculty Departments</option>
              {DEPARTMENTS.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Teachers Grid */}
      {filteredTeachers.length === 0 ? (
        <div className="bg-white rounded-3xl p-12 text-center border border-slate-200/80 shadow-sm">
          <div className="w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
            <Users size={28} />
          </div>
          <h3 className="text-base font-bold text-slate-900">No faculty members found</h3>
          <p className="text-xs text-slate-500 mt-1">
            Try searching for another name or clearing the department filter.
          </p>
          <button
            onClick={() => {
              setSearchQuery('');
              setSelectedDept('All');
            }}
            className="mt-4 px-4 py-2 bg-[#0F172A] text-white text-xs font-bold rounded-xl shadow-sm hover:bg-slate-800 transition-all"
          >
            Reset Search
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredTeachers.map((teacher) => {
            // Check today's teaching classes (Monday as default active weekday)
            const todaysClasses = getTeacherClassesForDay(timetable, teacher, 'Monday');
            const totalScheduledClasses = getTeacherClasses(timetable, teacher).length;

            return (
              <div
                key={teacher.id}
                className="bg-white rounded-3xl border border-slate-200/80 hover:border-slate-300 shadow-sm hover:shadow-md transition-all flex flex-col justify-between overflow-hidden group"
              >
                <div className="p-6">
                  {/* Avatar & Header */}
                  <div className="flex items-start gap-3.5 mb-4">
                    <div className="w-12 h-12 rounded-2xl bg-[#0F172A] text-[#C5A059] flex items-center justify-center font-bold text-base shadow-sm shrink-0">
                      {teacher.name.split(' ').slice(1, 2)[0]?.[0] || teacher.name[0]}
                    </div>
                    <div className="min-w-0 flex-1">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-[#C5A059] block">
                        {teacher.designation}
                      </span>
                      <h3 className="text-base font-bold text-slate-900 group-hover:text-indigo-950 truncate">
                        {teacher.name}
                      </h3>
                      <p className="text-xs text-slate-500 truncate mt-0.5">
                        {teacher.department}
                      </p>
                    </div>
                  </div>

                  {/* University Operating Hours Information */}
                  <div className="space-y-1.5 text-xs text-slate-600 mb-4 bg-slate-50 p-3 rounded-2xl border border-slate-100">
                    <div className="flex items-center gap-2">
                      <Clock size={13} className="text-[#C5A059] shrink-0" />
                      <span className="text-[11px] font-semibold text-slate-800">Campus Availability Hours:</span>
                    </div>
                    <div className="text-[11px] text-slate-600 pl-5">
                      Mon–Thu: 8:00 AM – 4:00 PM <br />
                      Fri: 8:00 AM – 3:00 PM
                    </div>
                  </div>

                  {/* Taught Courses Chips */}
                  <div className="mb-4">
                    <span className="text-[10px] uppercase font-bold text-slate-400 block mb-1.5">
                      Assigned Courses ({teacher.courses.length})
                    </span>
                    <div className="flex flex-wrap gap-1.5">
                      {teacher.courses.map((c) => (
                        <span
                          key={c}
                          className="text-[10px] font-semibold bg-indigo-50 text-indigo-800 px-2 py-0.5 rounded-md truncate max-w-[200px]"
                        >
                          {c}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Teaching Schedule Preview (No Room Numbers) */}
                  <div className="border-t border-slate-100 pt-3 text-xs">
                    <div className="flex items-center justify-between text-slate-500 mb-1.5">
                      <span className="font-semibold text-slate-700">Today&apos;s Teaching (Monday):</span>
                      <span className="font-mono text-emerald-700 font-bold">
                        {todaysClasses.length} {todaysClasses.length === 1 ? 'class' : 'classes'}
                      </span>
                    </div>
                    {todaysClasses.length > 0 ? (
                      <div className="space-y-1.5">
                        {todaysClasses.slice(0, 2).map((cls) => (
                          <div
                            key={cls.id}
                            className="p-2 rounded-xl bg-slate-50 border border-slate-100 text-[11px] text-slate-700"
                          >
                            <p className="font-bold truncate">{cls.courseName}</p>
                            <p className="text-slate-500 text-[10px] mt-0.5 font-mono">
                              {cls.startTime} – {cls.endTime} • Sem {cls.semester} (Sec {cls.section})
                            </p>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p className="text-[11px] text-slate-500 italic bg-slate-50/60 p-2 rounded-xl border border-dashed border-slate-200">
                        Available on campus for student consultations during university hours
                      </p>
                    )}
                  </div>
                </div>

                {/* Footer Action */}
                <div className="p-4 bg-slate-50/80 border-t border-slate-100 flex items-center justify-between text-xs">
                  <span className="text-slate-500 font-medium">
                    {totalScheduledClasses} weekly lectures/labs
                  </span>
                  <button
                    onClick={() => setSelectedTeacher(teacher)}
                    className="font-bold text-[#0F172A] hover:text-[#C5A059] flex items-center gap-1.5 transition-colors group-hover:translate-x-0.5 transform duration-150"
                  >
                    <span>Teaching Schedule</span>
                    <ArrowRight size={13} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Teacher Detail Profile Modal */}
      {selectedTeacher && (
        <TeacherDetailModal
          teacher={selectedTeacher}
          onClose={() => setSelectedTeacher(null)}
        />
      )}
    </div>
  );
};
