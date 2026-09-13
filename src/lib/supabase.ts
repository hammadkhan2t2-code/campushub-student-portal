import { createClient, SupabaseClient } from '@supabase/supabase-js';

const rawUrl = import.meta.env.VITE_SUPABASE_URL;
const rawAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

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
const activeUrl = isSupabaseConfigured ? cleanUrl : 'https://placeholder.supabase.co';
const activeKey = isSupabaseConfigured ? cleanAnonKey : 'placeholder-anon-key';

export const supabase: SupabaseClient = createClient(
  activeUrl,
  activeKey,
  {
    auth: {
      persistSession: isSupabaseConfigured,
      autoRefreshToken: isSupabaseConfigured,
      detectSessionInUrl: isSupabaseConfigured
    }
  }
);



