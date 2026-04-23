import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

/**
 * Supabase client — public (anon) access only.
 * Used for read-only queries on the /setor page.
 */
export const supabase = createClient(supabaseUrl, supabaseAnonKey)
