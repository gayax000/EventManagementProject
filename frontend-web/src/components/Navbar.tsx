import React from 'react';
import { Sparkles, ShieldCheck, CreditCard, LayoutDashboard, Package, Building2, ArrowLeftRight } from 'lucide-react';

interface NavbarProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
  currentPortal: 'manager' | 'vendor';
  onPortalChange: (portal: 'manager' | 'vendor') => void;
}

export const Navbar: React.FC<NavbarProps> = ({ 
  currentTab, 
  onTabChange,
  currentPortal,
  onPortalChange
}) => {
  return (
    <nav className="bg-slate-900 border-b border-slate-800 text-white sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          
          {/* Logo & Title */}
          <div className="flex items-center space-x-3 cursor-pointer" onClick={() => onPortalChange('manager')}>
            <div className="p-2 bg-gradient-to-tr from-sky-500 to-indigo-600 rounded-lg shadow-lg">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div>
              <span className="font-bold text-lg tracking-tight text-white">EventCraft<span className="text-sky-400">.AI</span></span>
              <span className={`ml-2 text-xs font-semibold px-2 py-0.5 rounded-full border ${
                currentPortal === 'manager' 
                  ? 'bg-slate-800 text-sky-300 border-slate-700' 
                  : 'bg-indigo-950 text-indigo-300 border-indigo-800'
              }`}>
                {currentPortal === 'manager' ? 'Manager Portal' : 'Vendor Portal'}
              </span>
            </div>
          </div>

          {/* Navigation Tabs (Only in Manager Portal) */}
          {currentPortal === 'manager' ? (
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
                <ShieldCheck className="w-4 h-4" />
                <span>Venues & Vendors</span>
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
          ) : (
            <div className="hidden md:flex items-center space-x-2 text-xs text-indigo-300 bg-indigo-950/60 px-3 py-1.5 rounded-xl border border-indigo-800/60">
              <Building2 className="w-4 h-4 text-indigo-400" />
              <span>External Supplier View • Onboarding & Status Tracking</span>
            </div>
          )}

          {/* Right Side: Role Switcher & Profile */}
          <div className="flex items-center space-x-4">
            
            {/* Role / Portal Switcher */}
            <div className="flex items-center bg-slate-800 p-1 rounded-xl border border-slate-700 shadow-inner">
              <button
                onClick={() => onPortalChange('manager')}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center space-x-1.5 transition ${
                  currentPortal === 'manager'
                    ? 'bg-sky-600 text-white shadow-sm'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                <LayoutDashboard className="w-3.5 h-3.5" />
                <span>Manager View</span>
              </button>
              <button
                onClick={() => onPortalChange('vendor')}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold flex items-center space-x-1.5 transition ${
                  currentPortal === 'vendor'
                    ? 'bg-indigo-600 text-white shadow-sm'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                <Building2 className="w-3.5 h-3.5" />
                <span>Vendor View</span>
              </button>
            </div>

            {/* Persona Status */}
            <div className="hidden sm:flex items-center space-x-2 text-xs text-slate-300">
              <span className={`w-2.5 h-2.5 rounded-full animate-pulse ${
                currentPortal === 'manager' ? 'bg-emerald-500' : 'bg-indigo-400'
              }`}></span>
              <span>{currentPortal === 'manager' ? 'Kasun (Manager)' : 'Supplier Session'}</span>
            </div>

          </div>

        </div>
      </div>
    </nav>
  );
};