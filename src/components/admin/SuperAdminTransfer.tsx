import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
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
import { AlertCircle, CheckCircle2, ArrowRight } from 'lucide-react';

interface User {
  user_id: string;
  email: string;
  full_name: string | null;
  role: string;
}

interface SuperAdminTransferProps {
  currentUserId: string;
  currentUserRole: string;
}

export const SuperAdminTransfer = ({
  currentUserId,
  currentUserRole,
}: SuperAdminTransferProps) => {
  const { toast } = useToast();
  const [users, setUsers] = useState<User[]>([]);
  const [selectedNewAdmin, setSelectedNewAdmin] = useState<string>('');
  const [downgradeCurrent, setDowngradeCurrent] = useState(true);
  const [loading, setLoading] = useState(false);
  const [fetchingUsers, setFetchingUsers] = useState(true);
  const [confirmOpen, setConfirmOpen] = useState(false);

  // Only show if current user is SUPER_ADMIN
  if (currentUserRole !== 'super_admin') {
    return null;
  }

  useEffect(() => {
    fetchAdminUsers();
  }, []);

  const fetchAdminUsers = async () => {
    try {
      setFetchingUsers(true);
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
        .in('role', ['admin', 'super_admin'])
        .order('user_id');

      if (error) throw error;

      const formattedUsers = data
        ?.map((item: any) => ({
          user_id: item.user_id,
          email: item.profiles?.email || 'Unknown',
          full_name: item.profiles?.full_name || 'Unknown',
          role: item.role,
        }))
        .filter((u: User) => u.user_id !== currentUserId);

      setUsers(formattedUsers || []);
    } catch (error) {
      console.error('Error fetching admin users:', error);
      toast({
        title: 'Error',
        description: 'Failed to load users',
        variant: 'destructive',
      });
    } finally {
      setFetchingUsers(false);
    }
  };

  const handleTransferOwnership = async () => {
    if (!selectedNewAdmin) {
      toast({
        title: 'Error',
        description: 'Please select a user to transfer ownership to',
        variant: 'destructive',
      });
      return;
    }

    setLoading(true);
    try {
      const { data, error } = await supabase.rpc(
        'transfer_super_admin_ownership',
        {
          p_current_super_admin_id: currentUserId,
          p_new_super_admin_id: selectedNewAdmin,
          p_downgrade_current: downgradeCurrent,
        }
      );

      if (error) throw error;

      if (data?.success) {
        toast({
          title: 'Success',
          description: data.message,
        });
        setSelectedNewAdmin('');
        fetchAdminUsers();
      } else {
        throw new Error(data?.error || 'Transfer failed');
      }
    } catch (error: any) {
      toast({
        title: 'Error',
        description: error.message || 'Failed to transfer ownership',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  };

  const selectedUser = users.find((u) => u.user_id === selectedNewAdmin);

  return (
    <>
      <Card className="border-purple-200 bg-gradient-to-br from-purple-50 to-transparent dark:border-purple-900 dark:from-purple-950">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Crown className="h-5 w-5 text-purple-600" />
          SUPER_ADMIN Ownership Transfer
        </CardTitle>
        <CardDescription>
          Transfer SUPER_ADMIN privileges to another user
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Warning Alert */}
        <div className="flex gap-3 rounded-lg border border-yellow-200 bg-yellow-50 p-3 dark:border-yellow-900 dark:bg-yellow-950">
          <AlertCircle className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
          <div className="text-sm text-yellow-800 dark:text-yellow-200">
            <p className="font-semibold">Caution:</p>
            <p>
              This action will transfer complete administrative control. Ensure
              you trust the recipient.
            </p>
          </div>
        </div>

        {/* User Selection */}
        <div className="space-y-2">
          <label className="text-sm font-medium">Select New SUPER_ADMIN</label>
          <Select value={selectedNewAdmin} onValueChange={setSelectedNewAdmin}>
            <SelectTrigger disabled={fetchingUsers}>
              <SelectValue
                placeholder={
                  fetchingUsers ? 'Loading users...' : 'Choose a user...'
                }
              />
            </SelectTrigger>
            <SelectContent>
              {users.map((user) => (
                <SelectItem key={user.user_id} value={user.user_id}>
                  <div className="flex items-center gap-2">
                    <span className="font-medium">{user.full_name}</span>
                    <span className="text-xs text-muted-foreground">
                      ({user.email})
                    </span>
                    <span
                      className={`text-xs font-semibold ${
                        user.role === 'super_admin'
                          ? 'text-purple-600'
                          : 'text-blue-600'
                      }`}
                    >
                      {user.role.toUpperCase()}
                    </span>
                  </div>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        {/* Transfer Preview */}
        {selectedNewAdmin && (
          <div className="rounded-lg bg-blue-50 p-3 dark:bg-blue-950">
            <p className="text-xs font-medium text-blue-900 dark:text-blue-100">
              Transfer Plan:
            </p>
            <div className="mt-2 space-y-1 text-sm">
              <div className="flex items-center gap-2">
                <span className="font-medium">You</span>
                <ArrowRight className="h-4 w-4" />
                <span className="font-medium">
                  {downgradeCurrent ? 'ADMIN' : 'SUPER_ADMIN (keep)'}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="font-medium">
                  {users.find((u) => u.user_id === selectedNewAdmin)?.full_name}
                </span>
                <ArrowRight className="h-4 w-4" />
                <span className="font-medium">SUPER_ADMIN</span>
              </div>
            </div>
          </div>
        )}

        {/* Downgrade Option */}
        <div className="flex items-center gap-2">
          <input
            type="checkbox"
            id="downgrade"
            checked={downgradeCurrent}
            onChange={(e) => setDowngradeCurrent(e.target.checked)}
            disabled={loading}
            className="h-4 w-4 rounded"
          />
          <label htmlFor="downgrade" className="text-sm cursor-pointer">
            Downgrade myself to ADMIN after transfer
            <span className="block text-xs text-muted-foreground">
              Recommended: Keep at least one SUPER_ADMIN active
            </span>
          </label>
        </div>

        {/* Transfer Button */}
        <Button
          onClick={() => setConfirmOpen(true)}
          disabled={!selectedNewAdmin || loading}
          className="w-full bg-purple-600 hover:bg-purple-700"
        >
          <span className="flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4" />
            Confirm Transfer
          </span>
        </Button>

        {/* Info Box */}
        <div className="text-xs text-muted-foreground space-y-1">
          <p>• System always maintains at least 1 SUPER_ADMIN</p>
          <p>• Transfer is permanent and immediate</p>
          <p>• All your current sessions remain active</p>
        </div>
      </CardContent>
      </Card>
      <Dialog open={confirmOpen} onOpenChange={setConfirmOpen}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Confirm SUPER_ADMIN Transfer</DialogTitle>
          <DialogDescription>
            This action will transfer SUPER_ADMIN privileges to
            {' '}
            <span className="font-semibold text-foreground">
              {selectedUser?.full_name || selectedUser?.email || 'the selected user'}
            </span>
            . You will be downgraded to ADMIN if the downgrade option is enabled.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" onClick={() => setConfirmOpen(false)}>
            Cancel
          </Button>
          <Button
            onClick={async () => {
              setConfirmOpen(false);
              await handleTransferOwnership();
            }}
            disabled={loading}
            className="bg-purple-600 hover:bg-purple-700"
          >
            {loading ? (
              <span className="flex items-center gap-2">
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                Transferring...
              </span>
            ) : (
              'Transfer Now'
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
      </Dialog>
    </>
  );
};

// Icon component
function Crown(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M11 15H9m6 0h-2m2-4l3-4H8l3 4M2 8h20M3.5 18h17l-1 2h-15l-1-2z" />
    </svg>
  );
}
