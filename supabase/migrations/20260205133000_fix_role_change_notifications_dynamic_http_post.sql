-- Use dynamic EXECUTE to call pg_net http_post only when available

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
  http_schema text;
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

  http_schema := NULL;
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'extensions'
      AND p.proname = 'http_post'
  ) THEN
    http_schema := 'extensions';
  ELSIF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'net'
      AND p.proname = 'http_post'
  ) THEN
    http_schema := 'net';
  END IF;

  IF http_schema IS NOT NULL THEN
    EXECUTE format('SELECT %I.http_post($1, $2, $3)', http_schema)
    USING
      supabase_url || '/functions/v1/notify-role-change',
      jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || service_role_key
      ),
      jsonb_build_object(
        'targetUserId', target_user_id,
        'action', action_type,
        'role', role_name,
        'adminName', COALESCE(admin_profile.full_name, 'Administrator')
      );
  END IF;

  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$;
