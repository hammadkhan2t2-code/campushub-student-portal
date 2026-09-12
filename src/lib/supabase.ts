import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const isSupabaseConfigured = Boolean(
  supabaseUrl &&
  supabaseAnonKey &&
  supabaseUrl !== 'https://your-project.supabase.co' &&
  supabaseAnonKey !== 'your-anon-key'
);

if (!isSupabaseConfigured) {
  console.info(
    'Supabase environment variables (VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY) are not set. CampusHub is running in high-fidelity offline/local mode with built-in university records.'
  );
}

// Fallback dummy credentials to allow safe client creation without throwing top-level crash
const activeUrl = isSupabaseConfigured && supabaseUrl ? supabaseUrl : 'https://placeholder.supabase.co';
const activeKey = isSupabaseConfigured && supabaseAnonKey ? supabaseAnonKey : 'placeholder-anon-key';

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

