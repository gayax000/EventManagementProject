import React from 'react';
import { ShieldAlert, ArrowLeft } from 'lucide-react';

interface ProtectedRouteProps {
  isAuthenticated: boolean;
  userRole: 'Manager' | 'Vendor' | 'Customer';
  allowedRoles: Array<'Manager' | 'Vendor' | 'Customer'>;
  children: React.ReactNode;
  onFallbackTab?: (tab: string) => void;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  isAuthenticated,
  userRole,
  allowedRoles,
  children,
  onFallbackTab
}) => {
  if (!isAuthenticated) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center p-6">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-xl border border-slate-200 p-8 text-center space-y-4">
          <div className="w-14 h-14 bg-amber-100 text-amber-600 rounded-full flex items-center justify-center mx-auto shadow-sm">
            <ShieldAlert className="w-7 h-7" />
          </div>
          <h2 className="text-xl font-bold text-slate-800">Authentication Required</h2>
          <p className="text-sm text-slate-600">
            You must be logged into EventCraft.AI to access this module.
          </p>
        </div>
      </div>
    );
  }

  if (!allowedRoles.includes(userRole)) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center p-6">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-xl border border-red-100 p-8 text-center space-y-4">
          <div className="w-14 h-14 bg-red-100 text-red-600 rounded-full flex items-center justify-center mx-auto shadow-sm animate-bounce">
            <ShieldAlert className="w-7 h-7" />
          </div>
          <h2 className="text-xl font-bold text-slate-900">Access Denied</h2>
          <p className="text-xs text-slate-500 bg-slate-100 py-1.5 px-3 rounded-lg font-mono inline-block">
            Required Role: {allowedRoles.join(' / ')} | Your Role: <span className="font-bold text-red-600">{userRole}</span>
          </p>
          <p className="text-sm text-slate-600">
            You do not have administrative permissions to view or edit this management module.
          </p>
          {onFallbackTab && (
            <button
              onClick={() => onFallbackTab('dashboard')}
              className="inline-flex items-center space-x-2 px-4 py-2 text-xs font-bold text-white bg-slate-900 hover:bg-slate-800 rounded-xl transition shadow-md cursor-pointer"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Return to Safe Dashboard</span>
            </button>
          )}
        </div>
      </div>
    );
  }

  return <>{children}</>;
};
