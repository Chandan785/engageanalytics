import { useEffect, useState } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { ScrollArea } from '@/components/ui/scroll-area';
import { History, UserPlus, UserMinus, AlertTriangle } from 'lucide-react';
import { format } from 'date-fns';

interface AuditLog {
  id: string;
  user_id: string;
  target_user_id: string;
  action: string;
  role: string;
  created_at: string;
  admin_profile?: {
    full_name: string | null;
    email: string;
  };
  target_profile?: {
    full_name: string | null;
    email: string;
  };
}

const RoleAuditLog = () => {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAuditLogs();
  }, []);

  const fetchAuditLogs = async () => {
    try {
      const { data, error } = await supabase
        .from('role_audit_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50);

      if (error) throw error;

      // Fetch profile info for each log
      const logsWithProfiles = await Promise.all(
        (data || []).map(async (log) => {
          const [adminProfile, targetProfile] = await Promise.all([
            supabase.from('profiles').select('full_name, email').eq('user_id', log.user_id).single(),
            supabase.from('profiles').select('full_name, email').eq('user_id', log.target_user_id).single(),
          ]);

          return {
            ...log,
            admin_profile: adminProfile.data || undefined,
            target_profile: targetProfile.data || undefined,
          };
        })
      );

      setLogs(logsWithProfiles);
    } catch (error) {
      console.error('Error fetching audit logs:', error);
    } finally {
      setLoading(false);
    }
  };

  const getRoleBadgeClass = (role: string) => {
    switch (role) {
      case 'admin':
        return 'bg-blue-500/10 text-blue-500 border-blue-500/20';
      case 'host':
        return 'bg-primary/10 text-primary border-primary/20';
      case 'participant':
        return 'bg-green-500/10 text-green-500 border-green-500/20';
      case 'viewer':
        return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const getActionIcon = (action: string) => {
    return action === 'add' ? (
      <UserPlus className="h-4 w-4 text-green-500" />
    ) : (
      <UserMinus className="h-4 w-4 text-destructive" />
    );
  };

  const getActionText = (action: string) => {
    return action === 'add' ? 'Added' : 'Removed';
  };

  const getDisplayName = (profile?: { full_name: string | null; email: string }) => {
    if (!profile) return 'Unknown User';
    return profile.full_name || profile.email;
  };

  return (
    <Card className="glass">
      <CardHeader>
        <CardTitle className="font-display flex items-center gap-2">
          <History className="h-5 w-5" />
          Role Change Activity
        </CardTitle>
        <CardDescription>Track all role assignments and removals.</CardDescription>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="space-y-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <Skeleton key={i} className="h-16 w-full" />
            ))}
          </div>
        ) : logs.length > 0 ? (
          <ScrollArea className="h-[400px] pr-4">
            <div className="space-y-3">
              {logs.map((log) => (
                <div
                  key={log.id}
                  className="flex items-start gap-4 p-4 rounded-lg bg-secondary/50 hover:bg-secondary/70 transition-colors"
                >
                  <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center flex-shrink-0">
                    {getActionIcon(log.action)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2 mb-1">
                      <span className="font-medium text-foreground">
                        {getDisplayName(log.admin_profile)}
                      </span>
                      <span className="text-muted-foreground text-sm">
                        {getActionText(log.action)}
                      </span>
                      <Badge variant="outline" className={getRoleBadgeClass(log.role)}>
                        {log.role}
                      </Badge>
                      <span className="text-muted-foreground text-sm">
                        {log.action === 'add' ? 'to' : 'from'}
                      </span>
                      <span className="font-medium text-foreground">
                        {getDisplayName(log.target_profile)}
                      </span>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {format(new Date(log.created_at), 'MMM d, yyyy • h:mm a')}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </ScrollArea>
        ) : (
          <div className="text-center py-12">
            <AlertTriangle className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <p className="text-muted-foreground">No role changes recorded yet.</p>
            <p className="text-sm text-muted-foreground mt-1">
              Changes will appear here when roles are added or removed.
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default RoleAuditLog;
