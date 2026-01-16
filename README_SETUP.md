# 🎯 ENGAGE Analytics - Real-Time Engagement Analytics Platform

A modern web application for tracking and analyzing engagement metrics during virtual meetings and sessions. Built with React, TypeScript, and Supabase.

---

## 🌐 Live URLs

Access the application at any of these URLs:

- **Primary Domain:** https://engageanalytic.me
- **WWW Subdomain:** https://www.engageanalytic.me
- **Vercel App:** https://engage-analytics.vercel.app

---

## ✨ Key Features

✅ **User Authentication**
- Secure signup and login with email verification
- Role-based access control (Admin, Host, Participant)
- Profile management with avatar uploads

✅ **Session Management**
- Create and schedule sessions
- Invite participants via email
- Real-time session tracking

✅ **Analytics & Tracking**
- Face detection and recognition
- Gesture detection and analysis
- Participant engagement scoring
- Live engagement tracking
- Comprehensive analytics dashboard

✅ **Communication**
- Email notifications for session invites
- Password reset via email
- Role change notifications
- Session reminders

✅ **Admin Features**
- Manage users and roles
- View analytics reports
- Monitor active sessions

---

## 🛠️ Tech Stack

**Frontend:**
- React 18 with TypeScript
- Vite (build tool)
- Tailwind CSS (styling)
- shadcn-ui (component library)
- Supabase JavaScript SDK

**Backend & Database:**
- Supabase (PostgreSQL)
- Supabase Auth
- Supabase Edge Functions
- Row-Level Security (RLS) policies

**Email Service:**
- Resend API (transactional emails)
- Custom domain: `engageanalytic.me`

**Storage:**
- Supabase Storage (avatar uploads)

**Deployment:**
- Vercel (frontend hosting)
- Custom domain with SSL/TLS

---

## 🚀 Quick Start - For Users

### Signup & Login

1. Go to **https://engageanalytic.me**
2. Click **"Sign Up"**
3. Enter your email and password
4. Check your email for verification link
5. Click verification link to confirm
6. Login with your credentials

### Using Pre-Verified Test Accounts

For quick testing without email verification:

| Email | Password |
|-------|----------|
| testuser1@engagetest.com | TestPass123! |
| testuser2@engagetest.com | TestPass123! |
| testuser3@engagetest.com | TestPass123! |

---

## 💻 Development Setup - For Developers

### Prerequisites

- Node.js 16+ 
- npm or bun
- Git
- Supabase account
- Vercel account (for deployment)

### Local Development

**Step 1: Clone & Install**
```bash
git clone https://github.com/Chandan785/engageanalytics.git
cd "Engage Analytics"
npm install
# or
bun install
```

**Step 2: Setup Environment Variables**
```bash
# Copy the example
cp .env.example .env

# Edit .env with your values:
# VITE_SUPABASE_URL=your_supabase_url
# VITE_SUPABASE_PUBLISHABLE_KEY=your_publishable_key
# VITE_SUPABASE_PROJECT_ID=your_project_id
# RESEND_API_KEY=your_resend_api_key
# SENDER_EMAIL=noreply@engageanalytic.me
```

**Step 3: Get Environment Variables**

From [Supabase Dashboard](https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb/settings/api):
- Copy `Project URL` → `VITE_SUPABASE_URL`
- Copy `anon public` key → `VITE_SUPABASE_PUBLISHABLE_KEY`
- Copy Project ID → `VITE_SUPABASE_PROJECT_ID`

From [Resend Dashboard](https://resend.com/api-keys):
- Copy API key → `RESEND_API_KEY`

**Step 4: Run Development Server**
```bash
npm run dev
# App runs on http://localhost:8081
```

**Step 5: Build for Production**
```bash
npm run build
# Output in ./dist folder
```

---

## 🌍 Environment Variables Reference

```env
# Supabase Configuration
VITE_SUPABASE_PROJECT_ID=mrdhmcpajolvherbbgrb
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_Aq5NmwJNHsoU04s9Gc7Jmw_Ostk2N4l
VITE_SUPABASE_URL=https://mrdhmcpajolvherbbgrb.supabase.co

# Email Configuration (Resend API)
RESEND_API_KEY=re_9HcJaUSe_D6rYFRqw9H8Qi27MrtBUb2Vd
SENDER_EMAIL=noreply@engageanalytic.me
```

---

## 📝 Database Schema

### Users
- User profiles with name, organization, avatar
- Role assignments (Admin, Host, Participant)
- Email verification status

### Sessions
- Session metadata (title, description, scheduled time)
- Participant invitations
- Session status tracking

### Analytics
- Face detection results
- Gesture detection data
- Engagement scores
- Participation metrics

---

## 🔐 Security Features

✅ **Authentication & Authorization**
- JWT-based authentication via Supabase
- Row-Level Security (RLS) policies
- Email verification required for signup
- Secure password reset flow

✅ **Data Protection**
- HTTPS/SSL encryption (custom domain)
- Secure API keys management
- Environment variable protection

✅ **Email Security**
- Domain verification (SPF, DKIM, DMARC)
- Verified sender domain
- Transactional email only

---

## 📧 Email Configuration

**Verified Domain:** engageanalytic.me

**Email Types Supported:**
1. **Welcome Email** - New user signup confirmation
2. **Email Verification** - Verify email address
3. **Password Reset** - Password recovery link
4. **Session Invite** - Invite to sessions
5. **Role Change Notification** - Role assignment updates
6. **Session Reminders** - Upcoming session notifications

**DNS Records Configured:**
- MX Records for mail routing
- SPF Record for authentication
- DKIM Record for signing
- DMARC Policy for monitoring

---

## 🚀 Deployment

### Deployed on Vercel

**Deployment Steps:**

1. **Push to GitHub**
```bash
git add .
git commit -m "Your message"
git push origin main
```

2. **Deploy to Vercel**
```bash
vercel --prod
```

3. **Add Environment Variables**
```bash
vercel env add VITE_SUPABASE_URL production
vercel env add VITE_SUPABASE_PUBLISHABLE_KEY production
vercel env add VITE_SUPABASE_PROJECT_ID production
```

4. **Connect Custom Domain**
- In Vercel Dashboard → Domains
- Add `engageanalytic.me`
- Update DNS records in domain provider

### Update Supabase Settings

In [Supabase Auth Settings](https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb/settings/auth):

```
Site URL: https://engageanalytic.me

Redirect URLs:
- https://engageanalytic.me/**
- https://www.engageanalytic.me/**
```

---

## 📱 Project Structure

```
Engage Analytics/
├── src/
│   ├── components/          # React components
│   ├── pages/              # Page components
│   ├── contexts/           # Auth context
│   ├── hooks/              # Custom hooks
│   ├── integrations/       # Supabase client
│   ├── lib/                # Utilities
│   └── assets/             # Images, videos
├── supabase/
│   ├── functions/          # Edge functions
│   ├── migrations/         # Database migrations
│   └── config.toml         # Supabase config
├── public/                 # Static files
├── .env                    # Environment variables
├── vite.config.ts         # Vite configuration
├── tsconfig.json          # TypeScript config
└── package.json           # Dependencies
```

---

## 🧪 Testing

### Manual Testing
1. Signup with new email at https://engageanalytic.me
2. Verify email from inbox
3. Login and explore features
4. Create a test session
5. Invite participants

### Using Test Accounts
```
testuser1@engagetest.com / TestPass123!
testuser2@engagetest.com / TestPass123!
testuser3@engagetest.com / TestPass123!
```

---

## 🐛 Troubleshooting

### Email Not Received
- Check spam folder
- Verify Supabase email settings
- Check domain verification in Namecheap

### Login Issues
- Ensure email is verified
- Clear browser cache and cookies
- Check if account exists

### Session Creation Failed
- Verify user has Host or Admin role
- Check database connection
- Review error logs in Supabase

### Avatar Upload Not Working
- Check Supabase Storage permissions
- Verify image file size < 5MB
- Ensure proper file format (jpg, png, gif)

---

## 📊 Analytics Features

### Face Detection
- Real-time face detection during sessions
- Participant identification
- Face recognition for return users

### Gesture Recognition
- Detects engagement gestures
- Hand raise detection
- Expression analysis

### Engagement Scoring
- Real-time engagement calculation
- Participant-level scores
- Session-level analytics

### Reports
- Session attendance reports
- Engagement metrics over time
- Participant analytics
- Exportable data

---

## 🔄 API & Integrations

### Supabase Edge Functions
- `notify-role-change` - Send email when role changes
- `notify-session-scheduled` - Send session invite
- `notify-session-ended` - Send session summary
- `send-session-reminders` - Send session reminders

### Resend Email API
- Provider: Resend
- Endpoint: smtp.resend.com:587
- Authentication: API key based
- Domain: engageanalytic.me

---

## 📚 Documentation Links

- **Supabase Docs:** https://supabase.com/docs
- **React Docs:** https://react.dev
- **Vite Docs:** https://vitejs.dev
- **Tailwind CSS:** https://tailwindcss.com
- **shadcn-ui:** https://ui.shadcn.com
- **Resend Email:** https://resend.com/docs

---

## 🤝 Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👨‍💼 Support & Contact

For issues, questions, or suggestions:

- **GitHub Issues:** https://github.com/Chandan785/engageanalytics/issues
- **Email:** support@engageanalytic.me
- **Website:** https://engageanalytic.me

---

## 🎯 Roadmap

- [ ] Mobile app (React Native)
- [ ] Advanced AI analytics
- [ ] Slack integration
- [ ] Teams integration
- [ ] Zoom integration
- [ ] API for third-party apps
- [ ] Advanced reporting dashboard
- [ ] Multi-language support

---

## ✅ Checklist for First-Time Users

- [ ] Visited https://engageanalytic.me
- [ ] Signed up with email
- [ ] Verified email from inbox
- [ ] Successfully logged in
- [ ] Updated profile with name/organization
- [ ] Uploaded profile avatar
- [ ] Created a test session
- [ ] Invited another user to session
- [ ] Reviewed analytics dashboard

---

**Last Updated:** January 16, 2026  
**Version:** 1.0.0  
**Status:** ✅ Production Ready

🚀 **Your ENGAGE Analytics platform is ready to track engagement!**
