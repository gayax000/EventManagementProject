import React from 'react';
import { Sparkles, Calendar, ShieldCheck, CreditCard, LayoutDashboard } from 'lucide-react';

export const Navbar: React.FC = () => {
  return (
    <nav className="bg-slate-900 border-b border-slate-800 text-white sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          
          {/* Logo & Title */}
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-gradient-to-tr from-sky-500 to-indigo-600 rounded-lg shadow-lg">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="font-bold text-lg tracking-tight text-white">EventCraft<span className="text-sky-400">.AI</span></span>
              <span className="ml-2 text-xs font-semibold px-2 py-0.5 bg-slate-800 text-sky-300 rounded-full border border-slate-700">Manager Portal</span>
            </div>
          </div>

          {/* Navigation Links */}
          <div className="hidden md:flex items-center space-x-1">
            <button className="flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium bg-slate-800 text-sky-400">
              <LayoutDashboard className="w-4 h-4" />
              <span>Dashboard</span>
            </button>
            <button className="flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium text-slate-300 hover:bg-slate-800 hover:text-white">
              <Calendar className="w-4 h-4" />
              <span>Event Proposals</span>
            </button>
            <button className="flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium text-slate-300 hover:bg-slate-800 hover:text-white">
              <ShieldCheck className="w-4 h-4" />
              <span>Vendor Approvals</span>
            </button>
            <button className="flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium text-slate-300 hover:bg-slate-800 hover:text-white">
              <CreditCard className="w-4 h-4" />
              <span>Payments & Audit</span>
            </button>
          </div>

          {/* Profile / Status */}
          <div className="flex items-center space-x-3">
            <div className="flex items-center space-x-2 text-sm text-slate-300">
              <span className="w-2.5 h-2.5 bg-emerald-500 rounded-full animate-pulse"></span>
              <span>Online • Kasun (Manager)</span>
            </div>
          </div>

        </div>
      </div>
    </nav>
  );
};