import React from 'react';
import { getProgramPrefix, extractRollNumberSuffix, formatRollNumber } from '../../utils/rollNumberUtils';

interface RollNumberInputProps {
  degree: string;
  value: string; // full roll number or suffix
  onChange: (fullRollNumber: string, suffixOnly: string) => void;
  required?: boolean;
  disabled?: boolean;
  placeholder?: string;
  className?: string;
  id?: string;
}

/**
 * RollNumberInput displays an uneditable program prefix badge (determined automatically
 * by the selected degree/program: BSCS, BSAI, BSSE) alongside a focused input for the
 * actual roll number portion (e.g. 25-048).
 */
export const RollNumberInput: React.FC<RollNumberInputProps> = ({
  degree,
  value,
  onChange,
  required = true,
  disabled = false,
  placeholder = '25-048',
  className = '',
  id
}) => {
  const prefix = getProgramPrefix(degree);
  const suffix = extractRollNumberSuffix(value);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    let cleanSuffix = e.target.value;
    // If the user pastes or types a prefix, strip it automatically
    cleanSuffix = extractRollNumberSuffix(cleanSuffix);
    const fullValue = cleanSuffix.trim() ? `${prefix}-${cleanSuffix.trim()}` : '';
    onChange(fullValue, cleanSuffix);
  };

  return (
    <div
      className={`flex items-stretch rounded-xl border border-slate-200 bg-slate-50 focus-within:bg-white focus-within:border-[#C5A059] focus-within:ring-2 focus-within:ring-[#C5A059]/30 transition-all overflow-hidden ${
        disabled ? 'opacity-60 cursor-not-allowed' : ''
      } ${className}`}
    >
      {/* Program-specific Prefix Badge (Determined automatically) */}
      <span
        title={`Prefix automatically determined by ${degree}`}
        className="inline-flex items-center px-3 sm:px-3.5 py-2 bg-slate-200/90 text-slate-900 font-mono font-bold text-xs sm:text-sm border-r border-slate-200 select-none tracking-wider shrink-0"
      >
        {prefix}
      </span>

      {/* Actual Roll Number Portion Input */}
      <input
        id={id}
        type="text"
        required={required}
        disabled={disabled}
        value={suffix}
        onChange={handleInputChange}
        placeholder={placeholder}
        className="w-full px-3 py-2 bg-transparent text-slate-900 font-mono font-semibold text-xs sm:text-sm outline-none placeholder:text-slate-400 placeholder:font-normal placeholder:font-sans"
      />
    </div>
  );
};
