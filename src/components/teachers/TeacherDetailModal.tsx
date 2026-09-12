import React from 'react';
import {
  X,
  Clock,
  BookOpen,
  Calendar,
  GraduationCap,
  Sparkles,
  Info,
  CheckCircle2
} from 'lucide-react';
import { Teacher, TimetableEntry } from '../../types';
import { useApp } from '../../context/AppContext';
import {
  UNIVERSITY_OPERATING_HOURS,
  getTeacherClasses,
  getTeacherClassesForDay
} from '../../utils/teacherUtils';

interface TeacherDetailModalProps {
  teacher: Teacher;
  onClose: () => void;
}

export const TeacherDetailModal: React.FC<TeacherDetailModalProps> = ({ teacher, onClose }) => {
  const { timetable } = useApp();

  // All teacher classes across the week from the real timetable
  const allTeacherSchedule: TimetableEntry[] = getTeacherClasses(timetable, teacher);

  // Teacher classes today (Monday)
  const todaysTeacherClasses: TimetableEntry[] = getTeacherClassesForDay(timetable, teacher, 'Monday');

  const daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'] as const;

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-6 overflow-y-auto animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="w-full max-w-2xl bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header Ribbon */}
        <div className="bg-[#0F172A] text-white p-6 relative">
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-[#1E293B] to-[#334155] border border-[#C5A059]/40 flex items-center justify-center text-[#C5A059] font-bold text-xl shadow-lg">
                {teacher.name.split(' ').slice(1, 2)[0]?.[0] || teacher.name[0]}
              </div>
              <div>
                <span className="text-[11px] font-bold uppercase tracking-wider text-[#C5A059]">
                  {teacher.designation}
                </span>
                <h2 className="text-xl font-bold tracking-tight text-white">{teacher.name}</h2>
                <p className="text-xs text-slate-300 mt-0.5">{teacher.department}</p>
              </div>
            </div>

            <button
              onClick={onClose}
              className="p-1.5 rounded-full text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            >
              <X size={18} />
            </button>
          </div>

          {/* University Operating Hours Bar */}
          <div className="mt-5 pt-4 border-t border-slate-800/80 text-xs">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-slate-300 bg-slate-800/60 p-3 rounded-2xl border border-slate-700/50">
              <div className="flex items-center gap-2">
                <Clock size={15} className="text-[#C5A059] shrink-0" />
                <span className="font-semibold text-white">University Operating Hours:</span>
              </div>
              <div className="text-[11px] text-slate-300">
                <span className="text-white font-medium">Mon–Thu:</span> 8:00 AM – 4:00 PM
                <span className="mx-2 text-slate-600">|</span>
                <span className="text-white font-medium">Fri:</span> 8:00 AM – 3:00 PM
              </div>
            </div>
          </div>
        </div>

        {/* Content Body */}
        <div className="p-6 space-y-6 overflow-y-auto">
          {/* Qualifications & Specialization */}
          <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 text-xs space-y-2">
            <div className="flex items-start gap-2">
              <GraduationCap size={15} className="text-slate-500 shrink-0 mt-0.5" />
              <div>
                <strong className="text-slate-900">Academic Qualifications: </strong>
                <span className="text-slate-700">{teacher.qualifications}</span>
              </div>
            </div>
            <div className="flex items-start gap-2">
              <Sparkles size={15} className="text-[#C5A059] shrink-0 mt-0.5" />
              <div>
                <strong className="text-slate-900">Specialization & Research: </strong>
                <span className="text-slate-700">{teacher.specialization}</span>
              </div>
            </div>
          </div>

          {/* Courses Taught */}
          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-2.5 flex items-center gap-1.5">
              <BookOpen size={14} className="text-indigo-600" />
              <span>Assigned Courses ({teacher.courses.length})</span>
            </h3>
            <div className="flex flex-wrap gap-2">
              {teacher.courses.map((c) => (
                <span
                  key={c}
                  className="px-3 py-1.5 rounded-xl bg-indigo-50 text-indigo-900 text-xs font-semibold border border-indigo-100"
                >
                  {c}
                </span>
              ))}
            </div>
          </div>

          {/* Today's Teaching Classes (Monday) */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-1.5">
                <Calendar size={14} className="text-emerald-600" />
                <span>Today&apos;s Scheduled Lectures (Monday)</span>
              </h3>
              <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200/70">
                {todaysTeacherClasses.length} Scheduled
              </span>
            </div>

            {todaysTeacherClasses.length === 0 ? (
              <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80 text-xs text-slate-600 flex items-center gap-2">
                <Info size={15} className="text-slate-400 shrink-0" />
                <span>
                  No lectures scheduled for this instructor today. Available on campus for faculty duties and student consultations during university operating hours (8:00 AM – 4:00 PM).
                </span>
              </div>
            ) : (
              <div className="space-y-2">
                {todaysTeacherClasses.map((cls) => (
                  <div
                    key={cls.id}
                    className="p-3.5 rounded-2xl border border-slate-200 bg-slate-50/70 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
                  >
                    <div>
                      <p className="font-bold text-slate-900 text-sm">{cls.courseName}</p>
                      <p className="text-slate-500 mt-0.5">
                        {cls.department} • Semester {cls.semester} (Section {cls.section})
                      </p>
                    </div>
                    <div className="sm:text-right shrink-0">
                      <p className="font-mono font-bold text-slate-900 bg-white px-2.5 py-1 rounded-xl border border-slate-200 inline-block">
                        {cls.startTime} – {cls.endTime}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Full Weekly Teaching Schedule (No Room Numbers) */}
          <div>
            <div className="flex items-center justify-between mb-2.5">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-1.5">
                <Clock size={14} className="text-[#C5A059]" />
                <span>Weekly Teaching Schedule</span>
              </h3>
              <span className="text-[11px] text-slate-500 font-mono">
                {allTeacherSchedule.length} total sessions
              </span>
            </div>

            {allTeacherSchedule.length === 0 ? (
              <p className="text-xs text-slate-400 italic p-4 bg-slate-50 rounded-xl">
                No active teaching sessions registered in current timetable.
              </p>
            ) : (
              <div className="overflow-x-auto border border-slate-200 rounded-2xl">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 text-slate-500 font-semibold text-[11px] border-b border-slate-200">
                    <tr>
                      <th className="px-4 py-2.5">Day</th>
                      <th className="px-4 py-2.5">Teaching Time</th>
                      <th className="px-4 py-2.5">Course Name</th>
                      <th className="px-4 py-2.5">Code</th>
                      <th className="px-4 py-2.5">Semester & Section</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {allTeacherSchedule.map((entry) => (
                      <tr key={entry.id} className="hover:bg-slate-50/80">
                        <td className="px-4 py-2.5 font-bold text-slate-800">{entry.day}</td>
                        <td className="px-4 py-2.5 font-mono text-slate-900 font-semibold">
                          {entry.startTime} – {entry.endTime}
                        </td>
                        <td className="px-4 py-2.5 text-slate-900 font-medium">{entry.courseName}</td>
                        <td className="px-4 py-2.5 font-mono text-slate-500">{entry.courseCode}</td>
                        <td className="px-4 py-2.5 text-slate-700">
                          Sem {entry.semester} <span className="text-slate-400">·</span> <strong className="text-slate-900">Sec {entry.section}</strong>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            <div className="mt-2.5 p-3 rounded-xl bg-amber-50/70 border border-amber-200/60 text-[11px] text-amber-900 flex items-start gap-2">
              <Info size={14} className="text-amber-700 shrink-0 mt-0.5" />
              <span>
                <strong>Academic Availability:</strong> Faculty members are on campus and available for student academic consultation and departmental assignments during university operating hours (Mon–Thu: 8:00 AM – 4:00 PM, Fri: 8:00 AM – 3:00 PM) outside their active teaching lecture times.
              </span>
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div className="p-4 bg-slate-50 border-t border-slate-200 flex items-center justify-between text-xs text-slate-500">
          <span>CampusHub Faculty Directory</span>
          <button
            onClick={onClose}
            className="px-4 py-2 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl font-bold transition-all"
          >
            Close Profile
          </button>
        </div>
      </div>
    </div>
  );
};
