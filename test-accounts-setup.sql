-- Run this in Supabase SQL Editor to create pre-verified test accounts
-- These accounts will bypass email verification

-- Create test user 1
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  role
) VALUES (
  gen_random_uuid(),
  'testuser1@engagetest.com',
  crypt('TestPass123!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Test User 1"}',
  now(),
  now(),
  '',
  'authenticated'
) ON CONFLICT (email) DO NOTHING;

-- Create test user 2
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  role
) VALUES (
  gen_random_uuid(),
  'testuser2@engagetest.com',
  crypt('TestPass123!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Test User 2"}',
  now(),
  now(),
  '',
  'authenticated'
) ON CONFLICT (email) DO NOTHING;

-- Create test user 3
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  role
) VALUES (
  gen_random_uuid(),
  'testuser3@engagetest.com',
  crypt('TestPass123!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Test User 3"}',
  now(),
  now(),
  '',
  'authenticated'
) ON CONFLICT (email) DO NOTHING;

-- Note: These accounts are already verified (email_confirmed_at is set to now())
-- Your friends can login immediately with:
-- Email: testuser1@engagetest.com, Password: TestPass123!
-- Email: testuser2@engagetest.com, Password: TestPass123!
-- Email: testuser3@engagetest.com, Password: TestPass123!
