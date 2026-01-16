-- Fix role change notification to actually send emails via Edge Function

-- Drop existing triggers
DROP TRIGGER IF EXISTS on_role_added ON public.user_roles;
DROP TRIGGER IF EXISTS on_role_removed ON public.user_roles;

-- Update the log_role_change function to also invoke the email notification Edge Function
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
  admin_profile record;
  supabase_url text;
  service_role_key text;
BEGIN
  -- Get Supabase URL and service role key from vault
  supabase_url := current_setting('app.settings.supabase_url', true);
  service_role_key := current_setting('app.settings.service_role_key', true);
  
  -- If not in vault, use environment defaults
  IF supabase_url IS NULL THEN
    supabase_url := 'https://mrdhmcpajolvherbbgrb.supabase.co';
  END IF;
  
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
  
  -- Log the role change
  INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
  VALUES (auth.uid(), target_user_id, action_type, role_name::app_role);
  
  -- Get admin's profile for the email
  SELECT full_name INTO admin_profile
  FROM public.profiles
  WHERE user_id = auth.uid();
  
  -- Call the Edge Function to send notification email
  -- Using pg_net extension to make HTTP request
  PERFORM net.http_post(
    url := supabase_url || '/functions/v1/notify-role-change',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_role_key
    ),
    body := jsonb_build_object(
      'targetUserId', target_user_id,
      'action', action_type,
      'role', role_name,
      'adminName', COALESCE(admin_profile.full_name, 'Administrator')
    )
  );
  
  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$;

-- Recreate triggers
CREATE TRIGGER on_role_added
  AFTER INSERT ON public.user_roles
  FOR EACH ROW EXECUTE FUNCTION public.log_role_change();

CREATE TRIGGER on_role_removed
  AFTER DELETE ON public.user_roles
  FOR EACH ROW EXECUTE FUNCTION public.log_role_change();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA net TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA net TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA net TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA net TO postgres, anon, authenticated, service_role;
