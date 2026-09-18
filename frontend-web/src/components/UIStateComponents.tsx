import React from 'react';
import { Loader2, Inbox, AlertTriangle, RefreshCw } from 'lucide-react';

// 1. Reusable Loading Spinner Component
interface LoadingSpinnerProps {
  message?: string;
}

export const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({ 
  message = "Loading management records..." 
}) => {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 space-y-3">
      <div className="p-3 bg-sky-50 text-sky-600 rounded-2xl shadow-inner border border-sky-100">
        <Loader2 className="w-8 h-8 animate-spin" />
      </div>
      <p className="text-xs font-semibold text-slate-600 animate-pulse">{message}</p>
    </div>
  );
};

// 2. Reusable Empty State Graphic Component
interface EmptyStateProps {
  title: string;
  description: string;
  actionText?: string;
  onAction?: () => void;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  title,
  description,
  actionText,
  onAction
}) => {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center bg-slate-50/50 rounded-2xl border border-dashed border-slate-300 my-4 space-y-3">
      <div className="p-4 bg-slate-100 text-slate-400 rounded-full shadow-inner">
        <Inbox className="w-10 h-10" />
      </div>
      <div className="max-w-md">
        <h3 className="text-base font-bold text-slate-800">{title}</h3>
        <p className="text-xs text-slate-500 mt-1">{description}</p>
      </div>
      {actionText && onAction && (
        <button
          onClick={onAction}
          className="mt-2 px-4 py-2 text-xs font-semibold text-white bg-sky-600 hover:bg-sky-500 rounded-xl transition shadow-md cursor-pointer"
        >
          {actionText}
        </button>
      )}
    </div>
  );
};

// 3. Reusable Error Alert Component with Retry
interface ErrorAlertProps {
  title?: string;
  message: string;
  onRetry?: () => void;
}

export const ErrorAlert: React.FC<ErrorAlertProps> = ({
  title = "Connection Error",
  message,
  onRetry
}) => {
  return (
    <div className="my-4 p-4 bg-red-50/90 border border-red-200 rounded-2xl shadow-sm text-red-900 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
      <div className="flex items-start space-x-3">
        <div className="p-2 bg-red-100 text-red-600 rounded-xl shrink-0 mt-0.5 sm:mt-0">
          <AlertTriangle className="w-5 h-5" />
        </div>
        <div>
          <h4 className="text-xs font-bold uppercase tracking-wider text-red-700">{title}</h4>
          <p className="text-xs text-red-600 mt-0.5">{message}</p>
        </div>
      </div>
      {onRetry && (
        <button
          onClick={onRetry}
          className="inline-flex items-center space-x-1.5 px-3 py-1.5 text-xs font-bold text-red-700 bg-red-100 hover:bg-red-200 border border-red-300 rounded-xl transition shrink-0 cursor-pointer"
        >
          <RefreshCw className="w-3.5 h-3.5" />
          <span>Retry Connection</span>
        </button>
      )}
    </div>
  );
};
