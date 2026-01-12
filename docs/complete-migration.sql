-- =====================================================
-- ENGAGEVISION COMPLETE DATABASE MIGRATION
-- Run this in your Supabase SQL Editor to set up the entire database
-- =====================================================

-- =====================================================
-- STEP 1: CREATE ENUMS
-- =====================================================

CREATE TYPE public.app_role AS ENUM ('host', 'participant', 'viewer', 'admin');
CREATE TYPE public.engagement_level AS ENUM ('fully_engaged', 'partially_engaged', 'passively_present', 'away');
CREATE TYPE public.session_status AS ENUM ('scheduled', 'active', 'completed', 'cancelled');

-- =====================================================
-- STEP 2: CREATE TABLES
-- =====================================================

-- Profiles table (stores user profile information)
CREATE TABLE public.profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL UNIQUE,
    email text NOT NULL,
    full_name text,
    avatar_url text,
    organization text,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- User roles table (stores user roles - separate from profiles for security)
CREATE TABLE public.user_roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    role public.app_role NOT NULL DEFAULT 'participant',
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    UNIQUE (user_id, role)
);

-- Sessions table (stores meeting/session information)
CREATE TABLE public.sessions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    meeting_link text,
    scheduled_at timestamp with time zone,
    started_at timestamp with time zone,
    ended_at timestamp with time zone,
    status public.session_status NOT NULL DEFAULT 'scheduled',
    settings jsonb DEFAULT '{"attention_threshold": 0.7, "alert_on_low_engagement": true}'::jsonb,
    reminder_sent_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Participants table (tracks session participants)
CREATE TABLE public.participants (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id uuid NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    user_id uuid NOT NULL,
    joined_at timestamp with time zone,
    left_at timestamp with time zone,
    consent_given boolean DEFAULT false,
    consent_given_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Engagement metrics table (stores real-time engagement data)
CREATE TABLE public.engagement_metrics (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_id uuid NOT NULL REFERENCES public.participants(id) ON DELETE CASCADE,
    session_id uuid NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    timestamp timestamp with time zone NOT NULL DEFAULT now(),
    attention_score numeric,
    face_detected boolean DEFAULT false,
    camera_on boolean DEFAULT false,
    audio_unmuted boolean DEFAULT false,
    eye_gaze_focused boolean DEFAULT true,
    head_pose_engaged boolean DEFAULT true,
    screen_focused boolean DEFAULT true,
    engagement_level public.engagement_level DEFAULT 'passively_present',
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Session reports table (stores generated session reports)
CREATE TABLE public.session_reports (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id uuid NOT NULL UNIQUE REFERENCES public.sessions(id) ON DELETE CASCADE,
    total_participants integer DEFAULT 0,
    avg_engagement_score numeric,
    fully_engaged_count integer DEFAULT 0,
    partially_engaged_count integer DEFAULT 0,
    passively_present_count integer DEFAULT 0,
    total_duration_minutes integer,
    report_data jsonb,
    generated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Role audit logs table (tracks role changes for security)
CREATE TABLE public.role_audit_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    target_user_id uuid NOT NULL,
    action text NOT NULL,
    role public.app_role NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- =====================================================
-- STEP 3: CREATE INDEXES
-- =====================================================

CREATE INDEX idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX idx_sessions_host_id ON public.sessions(host_id);
CREATE INDEX idx_sessions_status ON public.sessions(status);
CREATE INDEX idx_participants_session_id ON public.participants(session_id);
CREATE INDEX idx_participants_user_id ON public.participants(user_id);
CREATE INDEX idx_engagement_metrics_session_id ON public.engagement_metrics(session_id);
CREATE INDEX idx_engagement_metrics_participant_id ON public.engagement_metrics(participant_id);
CREATE INDEX idx_engagement_metrics_timestamp ON public.engagement_metrics(timestamp);

-- =====================================================
-- STEP 4: CREATE FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Function to check if user has a specific role (security definer to avoid RLS recursion)
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
          AND role = _role
    )
$$;

-- Function to check if user is session host
CREATE OR REPLACE FUNCTION public.is_session_host(session_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.sessions
        WHERE id = session_id
          AND host_id = auth.uid()
    )
$$;

-- Function to check if user is participant in session
CREATE OR REPLACE FUNCTION public.is_participant_in_session(session_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.participants
        WHERE session_id = is_participant_in_session.session_id
          AND user_id = auth.uid()
    )
$$;

-- Function to check if user can join session
CREATE OR REPLACE FUNCTION public.can_join_session(session_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.sessions
        WHERE id = session_id
          AND status = 'active'
    ) AND auth.uid() IS NOT NULL
$$;

-- Function to check if host can view profile
CREATE OR REPLACE FUNCTION public.can_host_view_profile(profile_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.sessions s
        JOIN public.participants p ON p.session_id = s.id
        WHERE s.host_id = auth.uid()
          AND p.user_id = profile_user_id
    )
$$;

-- Function to get participant profiles for host
CREATE OR REPLACE FUNCTION public.get_participant_profiles_for_host(p_session_id uuid)
RETURNS TABLE(id uuid, user_id uuid, full_name text, avatar_url text, organization text)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT 
        p.id,
        p.user_id,
        p.full_name,
        p.avatar_url,
        p.organization
    FROM public.profiles p
    INNER JOIN public.participants part ON part.user_id = p.user_id
    INNER JOIN public.sessions s ON s.id = part.session_id
    WHERE s.id = p_session_id
      AND s.host_id = auth.uid()
$$;

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (user_id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name', NEW.email),
        COALESCE(NEW.raw_user_meta_data ->> 'avatar_url', NEW.raw_user_meta_data ->> 'picture')
    );
    
    -- Default role is participant
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'participant');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function to log role changes
CREATE OR REPLACE FUNCTION public.log_role_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
        VALUES (auth.uid(), NEW.user_id, 'add', NEW.role);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO public.role_audit_logs (user_id, target_user_id, action, role)
        VALUES (auth.uid(), OLD.user_id, 'remove', OLD.role);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function to prevent consent manipulation
CREATE OR REPLACE FUNCTION public.prevent_consent_manipulation()
RETURNS TRIGGER AS $$
BEGIN
    -- Allow withdrawing consent (true -> false)
    -- But prevent giving consent again after withdrawal via direct UPDATE
    IF OLD.consent_given = false AND NEW.consent_given = true THEN
        RAISE EXCEPTION 'Cannot re-enable consent after withdrawal. Please rejoin the session.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =====================================================
-- STEP 5: CREATE TRIGGERS
-- =====================================================

-- Trigger for new user registration
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Trigger for updating timestamps
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at
    BEFORE UPDATE ON public.sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for role change logging
CREATE TRIGGER on_role_change
    AFTER INSERT OR DELETE ON public.user_roles
    FOR EACH ROW
    EXECUTE FUNCTION public.log_role_change();

-- Trigger to prevent consent manipulation
CREATE TRIGGER prevent_consent_manipulation_trigger
    BEFORE UPDATE ON public.participants
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_consent_manipulation();

-- =====================================================
-- STEP 6: ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.engagement_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_audit_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 7: CREATE RLS POLICIES
-- =====================================================

-- =====================================================
-- PROFILES POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view their own profile" 
ON public.profiles FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles" 
ON public.profiles FOR SELECT TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- Deny direct profile inserts (handled by trigger)
CREATE POLICY "Deny direct profile inserts" 
ON public.profiles FOR INSERT TO authenticated
WITH CHECK (false);

-- Deny profile deletion
CREATE POLICY "Deny profile deletion" 
ON public.profiles FOR DELETE TO authenticated
USING (false);

-- Deny anonymous access
CREATE POLICY "Require authentication for profiles" 
ON public.profiles FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on profiles" 
ON public.profiles FOR INSERT TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on profiles" 
ON public.profiles FOR UPDATE TO anon
USING (false);

CREATE POLICY "Deny anon delete on profiles" 
ON public.profiles FOR DELETE TO anon
USING (false);

-- =====================================================
-- USER ROLES POLICIES
-- =====================================================

-- Users can view their own roles
CREATE POLICY "Users can view their own roles" 
ON public.user_roles FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Admins can manage all roles
CREATE POLICY "Admins can manage all roles" 
ON public.user_roles FOR ALL TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- Deny anonymous access
CREATE POLICY "Require authentication for user_roles" 
ON public.user_roles FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on user_roles" 
ON public.user_roles FOR INSERT TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on user_roles" 
ON public.user_roles FOR UPDATE TO anon
USING (false);

CREATE POLICY "Deny anon delete on user_roles" 
ON public.user_roles FOR DELETE TO anon
USING (false);

-- =====================================================
-- SESSIONS POLICIES
-- =====================================================

-- Hosts can manage their own sessions
CREATE POLICY "Hosts can manage their own sessions" 
ON public.sessions FOR ALL TO authenticated
USING (auth.uid() = host_id);

-- Participants can view sessions they are part of
CREATE POLICY "Participants can view sessions they are part of" 
ON public.sessions FOR SELECT TO authenticated
USING (is_participant_in_session(id));

-- Deny anonymous access
CREATE POLICY "Require authentication for sessions" 
ON public.sessions FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on sessions" 
ON public.sessions FOR INSERT TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on sessions" 
ON public.sessions FOR UPDATE TO anon
USING (false);

CREATE POLICY "Deny anon delete on sessions" 
ON public.sessions FOR DELETE TO anon
USING (false);

-- =====================================================
-- PARTICIPANTS POLICIES
-- =====================================================

-- Users can view their own participation
CREATE POLICY "Users can view their own participation" 
ON public.participants FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Users can join sessions
CREATE POLICY "Users can join sessions" 
ON public.participants FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own participation
CREATE POLICY "Users can update their own participation" 
ON public.participants FOR UPDATE TO authenticated
USING (auth.uid() = user_id);

-- Hosts can manage participants in their sessions
CREATE POLICY "Hosts can manage participants in their sessions" 
ON public.participants FOR ALL TO authenticated
USING (is_session_host(session_id));

-- Deny anonymous access
CREATE POLICY "Require authentication for participants" 
ON public.participants FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on participants" 
ON public.participants FOR INSERT TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on participants" 
ON public.participants FOR UPDATE TO anon
USING (false);

CREATE POLICY "Deny anon delete on participants" 
ON public.participants FOR DELETE TO anon
USING (false);

-- =====================================================
-- ENGAGEMENT METRICS POLICIES
-- =====================================================

-- Users can view their own metrics
CREATE POLICY "Users can view their own metrics" 
ON public.engagement_metrics FOR SELECT TO authenticated
USING (EXISTS (
    SELECT 1 FROM participants
    WHERE participants.id = engagement_metrics.participant_id
      AND participants.user_id = auth.uid()
));

-- Hosts can view metrics for consenting participants
CREATE POLICY "Hosts can view metrics for consenting participants" 
ON public.engagement_metrics FOR SELECT TO authenticated
USING (EXISTS (
    SELECT 1 FROM participants p
    JOIN sessions s ON s.id = p.session_id
    WHERE p.id = engagement_metrics.participant_id
      AND s.host_id = auth.uid()
      AND p.consent_given = true
));

-- Participants can insert metrics only with consent
CREATE POLICY "Participants can insert metrics only with consent" 
ON public.engagement_metrics FOR INSERT TO authenticated
WITH CHECK (EXISTS (
    SELECT 1 FROM participants p
    WHERE p.id = engagement_metrics.participant_id
      AND p.user_id = auth.uid()
      AND p.consent_given = true
));

-- Deny updates and deletes on engagement metrics (immutable)
CREATE POLICY "Deny engagement metrics updates" 
ON public.engagement_metrics FOR UPDATE TO authenticated
USING (false);

CREATE POLICY "Deny engagement metrics deletion" 
ON public.engagement_metrics FOR DELETE TO authenticated
USING (false);

-- Deny anonymous access
CREATE POLICY "Require authentication for engagement_metrics" 
ON public.engagement_metrics FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on engagement_metrics" 
ON public.engagement_metrics FOR INSERT TO anon
WITH CHECK (false);

-- =====================================================
-- SESSION REPORTS POLICIES
-- =====================================================

-- Hosts can manage reports for their sessions
CREATE POLICY "Hosts can manage reports for their sessions" 
ON public.session_reports FOR ALL TO authenticated
USING (EXISTS (
    SELECT 1 FROM sessions
    WHERE sessions.id = session_reports.session_id
      AND sessions.host_id = auth.uid()
));

-- Participants can view reports for their sessions
CREATE POLICY "Participants can view reports for their sessions" 
ON public.session_reports FOR SELECT TO authenticated
USING (EXISTS (
    SELECT 1 FROM participants p
    JOIN sessions s ON s.id = p.session_id
    WHERE s.id = session_reports.session_id
      AND p.user_id = auth.uid()
));

-- Deny anonymous access
CREATE POLICY "Require authentication for session_reports" 
ON public.session_reports FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on session_reports" 
ON public.session_reports FOR INSERT TO anon
WITH CHECK (false);

CREATE POLICY "Deny anon update on session_reports" 
ON public.session_reports FOR UPDATE TO anon
USING (false);

CREATE POLICY "Deny anon delete on session_reports" 
ON public.session_reports FOR DELETE TO anon
USING (false);

-- =====================================================
-- ROLE AUDIT LOGS POLICIES
-- =====================================================

-- Admins can view all audit logs
CREATE POLICY "Admins can view all audit logs" 
ON public.role_audit_logs FOR SELECT TO authenticated
USING (has_role(auth.uid(), 'admin'));

-- Admins can insert audit logs
CREATE POLICY "Admins can insert audit logs" 
ON public.role_audit_logs FOR INSERT TO authenticated
WITH CHECK (has_role(auth.uid(), 'admin'));

-- Audit logs are immutable - deny updates and deletes
CREATE POLICY "Deny audit log updates" 
ON public.role_audit_logs FOR UPDATE TO authenticated
USING (false);

CREATE POLICY "Deny audit log deletion" 
ON public.role_audit_logs FOR DELETE TO authenticated
USING (false);

-- Deny anonymous access
CREATE POLICY "Require authentication for role_audit_logs" 
ON public.role_audit_logs FOR SELECT TO anon
USING (false);

CREATE POLICY "Deny anon insert on role_audit_logs" 
ON public.role_audit_logs FOR INSERT TO anon
WITH CHECK (false);

-- =====================================================
-- STEP 8: CREATE STORAGE BUCKET
-- =====================================================

-- Create avatars bucket (public)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for avatars
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- =====================================================
-- STEP 9: ENABLE REALTIME (OPTIONAL)
-- =====================================================

-- Enable realtime for tables that need live updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.engagement_metrics;
ALTER PUBLICATION supabase_realtime ADD TABLE public.participants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.sessions;

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================
-- 
-- Next steps:
-- 1. Configure Authentication in Supabase Dashboard:
--    - Enable Email/Password sign-ups
--    - (Optional) Enable email confirmation or disable for development
-- 
-- 2. Set up Edge Functions (if needed):
--    - Deploy functions from supabase/functions/ folder
--    - Add required secrets (RESEND_API_KEY, etc.)
-- 
-- 3. Update your .env file with:
--    VITE_SUPABASE_URL=https://your-project-id.supabase.co
--    VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key
--    VITE_SUPABASE_PROJECT_ID=your-project-id
--
-- =====================================================
