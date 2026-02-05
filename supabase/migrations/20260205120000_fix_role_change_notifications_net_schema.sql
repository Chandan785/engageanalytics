-- Fix role change notifications when pg_net is installed in extensions schema

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
  supabase_url := current_setting('app.settings.supabase_url', true);
  service_role_key := current_setting('app.settings.service_role_key', true);

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

  INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
  VALUES (auth.uid(), target_user_id, action_type, role_name::app_role);

  SELECT full_name INTO admin_profile
  FROM public.profiles
  WHERE user_id = auth.uid();

  BEGIN
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
  EXCEPTION
    WHEN invalid_schema_name OR undefined_function THEN
      PERFORM extensions.http_post(
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
  END;

  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$;
