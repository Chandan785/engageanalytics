-- Add immutability policies for role_audit_logs and user_roles
-- Audit logs should never be modifiable once created

-- Deny UPDATE on role_audit_logs (audit logs must be immutable)
CREATE POLICY "Deny audit log updates"
ON public.role_audit_logs
FOR UPDATE
TO authenticated
USING (false);

-- Deny DELETE on role_audit_logs (audit logs must be immutable)
CREATE POLICY "Deny audit log deletion"
ON public.role_audit_logs
FOR DELETE
TO authenticated
USING (false);

-- Also add INSERT/UPDATE/DELETE deny policies for anon role on critical tables
CREATE POLICY "Deny anon insert on profiles"
ON public.profiles
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on profiles"
ON public.profiles
FOR UPDATE
TO anon
USING (false);

CREATE POLICY "Deny anon delete on profiles"
ON public.profiles
FOR DELETE
TO anon
USING (false);

CREATE POLICY "Deny anon insert on sessions"
ON public.sessions
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on sessions"
ON public.sessions
FOR UPDATE
TO anon
USING (false);

CREATE POLICY "Deny anon delete on sessions"
ON public.sessions
FOR DELETE
TO anon
USING (false);

CREATE POLICY "Deny anon insert on participants"
ON public.participants
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on participants"
ON public.participants
FOR UPDATE
TO anon
USING (false);

CREATE POLICY "Deny anon delete on participants"
ON public.participants
FOR DELETE
TO anon
USING (false);

CREATE POLICY "Deny anon insert on engagement_metrics"
ON public.engagement_metrics
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon insert on user_roles"
ON public.user_roles
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on user_roles"
ON public.user_roles
FOR UPDATE
TO anon
USING (false);

CREATE POLICY "Deny anon delete on user_roles"
ON public.user_roles
FOR DELETE
TO anon
USING (false);

CREATE POLICY "Deny anon insert on role_audit_logs"
ON public.role_audit_logs
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon insert on session_reports"
ON public.session_reports
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on session_reports"
ON public.session_reports
FOR UPDATE
TO anon
USING (false);

CREATE POLICY "Deny anon delete on session_reports"
ON public.session_reports
FOR DELETE
TO anon
USING (false);