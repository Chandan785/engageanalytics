-- Migration: Expand audit logs and add user blocking for SUPER_ADMIN

-- Add block fields to profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_blocked boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS blocked_at timestamp with time zone,
  ADD COLUMN IF NOT EXISTS blocked_by uuid REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS block_reason text;

-- Update audit log action constraint to support additional actions
ALTER TABLE public.role_audit_logs
  DROP CONSTRAINT IF EXISTS role_audit_logs_action_check;

ALTER TABLE public.role_audit_logs
  ADD CONSTRAINT role_audit_logs_action_check
  CHECK (action IN (
    'add',
    'remove',
    'change',
    'transfer',
    'block',
    'unblock',
    'delete_user',
    'create_admin',
    'delete_admin'
  ));

-- Update audit log policies to include SUPER_ADMIN
DROP POLICY IF EXISTS "Admins can view all audit logs" ON public.role_audit_logs;
DROP POLICY IF EXISTS "Admins can insert audit logs" ON public.role_audit_logs;

CREATE POLICY "Admins and Super Admins can view all audit logs"
ON public.role_audit_logs
FOR SELECT
USING (
  has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'super_admin'::app_role)
);

CREATE POLICY "Admins and Super Admins can insert audit logs"
ON public.role_audit_logs
FOR INSERT
WITH CHECK (
  has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'super_admin'::app_role)
);

-- Update profiles policies to allow SUPER_ADMIN view access
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

CREATE POLICY "Admins can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role IN ('admin', 'super_admin')
  )
);

-- Allow SUPER_ADMIN to update any profile (for blocking/unblocking)
DROP POLICY IF EXISTS "Super Admins can update all profiles" ON public.profiles;

CREATE POLICY "Super Admins can update all profiles"
ON public.profiles
FOR UPDATE
TO authenticated
USING (has_role(auth.uid(), 'super_admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'super_admin'::app_role));

-- Function: Block/unblock users (SUPER_ADMIN only)
CREATE OR REPLACE FUNCTION public.set_user_block_status(
  p_super_admin_id uuid,
  p_target_user_id uuid,
  p_blocked boolean,
  p_reason text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_is_super_admin boolean;
  v_target_is_super_admin boolean;
  v_super_admin_count integer;
  v_role app_role;
BEGIN
  SELECT has_role(p_super_admin_id, 'super_admin'::app_role)
  INTO v_is_super_admin;

  IF NOT v_is_super_admin THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Only SUPER_ADMIN can block or unblock users'
    );
  END IF;

  IF p_super_admin_id = p_target_user_id THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'You cannot block yourself'
    );
  END IF;

  SELECT has_role(p_target_user_id, 'super_admin'::app_role)
  INTO v_target_is_super_admin;

  IF p_blocked AND v_target_is_super_admin THEN
    SELECT COUNT(*) INTO v_super_admin_count
    FROM public.user_roles
    WHERE role = 'super_admin'::app_role AND user_id != p_target_user_id;

    IF v_super_admin_count = 0 THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'Cannot block the last SUPER_ADMIN. Assign another SUPER_ADMIN first.'
      );
    END IF;
  END IF;

  UPDATE public.profiles
  SET
    is_blocked = p_blocked,
    blocked_at = CASE WHEN p_blocked THEN now() ELSE NULL END,
    blocked_by = CASE WHEN p_blocked THEN p_super_admin_id ELSE NULL END,
    block_reason = CASE WHEN p_blocked THEN p_reason ELSE NULL END
  WHERE user_id = p_target_user_id;

  SELECT COALESCE(
    (SELECT role FROM public.user_roles WHERE user_id = p_target_user_id LIMIT 1),
    'participant'::app_role
  )
  INTO v_role;

  INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
  VALUES (
    p_super_admin_id,
    p_target_user_id,
    CASE WHEN p_blocked THEN 'block' ELSE 'unblock' END,
    v_role
  );

  RETURN jsonb_build_object('success', true);
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_user_block_status(uuid, uuid, boolean, text)
TO authenticated, service_role;
