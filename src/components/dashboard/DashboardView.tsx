import React from 'react';
import {
  Calendar,
  DoorOpen,
  Users,
  Clock,
  PackageSearch,
  ArrowRight,
  Sparkles,
  MapPin,
  CheckCircle2,
  AlertCircle,
  PlusCircle,
  GraduationCap
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';
import { TimetableEntry } from '../../types';
import { formatRoomDisplay } from '../../utils/roomUtils';
import {
  getStudentEnrolledClasses,
  formatStudentAcademicContext,
  getPeshawarDateTime,
  getNextUpcomingClass,
  parseTimeToMinutes
} from '../../utils/studentScheduleUtils';
import { formatUserRollNumber } from '../../utils/rollNumberUtils';

export const DashboardView: React.FC = () => {
  const { currentUser, openAuthModal } = useAuth();
  const {
    timetable,
    lostFoundItems,
    setActiveTab,
    setSelectedTeacher,
    setSelectedRoom,
    teachers,
    rooms
  } = useApp();

  // Auto-updating state (refreshes every 30 seconds to catch midnight rollover & schedule transitions)
  const [currentTime, setCurrentTime] = React.useState<Date>(() => new Date());

  React.useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 30000);
    return () => clearInterval(timer);
  }, []);

  // Dynamically calculate the current date, weekday, and Peshawar/Pakistan time
  const {
    weekday: currentWeekday,
    currentMinutes,
    isWeekend,
    isWorkingDay,
    formattedDate
  } = getPeshawarDateTime(currentTime);

  const userSection = currentUser?.section || 'A';

  // Today's classes strictly for the student's enrolled courses:
  const enrolledClasses: TimetableEntry[] = currentUser
    ? getStudentEnrolledClasses(timetable, currentUser)
    : getStudentEnrolledClasses(timetable, {
        id: 'default-student',
        firstName: 'Student',
        lastName: '',
        rollNumber: '26-CS-01',
        email: '',
        department: 'Computer Science',
        degree: 'BS Computer Science',
        semester: '1st',
        section: 'A',
        admissionBatch: 'Fall 2026 – 2030',
        admissionYear: 2026,
        expectedGraduationYear: 2030
      });

  // Monday–Friday: Show only the student's classes scheduled for that actual day.
  // Saturday & Sunday: Non-working days. Do NOT show any Saturday or Sunday classes ([]).
  const todayClasses: TimetableEntry[] = isWorkingDay
    ? enrolledClasses
        .filter((item) => item.day === currentWeekday)
        .sort((a, b) => parseTimeToMinutes(a.startTime) - parseTimeToMinutes(b.startTime))
    : [];

  // Next Upcoming Class calculation:
  // - On weekday: next class today based on current time, or next working day if none remaining today.
  // - On Saturday or Sunday: searches forward starting from Monday through Friday.
  // - If a working day has no classes, continues searching forward through Monday–Friday.
  const nextClassInfo = getNextUpcomingClass(enrolledClasses, currentWeekday, currentMinutes);
  const nextClass = nextClassInfo?.entry || null;

  const nextTeacherObj = teachers.find((t) => t.id === nextClass?.teacherId);
  const nextRoomObj = rooms.find((r) =>
    r.roomNumber.toLowerCase().includes(nextClass?.classroomNumber?.toLowerCase() || '')
  );

  // Recent Lost & Found updates (latest 4 items)
  const recentLostFound = lostFoundItems.slice(0, 4);

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* 1. Header Banner with Student Info */}
      <div className="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-sm relative overflow-hidden">
        {/* Subtle geometric academic background accent */}
        <div className="absolute right-0 top-0 bottom-0 w-1/3 bg-gradient-to-l from-slate-50 to-transparent pointer-events-none hidden md:block" />
        <div className="absolute -right-8 -top-8 w-40 h-40 rounded-full bg-[#C5A059]/5 pointer-events-none" />

        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <div className="flex items-center gap-2 text-xs font-semibold text-[#047857] mb-2 bg-emerald-50 w-fit px-2.5 py-1 rounded-full border border-emerald-200/60">
              <span className="w-2 h-2 rounded-full bg-[#047857] animate-pulse" />
              <span>Fall Semester 2026 Active • Peshawar Campus</span>
            </div>

            <h1 className="text-2xl sm:text-3xl font-extrabold text-[#0F172A] tracking-tight">
              Welcome back, {currentUser ? `${currentUser.firstName} ${currentUser.lastName}` : 'Student'}
            </h1>

            <p className="text-slate-500 text-sm mt-1 flex items-center gap-2">
              <Calendar size={15} className="text-[#C5A059]" />
              <span className="font-medium text-slate-700">{formattedDate}</span>
              <span className="text-slate-300">•</span>
              <span>
                Today&apos;s Schedule:{' '}
                <span className="font-semibold text-slate-800">
                  {isWeekend ? 'No classes today' : currentWeekday}
                </span>
              </span>
            </p>
          </div>

          {/* Student Profile Snapshot Badge */}
          {currentUser && (
            <div className="bg-[#FAF9F6] border border-slate-200/80 rounded-2xl p-4 sm:p-5 flex items-center gap-4 shrink-0 shadow-inner">
              <div className="w-12 h-12 rounded-xl bg-[#0F172A] text-[#C5A059] flex items-center justify-center font-bold text-base shadow-sm">
                {currentUser.firstName[0]}
                {currentUser.lastName[0]}
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-mono text-xs font-bold text-slate-900 bg-white px-2 py-0.5 rounded border border-slate-200">
                    {formatUserRollNumber(currentUser)}
                  </span>
                  <span className="text-xs font-semibold text-slate-600">
                    Sec {currentUser.section}
                  </span>
                </div>
                <p className="text-xs font-semibold text-[#0F172A] mt-1">
                  {currentUser.degree}
                </p>
                <p className="text-[11px] text-slate-500">
                  {currentUser.semester} Semester • {currentUser.admissionBatch}
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* 2. Top Summary Cards: Next Class Hero + Today's Schedule Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Next Class Hero Card (Deep Navy) */}
        <div className="lg:col-span-2 bg-[#0F172A] text-white rounded-3xl p-6 sm:p-7 shadow-xl border border-slate-800 relative overflow-hidden flex flex-col justify-between">
          <div className="absolute right-0 bottom-0 opacity-5 pointer-events-none">
            <Calendar size={220} />
          </div>

          <div>
            <div className="flex items-center justify-between mb-4">
              <span className="text-xs font-bold uppercase tracking-wider text-[#C5A059] bg-amber-950/60 border border-[#C5A059]/30 px-3 py-1 rounded-full flex items-center gap-1.5">
                <Clock size={13} />
                <span>Next Upcoming Class</span>
              </span>
              <span className="text-xs text-slate-400 font-mono">
                {nextClassInfo?.startsLabel || 'No scheduled classes'}
              </span>
            </div>

            <div className="mt-2">
              {nextClass ? (
                <>
                  <div className="flex items-center gap-2 text-slate-400 text-xs font-mono">
                    <span>{nextClass.courseCode}</span>
                    <span>•</span>
                    <span className="text-amber-200">{nextClass.type}</span>
                    <span>•</span>
                    <span className="text-emerald-400 font-semibold">{nextClass.day}</span>
                  </div>
                  <h2 className="text-2xl sm:text-3xl font-extrabold text-white mt-1 tracking-tight">
                    {nextClass.courseName}
                  </h2>
                </>
              ) : (
                <>
                  <div className="text-slate-400 text-xs font-mono">
                    <span>Academic Schedule</span>
                  </div>
                  <h2 className="text-2xl sm:text-3xl font-extrabold text-white mt-1 tracking-tight">
                    No Upcoming Classes Scheduled
                  </h2>
                </>
              )}
            </div>

            {/* Next Classroom & Next Teacher Prominent Highlighting */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-6">
              {/* Next Classroom */}
              <button
                onClick={() => {
                  if (nextRoomObj) {
                    setSelectedRoom(nextRoomObj);
                  }
                  setActiveTab('rooms');
                }}
                className="bg-slate-800/80 hover:bg-slate-800 border border-slate-700/80 hover:border-[#C5A059]/50 rounded-2xl p-4 text-left transition-all group"
              >
                <div className="flex items-center justify-between text-xs text-slate-400 mb-1">
                  <span className="font-semibold flex items-center gap-1.5">
                    <DoorOpen size={14} className="text-[#C5A059]" />
                    <span>Next Classroom</span>
                  </span>
                  <span className="text-[10px] text-slate-500 group-hover:text-amber-200">
                    Inspect Room →
                  </span>
                </div>
                <p className="text-lg font-bold text-white font-mono">
                  {nextClass?.classroomNumber ? formatRoomDisplay(nextClass.classroomNumber) : '—'}
                </p>
                <p className="text-xs text-slate-400 truncate mt-0.5">
                  {nextClass?.building || 'No room currently assigned'}
                </p>
              </button>

              {/* Next Teacher */}
              <button
                onClick={() => {
                  if (nextTeacherObj) {
                    setSelectedTeacher(nextTeacherObj);
                  }
                  setActiveTab('teachers');
                }}
                className="bg-slate-800/80 hover:bg-slate-800 border border-slate-700/80 hover:border-[#C5A059]/50 rounded-2xl p-4 text-left transition-all group"
              >
                <div className="flex items-center justify-between text-xs text-slate-400 mb-1">
                  <span className="font-semibold flex items-center gap-1.5">
                    <Users size={14} className="text-[#C5A059]" />
                    <span>Next Teacher</span>
                  </span>
                  <span className="text-[10px] text-slate-500 group-hover:text-amber-200">
                    Faculty Info →
                  </span>
                </div>
                <p className="text-lg font-bold text-white truncate">
                  {nextClass?.teacherName || (nextTeacherObj ? nextTeacherObj.name : '—')}
                </p>
                <p className="text-xs text-slate-400 truncate mt-0.5">
                  {nextTeacherObj?.designation ? `${nextTeacherObj.designation} • ${nextTeacherObj.department}` : (nextClass?.department || 'No active faculty assignment')}
                </p>
              </button>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
            <span className="flex items-center gap-1">
              <CheckCircle2 size={13} className="text-emerald-400" />
              <span>{isWeekend ? 'Campus closed for weekend' : 'Attendance status verified'}</span>
            </span>
            <button
              onClick={() => setActiveTab('timetable')}
              className="text-[#C5A059] hover:text-amber-300 font-semibold flex items-center gap-1"
            >
              View Full Week Timetable <ArrowRight size={14} />
            </button>
          </div>
        </div>


        {/* Academic Quick Portal Links */}
        <div className="bg-white rounded-3xl p-6 border border-slate-200/80 shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
                Campus Navigation
              </h3>
              <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600">
                Peshawar Hub
              </span>
            </div>

            <div className="space-y-2.5">
              <button
                onClick={() => setActiveTab('timetable')}
                className="w-full p-3 rounded-2xl border border-slate-200 hover:border-slate-300 bg-slate-50/50 hover:bg-slate-100/80 flex items-center justify-between transition-all text-left group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-amber-50 text-amber-700 flex items-center justify-center font-semibold">
                    <Calendar size={16} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-900 group-hover:text-[#0F172A]">
                      Timetable & Schedules
                    </p>
                    <p className="text-[11px] text-slate-500">
                      5 days, filtered by sem & batch
                    </p>
                  </div>
                </div>
                <ArrowRight size={14} className="text-slate-400 group-hover:translate-x-1 transition-transform" />
              </button>

              <button
                onClick={() => setActiveTab('rooms')}
                className="w-full p-3 rounded-2xl border border-slate-200 hover:border-slate-300 bg-slate-50/50 hover:bg-slate-100/80 flex items-center justify-between transition-all text-left group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center font-semibold">
                    <DoorOpen size={16} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-900 group-hover:text-[#0F172A]">
                      Classrooms & Labs Directory
                    </p>
                    <p className="text-[11px] text-slate-500">
                      Search rooms, capacity & schedules
                    </p>
                  </div>
                </div>
                <ArrowRight size={14} className="text-slate-400 group-hover:translate-x-1 transition-transform" />
              </button>

              <button
                onClick={() => setActiveTab('teachers')}
                className="w-full p-3 rounded-2xl border border-slate-200 hover:border-slate-300 bg-slate-50/50 hover:bg-slate-100/80 flex items-center justify-between transition-all text-left group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-sky-50 text-sky-700 flex items-center justify-center font-semibold">
                    <Users size={16} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-900 group-hover:text-[#0F172A]">
                      Faculty & Teacher Directory
                    </p>
                    <p className="text-[11px] text-slate-500">
                      Faculty members, schedules & courses
                    </p>
                  </div>
                </div>
                <ArrowRight size={14} className="text-slate-400 group-hover:translate-x-1 transition-transform" />
              </button>

              <button
                onClick={() => setActiveTab('lost-found')}
                className="w-full p-3 rounded-2xl border border-slate-200 hover:border-slate-300 bg-slate-50/50 hover:bg-slate-100/80 flex items-center justify-between transition-all text-left group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-xl bg-rose-50 text-rose-700 flex items-center justify-center font-semibold">
                    <PackageSearch size={16} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-900 group-hover:text-[#0F172A]">
                      Lost & Found Noticeboard
                    </p>
                    <p className="text-[11px] text-slate-500">
                      Report items or claim belongings
                    </p>
                  </div>
                </div>
                <ArrowRight size={14} className="text-slate-400 group-hover:translate-x-1 transition-transform" />
              </button>
            </div>
          </div>

          <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-[11px] text-slate-500">
            <span>Peshawar University Portal</span>
            <span className="text-[#047857] font-semibold">Online & Synced</span>
          </div>
        </div>
      </div>

      {/* 3. Today's Classes List + Lost & Found Updates */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Today's Classes Table */}
        <div className="lg:col-span-2 bg-white rounded-3xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center font-bold">
                <Calendar size={16} />
              </div>
              <div>
                <h2 className="text-base font-bold text-slate-900">
                  Today&apos;s Classes ({isWeekend ? 'No classes today' : currentWeekday})
                </h2>
                <p className="text-xs text-slate-500">
                  {currentUser ? formatStudentAcademicContext(currentUser) : `Section ${userSection} • Computer Science`}
                </p>
              </div>
            </div>

            <button
              onClick={() => setActiveTab('timetable')}
              className="text-xs font-semibold text-[#C5A059] hover:text-[#B38E46] flex items-center gap-1"
            >
              My Enrolled Classes →
            </button>
          </div>

          {todayClasses.length === 0 ? (
            <div className="p-10 text-center text-slate-400">
              <Calendar size={36} className="mx-auto mb-2 text-slate-300" />
              <p className="text-sm font-semibold text-slate-700">
                {isWeekend ? 'No classes today' : 'No classes scheduled for today'}
              </p>
              <p className="text-xs text-slate-500 mt-1 max-w-md mx-auto">
                {isWeekend
                  ? `Academic working days are Monday through Friday. Your next upcoming class ${
                      nextClassInfo ? nextClassInfo.startsLabel.toLowerCase() : 'starts Monday'
                    }.`
                  : 'Enjoy your study-free day or visit the campus library.'}
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead className="bg-slate-50/75 text-slate-500 text-[11px] font-semibold uppercase tracking-wider border-b border-slate-100">
                  <tr>
                    <th className="px-6 py-3.5">Time</th>
                    <th className="px-6 py-3.5">Course Name & Code</th>
                    <th className="px-6 py-3.5">Classroom</th>
                    <th className="px-6 py-3.5">Instructor</th>
                    <th className="px-6 py-3.5">Type</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-xs">
                  {todayClasses.map((cls, idx) => (
                    <tr
                      key={cls.id}
                      className="hover:bg-slate-50/80 transition-colors group"
                    >
                      <td className="px-6 py-4 font-mono font-bold text-[#0F172A] whitespace-nowrap">
                        <div className="flex items-center gap-1.5">
                          {idx === 0 && (
                            <span className="w-1.5 h-1.5 rounded-full bg-[#047857]" title="Next Class" />
                          )}
                          <span>{cls.startTime} – {cls.endTime}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="font-bold text-slate-900 group-hover:text-indigo-950 block">
                          {cls.courseName}
                        </span>
                        <span className="text-[11px] text-slate-500 font-mono">
                          {cls.courseCode} • {cls.creditHours} Credits
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <button
                          onClick={() => {
                            const r = rooms.find((rm) => rm.roomNumber === cls.classroomNumber);
                            if (r) setSelectedRoom(r);
                            setActiveTab('rooms');
                          }}
                          className="font-mono font-semibold text-slate-800 hover:text-emerald-700 hover:underline flex items-center gap-1"
                        >
                          <DoorOpen size={13} className="text-emerald-600" />
                          <span>{formatRoomDisplay(cls.classroomNumber)}</span>
                        </button>
                        <span className="text-[10px] text-slate-400 block truncate max-w-[130px]">
                          {cls.building}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <button
                          onClick={() => {
                            const t = teachers.find((tch) => tch.id === cls.teacherId);
                            if (t) setSelectedTeacher(t);
                            setActiveTab('teachers');
                          }}
                          className="font-medium text-slate-700 hover:text-indigo-700 hover:underline"
                        >
                          {cls.teacherName}
                        </button>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span
                          className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                            cls.type === 'Lab'
                              ? 'bg-amber-100 text-amber-900 border border-amber-200'
                              : cls.type === 'Tutorial'
                              ? 'bg-purple-100 text-purple-900 border border-purple-200'
                              : 'bg-emerald-100 text-emerald-900 border border-emerald-200'
                          }`}
                        >
                          {cls.type}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Lost & Found Updates Card */}
        <div className="bg-white rounded-3xl border border-slate-200/80 shadow-sm p-6 flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between pb-4 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-rose-50 text-rose-700 flex items-center justify-center font-bold">
                  <PackageSearch size={16} />
                </div>
                <div>
                  <h2 className="text-sm font-bold text-slate-900">Lost & Found Updates</h2>
                  <p className="text-[11px] text-slate-500">Recent campus notices</p>
                </div>
              </div>

              <button
                onClick={() => setActiveTab('lost-found')}
                className="text-xs font-semibold text-[#C5A059] hover:underline"
              >
                View all →
              </button>
            </div>

            {recentLostFound.length === 0 ? (
              <div className="text-center py-7 px-4 bg-slate-50/70 rounded-2xl border border-slate-200/60">
                <PackageSearch size={26} className="mx-auto text-slate-400 mb-2" />
                <p className="text-xs font-bold text-slate-800">No Lost & Found Items Yet</p>
                <p className="text-[11px] text-slate-500 mt-1 max-w-xs mx-auto leading-relaxed">
                  Lost something or found an item on campus? Create a listing to help reunite it with its owner.
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {recentLostFound.map((item) => (
                  <div
                    key={item.id}
                    onClick={() => setActiveTab('lost-found')}
                    className="p-3 rounded-2xl bg-slate-50/70 border border-slate-200/70 hover:bg-slate-100/70 cursor-pointer transition-all"
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span
                        className={`text-[10px] font-bold uppercase px-2 py-0.5 rounded-full ${
                          item.type === 'lost'
                            ? 'bg-rose-100 text-rose-800'
                            : 'bg-emerald-100 text-emerald-800'
                        }`}
                      >
                        {item.type}
                      </span>
                      <span className="text-[10px] text-slate-400 font-medium">
                        {item.date}
                      </span>
                    </div>
                    <h4 className="text-xs font-bold text-slate-900 truncate">
                      {item.itemName}
                    </h4>
                    <p className="text-[11px] text-slate-500 line-clamp-1 mt-0.5">
                      {item.location}
                    </p>
                    <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-200/60 text-[10px]">
                      <span className="font-semibold text-slate-600">
                        Status: {item.status}
                      </span>
                      <span className="text-[#C5A059] font-bold hover:underline">
                        View Details →
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <button
            onClick={() => setActiveTab('lost-found')}
            className="w-full mt-4 py-2.5 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 shadow-sm"
          >
            <PlusCircle size={14} />
            <span>Report Item on Campus</span>
          </button>
        </div>
      </div>
    </div>
  );
};
