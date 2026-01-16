# Email Configuration Issues - Resolution Guide

## Problem 1: Role Change Emails Not Sending ✅ FIXED

**Issue**: When admin changes user roles, the database trigger logs the change but never invokes the email notification Edge Function.

**Root Cause**: The `log_role_change()` function only inserts into audit logs - it doesn't call the `notify-role-change` Edge Function.

**Solution Applied**: 
- Created migration `20260116_fix_role_change_notifications.sql`
- Updated trigger to use `pg_net.http_post()` to invoke the Edge Function
- The trigger now sends HTTP request to notify-role-change function with role change details

**To Apply**: Run `supabase db push` to apply the migration

---

## Problem 2: Signup Confirmation Emails Not Sending ⚠️ NEEDS MANUAL FIX

**Issue**: New users don't receive email confirmation when signing up.

**Root Cause**: Supabase Auth's built-in email system is not properly configured. While SMTP settings are configured, the email template or settings may be disabled.

### Steps to Fix in Supabase Dashboard:

1. **Go to Supabase Dashboard**: https://supabase.com/dashboard/project/mrdhmcpajolvherbbgrb

2. **Navigate to Authentication → Email Templates**
   - Click on "Authentication" in left sidebar
   - Click "Email Templates" tab

3. **Check "Confirm signup" Template**
   - Find "Confirm signup" template
   - Verify it is **ENABLED** (toggle should be ON)
   - Check the "Subject" field has text
   - Verify the email body template is present

4. **Verify SMTP Settings** (Authentication → Settings)
   - Enable Custom SMTP: **ON**
   - Sender email: `notifications@engageanalytic.me`
   - Sender name: `EngageAnalytic`
   - Host: `smtp.resend.com`
   - Port: `587`
   - Username: `resend`
   - Password: `re_9HcJaUSe_D6rYFRqw9H8Qi27MrtBUb2Vd`

5. **Check Site URL Settings** (Authentication → URL Configuration)
   - Site URL: `https://engageanalytic.me`
   - Redirect URLs: Add `https://engageanalytic.me/**`

6. **Email Auth Settings** (Authentication → Settings)
   - Enable email confirmations: **ON** ✅
   - Secure email change: **ON** (recommended)
   - Double confirm email changes: **ON** (recommended)

### Alternative Solution: Custom Edge Function

If Supabase Auth emails still don't work, create a custom signup flow:

```typescript
// In Auth.tsx - replace Supabase's signUp with custom function:

// 1. Create user WITHOUT email confirmation
const { data, error } = await supabase.auth.signUp({
  email,
  password,
  options: {
    emailRedirectTo: undefined, // Disable built-in confirmation
  }
});

// 2. Call custom Edge Function to send confirmation
await fetch(`${SUPABASE_URL}/functions/v1/send-signup-confirmation`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: email,
    userId: data.user?.id,
  }),
});
```

Then create `supabase/functions/send-signup-confirmation/index.ts` similar to other email functions.

---

## Quick Test After Fixes:

### Test Role Change Email:
1. Login as admin at https://engageanalytic.me
2. Go to Admin Dashboard → User Management
3. Change a user's role (add/remove admin or researcher)
4. User should receive email notification within 30 seconds

### Test Signup Confirmation:
1. Go to https://engageanalytic.me/auth
2. Try signing up with a new email
3. Check email inbox for confirmation link
4. If no email arrives after 2 minutes, check Supabase Dashboard → Authentication → Users to see if user was created

---

## Current Email Status:

✅ **Working Emails:**
- Password reset emails
- Session invitations (when manually triggered)
- Session reminders (via cron)

❌ **Not Working:**
- Signup confirmation emails (Supabase Auth issue)
- Role change notifications (fixed by migration, needs db push)

---

## Debugging Tips:

1. **Check Resend Dashboard**: https://resend.com/emails
   - See if emails are being sent/failed
   - Check delivery status and error messages

2. **Check Supabase Logs**: Dashboard → Logs → Function Logs
   - See if Edge Functions are being invoked
   - Check for error messages

3. **Check Database Logs**: 
   ```sql
   -- See recent role changes
   SELECT * FROM role_audit_logs ORDER BY created_at DESC LIMIT 10;
   ```

4. **Test Edge Function Directly**:
   ```bash
   curl -X POST https://mrdhmcpajolvherbbgrb.supabase.co/functions/v1/notify-role-change \
     -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
     -H "Content-Type: application/json" \
     -d '{"targetUserId":"USER_ID","action":"add","role":"admin","adminName":"Test Admin"}'
   ```
