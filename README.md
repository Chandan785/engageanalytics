# 🎯 ENGAGE Analytics

**AI-Powered Real-Time Engagement Analytics Platform for Virtual Meetings**

---

## 🌐 Live Application URLs

> **Access the application now:**

🔗 **Primary Domain:** https://engageanalytic.me  
🔗 **WWW Subdomain:** https://www.engageanalytic.me  
🔗 **Vercel Backup:** https://engage-analytics.vercel.app  

---

## 📋 Project Info

**Project**: AI-Powered Engagement Analytics Platform  
**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Last Updated**: January 16, 2026

---

## ⚡ Quick Start

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

**For detailed setup instructions, see [README_SETUP.md](./README_SETUP.md)**

---

## ✨ Key Features

✅ Real-time engagement analytics  
✅ Face detection & recognition  
✅ Gesture detection  
✅ Engagement scoring  
✅ User authentication  
✅ Email notifications  
✅ Profile management  
✅ Admin dashboard  

---

## How can I edit this code?

There are several ways of editing your application.

**Use your preferred IDE**

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

**Edit a file directly in GitHub**

- Navigate to the desired file(s).
- Click the "Edit" button (pencil icon) at the top right of the file view.
- Make your changes and commit the changes.

**Use GitHub Codespaces**

- Navigate to the main page of your repository.
- Click on the "Code" button (green button) near the top right.
- Select the "Codespaces" tab.
- Click on "New codespace" to launch a new Codespace environment.
- Edit files directly within the Codespace and commit and push your changes once you're done.

## What technologies are used for this project?

This project is built with:

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS

## How can I deploy this project?

Deploy this project using your preferred hosting service (Vercel, Netlify, AWS, etc.).

## Email Configuration (Password Reset & Notifications)

**Important:** Email functionality (password reset, notifications) requires SMTP configuration.

See [RESEND_EMAIL_SETUP.md](./RESEND_EMAIL_SETUP.md) for detailed instructions on:
- Setting up Resend API for emails
- Configuring Supabase SMTP settings
- Testing email functionality
- Troubleshooting common issues

**Quick Setup:**
1. Get a Resend API key from [resend.com](https://resend.com)
2. Configure SMTP in Supabase Project Settings > Auth > SMTP Settings
3. Update `.env` with your `RESEND_API_KEY` and `SENDER_EMAIL`

## Configuring Google Sign-In (Supabase)

If you use Google OAuth for sign-in, make sure you complete these steps to avoid errors during sign-in:

1. In Supabase dashboard, go to Authentication -> Providers and enable **Google**. Add the OAuth Client ID and Client Secret created in Google Cloud Console.
2. Under the same Authentication settings, add your app redirect URL to **Redirect URLs**. For local development this is typically:

   `http://localhost:5173/dashboard`

   For production, add your deployed origin + `/dashboard` (e.g., `https://app.example.com/dashboard`).
3. In Google Cloud Console, create OAuth credentials (OAuth Client ID) and add the same redirect URL(s) in the OAuth consent / credentials configuration.
4. Ensure the following env vars are set in your `.env` or hosting environment:

   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`

After these steps, Google sign-in should work without the "Invalid redirect" or provider configuration errors.

## Custom Domain Setup

Configure your custom domain (engageanalytic.me) through your hosting provider's DNS settings.
