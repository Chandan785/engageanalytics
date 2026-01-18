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
**Last Updated**: January 18, 2026

---

## 📚 Documentation

This README provides quick start information. For comprehensive documentation including full project structure, architecture diagrams, screenshots, and detailed setup instructions, please see:

### 📖 Main Documentation Files

| Document | Contains |
|----------|----------|
| **[ENGAGE Analytics - Complete Guide](./docs/COMPLETE_README.md)** | 📋 Full project overview<br/>📁 Complete project structure (29+ directories)<br/>📸 Screenshots & images<br/>🏗️ Architecture diagrams<br/>🔒 Security & compliance details<br/>📚 Contributing guidelines |
| **[Setup Reference Guide](./docs/SETUP_REFERENCE.md)** | ⚙️ Email configuration (Resend API)<br/>🔐 Google OAuth setup<br/>🌐 Custom domain configuration<br/>💻 Local development commands<br/>🗄️ Database migrations<br/>🔧 Environment variables<br/>🐛 Troubleshooting<br/>✅ Security checklist |

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
# App runs on http://localhost:5173
```

**For detailed setup instructions, see [Setup Reference Guide](./docs/SETUP_REFERENCE.md)**

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

---

## Email Configuration (Password Reset & Notifications)

**Important:** Email functionality (password reset, notifications) requires SMTP configuration.

For comprehensive email setup instructions including Resend API configuration, Supabase SMTP settings, and troubleshooting, see:
- **[Setup Reference Guide - Email Configuration Section](./docs/SETUP_REFERENCE.md#email-configuration-password-reset--notifications)**

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

For detailed step-by-step instructions, see:
- **[Setup Reference Guide - Google Sign-In Section](./docs/SETUP_REFERENCE.md#configuring-google-sign-in-supabase)**

## Custom Domain Setup

Configure your custom domain (engageanalytic.me) through your hosting provider's DNS settings.

For detailed Vercel and DNS configuration instructions, see:
- **[Setup Reference Guide - Custom Domain Setup Section](./docs/SETUP_REFERENCE.md#custom-domain-setup)**

---

## 📖 Need More Information?

### Quick Links to Detailed Guides

- 🚀 **Getting Started**: [Setup Reference Guide - Quick Start](./docs/SETUP_REFERENCE.md#quick-start)
- ⚙️ **Environment Setup**: [Setup Reference Guide - Environment Setup](./docs/SETUP_REFERENCE.md#environment-variables-reference)
- 📦 **Installation**: [Setup Reference Guide - Installation](./docs/SETUP_REFERENCE.md#step-1-clone-repository)
- 💻 **Local Development**: [Setup Reference Guide - Running Locally](./docs/SETUP_REFERENCE.md#local-development-commands)
- 🌐 **Deployment**: [Setup Reference Guide - Deployment](./docs/SETUP_REFERENCE.md#deploy-to-vercel)
- 🗄️ **Database**: [Setup Reference Guide - Database Setup](./docs/SETUP_REFERENCE.md#database-setup)
- 🐛 **Troubleshooting**: [Setup Reference Guide - Troubleshooting](./docs/SETUP_REFERENCE.md#troubleshooting)
- 📋 **Full Project Structure**: [Complete README - Project Structure](./docs/COMPLETE_README.md#-project-structure)
- 🏗️ **Architecture**: [Complete README - Architecture](./docs/COMPLETE_README.md#-architecture)
- 🔒 **Security**: [Complete README - Security & Privacy](./docs/COMPLETE_README.md#-security--privacy)

---

## 📞 Support & Resources

- **Website:** https://engageanalytic.me
- **Email:** support@engageanalytic.me
- **GitHub Issues:** https://github.com/Chandan785/engageanalytics/issues
- **GitHub Repository:** https://github.com/Chandan785/engageanalytics

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

Made with ❤️ for better engagement tracking

[Visit Live Demo](https://engageanalytic.me) • [GitHub Repository](https://github.com/Chandan785/engageanalytics) • [Report Issues](https://github.com/Chandan785/engageanalytics/issues)

</div>
