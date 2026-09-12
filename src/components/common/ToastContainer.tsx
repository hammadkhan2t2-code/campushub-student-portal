import React from 'react';
import { CheckCircle2, AlertCircle, Info, X, AlertTriangle } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const ToastContainer: React.FC = () => {
  const { toasts, removeToast } = useApp();

  if (toasts.length === 0) return null;

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none">
      {toasts.map((toast) => {
        let icon = <CheckCircle2 size={18} className="text-emerald-500 shrink-0" />;
        let borderColor = 'border-emerald-200';
        let bgStyle = 'bg-white';

        if (toast.type === 'error') {
          icon = <AlertCircle size={18} className="text-rose-500 shrink-0" />;
          borderColor = 'border-rose-200';
        } else if (toast.type === 'warning') {
          icon = <AlertTriangle size={18} className="text-amber-500 shrink-0" />;
          borderColor = 'border-amber-200';
        } else if (toast.type === 'info') {
          icon = <Info size={18} className="text-sky-500 shrink-0" />;
          borderColor = 'border-sky-200';
        }

        return (
          <div
            key={toast.id}
            className={`pointer-events-auto flex items-start gap-3 p-3.5 rounded-2xl shadow-xl border ${borderColor} ${bgStyle} text-slate-900 transition-all animate-in slide-in-from-bottom-3 duration-200`}
          >
            <div className="pt-0.5">{icon}</div>
            <div className="flex-1 min-w-0">
              <p className="text-xs font-bold text-slate-900">{toast.title}</p>
              <p className="text-[11px] text-slate-600 mt-0.5 leading-snug">{toast.message}</p>
            </div>
            <button
              onClick={() => removeToast(toast.id)}
              className="text-slate-400 hover:text-slate-600 p-0.5 shrink-0"
              aria-label="Dismiss toast"
            >
              <X size={14} />
            </button>
          </div>
        );
      })}
    </div>
  );
};
