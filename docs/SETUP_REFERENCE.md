# Setup Reference Guide

> Previous README documentation - detailed technical setup and development guide

This file serves as a comprehensive reference for developers on setup, configuration, and development practices.

---

## Quick Start

### For Users
1. Visit: **https://engageanalytic.me**
2. Click **"Sign Up"** to create an account
3. Verify your email
4. Login and start using the app!

**Test Accounts** (pre-verified, no email needed):
```
Email: testuser1@engagetest.com
Password: TestPass123!
```

### For Developers
```bash
# Clone the repository
git clone https://github.com/Chandan785/engageanalytics.git
cd "Engage Analytics"

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your Supabase and Resend API keys

# Start development server
npm run dev
# App runs on http://localhost:8081
```

---

## Project Info

**Project**: AI-Powered Engagement Analytics Platform  
**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Last Updated**: January 16, 2026

---

## Key Features

✅ Real-time engagement analytics  
✅ Face detection & recognition  
✅ Gesture detection  
✅ Engagement scoring  
✅ User authentication  
✅ Email notifications  
✅ Profile management  
✅ Admin dashboard  

---

## How to Edit This Code

### Use Your Preferred IDE

Clone this repo and work locally using your preferred IDE. Push changes to your git repository.

The only requirement is having Node.js & npm installed - [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating)

Follow these steps:

```sh
# Step 1: Clone the repository using the project's Git URL.
git clone <YOUR_GIT_URL>

# Step 2: Navigate to the project directory.
cd <YOUR_PROJECT_NAME>

# Step 3: Install the necessary dependencies.
npm i

# Step 4: Start the development server with auto-reloading and an instant preview.
npm run dev
```

### Edit a File Directly in GitHub

- Navigate to the desired file(s).
- Click the "Edit" button (pencil icon) at the top right of the file view.
- Make your changes and commit the changes.

### Use GitHub Codespaces

- Navigate to the main page of your repository.
- Click on the "Code" button (green button) near the top right.
- Select the "Codespaces" tab.
- Click on "New codespace" to launch a new Codespace environment.
- Edit files directly within the Codespace and commit and push your changes once you're done.

---

## Technologies Used

This project is built with:

- **Vite** - Build tool and dev server
- **TypeScript** - Type-safe JavaScript
- **React** - UI Framework
- **shadcn-ui** - Component library
- **Tailwind CSS** - Utility-first CSS framework
- **Supabase** - Backend as a service (PostgreSQL + Auth)
- **Resend** - Email delivery service
- **Vercel** - Frontend hosting and deployment

---

## Deployment

### Deploy to Vercel

```bash
# Option 1: Using Vercel CLI
vercel login
vercel

# Option 2: Connect repository directly
# Visit vercel.com, connect GitHub repo, and auto-deploy
```

### Deploy Supabase Functions

```bash
# Setup CLI
npm install -g supabase

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Deploy functions
supabase functions deploy send-session-invite
supabase functions deploy notify-session-scheduled
```

---

## Email Configuration (Password Reset & Notifications)

**Important:** Email functionality (password reset, notifications) requires proper SMTP configuration.

### Using Resend API

1. **Get Resend API Key:**
   - Sign up at [resend.com](https://resend.com)
   - Navigate to API Keys section
   - Create new API key (copy it)

2. **Add to Environment:**
   ```env
   RESEND_API_KEY=re_YOUR_API_KEY
   SENDER_EMAIL=noreply@yourdomain.com
   ```

3. **Configure in Supabase:**
   - Go to Supabase Dashboard
   - Settings → Auth → SMTP Settings
   - Use Resend provider configuration:
     - SMTP Host: `smtp.resend.io`
     - SMTP Port: `465` (SSL/TLS)
     - SMTP User: `resend`
     - SMTP Password: Your RESEND_API_KEY

4. **Test Email Functionality:**
   - Use password reset feature to test
   - Check email delivery in Resend dashboard

### Troubleshooting Email

**Issue: "Email provider not configured"**
- Verify RESEND_API_KEY is set correctly
- Check Supabase SMTP settings are complete
- Restart dev server after env changes

**Issue: "Emails not arriving"**
- Check Resend dashboard for delivery status
- Verify sender email domain is verified
- Check recipient email spam folder

**Issue: "SMTP connection failed"**
- Verify correct SMTP credentials
- Check firewall/network allows port 465
- Confirm API key has email permissions

---

## Configuring Google Sign-In (Supabase)

If you use Google OAuth for sign-in, complete these steps to avoid errors:

### Step 1: Supabase Configuration

1. In Supabase dashboard, go to **Authentication → Providers**
2. Enable **Google** provider
3. Add OAuth credentials:
   - Client ID (from Google Cloud Console)
   - Client Secret (from Google Cloud Console)

### Step 2: Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable Google+ API:
   - Go to **APIs & Services → Library**
   - Search for "Google+ API"
   - Click **Enable**
4. Create OAuth 2.0 Credentials:
   - Go to **APIs & Services → Credentials**
   - Click **Create Credentials → OAuth Client ID**
   - Choose **Web application**
   - Add authorized redirect URIs:
     ```
     http://localhost:5173/auth/callback
     https://engageanalytic.me/auth/callback
     https://YOUR_PROJECT.supabase.co/auth/v1/callback
     ```
   - Copy Client ID and Client Secret

### Step 3: Supabase Redirect URLs

In Supabase dashboard:

1. Go to **Auth → URL Configuration**
2. Add redirect URLs:
   - `http://localhost:5173/dashboard` (dev)
   - `https://engageanalytic.me/dashboard` (production)

### Step 4: Environment Variables

Ensure these are set:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=YOUR_ANON_KEY
```

### Step 5: Test

1. Start dev server: `npm run dev`
2. Click "Sign in with Google" button
3. Should redirect to Google login, then back to app
4. Check browser console for errors

**Common Issues:**

| Issue | Solution |
|-------|----------|
| "Invalid redirect URI" | Update redirect URIs in Google Console AND Supabase |
| OAuth provider not showing | Enable Google provider in Supabase |
| "Client not authorized" | Verify Client ID is correct |
| CORS errors | Check your domain is in Google Console |

---

## Custom Domain Setup

Configure your custom domain (engageanalytic.me) through your hosting provider's DNS settings.

### For Vercel Custom Domain

1. In Vercel Dashboard:
   - Select your project
   - Go to **Settings → Domains**
   - Add custom domain
   - Follow DNS configuration instructions

2. Update DNS Records:
   - Add `A` record pointing to Vercel IP
   - Or add `CNAME` record if using subdomain

3. Wait for DNS propagation (5-30 minutes)

### Supabase Custom Domain (Optional)

For custom domain on auth endpoints:

1. Go to Supabase Dashboard
2. **Settings → Auth → Custom Domain**
3. Configure your domain and DNS records

---

## Local Development Commands

### Start Dev Server
```bash
npm run dev
```
Runs on: `http://localhost:5173` (or next available port)

### Build for Production
```bash
npm run build
```
Creates optimized `dist/` folder

### Preview Production Build
```bash
npm run preview
```
Serve production build locally

### Lint Code
```bash
npm run lint
```
Check code for errors and style issues

### Format Code
```bash
npm run format
```
Auto-format code with Prettier

---

## Database Setup

### Initial Migration

When you first clone the repo:

```bash
# Link to your Supabase project
supabase link --project-ref YOUR_PROJECT_REF

# Apply all migrations
supabase db push
```

### Create New Migration

```bash
supabase migration new <migration_name>
```
Edit the created SQL file in `supabase/migrations/`

### Apply Migration

```bash
supabase db push
```

---

## Environment Variables Reference

### Required

```env
# Supabase
VITE_SUPABASE_URL=                 # Your Supabase project URL
VITE_SUPABASE_PUBLISHABLE_KEY=     # Anon/Public Key

# Email
RESEND_API_KEY=                    # Resend API key
SENDER_EMAIL=                      # Sender email address
```

### Optional

```env
VITE_APP_URL=                      # App base URL (for links)
VITE_API_URL=                      # API endpoint
DEBUG=true                         # Enable debug logging
```

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 5173
netstat -ano | findstr :5173

# Kill process
taskkill /PID <PID> /F

# Or use different port
npm run dev -- --port 3000
```

### Dependencies Issues

```bash
# Clear node_modules and reinstall
rm -r node_modules
npm install

# Or using Bun
bun install
```

### Supabase Connection Issues

```bash
# Test connection
supabase status

# Check project ref
supabase projects list

# Verify credentials in .env
```

### Build Errors

```bash
# Clear cache and rebuild
npm run build -- --force

# Check for TypeScript errors
npx tsc --noEmit
```

---

## Performance Tips

1. **Use React DevTools** - Profile component renders
2. **Enable Source Maps** - Debug production builds
3. **Monitor Bundle Size** - Use `npm run build` and check `dist/`
4. **Lazy Load Routes** - Use React.lazy() for code splitting
5. **Optimize Images** - Compress before deploying

---

## Security Checklist

- [ ] All secrets in `.env.local`, never in repo
- [ ] HTTPS enabled in production
- [ ] Supabase RLS policies configured
- [ ] Resend API key has minimal permissions
- [ ] Database backups enabled
- [ ] Error monitoring (Sentry) configured

---

## Resources

- **Supabase Docs:** https://supabase.com/docs
- **React Docs:** https://react.dev
- **Vite Docs:** https://vitejs.dev
- **TailwindCSS:** https://tailwindcss.com
- **Shadcn/ui:** https://ui.shadcn.com

---

## Contact & Support

For issues or questions:
- **GitHub Issues:** https://github.com/Chandan785/engageanalytics/issues
- **Email:** support@engageanalytic.me
- **Website:** https://engageanalytic.me
