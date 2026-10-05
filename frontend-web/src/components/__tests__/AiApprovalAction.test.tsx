import React, { useState } from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { eventService } from '../../services/api';

// Realistic AI Proposal Approval Action Component modeled after Dashboard approval UI
interface AiApprovalActionProps {
  eventId: string;
  userRole: 'Manager' | 'Customer' | 'Vendor';
  currentStatus: string;
  initialCost: number;
  onApprovalSuccess?: (newStatus: string) => void;
}

const AiApprovalAction: React.FC<AiApprovalActionProps> = ({
  eventId,
  userRole,
  currentStatus,
  initialCost,
  onApprovalSuccess,
}) => {
  const [status, setStatus] = useState(currentStatus);
  const [isApproving, setIsApproving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (userRole !== 'Manager') {
    return (
      <div data-testid="restricted-notice">
        Only Operations Managers can approve AI event proposals.
      </div>
    );
  }

  const handleApprove = async () => {
    setIsApproving(true);
    setError(null);
    try {
      await eventService.approveProposal(eventId, 0, initialCost, 'ApprovedByManager');
      setStatus('ApprovedByManager');
      onApprovalSuccess?.('ApprovedByManager');
    } catch {
      setError('Failed to approve proposal on backend.');
    } finally {
      setIsApproving(false);
    }
  };

  return (
    <div data-testid="approval-container">
      <div data-testid="proposal-status">Status: {status}</div>
      {error && <div data-testid="approval-error" role="alert">{error}</div>}
      <button
        type="button"
        disabled={isApproving || status === 'ApprovedByManager'}
        onClick={handleApprove}
        className="btn-approve"
      >
        {isApproving ? 'Approving...' : status === 'ApprovedByManager' ? 'Proposal Approved' : 'Approve Proposal'}
      </button>
    </div>
  );
};

vi.mock('../../services/api', () => ({
  eventService: {
    approveProposal: vi.fn(),
  },
}));

describe('AI Workflow Approval UI Component', () => {
  const sampleEventId = 'ev-test-123';

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders approval action for Manager role with current status', () => {
    render(
      <AiApprovalAction
        eventId={sampleEventId}
        userRole="Manager"
        currentStatus="PendingManagerApproval"
        initialCost={1500000}
      />
    );

    expect(screen.getByTestId('approval-container')).toBeInTheDocument();
    expect(screen.getByTestId('proposal-status')).toHaveTextContent('PendingManagerApproval');
    expect(screen.getByRole('button', { name: /Approve Proposal/i })).toBeInTheDocument();
  });

  it('blocks non-manager from triggering approval action', () => {
    render(
      <AiApprovalAction
        eventId={sampleEventId}
        userRole="Customer"
        currentStatus="PendingManagerApproval"
        initialCost={1500000}
      />
    );

    expect(screen.getByTestId('restricted-notice')).toHaveTextContent(/Only Operations Managers can approve/i);
    expect(screen.queryByRole('button', { name: /Approve Proposal/i })).not.toBeInTheDocument();
  });

  it('clicking Approve calls correct API and changes button state to loading', async () => {
    let resolveApprove: () => void = () => {};
    vi.mocked(eventService.approveProposal).mockImplementationOnce(() => {
      return new Promise<any>((resolve) => {
        resolveApprove = () => resolve({ message: 'Approved' });
      });
    });

    render(
      <AiApprovalAction
        eventId={sampleEventId}
        userRole="Manager"
        currentStatus="PendingManagerApproval"
        initialCost={1500000}
      />
    );

    const approveBtn = screen.getByRole('button', { name: /Approve Proposal/i });
    fireEvent.click(approveBtn);

    // Verify loading state
    expect(screen.getByRole('button', { name: /Approving.../i })).toBeDisabled();

    // Complete approval
    resolveApprove();

    await waitFor(() => {
      expect(eventService.approveProposal).toHaveBeenCalledWith(sampleEventId, 0, 1500000, 'ApprovedByManager');
      expect(screen.getByTestId('proposal-status')).toHaveTextContent('ApprovedByManager');
      expect(screen.getByRole('button', { name: /Proposal Approved/i })).toBeDisabled();
    });
  });

  it('shows error state when API request fails', async () => {
    vi.mocked(eventService.approveProposal).mockRejectedValueOnce(new Error('Network error'));

    render(
      <AiApprovalAction
        eventId={sampleEventId}
        userRole="Manager"
        currentStatus="PendingManagerApproval"
        initialCost={1500000}
      />
    );

    const approveBtn = screen.getByRole('button', { name: /Approve Proposal/i });
    fireEvent.click(approveBtn);

    await waitFor(() => {
      expect(screen.getByTestId('approval-error')).toHaveTextContent('Failed to approve proposal on backend.');
      expect(screen.getByTestId('proposal-status')).toHaveTextContent('PendingManagerApproval');
      expect(screen.getByRole('button', { name: /Approve Proposal/i })).not.toBeDisabled();
    });
  });
});
