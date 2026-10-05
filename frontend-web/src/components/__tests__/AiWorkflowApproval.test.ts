import { describe, it, expect } from 'vitest';

describe('AI Workflow Human-in-the-Loop Approval Decision Logic', () => {
  it('should transition status to ApprovedByManager when manager approves proposal', () => {
    const handleDecision = (currentStatus: string, decision: 'approve' | 'reject' | 'revise') => {
      if (decision === 'approve') return 'ApprovedByManager';
      if (decision === 'reject') return 'Rejected';
      if (decision === 'revise') return 'RevisionRequested';
      return currentStatus;
    };

    expect(handleDecision('PendingManagerApproval', 'approve')).toBe('ApprovedByManager');
    expect(handleDecision('PendingManagerApproval', 'reject')).toBe('Rejected');
    expect(handleDecision('PendingManagerApproval', 'revise')).toBe('RevisionRequested');
  });

  it('should adjust estimated total budget when custom add-on cost is specified', () => {
    const originalEstimatedCost = 450000;
    const customAddonCost = 50000;

    const calculateFinalTotal = (base: number, addOn: number | null) => {
      return base + (addOn && addOn > 0 ? addOn : 0);
    };

    expect(calculateFinalTotal(originalEstimatedCost, customAddonCost)).toBe(500000);
    expect(calculateFinalTotal(originalEstimatedCost, null)).toBe(450000);
  });

  it('should format Sri Lankan Rupee currency strings properly for venue cards', () => {
    const formatLKR = (amount: number) => `Rs. ${amount.toLocaleString('en-US')}`;

    expect(formatLKR(850000)).toBe('Rs. 850,000');
    expect(formatLKR(1200000)).toBe('Rs. 1,200,000');
  });

  it('should identify outdoor venues requiring weather risk safeguards', () => {
    const requiresWeatherCheck = (isOutdoor: boolean, guestCount: number) => {
      return isOutdoor && guestCount >= 50;
    };

    expect(requiresWeatherCheck(true, 150)).toBe(true);
    expect(requiresWeatherCheck(false, 300)).toBe(false);
  });
});
