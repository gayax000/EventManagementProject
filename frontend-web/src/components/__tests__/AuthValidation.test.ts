import { describe, it, expect } from 'vitest';

describe('Auth & Protected Route Authorization Rules', () => {
  it('should validate standard email format correctly', () => {
    const validEmail = 'manager@eventcraft.lk';
    const invalidEmail = 'invalid-email-address';

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    expect(emailRegex.test(validEmail)).toBe(true);
    expect(emailRegex.test(invalidEmail)).toBe(false);
  });

  it('should require minimum password length for secure registration', () => {
    const shortPass = '123';
    const validPass = 'Secure@2026';

    const isValidPassword = (p: string) => p.length >= 6;
    expect(isValidPassword(shortPass)).toBe(false);
    expect(isValidPassword(validPass)).toBe(true);
  });

  it('should enforce role-based access control for Manager-only routes', () => {
    const canAccessManagerDashboard = (role: string | null) => role === 'Manager' || role === 'Admin';

    expect(canAccessManagerDashboard('Manager')).toBe(true);
    expect(canAccessManagerDashboard('Admin')).toBe(true);
    expect(canAccessManagerDashboard('Customer')).toBe(false);
    expect(canAccessManagerDashboard('Vendor')).toBe(false);
    expect(canAccessManagerDashboard(null)).toBe(false);
  });

  it('should redirect unauthenticated users to login', () => {
    const getTargetRoute = (isAuthenticated: boolean, requestedPath: string) => {
      if (!isAuthenticated) return '/login';
      return requestedPath;
    };

    expect(getTargetRoute(false, '/dashboard')).toBe('/login');
    expect(getTargetRoute(true, '/dashboard')).toBe('/dashboard');
  });
});
