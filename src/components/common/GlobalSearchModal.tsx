import React, { useEffect, useRef } from 'react';
import {
  Search,
  X,
  Users,
  DoorOpen,
  BookOpen,
  Calendar,
  PackageSearch,
  ArrowRight,
  Sparkles
} from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { formatRoomDisplay } from '../../utils/roomUtils';

export const GlobalSearchModal: React.FC = () => {
  const {
    isSearchOpen,
    setIsSearchOpen,
    searchQuery,
    setSearchQuery,
    teachers,
    rooms,
    timetable,
    lostFoundItems,
    setSelectedTeacher,
    setSelectedRoom,
    setActiveTab,
    setSelectedItemForClaim
  } = useApp();

  const inputRef = useRef<HTMLInputElement>(null);

  // Keyboard shortcut listener (Cmd+K / Ctrl+K & Escape)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        setIsSearchOpen(!isSearchOpen);
      } else if (e.key === 'Escape' && isSearchOpen) {
        setIsSearchOpen(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isSearchOpen, setIsSearchOpen]);

  useEffect(() => {
    if (isSearchOpen) {
      setTimeout(() => inputRef.current?.focus(), 50);
    } else {
      setSearchQuery('');
    }
  }, [isSearchOpen, setSearchQuery]);

  if (!isSearchOpen) return null;

  const query = searchQuery.trim().toLowerCase();

  // 1. Search Teachers
  const matchedTeachers = query
    ? teachers.filter(
        (t) =>
          t.name.toLowerCase().includes(query) ||
          t.department.toLowerCase().includes(query) ||
          t.courses.some((c) => c.toLowerCase().includes(query)) ||
          t.specialization.toLowerCase().includes(query)
      )
    : teachers.slice(0, 3);

  // 2. Search Rooms
  const matchedRooms = query
    ? rooms.filter(
        (r) =>
          r.roomNumber.toLowerCase().includes(query) ||
          r.building.toLowerCase().includes(query) ||
          r.type.toLowerCase().includes(query) ||
          r.facilities.some((f) => f.toLowerCase().includes(query))
      )
    : rooms.slice(0, 3);

  // 3. Search Courses & Timetable Entries
  const matchedTimetable = query
    ? timetable.filter(
        (tt) =>
          tt.courseName.toLowerCase().includes(query) ||
          tt.courseCode.toLowerCase().includes(query) ||
          tt.teacherName.toLowerCase().includes(query) ||
          tt.classroomNumber.toLowerCase().includes(query) ||
          tt.day.toLowerCase().includes(query) ||
          tt.department.toLowerCase().includes(query)
      )
    : timetable.slice(0, 3);

  // Unique courses extracted
  const uniqueCourseNames = Array.from(
    new Set(matchedTimetable.map((tt) => `${tt.courseCode}: ${tt.courseName}`))
  );

  // 4. Search Lost & Found
  const matchedLostFound = query
    ? lostFoundItems.filter(
        (lf) =>
          lf.itemName.toLowerCase().includes(query) ||
          lf.description.toLowerCase().includes(query) ||
          lf.location.toLowerCase().includes(query) ||
          (lf.room && lf.room.toLowerCase().includes(query)) ||
          lf.category.toLowerCase().includes(query) ||
          lf.status.toLowerCase().includes(query)
      )
    : lostFoundItems.slice(0, 3);

  const totalResults =
    matchedTeachers.length +
    matchedRooms.length +
    matchedTimetable.length +
    matchedLostFound.length;

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-start justify-center p-3 sm:p-6 sm:pt-20 overflow-y-auto animate-in fade-in duration-150"
      onClick={() => setIsSearchOpen(false)}
    >
      <div
        className="w-full max-w-3xl bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Search Input Bar */}
        <div className="p-4 border-b border-slate-200 bg-slate-50/70 flex items-center gap-3">
          <Search size={20} className="text-[#C5A059] shrink-0" />
          <input
            ref={inputRef}
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search teachers, rooms, course codes, timetable entries, lost & found..."
            className="flex-1 bg-transparent text-slate-900 placeholder:text-slate-400 text-sm sm:text-base focus:outline-none"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="text-slate-400 hover:text-slate-600 p-1"
            >
              <X size={16} />
            </button>
          )}
          <button
            onClick={() => setIsSearchOpen(false)}
            className="px-2 py-1 text-xs font-semibold text-slate-500 bg-white border border-slate-200 rounded-lg hover:bg-slate-100"
          >
            ESC
          </button>
        </div>

        {/* Results Body */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-6">
          {!query && (
            <div className="flex items-center gap-2 text-xs font-semibold text-slate-400 uppercase tracking-wider">
              <Sparkles size={14} className="text-[#C5A059]" />
              <span>Suggested quick lookups on campus</span>
            </div>
          )}

          {query && totalResults === 0 && (
            <div className="text-center py-12">
              <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
                <Search size={22} />
              </div>
              <h3 className="text-sm font-bold text-slate-800">No matching campus records</h3>
              <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
                No teachers, rooms, courses, or lost items matched &quot;{searchQuery}&quot;. Try searching with a teacher name, room number (e.g. CS-101), or course code.
              </p>
            </div>
          )}

          {/* 1. Teachers Section */}
          {matchedTeachers.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-2.5">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
                  <Users size={14} className="text-indigo-600" />
                  <span>Faculty & Teachers ({matchedTeachers.length})</span>
                </div>
                <button
                  onClick={() => {
                    setActiveTab('teachers');
                    setIsSearchOpen(false);
                  }}
                  className="text-xs text-[#C5A059] font-medium hover:underline flex items-center gap-1"
                >
                  View all in Directory <ArrowRight size={12} />
                </button>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {matchedTeachers.map((teacher) => (
                  <button
                    key={teacher.id}
                    onClick={() => {
                      setSelectedTeacher(teacher);
                      setActiveTab('teachers');
                      setIsSearchOpen(false);
                    }}
                    className="p-3 rounded-xl border border-slate-200/80 bg-slate-50/50 hover:bg-slate-100/80 hover:border-slate-300 text-left transition-all group flex items-start gap-3"
                  >
                    <div className="w-8 h-8 rounded-lg bg-[#0F172A] text-white flex items-center justify-center font-bold text-xs shrink-0">
                      {teacher.name.split(' ').slice(1, 2)[0]?.[0] || teacher.name[0]}
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-bold text-slate-900 group-hover:text-indigo-950 truncate">
                        {teacher.name}
                      </p>
                      <p className="text-[11px] text-slate-500 truncate">{teacher.department}</p>
                      <p className="text-[10px] text-slate-400 mt-0.5 font-medium truncate">
                        {teacher.designation}
                      </p>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* 2. Rooms Section */}
          {matchedRooms.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-2.5">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
                  <DoorOpen size={14} className="text-emerald-600" />
                  <span>Classrooms & Labs ({matchedRooms.length})</span>
                </div>
                <button
                  onClick={() => {
                    setActiveTab('rooms');
                    setIsSearchOpen(false);
                  }}
                  className="text-xs text-[#C5A059] font-medium hover:underline flex items-center gap-1"
                >
                  View all Rooms <ArrowRight size={12} />
                </button>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                {matchedRooms.map((room) => (
                  <button
                    key={room.id}
                    onClick={() => {
                      setSelectedRoom(room);
                      setActiveTab('rooms');
                      setIsSearchOpen(false);
                    }}
                    className="p-3 rounded-xl border border-slate-200/80 bg-slate-50/50 hover:bg-slate-100/80 hover:border-slate-300 text-left transition-all group"
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-bold text-slate-900 group-hover:text-emerald-900">
                        {room.roomNumber}
                      </span>
                      <span className="text-[10px] font-semibold px-1.5 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200">
                        {room.capacity} seats
                      </span>
                    </div>
                    <p className="text-[11px] text-slate-500 truncate">{room.building}</p>
                    <p className="text-[10px] text-slate-400">{room.type}</p>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* 3. Timetable / Course Entries */}
          {matchedTimetable.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-2.5">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
                  <Calendar size={14} className="text-amber-600" />
                  <span>Timetable Classes & Schedules ({matchedTimetable.length})</span>
                </div>
                <button
                  onClick={() => {
                    setActiveTab('timetable');
                    setIsSearchOpen(false);
                  }}
                  className="text-xs text-[#C5A059] font-medium hover:underline flex items-center gap-1"
                >
                  Full Timetable <ArrowRight size={12} />
                </button>
              </div>
              <div className="space-y-2">
                {matchedTimetable.map((entry) => (
                  <button
                    key={entry.id}
                    onClick={() => {
                      setActiveTab('timetable');
                      setIsSearchOpen(false);
                    }}
                    className="w-full p-2.5 rounded-xl border border-slate-200/80 bg-slate-50/50 hover:bg-amber-50/40 hover:border-amber-200 text-left transition-all flex items-center justify-between gap-3 group"
                  >
                    <div className="min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-bold text-slate-900 group-hover:text-slate-950">
                          {entry.courseCode}: {entry.courseName}
                        </span>
                        <span className="text-[10px] font-medium px-1.5 py-0.5 rounded bg-slate-200 text-slate-700">
                          {entry.day}
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-500 mt-0.5">
                        {entry.teacherName} • {formatRoomDisplay(entry.classroomNumber)} • Sec {entry.section} (Sem {entry.semester})
                      </p>
                    </div>
                    <div className="text-right shrink-0">
                      <span className="text-xs font-semibold text-[#0F172A] block font-mono">
                        {entry.startTime} – {entry.endTime}
                      </span>
                      <span className="text-[10px] text-slate-400">{entry.type}</span>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* 4. Lost & Found Items */}
          {matchedLostFound.length > 0 && (
            <div>
              <div className="flex items-center justify-between mb-2.5">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
                  <PackageSearch size={14} className="text-rose-600" />
                  <span>Lost & Found Registry ({matchedLostFound.length})</span>
                </div>
                <button
                  onClick={() => {
                    setActiveTab('lost-found');
                    setIsSearchOpen(false);
                  }}
                  className="text-xs text-[#C5A059] font-medium hover:underline flex items-center gap-1"
                >
                  View Registry <ArrowRight size={12} />
                </button>
              </div>
              <div className="space-y-2">
                {matchedLostFound.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => {
                      setActiveTab('lost-found');
                      setIsSearchOpen(false);
                    }}
                    className="w-full p-3 rounded-xl border border-slate-200/80 bg-slate-50/50 hover:bg-slate-100/80 hover:border-slate-300 text-left transition-all flex items-center justify-between gap-3 group"
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span
                          className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                            item.type === 'lost'
                              ? 'bg-rose-100 text-rose-800'
                              : 'bg-emerald-100 text-emerald-800'
                          }`}
                        >
                          {item.type}
                        </span>
                        <span className="text-xs font-bold text-slate-900 group-hover:text-slate-950">
                          {item.itemName}
                        </span>
                        <span className="text-[10px] text-slate-400 font-medium">
                          ({item.category})
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-500 mt-1 line-clamp-1">
                        {item.description}
                      </p>
                      <p className="text-[10px] text-slate-400 mt-0.5">
                        📍 {item.location} • {item.date}
                      </p>
                    </div>
                    <span
                      className={`text-[11px] font-semibold px-2 py-1 rounded-md shrink-0 ${
                        item.status === 'Resolved'
                          ? 'bg-slate-100 text-slate-600'
                          : item.status === 'Claimed'
                          ? 'bg-purple-100 text-purple-800'
                          : 'bg-amber-100 text-amber-800'
                      }`}
                    >
                      {item.status}
                    </span>
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Search Modal Footer */}
        <div className="p-3 bg-slate-100/80 border-t border-slate-200 text-[11px] text-slate-500 flex items-center justify-between px-4 sm:px-6">
          <div className="flex items-center gap-3">
            <span>
              Tip: Press <kbd className="px-1 py-0.5 bg-white border border-slate-300 rounded">ESC</kbd> to exit
            </span>
            <span>
              Filter by <span className="font-semibold text-slate-700">Course, Faculty, or Room</span>
            </span>
          </div>
          <span className="font-medium text-slate-600">CampusHub Information Engine</span>
        </div>
      </div>
    </div>
  );
};
