import React, { useState } from 'react';
import { authService } from '../services/authService';

interface LoginProps {
  onLoginSuccess: () => void;
  onNavigateRegister: () => void;
}

export const Login: React.FC<LoginProps> = ({ onLoginSuccess, onNavigateRegister }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Please fill in all fields');
      return;
    }

    setIsLoading(true);
    setError('');
    
    const success = await authService.login(email, password);
    
    setIsLoading(false);

    if (success) {
      onLoginSuccess();
    } else {
      setError('Login failed. Please check your credentials.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col justify-center items-center px-4">
      <div className="w-full max-w-md bg-slate-800 p-8 rounded-2xl shadow-2xl border border-slate-700">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-cyan-900/30 text-cyan-400 mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
          <h2 className="text-3xl font-bold text-white">EventCraft AI</h2>
          <p className="text-slate-400 mt-2">Manager Portal Login</p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-lg text-red-200 text-sm text-center">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">Email Address</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-transparent text-white"
              placeholder="manager@eventcraft.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-transparent text-white"
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 px-4 bg-cyan-600 hover:bg-cyan-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
          >
            {isLoading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>

        {/* Quick Demo Access Buttons */}
        <div className="mt-6 pt-6 border-t border-slate-700">
          <p className="text-xs text-slate-400 text-center uppercase tracking-wider font-semibold mb-3">
            Quick Persona Login (Strict RBAC)
          </p>
          <div className="grid grid-cols-2 gap-3">
            <button
              type="button"
              onClick={() => {
                localStorage.setItem('jwt_token', 'token-mgr');
                localStorage.setItem('user_role', 'Manager');
                localStorage.setItem('user_name', 'Kasun Bandara');
                onLoginSuccess();
              }}
              className="p-3 bg-slate-900/90 hover:bg-slate-900 border border-cyan-500/40 hover:border-cyan-400 rounded-xl text-left transition"
            >
              <span className="text-xs font-bold text-cyan-400 block">Operations Manager</span>
              <span className="text-[11px] text-slate-400 block mt-0.5">Full Admin Dashboard</span>
            </button>
            <button
              type="button"
              onClick={() => {
                localStorage.setItem('jwt_token', 'token-vnd');
                localStorage.setItem('user_role', 'Vendor');
                localStorage.setItem('user_name', 'Royal Colombo Catering');
                onLoginSuccess();
              }}
              className="p-3 bg-slate-900/90 hover:bg-slate-900 border border-indigo-500/40 hover:border-indigo-400 rounded-xl text-left transition"
            >
              <span className="text-xs font-bold text-indigo-400 block">Vendor / Supplier</span>
              <span className="text-[11px] text-slate-400 block mt-0.5">Onboarding Portal</span>
            </button>
          </div>
        </div>

        <div className="mt-6 text-center">
          <p className="text-slate-400 text-sm">
            Don't have an account?{' '}
            <button onClick={onNavigateRegister} className="text-cyan-400 hover:text-cyan-300 font-medium">
              Register as Vendor
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};
