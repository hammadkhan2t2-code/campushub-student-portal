/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { AppProvider, useApp } from './context/AppContext';
import { Header } from './components/common/Header';
import { AuthModal } from './components/auth/AuthModal';
import { GlobalSearchModal } from './components/common/GlobalSearchModal';
import { ToastContainer } from './components/common/ToastContainer';
import { DashboardView } from './components/dashboard/DashboardView';
import { TimetablePage } from './components/timetable/TimetablePage';
import { RoomsPage } from './components/rooms/RoomsPage';
import { TeachersPage } from './components/teachers/TeachersPage';
import { LostFoundPage } from './components/lostfound/LostFoundPage';
import { StudentProfilePage } from './components/profile/StudentProfilePage';
import { DatabaseErrorBanner } from './components/common/DatabaseErrorBanner';
import { AuthCallback } from './components/auth/AuthCallback';
import {
  GraduationCap,
  Sparkles,
  ShieldCheck,
  HeartHandshake,
  ExternalLink,
  MapPin
} from 'lucide-react';

const MainLayout: React.FC = () => {
  const { activeTab, setActiveTab } = useApp();
  const { currentUser } = useAuth();
  const [isAuthCallback, setIsAuthCallback] = React.useState(() => {
    const path = window.location.pathname;
    const search = window.location.search;
    const hash = window.location.hash;
    return (
      path.startsWith('/auth/callback') ||
      search.includes('code=') ||
      search.includes('token_hash=') ||
      (hash.includes('access_token=') && !hash.includes('#/'))
    );
  });

  if (isAuthCallback) {
    return <AuthCallback onComplete={() => setIsAuthCallback(false)} />;
  }

  return (
    <div className="min-h-screen bg-[#FAF9F6] text-slate-900 flex flex-col font-sans selection:bg-[#C5A059]/20 selection:text-[#0F172A]">
      {/* Top Application Header */}
      <Header />

      {/* Main Page Body */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <DatabaseErrorBanner />
        {activeTab === 'home' && <DashboardView />}
        {activeTab === 'timetable' && <TimetablePage />}
        {activeTab === 'rooms' && <RoomsPage />}
        {activeTab === 'teachers' && <TeachersPage />}
        {activeTab === 'lost-found' && <LostFoundPage />}
        {activeTab === 'profile' && <StudentProfilePage />}
      </main>

      {/* Professional Academic Footer */}
      <footer className="bg-[#0F172A] text-white border-t border-slate-800 mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8 pb-8 border-b border-slate-800">
            {/* Brand column */}
            <div className="md:col-span-2 space-y-3">
              <div className="flex items-center gap-2.5">
                <div className="w-[36px] h-[36px] sm:w-[40px] sm:h-[40px] flex items-center justify-center shrink-0">
                  <img
                    src="/campushub-logo.svg"
                    alt="CampusHub Logo"
                    className="w-full h-full object-contain select-none"
                    referrerPolicy="no-referrer"
                  />
                </div>
                <span className="font-extrabold text-lg tracking-tight text-white font-serif">
                  Campus<span className="text-[#C5A059]">Hub</span>
                </span>
                <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-slate-800 text-slate-300 border border-slate-700">
                  Peshawar
                </span>
              </div>
              <p className="text-xs text-slate-400 max-w-md leading-relaxed">
                CampusHub is a student-focused campus information platform designed for students of a university in Peshawar. Fast, reliable access to lecture timetables, classroom availability, faculty directories, and campus lost &amp; found.
              </p>
              <div className="flex items-center gap-2 text-xs text-[#C5A059]">
                <MapPin size={13} />
                <span>Peshawar, Khyber Pakhtunkhwa, Pakistan</span>
              </div>
            </div>

            {/* Quick Navigation */}
            <div>
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 mb-3">
                Campus Services
              </h4>
              <ul className="space-y-2 text-xs text-slate-400">
                <li>
                  <button
                    onClick={() => setActiveTab('timetable')}
                    className="hover:text-white transition-colors"
                  >
                    Academic Timetable
                  </button>
                </li>
                <li>
                  <button
                    onClick={() => setActiveTab('rooms')}
                    className="hover:text-white transition-colors"
                  >
                    Classrooms &amp; Labs
                  </button>
                </li>
                <li>
                  <button
                    onClick={() => setActiveTab('teachers')}
                    className="hover:text-white transition-colors"
                  >
                    Teacher Directory
                  </button>
                </li>
                <li>
                  <button
                    onClick={() => setActiveTab('lost-found')}
                    className="hover:text-white transition-colors"
                  >
                    Lost &amp; Found Registry
                  </button>
                </li>
                <li>
                  <button
                    onClick={() => setActiveTab('profile')}
                    className="hover:text-white transition-colors"
                  >
                    Student Records &amp; Profile
                  </button>
                </li>
              </ul>
            </div>

            {/* System Status & Community Notice */}
            <div>
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-300 mb-3">
                Platform Status
              </h4>
              <div className="space-y-2.5 text-xs text-slate-400">
                <div className="flex items-center gap-2 text-emerald-400">
                  <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                  <span>Schedules Synced (Fall 2026)</span>
                </div>
                <p className="text-[11px] text-slate-500 leading-normal">
                  Press <kbd className="px-1.5 py-0.5 rounded bg-slate-800 text-slate-300 font-mono text-[10px] border border-slate-700">⌘K</kbd> anywhere to search classes, faculty, or classrooms.
                </p>
                <div className="pt-2 text-[11px] text-slate-400 flex items-center gap-1">
                  <ShieldCheck size={14} className="text-[#C5A059]" />
                  <span>Student Data Privacy Assured</span>
                </div>
              </div>
            </div>
          </div>

          {/* Mandatory Disclaimers */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 text-xs text-slate-500">
            <p>
              &copy; {new Date().getFullYear()} CampusHub Peshawar. Designed by and for university students.
            </p>
            <p className="text-[11px] text-slate-500">
              Disclaimer: Independent student portal. Not an official university website.
            </p>
          </div>
        </div>
      </footer>

      {/* Global Overlays & Modals */}
      <AuthModal />
      <GlobalSearchModal />
      <ToastContainer />
    </div>
  );
};

export default function App() {
  return (
    <AuthProvider>
      <AppProvider>
        <MainLayout />
      </AppProvider>
    </AuthProvider>
  );
}

