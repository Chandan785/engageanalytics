import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { AppHeader } from '@/components/AppHeader';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
} from '@/components/ui/sidebar';
import { Users, Shield, Settings, Activity, ArrowRightLeft, BookOpen } from 'lucide-react';
import UserRoleManagement from '@/components/admin/UserRoleManagement';
import { EnhancedRoleManagement } from '@/components/admin/EnhancedRoleManagement';
import { SuperAdminTransfer } from '@/components/admin/SuperAdminTransfer';
import RoleAuditLog from '@/components/admin/RoleAuditLog';

const SuperAdminDashboard = () => {
  const { user, isSuperAdmin } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isSuperAdmin) {
      navigate('/dashboard', { replace: true });
    }
  }, [isSuperAdmin, navigate]);

  if (!isSuperAdmin) {
    return null;
  }

  return (
    <SidebarProvider>
      <Sidebar variant="inset">
        <SidebarHeader>
          <div className="flex items-center gap-3 px-2 py-2">
            <div className="h-9 w-9 rounded-lg bg-purple-600/10 text-purple-600 flex items-center justify-center">
              <Shield className="h-5 w-5" />
            </div>
            <div>
              <p className="text-sm font-semibold">Super Admin</p>
              <p className="text-xs text-muted-foreground">System Control</p>
            </div>
          </div>
        </SidebarHeader>
        <SidebarContent>
          <SidebarGroup>
            <SidebarGroupLabel>Management</SidebarGroupLabel>
            <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <a href="#users" className="flex items-center gap-2">
                    <Users className="h-4 w-4" />
                    Users Management
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <a href="#roles" className="flex items-center gap-2">
                    <Shield className="h-4 w-4" />
                    Role Management
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <a href="#transfer" className="flex items-center gap-2">
                    <ArrowRightLeft className="h-4 w-4" />
                    Transfer Super Admin
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <a href="#settings" className="flex items-center gap-2">
                    <Settings className="h-4 w-4" />
                    System Settings
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <a href="#audit" className="flex items-center gap-2">
                    <BookOpen className="h-4 w-4" />
                    Audit Logs
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <a href="#analytics" className="flex items-center gap-2">
                    <Activity className="h-4 w-4" />
                    Global Analytics
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
            </SidebarMenu>
          </SidebarGroup>
        </SidebarContent>
      </Sidebar>
      <SidebarInset>
        <AppHeader backTo="/dashboard" backLabel="Back" />
        <main className="container py-8 space-y-10">
          <section id="users" className="space-y-4">
            <div>
              <h1 className="font-display text-3xl font-bold">Super Admin Dashboard</h1>
              <p className="text-muted-foreground">Full control over users, roles, and system security.</p>
            </div>
            <UserRoleManagement />
          </section>

          <section id="roles" className="space-y-4">
            <Card className="glass">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Shield className="h-5 w-5" />
                  Role Management (Advanced)
                </CardTitle>
                <CardDescription>Change user roles with SUPER_ADMIN rules enforced.</CardDescription>
              </CardHeader>
              <CardContent>
                <EnhancedRoleManagement
                  currentUserId={user?.id || ''}
                  currentUserRole="super_admin"
                />
              </CardContent>
            </Card>
          </section>

          <section id="transfer" className="space-y-4">
            <SuperAdminTransfer
              currentUserId={user?.id || ''}
              currentUserRole="super_admin"
            />
          </section>

          <section id="settings" className="space-y-4">
            <Card className="glass">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Settings className="h-5 w-5" />
                  System Settings
                </CardTitle>
                <CardDescription>Global system controls reserved for SUPER_ADMIN.</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-sm text-muted-foreground">
                  Settings management can be extended here (feature flags, policies, integrations).
                </div>
              </CardContent>
            </Card>
          </section>

          <section id="audit" className="space-y-4">
            <RoleAuditLog />
          </section>

          <section id="analytics" className="space-y-4">
            <Card className="glass">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Activity className="h-5 w-5" />
                  Global Analytics
                </CardTitle>
                <CardDescription>High-level system analytics overview.</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="text-sm text-muted-foreground">
                  Use the Analytics page for detailed reports and engagement trends.
                </div>
              </CardContent>
            </Card>
          </section>
        </main>
      </SidebarInset>
    </SidebarProvider>
  );
};

export default SuperAdminDashboard;
