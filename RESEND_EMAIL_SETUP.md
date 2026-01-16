# Email Setup Guide - Resend API Integration

## Issue: Password Reset & Notification Emails Not Working

When running locally (not on Lovable), Supabase's email functionality requires proper SMTP configuration. Here's how to set up Resend API for sending emails.

## Solution: Configure Resend API in Supabase

### Step 1: Get Resend API Key

1. Go to [Resend.com](https://resend.com) and sign up/login
2. Navigate to **API Keys** section
3. Click **Create API Key**
4. Give it a name (e.g., "Engage Analytics Production")
5. Copy the API key (starts with `re_...`)

### Step 2: Configure Supabase Email Settings

You have **two options** depending on your setup:

#### Option A: Supabase Cloud Dashboard (Recommended)

1. Go to your Supabase project dashboard: [https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb](https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb)

2. Navigate to **Project Settings** > **Auth**

3. Scroll down to **SMTP Settings** section

4. Enable **Enable Custom SMTP**

5. Fill in the following details:
   ```
   Sender email: noreply@yourdomain.com (use your verified Resend domain)
   Sender name: Engage Analytics
   Host: smtp.resend.com
   Port: 465 or 587
   Username: resend
   Password: [Your Resend API Key here - re_...]
   ```

6. Click **Save**

#### Option B: Local Development with Supabase CLI

If you're running Supabase locally, update your `supabase/config.toml`:

```toml
[auth.email.smtp]
enabled = true
host = "smtp.resend.com"
port = 587
user = "resend"
pass = "env(RESEND_API_KEY)"
admin_email = "noreply@yourdomain.com"
sender_name = "Engage Analytics"

[auth.email.template.reset_password]
subject = "Reset Your Password"
```

Then add to your `.env` file:
```
RESEND_API_KEY=re_your_api_key_here
```

### Step 3: Verify Domain (Important!)

For production use, you **must** verify your domain with Resend:

1. In Resend dashboard, go to **Domains**
2. Click **Add Domain**
3. Enter your domain (e.g., `yourdomain.com`)
4. Add the DNS records Resend provides to your domain registrar
5. Wait for verification (usually takes a few minutes)
6. Use `noreply@yourdomain.com` as your sender email

**For testing:** You can use Resend's default domain initially, but it's limited.

### Step 4: Update Environment Variables

Add these to your `.env` file if not already present:

```bash
# Resend API Key (for Edge Functions if needed)
RESEND_API_KEY=re_your_api_key_here

# Your verified sender email
SENDER_EMAIL=noreply@yourdomain.com
```

### Step 5: Test Email Functionality

1. **Test Password Reset:**
   - Go to your app's login page
   - Click "Forgot Password"
   - Enter your email
   - Check your inbox for the reset email

2. **Test Profile Password Change:**
   - Login to your account
   - Go to Profile page
   - Click "Change Password"
   - Check your inbox for the reset email

3. **Test Sign Up Confirmation:**
   - Sign up with a new email
   - Check inbox for confirmation email

## Email Templates Location

Supabase email templates can be customized in:
- **Cloud:** Project Settings > Auth > Email Templates
- **Local:** `supabase/templates/` directory

## Common Issues & Solutions

### Issue: "Error sending email"
**Solution:** Check that your Resend API key is correct and hasn't expired.

### Issue: Emails going to spam
**Solution:** 
- Verify your domain with Resend
- Set up SPF, DKIM, and DMARC records
- Use a professional sender email (noreply@yourdomain.com)

### Issue: "Invalid sender email"
**Solution:** Make sure you're using a verified domain or Resend's default domain.

### Issue: Emails working on Lovable but not locally
**Solution:** Lovable has pre-configured SMTP settings. You need to set them up manually for local/production deployment.

## Rate Limits

Resend Free Tier:
- 100 emails/day
- 3,000 emails/month

For production, consider upgrading to:
- Pro: $20/month - 50,000 emails/month
- Business: Custom pricing

## Security Best Practices

1. **Never commit API keys** to version control
2. Use environment variables for all sensitive data
3. Rotate API keys periodically
4. Use different API keys for development and production
5. Enable webhook signatures for additional security

## Edge Functions Email Integration

Your existing Supabase Edge Functions can also use Resend. Update each function:

```typescript
// supabase/functions/[function-name]/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
  
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${RESEND_API_KEY}`
    },
    body: JSON.stringify({
      from: 'noreply@yourdomain.com',
      to: ['user@example.com'],
      subject: 'Your Subject',
      html: '<p>Your HTML content</p>'
    })
  })
  
  return new Response(JSON.stringify(await response.json()), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

## Testing

After setup, test all email-related features:
- ✅ Sign up confirmation
- ✅ Password reset from login page
- ✅ Password change from profile page
- ✅ Session invitations (if applicable)
- ✅ Role change notifications
- ✅ Session reminders

## Support

- Resend Documentation: https://resend.com/docs
- Supabase Email Docs: https://supabase.com/docs/guides/auth/auth-smtp
- For issues, check Supabase logs: Project Dashboard > Logs > Auth

---

**Status:** After completing these steps, your email functionality should work exactly like it did on Lovable! 🚀
