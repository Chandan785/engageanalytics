-- Migration: Add SUPER_ADMIN role and transfer functionality
-- This migration adds SUPER_ADMIN role and ensures at least one SUPER_ADMIN exists

-- Step 1: Add super_admin to app_role enum
ALTER TYPE public.app_role ADD VALUE 'super_admin' BEFORE 'admin';

-- Step 2: Create function to validate role changes
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
  v_error jsonb;
BEGIN
  -- Get current user's highest role
  SELECT MAX(role::text) INTO v_current_role
  FROM public.user_roles
  WHERE user_id = p_current_user_id;
  
  -- Get target user's current role
  SELECT role INTO v_target_current_role
  FROM public.user_roles
  WHERE user_id = p_target_user_id;
  
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

-- Step 3: Create function to safely transfer SUPER_ADMIN ownership
CREATE OR REPLACE FUNCTION public.transfer_super_admin_ownership(
  p_current_super_admin_id uuid,
  p_new_super_admin_id uuid,
  p_downgrade_current boolean DEFAULT true
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_role app_role;
  v_target_exists boolean;
  v_error jsonb;
BEGIN
  -- Verify current user is SUPER_ADMIN
  SELECT role INTO v_current_role
  FROM public.user_roles
  WHERE user_id = p_current_super_admin_id;
  
  IF v_current_role != 'super_admin' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Only SUPER_ADMIN can transfer ownership'
    );
  END IF;
  
  -- Verify target user exists
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = p_new_super_admin_id)
  INTO v_target_exists;
  
  IF NOT v_target_exists THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Target user does not exist'
    );
  END IF;
  
  -- Can't transfer to same user
  IF p_current_super_admin_id = p_new_super_admin_id THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Cannot transfer ownership to the same user'
    );
  END IF;
  
  -- Step 1: Assign SUPER_ADMIN role to new user
  DELETE FROM public.user_roles
  WHERE user_id = p_new_super_admin_id AND role = 'super_admin'::app_role;
  
  INSERT INTO public.user_roles (user_id, role)
  VALUES (p_new_super_admin_id, 'super_admin'::app_role)
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Step 2: Optionally downgrade current SUPER_ADMIN to ADMIN
  IF p_downgrade_current THEN
    DELETE FROM public.user_roles
    WHERE user_id = p_current_super_admin_id AND role = 'super_admin'::app_role;
    
    INSERT INTO public.user_roles (user_id, role)
    VALUES (p_current_super_admin_id, 'admin'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Log the transfer in audit
  INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
  VALUES (p_current_super_admin_id, p_new_super_admin_id, 'transfer', 'super_admin'::app_role);
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'SUPER_ADMIN ownership transferred successfully'
  );
END;
$$;

-- Step 4: Create function to change user role with validation
CREATE OR REPLACE FUNCTION public.change_user_role(
  p_admin_user_id uuid,
  p_target_user_id uuid,
  p_new_role app_role
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_validation jsonb;
BEGIN
  -- Validate the role change
  SELECT public.validate_role_change(p_admin_user_id, p_target_user_id, p_new_role)
  INTO v_validation;
  
  IF NOT (v_validation->>'success')::boolean THEN
    RETURN v_validation;
  END IF;
  
  -- Delete all existing roles and assign new role
  DELETE FROM public.user_roles
  WHERE user_id = p_target_user_id;
  
  INSERT INTO public.user_roles (user_id, role)
  VALUES (p_target_user_id, p_new_role)
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Log the role change
  INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
  VALUES (p_admin_user_id, p_target_user_id, 'change', p_new_role);
  
  RETURN jsonb_build_object(
    'success', true,
    'message', 'Role changed successfully'
  );
END;
$$;

-- Step 5: Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.validate_role_change(uuid, uuid, app_role) 
  TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.transfer_super_admin_ownership(uuid, uuid, boolean) 
  TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.change_user_role(uuid, uuid, app_role) 
  TO authenticated, service_role;
