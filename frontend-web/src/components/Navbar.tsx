import React, { useState, useEffect, useRef } from 'react';
import { 
  Sparkles, 
  ShieldCheck, 
  CreditCard, 
  LayoutDashboard, 
  Package, 
  Building2, 
  LogOut, 
  LogIn, 
  UserPlus, 
  ChevronDown, 
  User, 
  Edit3, 
  Mail, 
  Phone, 
  Store 
} from 'lucide-react';
import { authService } from '../services/authService';
import { EditProfileModal } from './EditProfileModal';

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
  const [userName, setUserName] = useState(authService.getUserName());
  const [userEmail, setUserEmail] = useState(authService.getUserEmail());
  const [userPhone, setUserPhone] = useState(authService.getUserPhone());
  const isLoggedIn = authService.isLoggedIn();

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);

  const dropdownRef = useRef<HTMLDivElement>(null);

  const syncUserProfile = () => {
    setUserName(authService.getUserName());
    setUserEmail(authService.getUserEmail());
    setUserPhone(authService.getUserPhone());
  };

  useEffect(() => {
    syncUserProfile();

    const handleProfileUpdate = () => {
      syncUserProfile();
    };

    window.addEventListener('user_profile_updated', handleProfileUpdate);
    return () => {
      window.removeEventListener('user_profile_updated', handleProfileUpdate);
    };
  }, []);

  // Click outside listener for profile dropdown
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

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
    <>
      <nav className="bg-slate-900 border-b border-slate-800 text-white sticky top-0 z-40">
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

            {/* Right Side: Logged-in Persona Dropdown Menu or Sign In buttons */}
            <div className="flex items-center space-x-3">
              {isLoggedIn ? (
                <div className="relative" ref={dropdownRef}>
                  
                  {/* User Badge Button */}
                  <button 
                    onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                    className="flex items-center space-x-2.5 text-xs text-slate-200 bg-slate-800/80 hover:bg-slate-800 px-3.5 py-1.5 rounded-xl border border-slate-700/80 hover:border-slate-600 transition shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50 cursor-pointer"
                  >
                    <span className={`w-2 h-2 rounded-full ${
                      userRole === 'Manager' ? 'bg-emerald-500 animate-pulse' : 'bg-indigo-400'
                    }`}></span>
                    <span className="font-semibold text-slate-100">{userName}</span>
                    <span className="text-indigo-300 bg-indigo-950/80 px-2 py-0.5 rounded-md border border-indigo-800/50 text-[10px] font-bold">
                      {userRole}
                    </span>
                    <ChevronDown className={`w-3.5 h-3.5 text-slate-400 transition-transform duration-200 ${isDropdownOpen ? 'rotate-180 text-white' : ''}`} />
                  </button>

                  {/* Dropdown Menu Popup */}
                  {isDropdownOpen && (
                    <div className="absolute right-0 mt-2 w-72 bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl overflow-hidden z-50 animate-fadeIn">
                      
                      {/* Dropdown Header User Info */}
                      <div className="p-4 bg-slate-950/80 border-b border-slate-800 flex items-center space-x-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-indigo-600 to-sky-500 flex items-center justify-center font-bold text-white shadow-md">
                          {userName ? userName.charAt(0).toUpperCase() : 'U'}
                        </div>
                        <div className="overflow-hidden">
                          <p className="text-sm font-bold text-white truncate">{userName}</p>
                          <p className="text-xs text-slate-400 truncate flex items-center gap-1 mt-0.5">
                            <Mail className="w-3 h-3 text-slate-500 shrink-0" />
                            {userEmail || 'No email specified'}
                          </p>
                          {userPhone && (
                            <p className="text-[11px] text-slate-400 truncate flex items-center gap-1 mt-0.5">
                              <Phone className="w-3 h-3 text-slate-500 shrink-0" />
                              {userPhone}
                            </p>
                          )}
                        </div>
                      </div>

                      {/* Menu Actions */}
                      <div className="p-2 space-y-1">
                        <button
                          onClick={() => {
                            setIsDropdownOpen(false);
                            setIsEditModalOpen(true);
                          }}
                          className="w-full flex items-center space-x-2.5 px-3 py-2 text-xs text-slate-200 hover:text-white hover:bg-slate-800 rounded-xl transition font-medium cursor-pointer"
                        >
                          <Edit3 className="w-4 h-4 text-indigo-400" />
                          <span>Edit Profile Details</span>
                        </button>

                        {userRole === 'Vendor' && (
                          <button
                            onClick={() => {
                              setIsDropdownOpen(false);
                              onTabChange('dashboard');
                            }}
                            className="w-full flex items-center space-x-2.5 px-3 py-2 text-xs text-slate-200 hover:text-white hover:bg-slate-800 rounded-xl transition font-medium cursor-pointer"
                          >
                            <Store className="w-4 h-4 text-sky-400" />
                            <span>Vendor Business Profile</span>
                          </button>
                        )}
                      </div>

                      {/* Menu Footer / Sign Out */}
                      <div className="p-2 border-t border-slate-800 bg-slate-950/40">
                        <button
                          onClick={() => {
                            setIsDropdownOpen(false);
                            onLogout();
                          }}
                          className="w-full flex items-center space-x-2.5 px-3 py-2 text-xs text-red-400 hover:text-red-300 hover:bg-red-500/10 rounded-xl transition font-semibold cursor-pointer"
                        >
                          <LogOut className="w-4 h-4" />
                          <span>Sign Out</span>
                        </button>
                      </div>

                    </div>
                  )}

                </div>
              ) : (
                <div className="flex items-center space-x-2">
                  <button
                    onClick={onOpenLogin}
                    className="flex items-center space-x-1 px-3 py-1.5 text-xs font-bold text-slate-300 hover:text-white bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-lg transition cursor-pointer"
                  >
                    <LogIn className="w-3.5 h-3.5 text-sky-400" />
                    <span>Log In</span>
                  </button>
                  <button
                    onClick={onOpenRegister}
                    className="flex items-center space-x-1 px-3 py-1.5 text-xs font-bold text-white bg-gradient-to-r from-sky-500 to-indigo-600 rounded-lg shadow-sm hover:from-sky-400 hover:to-indigo-500 transition cursor-pointer"
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

      {/* Edit Profile Modal */}
      <EditProfileModal 
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        onProfileUpdated={syncUserProfile}
      />
    </>
  );
};
