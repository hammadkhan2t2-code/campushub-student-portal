import React from 'react';
import { Database, AlertTriangle, RefreshCw, ServerOff } from 'lucide-react';
import { useApp } from '../../context/AppContext';

export const DatabaseErrorBanner: React.FC = () => {
  const { isDbConnected, dataError, refreshData, isLoadingData } = useApp();

  if (isDbConnected && !dataError) {
    return null;
  }

  return (
    <div className="mb-6 bg-red-50 border border-red-200 rounded-2xl p-4 sm:p-5 shadow-sm">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-red-100 text-red-600 flex items-center justify-center shrink-0 mt-0.5">
            <ServerOff size={20} />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-bold text-red-900">
                Database Connection Error
              </h3>
              <span className="px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider rounded bg-red-200/80 text-red-800">
                Supabase Offline
              </span>
            </div>
            <p className="text-xs text-red-700 mt-1 max-w-2xl leading-relaxed">
              {dataError || 'Unable to connect to the Supabase database. Local and mock university data have been removed; showing empty database state as required.'}
            </p>
          </div>
        </div>

        <button
          onClick={() => refreshData()}
          disabled={isLoadingData}
          className="px-4 py-2 bg-red-600 hover:bg-red-700 disabled:bg-red-400 text-white text-xs font-bold rounded-xl shadow-sm transition-all flex items-center gap-2 shrink-0 cursor-pointer"
        >
          <RefreshCw size={14} className={isLoadingData ? 'animate-spin' : ''} />
          <span>{isLoadingData ? 'Retrying...' : 'Retry Connection'}</span>
        </button>
      </div>
    </div>
  );
};
