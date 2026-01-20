import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { Loader2 } from 'lucide-react';

const RoleBasedRedirect = () => {
  const { isAdmin, isSuperAdmin, isHost, loading, user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (loading) return;

    if (!user) {
      navigate('/auth');
      return;
    }

    // Check if user was trying to join a session before logging in
    const joinSessionId = sessionStorage.getItem('joinSessionId');
    if (joinSessionId) {
      sessionStorage.removeItem('joinSessionId');
      navigate(`/join/${joinSessionId}`, { replace: true });
      return;
    }

    // Redirect based on role priority: super_admin > admin > host > participant
    if (isSuperAdmin) {
      navigate('/super-admin', { replace: true });
    } else if (isAdmin) {
      navigate('/admin', { replace: true });
    } else if (isHost) {
      navigate('/host-dashboard', { replace: true });
    } else {
      navigate('/participant-dashboard', { replace: true });
    }
  }, [isAdmin, isSuperAdmin, isHost, loading, user, navigate]);

  return (
    <div className="min-h-screen bg-gradient-hero flex items-center justify-center">
      <div className="text-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary mx-auto mb-4" />
        <p className="text-muted-foreground">Redirecting to your dashboard...</p>
      </div>
    </div>
  );
};

export default RoleBasedRedirect;
