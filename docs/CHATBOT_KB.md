# Engage Analytics Chatbot Knowledge Base

Purpose: Help users understand and use all features and workflows of the Engage Analytics app.

## Quick Access
- Live app: https://engageanalytic.me
- Support: https://engageanalytic.me/support

## Core Capabilities (High-Level)
- AI-powered engagement tracking for virtual meetings
- Privacy-first: video stays on device; only metrics used
- Role-based experiences for Hosts, Participants, Admins

## Roles & What They Can Do

### Host
- Create, schedule, and launch sessions
- Monitor live engagement during sessions
- View session reports and analytics
- Manage participant consent and receive notifications

### Participant
- Join sessions via link
- Provide or withdraw consent anytime
- View personal participation experience

### Admin / Super Admin
- Manage users and assign roles (RBAC)
- View platform-wide analytics
- Access audit logs

### Super Admin (Advanced)
- Full control of system roles and permissions
- Advanced role management with SUPER_ADMIN rules enforced
- Transfer SUPER_ADMIN ownership to another user
- View role audit logs and system activity
- Access global system settings (feature flags, policies, integrations)

## Top Tasks (User How-To)

### 1) Create an account
- Go to the Auth page and sign up
- Verify email, then log in

### 2) Start or schedule a session (Host)
- Open the Sessions area
- Click “New Session” to create and schedule
- Launch the session when ready

### 3) Join a session (Participant)
- Open the invite link
- Review consent and join

### 4) Use Live Tracking (Host)
- From an active session, open Live Tracking
- Monitor real-time engagement levels

### 5) View Analytics (Host/Admin)
- Open the Analytics dashboard
- Filter by session or all sessions
- Export report if needed

### 6) Manage Users (Admin)
- Open Admin Dashboard
- Update roles and permissions

### 7) Update Profile / Password
- Open Profile page
- Edit details or reset password

## FAQ-Style Responses

**What is Engage Analytics?**
A real-time engagement tracking platform for virtual meetings using AI-powered computer vision, with privacy-first on-device processing.

**How do I host a session?**
Go to Sessions, create a new session, schedule or start it, then use Live Tracking during the meeting.

**How do participants join?**
Participants use the session link and complete consent before tracking starts.

**Where can I see reports?**
Reports and analytics are in the Analytics dashboard and Session History.

**Can I export analytics?**
Yes, use the Export option in Analytics.

**How is privacy handled?**
Video never leaves the device; only engagement metrics are processed.

**How do admins manage users?**
Admins use the Admin Dashboard to assign roles and review platform analytics.

## Intents & Sample Utterances

### Intent: GetAppOverview
- What is Engage Analytics?
- Explain the app in one line
- What does this project do?

### Intent: CreateAccount
- How do I sign up?
- Create a new account
- Where is the registration page?

### Intent: LoginHelp
- I can’t log in
- How do I log in?
- Where do I enter my email and password?

### Intent: ResetPassword
- I forgot my password
- Reset my password
- How do I change my password?

### Intent: HostCreateSession
- Create a session
- Schedule a meeting
- Start a new session

### Intent: HostLaunchSession
- Launch session
- Start the session now
- Begin live session

### Intent: JoinSession
- Join session link
- How do participants join?
- I have a session link

### Intent: ConsentFlow
- What is the consent screen?
- How do I give consent?
- Can I withdraw consent?

### Intent: LiveTracking
- Open live tracking
- Show live engagement
- Real-time dashboard

### Intent: ViewAnalytics
- Show analytics
- View session reports
- Engagement trends

### Intent: ExportReport
- Export analytics
- Download report
- Export session data

### Intent: ManageUsers
- Assign roles
- Manage users
- Admin user controls

### Intent: SuperAdminOverview
- What can super admin do?
- Super admin features
- Super admin dashboard

### Intent: SuperAdminTransfer
- Transfer super admin
- Change super admin owner
- Give super admin to another user

### Intent: SuperAdminAudit
- Super admin audit log
- Role audit logs
- System activity logs

### Intent: SuperAdminSettings
- Super admin settings
- System settings
- Global settings

### Intent: RolePermissions
- What can admins do?
- Host vs participant permissions
- Role-based access

### Intent: Support
- Contact support
- Where is help?
- Need assistance

## Escalation
If the user needs help beyond the app, direct them to:
- Support page: https://engageanalytic.me/support
- Email: support@engageanalytic.me
