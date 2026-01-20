-- Query to find existing sessions with join links
SELECT 
  id, 
  title, 
  status, 
  join_link, 
  scheduled_for, 
  created_at
FROM public.sessions 
WHERE join_link IS NOT NULL 
ORDER BY created_at DESC 
LIMIT 5;
