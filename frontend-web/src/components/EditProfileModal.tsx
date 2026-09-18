import React, { useState } from 'react';
import { User, Mail, Phone, ShieldCheck, X, Check, Sparkles } from 'lucide-react';
import { authService } from '../services/authService';

interface EditProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
  onProfileUpdated?: () => void;
}

export const EditProfileModal: React.FC<EditProfileModalProps> = ({
  isOpen,
  onClose,
  onProfileUpdated
}) => {
  const currentName = authService.getUserName();
  const currentEmail = authService.getUserEmail();
  const currentPhone = authService.getUserPhone();
  const currentRole = authService.getUserRole();

  const [fullName, setFullName] = useState(currentName);
  const [email, setEmail] = useState(currentEmail);
  const [phone, setPhone] = useState(currentPhone);
  const [isSaved, setIsSaved] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    authService.updateProfile(fullName, email, phone);
    setIsSaved(true);

    if (onProfileUpdated) {
      onProfileUpdated();
    }

    setTimeout(() => {
      setIsSaved(false);
      onClose();
    }, 800);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-sm animate-fadeIn">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-md shadow-2xl text-white overflow-hidden transform transition-all">
        
        {/* Header */}
        <div className="px-6 py-5 bg-gradient-to-r from-slate-900 via-indigo-950 to-slate-900 border-b border-slate-800 flex justify-between items-center">
          <div className="flex items-center space-x-3">
            <div className="p-2.5 bg-indigo-600/20 border border-indigo-500/30 rounded-xl">
              <Sparkles className="w-5 h-5 text-indigo-400" />
            </div>
            <div>
              <h3 className="font-bold text-lg text-white">Edit Profile Details</h3>
              <p className="text-xs text-slate-400">Update your personal account information</p>
            </div>
          </div>
          <button 
            type="button"
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          
          {/* Current Role Badge */}
          <div className="flex items-center justify-between px-4 py-2.5 bg-slate-800/60 rounded-xl border border-slate-700/50">
            <span className="text-xs text-slate-400 font-medium">Account Role:</span>
            <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 flex items-center gap-1.5">
              <ShieldCheck className="w-3.5 h-3.5" />
              {currentRole} Account
            </span>
          </div>

          {/* Full Name */}
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Full Name / Display Name
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                <User className="w-4 h-4 text-slate-500" />
              </div>
              <input 
                type="text"
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                placeholder="Enter your full name"
                className="w-full pl-10 pr-4 py-2.5 bg-slate-950 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition"
              />
            </div>
          </div>

          {/* Email */}
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Email Address
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                <Mail className="w-4 h-4 text-slate-500" />
              </div>
              <input 
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="e.g. vendor@eventcraft.ai"
                className="w-full pl-10 pr-4 py-2.5 bg-slate-950 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition"
              />
            </div>
          </div>

          {/* Contact Phone */}
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Contact Number
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                <Phone className="w-4 h-4 text-slate-500" />
              </div>
              <input 
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="e.g. +94 77 123 4567"
                className="w-full pl-10 pr-4 py-2.5 bg-slate-950 border border-slate-700/80 rounded-xl text-white placeholder-slate-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition"
              />
            </div>
          </div>

          {/* Success notification */}
          {isSaved && (
            <div className="p-3 bg-emerald-500/10 border border-emerald-500/30 rounded-xl text-emerald-400 text-xs font-semibold flex items-center space-x-2 animate-fadeIn">
              <Check className="w-4 h-4 text-emerald-400" />
              <span>Profile details updated successfully!</span>
            </div>
          )}

          {/* Buttons */}
          <div className="flex items-center justify-end space-x-3 pt-3 border-t border-slate-800">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-xl transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex items-center space-x-1.5 px-5 py-2 text-xs font-bold text-white bg-gradient-to-r from-indigo-600 to-sky-600 hover:from-indigo-500 hover:to-sky-500 rounded-xl shadow-lg transition"
            >
              <Check className="w-4 h-4" />
              <span>Save Changes</span>
            </button>
          </div>
        </form>

      </div>
    </div>
  );
};
