-- Add explicit DENY policies for UPDATE and DELETE on engagement_metrics
-- This prevents any modification or deletion of engagement data once recorded

-- Deny all UPDATE operations on engagement_metrics
CREATE POLICY "Deny engagement metrics updates"
ON public.engagement_metrics
FOR UPDATE
TO authenticated
USING (false);

-- Deny all DELETE operations on engagement_metrics
CREATE POLICY "Deny engagement metrics deletion"
ON public.engagement_metrics
FOR DELETE
TO authenticated
USING (false);