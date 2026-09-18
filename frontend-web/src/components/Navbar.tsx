import React from 'react';
import { Sparkles, ShieldCheck, CreditCard, LayoutDashboard, Package, Bell, User } from 'lucide-react';

interface NavbarProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
}

export const Navbar: React.FC<NavbarProps> = ({ currentTab, onTabChange }) => {
  return (
    <nav className="bg-slate-950/90 backdrop-blur-md border-b border-slate-800/80 text-white sticky top-0 z-50 shadow-xl">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          
          {/* Logo & Title */}
          <div className="flex items-center space-x-3 cursor-pointer group" onClick={() => onTabChange('dashboard')}>
            <div className="p-2.5 bg-gradient-to-tr from-sky-400 via-cyan-500 to-indigo-600 rounded-xl shadow-lg shadow-sky-500/25 group-hover:scale-105 transition duration-200">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="flex items-center space-x-1.5">
                <span className="font-extrabold text-lg tracking-tight text-white">EventCraft</span>
                <span className="text-xs font-black px-1.5 py-0.5 rounded bg-sky-500/20 text-sky-400 border border-sky-400/30 tracking-wide">
                  AI
                </span>
              </div>
              <p className="text-[10px] font-semibold text-slate-400 uppercase tracking-widest -mt-0.5">
                Operations Platform
              </p>
            </div>
          </div>

          {/* Navigation Tabs */}
          <div className="hidden md:flex items-center space-x-1.5 bg-slate-900/90 p-1 rounded-xl border border-slate-800">
            <button 
              onClick={() => onTabChange('dashboard')}
              className={`flex items-center space-x-2 px-3.5 py-1.5 rounded-lg text-xs font-bold transition duration-200 ${
                currentTab === 'dashboard' 
                  ? 'bg-gradient-to-r from-sky-500/20 to-indigo-500/20 text-sky-400 border border-sky-500/40 shadow-sm' 
                  : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
              }`}
            >
              <LayoutDashboard className="w-3.5 h-3.5" />
              <span>AI Dashboard</span>
            </button>

            <button 
              onClick={() => onTabChange('venues')}
              className={`flex items-center space-x-2 px-3.5 py-1.5 rounded-lg text-xs font-bold transition duration-200 ${
                currentTab === 'venues' 
                  ? 'bg-gradient-to-r from-sky-500/20 to-indigo-500/20 text-sky-400 border border-sky-500/40 shadow-sm' 
                  : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
              }`}
            >
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Venues & Vendors</span>
            </button>

            <button 
              onClick={() => onTabChange('resources')}
              className={`flex items-center space-x-2 px-3.5 py-1.5 rounded-lg text-xs font-bold transition duration-200 ${
                currentTab === 'resources' 
                  ? 'bg-gradient-to-r from-sky-500/20 to-indigo-500/20 text-sky-400 border border-sky-500/40 shadow-sm' 
                  : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
              }`}
            >
              <Package className="w-3.5 h-3.5" />
              <span>Resources & Rules</span>
            </button>

            <button 
              onClick={() => onTabChange('payments')}
              className={`flex items-center space-x-2 px-3.5 py-1.5 rounded-lg text-xs font-bold transition duration-200 ${
                currentTab === 'payments' 
                  ? 'bg-gradient-to-r from-sky-500/20 to-indigo-500/20 text-sky-400 border border-sky-500/40 shadow-sm' 
                  : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
              }`}
            >
              <CreditCard className="w-3.5 h-3.5" />
              <span>Payments & Analytics</span>
            </button>
          </div>

          {/* User Profile & Notifications */}
          <div className="flex items-center space-x-3">
            {/* Notification Bell with 3 Pending Badge */}
            <div className="relative p-2 rounded-xl bg-slate-900 border border-slate-800 text-slate-300 hover:text-white cursor-pointer transition">
              <Bell className="w-4 h-4" />
              <span className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-amber-500 text-slate-950 font-black text-[9px] flex items-center justify-center">
                3
              </span>
            </div>

            {/* Profile pill */}
            <div className="flex items-center space-x-2.5 px-3 py-1.5 bg-slate-900 rounded-xl border border-slate-800">
              <span className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse"></span>
              <div className="text-left hidden sm:block">
                <p className="text-xs font-bold text-slate-200 leading-tight">Kasun</p>
                <p className="text-[10px] text-sky-400 font-medium leading-tight">Manager Portal</p>
              </div>
            </div>
          </div>

        </div>
      </div>
    </nav>
  );
};