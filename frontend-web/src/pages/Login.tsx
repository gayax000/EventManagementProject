import React, { useState } from 'react';
import { 
  Sparkles, 
  LogIn, 
  UserPlus, 
  X, 
  Mail, 
  Lock, 
  User, 
  Phone, 
  CheckCircle,
  ArrowRight,
  ShieldCheck,
  Building2,
  Calendar,
  Check
} from 'lucide-react';
import { authService } from '../services/authService';

interface LoginProps {
  onLoginSuccess: () => void;
  onNavigateRegister?: () => void;
}

// Single Full-Size Featured Showcase Photo for Event Management Business
const FEATURED_HERO_IMAGE = 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=2400&q=85';

export const Login: React.FC<LoginProps> = ({ onLoginSuccess }) => {
  // Modal state: null | 'login' | 'register'
  const [authModal, setAuthModal] = useState<'login' | 'register' | null>(null);

  // Login Form States
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  // Register Form States
  const [regFullName, setRegFullName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPhone, setRegPhone] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regRole, setRegRole] = useState<string>('Customer');
  const [regLoading, setRegLoading] = useState(false);

  // Handle Login Submit
  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Please fill in both email and password.');
      return;
    }

    setIsLoading(true);
    setError('');
    setSuccessMsg('');
    
    const success = await authService.login(email, password);
    setIsLoading(false);

    if (success) {
      setAuthModal(null);
      onLoginSuccess();
    } else {
      setError('Login failed. Please check your credentials or create an account.');
    }
  };

  // Handle Register Submit
  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!regFullName || !regEmail || !regPassword || !regPhone) {
      setError('Please fill in all registration fields.');
      return;
    }

    setRegLoading(true);
    setError('');
    setSuccessMsg('');
    
    const success = await authService.register(regFullName, regEmail, regPassword, regPhone, regRole);
    setRegLoading(false);

    if (success) {
      // Auto-login newly registered user
      const autoLogin = await authService.login(regEmail, regPassword);
      if (autoLogin) {
        setAuthModal(null);
        onLoginSuccess();
      } else {
        setAuthModal('login');
        setEmail(regEmail);
        setSuccessMsg('Account created successfully! Please sign in with your password.');
      }
    } else {
      setError('Registration failed. The email address may already be registered.');
    }
  };

  const openAuth = (type: 'login' | 'register') => {
    setError('');
    setSuccessMsg('');
    setAuthModal(type);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col selection:bg-sky-500 selection:text-white">
      
      {/* ========================================================================= */}
      {/* 1. TOP NAVBAR: Logo on Left Corner, Log In & Sign Up on Right Corner       */}
      {/* ========================================================================= */}
      <nav className="w-full bg-slate-950/80 backdrop-blur-md border-b border-slate-800/80 sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-18 flex items-center justify-between">
          
          {/* Left Corner: Logo */}
          <div className="flex items-center space-x-3 cursor-pointer" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
            <div className="p-2.5 bg-gradient-to-tr from-sky-500 to-indigo-600 rounded-xl shadow-lg shadow-sky-500/20">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="font-black text-xl tracking-tight text-white">EventCraft<span className="text-sky-400">.AI</span></span>
            </div>
          </div>

          {/* Right Corner: Modern Website Log In & Sign Up Options */}
          <div className="flex items-center space-x-3 sm:space-x-4">
            {/* Log In Button */}
            <button
              onClick={() => openAuth('login')}
              className="px-3.5 sm:px-4 py-2 text-xs sm:text-sm font-semibold text-slate-300 hover:text-white hover:bg-slate-900 rounded-xl transition duration-150"
            >
              Log In
            </button>

            {/* Sign Up Button */}
            <button
              onClick={() => openAuth('register')}
              className="px-4 sm:px-5 py-2 sm:py-2.5 text-xs sm:text-sm font-bold text-white bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 rounded-xl shadow-md shadow-sky-500/20 hover:shadow-sky-500/30 transition duration-150 flex items-center space-x-1.5"
            >
              <span>Sign Up</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

        </div>
      </nav>

      {/* ========================================================================= */}
      {/* 2. MIDDLE CONTENT: Welcome to EventCraft + Attractive Business Description */}
      {/* ========================================================================= */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16 flex flex-col items-center">
        
        {/* Centered Hero Heading & Description */}
        <div className="text-center max-w-3xl mx-auto space-y-4 sm:space-y-5">
          
          {/* Subtle Tag Pill */}
          <div className="inline-flex items-center space-x-2 px-3.5 py-1 rounded-full bg-slate-900 border border-slate-800 text-sky-400 text-xs font-semibold shadow-xs">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Smart Multi-Agent AI Event Management</span>
          </div>

          {/* Headline */}
          <h1 className="text-3xl sm:text-5xl lg:text-6xl font-black tracking-tight text-white leading-tight">
            Welcome to <span className="bg-gradient-to-r from-sky-400 via-indigo-300 to-pink-400 bg-clip-text text-transparent">EventCraft</span>
          </h1>

          {/* Customer Attracting Description */}
          <p className="text-sm sm:text-base md:text-lg text-slate-300 leading-relaxed font-normal">
            EventCraft is Sri Lanka's premier AI event management platform, transforming how extraordinary celebrations are born. We seamlessly pair certified 5-star hotel banquet halls with verified elite suppliers, gourmet catering, and real-time environmental weather contingency safeguards into one transparent proposal. Experience stress-free planning, transparent pricing, and unforgettable moments for your royal wedding, corporate gala, or milestone celebration.
          </p>

          {/* Quick CTA Buttons */}
          <div className="pt-2 flex flex-wrap items-center justify-center gap-3">
            <button
              onClick={() => openAuth('register')}
              className="px-6 py-3 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white rounded-xl text-xs sm:text-sm font-bold shadow-lg shadow-sky-500/20 transition flex items-center space-x-2"
            >
              <UserPlus className="w-4 h-4" />
              <span>Get Started — Sign Up</span>
            </button>
            <button
              onClick={() => openAuth('login')}
              className="px-6 py-3 bg-slate-900 hover:bg-slate-850 text-slate-200 border border-slate-800 hover:border-slate-700 rounded-xl text-xs sm:text-sm font-semibold transition flex items-center space-x-2"
            >
              <LogIn className="w-4 h-4 text-sky-400" />
              <span>Client Log In</span>
            </button>
          </div>

        </div>

        {/* ========================================================================= */}
        {/* 3. UNDERNEATH DESCRIPTION: ONLY ONE FULL-SIZE LUXURY PHOTO               */}
        {/* ========================================================================= */}
        <div className="w-full max-w-6xl mt-10 sm:mt-14">
          <div className="relative rounded-2xl sm:rounded-3xl overflow-hidden border border-slate-800 shadow-2xl bg-slate-900 aspect-[16/9] sm:aspect-[21/9]">
            <img 
              src={FEATURED_HERO_IMAGE} 
              alt="Luxury Grand Event Celebration" 
              className="w-full h-full object-cover object-center"
              loading="eager"
            />
            
            {/* Subtle Gradient Vignette Overlay */}
            <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-transparent to-black/20 pointer-events-none"></div>

            {/* Bottom Floating Badge Inside Photo */}
            <div className="absolute bottom-4 left-4 sm:bottom-6 sm:left-6 right-4 sm:right-auto flex flex-wrap items-center gap-2">
              <span className="inline-flex items-center space-x-1.5 px-3 py-1.5 rounded-xl bg-black/60 backdrop-blur-md text-white text-xs font-semibold border border-white/20 shadow-lg">
                <ShieldCheck className="w-4 h-4 text-sky-400" />
                <span>Certified 5-Star Luxury Venues & Weather Safeguarded Events</span>
              </span>
            </div>
          </div>
        </div>

      </main>

      {/* Footer */}
      <footer className="py-6 text-center text-xs text-slate-500 border-t border-slate-900 bg-slate-950">
        SE3090 Software Engineering Frameworks • EventCraft AI Management Platform
      </footer>

      {/* ========================================================================= */}
      {/* 4. MODERN AUTHENTICATION MODAL (Triggered by Log In / Sign Up)             */}
      {/* ========================================================================= */}
      {authModal && (
        <div 
          className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in duration-200"
          onClick={() => setAuthModal(null)}
        >
          <div 
            className="w-full max-w-md bg-slate-900 border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-2xl text-white relative"
            onClick={e => e.stopPropagation()}
          >
            {/* Close Button */}
            <button 
              onClick={() => setAuthModal(null)}
              className="absolute top-4 right-4 p-2 text-slate-400 hover:text-white rounded-full hover:bg-slate-800 transition"
            >
              <X className="w-5 h-5" />
            </button>

            {/* Modal Header Tabs */}
            <div className="flex border-b border-slate-800 pb-3 mb-5">
              <button
                type="button"
                onClick={() => { setAuthModal('login'); setError(''); setSuccessMsg(''); }}
                className={`flex-1 text-center py-2 text-xs font-bold rounded-xl transition ${
                  authModal === 'login'
                    ? 'bg-slate-800 text-sky-400 border border-slate-700'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Log In
              </button>
              <button
                type="button"
                onClick={() => { setAuthModal('register'); setError(''); setSuccessMsg(''); }}
                className={`flex-1 text-center py-2 text-xs font-bold rounded-xl transition ${
                  authModal === 'register'
                    ? 'bg-slate-800 text-indigo-400 border border-slate-700'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                Sign Up / Register
              </button>
            </div>

            {/* Error & Success Alerts */}
            {error && (
              <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-xs text-center">
                {error}
              </div>
            )}
            {successMsg && (
              <div className="mb-4 p-3 bg-emerald-500/20 border border-emerald-500/50 rounded-xl text-emerald-200 text-xs text-center flex items-center justify-center space-x-1.5">
                <CheckCircle className="w-4 h-4 text-emerald-400" />
                <span>{successMsg}</span>
              </div>
            )}

            {/* Form: Log In */}
            {authModal === 'login' ? (
              <form onSubmit={handleLoginSubmit} className="space-y-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Email Address</label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full pl-9 pr-4 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500"
                      placeholder="you@example.com"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Password</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="w-full pl-9 pr-4 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500"
                      placeholder="••••••••"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full py-3 px-4 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white rounded-xl text-xs font-bold shadow-lg shadow-sky-500/20 transition disabled:opacity-50 flex items-center justify-center space-x-2"
                >
                  <LogIn className="w-4 h-4" />
                  <span>{isLoading ? 'Signing in...' : 'Sign In to EventCraft'}</span>
                </button>

                <div className="text-center pt-2">
                  <p className="text-xs text-slate-400">
                    Don't have an account?{' '}
                    <button
                      type="button"
                      onClick={() => { setAuthModal('register'); setError(''); }}
                      className="text-sky-400 hover:text-sky-300 font-bold underline ml-1"
                    >
                      Sign Up
                    </button>
                  </p>
                </div>
              </form>
            ) : (
              /* Form: Register */
              <form onSubmit={handleRegisterSubmit} className="space-y-3">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Full Name</label>
                  <div className="relative">
                    <User className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
                    <input
                      type="text"
                      required
                      value={regFullName}
                      onChange={(e) => setRegFullName(e.target.value)}
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      placeholder="e.g. Kasun Perera"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Email Address</label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
                    <input
                      type="email"
                      required
                      value={regEmail}
                      onChange={(e) => setRegEmail(e.target.value)}
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      placeholder="kasun@example.com"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Phone Number</label>
                  <div className="relative">
                    <Phone className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
                    <input
                      type="tel"
                      required
                      value={regPhone}
                      onChange={(e) => setRegPhone(e.target.value)}
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      placeholder="+94 77 123 4567"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Password</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
                    <input
                      type="password"
                      required
                      value={regPassword}
                      onChange={(e) => setRegPassword(e.target.value)}
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      placeholder="••••••••"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Role</label>
                  <div className="grid grid-cols-2 gap-2">
                    <button
                      type="button"
                      onClick={() => setRegRole('Customer')}
                      className={`py-2 px-2 text-xs font-bold rounded-xl border text-center transition ${
                        regRole === 'Customer'
                          ? 'bg-sky-500/20 text-sky-300 border-sky-500/40'
                          : 'bg-slate-950 text-slate-400 border-slate-800 hover:border-slate-700'
                      }`}
                    >
                      🎉 Client
                    </button>
                    <button
                      type="button"
                      onClick={() => setRegRole('Vendor')}
                      className={`py-2 px-2 text-xs font-bold rounded-xl border text-center transition ${
                        regRole === 'Vendor'
                          ? 'bg-indigo-500/20 text-indigo-300 border-indigo-500/40'
                          : 'bg-slate-950 text-slate-400 border-slate-800 hover:border-slate-700'
                      }`}
                    >
                      🏢 Vendor
                    </button>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={regLoading}
                  className="w-full py-2.5 px-4 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white rounded-xl text-xs font-bold shadow-lg shadow-indigo-500/20 transition disabled:opacity-50 flex items-center justify-center space-x-2 mt-2"
                >
                  <UserPlus className="w-4 h-4" />
                  <span>{regLoading ? 'Creating Account...' : 'Create Account'}</span>
                </button>

                <div className="text-center pt-1">
                  <p className="text-xs text-slate-400">
                    Already have an account?{' '}
                    <button
                      type="button"
                      onClick={() => { setAuthModal('login'); setError(''); }}
                      className="text-indigo-400 hover:text-indigo-300 font-bold underline ml-1"
                    >
                      Log In
                    </button>
                  </p>
                </div>
              </form>
            )}

          </div>
        </div>
      )}

    </div>
  );
};
