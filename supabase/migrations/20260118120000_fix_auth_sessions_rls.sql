-- Drop the old policy
DROP POLICY IF EXISTS "Authenticated users can view active sessions by link" ON public.sessions;

-- Create new policy allowing both active and scheduled
CREATE POLICY "Authenticated users can view active or scheduled sessions by link"
  ON public.sessions FOR SELECT
  TO authenticated
  USING (status = 'active' OR status = 'scheduled');
