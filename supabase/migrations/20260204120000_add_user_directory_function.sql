-- Function: get_user_directory
-- Provides a complete user list for admin/super_admin dashboards and backfills missing profiles/roles

CREATE OR REPLACE FUNCTION public.get_user_directory()
RETURNS TABLE (
  user_id uuid,
  email text,
  full_name text,
  last_login_at timestamptz,
  roles app_role[],
  is_blocked boolean,
  blocked_at timestamptz,
  block_reason text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  IF NOT (has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'super_admin'::app_role)) THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- Backfill missing profiles
  INSERT INTO public.profiles (user_id, email, full_name, avatar_url)
  SELECT 
    u.id,
    u.email,
    COALESCE(u.raw_user_meta_data ->> 'full_name', u.raw_user_meta_data ->> 'name', u.email),
    COALESCE(u.raw_user_meta_data ->> 'avatar_url', u.raw_user_meta_data ->> 'picture')
  FROM auth.users u
  WHERE NOT EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
  )
  ON CONFLICT (user_id) DO NOTHING;

  -- Ensure all users have at least the participant role
  INSERT INTO public.user_roles (user_id, role)
  SELECT u.id, 'participant'::app_role
  FROM auth.users u
  WHERE NOT EXISTS (
    SELECT 1 FROM public.user_roles r WHERE r.user_id = u.id
  )
  ON CONFLICT DO NOTHING;

  RETURN QUERY
  SELECT
    p.user_id,
    p.email,
    p.full_name,
    p.last_login_at,
    COALESCE(array_agg(r.role) FILTER (WHERE r.role IS NOT NULL), '{}'::app_role[]) AS roles,
    p.is_blocked,
    p.blocked_at,
    p.block_reason
  FROM public.profiles p
  LEFT JOIN public.user_roles r ON r.user_id = p.user_id
  GROUP BY p.user_id, p.email, p.full_name, p.last_login_at, p.is_blocked, p.blocked_at, p.block_reason
  ORDER BY p.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_user_directory() TO authenticated;
