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
  const [role, setRole] = useState<'Vendor' | 'Manager'>('Vendor');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!fullName || !email || !password || !phone) {
      setError('Please fill in all fields');
      return;
    }

    setIsLoading(true);
    setError('');
    
    const success = await authService.register(fullName, email, password, phone, role);
    
    setIsLoading(false);

    if (success) {
      alert(`Registration successful as ${role}! Please sign in.`);
      onNavigateLogin();
    } else {
      setError('Registration failed. Please try again.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col justify-center items-center px-4 py-12">
      <div className="w-full max-w-md bg-slate-800 p-8 rounded-2xl shadow-2xl border border-slate-700">
        <div className="text-center mb-8">
          <h2 className="text-3xl font-bold text-white">Create Account</h2>
          <p className="text-slate-400 mt-2">Join EventCraft AI</p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-lg text-red-200 text-sm text-center">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Full Name</label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-cyan-500 text-white"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-cyan-500 text-white"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Phone Number</label>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-cyan-500 text-white"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-1">Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:ring-2 focus:ring-cyan-500 text-white"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">Account Role</label>
            <div className="grid grid-cols-2 gap-3">
              <label className={`flex items-center space-x-2 p-3 rounded-xl border cursor-pointer transition ${
                role === 'Vendor' 
                  ? 'bg-indigo-950/60 border-indigo-500 text-white' 
                  : 'bg-slate-900/60 border-slate-700 text-slate-400'
              }`}>
                <input 
                  type="radio" 
                  name="role" 
                  value="Vendor" 
                  checked={role === 'Vendor'} 
                  onChange={() => setRole('Vendor')} 
                  className="hidden"
                />
                <span className="text-xs font-semibold">Vendor / Supplier</span>
              </label>

              <label className={`flex items-center space-x-2 p-3 rounded-xl border cursor-pointer transition ${
                role === 'Manager' 
                  ? 'bg-cyan-950/60 border-cyan-500 text-white' 
                  : 'bg-slate-900/60 border-slate-700 text-slate-400'
              }`}>
                <input 
                  type="radio" 
                  name="role" 
                  value="Manager" 
                  checked={role === 'Manager'} 
                  onChange={() => setRole('Manager')} 
                  className="hidden"
                />
                <span className="text-xs font-semibold">Operations Manager</span>
              </label>
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-3 px-4 mt-4 bg-cyan-600 hover:bg-cyan-500 text-white rounded-xl font-medium transition-colors disabled:opacity-50"
          >
            {isLoading ? 'Creating...' : 'Sign Up'}
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
