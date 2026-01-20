-- Migration: Prevent admin/super_admin downgrade or deletion via role change

CREATE OR REPLACE FUNCTION public.validate_role_change(
  p_current_user_id uuid,
  p_target_user_id uuid,
  p_new_role app_role
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_role app_role;
  v_target_current_role app_role;
  v_super_admin_count integer;
BEGIN
  -- Get current user's highest role
  SELECT MAX(role::text) INTO v_current_role
  FROM public.user_roles
  WHERE user_id = p_current_user_id;

  -- Get target user's current role
  SELECT role INTO v_target_current_role
  FROM public.user_roles
  WHERE user_id = p_target_user_id;

  -- RULE 0: Admin or Super Admin roles cannot be downgraded or removed
  IF v_target_current_role IN ('admin'::app_role, 'super_admin'::app_role)
     AND p_new_role <> v_target_current_role THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Admin and Super Admin roles cannot be downgraded or removed'
    );
  END IF;

  -- RULE 1: Only SUPER_ADMIN can assign SUPER_ADMIN role
  IF p_new_role = 'super_admin'::app_role THEN
    IF v_current_role != 'super_admin' THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'Only SUPER_ADMIN can assign SUPER_ADMIN role'
      );
    END IF;
  END IF;

  -- RULE 2: ADMIN can only change between PARTICIPANT <-> HOST
  IF v_current_role = 'admin' THEN
    IF p_new_role NOT IN ('participant'::app_role, 'host'::app_role, 'viewer'::app_role) THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'ADMIN can only assign PARTICIPANT, HOST, or VIEWER roles'
      );
    END IF;
  END IF;

  -- RULE 3: Prevent assigning ADMIN role (only SUPER_ADMIN can do this)
  IF p_new_role = 'admin'::app_role AND v_current_role != 'super_admin' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Only SUPER_ADMIN can assign ADMIN role'
    );
  END IF;

  -- RULE 4: System must always keep at least 1 SUPER_ADMIN
  IF v_target_current_role = 'super_admin' AND p_new_role != 'super_admin' THEN
    SELECT COUNT(*) INTO v_super_admin_count
    FROM public.user_roles
    WHERE role = 'super_admin'::app_role AND user_id != p_target_user_id;

    IF v_super_admin_count = 0 THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'Cannot remove the last SUPER_ADMIN. Assign SUPER_ADMIN to another user first.'
      );
    END IF;
  END IF;

  RETURN jsonb_build_object('success', true);
END;
$$;
