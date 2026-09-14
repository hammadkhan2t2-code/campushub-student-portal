import React, { useEffect, useState } from 'react';
import { Loader2, CheckCircle2, AlertTriangle, ArrowRight, RefreshCw, LogIn } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';

interface AuthCallbackProps {
  onComplete?: () => void;
}

export const AuthCallback: React.FC<AuthCallbackProps> = ({ onComplete }) => {
  const { currentUser, isLoading: authLoading, openAuthModal } = useAuth();
  const { setActiveTab } = useApp();

  const [status, setStatus] = useState<'verifying' | 'success' | 'error'>('verifying');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [processed, setProcessed] = useState(false);

  useEffect(() => {
    let isCancelled = false;

    async function handleAuthCallback() {
      try {
        const url = new URL(window.location.href);
        const code = url.searchParams.get('code');
        const tokenHash = url.searchParams.get('token_hash');
        const type = url.searchParams.get('type') || 'signup';
        const errorParam = url.searchParams.get('error') || (window.location.hash.includes('error=') ? 'access_denied' : null);
        const errorDescription = url.searchParams.get('error_description');

        // Check for error in query or hash
        if (errorParam) {
          const cleanDesc = errorDescription
            ? decodeURIComponent(errorDescription.replace(/\+/g, ' '))
            : 'Authentication failed or your confirmation link has expired.';
          if (!isCancelled) {
            setErrorMessage(cleanDesc);
            setStatus('error');
          }
          return;
        }

        // 1. Handle PKCE code exchange
        if (code) {
          const { data, error } = await supabase.auth.exchangeCodeForSession(code);
          if (error) {
            console.warn('AuthCallback exchangeCodeForSession error:', error.message);
            // Check if session is already present despite error
            const { data: currentSession } = await supabase.auth.getSession();
            if (!currentSession.session) {
              if (!isCancelled) {
                setErrorMessage(error.message || 'Unable to exchange authentication code for a valid session.');
                setStatus('error');
              }
              return;
            }
          }
        }

        // 2. Handle OTP token_hash email verification
        if (tokenHash) {
          const { data, error } = await supabase.auth.verifyOtp({
            token_hash: tokenHash,
            type: (type as any) || 'signup'
          });
          if (error) {
            console.warn('AuthCallback verifyOtp error:', error.message);
            const { data: currentSession } = await supabase.auth.getSession();
            if (!currentSession.session) {
              if (!isCancelled) {
                setErrorMessage(error.message || 'Verification link is invalid or has expired.');
                setStatus('error');
              }
              return;
            }
          }
        }

        // 3. Confirm active session
        const { data: sessionData } = await supabase.auth.getSession();
        if (sessionData.session) {
          if (!isCancelled) {
            setStatus('success');
            setProcessed(true);
          }
        } else {
          // Wait briefly in case onAuthStateChange is in flight
          const timer = setTimeout(async () => {
            const { data: retryData } = await supabase.auth.getSession();
            if (!isCancelled) {
              if (retryData.session) {
                setStatus('success');
                setProcessed(true);
              } else {
                setErrorMessage('No active session found. Please sign in with your credentials.');
                setStatus('error');
              }
            }
          }, 1200);

          return () => clearTimeout(timer);
        }
      } catch (err: any) {
        if (!isCancelled) {
          setErrorMessage(err.message || 'An unexpected error occurred while verifying authentication.');
          setStatus('error');
        }
      }
    }

    handleAuthCallback();

    return () => {
      isCancelled = true;
    };
  }, []);

  // When session is confirmed and currentUser is ready, clean URL and redirect
  useEffect(() => {
    if (status === 'success' && !authLoading && currentUser) {
      // Clean query parameters and hash from browser URL without reloading
      window.history.replaceState({}, document.title, window.location.pathname === '/auth/callback' ? '/' : window.location.pathname);

      const timer = setTimeout(() => {
        if (currentUser.needsProfileCompletion) {
          // First-time Google user: send to profile setup
          setActiveTab('profile');
        } else {
          // Returning user or confirmed user with full profile: go directly to dashboard
          setActiveTab('home');
        }
        if (onComplete) {
          onComplete();
        }
      }, 700);

      return () => clearTimeout(timer);
    }
  }, [status, authLoading, currentUser, setActiveTab, onComplete]);

  return (
    <div className="min-h-screen bg-[#FAF9F6] flex flex-col items-center justify-center p-4 sm:p-6">
      <div className="w-full max-w-md bg-white rounded-3xl p-8 border border-slate-200 shadow-xl text-center space-y-6 animate-in fade-in zoom-in-95 duration-200">
        {/* University Brand Header */}
        <div className="w-16 h-16 rounded-2xl bg-[#0F172A] p-3 shadow-lg flex items-center justify-center mx-auto border border-slate-800">
          <img
            src="/campushub-logo.svg"
            alt="CampusHub Logo"
            className="w-full h-full object-contain"
            referrerPolicy="no-referrer"
          />
        </div>

        {status === 'verifying' && (
          <div className="space-y-3">
            <div className="flex items-center justify-center gap-2 text-slate-900 font-bold text-lg">
              <Loader2 size={22} className="animate-spin text-[#C5A059]" />
              <span>Verifying Authentication</span>
            </div>
            <p className="text-xs text-slate-500 max-w-sm mx-auto leading-relaxed">
              Confirming your credentials with Supabase, establishing your secure session, and restoring your student profile...
            </p>
          </div>
        )}

        {status === 'success' && (
          <div className="space-y-3 animate-in fade-in duration-300">
            <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto border border-emerald-200">
              <CheckCircle2 size={26} />
            </div>
            <h2 className="text-lg font-bold text-slate-900">
              Authentication Confirmed!
            </h2>
            <p className="text-xs text-slate-600 max-w-sm mx-auto leading-relaxed">
              {currentUser?.needsProfileCompletion
                ? `Welcome to CampusHub, ${currentUser.firstName}! Redirecting you to complete your academic profile...`
                : `Welcome back, ${currentUser?.firstName || 'Student'}! Launching your personalized dashboard...`}
            </p>
            <div className="pt-2 flex justify-center">
              <span className="inline-flex items-center gap-2 text-xs font-semibold text-[#C5A059] bg-[#0F172A] px-4 py-2 rounded-xl">
                <span>Entering CampusHub</span>
                <ArrowRight size={14} />
              </span>
            </div>
          </div>
        )}

        {status === 'error' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            <div className="w-12 h-12 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center mx-auto border border-rose-200">
              <AlertTriangle size={26} />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">Authentication Failed</h2>
              <p className="text-xs text-rose-600 mt-1 px-3 py-2 bg-rose-50/70 rounded-xl border border-rose-100 leading-relaxed text-left">
                {errorMessage || 'Your authentication token could not be verified or has expired.'}
              </p>
            </div>
            <p className="text-xs text-slate-500">
              Please sign in with your email or roll number, or request a new verification link.
            </p>
            <div className="flex flex-col sm:flex-row gap-2 pt-2">
              <button
                type="button"
                onClick={() => {
                  window.history.replaceState({}, document.title, '/');
                  setActiveTab('home');
                  if (onComplete) onComplete();
                  openAuthModal('signin');
                }}
                className="flex-1 py-2.5 px-4 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2"
              >
                <LogIn size={15} />
                <span>Student Sign In</span>
              </button>
              <button
                type="button"
                onClick={() => {
                  window.history.replaceState({}, document.title, '/');
                  setActiveTab('home');
                  if (onComplete) onComplete();
                }}
                className="py-2.5 px-4 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition-all"
              >
                <span>Guest Home</span>
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
