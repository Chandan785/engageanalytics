-- Add missing profile blocking fields (idempotent)

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_blocked boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS blocked_at timestamp with time zone,
  ADD COLUMN IF NOT EXISTS blocked_by uuid REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS block_reason text;
