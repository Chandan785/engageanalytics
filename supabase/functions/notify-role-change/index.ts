import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RoleChangeRequest {
  targetUserId: string;
  action: "add" | "remove";
  role: string;
  adminName?: string;
}

const handler = async (req: Request): Promise<Response> => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { targetUserId, action, role, adminName }: RoleChangeRequest = await req.json();

    console.log(`Processing role change notification for user ${targetUserId}: ${action} ${role}`);

    // Create Supabase client to fetch user profile
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Fetch target user's profile
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("email, full_name")
      .eq("user_id", targetUserId)
      .single();

    if (profileError || !profile) {
      console.error("Error fetching profile:", profileError);
      return new Response(
        JSON.stringify({ error: "User profile not found" }),
        { status: 404, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    const userName = profile.full_name || profile.email;
    const actionText = action === "add" ? "granted" : "removed";
    const roleDisplayName = role.charAt(0).toUpperCase() + role.slice(1);

    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f4f4f5; margin: 0; padding: 20px;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
          <div style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); padding: 32px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 24px; font-weight: 600;">Role Update Notification</h1>
          </div>
          <div style="padding: 32px;">
            <p style="color: #374151; font-size: 16px; line-height: 1.6; margin: 0 0 16px 0;">
              Hello ${userName},
            </p>
            <p style="color: #374151; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
              Your account role has been updated. Here are the details:
            </p>
            <div style="background-color: #f9fafb; border-radius: 8px; padding: 20px; margin-bottom: 24px;">
              <table style="width: 100%; border-collapse: collapse;">
                <tr>
                  <td style="color: #6b7280; font-size: 14px; padding: 8px 0;">Action:</td>
                  <td style="color: ${action === 'add' ? '#10b981' : '#ef4444'}; font-size: 14px; padding: 8px 0; text-align: right; font-weight: 600;">
                    ${action === 'add' ? '✓ Role Granted' : '✗ Role Removed'}
                  </td>
                </tr>
                <tr>
                  <td style="color: #6b7280; font-size: 14px; padding: 8px 0;">Role:</td>
                  <td style="color: #374151; font-size: 14px; padding: 8px 0; text-align: right; font-weight: 600;">${roleDisplayName}</td>
                </tr>
                ${adminName ? `
                <tr>
                  <td style="color: #6b7280; font-size: 14px; padding: 8px 0;">Changed by:</td>
                  <td style="color: #374151; font-size: 14px; padding: 8px 0; text-align: right;">${adminName}</td>
                </tr>
                ` : ''}
              </table>
            </div>
            <p style="color: #6b7280; font-size: 14px; line-height: 1.6; margin: 0;">
              If you have any questions about this change, please contact your administrator.
            </p>
          </div>
          <div style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 1px solid #e5e7eb;">
            <p style="color: #9ca3af; font-size: 12px; margin: 0;">
              This is an automated message from the Engagement Tracker system.
            </p>
          </div>
        </div>
      </body>
      </html>
    `;

    // Send email using Resend API directly
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (!resendApiKey) {
      throw new Error("RESEND_API_KEY not configured");
    }

    const emailResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from: "Engagement Tracker <onboarding@resend.dev>",
        to: [profile.email],
        subject: `Your ${roleDisplayName} role has been ${actionText}`,
        html: emailHtml,
      }),
    });

    const emailResult = await emailResponse.json();
    
    // Handle Resend domain verification requirement gracefully
    if (!emailResponse.ok) {
      console.warn("Email send failed:", emailResult);
      
      // Check if it's a domain verification issue
      const isDomainError = emailResult.message?.includes("verify a domain") || 
                           emailResult.message?.includes("testing emails");
      
      if (isDomainError) {
        console.log("Domain not verified - role change succeeded but notification email was not sent");
        return new Response(
          JSON.stringify({ 
            success: true, 
            emailSent: false,
            warning: "Role updated successfully but email notification could not be sent. To enable email notifications, verify a domain at resend.com/domains."
          }),
          {
            status: 200,
            headers: { "Content-Type": "application/json", ...corsHeaders },
          }
        );
      }
      
      // For other email errors, still return success for the role change
      return new Response(
        JSON.stringify({ 
          success: true, 
          emailSent: false,
          warning: `Role updated but email failed: ${emailResult.message}`
        }),
        {
          status: 200,
          headers: { "Content-Type": "application/json", ...corsHeaders },
        }
      );
    }

    console.log("Email sent successfully:", emailResult);

    return new Response(
      JSON.stringify({ success: true, emailSent: true, emailResponse: emailResult }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  } catch (error: any) {
    console.error("Error in notify-role-change function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  }
};

serve(handler);
