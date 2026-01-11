import { useMemo } from 'react';
import { Check, X, AlertTriangle } from 'lucide-react';

interface PasswordStrengthIndicatorProps {
  password: string;
  email?: string;
}

// Common passwords list (top 100 most common)
const COMMON_PASSWORDS = new Set([
  'password', '123456', '12345678', 'qwerty', 'abc123', 'monkey', '1234567',
  'letmein', 'trustno1', 'dragon', 'baseball', 'iloveyou', 'master', 'sunshine',
  'ashley', 'bailey', 'shadow', '123123', '654321', 'superman', 'qazwsx',
  'michael', 'football', 'password1', 'password123', 'batman', 'login',
  'admin', 'welcome', 'hello', '123456789', '1234567890', 'passw0rd',
  '1q2w3e4r', 'qwerty123', 'admin123', 'root', 'toor', 'pass', 'test',
  'guest', 'master123', 'changeme', 'mustang', 'access', 'thunder',
  'harley', 'ranger', 'dallas', 'yankees', 'jordan', 'hunter', 'pepper',
  'thomas', 'robert', 'daniel', 'orange', 'banana', 'joshua', 'jessica',
  'jennifer', 'michelle', 'amanda', 'nicole', 'princess', 'ginger', 'cookie',
  'killer', 'computer', 'internet', 'charlie', 'george', 'soccer', 'hockey',
  'basketball', 'tennis', 'golf', 'swimming', 'running', 'walking', 'fitness',
  '111111', '222222', '333333', '444444', '555555', '666666', '777777',
  '888888', '999999', '000000', 'abcdef', 'abcd1234', 'abc12345', 'qwertyuiop',
  'asdfghjkl', 'zxcvbnm', 'password!', 'p@ssw0rd', 'p@ssword', 'letmein1',
  '123qwe', 'qwe123', 'zaq1zaq1', '!qaz2wsx', 'love', 'freedom', 'ninja'
]);

// Sequential patterns to check
const SEQUENTIAL_PATTERNS = [
  'abcdefghijklmnopqrstuvwxyz',
  '01234567890',
  'qwertyuiop',
  'asdfghjkl',
  'zxcvbnm',
];

const isSequential = (password: string): boolean => {
  const lower = password.toLowerCase();
  for (const pattern of SEQUENTIAL_PATTERNS) {
    // Check for 4+ consecutive characters from the pattern
    for (let i = 0; i <= pattern.length - 4; i++) {
      const seq = pattern.slice(i, i + 4);
      if (lower.includes(seq)) return true;
      // Also check reverse
      const reverseSeq = seq.split('').reverse().join('');
      if (lower.includes(reverseSeq)) return true;
    }
  }
  return false;
};

const isRepeating = (password: string): boolean => {
  // Check for 3+ repeating characters
  return /(.)\1{2,}/.test(password);
};

const containsEmail = (password: string, email?: string): boolean => {
  if (!email) return false;
  const emailParts = email.toLowerCase().split('@');
  const username = emailParts[0];
  if (username.length >= 3 && password.toLowerCase().includes(username)) {
    return true;
  }
  return false;
};

const PasswordStrengthIndicator = ({ password, email }: PasswordStrengthIndicatorProps) => {
  const checks = useMemo(() => {
    const lowerPassword = password.toLowerCase();
    return {
      length: password.length >= 8,
      uppercase: /[A-Z]/.test(password),
      lowercase: /[a-z]/.test(password),
      number: /[0-9]/.test(password),
      special: /[!@#$%^&*(),.?":{}|<>]/.test(password),
      notCommon: !COMMON_PASSWORDS.has(lowerPassword),
      notSequential: !isSequential(password),
      notRepeating: !isRepeating(password),
      notEmail: !containsEmail(password, email),
    };
  }, [password, email]);

  const warnings = useMemo(() => {
    const result: string[] = [];
    if (!checks.notCommon) result.push('This is a commonly used password');
    if (!checks.notSequential) result.push('Avoid sequential patterns');
    if (!checks.notRepeating) result.push('Avoid repeating characters');
    if (!checks.notEmail) result.push('Password should not contain your email');
    return result;
  }, [checks]);

  const strength = useMemo(() => {
    // Core requirements
    const coreChecks = [checks.length, checks.uppercase, checks.lowercase, checks.number, checks.special];
    const corePassed = coreChecks.filter(Boolean).length;
    
    // Security checks (must all pass for strong password)
    const securityChecks = [checks.notCommon, checks.notSequential, checks.notRepeating, checks.notEmail];
    const allSecurityPassed = securityChecks.every(Boolean);
    
    if (corePassed === 0) return { label: '', color: '', width: '0%', score: 0 };
    
    // If any security check fails, cap at Medium
    if (!allSecurityPassed) {
      if (corePassed <= 2) return { label: 'Weak', color: 'bg-destructive', width: '25%', score: 1 };
      return { label: 'Medium', color: 'bg-yellow-500', width: '50%', score: 2 };
    }
    
    if (corePassed <= 2) return { label: 'Weak', color: 'bg-destructive', width: '25%', score: 1 };
    if (corePassed <= 3) return { label: 'Fair', color: 'bg-orange-500', width: '50%', score: 2 };
    if (corePassed <= 4) return { label: 'Good', color: 'bg-yellow-500', width: '75%', score: 3 };
    return { label: 'Strong', color: 'bg-green-500', width: '100%', score: 4 };
  }, [checks]);

  if (!password) return null;

  return (
    <div className="space-y-2 mt-2">
      <div className="flex items-center gap-2">
        <div className="flex-1 h-1.5 bg-muted rounded-full overflow-hidden">
          <div
            className={`h-full transition-all duration-300 ${strength.color}`}
            style={{ width: strength.width }}
          />
        </div>
        {strength.label && (
          <span className={`text-xs font-medium ${
            strength.label === 'Weak' ? 'text-destructive' : 
            strength.label === 'Fair' ? 'text-orange-500' :
            strength.label === 'Medium' || strength.label === 'Good' ? 'text-yellow-500' : 'text-green-500'
          }`}>
            {strength.label}
          </span>
        )}
      </div>
      
      {/* Warnings */}
      {warnings.length > 0 && (
        <div className="space-y-1">
          {warnings.map((warning, index) => (
            <div key={index} className="flex items-center gap-1.5 text-xs text-destructive">
              <AlertTriangle className="h-3 w-3" />
              <span>{warning}</span>
            </div>
          ))}
        </div>
      )}
      
      <div className="grid grid-cols-2 gap-1 text-xs">
        <CheckItem passed={checks.length} label="8+ characters" />
        <CheckItem passed={checks.uppercase} label="Uppercase letter" />
        <CheckItem passed={checks.lowercase} label="Lowercase letter" />
        <CheckItem passed={checks.number} label="Number" />
        <CheckItem passed={checks.special} label="Special character" />
        <CheckItem passed={checks.notCommon} label="Not common password" />
      </div>
    </div>
  );
};

const CheckItem = ({ passed, label }: { passed: boolean; label: string }) => (
  <div className={`flex items-center gap-1.5 ${passed ? 'text-green-500' : 'text-muted-foreground'}`}>
    {passed ? <Check className="h-3 w-3" /> : <X className="h-3 w-3" />}
    <span>{label}</span>
  </div>
);

export default PasswordStrengthIndicator;

// Export validation function for use in forms
export const validatePasswordStrength = (password: string, email?: string): string | null => {
  const lowerPassword = password.toLowerCase();
  
  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }
  
  if (COMMON_PASSWORDS.has(lowerPassword)) {
    return 'This password is too common. Please choose a stronger password';
  }
  
  if (isSequential(password)) {
    return 'Password contains sequential patterns. Please choose a stronger password';
  }
  
  if (isRepeating(password)) {
    return 'Password contains too many repeating characters';
  }
  
  if (containsEmail(password, email)) {
    return 'Password should not contain your email address';
  }
  
  // Check for at least 3 character types
  const hasUpper = /[A-Z]/.test(password);
  const hasLower = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
  const charTypes = [hasUpper, hasLower, hasNumber, hasSpecial].filter(Boolean).length;
  
  if (charTypes < 3) {
    return 'Password must contain at least 3 of: uppercase, lowercase, number, special character';
  }
  
  return null;
};
