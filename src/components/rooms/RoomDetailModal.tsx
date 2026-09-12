import React from 'react';
import {
  X,
  DoorOpen,
  Building,
  Users,
  Clock,
  CheckCircle2,
  AlertCircle,
  Calendar,
  Layers,
  Sparkles
} from 'lucide-react';
import { Room, TimetableEntry } from '../../types';
import { useApp } from '../../context/AppContext';

interface RoomDetailModalProps {
  room: Room;
  onClose: () => void;
}

export const RoomDetailModal: React.FC<RoomDetailModalProps> = ({ room, onClose }) => {
  const { timetable, setSelectedTeacher, setActiveTab } = useApp();

  // Schedule for this room today (e.g. Monday)
  const roomScheduleToday: TimetableEntry[] = timetable.filter(
    (tt) => tt.classroomNumber.trim().toLowerCase() === room.roomNumber.trim().toLowerCase() && tt.day === 'Monday'
  );

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-6 overflow-y-auto animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="w-full max-w-2xl bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-[#0F172A] text-white p-6 relative">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-[#C5A059] text-[#0F172A] flex items-center justify-center font-mono font-bold text-sm shadow-md">
                <DoorOpen size={20} />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h2 className="text-xl font-bold font-mono tracking-tight">{room.roomNumber}</h2>
                  <span className="text-[10px] uppercase font-bold px-2 py-0.5 rounded-full bg-slate-800 text-amber-200 border border-slate-700">
                    {room.type}
                  </span>
                </div>
                <p className="text-xs text-slate-400 mt-0.5 flex items-center gap-1.5">
                  <Building size={13} />
                  <span>{room.building} • {room.floor}</span>
                </p>
              </div>
            </div>

            <button
              onClick={onClose}
              className="p-1.5 rounded-full text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            >
              <X size={18} />
            </button>
          </div>

          {/* Quick Stats Banner */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 mt-5 pt-4 border-t border-slate-800/80 text-xs">
            <div>
              <span className="text-slate-400 block text-[10px] uppercase">Seating Capacity</span>
              <span className="font-bold text-white text-sm">{room.capacity} Students</span>
            </div>
            <div>
              <span className="text-slate-400 block text-[10px] uppercase">Classes Today</span>
              <span className="font-bold text-[#C5A059] text-sm">{roomScheduleToday.length} Sessions</span>
            </div>
            <div className="col-span-2 sm:col-span-1">
              <span className="text-slate-400 block text-[10px] uppercase">Room Status</span>
              <span className="font-bold text-emerald-400 text-sm flex items-center gap-1">
                <span className="w-2 h-2 rounded-full bg-emerald-400" />
                Operational
              </span>
            </div>
          </div>
        </div>

        {/* Content Body */}
        <div className="p-6 space-y-6 overflow-y-auto">
          {/* Facilities & Amenities */}
          <div>
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 mb-2.5 flex items-center gap-1.5">
              <Layers size={14} className="text-[#C5A059]" />
              <span>Equipped Facilities & Technology</span>
            </h3>
            <div className="flex flex-wrap gap-2">
              {room.facilities.map((fac) => (
                <span
                  key={fac}
                  className="px-3 py-1.5 rounded-xl bg-slate-100 text-slate-800 text-xs font-medium border border-slate-200/80"
                >
                  ✓ {fac}
                </span>
              ))}
            </div>
          </div>

          {/* Today's Classes in this room */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 flex items-center gap-1.5">
                <Calendar size={14} className="text-emerald-600" />
                <span>Today&apos;s Class Schedule ({roomScheduleToday.length})</span>
              </h3>
              <span className="text-[11px] text-slate-400 font-mono">Monday Roster</span>
            </div>

            {roomScheduleToday.length === 0 ? (
              <div className="p-8 text-center bg-slate-50 rounded-2xl border border-slate-200/80">
                <p className="text-xs font-bold text-slate-700">No scheduled classes in {room.roomNumber} today</p>
                <p className="text-[11px] text-slate-500 mt-0.5">
                  This room is currently available for open student study or faculty appointments.
                </p>
              </div>
            ) : (
              <div className="space-y-2.5">
                {roomScheduleToday.map((entry) => (
                  <div
                    key={entry.id}
                    className="p-4 rounded-2xl border border-slate-200 bg-slate-50/60 hover:bg-slate-100/70 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs"
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-900 text-sm">
                          {entry.courseName}
                        </span>
                        <span className="font-mono text-[10px] bg-slate-200 text-slate-700 px-1.5 py-0.5 rounded font-bold">
                          {entry.courseCode}
                        </span>
                      </div>
                      <p className="text-slate-500 mt-1">
                        Teacher:{' '}
                        <strong className="text-slate-800">{entry.teacherName}</strong> • {entry.department} (Sec {entry.section})
                      </p>
                    </div>

                    <div className="sm:text-right shrink-0">
                      <div className="flex items-center gap-1 font-mono font-bold text-slate-900 sm:justify-end">
                        <Clock size={13} className="text-[#C5A059]" />
                        <span>{entry.startTime} – {entry.endTime}</span>
                      </div>
                      <span className="text-[10px] uppercase font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full mt-1 inline-block">
                        {entry.type}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Modal Footer */}
        <div className="p-4 bg-slate-50 border-t border-slate-200 flex items-center justify-between text-xs text-slate-500">
          <span>CampusHub Classroom Management</span>
          <button
            onClick={onClose}
            className="px-4 py-2 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl font-bold transition-all"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
