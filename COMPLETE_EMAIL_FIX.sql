-- ===================================================================
-- COMPLETE FIX FOR NEW USER EMAIL NOTIFICATIONS
-- Run this entire script in Supabase SQL Editor
-- ===================================================================

-- Step 1: Fix the handle_new_user trigger
-- ===================================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Create profile for new user
  INSERT INTO public.profiles (user_id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data ->> 'avatar_url', NEW.raw_user_meta_data ->> 'picture')
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url);
  
  -- Assign default participant role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'participant'::app_role)
  ON CONFLICT (user_id, role) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;

-- Step 2: Create missing profiles for existing users
-- ===================================================================

INSERT INTO public.profiles (user_id, email, full_name, avatar_url)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data ->> 'full_name', raw_user_meta_data ->> 'name', split_part(email, '@', 1)),
  COALESCE(raw_user_meta_data ->> 'avatar_url', raw_user_meta_data ->> 'picture')
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM public.profiles)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO public.user_roles (user_id, role)
SELECT id, 'participant'::app_role
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM public.user_roles WHERE role = 'participant')
ON CONFLICT (user_id, role) DO NOTHING;

-- Step 3: Fix role change notifications to send emails
-- ===================================================================

DROP TRIGGER IF EXISTS on_role_added ON public.user_roles;
DROP TRIGGER IF EXISTS on_role_removed ON public.user_roles;

CREATE OR REPLACE FUNCTION public.log_role_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  action_type text;
  role_name text;
  target_user_id uuid;
  admin_full_name text;
  supabase_url text := 'https://mrdhmcpajolvherbbgrb.supabase.co';
  service_role_key text;
  http_response record;
BEGIN
  -- Get service role key from database settings
  BEGIN
    service_role_key := current_setting('app.settings.service_role_key', false);
  EXCEPTION
    WHEN OTHERS THEN
      -- If not set, log warning and continue without sending email
      RAISE WARNING 'Service role key not configured. Email notification will not be sent.';
      service_role_key := NULL;
  END;
  
  -- Determine action type and role
  IF TG_OP = 'INSERT' THEN
    action_type := 'add';
    role_name := NEW.role::text;
    target_user_id := NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    action_type := 'remove';
    role_name := OLD.role::text;
    target_user_id := OLD.user_id;
  ELSE
    RETURN NULL;
  END IF;
  
  -- Log the role change in audit table
  INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
  VALUES (auth.uid(), target_user_id, action_type, role_name::app_role);
  
  -- Get admin's name for the email
  SELECT full_name INTO admin_full_name
  FROM public.profiles
  WHERE user_id = auth.uid();
  
  -- Send email notification via Edge Function (only if service key is configured)
  IF service_role_key IS NOT NULL THEN
    BEGIN
      SELECT * INTO http_response FROM net.http_post(
        url := supabase_url || '/functions/v1/notify-role-change',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || service_role_key
        ),
        body := jsonb_build_object(
          'targetUserId', target_user_id::text,
          'action', action_type,
          'role', role_name,
          'adminName', COALESCE(admin_full_name, 'Administrator')
        ),
        timeout_milliseconds := 5000
      );
      
      RAISE LOG 'Role change notification sent. Status: %', http_response.status;
    EXCEPTION
      WHEN OTHERS THEN
        -- Don't fail the role change if email fails
        RAISE WARNING 'Failed to send role change notification: %', SQLERRM;
    END;
  END IF;
  
  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$;

CREATE TRIGGER on_role_added
  AFTER INSERT ON public.user_roles
  FOR EACH ROW EXECUTE FUNCTION public.log_role_change();

CREATE TRIGGER on_role_removed
  AFTER DELETE ON public.user_roles
  FOR EACH ROW EXECUTE FUNCTION public.log_role_change();

-- Step 4: Grant necessary permissions
-- ===================================================================

GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres, service_role;
GRANT EXECUTE ON FUNCTION public.log_role_change() TO postgres, authenticated, service_role;
GRANT USAGE ON SCHEMA net TO postgres, anon, authenticated, service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA net TO postgres, anon, authenticated, service_role;

-- Step 5: Configure service role key
-- ===================================================================
-- IMPORTANT: Replace 'YOUR_SERVICE_ROLE_KEY' with actual key from:
-- https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb/settings/api
--
-- Uncomment and run this line after replacing the key:
-- ALTER DATABASE postgres SET app.settings.service_role_key = 'YOUR_SERVICE_ROLE_KEY';

-- ===================================================================
-- VERIFICATION QUERIES
-- ===================================================================

-- Check if trigger is active
SELECT tgname, tgenabled 
FROM pg_trigger 
WHERE tgname IN ('on_auth_user_created', 'on_role_added', 'on_role_removed');

-- Check all users have profiles
SELECT 
  COUNT(*) as total_users,
  (SELECT COUNT(*) FROM public.profiles) as users_with_profiles,
  (SELECT COUNT(*) FROM auth.users WHERE id NOT IN (SELECT user_id FROM public.profiles)) as users_without_profiles
FROM auth.users;

-- Check service role key is configured (won't show actual value for security)
SELECT 
  CASE 
    WHEN current_setting('app.settings.service_role_key', true) IS NOT NULL 
    THEN 'Service role key is configured ✓'
    ELSE 'Service role key NOT configured - emails will not send!'
  END as service_key_status;
