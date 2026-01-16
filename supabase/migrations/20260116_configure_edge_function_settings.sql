-- Configure Supabase settings for Edge Function invocation

-- Store Supabase URL and service role key in database settings
-- These will be used by triggers to invoke Edge Functions

-- Note: Run these commands in Supabase SQL Editor with your actual service role key

-- Set Supabase URL
ALTER DATABASE postgres SET app.settings.supabase_url = 'https://mrdhmcpajolvherbbgrb.supabase.co';

-- Set service role key (REPLACE WITH YOUR ACTUAL KEY FROM SUPABASE DASHBOARD)
-- Go to: https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb/settings/api
-- Copy the "service_role" secret key (starts with "eyJ...")
-- 
-- Then run this command in SQL Editor:
-- ALTER DATABASE postgres SET app.settings.service_role_key = 'YOUR_SERVICE_ROLE_KEY_HERE';

-- Verify settings (optional - check if values are set)
-- SELECT name, setting FROM pg_settings WHERE name LIKE 'app.settings%';
