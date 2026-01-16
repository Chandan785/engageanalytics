# SUPER_ADMIN Ownership Transfer Feature

## Overview

This feature implements a secure SUPER_ADMIN role management system with ownership transfer capabilities. It enforces strict rules to prevent unauthorized access escalation while ensuring the system always maintains at least one SUPER_ADMIN.

## Roles Hierarchy

```
PARTICIPANT (0)
    ↓
VIEWER (0)
    ↓
HOST (1)
    ↓
ADMIN (2)
    ↓
SUPER_ADMIN (3)
```

## Core Rules

### Rule 1: ADMIN Role Restrictions
- **ADMIN** can ONLY change roles between: `PARTICIPANT` ↔ `HOST` ↔ `VIEWER`
- **ADMIN** CANNOT:
  - Change or manage ADMIN role
  - Change or manage SUPER_ADMIN role
  - Delete SUPER_ADMIN users
  - Promote users to ADMIN or SUPER_ADMIN

### Rule 2: SUPER_ADMIN Full Control
- **SUPER_ADMIN** can manage ALL roles (PARTICIPANT, HOST, VIEWER, ADMIN, SUPER_ADMIN)
- **SUPER_ADMIN** can assign SUPER_ADMIN to other users
- **SUPER_ADMIN** can downgrade themselves after transfer

### Rule 3: SUPER_ADMIN Ownership Transfer
**Process:**
1. Current SUPER_ADMIN selects a target user (typically ADMIN)
2. Target user is promoted to SUPER_ADMIN
3. Current SUPER_ADMIN can optionally downgrade themselves to ADMIN
4. System maintains audit log of transfer

**Safety Guarantees:**
- ✅ System ALWAYS keeps at least 1 SUPER_ADMIN active
- ✅ Cannot remove the last SUPER_ADMIN
- ✅ Cannot transfer to self
- ✅ Target user must exist in system

### Rule 4: Immutable System Constraint
- The database will ALWAYS contain at least 1 user with SUPER_ADMIN role
- Attempting to remove the last SUPER_ADMIN will fail with a clear error message
- RLS policies prevent direct deletion of SUPER_ADMIN users

## Implementation Files

### Database Migrations
**File:** `supabase/migrations/20260116_add_super_admin_role.sql`

Contains:
- Add `super_admin` to app_role enum
- `validate_role_change()` - Validates role transitions
- `transfer_super_admin_ownership()` - Securely transfers ownership
- `change_user_role()` - Safe role changes with validation
- RLS policies for SUPER_ADMIN protection

### Frontend Components

#### 1. SuperAdminTransfer Component
**File:** `src/components/admin/SuperAdminTransfer.tsx`

Features:
- Shows only to SUPER_ADMIN users
- Displays list of eligible users (ADMIN and SUPER_ADMIN)
- Preview of transfer plan before confirmation
- Option to downgrade current SUPER_ADMIN to ADMIN
- Clear warning about consequences
- Real-time validation

```tsx
import { SuperAdminTransfer } from '@/components/admin/SuperAdminTransfer';

// In Admin Dashboard:
<SuperAdminTransfer 
  currentUserId={userId}
  currentUserRole={userRole}
/>
```

#### 2. EnhancedRoleManagement Component
**File:** `src/components/admin/EnhancedRoleManagement.tsx`

Features:
- Lists all users with current roles
- Role-based access control (ADMIN vs SUPER_ADMIN)
- Real-time validation with warnings
- Prevents invalid role changes
- Shows detailed validation messages
- Dialog-based role change flow

```tsx
import { EnhancedRoleManagement } from '@/components/admin/EnhancedRoleManagement';

// In Admin Dashboard:
<EnhancedRoleManagement 
  currentUserId={userId}
  currentUserRole={userRole}
/>
```

## Setup Instructions

### Step 1: Run Database Migration

Go to Supabase SQL Editor and run the migration file:
```sql
-- Copy entire content from supabase/migrations/20260116_add_super_admin_role.sql
```

**Expected Results:**
- ✅ `super_admin` added to app_role enum
- ✅ 3 new functions created
- ✅ Permissions granted

### Step 2: Add Components to Admin Dashboard

Update `src/pages/AdminDashboard.tsx`:

```tsx
import { SuperAdminTransfer } from '@/components/admin/SuperAdminTransfer';
import { EnhancedRoleManagement } from '@/components/admin/EnhancedRoleManagement';

export const AdminDashboard = () => {
  // ... existing code ...
  
  return (
    <Tabs>
      <TabsTrigger value="roles">Role Management</TabsTrigger>
      
      <TabsContent value="roles">
        {/* Show transfer only to SUPER_ADMIN */}
        {userRole === 'super_admin' && (
          <SuperAdminTransfer 
            currentUserId={user.id}
            currentUserRole={userRole}
          />
        )}
        
        {/* Show enhanced role management */}
        <EnhancedRoleManagement 
          currentUserId={user.id}
          currentUserRole={userRole}
        />
      </TabsContent>
    </Tabs>
  );
};
```

### Step 3: Update AuthContext

Ensure `AuthContext.tsx` exposes `userRole`:

```tsx
const { user, userRole } = useAuth();
// Make sure userRole includes 'super_admin'
```

## API Reference

### `validate_role_change()`
```sql
SELECT public.validate_role_change(
  p_current_user_id,    -- UUID
  p_target_user_id,     -- UUID
  p_new_role             -- app_role (participant, host, viewer, admin, super_admin)
) → jsonb
```

**Returns:**
```json
{
  "success": true/false,
  "error": "Error message if success=false"
}
```

### `transfer_super_admin_ownership()`
```sql
SELECT public.transfer_super_admin_ownership(
  p_current_super_admin_id,  -- UUID (must be SUPER_ADMIN)
  p_new_super_admin_id,      -- UUID (target user)
  p_downgrade_current         -- boolean (optional, default: true)
) → jsonb
```

**Returns:**
```json
{
  "success": true/false,
  "message": "Transfer success message",
  "error": "Error message if success=false"
}
```

### `change_user_role()`
```sql
SELECT public.change_user_role(
  p_admin_user_id,      -- UUID (admin/super_admin making change)
  p_target_user_id,     -- UUID (user being modified)
  p_new_role             -- app_role
) → jsonb
```

**Returns:**
```json
{
  "success": true/false,
  "message": "Role changed successfully",
  "error": "Error message if success=false"
}
```

## Usage Scenarios

### Scenario 1: SUPER_ADMIN Transfers Ownership

```typescript
// Alice (SUPER_ADMIN) wants to transfer to Bob (ADMIN)
const result = await supabase.rpc('transfer_super_admin_ownership', {
  p_current_super_admin_id: alice_id,
  p_new_super_admin_id: bob_id,
  p_downgrade_current: true  // Alice becomes ADMIN
});

// Result: Alice → ADMIN, Bob → SUPER_ADMIN
```

### Scenario 2: ADMIN Changes User Role

```typescript
// Charlie (ADMIN) changes David's role
const result = await supabase.rpc('change_user_role', {
  p_admin_user_id: charlie_id,
  p_target_user_id: david_id,
  p_new_role: 'host'
});

// Result: David → HOST (only if Charlie is ADMIN and David was PARTICIPANT/VIEWER)
```

### Scenario 3: SUPER_ADMIN Promotes ADMIN to SUPER_ADMIN

```typescript
// Eve (SUPER_ADMIN) promotes Frank (ADMIN) to SUPER_ADMIN
const result = await supabase.rpc('change_user_role', {
  p_admin_user_id: eve_id,
  p_target_user_id: frank_id,
  p_new_role: 'super_admin'
});

// Result: Frank → SUPER_ADMIN (only SUPER_ADMIN can do this)
```

## Security Features

✅ **Role Validation:**
- Every role change is validated before execution
- Prevents unauthorized escalation

✅ **Audit Logging:**
- All role changes logged in `role_audit_logs`
- Tracks who changed what and when

✅ **Database Constraints:**
- RLS policies enforce role-based access
- Immutable SUPER_ADMIN count constraint

✅ **Frontend Validation:**
- Real-time validation feedback
- Clear error messages
- Prevents invalid states

✅ **System Safety:**
- Always maintains ≥1 SUPER_ADMIN
- Cannot remove last SUPER_ADMIN
- Cannot transfer to self
- Cannot violate role hierarchy

## Error Handling

### Common Errors & Solutions

**"Only SUPER_ADMIN can assign SUPER_ADMIN role"**
- Only SUPER_ADMIN users can promote others to SUPER_ADMIN
- Solution: Use SUPER_ADMIN account for this operation

**"ADMIN can only assign PARTICIPANT, HOST, or VIEWER roles"**
- ADMIN users cannot manage ADMIN/SUPER_ADMIN roles
- Solution: Have SUPER_ADMIN perform the operation

**"Cannot remove the last SUPER_ADMIN"**
- System prevents removing all SUPER_ADMIN users
- Solution: Assign SUPER_ADMIN to another user first

**"Target user does not exist"**
- Selected user ID is invalid or deleted
- Solution: Refresh user list and try again

## Testing

### Test Case 1: ADMIN Role Restrictions
```typescript
// Setup: Alice is ADMIN, Bob is PARTICIPANT
// Action: Alice tries to promote Bob to ADMIN
// Expected: Error "Only SUPER_ADMIN can assign ADMIN role"
```

### Test Case 2: SUPER_ADMIN Transfer
```typescript
// Setup: Charlie is SUPER_ADMIN, David is ADMIN
// Action: Charlie transfers to David with downgrade
// Expected: 
//   - David → SUPER_ADMIN
//   - Charlie → ADMIN
//   - Audit log created
```

### Test Case 3: Last SUPER_ADMIN Protection
```typescript
// Setup: Eve is the only SUPER_ADMIN
// Action: Attempt to demote Eve
// Expected: Error "Cannot remove the last SUPER_ADMIN"
```

## Database Schema

### Updated Enums
```sql
CREATE TYPE app_role AS ENUM (
  'super_admin',  -- NEW
  'admin',
  'host',
  'participant',
  'viewer'
);
```

### Audit Log Table
```sql
CREATE TABLE role_audit_logs (
  id uuid PRIMARY KEY,
  user_id uuid,           -- Admin making change
  target_user_id uuid,    -- User being modified
  action text,            -- 'add', 'remove', 'change', 'transfer'
  role app_role,          -- Role involved
  created_at timestamp
);
```

## Deployment Checklist

- [ ] Run SQL migration in Supabase
- [ ] Add SuperAdminTransfer component to AdminDashboard
- [ ] Add EnhancedRoleManagement component to AdminDashboard
- [ ] Test ADMIN role restrictions
- [ ] Test SUPER_ADMIN transfer
- [ ] Test last SUPER_ADMIN protection
- [ ] Verify audit logs are created
- [ ] Push to GitHub
- [ ] Deploy to Vercel

## Support

For issues or questions:
1. Check error messages in browser console
2. Check Supabase logs in Dashboard
3. Verify all migrations were applied
4. Check role_audit_logs for history
