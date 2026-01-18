-- Allow anonymous users to view minimal session details needed for the join page
-- Context: Participants opening a shared join link in a fresh browser are not yet
-- authenticated. The existing policy only allows SELECT for the "authenticated"
-- role, which causes the client query to return no rows and the UI to show
-- "Session not found" even when the session is live.

-- Grant SELECT to the anon role for sessions that are either active or scheduled.
-- Participants still must sign in to actually join; this only allows reading
-- the row to render the Join Session page.
DROP POLICY IF EXISTS "Anonymous can view active or scheduled sessions by link" ON public.sessions;
CREATE POLICY "Anonymous can view active or scheduled sessions by link"
  ON public.sessions FOR SELECT
  TO anon
  USING (status = 'active' OR status = 'scheduled');
