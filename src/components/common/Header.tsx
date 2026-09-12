import React, { useState } from 'react';
import {
  Search,
  Calendar,
  DoorOpen,
  Users,
  PackageSearch,
  UserCircle,
  Menu,
  X,
  Bell,
  LogOut,
  Sparkles,
  ChevronRight,
  ShieldCheck,
  Home
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';
import { ActiveTab } from '../../types';
import { getStudentEnrolledClasses, getPeshawarDateTime } from '../../utils/studentScheduleUtils';
import { formatUserRollNumber } from '../../utils/rollNumberUtils';

export const Header: React.FC = () => {
  const { currentUser, isAuthenticated, signOut, openAuthModal } = useAuth();
  const { activeTab, setActiveTab, setIsSearchOpen, lostFoundItems, timetable } = useApp();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isProfileDropdownOpen, setIsProfileDropdownOpen] = useState(false);
  const [showNotificationPanel, setShowNotificationPanel] = useState(false);

  const navItems: { id: ActiveTab; label: string; icon: React.ElementType }[] = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'timetable', label: 'Timetable', icon: Calendar },
    { id: 'rooms', label: 'Rooms', icon: DoorOpen },
    { id: 'teachers', label: 'Teachers', icon: Users },
    { id: 'lost-found', label: 'Lost & Found', icon: PackageSearch },
    { id: 'profile', label: 'Student Profile', icon: UserCircle }
  ];

  // Quick stats for notifications using current Pakistan/Peshawar time
  const peshawarTime = getPeshawarDateTime();
  const recentLostFound = lostFoundItems.slice(0, 3);
  const todaysClassesCount = peshawarTime.isWeekend
    ? 0
    : currentUser
    ? getStudentEnrolledClasses(timetable, currentUser).filter((c) => c.day === peshawarTime.weekday).length
    : timetable.filter((c) => c.day === peshawarTime.weekday && c.section === 'A').length;

  return (
    <header className="sticky top-0 z-40 bg-[#0F172A] text-white border-b border-slate-800 shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Brand Logo - Abstract Geometric Academic Visuals */}
          <div className="flex items-center gap-6">
            <button
              onClick={() => setActiveTab('home')}
              className="flex items-center gap-3 group text-left focus:outline-none"
            >
              {/* Official CampusHub Logo */}
              <div className="relative w-[40px] h-[40px] sm:w-[44px] sm:h-[44px] flex items-center justify-center shrink-0">
                <img
                  src="/campushub-logo.svg"
                  alt="CampusHub Logo"
                  className="w-full h-full object-contain select-none"
                  referrerPolicy="no-referrer"
                />
              </div>
              <div>
                <div className="flex items-center gap-1.5">
                  <span className="text-lg font-bold tracking-tight text-white group-hover:text-amber-100 transition-colors">
                    CampusHub
                  </span>
                </div>
                <p className="text-[11px] text-slate-400 font-medium tracking-wide hidden sm:block">
                  Student Academic Portal
                </p>
              </div>
            </button>

            {/* Desktop Navigation */}
            <nav className="hidden lg:flex items-center space-x-1 pl-4 border-l border-slate-800">
              {navItems.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                return (
                  <button
                    key={item.id}
                    onClick={() => setActiveTab(item.id)}
                    className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-sm font-medium transition-all ${
                      isActive
                        ? 'bg-[#1E293B] text-amber-200 border border-[#C5A059]/30 shadow-sm'
                        : 'text-slate-300 hover:text-white hover:bg-slate-800/60'
                    }`}
                  >
                    <Icon
                      size={17}
                      className={isActive ? 'text-[#C5A059]' : 'text-slate-400'}
                    />
                    <span>{item.label}</span>
                  </button>
                );
              })}
            </nav>
          </div>

          {/* Right Header Controls */}
          <div className="flex items-center gap-2 sm:gap-3">
            {/* Global Search Button */}
            <button
              onClick={() => setIsSearchOpen(true)}
              className="flex items-center gap-2 px-3 py-1.5 sm:px-4 sm:py-2 text-xs sm:text-sm bg-slate-800/80 hover:bg-slate-800 text-slate-300 rounded-xl border border-slate-700/80 hover:border-slate-600 transition-all shadow-inner group"
              title="Search teachers, rooms, courses, timetable, lost & found"
            >
              <Search size={15} className="text-[#C5A059] group-hover:scale-110 transition-transform" />
              <span className="hidden md:inline text-slate-300">Quick search...</span>
              <kbd className="hidden sm:inline-block px-1.5 py-0.5 text-[10px] bg-slate-900 text-slate-400 rounded border border-slate-700">
                ⌘K
              </kbd>
            </button>

            {/* Notifications Bell */}
            <div className="relative">
              <button
                onClick={() => setShowNotificationPanel(!showNotificationPanel)}
                className="p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-xl transition-colors relative"
                aria-label="Campus alerts"
              >
                <Bell size={19} />
                <span className="absolute top-1.5 right-1.5 w-2.5 h-2.5 bg-[#C5A059] rounded-full ring-2 ring-[#0F172A]" />
              </button>

              {/* Notification Popover */}
              {showNotificationPanel && (
                <div
                  className="absolute right-0 mt-2 w-80 sm:w-88 bg-white text-slate-900 rounded-2xl shadow-2xl border border-slate-200 z-50 p-4 animate-in fade-in zoom-in-95 duration-150"
                  onClick={() => setShowNotificationPanel(false)}
                >
                  <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-3">
                    <div className="flex items-center gap-2">
                      <div className="w-2 h-2 rounded-full bg-[#047857]" />
                      <span className="text-xs font-bold uppercase tracking-wider text-slate-500">
                        Campus Notifications
                      </span>
                    </div>
                    <span className="text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full">
                      Active
                    </span>
                  </div>
                  <div className="space-y-2.5 text-xs">
                    <div className="p-2.5 rounded-xl bg-slate-50 border border-slate-100 flex gap-2.5 items-start">
                      <div className="w-6 h-6 rounded-lg bg-[#0F172A] text-[#C5A059] flex items-center justify-center shrink-0 text-xs font-bold">
                        <Calendar size={13} />
                      </div>
                      <div>
                        <p className="font-semibold text-slate-800">
                          {todaysClassesCount} classes scheduled today
                        </p>
                        <p className="text-slate-500 mt-0.5">
                          Section {currentUser?.section || 'A'} • Check your timetable for room updates.
                        </p>
                      </div>
                    </div>

                    <div className="p-2.5 rounded-xl bg-amber-50/70 border border-amber-100 flex gap-2.5 items-start">
                      <div className="w-6 h-6 rounded-lg bg-amber-600 text-white flex items-center justify-center shrink-0">
                        <PackageSearch size={13} />
                      </div>
                      <div>
                        <p className="font-semibold text-amber-900">
                          {recentLostFound.length} recent Lost & Found notices
                        </p>
                        <p className="text-amber-700 mt-0.5">
                          Latest: {recentLostFound[0]?.itemName}
                        </p>
                      </div>
                    </div>
                  </div>
                  <button
                    onClick={() => {
                      setActiveTab('lost-found');
                      setShowNotificationPanel(false);
                    }}
                    className="w-full mt-3 py-2 text-center text-xs font-semibold text-slate-700 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors"
                  >
                    View Lost & Found Desk →
                  </button>
                </div>
              )}
            </div>

            {/* Authenticated User Status or Sign In Button */}
            {isAuthenticated && currentUser ? (
              <div className="relative">
                <button
                  onClick={() => setIsProfileDropdownOpen(!isProfileDropdownOpen)}
                  className="flex items-center gap-2.5 pl-2 pr-1 sm:pr-3 py-1 bg-slate-800/80 hover:bg-slate-800 rounded-xl border border-slate-700 transition-all text-left"
                >
                  <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#1E293B] to-[#334155] border border-[#C5A059]/40 flex items-center justify-center font-semibold text-xs text-amber-200">
                    {currentUser.firstName[0]}
                    {currentUser.lastName[0]}
                  </div>
                  <div className="hidden sm:block">
                    <p className="text-xs font-semibold text-white leading-tight">
                      {currentUser.firstName} {currentUser.lastName}
                    </p>
                    <p className="text-[10px] text-slate-400 font-mono">
                      {formatUserRollNumber(currentUser)}
                    </p>
                  </div>
                </button>

                {/* Profile Dropdown Menu */}
                {isProfileDropdownOpen && (
                  <div
                    className="absolute right-0 mt-2 w-56 bg-white text-slate-900 rounded-2xl shadow-xl border border-slate-200 z-50 py-2 animate-in fade-in zoom-in-95 duration-150"
                    onMouseLeave={() => setIsProfileDropdownOpen(false)}
                  >
                    <div className="px-4 py-2.5 border-b border-slate-100">
                      <p className="text-xs font-semibold text-slate-900">
                        {currentUser.firstName} {currentUser.lastName}
                      </p>
                      <p className="text-[11px] text-slate-500 font-mono">
                        {formatUserRollNumber(currentUser)}
                      </p>
                      <span className="inline-block mt-1 text-[10px] px-2 py-0.5 rounded bg-emerald-50 text-emerald-700 font-medium">
                        {currentUser.degree} • Sem {currentUser.semester}
                      </span>
                    </div>

                    <button
                      onClick={() => {
                        setActiveTab('profile');
                        setIsProfileDropdownOpen(false);
                      }}
                      className="w-full flex items-center gap-2.5 px-4 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50 transition-colors text-left"
                    >
                      <UserCircle size={16} className="text-slate-400" />
                      <span>My Student Profile</span>
                    </button>

                    <button
                      onClick={() => {
                        setActiveTab('timetable');
                        setIsProfileDropdownOpen(false);
                      }}
                      className="w-full flex items-center gap-2.5 px-4 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50 transition-colors text-left"
                    >
                      <Calendar size={16} className="text-slate-400" />
                      <span>My Semester Timetable</span>
                    </button>

                    <div className="border-t border-slate-100 my-1" />

                    <button
                      onClick={() => {
                        signOut();
                        setIsProfileDropdownOpen(false);
                      }}
                      className="w-full flex items-center gap-2.5 px-4 py-2 text-xs font-medium text-rose-600 hover:bg-rose-50 transition-colors text-left"
                    >
                      <LogOut size={16} />
                      <span>Sign Out</span>
                    </button>
                  </div>
                )}
              </div>
            ) : (
              <button
                onClick={() => openAuthModal('signin')}
                className="flex items-center gap-2 px-3.5 py-1.5 text-xs sm:text-sm font-semibold rounded-xl bg-[#C5A059] hover:bg-[#B38E46] text-[#0F172A] shadow-sm transition-all"
              >
                <span>Sign In</span>
              </button>
            )}

            {/* Mobile Menu Button */}
            <button
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              className="lg:hidden p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-xl transition-colors"
              aria-label="Toggle navigation menu"
            >
              {isMobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer Menu */}
      {isMobileMenuOpen && (
        <div className="lg:hidden bg-[#0A101D] border-b border-slate-800 px-4 pt-2 pb-4 space-y-1 animate-in slide-in-from-top-4 duration-200">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => {
                  setActiveTab(item.id);
                  setIsMobileMenuOpen(false);
                }}
                className={`w-full flex items-center justify-between px-4 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-[#1E293B] text-amber-200 border border-[#C5A059]/40'
                    : 'text-slate-300 hover:bg-slate-800/80 hover:text-white'
                }`}
              >
                <div className="flex items-center gap-3">
                  <Icon
                    size={18}
                    className={isActive ? 'text-[#C5A059]' : 'text-slate-400'}
                  />
                  <span>{item.label}</span>
                </div>
                <ChevronRight size={16} className="text-slate-600" />
              </button>
            );
          })}

          <div className="pt-3 mt-2 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
            <span>CampusHub • v2.4</span>
            <span className="flex items-center gap-1 text-emerald-400">
              <ShieldCheck size={13} />
              Verified Student Portal
            </span>
          </div>
        </div>
      )}
    </header>
  );
};
