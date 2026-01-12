# EngageVision - Local Development Setup Guide

A comprehensive guide to setting up EngageVision on your local machine with your own Supabase backend.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Supabase Configuration](#supabase-configuration)
4. [Environment Configuration](#environment-configuration)
5. [Database Setup](#database-setup)
6. [Authentication Configuration](#authentication-configuration)
7. [Edge Functions Deployment](#edge-functions-deployment)
8. [Running the Application](#running-the-application)
9. [Creating an Admin User](#creating-an-admin-user)
10. [Troubleshooting](#troubleshooting)
11. [Deployment](#deployment)

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
- **npm** or **bun** package manager
- **Git** - [Download](https://git-scm.com/)
- **Supabase CLI** (optional, for edge functions) - [Install Guide](https://supabase.com/docs/guides/cli)

```bash
# Verify installations
node --version    # Should be v18+
npm --version     # Should be v8+
git --version
```

---

## Project Setup

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd engagevision
```

### 2. Install Dependencies

```bash
# Using npm
npm install

# Or using bun
bun install
```

---

## Supabase Configuration

### 1. Create a Supabase Account

1. Go to [supabase.com](https://supabase.com)
2. Sign up for a free account
3. Click **"New Project"**

### 2. Create a New Project

1. Choose your organization
2. Enter a project name (e.g., "engagevision")
3. Set a strong database password (save this securely!)
4. Select a region closest to your users
5. Click **"Create new project"**

### 3. Get Your API Keys

Once the project is created:

1. Go to **Settings** → **API**
2. Note down the following:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **anon/public key**: Starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - **Project ID**: Found in the URL or Settings → General

---

## Environment Configuration

### 1. Create Environment File

Create a `.env` file in the project root:

```bash
touch .env
```

### 2. Add Environment Variables

```env
# Supabase Configuration
VITE_SUPABASE_URL="https://your-project-id.supabase.co"
VITE_SUPABASE_PUBLISHABLE_KEY="your-anon-public-key"
VITE_SUPABASE_PROJECT_ID="your-project-id"
```

### 3. Update Supabase Client (if needed)

The Supabase client at `src/integrations/supabase/client.ts` reads from these environment variables automatically. No changes needed.

---

## Database Setup

### 1. Run the Migration

1. Open your Supabase Dashboard
2. Go to **SQL Editor**
3. Click **"New Query"**
4. Copy the entire contents of `docs/complete-migration.sql`
5. Paste into the SQL Editor
6. Click **"Run"**

This will create:
- ✅ All database tables (profiles, sessions, participants, etc.)
- ✅ Custom enums (app_role, engagement_level, session_status)
- ✅ Security functions (has_role, is_session_host, etc.)
- ✅ Database triggers (user registration, timestamps, audit logs)
- ✅ Row Level Security policies
- ✅ Storage bucket for avatars

### 2. Verify Setup

After running the migration, verify in the Supabase Dashboard:

1. **Table Editor**: Should show 7 tables
2. **Authentication → Users**: Should be empty (ready for sign-ups)
3. **Storage**: Should have an "avatars" bucket

---

## Authentication Configuration

### 1. Configure Email Authentication

1. Go to **Authentication** → **Providers**
2. Ensure **Email** is enabled
3. Configure settings:
   - ✅ Enable email confirmations (or disable for development)
   - ✅ Enable password recovery

### 2. Configure Site URL

1. Go to **Authentication** → **URL Configuration**
2. Set **Site URL**: `http://localhost:8080` (for local development)
3. Add to **Redirect URLs**:
   ```
   http://localhost:8080
   http://localhost:8080/**
   ```

### 3. Email Templates (Optional)

Customize email templates in **Authentication** → **Email Templates**:
- Confirm signup
- Magic Link
- Password recovery
- Email change

---

## Edge Functions Deployment

Edge functions handle background tasks like sending emails and notifications.

### 1. Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Windows (via Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# npm (all platforms)
npm install -g supabase
```

### 2. Login to Supabase

```bash
supabase login
```

### 3. Link Your Project

```bash
supabase link --project-ref your-project-id
```

### 4. Set Required Secrets

The edge functions require certain secrets. Set them in Supabase Dashboard → **Settings** → **Edge Functions** → **Secrets**:

| Secret Name | Description |
|-------------|-------------|
| `RESEND_API_KEY` | API key from [Resend](https://resend.com) for email notifications |

Or via CLI:

```bash
supabase secrets set RESEND_API_KEY=your_resend_api_key
```

### 5. Deploy Edge Functions

```bash
supabase functions deploy notify-consent-withdrawal
supabase functions deploy notify-role-change
supabase functions deploy notify-session-ended
supabase functions deploy notify-session-scheduled
supabase functions deploy send-session-invite
supabase functions deploy send-session-reminders
```

Or deploy all at once:

```bash
supabase functions deploy
```

---

## Running the Application

### 1. Start Development Server

```bash
npm run dev
```

The application will be available at: `http://localhost:8080`

### 2. Create Your First Account

1. Navigate to `http://localhost:8080/auth`
2. Click **"Sign Up"**
3. Enter your email and a strong password
4. Check your email for confirmation (if enabled)

---

## Creating an Admin User

After creating your first account, you'll need to manually assign admin role:

### Option 1: Via Supabase Dashboard

1. Go to **SQL Editor**
2. Run the following query (replace with your user's ID):

```sql
-- First, find your user ID
SELECT id, email FROM auth.users;

-- Then insert admin role (replace 'your-user-id' with actual UUID)
INSERT INTO public.user_roles (user_id, role)
VALUES ('your-user-id', 'admin');

-- Also add host role for full functionality
INSERT INTO public.user_roles (user_id, role)
VALUES ('your-user-id', 'host');
```

### Option 2: Via SQL Editor Script

```sql
-- Make the most recent user an admin and host
DO $$
DECLARE
    latest_user_id uuid;
BEGIN
    SELECT id INTO latest_user_id 
    FROM auth.users 
    ORDER BY created_at DESC 
    LIMIT 1;
    
    -- Add admin role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (latest_user_id, 'admin')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    -- Add host role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (latest_user_id, 'host')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE 'Admin and host roles assigned to user: %', latest_user_id;
END $$;
```

---

## Troubleshooting

### Common Issues

#### 1. "Invalid API key" Error

- Verify your `.env` file has correct values
- Ensure no extra spaces or quotes in the keys
- Restart the dev server after changing `.env`

#### 2. "Permission denied" / RLS Errors

- Ensure you're logged in to the application
- Check that RLS policies were created (run migration again if needed)
- Verify the user has appropriate roles

#### 3. "User not found" After Sign Up

- Check if email confirmation is required
- Look in **Authentication** → **Users** to see if user exists
- Check spam folder for confirmation email

#### 4. Edge Functions Not Working

- Verify secrets are set in Supabase Dashboard
- Check function logs: `supabase functions logs <function-name>`
- Ensure functions are deployed: `supabase functions list`

#### 5. Database Connection Issues

- Check Supabase project is active (not paused)
- Verify project URL is correct
- Check browser console for specific errors

### Debug Commands

```bash
# Check Supabase CLI status
supabase status

# View function logs
supabase functions logs notify-session-scheduled --tail

# List all functions
supabase functions list

# Check project health
supabase db lint
```

---

## Deployment

### Option 1: Deploy with Lovable

1. Push your code to GitHub
2. Connect your repository to Lovable
3. Click **"Publish"** to deploy

### Option 2: Deploy to Vercel

1. Push to GitHub
2. Import project in [Vercel](https://vercel.com)
3. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
   - `VITE_SUPABASE_PROJECT_ID`
4. Deploy

### Option 3: Deploy to Netlify

1. Push to GitHub
2. Import project in [Netlify](https://netlify.com)
3. Set build command: `npm run build`
4. Set publish directory: `dist`
5. Add environment variables
6. Deploy

### Production Checklist

Before going to production, ensure:

- [ ] Email confirmation is enabled
- [ ] Site URL updated to production domain
- [ ] Redirect URLs updated in Supabase
- [ ] Edge functions deployed
- [ ] All secrets configured
- [ ] Database backups enabled (Supabase Pro plan)
- [ ] Rate limiting configured
- [ ] Custom domain connected (optional)

---

## Project Structure

```
engagevision/
├── docs/
│   ├── complete-migration.sql    # Full database setup
│   └── LOCAL_SETUP.md            # This file
├── public/
│   └── ...                       # Static assets
├── src/
│   ├── components/               # React components
│   ├── contexts/                 # React contexts (Auth, etc.)
│   ├── hooks/                    # Custom React hooks
│   ├── integrations/
│   │   └── supabase/
│   │       ├── client.ts         # Supabase client
│   │       └── types.ts          # Database types
│   ├── pages/                    # Page components
│   └── ...
├── supabase/
│   ├── config.toml               # Supabase configuration
│   └── functions/                # Edge functions
│       ├── notify-consent-withdrawal/
│       ├── notify-role-change/
│       ├── notify-session-ended/
│       ├── notify-session-scheduled/
│       ├── send-session-invite/
│       └── send-session-reminders/
├── .env                          # Environment variables (create this)
├── package.json
└── README.md
```

---

## Support & Resources

- **Supabase Documentation**: [supabase.com/docs](https://supabase.com/docs)
- **Lovable Documentation**: [docs.lovable.dev](https://docs.lovable.dev)
- **React Documentation**: [react.dev](https://react.dev)
- **Tailwind CSS**: [tailwindcss.com](https://tailwindcss.com)

---

## License

This project is private. All rights reserved.
