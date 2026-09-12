import React, { useState } from 'react';
import {
  X,
  ShieldCheck,
  PackageSearch,
  CheckCircle2,
  AlertCircle,
  Phone,
  Mail,
  FileText,
  Users
} from 'lucide-react';
import { LostFoundItem } from '../../types';
import { useAuth } from '../../context/AuthContext';
import { useApp } from '../../context/AppContext';
import { RollNumberInput } from '../common/RollNumberInput';
import { LOST_FOUND_CONTACT_CONFIG } from '../../utils/lostFoundContact';
import { formatRollNumber } from '../../utils/rollNumberUtils';

interface ClaimItemModalProps {
  item: LostFoundItem;
  onClose: () => void;
}

export const ClaimItemModal: React.FC<ClaimItemModalProps> = ({ item, onClose }) => {
  const { currentUser } = useAuth();
  const { claimItem } = useApp();

  const [studentName, setStudentName] = useState(
    currentUser ? `${currentUser.firstName} ${currentUser.lastName}` : ''
  );
  const [degree, setDegree] = useState(currentUser?.degree || 'BS Computer Science');
  const [rollNumber, setRollNumber] = useState(
    currentUser ? formatRollNumber(currentUser.rollNumber, currentUser.degree) : ''
  );
  const [email, setEmail] = useState(currentUser?.email || '');
  const [contact, setContact] = useState(
    currentUser?.phone || `Email: ${currentUser?.email || ''} • ${LOST_FOUND_CONTACT_CONFIG.instruction}`
  );
  const [claimNote, setClaimNote] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!studentName.trim() || !rollNumber.trim() || !claimNote.trim()) {
      setError('Please provide your name, roll number, and ownership proof details.');
      return;
    }

    const formattedRoll = formatRollNumber(rollNumber, degree);

    claimItem(item.id, {
      claimedBy: studentName.trim(),
      claimedByRoll: formattedRoll,
      claimedByEmail: email.trim().toLowerCase(),
      claimNote: claimNote.trim(),
      contact: contact.trim() || LOST_FOUND_CONTACT_CONFIG.instruction,
      claimedAt: new Date().toISOString()
    });

    onClose();
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-6 overflow-y-auto animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col my-auto animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-[#0F172A] text-white p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-[#C5A059] text-[#0F172A] flex items-center justify-center font-bold shadow-md">
                <ShieldCheck size={22} />
              </div>
              <div>
                <h2 className="text-base font-bold tracking-tight">Declare Item Ownership</h2>
                <p className="text-xs text-slate-400">Campus Verification & Claim Workflow</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-1.5 rounded-full text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            >
              <X size={18} />
            </button>
          </div>

          {/* Item Preview Pill */}
          <div className="mt-4 p-3 rounded-2xl bg-slate-800/80 border border-slate-700 text-xs flex items-center justify-between">
            <div>
              <span className="text-[10px] uppercase font-bold text-[#C5A059] block">
                Item to Claim
              </span>
              <p className="font-bold text-white text-sm">{item.itemName}</p>
              <p className="text-slate-400 text-[11px] mt-0.5">Found at {item.location}</p>
            </div>
            <span className="px-2 py-1 rounded bg-amber-500/20 text-amber-200 font-semibold text-[11px]">
              {item.status}
            </span>
          </div>
        </div>

        {/* Claim Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
              {error}
            </div>
          )}

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Your Full Name *
              </label>
              <input
                type="text"
                required
                value={studentName}
                onChange={(e) => setStudentName(e.target.value)}
                placeholder="e.g. Full Name"
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Roll Number *
              </label>
              <RollNumberInput
                degree={degree}
                value={rollNumber}
                onChange={(fullRoll) => setRollNumber(fullRoll)}
                placeholder="e.g. 25-001"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Campus Email *
              </label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="student@campushub.pk"
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Assistance / Contact Info *
              </label>
              <input
                type="text"
                required
                value={contact}
                onChange={(e) => setContact(e.target.value)}
                placeholder="Email or Contact Your CR"
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Proof of Ownership / Distinctive Features *
            </label>
            <textarea
              required
              rows={3}
              value={claimNote}
              onChange={(e) => setClaimNote(e.target.value)}
              placeholder="Describe unique details only the true owner would know: e.g. serial numbers, specific stickers, contents inside, lock screen image, scratch marks..."
              className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none resize-none"
            />
            <p className="text-[11px] text-slate-400 mt-1">
              This verification statement is shared with the finder / security desk before releasing the item.
            </p>
          </div>

          {/* Action Buttons */}
          <div className="pt-2 flex items-center justify-end gap-2 border-t border-slate-100">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition-all"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center gap-1.5"
            >
              <ShieldCheck size={14} className="text-[#C5A059]" />
              <span>Submit &quot;This is Mine&quot; Claim</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
