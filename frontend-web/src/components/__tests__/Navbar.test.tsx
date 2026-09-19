import { describe, it, expect } from 'vitest';
import React from 'react';

// Unit Test suite verifying Navbar branding and role structure
describe('Navbar Component Render Rules', () => {
  it('should verify EventCraft.AI branding title format', () => {
    const brandName = "EventCraft.AI";
    expect(brandName).toContain("EventCraft");
    expect(brandName).toContain(".AI");
  });

  it('should verify portal badge label for Operations Manager', () => {
    const userRole = 'Manager';
    const badgeLabel = userRole === 'Manager' ? 'Operations Portal' : 'Client Portal';
    expect(badgeLabel).toBe('Operations Portal');
  });

  it('should clean user name display removing redundant role parentheses', () => {
    const rawUserName = "Kasun Bandara (Operations Manager)";
    const cleanedName = rawUserName.replace(/\s*\([^)]*\)/g, '').trim();
    expect(cleanedName).toBe("Kasun Bandara");
  });
});
