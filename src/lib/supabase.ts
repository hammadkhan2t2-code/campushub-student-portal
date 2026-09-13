import { createClient, SupabaseClient } from '@supabase/supabase-js';

// Resolves Supabase credentials from Vite import.meta.env with server and build-time fallbacks
const rawUrl: string =
  (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env.VITE_SUPABASE_URL) ||
  (typeof process !== 'undefined' && process.env?.VITE_SUPABASE_URL) ||
  'https://gfvadvqmsfmhlhwkgden.supabase.co';

const rawAnonKey: string =
  (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env.VITE_SUPABASE_ANON_KEY) ||
  (typeof process !== 'undefined' && process.env?.VITE_SUPABASE_ANON_KEY) ||
  'sb_publishable_K7ptyYnUXqqwARCzgXhOwQ_sKzkVORm';

// Clean and validate Supabase configuration values (stripping whitespace and accidental trailing slashes)
const cleanUrl = typeof rawUrl === 'string' ? rawUrl.trim().replace(/\/+$/, '') : '';
const cleanAnonKey = typeof rawAnonKey === 'string' ? rawAnonKey.trim() : '';

export const isSupabaseConfigured = Boolean(
  cleanUrl &&
  cleanAnonKey &&
  cleanUrl.startsWith('http') &&
  cleanUrl !== 'https://your-project.supabase.co' &&
  cleanAnonKey !== 'your-anon-key'
);

if (!isSupabaseConfigured) {
  console.warn(
    'Supabase environment variables (VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY) are not set or are using defaults. CampusHub requires Supabase as single source of truth for authentication and database.'
  );
}

// Active configuration endpoint
const activeUrl = isSupabaseConfigured ? cleanUrl : 'https://gfvadvqmsfmhlhwkgden.supabase.co';
const activeKey = isSupabaseConfigured ? cleanAnonKey : 'sb_publishable_K7ptyYnUXqqwARCzgXhOwQ_sKzkVORm';

export const supabase: SupabaseClient = createClient(
  activeUrl,
  activeKey,
  {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true
    }
  }
);
