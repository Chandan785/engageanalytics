import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useToast } from '@/hooks/use-toast';
import { AlertCircle, CheckCircle2, Loader2 } from 'lucide-react';

interface User {
  user_id: string;
  email: string;
  full_name: string | null;
  current_role: string;
}

interface EnhancedRoleManagementProps {
  currentUserId: string;
  currentUserRole: string;
}

const ROLE_HIERARCHY: { [key: string]: number } = {
  participant: 0,
  viewer: 0,
  host: 1,
  admin: 2,
  super_admin: 3,
};

const AVAILABLE_ROLES = ['participant', 'viewer', 'host', 'admin', 'super_admin'];

export const EnhancedRoleManagement = ({
  currentUserId,
  currentUserRole,
}: EnhancedRoleManagementProps) => {
  const { toast } = useToast();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [newRole, setNewRole] = useState<string>('');
  const [showDialog, setShowDialog] = useState(false);
  const [processing, setProcessing] = useState(false);
  const [validationMessage, setValidationMessage] = useState<{
    type: 'error' | 'warning' | 'info';
    message: string;
  } | null>(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('user_roles')
        .select(
          `
          user_id,
          role,
          profiles:user_id (
            email,
            full_name
          )
        `
        )
        .order('user_id');

      if (error) throw error;

      const formattedUsers = data
        ?.map((item: any) => ({
          user_id: item.user_id,
          email: item.profiles?.email || 'Unknown',
          full_name: item.profiles?.full_name || 'Unknown',
          current_role: item.role,
        }))
        .filter((u: User) => u.user_id !== currentUserId);

      setUsers(formattedUsers || []);
    } catch (error) {
      console.error('Error fetching users:', error);
      toast({
        title: 'Error',
        description: 'Failed to load users',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  };

  const validateRoleChange = (
    targetUser: User,
    role: string
  ): {
    valid: boolean;
    message: string;
    type: 'error' | 'warning' | 'info';
  } => {
    const currentHierarchy = ROLE_HIERARCHY[currentUserRole];
    const targetHierarchy = ROLE_HIERARCHY[role];
    const targetCurrentHierarchy = ROLE_HIERARCHY[targetUser.current_role];

    if (
      (targetUser.current_role === 'admin' || targetUser.current_role === 'super_admin') &&
      role !== targetUser.current_role
    ) {
      return {
        valid: false,
        message: 'Admin and SUPER_ADMIN roles cannot be downgraded or removed',
        type: 'error',
      };
    }

    // Rule 1: Only SUPER_ADMIN can assign SUPER_ADMIN
    if (role === 'super_admin' && currentUserRole !== 'super_admin') {
      return {
        valid: false,
        message: 'Only SUPER_ADMIN can assign SUPER_ADMIN role',
        type: 'error',
      };
    }

    // Rule 2: ADMIN can only change between PARTICIPANT, HOST, VIEWER
    if (currentUserRole === 'admin') {
      if (!['participant', 'viewer', 'host'].includes(role)) {
        return {
          valid: false,
          message:
            'ADMIN can only assign PARTICIPANT, VIEWER, or HOST roles',
          type: 'error',
        };
      }
      if (
        targetUser.current_role === 'admin' ||
        targetUser.current_role === 'super_admin'
      ) {
        return {
          valid: false,
          message: 'ADMIN cannot change ADMIN or SUPER_ADMIN roles',
          type: 'error',
        };
      }
    }

    // Rule 3: Only SUPER_ADMIN can assign ADMIN role
    if (role === 'admin' && currentUserRole !== 'super_admin') {
      return {
        valid: false,
        message: 'Only SUPER_ADMIN can assign ADMIN role',
        type: 'error',
      };
    }

    // Rule 4: Prevent removing last SUPER_ADMIN
    if (
      targetUser.current_role === 'super_admin' &&
      role !== 'super_admin'
    ) {
      return {
        valid: false,
        message:
          'Cannot remove the last SUPER_ADMIN. Assign SUPER_ADMIN to another user first.',
        type: 'error',
      };
    }

    // Warning: Changing own role to lower hierarchy
    if (targetUser.user_id === currentUserId && targetHierarchy < currentHierarchy) {
      return {
        valid: true,
        message: 'Warning: You are downgrading your own role',
        type: 'warning',
      };
    }

    return {
      valid: true,
      message: `Ready to change ${targetUser.full_name} to ${role.toUpperCase()}`,
      type: 'info',
    };
  };

  const handleOpenDialog = (user: User) => {
    setSelectedUser(user);
    setNewRole('');
    setValidationMessage(null);
    setShowDialog(true);
  };

  const handleRoleChange = (role: string) => {
    setNewRole(role);
    if (selectedUser) {
      const validation = validateRoleChange(selectedUser, role);
      setValidationMessage({
        type: validation.type,
        message: validation.message,
      });
    }
  };

  const handleConfirmChange = async () => {
    if (!selectedUser || !newRole) return;

    const validation = validateRoleChange(selectedUser, newRole);
    if (!validation.valid) {
      toast({
        title: 'Invalid Role Change',
        description: validation.message,
        variant: 'destructive',
      });
      return;
    }

    setProcessing(true);
    try {
      const { data, error } = await supabase.rpc('change_user_role', {
        p_admin_user_id: currentUserId,
        p_target_user_id: selectedUser.user_id,
        p_new_role: newRole,
      });

      if (error) throw error;

      if (data?.success) {
        toast({
          title: 'Success',
          description: `Role changed to ${newRole.toUpperCase()}`,
        });
        setShowDialog(false);
        fetchUsers();
      } else {
        throw new Error(data?.error || 'Role change failed');
      }
    } catch (error: any) {
      toast({
        title: 'Error',
        description: error.message || 'Failed to change role',
        variant: 'destructive',
      });
    } finally {
      setProcessing(false);
    }
  };

  const canManageUser = (user: User): boolean => {
    if (currentUserRole === 'super_admin') return true;
    if (currentUserRole === 'admin') {
      return !['admin', 'super_admin'].includes(user.current_role);
    }
    return false;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4">
        {users.map((user) => (
          <div
            key={user.user_id}
            className="flex items-center justify-between rounded-lg border p-4"
          >
            <div className="flex-1">
              <p className="font-medium">{user.full_name || 'Unknown'}</p>
              <p className="text-sm text-muted-foreground">{user.email}</p>
            </div>
            <div className="flex items-center gap-2">
              <span
                className={`text-xs font-semibold px-2 py-1 rounded-full ${
                  user.current_role === 'super_admin'
                    ? 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200'
                    : user.current_role === 'admin'
                    ? 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200'
                    : 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'
                }`}
              >
                {user.current_role.toUpperCase()}
              </span>
              <Button
                onClick={() => handleOpenDialog(user)}
                disabled={!canManageUser(user)}
                variant="outline"
                size="sm"
              >
                Change Role
              </Button>
            </div>
          </div>
        ))}
      </div>

      <Dialog open={showDialog} onOpenChange={setShowDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Change User Role</DialogTitle>
            <DialogDescription>
              Select a new role for {selectedUser?.full_name}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            {/* Current Role Display */}
            <div className="rounded-lg bg-muted p-3">
              <p className="text-xs font-medium text-muted-foreground mb-1">
                Current Role
              </p>
              <p className="font-semibold">
                {selectedUser?.current_role.toUpperCase()}
              </p>
            </div>

            {/* Role Selector */}
            <div className="space-y-2">
              <label className="text-sm font-medium">New Role</label>
              <Select value={newRole} onValueChange={handleRoleChange}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a role..." />
                </SelectTrigger>
                <SelectContent>
                  {AVAILABLE_ROLES.map((role) => {
                    const canSelect =
                      currentUserRole === 'super_admin' ||
                      (currentUserRole === 'admin' &&
                        ['participant', 'viewer', 'host'].includes(role));

                    return (
                      <SelectItem
                        key={role}
                        value={role}
                        disabled={!canSelect}
                      >
                        {role.toUpperCase()}
                      </SelectItem>
                    );
                  })}
                </SelectContent>
              </Select>
            </div>

            {/* Validation Message */}
            {validationMessage && (
              <div
                className={`flex gap-2 p-3 rounded-lg text-sm ${
                  validationMessage.type === 'error'
                    ? 'bg-red-50 text-red-800 dark:bg-red-950 dark:text-red-200'
                    : validationMessage.type === 'warning'
                    ? 'bg-yellow-50 text-yellow-800 dark:bg-yellow-950 dark:text-yellow-200'
                    : 'bg-blue-50 text-blue-800 dark:bg-blue-950 dark:text-blue-200'
                }`}
              >
                {validationMessage.type === 'error' ? (
                  <AlertCircle className="h-4 w-4 flex-shrink-0 mt-0.5" />
                ) : (
                  <CheckCircle2 className="h-4 w-4 flex-shrink-0 mt-0.5" />
                )}
                <span>{validationMessage.message}</span>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex gap-2 justify-end">
              <Button
                onClick={() => setShowDialog(false)}
                disabled={processing}
                variant="outline"
              >
                Cancel
              </Button>
              <Button
                onClick={handleConfirmChange}
                disabled={!newRole || processing || !validationMessage?.type}
              >
                {processing ? (
                  <Loader2 className="h-4 w-4 animate-spin mr-2" />
                ) : null}
                Confirm Change
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
};
