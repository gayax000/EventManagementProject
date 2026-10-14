import React, { useState } from 'react';
import { authService } from '../services/authService';

interface RegisterProps {
  onNavigateLogin: () => void;
}

export const Register: React.FC<RegisterProps> = ({ onNavigateLogin }) => {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [role, setRole] = useState<'Vendor' | 'Manager'>('Vendor');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanName = fullName.trim();
    const cleanEmail = email.trim();
    const cleanPhone = phone.trim().replace(/\s+/g, '');
    const cleanPassword = password.trim();

    if (!cleanName || !cleanEmail || !cleanPassword || !cleanPhone || !confirmPassword.trim()) {
      setError('Please fill in all registration fields.');
      return;
    }

    if (cleanName.length < 2) {
      setError('Full Name must be at least 2 characters long.');
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(cleanEmail)) {
      setError('Please enter a valid email address (e.g. vendor@example.com).');
      return;
    }

    const phoneRegex = /^(?:\+94|0)[0-9]{9}$/;
    if (!phoneRegex.test(cleanPhone)) {
      setError('Please enter a valid 10-digit Sri Lankan phone number (e.g. 0771234567 or +94771234567).');
      return;
    }

    if (cleanPassword.length < 6) {
      setError('Password must be at least 6 characters long.');
      return;
    }

    if (cleanPassword !== confirmPassword.trim()) {
      setError('Passwords do not match. Please re-enter your password.');
      return;
    }

    setIsLoading(true);
    setError('');
    
    // Public registrations are strictly Vendors / Suppliers
    const success = await authService.register(cleanName, cleanEmail, cleanPassword, cleanPhone, 'Vendor');
    
    setIsLoading(false);

    if (success) {
      alert(`Vendor account created successfully! Please sign in with your email and password.`);
      onNavigateLogin();
    } else {
      setError('Registration failed. The email address may already be in use.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col justify-center items-center px-4 py-12">
      <div className="w-full max-w-md bg-slate-800 p-8 rounded-2xl shadow-2xl border border-slate-700">
        <div className="text-center mb-8">
          <span className="text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-indigo-950 text-indigo-300 border border-indigo-800 inline-block mb-3">
            Supplier Onboarding
          </span>
          <h2 className="text-3xl font-bold text-white">Vendor Registration</h2>
          <p className="text-slate-400 mt-2 text-sm">Register your supplier account to onboard your catering, audio/visual or event services.</p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-lg text-red-200 text-sm text-center">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Full Name / Contact Person</label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-indigo-500 text-white"
              placeholder="e.g. Yohan Fernando"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Business Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-indigo-500 text-white"
              placeholder="vendor@example.com"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Phone Number</label>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-indigo-500 text-white"
              placeholder="+94 77 123 4567"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-indigo-500 text-white"
              placeholder="•••••••• (Min 6 characters)"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Confirm Password</label>
            <input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-indigo-500 text-white"
              placeholder="•••••••• (Re-enter password)"
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 px-4 mt-4 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50 shadow-md"
          >
            {isLoading ? 'Creating Vendor Account...' : 'Register as Vendor'}
          </button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-slate-400 text-sm">
            Already have an account?{' '}
            <button onClick={onNavigateLogin} className="text-cyan-400 hover:text-cyan-300 font-medium">
              Log in
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};
