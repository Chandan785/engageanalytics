-- Add explicit policies to deny unauthenticated access to all tables
-- These are PERMISSIVE policies that check for authenticated users
-- Combined with existing RESTRICTIVE policies, this adds defense in depth

-- Profiles: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for profiles"
ON public.profiles
FOR SELECT
TO anon
USING (false);

-- Engagement metrics: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for engagement_metrics"
ON public.engagement_metrics
FOR SELECT
TO anon
USING (false);

-- Participants: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for participants"
ON public.participants
FOR SELECT
TO anon
USING (false);

-- Sessions: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for sessions"
ON public.sessions
FOR SELECT
TO anon
USING (false);

-- Session reports: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for session_reports"
ON public.session_reports
FOR SELECT
TO anon
USING (false);

-- User roles: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for user_roles"
ON public.user_roles
FOR SELECT
TO anon
USING (false);

-- Role audit logs: Add policy requiring authentication for SELECT
CREATE POLICY "Require authentication for role_audit_logs"
ON public.role_audit_logs
FOR SELECT
TO anon
USING (false);