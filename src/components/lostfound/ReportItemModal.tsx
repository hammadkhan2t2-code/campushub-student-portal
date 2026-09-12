import React, { useState } from 'react';
import {
  X,
  PackageSearch,
  Upload,
  Calendar,
  Clock,
  MapPin,
  DoorOpen,
  Phone,
  Image as ImageIcon,
  Check,
  AlertCircle
} from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { useAuth } from '../../context/AuthContext';
import { ItemCategory, ItemType, LostFoundItem } from '../../types';
import { ROOMS } from '../../data/mockData';
import { formatRoomDisplay } from '../../utils/roomUtils';
import { LOST_FOUND_CONTACT_CONFIG } from '../../utils/lostFoundContact';

interface ReportItemModalProps {
  initialType?: ItemType;
  onClose: () => void;
}

const CATEGORIES: ItemCategory[] = [
  'Electronics',
  'IDs & Cards',
  'Books & Stationery',
  'Keys & Wallets',
  'Accessories',
  'Other'
];

export const ReportItemModal: React.FC<ReportItemModalProps> = ({
  initialType = 'lost',
  onClose
}) => {
  const { addLostFoundItem } = useApp();
  const { currentUser } = useAuth();

  const [type, setType] = useState<ItemType>(initialType);
  const [itemName, setItemName] = useState('');
  const [category, setCategory] = useState<ItemCategory>('Electronics');
  const [description, setDescription] = useState('');
  const [location, setLocation] = useState('');
  const [room, setRoom] = useState('CS-101');
  const [date, setDate] = useState(() => new Date().toISOString().split('T')[0]);
  const [approximateTime, setApproximateTime] = useState('11:00 AM');
  const [contactMethod, setContactMethod] = useState(
    currentUser ? `Email: ${currentUser.email} • ${LOST_FOUND_CONTACT_CONFIG.instruction}` : LOST_FOUND_CONTACT_CONFIG.instruction
  );
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [error, setError] = useState('');

  // Handle local file image upload
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 2 * 1024 * 1024) {
        setError('Image file is too large (max 2MB).');
        return;
      }
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!itemName.trim() || !description.trim() || !location.trim()) {
      setError('Please fill in the item name, description, and location.');
      return;
    }

    addLostFoundItem({
      type,
      itemName: itemName.trim(),
      category,
      description: description.trim(),
      location: location.trim(),
      room: room.trim() || undefined,
      date,
      approximateTime,
      imageUrl: imagePreview || undefined,
      contactMethod: contactMethod.trim() || undefined,
      reportedBy: currentUser ? `${currentUser.firstName} ${currentUser.lastName}` : 'Campus Student',
      reportedByEmail: currentUser?.email || 'student@campushub.pk',
      status: type === 'lost' ? 'Lost' : 'Found'
    });

    onClose();
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-6 overflow-y-auto animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="w-full max-w-xl bg-white rounded-3xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col max-h-[90vh] my-auto animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header Ribbon with Mode Switcher */}
        <div className="bg-[#0F172A] text-white p-6 pb-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-[#C5A059] text-[#0F172A] flex items-center justify-center font-bold">
                <PackageSearch size={18} />
              </div>
              <h2 className="text-base font-bold tracking-tight">
                Campus Lost & Found Notice
              </h2>
            </div>
            <button
              onClick={onClose}
              className="p-1.5 rounded-full text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            >
              <X size={18} />
            </button>
          </div>

          {/* Workflow Toggle Buttons: Report Lost vs Report Found */}
          <div className="grid grid-cols-2 gap-2 bg-slate-900/90 p-1 rounded-xl border border-slate-800 text-xs font-bold">
            <button
              type="button"
              onClick={() => setType('lost')}
              className={`py-2 rounded-lg transition-all flex items-center justify-center gap-1.5 ${
                type === 'lost'
                  ? 'bg-rose-700 text-white shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <span>Report Lost Item</span>
            </button>
            <button
              type="button"
              onClick={() => setType('found')}
              className={`py-2 rounded-lg transition-all flex items-center justify-center gap-1.5 ${
                type === 'found'
                  ? 'bg-emerald-700 text-white shadow-sm'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <span>Report Found Item</span>
            </button>
          </div>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4 overflow-y-auto">
          {error && (
            <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-medium">
              {error}
            </div>
          )}

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Item Name *
              </label>
              <input
                type="text"
                required
                value={itemName}
                onChange={(e) => setItemName(e.target.value)}
                placeholder={type === 'lost' ? 'e.g. Casio fx-991EX Calculator' : 'e.g. Leather Wallet with ID'}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Category *
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value as ItemCategory)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              >
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Description * (Specific details, color, markings)
            </label>
            <textarea
              required
              rows={2}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Describe distinctive stickers, brand model, condition, or identifiers..."
              className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none resize-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Campus Location *
              </label>
              <input
                type="text"
                required
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. Takbeer Block 1st floor corridor"
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Classroom / Room Number (Optional)
              </label>
              <select
                value={room}
                onChange={(e) => setRoom(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              >
                <option value="">None / Open Area</option>
                {ROOMS.map((r) => (
                  <option key={r.id} value={r.roomNumber}>
                    {formatRoomDisplay(r.roomNumber)} ({r.building.split(' ')[0]})
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Date *
              </label>
              <input
                type="date"
                required
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Approximate Time *
              </label>
              <input
                type="text"
                required
                value={approximateTime}
                onChange={(e) => setApproximateTime(e.target.value)}
                placeholder="e.g. 10:30 AM or during 2nd period"
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
              />
            </div>
          </div>

          {/* Contact Method (Required for Lost, or Where item was deposited for Found) */}
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              {type === 'lost' ? 'Owner Contact / Assistance Instruction *' : 'Handover / Deposit Location or Assistance *'}
            </label>
            <input
              type="text"
              required
              value={contactMethod}
              onChange={(e) => setContactMethod(e.target.value)}
              placeholder={
                type === 'lost'
                  ? 'e.g. Email student@campushub.pk or Contact Your CR'
                  : 'e.g. Deposited with CS Security Counter • Contact Your CR'
              }
              className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            />
            <p className="text-[11px] text-slate-500 mt-1">
              Assistance protocol: Coordinate handovers and verifications through your Class Representative (<strong>{LOST_FOUND_CONTACT_CONFIG.instruction}</strong>).
            </p>
          </div>

          {/* Image Upload Area */}
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Image Attachment (Optional)
            </label>
            <div className="flex items-center gap-3">
              <label className="flex-1 border-2 border-dashed border-slate-200 hover:border-[#C5A059] rounded-2xl p-3 text-center cursor-pointer transition-colors bg-slate-50/50 hover:bg-slate-50 flex items-center justify-center gap-2">
                <Upload size={16} className="text-[#C5A059]" />
                <span className="text-xs font-semibold text-slate-700">
                  {imagePreview ? 'Change Selected Image' : 'Select Image from Device'}
                </span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="hidden"
                />
              </label>

              {imagePreview && (
                <div className="relative w-12 h-12 rounded-xl overflow-hidden border border-slate-200 shrink-0">
                  <img
                    src={imagePreview}
                    alt="Preview"
                    className="w-full h-full object-cover"
                  />
                  <button
                    type="button"
                    onClick={() => setImagePreview(null)}
                    className="absolute top-0 right-0 bg-rose-600 text-white rounded-bl p-0.5"
                  >
                    <X size={10} />
                  </button>
                </div>
              )}
            </div>
          </div>

          {/* Form Actions */}
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
              className={`px-5 py-2 text-white rounded-xl text-xs font-bold shadow-md transition-all ${
                type === 'lost'
                  ? 'bg-rose-700 hover:bg-rose-800'
                  : 'bg-emerald-700 hover:bg-emerald-800'
              }`}
            >
              Publish {type === 'lost' ? 'Lost Item Report' : 'Found Item Notice'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
