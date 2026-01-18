# ENGAGE Analytics - Complete Technical Guide

> **Comprehensive documentation with full project structure, architecture, and detailed information**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Security & Privacy](#security--privacy)
- [Contributing](#contributing)

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
├── README.md                          # Main documentation (quick start)
├── package.json                       # Project dependencies
├── bun.lockb                          # Bun lockfile
├── vite.config.ts                     # Vite configuration
├── tsconfig.json                      # TypeScript config
├── tsconfig.app.json                  # App TypeScript config
├── tsconfig.node.json                 # Node TypeScript config
├── tailwind.config.ts                 # TailwindCSS config
├── eslint.config.js                   # ESLint configuration
├── postcss.config.js                  # PostCSS config
├── index.html                         # HTML entry point
├── vercel.json                        # Vercel deployment config
├── components.json                    # Shadcn/ui config
│
├── src/                               # Source code
│   ├── main.tsx                       # React app entry point
│   ├── App.tsx                        # Main App component
│   ├── App.css                        # Global app styles
│   ├── index.css                      # Base/reset styles
│   ├── vite-env.d.ts                  # Vite type definitions
│   │
│   ├── pages/                         # Page components (routes)
│   │   ├── Index.tsx                  # Landing page
│   │   ├── Auth.tsx                   # Login/signup page
│   │   ├── Dashboard.tsx              # Main user dashboard
│   │   ├── AdminDashboard.tsx         # Admin control panel
│   │   ├── Sessions.tsx               # Sessions list view
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
│   │   ├── ProtectedRoute.tsx         # Route authentication guard
│   │   ├── RoleBasedRedirect.tsx      # Role-based routing logic
│   │   ├── ImageLightbox.tsx          # Image lightbox viewer
│   │   ├── MFAVerification.tsx        # Multi-factor auth verification
│   │   ├── TwoFactorSetup.tsx         # 2FA setup wizard
│   │   ├── PasswordStrengthIndicator.tsx # Password strength meter
│   │   │
│   │   ├── admin/                     # Admin-specific components
│   │   │   ├── UserRoleManagement.tsx # Manage user roles
│   │   │   ├── SessionManagement.tsx  # Manage sessions
│   │   │   └── AnalyticsOverview.tsx  # Platform analytics
│   │   │
│   │   ├── analytics/                 # Analytics components
│   │   │   ├── ParticipantDistributionChart.tsx # Distribution chart
│   │   │   ├── EngagementTrendChart.tsx         # Trend analysis
│   │   │   └── ExportReport.tsx                 # Report export
│   │   │
│   │   ├── live-tracking/             # Live session components
│   │   │   ├── VideoFeed.tsx          # Video display component
│   │   │   ├── EngagementMetrics.tsx  # Metrics display
│   │   │   ├── ParticipantTracker.tsx # Participant list
│   │   │   ├── SessionStats.tsx       # Session statistics
│   │   │   ├── EngagementTimeline.tsx # Timeline chart
│   │   │   └── ConsentDialog.tsx      # Consent management
│   │   │
│   │   └── ui/                        # Shadcn/ui components
│   │       ├── button.tsx
│   │       ├── card.tsx
│   │       ├── dialog.tsx
│   │       ├── input.tsx
│   │       ├── select.tsx
│   │       ├── alert.tsx
│   │       ├── form.tsx
│   │       ├── dropdown-menu.tsx
│   │       └── ... (15+ component files)
│   │
│   ├── contexts/                      # React context providers
│   │   └── AuthContext.tsx            # Authentication state management
│   │
│   ├── hooks/                         # Custom React hooks
│   │   ├── useFaceDetection.ts        # Face detection algorithm
│   │   ├── use-mobile.tsx             # Mobile device detection
│   │   └── use-toast.ts               # Toast notifications hook
│   │
│   ├── lib/                           # Utility functions
│   │   └── utils.ts                   # Helper utilities
│   │
│   ├── integrations/                  # External service integrations
│   │   └── supabase/
│   │       ├── client.ts              # Supabase client initialization
│   │       └── types.ts               # Database TypeScript types
│   │
│   └── assets/                        # Static assets
│       └── (images, fonts, icons)
│
├── supabase/                          # Supabase backend
│   ├── config.toml                    # Local development config
│   │
│   ├── migrations/                    # Database migrations
│   │   ├── 20251230173056_*.sql       # Initial schema setup
│   │   ├── 20251231053724_*.sql       # User profiles table
│   │   ├── 20251231072615_*.sql       # Sessions management
│   │   ├── 20251231072917_*.sql       # Participants table
│   │   ├── 20251231073928_*.sql       # Engagement metrics
│   │   ├── 20251231074105_*.sql       # Session reports
│   │   ├── 20251231074240_*.sql       # Consent tracking
│   │   ├── 20251231092032_*.sql       # RLS policies
│   │   ├── 20251231092122_*.sql       # Auth functions
│   │   ├── 20251231092336_*.sql       # Indexes
│   │   └── ... (additional migrations)
│   │
│   └── functions/                     # Serverless Edge Functions
│       ├── send-session-invite/       # Email invite notifications
│       ├── send-session-reminders/    # Session reminder emails
│       ├── notify-session-scheduled/  # Session scheduled alerts
│       ├── notify-session-ended/      # Session end notifications
│       ├── notify-role-change/        # Role change emails
│       └── notify-consent-withdrawal/ # Consent withdrawal alerts
│
├── docs/                              # Documentation folder
│   ├── SETUP_REFERENCE.md             # Detailed setup guide
│   └── COMPLETE_README.md             # This file
│
├── public/                            # Static files (served directly)
│   └── robots.txt
│
└── .gitignore                         # Git ignore rules
```

### Directory Explanations

**`src/pages/`** 
- Full-page components representing different routes
- Each file corresponds to a route in the application
- Examples: landing page, dashboard, session detail

**`src/components/`** 
- Reusable components organized by feature
- Admin, analytics, and live-tracking are feature-specific folders
- UI folder contains shadcn/ui primitives

**`src/hooks/`** 
- Custom React hooks for shared logic
- `useFaceDetection.ts` implements the engagement detection algorithm
- `use-mobile.tsx` detects if user is on mobile device

**`src/lib/`** 
- Utility functions and helpers
- Centralized logic used across components

**`supabase/migrations/`** 
- Database schema definitions
- Row-Level Security (RLS) policies
- Auto-applied in order on database push

**`supabase/functions/`** 
- Serverless Edge Functions
- Run on Supabase's Edge Network
- Used for email notifications and webhooks

---

## 📸 Screenshots

### 1. Landing Page - AI-Powered Engagement Analytics
*Modern landing page with key features and call-to-action buttons*

### 2. Session Dashboard - Live Engagement Tracking
*Real-time participant engagement metrics and live tracking interface*

### 3. Join Session via Link
*Seamless one-click session joining with consent management*

### 4. Analytics Dashboard - Detailed Reports
*Comprehensive engagement analytics with charts and export options*

### 5. Admin Panel - User Management
*Administrator interface for user and role management*

---

## 🏗 Architecture

### System Architecture

```
┌──────────────────────────────────────┐
│   Frontend (React + TypeScript)      │
│  ┌────────────────────────────────┐  │
│  │  Face Detection Pipeline       │  │
│  │  • Canvas pixel analysis       │  │
│  │  • Engagement classification   │  │
│  │  • Local video processing      │  │
│  │  • Real-time metrics           │  │
│  └────────────────────────────────┘  │
└──────────┬─────────────────────────────┘
           │ WebSocket (Realtime)
           │ HTTPS (REST API)
           ▼
┌──────────────────────────────────────┐
│   Supabase Backend                   │
│  ┌────────────────────────────────┐  │
│  │  PostgreSQL Database           │  │
│  │  • 6 core tables               │  │
│  │  • Row-Level Security (RLS)    │  │
│  │  • Real-time subscriptions     │  │
│  │  • Built-in authentication     │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │  Edge Functions (Serverless)   │  │
│  │  • Email notifications         │  │
│  │  • Session webhooks            │  │
│  │  • Data processing             │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

### Data Flow

1. **User Session Starts** 
   - Host creates/starts session
   - Participants receive invite link
   - Real-time subscription established

2. **Live Tracking** 
   - Face detection runs locally in browser
   - Engagement metrics sent to backend in real-time
   - Dashboard updates via WebSocket

3. **Session Ends** 
   - Metrics processed and stored
   - Reports generated
   - Notifications sent to participants

### Database Schema

**Core Tables:**

```sql
-- User Profiles
profiles {
  id UUID (PK)
  email TEXT
  full_name TEXT
  role (host|admin|participant)
  created_at TIMESTAMP
}

-- Sessions
sessions {
  id UUID (PK)
  host_id UUID (FK → profiles)
  title TEXT
  description TEXT
  status (scheduled|active|ended)
  start_time TIMESTAMP
  end_time TIMESTAMP
  join_link TEXT (unique)
  created_at TIMESTAMP
}

-- Participants
participants {
  id UUID (PK)
  session_id UUID (FK → sessions)
  user_id UUID (FK → profiles)
  join_time TIMESTAMP
  consent_given BOOLEAN
  created_at TIMESTAMP
}

-- Engagement Metrics
engagement_metrics {
  id UUID (PK)
  participant_id UUID (FK → participants)
  engagement_level (fully_engaged|partially_engaged|passively_present|away)
  timestamp TIMESTAMP
  face_detected BOOLEAN
  confidence FLOAT
}

-- Session Reports
session_reports {
  id UUID (PK)
  session_id UUID (FK → sessions)
  total_participants INTEGER
  avg_engagement FLOAT
  report_data JSONB
  created_at TIMESTAMP
}

-- Consent Logs
consent_logs {
  id UUID (PK)
  participant_id UUID (FK → participants)
  action (given|withdrawn)
  timestamp TIMESTAMP
}
```

---

## 🔒 Security & Privacy

### Privacy Measures

✅ **Zero Video Upload** - All processing happens locally in the browser  
✅ **No Face Detection Storage** - Only engagement metrics stored, no facial data  
✅ **Encrypted Communication** - All data transmitted over HTTPS/WSS  
✅ **End-to-End Protection** - TLS 1.3 for all connections  

### Compliance Standards

✅ **GDPR Compliant** 
- Full data deletion capabilities
- Consent management system
- Right to be forgotten implemented

✅ **CCPA Ready** 
- Data export features
- Deletion and opt-out capabilities
- Privacy policy transparency

✅ **SOC 2 Type II** 
- Enterprise security standards
- Access controls and auditing
- Data protection measures

### Security Best Practices

- 🔐 Supabase RLS policies on all tables
- 🔐 JWT tokens with short expiration (1 hour)
- 🔐 Database encryption at rest
- 🔐 Rate limiting on all APIs
- 🔐 CSRF protection enabled
- 🔐 Input validation and sanitization
- 🔐 SQL injection prevention

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
- Ensure no console errors

---

## 📞 Support & Resources

- **Website:** https://engageanalytic.me
- **Email:** support@engageanalytic.me
- **GitHub Issues:** https://github.com/Chandan785/engageanalytics/issues
- **GitHub Repository:** https://github.com/Chandan785/engageanalytics

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

Made with ❤️ for better engagement tracking

**[Setup Reference Guide](./SETUP_REFERENCE.md)** | **[Main README](../README.md)** | **[GitHub](https://github.com/Chandan785/engageanalytics)**

</div>
