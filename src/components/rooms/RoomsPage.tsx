import React, { useState } from 'react';
import {
  DoorOpen,
  Search,
  Building,
  Users,
  Clock,
  Layers,
  Sparkles,
  ArrowRight,
  Filter,
  CheckCircle2
} from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { RoomDetailModal } from './RoomDetailModal';
import { Room } from '../../types';

export const RoomsPage: React.FC = () => {
  const { rooms, timetable, selectedRoom, setSelectedRoom, setSelectedTeacher, setActiveTab } = useApp();

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBuilding, setSelectedBuilding] = useState<string>('All');
  const [selectedType, setSelectedType] = useState<string>('All');

  // Distinct buildings
  const buildings = ['All', ...Array.from(new Set(rooms.map((r) => r.building)))];
  const types = ['All', 'Lecture Hall', 'Computer Lab', 'Hardware Lab', 'Seminar Room', 'Auditorium'];

  const filteredRooms = rooms.filter((room) => {
    if (selectedBuilding !== 'All' && room.building !== selectedBuilding) return false;
    if (selectedType !== 'All' && room.type !== selectedType) return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const match =
        room.roomNumber.toLowerCase().includes(q) ||
        room.building.toLowerCase().includes(q) ||
        room.type.toLowerCase().includes(q) ||
        room.facilities.some((f) => f.toLowerCase().includes(q));
      if (!match) return false;
    }
    return true;
  });

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Top Banner */}
      <div className="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#047857] mb-1">
            <DoorOpen size={15} />
            <span>Classroom & Lab Directory</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-[#0F172A] tracking-tight">
            Campus Rooms
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
            Search classrooms, lecture halls, and laboratory suites with live today&apos;s class rosters.
          </p>
        </div>

        <div className="flex items-center gap-2 text-xs font-semibold px-3 py-1.5 bg-slate-100 rounded-xl text-slate-700">
          <span>Total Classrooms: <strong className="text-slate-900">{rooms.length}</strong></span>
        </div>
      </div>

      {/* Search & Filter Toolbar */}
      <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-sm space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          {/* Search Box */}
          <div className="relative sm:col-span-1">
            <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by room # (e.g. CS-101) or facility..."
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            />
          </div>

          {/* Building Filter */}
          <div>
            <select
              value={selectedBuilding}
              onChange={(e) => setSelectedBuilding(e.target.value)}
              className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none truncate"
            >
              {buildings.map((b) => (
                <option key={b} value={b}>
                  {b === 'All' ? 'All Campus Buildings' : b}
                </option>
              ))}
            </select>
          </div>

          {/* Room Type Filter */}
          <div>
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              className="w-full px-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            >
              {types.map((t) => (
                <option key={t} value={t}>
                  {t === 'All' ? 'All Facility Types' : t}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Rooms Grid */}
      {filteredRooms.length === 0 ? (
        <div className="bg-white rounded-3xl p-12 text-center border border-slate-200/80 shadow-sm">
          <div className="w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
            <DoorOpen size={28} />
          </div>
          <h3 className="text-base font-bold text-slate-900">No rooms match your search</h3>
          <p className="text-xs text-slate-500 mt-1">
            Try searching for another room number or selecting &quot;All Campus Buildings&quot;.
          </p>
          <button
            onClick={() => {
              setSearchQuery('');
              setSelectedBuilding('All');
              setSelectedType('All');
            }}
            className="mt-4 px-4 py-2 bg-[#0F172A] text-white text-xs font-bold rounded-xl shadow-sm hover:bg-slate-800 transition-all"
          >
            Reset Room Filters
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRooms.map((room) => {
            // Get today's classes for this room
            const classesToday = timetable.filter(
              (tt) => tt.classroomNumber.trim().toLowerCase() === room.roomNumber.trim().toLowerCase() && tt.day === 'Monday'
            );

            return (
              <div
                key={room.id}
                className="bg-white rounded-3xl border border-slate-200/80 hover:border-slate-300 shadow-sm hover:shadow-md transition-all flex flex-col justify-between overflow-hidden group"
              >
                <div className="p-6">
                  {/* Top Card Header */}
                  <div className="flex items-start justify-between gap-3 mb-3">
                    <div>
                      <span className="text-[10px] font-bold uppercase tracking-wider text-[#C5A059] block mb-0.5">
                        {room.type}
                      </span>
                      <h3 className="text-xl font-bold font-mono text-[#0F172A] group-hover:text-indigo-950">
                        {room.roomNumber}
                      </h3>
                    </div>
                    <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-slate-100 text-slate-700 border border-slate-200 shrink-0">
                      {room.capacity} Seats
                    </span>
                  </div>

                  <p className="text-xs text-slate-500 flex items-center gap-1.5 mb-4">
                    <Building size={14} className="text-slate-400 shrink-0" />
                    <span>{room.building} ({room.floor})</span>
                  </p>

                  {/* Facilities Chips */}
                  <div className="flex flex-wrap gap-1.5 mb-5">
                    {room.facilities.slice(0, 3).map((f) => (
                      <span
                        key={f}
                        className="text-[10px] font-medium bg-slate-100 text-slate-600 px-2 py-0.5 rounded-md truncate max-w-[150px]"
                      >
                        {f}
                      </span>
                    ))}
                    {room.facilities.length > 3 && (
                      <span className="text-[10px] font-semibold text-slate-400 self-center">
                        +{room.facilities.length - 3} more
                      </span>
                    )}
                  </div>

                  {/* Today's Classes preview in this room */}
                  <div className="border-t border-slate-100 pt-4">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-xs font-bold uppercase tracking-wider text-slate-600 flex items-center gap-1">
                        <Clock size={13} className="text-[#C5A059]" />
                        <span>Today&apos;s Classes</span>
                      </span>
                      <span className="text-[11px] font-semibold text-slate-400">
                        {classesToday.length} sessions
                      </span>
                    </div>

                    {classesToday.length === 0 ? (
                      <p className="text-xs text-slate-400 italic py-1">
                        No lectures scheduled in this room today
                      </p>
                    ) : (
                      <div className="space-y-2">
                        {classesToday.slice(0, 2).map((cls) => (
                          <div
                            key={cls.id}
                            className="p-2.5 rounded-xl bg-slate-50 border border-slate-100 text-xs"
                          >
                            <div className="flex items-center justify-between font-medium text-slate-900">
                              <span className="font-bold truncate max-w-[160px]">
                                {cls.courseName}
                              </span>
                              <span className="font-mono text-[11px] text-slate-600 shrink-0">
                                {cls.startTime}
                              </span>
                            </div>
                            <div className="flex items-center justify-between text-[11px] text-slate-500 mt-1">
                              <span>Instructor: {cls.teacherName}</span>
                              <span className="text-[10px] font-semibold text-emerald-700">
                                Sec {cls.section}
                              </span>
                            </div>
                          </div>
                        ))}
                        {classesToday.length > 2 && (
                          <p className="text-[11px] text-[#C5A059] font-medium text-center">
                            +{classesToday.length - 2} more session(s) today
                          </p>
                        )}
                      </div>
                    )}
                  </div>
                </div>

                {/* Card Action Footer */}
                <div className="p-4 bg-slate-50/70 border-t border-slate-100 flex items-center justify-between">
                  <span className="text-xs text-slate-500 font-medium">
                    {classesToday.length > 0 ? (
                      <span className="flex items-center gap-1 text-[#047857] font-semibold">
                        <span className="w-2 h-2 rounded-full bg-[#047857]" />
                        In use today
                      </span>
                    ) : (
                      <span className="text-slate-400">Available room</span>
                    )}
                  </span>

                  <button
                    onClick={() => setSelectedRoom(room)}
                    className="text-xs font-bold text-[#0F172A] hover:text-[#C5A059] flex items-center gap-1 transition-colors"
                  >
                    <span>View Room Details</span>
                    <ArrowRight size={13} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Room Detail Modal */}
      {selectedRoom && (
        <RoomDetailModal
          room={selectedRoom}
          onClose={() => setSelectedRoom(null)}
        />
      )}
    </div>
  );
};
