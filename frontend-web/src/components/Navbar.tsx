import React from 'react';
import { Sparkles, ShieldCheck, CreditCard, LayoutDashboard, Package, Building2, LogOut, LogIn, UserPlus } from 'lucide-react';
import { authService } from '../services/authService';

interface NavbarProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
  userRole: 'Manager' | 'Vendor' | 'Customer' | 'Guest';
  onLogout: () => void;
  onOpenLogin?: () => void;
  onOpenRegister?: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ 
  currentTab, 
  onTabChange,
  userRole,
  onLogout,
  onOpenLogin,
  onOpenRegister
}) => {
  const userName = authService.getUserName();
  const isLoggedIn = authService.isLoggedIn();

  const getPortalBadge = () => {
    switch (userRole) {
      case 'Manager':
        return { label: 'Operations Manager Portal', bg: 'bg-slate-800 text-sky-300 border-slate-700' };
      case 'Vendor':
        return { label: 'Supplier & Vendor Portal', bg: 'bg-indigo-950 text-indigo-300 border-indigo-800' };
      case 'Customer':
        return { label: 'Client Experience Portal', bg: 'bg-sky-950 text-sky-300 border-sky-800' };
      default:
        return { label: 'Client & Visitor Portal', bg: 'bg-slate-800 text-slate-300 border-slate-700' };
    }
  };

  const badge = getPortalBadge();

  return (
    <nav className="bg-slate-900 border-b border-slate-800 text-white sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          
          {/* Logo & Portal Branding */}
          <div className="flex items-center space-x-3 cursor-pointer" onClick={() => onTabChange('dashboard')}>
            <div className="p-2 bg-gradient-to-tr from-sky-500 to-indigo-600 rounded-lg shadow-lg">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="font-bold text-lg tracking-tight text-white">EventCraft<span className="text-sky-400">.AI</span></span>
              <span className={`ml-2 text-xs font-semibold px-2.5 py-0.5 rounded-full border ${badge.bg}`}>
                {badge.label}
              </span>
            </div>
          </div>

          {/* Navigation Tabs */}
          {userRole === 'Manager' ? (
            <div className="hidden lg:flex items-center space-x-1">
              <button 
                onClick={() => onTabChange('dashboard')}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium transition ${
                  currentTab === 'dashboard' ? 'bg-slate-800 text-sky-400 shadow-sm' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <LayoutDashboard className="w-4 h-4" />
                <span>Dashboard</span>
              </button>

              <button 
                onClick={() => onTabChange('venues')}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium transition ${
                  currentTab === 'venues' ? 'bg-slate-800 text-sky-400 shadow-sm' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <Building2 className="w-4 h-4" />
                <span>Venues</span>
              </button>

              <button 
                onClick={() => onTabChange('vendors')}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium transition ${
                  currentTab === 'vendors' ? 'bg-slate-800 text-sky-400 shadow-sm' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <ShieldCheck className="w-4 h-4" />
                <span>Vendors</span>
              </button>

              <button 
                onClick={() => onTabChange('resources')}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium transition ${
                  currentTab === 'resources' ? 'bg-slate-800 text-sky-400 shadow-sm' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <Package className="w-4 h-4" />
                <span>Resources & AI Rules</span>
              </button>

              <button 
                onClick={() => onTabChange('payments')}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium transition ${
                  currentTab === 'payments' ? 'bg-slate-800 text-sky-400 shadow-sm' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <CreditCard className="w-4 h-4" />
                <span>Payments & Analytics</span>
              </button>
            </div>
          ) : userRole === 'Vendor' ? (
            <div className="hidden md:flex items-center space-x-2 text-xs text-indigo-300 bg-indigo-950/60 px-3.5 py-1.5 rounded-xl border border-indigo-800/60">
              <Building2 className="w-4 h-4 text-indigo-400" />
              <span>Dedicated Supplier View • Business Registration & Audit Tracking</span>
            </div>
          ) : (
            <div className="hidden md:flex items-center space-x-2">
              <button 
                onClick={() => onTabChange('dashboard')}
                className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                  currentTab === 'dashboard' ? 'bg-slate-800 text-sky-400' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <LayoutDashboard className="w-3.5 h-3.5" />
                <span>Client Dashboard</span>
              </button>
              <button 
                onClick={() => onTabChange('venues')}
                className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                  currentTab === 'venues' ? 'bg-slate-800 text-sky-400' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                }`}
              >
                <Building2 className="w-3.5 h-3.5" />
                <span>Browse Venues</span>
              </button>
            </div>
          )}

          {/* Right Side: Logged-in Persona or Sign In buttons */}
          <div className="flex items-center space-x-3">
            {isLoggedIn ? (
              <>
                <div className="flex items-center space-x-2 text-xs text-slate-300 bg-slate-800/60 px-3 py-1.5 rounded-lg border border-slate-700/60">
                  <span className={`w-2 h-2 rounded-full ${
                    userRole === 'Manager' ? 'bg-emerald-500 animate-pulse' : 'bg-sky-400'
                  }`}></span>
                  <span className="font-medium text-slate-200">{userName}</span>
                  <span className="text-slate-500 font-normal">({userRole})</span>
                </div>

                <button 
                  onClick={onLogout}
                  className="flex items-center space-x-1.5 px-3 py-1.5 text-xs text-slate-400 hover:text-red-300 hover:bg-red-500/10 border border-slate-700 hover:border-red-500/30 rounded-lg transition"
                  title="Sign Out"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Sign Out</span>
                </button>
              </>
            ) : (
              <div className="flex items-center space-x-2">
                <button
                  onClick={onOpenLogin}
                  className="flex items-center space-x-1 px-3 py-1.5 text-xs font-bold text-slate-300 hover:text-white bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-lg transition"
                >
                  <LogIn className="w-3.5 h-3.5 text-sky-400" />
                  <span>Log In</span>
                </button>
                <button
                  onClick={onOpenRegister}
                  className="flex items-center space-x-1 px-3 py-1.5 text-xs font-bold text-white bg-gradient-to-r from-sky-500 to-indigo-600 rounded-lg shadow-sm hover:from-sky-400 hover:to-indigo-500 transition"
                >
                  <UserPlus className="w-3.5 h-3.5" />
                  <span>Sign Up</span>
                </button>
              </div>
            )}
          </div>

        </div>
      </div>
    </nav>
  );
};
