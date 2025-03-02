const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// Create Supabase client with anonymous key (for client-side operations)
const supabaseClient = createClient(supabaseUrl, supabaseAnonKey);

// Create Supabase admin client with service role key (for admin operations)
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

module.exports = {
  supabaseClient,
  supabaseAdmin
}; 