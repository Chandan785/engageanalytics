-- Fix: Prevent ADMIN from modifying SUPER_ADMIN roles

-- Replace overly broad policy that allowed admins to manage all roles
DROP POLICY IF EXISTS "Admins can manage all roles" ON public.user_roles;

-- Allow users to view their own roles (keep existing policy)
-- (Policy "Users can view their own roles" remains unchanged)

-- Allow admins and super admins to view all roles
DROP POLICY IF EXISTS "Admins can view all roles" ON public.user_roles;
CREATE POLICY "Admins can view all roles"
  ON public.user_roles
  FOR SELECT
  USING (
    public.has_role(auth.uid(), 'admin')
    OR public.has_role(auth.uid(), 'super_admin')
  );

-- Allow inserts for admins (non-super_admin) and super_admins (all)
DROP POLICY IF EXISTS "Admins can insert roles" ON public.user_roles;
CREATE POLICY "Admins can insert roles"
  ON public.user_roles
  FOR INSERT
  WITH CHECK (
    public.has_role(auth.uid(), 'super_admin')
    OR (
      public.has_role(auth.uid(), 'admin')
      AND role NOT IN ('admin'::app_role, 'super_admin'::app_role)
    )
  );

-- Allow updates for admins (non-super_admin) and super_admins (all)
DROP POLICY IF EXISTS "Admins can update roles" ON public.user_roles;
CREATE POLICY "Admins can update roles"
  ON public.user_roles
  FOR UPDATE
  USING (
    (
      public.has_role(auth.uid(), 'super_admin')
      OR (
        public.has_role(auth.uid(), 'admin')
        AND role NOT IN ('admin'::app_role, 'super_admin'::app_role)
      )
    )
    AND (
      role NOT IN ('admin'::app_role, 'super_admin'::app_role)
      OR (
        role = 'super_admin'::app_role
        AND (
          SELECT COUNT(*)
          FROM public.user_roles ur
          WHERE ur.role = 'super_admin'::app_role
            AND ur.user_id <> user_roles.user_id
        ) > 0
      )
    )
  )
  WITH CHECK (
    public.has_role(auth.uid(), 'super_admin')
    OR (
      public.has_role(auth.uid(), 'admin')
      AND role <> 'super_admin'::app_role
    )
  );

-- Allow deletes for admins (non-super_admin) and super_admins (all)
DROP POLICY IF EXISTS "Admins can delete roles" ON public.user_roles;
CREATE POLICY "Admins can delete roles"
  ON public.user_roles
  FOR DELETE
  USING (
    (
      public.has_role(auth.uid(), 'super_admin')
      OR (
        public.has_role(auth.uid(), 'admin')
        AND role NOT IN ('admin'::app_role, 'super_admin'::app_role)
      )
    )
    AND (
      role NOT IN ('admin'::app_role, 'super_admin'::app_role)
      OR (
        role = 'super_admin'::app_role
        AND (
          SELECT COUNT(*)
          FROM public.user_roles ur
          WHERE ur.role = 'super_admin'::app_role
            AND ur.user_id <> user_roles.user_id
        ) > 0
      )
    )
  );
