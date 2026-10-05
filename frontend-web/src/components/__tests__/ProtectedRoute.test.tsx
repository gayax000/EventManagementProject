import React from 'react';
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ProtectedRoute } from '../ProtectedRoute';

describe('ProtectedRoute Component', () => {
  it('blocks unauthenticated access and displays Authentication Required', () => {
    render(
      <ProtectedRoute
        isAuthenticated={false}
        userRole="Customer"
        allowedRoles={['Manager']}
      >
        <div>Secret Manager Content</div>
      </ProtectedRoute>
    );

    expect(screen.getByText('Authentication Required')).toBeInTheDocument();
    expect(screen.getByText(/You must be logged into EventCraft.AI/i)).toBeInTheDocument();
    expect(screen.queryByText('Secret Manager Content')).not.toBeInTheDocument();
  });

  it('blocks Customer from accessing Manager-restricted modules with Access Denied', () => {
    const handleFallback = vi.fn();

    render(
      <ProtectedRoute
        isAuthenticated={true}
        userRole="Customer"
        allowedRoles={['Manager']}
        onFallbackTab={handleFallback}
      >
        <div>Operations Dashboard</div>
      </ProtectedRoute>
    );

    expect(screen.getByText('Access Denied')).toBeInTheDocument();
    expect(screen.getByText(/You do not have administrative permissions/i)).toBeInTheDocument();
    expect(screen.queryByText('Operations Dashboard')).not.toBeInTheDocument();

    const fallbackBtn = screen.getByRole('button', { name: /Return to Safe Dashboard/i });
    fireEvent.click(fallbackBtn);
    expect(handleFallback).toHaveBeenCalledWith('dashboard');
  });

  it('allows Manager role to view Manager-allowed modules', () => {
    render(
      <ProtectedRoute
        isAuthenticated={true}
        userRole="Manager"
        allowedRoles={['Manager', 'Vendor']}
      >
        <div data-testid="manager-content">Authorized Manager Panel</div>
      </ProtectedRoute>
    );

    expect(screen.getByTestId('manager-content')).toBeInTheDocument();
    expect(screen.getByText('Authorized Manager Panel')).toBeInTheDocument();
    expect(screen.queryByText('Access Denied')).not.toBeInTheDocument();
  });

  it('allows Vendor role to view Vendor-allowed modules', () => {
    render(
      <ProtectedRoute
        isAuthenticated={true}
        userRole="Vendor"
        allowedRoles={['Vendor']}
      >
        <div data-testid="vendor-content">Vendor Work Orders</div>
      </ProtectedRoute>
    );

    expect(screen.getByTestId('vendor-content')).toBeInTheDocument();
    expect(screen.queryByText('Access Denied')).not.toBeInTheDocument();
  });
});
