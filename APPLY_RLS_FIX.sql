-- URGENT FIX: Apply this SQL in Supabase Dashboard SQL Editor
-- Navigate to: Supabase Dashboard → SQL Editor → New Query → Paste this

-- Step 1: Drop the old restrictive policy
DROP POLICY IF EXISTS "Authenticated users can view active sessions by link" ON public.sessions;

-- Step 2: Create new policy allowing authenticated users to view BOTH active AND scheduled sessions
CREATE POLICY "Authenticated users can view active or scheduled sessions by link"
  ON public.sessions FOR SELECT
  TO authenticated
  USING (status = 'active' OR status = 'scheduled');

-- Verify the policies are correct
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  qual
FROM pg_policies
WHERE tablename = 'sessions'
ORDER BY policyname;
