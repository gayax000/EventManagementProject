import React, { useState } from 'react';
import { 
  Sparkles, 
  LogIn, 
  UserPlus, 
  Layers, 
  ShieldCheck, 
  CheckCircle, 
  Calendar, 
  Users, 
  MapPin, 
  Eye, 
  X, 
  Mail, 
  Lock, 
  User, 
  Phone, 
  Check, 
  CloudRain, 
  Sun, 
  Music, 
  Camera, 
  Building2, 
  Star, 
  ArrowRight,
  Image as ImageIcon
} from 'lucide-react';
import { authService } from '../services/authService';

interface LoginProps {
  onLoginSuccess: () => void;
  onNavigateRegister?: () => void;
}

// Curated Showcase Photos of Luxury Celebrations
const CURATED_SHOWCASE_PHOTOS = [
  {
    id: 'ballroom',
    title: 'Royal Grand Ballroom & Crystal Chandeliers',
    category: 'Grand Ballrooms & 5-Star Venues',
    icon: '🏛️',
    description: 'Opulent hotel banquet halls with crystal chandeliers, round banquet seating, and climate-controlled indoor elegance.',
    imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1200&q=80',
    tag: '5-Star Luxury'
  },
  {
    id: 'outdoor',
    title: 'Sunset Garden & Coastal Reception',
    category: 'Scenic Outdoor Lawns',
    icon: '🌴',
    description: 'Enchanting open-air celebrations beneath fairy-light canopies, backed by autonomous environmental weather safeguards.',
    imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
    tag: 'Weather Protected'
  },
  {
    id: 'sound',
    title: 'Concert Line-Array Sound & Beam Lighting',
    category: 'Sound & Intelligent Lighting',
    icon: '🔊',
    description: 'Acoustic line-array audio rigs, digital mixing consoles, and programmable moving-head trusses for electrifying atmospheres.',
    imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1200&q=80',
    tag: 'Tour-Grade Rig'
  },
  {
    id: 'decor',
    title: 'Fresh Floral Stage Cascades & Ceiling Drapes',
    category: 'Floral Art & Stage Design',
    icon: '🌸',
    description: 'Bespoke thematic floral backdrops, entrance tunnel archways, geometric frames, and luxurious ambient tablescapes.',
    imageUrl: 'https://images.unsplash.com/photo-1520854221256-17451cc331bf?auto=format&fit=crop&w=1200&q=80',
    tag: 'Master Florists'
  },
  {
    id: 'cake',
    title: 'Artisanal Fondant Celebration Cakes',
    category: 'Celebration Cakes & Dessert Art',
    icon: '🎂',
    description: 'Handcrafted 3-to-5 tier fondant showstoppers decorated with handcrafted edible sugar blooms and custom branding.',
    imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?auto=format&fit=crop&w=1200&q=80',
    tag: 'Bespoke Confectionery'
  },
  {
    id: 'photo',
    title: 'Cinematic 4K Media & Aerial Drone Coverage',
    category: 'Photography & Cinematography',
    icon: '📸',
    description: 'Award-winning photojournalism, cinematic 4K video reels, drone perspectives, and handcrafted leather-bound albums.',
    imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=1200&q=80',
    tag: '4K Deliverables'
  }
];

export const Login: React.FC<LoginProps> = ({ onLoginSuccess, onNavigateRegister }) => {
  // Tab switch: 'login' | 'register'
  const [activeAuthTab, setActiveAuthTab] = useState<'login' | 'register'>('login');

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

  // Photo Lightbox Zoom
  const [previewImage, setPreviewImage] = useState<string | null>(null);

  // Handle Login
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
      onLoginSuccess();
    } else {
      setError('Login failed. Please check your credentials or register a new account.');
    }
  };

  // Handle Register
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
        onLoginSuccess();
      } else {
        setActiveAuthTab('login');
        setEmail(regEmail);
        setSuccessMsg('Account created successfully! Please sign in with your password.');
      }
    } else {
      setError('Registration failed. The email address may already be registered.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col selection:bg-sky-500 selection:text-white">
      
      {/* ========================================================================= */}
      {/* 1. TOP AUTHENTICATION & ONBOARDING TAB / BAR (Fully Mobile-Responsive)     */}
      {/* ========================================================================= */}
      <header className="sticky top-0 z-40 bg-slate-900/95 backdrop-blur-md border-b border-slate-800 shadow-xl">
        <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8 py-2.5 sm:py-3 sm:h-18 flex flex-col sm:flex-row items-center justify-between gap-2.5 sm:gap-4">
          
          {/* Left: Brand Identity */}
          <div className="flex items-center space-x-2.5 sm:space-x-3 w-full sm:w-auto justify-between sm:justify-start">
            <div className="flex items-center space-x-2 sm:space-x-3">
              <div className="p-2 sm:p-2.5 bg-gradient-to-tr from-sky-500 to-indigo-600 rounded-xl shadow-lg shadow-sky-500/20">
                <Sparkles className="w-4 h-4 sm:w-5 sm:h-5 text-white" />
              </div>
              <div>
                <span className="font-black text-lg sm:text-xl tracking-tight text-white">EventCraft<span className="text-sky-400">.AI</span></span>
                <span className="ml-2 text-[10px] sm:text-[11px] font-semibold px-2 py-0.5 rounded-full bg-slate-800 text-sky-300 border border-slate-700 hidden xs:inline-block">
                  Client & Supplier
                </span>
              </div>
            </div>
            <span className="text-[10px] text-slate-400 sm:hidden">
              AI Event Platform
            </span>
          </div>

          {/* Right: Auth Tabs (Log In & Don't have an acc? Sign Up / Register) */}
          <div className="flex items-center space-x-1.5 sm:space-x-2 bg-slate-950/80 p-1 sm:p-1.5 rounded-2xl border border-slate-800 w-full sm:w-auto justify-center">
            {/* Log In Tab */}
            <button
              onClick={() => { setActiveAuthTab('login'); setError(''); setSuccessMsg(''); }}
              className={`flex items-center justify-center space-x-1.5 px-3 sm:px-4 py-1.5 sm:py-2 rounded-xl text-xs font-bold transition-all duration-200 flex-1 sm:flex-initial ${
                activeAuthTab === 'login'
                  ? 'bg-gradient-to-r from-sky-500 to-indigo-600 text-white shadow-md shadow-sky-500/20'
                  : 'text-slate-400 hover:text-white hover:bg-slate-850'
              }`}
            >
              <LogIn className="w-3.5 h-3.5" />
              <span>Log In</span>
            </button>

            {/* Don't have an acc? Sign Up / Register Tab */}
            <button
              onClick={() => { setActiveAuthTab('register'); setError(''); setSuccessMsg(''); }}
              className={`flex items-center justify-center space-x-1.5 px-3 sm:px-4 py-1.5 sm:py-2 rounded-xl text-xs font-bold transition-all duration-200 flex-1 sm:flex-initial ${
                activeAuthTab === 'register'
                  ? 'bg-gradient-to-r from-sky-500 to-indigo-600 text-white shadow-md shadow-indigo-500/20'
                  : 'text-slate-400 hover:text-white hover:bg-slate-850'
              }`}
            >
              <UserPlus className="w-3.5 h-3.5 text-sky-400" />
              <span className="hidden sm:inline">Don't have an account? </span>
              <span>Sign Up / Register</span>
            </button>
          </div>

        </div>
      </header>

      {/* Main Body */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-3 sm:px-6 lg:px-8 py-5 sm:py-8 space-y-6 sm:space-y-10">

        {/* ========================================================================= */}
        {/* 2. WELCOME TO EVENTCRAFT — HERO & SYSTEM WORKFLOW EXPLANATION            */}
        {/* ========================================================================= */}
        <div className="relative overflow-hidden rounded-2xl sm:rounded-3xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 border border-slate-800 p-5 sm:p-8 md:p-12 shadow-2xl">
          {/* Radiant Glow Accents */}
          <div className="absolute top-0 right-0 -mt-20 -mr-20 w-72 sm:w-96 h-72 sm:h-96 rounded-full bg-sky-500/15 blur-3xl pointer-events-none"></div>
          <div className="absolute bottom-0 left-0 -mb-20 -ml-20 w-72 sm:w-96 h-72 sm:h-96 rounded-full bg-indigo-500/15 blur-3xl pointer-events-none"></div>

          <div className="relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-6 sm:gap-10 items-center">
            
            {/* Left Side: Welcome Description & Value Proposition (7 cols) */}
            <div className="lg:col-span-7 space-y-3.5 sm:space-y-5 text-left">
              
              <div className="inline-flex items-center space-x-2 px-2.5 sm:px-3 py-1 rounded-full bg-indigo-500/20 border border-indigo-500/30 text-indigo-300 text-[11px] sm:text-xs font-semibold">
                <Sparkles className="w-3.5 h-3.5 text-sky-400 flex-shrink-0" />
                <span>Premier AI-Powered Event Platform</span>
              </div>

              <h1 className="text-2xl sm:text-4xl lg:text-5xl font-black tracking-tight text-white leading-tight">
                Welcome to <span className="bg-gradient-to-r from-sky-400 via-indigo-300 to-pink-400 bg-clip-text text-transparent">EventCraft</span>
              </h1>

              <p className="text-xs sm:text-sm md:text-base text-slate-300 leading-relaxed font-normal">
                EventCraft is Sri Lanka's leading multi-agent AI event management system. We take the hassle, uncertainty, and endless back-and-forth out of event planning. By pairing certified 5-star hotel banquet halls with verified suppliers and real-time environmental weather contingency safeguards, EventCraft transforms your dream wedding, corporate gala, or milestone celebration into a flawlessly coordinated reality.
              </p>

              {/* Highlights Metric Counter (Responsive 2x2 on mobile, 4-col on desktop) */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 sm:gap-3 pt-2">
                <div className="bg-slate-800/60 backdrop-blur-sm border border-slate-700/60 rounded-xl sm:rounded-2xl p-3 sm:p-3.5">
                  <div className="text-xl sm:text-2xl font-black text-sky-400">100+</div>
                  <div className="text-[10px] sm:text-[11px] text-slate-400 font-medium mt-0.5">Certified 5-Star Venues</div>
                </div>
                <div className="bg-slate-800/60 backdrop-blur-sm border border-slate-700/60 rounded-2xl p-3 sm:p-3.5">
                  <div className="text-xl sm:text-2xl font-black text-indigo-400">250+</div>
                  <div className="text-[10px] sm:text-[11px] text-slate-400 font-medium mt-0.5">Verified Elite Vendors</div>
                </div>
                <div className="bg-slate-800/60 backdrop-blur-sm border border-slate-700/60 rounded-2xl p-3 sm:p-3.5">
                  <div className="text-xl sm:text-2xl font-black text-emerald-400">100%</div>
                  <div className="text-[10px] sm:text-[11px] text-slate-400 font-medium mt-0.5">Weather Shield</div>
                </div>
                <div className="bg-slate-800/60 backdrop-blur-sm border border-slate-700/60 rounded-2xl p-3 sm:p-3.5">
                  <div className="text-xl sm:text-2xl font-black text-amber-400">4.9 / 5.0</div>
                  <div className="text-[10px] sm:text-[11px] text-slate-400 font-medium mt-0.5">Client Rating</div>
                </div>
              </div>

            </div>

            {/* Right Side: Authentication Box (5 cols) */}
            <div className="lg:col-span-5 w-full">
              <div className="bg-slate-900/95 backdrop-blur-xl border border-slate-700/80 rounded-2xl sm:rounded-3xl p-5 sm:p-8 shadow-2xl">
                
                {/* Form Header Tabs */}
                <div className="flex border-b border-slate-800 pb-3 mb-4 sm:mb-5">
                  <button
                    type="button"
                    onClick={() => { setActiveAuthTab('login'); setError(''); setSuccessMsg(''); }}
                    className={`flex-1 text-center py-2 text-xs font-bold rounded-xl transition ${
                      activeAuthTab === 'login'
                        ? 'bg-slate-800 text-sky-400 border border-slate-700'
                        : 'text-slate-400 hover:text-white'
                    }`}
                  >
                    Client Sign In
                  </button>
                  <button
                    type="button"
                    onClick={() => { setActiveAuthTab('register'); setError(''); setSuccessMsg(''); }}
                    className={`flex-1 text-center py-2 text-xs font-bold rounded-xl transition ${
                      activeAuthTab === 'register'
                        ? 'bg-slate-800 text-indigo-400 border border-slate-700'
                        : 'text-slate-400 hover:text-white'
                    }`}
                  >
                    New Account
                  </button>
                </div>

                {/* Status Messages */}
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

                {/* Tab 1: Login Form */}
                {activeAuthTab === 'login' ? (
                  <form onSubmit={handleLoginSubmit} className="space-y-3.5 sm:space-y-4">
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
                          placeholder="client@example.com"
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
                      className="w-full py-3 px-4 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white rounded-xl text-xs font-bold shadow-lg shadow-sky-500/20 transition-all disabled:opacity-50 flex items-center justify-center space-x-2"
                    >
                      <LogIn className="w-4 h-4" />
                      <span>{isLoading ? 'Signing in...' : 'Sign In to Dashboard'}</span>
                    </button>

                    <div className="text-center pt-2">
                      <p className="text-xs text-slate-400">
                        Don't have an account yet?{' '}
                        <button
                          type="button"
                          onClick={() => { setActiveAuthTab('register'); setError(''); }}
                          className="text-sky-400 hover:text-sky-300 font-bold underline ml-1"
                        >
                          Sign Up / Register
                        </button>
                      </p>
                    </div>
                  </form>
                ) : (
                  /* Tab 2: Register Form */
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
                      <label className="block text-xs font-semibold text-slate-300 mb-1">Account Role</label>
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
                      className="w-full py-2.5 px-4 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white rounded-xl text-xs font-bold shadow-lg shadow-indigo-500/20 transition-all disabled:opacity-50 flex items-center justify-center space-x-2 mt-2"
                    >
                      <UserPlus className="w-4 h-4" />
                      <span>{regLoading ? 'Creating Account...' : 'Create My Account'}</span>
                    </button>

                    <div className="text-center pt-1">
                      <p className="text-xs text-slate-400">
                        Already have an account?{' '}
                        <button
                          type="button"
                          onClick={() => { setActiveAuthTab('login'); setError(''); }}
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

          </div>

          {/* "How Our Work Happens" 5-Step Process Breakdown (Responsive Grid) */}
          <div className="relative z-10 mt-8 sm:mt-12 pt-6 sm:pt-8 border-t border-slate-800/80">
            <div className="flex items-center space-x-2 mb-4">
              <Layers className="w-4 h-4 text-sky-400" />
              <h2 className="text-xs font-bold uppercase tracking-wider text-slate-300">
                How EventCraft Works — Our Seamless 5-Step Process
              </h2>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-5 gap-3">
              
              <div className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-4 hover:border-sky-500/40 transition">
                <div className="w-7 h-7 rounded-lg bg-sky-500/20 text-sky-400 font-black text-xs flex items-center justify-center mb-2.5">
                  01
                </div>
                <h3 className="font-bold text-xs text-white">1. Define Your Vision</h3>
                <p className="text-[11px] text-slate-400 mt-1 leading-relaxed">
                  Choose your celebration type, target date, guest count, and preferred venue location.
                </p>
              </div>

              <div className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-4 hover:border-indigo-500/40 transition">
                <div className="w-7 h-7 rounded-lg bg-indigo-500/20 text-indigo-400 font-black text-xs flex items-center justify-center mb-2.5">
                  02
                </div>
                <h3 className="font-bold text-xs text-white">2. AI Multi-Agent Curation</h3>
                <p className="text-[11px] text-slate-400 mt-1 leading-relaxed">
                  Autonomous agents instantly match ideal certified banquet halls and calculate hotel catering packages.
                </p>
              </div>

              <div className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-4 hover:border-amber-500/40 transition">
                <div className="w-7 h-7 rounded-lg bg-amber-500/20 text-amber-400 font-black text-xs flex items-center justify-center mb-2.5">
                  03
                </div>
                <h3 className="font-bold text-xs text-white">3. Weather Safeguard</h3>
                <p className="text-[11px] text-slate-400 mt-1 leading-relaxed">
                  Live environmental AI evaluates rain risks and auto-integrates heavy-duty waterproof marquee tents.
                </p>
              </div>

              <div className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-4 hover:border-pink-500/40 transition">
                <div className="w-7 h-7 rounded-lg bg-pink-500/20 text-pink-400 font-black text-xs flex items-center justify-center mb-2.5">
                  04
                </div>
                <h3 className="font-bold text-xs text-white">4. Verified Supplier Synergy</h3>
                <p className="text-[11px] text-slate-400 mt-1 leading-relaxed">
                  Synchronizes concert sound, moving heads, fresh floral stages, 4K media crew, and celebration cakes.
                </p>
              </div>

              <div className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-4 hover:border-emerald-500/40 transition sm:col-span-2 md:col-span-1">
                <div className="w-7 h-7 rounded-lg bg-emerald-500/20 text-emerald-400 font-black text-xs flex items-center justify-center mb-2.5">
                  05
                </div>
                <h3 className="font-bold text-xs text-white">5. Transparent Dashboard</h3>
                <p className="text-[11px] text-slate-400 mt-1 leading-relaxed">
                  Inspect live itemized breakdowns, claim discounts, review inspiration photos, and confirm bookings.
                </p>
              </div>

            </div>
          </div>

        </div>

        {/* ========================================================================= */}
        {/* 3. CURATED LUXURY EVENT PHOTOGRAPHY SHOWCASE ("Lassana Photos")          */}
        {/* ========================================================================= */}
        <div className="bg-slate-900 rounded-2xl sm:rounded-3xl border border-slate-800 p-5 sm:p-8 shadow-xl">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-2 mb-6 pb-4 border-b border-slate-800">
            <div>
              <div className="flex items-center space-x-2">
                <ImageIcon className="w-5 h-5 text-sky-400" />
                <h2 className="text-lg sm:text-xl font-black text-white">Curated Luxury Celebrations & Inspirations</h2>
              </div>
              <p className="text-xs text-slate-400 mt-1">
                Explore signature event setups curated by EventCraft AI across premier Sri Lankan hotels and destinations.
              </p>
            </div>
            <span className="text-[11px] font-semibold px-2.5 py-1 rounded-full bg-slate-800 text-slate-300 border border-slate-700">
              Tap any image to view in HD
            </span>
          </div>

          {/* 6 Curated High-Res Visual Cards (Responsive 1-col on phone, 2-col on tablet, 3-col on desktop) */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
            {CURATED_SHOWCASE_PHOTOS.map((item) => (
              <div 
                key={item.id}
                onClick={() => setPreviewImage(item.imageUrl)}
                className="group relative bg-slate-950 rounded-2xl overflow-hidden border border-slate-800 hover:border-sky-500/60 shadow-md hover:shadow-xl transition-all duration-300 cursor-pointer flex flex-col"
              >
                {/* Image Aspect Box */}
                <div className="relative aspect-[16/10] overflow-hidden bg-slate-950">
                  <img 
                    src={item.imageUrl} 
                    alt={item.title} 
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 opacity-90 group-hover:opacity-100"
                    loading="lazy"
                  />
                  
                  {/* Floating Tag Badge */}
                  <div className="absolute top-3 left-3">
                    <span className="text-[10px] font-bold px-2.5 py-1 rounded-full bg-black/70 backdrop-blur-md text-white border border-white/20 shadow-sm">
                      {item.tag}
                    </span>
                  </div>

                  {/* Hover Zoom Overlay */}
                  <div className="absolute inset-0 bg-slate-950/40 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
                    <span className="flex items-center space-x-1.5 px-3 py-1.5 rounded-xl bg-white text-slate-900 text-xs font-bold shadow-lg">
                      <Eye className="w-3.5 h-3.5 text-sky-600" />
                      <span>View Photo</span>
                    </span>
                  </div>
                </div>

                {/* Card Meta Content */}
                <div className="p-4 bg-slate-900/90 flex-1 flex flex-col justify-between border-t border-slate-800">
                  <div>
                    <div className="flex items-center space-x-1.5 text-xs text-sky-400 font-semibold mb-1">
                      <span>{item.icon}</span>
                      <span>{item.category}</span>
                    </div>
                    <h3 className="font-bold text-sm text-white leading-snug group-hover:text-sky-400 transition-colors">
                      {item.title}
                    </h3>
                    <p className="text-xs text-slate-400 mt-1.5 line-clamp-2 leading-relaxed">
                      {item.description}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

      </main>

      {/* Lightbox Modal (Responsive for mobile screens) */}
      {previewImage && (
        <div 
          className="fixed inset-0 z-50 bg-black/90 backdrop-blur-sm flex items-center justify-center p-2 sm:p-4" 
          onClick={() => setPreviewImage(null)}
        >
          <div 
            className="relative w-full max-w-5xl max-h-[90vh] bg-slate-900 rounded-2xl sm:rounded-3xl overflow-hidden shadow-2xl border border-slate-700" 
            onClick={e => e.stopPropagation()}
          >
            <button 
              onClick={() => setPreviewImage(null)}
              className="absolute top-3 right-3 p-2 bg-black/70 hover:bg-black text-white rounded-full transition z-20 shadow-lg border border-white/20"
            >
              <X className="w-5 h-5" />
            </button>
            <img 
              src={previewImage} 
              alt="High Definition Preview" 
              className="w-full h-auto max-h-[85vh] object-contain" 
            />
          </div>
        </div>
      )}

      {/* Footer */}
      <footer className="py-6 text-center text-xs text-slate-500 border-t border-slate-900 bg-slate-950 px-4">
        SE3090 Software Engineering Frameworks • EventCraft AI Management Platform
      </footer>

    </div>
  );
};
