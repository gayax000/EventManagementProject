import React from 'react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { Login } from '../Login';
import { authService } from '../../services/authService';

vi.mock('../../services/authService', () => ({
  authService: {
    login: vi.fn(),
    register: vi.fn(),
    getUserRole: vi.fn(),
    logout: vi.fn(),
  },
}));

vi.mock('../../assets/login-bg.jpg', () => ({
  default: 'mock-login-bg.jpg',
}));

describe('Login Component', () => {
  const mockOnLoginSuccess = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders landing page with Log In and Sign Up buttons', () => {
    render(<Login onLoginSuccess={mockOnLoginSuccess} />);
    expect(screen.getAllByText(/EventCraft/i).length).toBeGreaterThan(0);
    expect(screen.getByRole('button', { name: /Log In/i })).toBeInTheDocument();
  });

  it('shows validation error when submitting empty credentials', async () => {
    render(<Login onLoginSuccess={mockOnLoginSuccess} />);
    
    // Open the login modal
    fireEvent.click(screen.getByRole('button', { name: /Log In/i }));
    
    // Submit the form directly
    const form = screen.getByRole('button', { name: /Sign In/i }).closest('form')!;
    fireEvent.submit(form);

    await waitFor(() => {
      expect(screen.getByText(/Please fill in both email and password/i)).toBeInTheDocument();
    });
    expect(authService.login).not.toHaveBeenCalled();
  });

  it('shows error UI when credentials are invalid', async () => {
    vi.mocked(authService.login).mockResolvedValueOnce(false);

    render(<Login onLoginSuccess={mockOnLoginSuccess} />);
    
    // Open login modal
    fireEvent.click(screen.getByRole('button', { name: /Log In/i }));

    // Fill credentials
    const emailInput = screen.getByPlaceholderText('vendor@eventcraft.com');
    const passwordInput = screen.getByPlaceholderText('••••••••');
    fireEvent.change(emailInput, { target: { value: 'bad@eventcraft.com' } });
    fireEvent.change(passwordInput, { target: { value: 'wrongpassword' } });

    // Submit
    const form = screen.getByRole('button', { name: /Sign In/i }).closest('form')!;
    fireEvent.submit(form);

    await waitFor(() => {
      expect(screen.getByText(/Login failed. Please check your credentials/i)).toBeInTheDocument();
    });
    expect(mockOnLoginSuccess).not.toHaveBeenCalled();
  });

  it('disables submit button and shows loading state while request is pending', async () => {
    let resolveLogin: (value: boolean) => void = () => {};
    vi.mocked(authService.login).mockImplementationOnce(() => {
      return new Promise((resolve) => {
        resolveLogin = resolve;
      });
    });

    render(<Login onLoginSuccess={mockOnLoginSuccess} />);
    fireEvent.click(screen.getByRole('button', { name: /Log In/i }));

    const emailInput = screen.getByPlaceholderText('vendor@eventcraft.com');
    const passwordInput = screen.getByPlaceholderText('••••••••');
    fireEvent.change(emailInput, { target: { value: 'manager@eventcraft.lk' } });
    fireEvent.change(passwordInput, { target: { value: 'Manager@2026' } });

    const submitBtn = screen.getByRole('button', { name: /Sign In/i });
    const form = submitBtn.closest('form')!;
    fireEvent.submit(form);

    expect(screen.getByText(/Signing in.../i)).toBeInTheDocument();
    expect(submitBtn).toBeDisabled();

    // Resolve login
    resolveLogin(true);
    vi.mocked(authService.getUserRole).mockReturnValue('Manager');

    await waitFor(() => {
      expect(mockOnLoginSuccess).toHaveBeenCalledTimes(1);
    });
  });

  it('calls authService.login and invokes onLoginSuccess for authorized Manager', async () => {
    vi.mocked(authService.login).mockResolvedValueOnce(true);
    vi.mocked(authService.getUserRole).mockReturnValue('Manager');

    render(<Login onLoginSuccess={mockOnLoginSuccess} />);
    fireEvent.click(screen.getByRole('button', { name: /Log In/i }));

    const emailInput = screen.getByPlaceholderText('vendor@eventcraft.com');
    const passwordInput = screen.getByPlaceholderText('••••••••');
    fireEvent.change(emailInput, { target: { value: 'manager@eventcraft.lk' } });
    fireEvent.change(passwordInput, { target: { value: 'Manager@2026' } });

    const form = screen.getByRole('button', { name: /Sign In/i }).closest('form')!;
    fireEvent.submit(form);

    await waitFor(() => {
      expect(authService.login).toHaveBeenCalledWith('manager@eventcraft.lk', 'Manager@2026');
      expect(mockOnLoginSuccess).toHaveBeenCalledTimes(1);
    });
  });
});
