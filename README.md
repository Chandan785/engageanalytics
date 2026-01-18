# ENGAGE Analytics

> **AI-Powered Engagement Analytics for Virtual Meetings**
> 
> Stop Guessing Who's Actually Engaged. Measure attention, not just attendance.

[![Live Demo](https://img.shields.io/badge/Live%20Demo-engageanalytic.me-blue?style=flat-square)](https://engageanalytic.me)
[![GitHub](https://img.shields.io/badge/GitHub-Chandan785%2Fengageanalytics-black?style=flat-square&logo=github)](https://github.com/Chandan785/engageanalytics)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Compliance](https://img.shields.io/badge/Compliance-SOC%202%20%7C%20GDPR-blue?style=flat-square)]()

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Environment Setup](#environment-setup)
- [Running Locally](#running-locally)
- [Deployment](#deployment)
- [Architecture](#architecture)
- [Security & Privacy](#security--privacy)

---

## 🎯 Overview

**ENGAGE Analytics** is a real-time engagement tracking platform for virtual meetings that uses AI-powered computer vision to measure participant attention and engagement levels. Unlike traditional meeting tools that only track presence, ENGAGE provides actionable insights into:

- **Face Presence Detection**: Detects if participants are physically present at their camera
- **Attention Metrics**: Measures eye gaze focus and head pose engagement
- **Engagement Scoring**: Classifies participants into 4 engagement levels (Fully Engaged, Partially Engaged, Passively Present, Away)
- **Privacy-First Design**: All video processing happens locally—no video is uploaded or stored

### Access the Application

🔗 **Live Domain:** https://engageanalytic.me  
🔗 **WWW Subdomain:** https://www.engageanalytic.me  
🔗 **Vercel Backup:** https://engage-analytics.vercel.app  

---

## ✨ Features

### For Session Hosts

- ✅ **Schedule & Launch Sessions**: Plan meetings in advance or start instantly
- ✅ **Live Engagement Dashboard**: Real-time visualization of participant engagement
- ✅ **Participant Tracking**: See who's present and their attention levels
- ✅ **Session Reports**: Detailed analytics post-session
- ✅ **Consent Management**: Full control over data collection permissions
- ✅ **Email Notifications**: Alerts when participants withdraw consent

### For Participants

- ✅ **Join via Link**: One-click join links (no login required initially)
- ✅ **Transparency**: Clear consent dialogs before tracking starts
- ✅ **Privacy Control**: Ability to withdraw consent at any time
- ✅ **Local Processing**: Camera feed never leaves your device

### For Administrators

- ✅ **User Management**: Manage hosts, participants, and viewers
- ✅ **Role Assignment**: Fine-grained role-based access control
- ✅ **Analytics Dashboard**: Platform-wide metrics
- ✅ **Audit Logs**: Complete trail of user actions

---

## 🛠 Technology Stack

### Frontend

```
React 18               - UI Framework
TypeScript             - Type-safe JavaScript
Vite                   - Build tool
TailwindCSS            - Styling
Shadcn/ui              - Component library
React Router v6        - Client-side routing
Lucide Icons           - Icon set
```

### Backend & Services

```
Supabase               - PostgreSQL + Auth + Real-time
Node.js (Edge Fn.)    - Serverless functions
Resend                 - Email delivery
```

### Deployment

```
Vercel                 - Frontend hosting & Edge Network
Supabase Cloud         - Database & Auth hosting
```

---

## 📁 Project Structure

```
engage-analytics/
├── README.md                          # Main documentation
├── package.json                       # Project dependencies
├── bun.lockb                          # Bun lockfile
├── vite.config.ts                     # Vite configuration
├── tsconfig.json                      # TypeScript config
├── tsconfig.app.json                  # App TypeScript config
├── tsconfig.node.json                 # Node TypeScript config
├── tailwind.config.ts                 # TailwindCSS config
├── eslint.config.js                   # ESLint configuration
├── postcss.config.js                  # PostCSS config
├── index.html                         # Entry point
├── vercel.json                        # Vercel deployment config
├── components.json                    # Shadcn/ui config
│
├── src/                               # Source code
│   ├── main.tsx                       # App entry point
│   ├── App.tsx                        # Main App component
│   ├── App.css                        # Global app styles
│   ├── index.css                      # Base/reset styles
│   ├── vite-env.d.ts                  # Vite type definitions
│   │
│   ├── pages/                         # Page components
│   │   ├── Index.tsx                  # Landing page
│   │   ├── Auth.tsx                   # Login/signup page
│   │   ├── Dashboard.tsx              # Main user dashboard
│   │   ├── AdminDashboard.tsx         # Admin panel
│   │   ├── Sessions.tsx               # Sessions list
│   │   ├── SessionNew.tsx             # Create new session
│   │   ├── SessionDetail.tsx          # Session details view
│   │   ├── SessionHistory.tsx         # Session history
│   │   ├── LiveSession.tsx            # Live tracking page
│   │   ├── JoinSession.tsx            # Join session via link
│   │   ├── Analytics.tsx              # Analytics dashboard
│   │   ├── ParticipantDashboard.tsx   # Participant view
│   │   ├── Profile.tsx                # User profile
│   │   ├── ResetPassword.tsx          # Password reset
│   │   ├── Support.tsx                # Support page
│   │   └── NotFound.tsx               # 404 page
│   │
│   ├── components/                    # Reusable components
│   │   ├── AppHeader.tsx              # Navigation header
│   │   ├── Logo.tsx                   # Logo component
│   │   ├── NavLink.tsx                # Navigation link
│   │   ├── ProtectedRoute.tsx         # Route guard
│   │   ├── RoleBasedRedirect.tsx      # Role-based routing
│   │   ├── ImageLightbox.tsx          # Image lightbox
│   │   ├── MFAVerification.tsx        # MFA verification
│   │   ├── TwoFactorSetup.tsx         # 2FA setup wizard
│   │   ├── PasswordStrengthIndicator.tsx # Password strength meter
│   │   │
│   │   ├── admin/                     # Admin components
│   │   │   ├── UserRoleManagement.tsx # Manage user roles
│   │   │   ├── SessionManagement.tsx  # Manage sessions
│   │   │   └── AnalyticsOverview.tsx  # Platform analytics
│   │   │
│   │   ├── analytics/                 # Analytics components
│   │   │   ├── ParticipantDistributionChart.tsx
│   │   │   ├── EngagementTrendChart.tsx
│   │   │   └── ExportReport.tsx
│   │   │
│   │   ├── live-tracking/             # Live session components
│   │   │   ├── VideoFeed.tsx          # Video display
│   │   │   ├── EngagementMetrics.tsx  # Metrics display
│   │   │   ├── ParticipantTracker.tsx # Participant list
│   │   │   ├── SessionStats.tsx       # Session stats
│   │   │   ├── EngagementTimeline.tsx # Timeline chart
│   │   │   └── ConsentDialog.tsx      # Consent management
│   │   │
│   │   └── ui/                        # UI primitives (Shadcn/ui)
│   │       ├── button.tsx
│   │       ├── card.tsx
│   │       ├── dialog.tsx
│   │       ├── input.tsx
│   │       ├── select.tsx
│   │       ├── alert.tsx
│   │       └── ... (20+ component files)
│   │
│   ├── contexts/                      # React contexts
│   │   └── AuthContext.tsx            # Authentication state
│   │
│   ├── hooks/                         # Custom React hooks
│   │   ├── useFaceDetection.ts        # Face detection logic
│   │   ├── use-mobile.tsx             # Mobile detection
│   │   └── use-toast.ts               # Toast notifications
│   │
│   ├── lib/                           # Utility functions
│   │   └── utils.ts                   # Helper utilities
│   │
│   ├── integrations/                  # External service integrations
│   │   └── supabase/
│   │       ├── client.ts              # Supabase client setup
│   │       └── types.ts               # Database types
│   │
│   └── assets/                        # Static assets
│       └── (images, fonts, etc.)
│
├── supabase/                          # Supabase backend
│   ├── config.toml                    # Local development config
│   │
│   ├── migrations/                    # Database migrations (auto-applied)
│   │   ├── 20251230173056_*.sql       # Initial schema
│   │   ├── 20251231053724_*.sql       # User profiles
│   │   ├── 20251231072615_*.sql       # Session management
│   │   ├── 20251231092032_*.sql       # Engagement metrics
│   │   ├── 20260117133000_*.sql       # RLS policies
│   │   └── ... (10+ migration files)
│   │
│   └── functions/                     # Serverless Edge Functions
│       ├── send-session-invite/       # Email invite function
│       ├── send-session-reminders/    # Reminder emails
│       ├── notify-session-scheduled/  # Schedule notifications
│       ├── notify-session-ended/      # Session end alerts
│       ├── notify-role-change/        # Role change emails
│       └── notify-consent-withdrawal/ # Consent withdrawal alerts
│
├── public/                            # Static assets served directly
│   └── robots.txt
│
└── .gitignore                         # Git ignore rules
```

### Key Directories Explained

**`src/pages/`** - Full-page components representing different routes  
**`src/components/`** - Reusable components organized by feature  
**`src/hooks/`** - Custom React hooks (face detection, mobile detection)  
**`supabase/migrations/`** - Database schema and RLS policies  
**`supabase/functions/`** - Serverless functions for emails and notifications  

---

## 📸 Screenshots

### 1. Landing Page - AI-Powered Engagement Analytics
![Landing Page - Hero Section](https://engageanalytic.me/landing-page.png)
*Modern landing page with key features and call-to-action buttons*

### 2. Session Dashboard - Live Engagement Tracking
![Session Dashboard](https://engageanalytic.me/session-dashboard.png)
*Real-time participant engagement metrics and live tracking interface*

### 3. Join Session via Link
![Join Session Interface](https://engageanalytic.me/join-session.png)
*Seamless one-click session joining with consent management*

### 4. Analytics Dashboard - Detailed Reports
![Analytics Dashboard](https://engageanalytic.me/analytics-dashboard.png)
*Comprehensive engagement analytics with charts and export options*

### 5. Admin Panel - User Management
![Admin Panel](https://engageanalytic.me/admin-dashboard.png)
*Administrator interface for user and role management*

> **Note:** To view actual screenshots, replace image URLs with your own. Add screenshot images to a `docs/images/` folder in your repository.

---

## 🚀 Quick Start

### For End Users

1. **Visit the app:** https://engageanalytic.me
2. **Sign up** or **log in** with your email
3. **Create a session** or **join an existing one**
4. **Enable camera** for engagement tracking
5. **View real-time analytics** for your session

### For Developers

```bash
# 1. Clone the repository
git clone https://github.com/Chandan785/engageanalytics.git
cd engageanalytics

# 2. Install dependencies
bun install
# or: npm install

# 3. Setup environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase and Resend credentials

# 4. Start the development server
bun run dev
# App runs on http://localhost:5173
```

---

## ⚙️ Installation

### Prerequisites

- **Node.js** 18+ ([Download](https://nodejs.org/))
- **Bun** 1.0+ ([Download](https://bun.sh/)) or **npm** 9+
- **Supabase** account ([Create Free](https://supabase.com))
- **Resend** account for emails ([Create Free](https://resend.com))

### Step 1: Clone Repository

```bash
git clone https://github.com/Chandan785/engageanalytics.git
cd engageanalytics
```

### Step 2: Install Dependencies

```bash
# Using Bun (recommended)
bun install

# Or using npm
npm install
```

### Step 3: Create Environment File

```bash
cp .env.example .env.local
```

### Step 4: Configure Environment Variables

Edit `.env.local`:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_PROJECT_ID=YOUR_PROJECT_ID
VITE_SUPABASE_PUBLISHABLE_KEY=YOUR_ANON_KEY

# Email Service (Resend)
RESEND_API_KEY=re_YOUR_API_KEY
SENDER_EMAIL=noreply@yourdomain.com

# Optional: Custom domain
VITE_APP_URL=https://engageanalytic.me
```

---

## 🔧 Environment Setup

### Supabase Setup

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Go to **Settings → API** and copy:
   - `SUPABASE_URL` → `VITE_SUPABASE_URL`
   - `Project ID` → `VITE_SUPABASE_PROJECT_ID`
   - `anon public` key → `VITE_SUPABASE_PUBLISHABLE_KEY`
4. Enable authentication:
   - **Auth → Providers** → Enable "Email"
   - **Auth → Providers** → Optional: Enable "Google"
5. Run migrations:
   ```bash
   supabase db push
   ```

### Resend Setup

1. Sign up at [resend.com](https://resend.com)
2. Create API key and copy to `RESEND_API_KEY`
3. Verify sender domain
4. Update `SENDER_EMAIL` in `.env.local`

### Database Initialization

Supabase will automatically run migrations from `/supabase/migrations/` folder.

---

## 🏃 Running Locally

### Development Server

```bash
bun run dev
```
Runs on: **http://localhost:5173**

### Production Build

```bash
bun run build
```
Output: `dist/` folder

### Preview Production Build

```bash
bun run preview
```

### Lint Code

```bash
bun run lint
```

---

## 🚀 Deployment

### Deploy Frontend to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

**Or** connect your GitHub repo to Vercel for automatic deployments.

### Deploy to Supabase

Functions are automatically deployed with:

```bash
supabase functions deploy send-session-invite
supabase functions deploy notify-session-scheduled
```

### Production Checklist

- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] Email service configured
- [ ] Custom domain configured
- [ ] HTTPS enabled
- [ ] Error monitoring setup (Sentry recommended)

---

## 🏗 Architecture

### System Architecture

```
┌─────────────────────────────────────┐
│   Frontend (React + TypeScript)     │
│  ┌───────────────────────────────┐  │
│  │  Face Detection Pipeline      │  │
│  │  • Canvas pixel analysis      │  │
│  │  • Engagement classification  │  │
│  │  • Local video processing     │  │
│  └───────────────────────────────┘  │
└──────────┬────────────────────────────┘
           │ WebSocket (Realtime)
           ▼
┌─────────────────────────────────────┐
│   Supabase Backend                  │
│  ┌───────────────────────────────┐  │
│  │  PostgreSQL Database          │  │
│  │  • 6 core tables              │  │
│  │  • Row-Level Security (RLS)   │  │
│  │  • Real-time subscriptions    │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  Edge Functions (Serverless)  │  │
│  │  • Email notifications        │  │
│  │  • Session webhooks           │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Database Schema

```
┌─────────────────────┐
│     profiles        │ User profiles
├─────────────────────┤
│ id (UUID)          │
│ email              │
│ full_name          │
│ role (host|admin)  │
│ created_at         │
└─────────────────────┘

┌─────────────────────┐
│     sessions        │ Meeting sessions
├─────────────────────┤
│ id (UUID)          │
│ host_id (FK)       │
│ title              │
│ status (scheduled  │
│ start_time         │
│ end_time           │
│ join_link          │
│ created_at         │
└─────────────────────┘

┌─────────────────────────┐
│     participants        │ Session participants
├─────────────────────────┤
│ id (UUID)              │
│ session_id (FK)        │
│ user_id (FK)           │
│ join_time              │
│ consent_given          │
│ created_at             │
└─────────────────────────┘

┌──────────────────────────┐
│   engagement_metrics     │ Real-time metrics
├──────────────────────────┤
│ id (UUID)               │
│ participant_id (FK)     │
│ engagement_level        │
│ timestamp               │
│ face_detected           │
│ confidence              │
└──────────────────────────┘
```

---

## 🔒 Security & Privacy

### Privacy Measures

✅ **Zero Video Upload** - All processing happens locally in the browser  
✅ **No Face Detection Storage** - Engagement metrics only, no facial data stored  
✅ **Encrypted Communication** - All data transmitted over HTTPS/WSS  
✅ **End-to-End Protection** - TLS 1.3 for all connections  

### Compliance

✅ **GDPR Compliant** - Full data deletion, consent management  
✅ **CCPA Ready** - Data export and deletion features  
✅ **SOC 2 Type II** - Enterprise security standards  
✅ **Privacy by Design** - User consent required before tracking  

### Security Best Practices

- 🔐 Supabase RLS policies on all tables
- 🔐 JWT tokens with short expiration
- 🔐 Database encryption at rest
- 🔐 Rate limiting on all APIs
- 🔐 CSRF protection enabled

---

## 📞 Support & Contact

- **Website:** https://engageanalytic.me
- **Email:** support@engageanalytic.me
- **GitHub:** https://github.com/Chandan785/engageanalytics
- **Report Issues:** [GitHub Issues](https://github.com/Chandan785/engageanalytics/issues)

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Write clean, type-safe code
- Add tests for new features
- Follow existing code style
- Update documentation

---

## 🎉 Acknowledgments

Built with passion for better virtual engagement tracking using:

- **Supabase** - Backend infrastructure
- **Vercel** - Frontend deployment
- **React** - UI framework
- **TailwindCSS** - Styling
- **Shadcn/ui** - Component library

---

<div align="center">

**Live:** https://engageanalytic.me  
**Repository:** https://github.com/Chandan785/engageanalytics  
**Issues:** https://github.com/Chandan785/engageanalytics/issues

Made with ❤️ for better engagement tracking

</div>
