import React, { useState } from 'react';
import {
  PackageSearch,
  Search,
  PlusCircle,
  Filter,
  MapPin,
  Calendar,
  Clock,
  User,
  ShieldCheck,
  CheckCircle2,
  AlertCircle,
  Tag,
  Check,
  Phone,
  DoorOpen,
  Users,
  MessageSquare
} from 'lucide-react';
import { useApp } from '../../context/AppContext';
import { useAuth } from '../../context/AuthContext';
import { LostFoundItem, ItemType, LostFoundStatus, ItemCategory } from '../../types';
import { ReportItemModal } from './ReportItemModal';
import { ClaimItemModal } from './ClaimItemModal';
import { formatRoomDisplay } from '../../utils/roomUtils';
import { LOST_FOUND_CONTACT_CONFIG, getLostFoundContactDisplay } from '../../utils/lostFoundContact';
import { formatRollNumber } from '../../utils/rollNumberUtils';

export const LostFoundPage: React.FC = () => {
  const {
    lostFoundItems,
    selectedItemForClaim,
    setSelectedItemForClaim,
    updateItemStatus
  } = useApp();
  const { currentUser } = useAuth();

  // State
  const [activeTabFilter, setActiveTabFilter] = useState<'all' | 'lost' | 'found' | 'my-items'>('all');
  const [statusFilter, setStatusFilter] = useState<string>('All');
  const [categoryFilter, setCategoryFilter] = useState<string>('All');
  const [searchQuery, setSearchQuery] = useState('');

  // Modals
  const [isReportModalOpen, setIsReportModalOpen] = useState(false);
  const [reportModalType, setReportModalType] = useState<ItemType>('lost');

  const openReportModal = (type: ItemType) => {
    setReportModalType(type);
    setIsReportModalOpen(true);
  };

  const filteredItems = lostFoundItems.filter((item) => {
    // Tab filter
    if (activeTabFilter === 'lost' && item.type !== 'lost') return false;
    if (activeTabFilter === 'found' && item.type !== 'found') return false;
    if (activeTabFilter === 'my-items') {
      const isMyReport =
        currentUser?.email &&
        item.reportedByEmail?.toLowerCase() === currentUser.email.toLowerCase();
      const isMyClaim =
        currentUser?.email &&
        item.claimRecord?.claimedByEmail?.toLowerCase() === currentUser.email.toLowerCase();
      if (!isMyReport && !isMyClaim) return false;
    }

    // Status filter
    if (statusFilter !== 'All' && item.status !== statusFilter) return false;

    // Category filter
    if (categoryFilter !== 'All' && item.category !== categoryFilter) return false;

    // Search query
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const match =
        item.itemName.toLowerCase().includes(q) ||
        item.description.toLowerCase().includes(q) ||
        item.location.toLowerCase().includes(q) ||
        (item.room && item.room.toLowerCase().includes(q)) ||
        item.category.toLowerCase().includes(q);
      if (!match) return false;
    }

    return true;
  });

  const getStatusBadge = (status: LostFoundStatus) => {
    switch (status) {
      case 'Lost':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-rose-100 text-rose-800 border border-rose-200">
            Lost
          </span>
        );
      case 'Found':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-emerald-100 text-emerald-800 border border-emerald-200">
            Found
          </span>
        );
      case 'Claimed':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-purple-100 text-purple-800 border border-purple-200 flex items-center gap-1">
            <ShieldCheck size={12} /> Claimed
          </span>
        );
      case 'Resolved':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider bg-slate-100 text-slate-700 border border-slate-200 flex items-center gap-1">
            <Check size={12} /> Resolved
          </span>
        );
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Top Banner */}
      <div className="bg-white rounded-3xl p-6 sm:p-8 border border-slate-200/80 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-rose-600 mb-1">
            <PackageSearch size={15} />
            <span>Campus Registry & Noticeboard</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-[#0F172A] tracking-tight">
            Lost & Found Desk
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-0.5">
            Report lost belongings, register found items, and claim ownership across campus.
          </p>
        </div>

        {/* The Two Main Required Workflows Buttons */}
        <div className="flex flex-wrap items-center gap-2.5">
          <button
            onClick={() => openReportModal('lost')}
            className="px-4 py-2.5 rounded-xl text-xs font-bold bg-rose-700 hover:bg-rose-800 text-white shadow-sm transition-all flex items-center gap-1.5"
          >
            <PlusCircle size={15} />
            <span>Report Lost Item</span>
          </button>

          <button
            onClick={() => openReportModal('found')}
            className="px-4 py-2.5 rounded-xl text-xs font-bold bg-[#047857] hover:bg-emerald-800 text-white shadow-sm transition-all flex items-center gap-1.5"
          >
            <PlusCircle size={15} />
            <span>Report Found Item</span>
          </button>
        </div>
      </div>

      {/* Assistance Instruction Banner: Contact Your CR */}
      <div className="bg-[#0F172A] text-white rounded-3xl p-5 sm:p-6 border border-slate-800 shadow-sm flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-start sm:items-center gap-3.5">
          <div className="w-11 h-11 rounded-2xl bg-[#C5A059]/20 border border-[#C5A059]/40 text-[#C5A059] flex items-center justify-center shrink-0">
            <Users size={22} />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-[#C5A059]">
                Lost & Found Assistance
              </span>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-slate-800 text-slate-300 border border-slate-700 font-medium">
                Campus Protocol
              </span>
            </div>
            <h2 className="text-base sm:text-lg font-bold text-white mt-0.5">
              Need Assistance With An Item? <span className="text-[#C5A059]">{LOST_FOUND_CONTACT_CONFIG.instruction}</span>
            </h2>
            <p className="text-xs text-slate-300 mt-1 max-w-2xl leading-relaxed">
              If you need assistance regarding a lost or found item, claiming property, or coordinating a handover, please <strong className="text-white underline decoration-[#C5A059] decoration-2 underline-offset-2">{LOST_FOUND_CONTACT_CONFIG.instruction}</strong>. Official Class Representative contact numbers will be updated here soon.
            </p>
          </div>
        </div>

        <div className="px-4 py-3 rounded-2xl bg-slate-800/90 border border-slate-700 text-center sm:text-right shrink-0">
          <span className="text-[10px] uppercase font-bold tracking-wider text-slate-400 block mb-0.5">
            Primary Contact Instruction
          </span>
          <span className="text-sm font-bold text-[#C5A059] flex items-center justify-center sm:justify-end gap-1.5">
            <MessageSquare size={14} />
            <span>{LOST_FOUND_CONTACT_CONFIG.instruction}</span>
          </span>
        </div>
      </div>

      {/* Navigation Filter Toolbar */}
      <div className="bg-white rounded-3xl p-5 border border-slate-200/80 shadow-sm space-y-4">
        {/* Main Tab Switcher */}
        <div className="flex items-center gap-2 overflow-x-auto pb-1">
          <button
            onClick={() => setActiveTabFilter('all')}
            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
              activeTabFilter === 'all'
                ? 'bg-[#0F172A] text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            All Notices ({lostFoundItems.length})
          </button>
          <button
            onClick={() => setActiveTabFilter('lost')}
            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
              activeTabFilter === 'lost'
                ? 'bg-rose-700 text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            Lost Items ({lostFoundItems.filter((i) => i.type === 'lost').length})
          </button>
          <button
            onClick={() => setActiveTabFilter('found')}
            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
              activeTabFilter === 'found'
                ? 'bg-[#047857] text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            Found Items ({lostFoundItems.filter((i) => i.type === 'found').length})
          </button>
          <button
            onClick={() => setActiveTabFilter('my-items')}
            className={`px-4 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all ${
              activeTabFilter === 'my-items'
                ? 'bg-[#0F172A] text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            My Submissions & Claims
          </button>
        </div>

        {/* Secondary Filter Controls */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2 border-t border-slate-100">
          {/* Search Bar */}
          <div className="relative">
            <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by item name, room, or location..."
              className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            />
          </div>

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            >
              <option value="All">All Statuses (Lost, Found, Claimed, Resolved)</option>
              <option value="Lost">Status: Lost</option>
              <option value="Found">Status: Found</option>
              <option value="Claimed">Status: Claimed</option>
              <option value="Resolved">Status: Resolved</option>
            </select>
          </div>

          {/* Category Filter */}
          <div>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium text-slate-900 focus:bg-white focus:ring-2 focus:ring-[#C5A059]/30 outline-none"
            >
              <option value="All">All Item Categories</option>
              <option value="Electronics">Electronics</option>
              <option value="IDs & Cards">IDs & Cards</option>
              <option value="Books & Stationery">Books & Stationery</option>
              <option value="Keys & Wallets">Keys & Wallets</option>
              <option value="Accessories">Accessories</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>
      </div>

      {/* Cards Grid */}
      {lostFoundItems.length === 0 ? (
        <div className="bg-white rounded-3xl p-10 sm:p-14 text-center border border-slate-200/80 shadow-sm max-w-xl mx-auto my-4">
          <div className="w-16 h-16 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-4 border border-slate-200/60">
            <PackageSearch size={32} />
          </div>
          <h3 className="text-lg font-bold text-slate-900">No Lost & Found Items Yet</h3>
          <p className="text-xs sm:text-sm text-slate-500 mt-2 max-w-md mx-auto leading-relaxed">
            Lost something or found an item on campus? Create a listing to help reunite it with its owner.
          </p>
          <div className="mt-6 flex flex-wrap items-center justify-center gap-3">
            <button
              onClick={() => openReportModal('lost')}
              className="px-4 py-2.5 rounded-xl text-xs font-bold bg-rose-700 hover:bg-rose-800 text-white shadow-sm transition-all flex items-center gap-1.5"
            >
              <PlusCircle size={15} />
              <span>Report Lost Item</span>
            </button>
            <button
              onClick={() => openReportModal('found')}
              className="px-4 py-2.5 rounded-xl text-xs font-bold bg-[#047857] hover:bg-emerald-800 text-white shadow-sm transition-all flex items-center gap-1.5"
            >
              <PlusCircle size={15} />
              <span>Report Found Item</span>
            </button>
          </div>
          <div className="mt-6 pt-5 border-t border-slate-100 text-xs text-slate-500 flex items-center justify-center gap-1.5">
            <MessageSquare size={13} className="text-[#C5A059]" />
            <span>Need assistance? <strong className="text-slate-800 font-semibold">{LOST_FOUND_CONTACT_CONFIG.instruction}</strong></span>
          </div>
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="bg-white rounded-3xl p-12 text-center border border-slate-200/80 shadow-sm">
          <div className="w-14 h-14 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3">
            <PackageSearch size={28} />
          </div>
          <h3 className="text-base font-bold text-slate-900">No items match your query</h3>
          <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
            Try adjusting your search terms or filters. You can also publish a new lost or found notice above.
          </p>
          <div className="mt-4 flex items-center justify-center gap-2">
            <button
              onClick={() => {
                setActiveTabFilter('all');
                setStatusFilter('All');
                setCategoryFilter('All');
                setSearchQuery('');
              }}
              className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold transition-all"
            >
              Clear Filters
            </button>
            <button
              onClick={() => openReportModal('lost')}
              className="px-4 py-2 bg-[#0F172A] hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all"
            >
              Report an Item
            </button>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredItems.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-3xl border border-slate-200/80 hover:border-slate-300 shadow-sm hover:shadow-md transition-all flex flex-col justify-between overflow-hidden group"
            >
              <div className="p-6">
                {/* Header with Type, Category, and Status */}
                <div className="flex items-center justify-between gap-2 mb-3">
                  <div className="flex items-center gap-1.5">
                    <span
                      className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                        item.type === 'lost'
                          ? 'bg-rose-50 text-rose-700 border border-rose-200'
                          : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                      }`}
                    >
                      {item.type}
                    </span>
                    <span className="text-[10px] font-semibold text-slate-500 bg-slate-100 px-2 py-0.5 rounded-md">
                      {item.category}
                    </span>
                  </div>

                  {getStatusBadge(item.status)}
                </div>

                {/* Item Name & Optional Image Preview */}
                <h3 className="text-base font-bold text-slate-900 group-hover:text-indigo-950 mb-2">
                  {item.itemName}
                </h3>

                {item.imageUrl && (
                  <div className="w-full h-36 rounded-2xl overflow-hidden mb-3 border border-slate-200 bg-slate-50">
                    <img
                      src={item.imageUrl}
                      alt={item.itemName}
                      className="w-full h-full object-cover"
                    />
                  </div>
                )}

                <p className="text-xs text-slate-600 line-clamp-3 mb-4 leading-relaxed">
                  {item.description}
                </p>

                {/* Location, Room, and Date Info */}
                <div className="space-y-1.5 text-xs text-slate-500 bg-slate-50/80 p-3 rounded-2xl border border-slate-100 mb-4">
                  <div className="flex items-center gap-2">
                    <MapPin size={13} className="text-slate-400 shrink-0" />
                    <span className="truncate">{item.location}</span>
                  </div>
                  {item.room && (
                    <div className="flex items-center gap-2">
                      <DoorOpen size={13} className="text-[#C5A059] shrink-0" />
                      <span><strong className="text-slate-700">{formatRoomDisplay(item.room)}</strong></span>
                    </div>
                  )}
                  <div className="flex items-center justify-between text-[11px] pt-1 border-t border-slate-200/50">
                    <span className="flex items-center gap-1">
                      <Calendar size={12} className="text-slate-400" />
                      <span>{item.date}</span>
                    </span>
                    <span className="flex items-center gap-1">
                      <Clock size={12} className="text-slate-400" />
                      <span>{item.approximateTime}</span>
                    </span>
                  </div>
                </div>

                {/* Reporter / Contact Info */}
                <div className="text-[11px] text-slate-600 mb-2 p-2.5 rounded-xl bg-slate-50 border border-slate-100 flex items-start gap-2">
                  <span className="text-slate-400 mt-0.5"><Users size={13} /></span>
                  <div>
                    <strong className="text-slate-800">Assistance / Contact: </strong>
                    <span className="text-slate-600 font-medium">
                      {getLostFoundContactDisplay(item.contactMethod)}
                    </span>
                  </div>
                </div>

                {/* Claim Record Box if already claimed */}
                {item.claimRecord && (
                  <div className="p-3 rounded-2xl bg-purple-50 border border-purple-200 text-xs text-purple-900 mt-2">
                    <p className="font-bold flex items-center gap-1">
                      <ShieldCheck size={13} />
                      Claim Filed by {item.claimRecord.claimedBy} ({formatRollNumber(item.claimRecord.claimedByRoll)})
                    </p>
                    <p className="text-[11px] text-purple-800 mt-1 italic">
                      &quot;{item.claimRecord.claimNote}&quot;
                    </p>
                  </div>
                )}
              </div>

              {/* Action Footer */}
              <div className="p-4 bg-slate-50 border-t border-slate-100 flex items-center justify-between gap-2">
                <span className="text-[11px] text-slate-400">
                  By {item.reportedBy}
                </span>

                <div className="flex items-center gap-2">
                  {item.status !== 'Resolved' && (
                    <>
                      {/* "This is mine" claim action */}
                      <button
                        onClick={() => setSelectedItemForClaim(item)}
                        className="px-3 py-1.5 rounded-xl bg-[#0F172A] hover:bg-slate-800 text-white text-xs font-bold transition-all shadow-sm flex items-center gap-1"
                        title="Report that you believe this item belongs to you"
                      >
                        <ShieldCheck size={13} className="text-[#C5A059]" />
                        <span>This is mine</span>
                      </button>

                      {/* Quick status resolution if claimed or found */}
                      <button
                        onClick={() => updateItemStatus(item.id, 'Resolved')}
                        className="p-1.5 rounded-xl text-slate-400 hover:text-emerald-700 hover:bg-emerald-50 transition-colors"
                        title="Mark item as Resolved"
                      >
                        <Check size={16} />
                      </button>
                    </>
                  )}

                  {item.status === 'Resolved' && (
                    <span className="text-xs font-semibold text-slate-500 flex items-center gap-1">
                      <CheckCircle2 size={13} className="text-emerald-600" />
                      Case Closed
                    </span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Report Modal */}
      {isReportModalOpen && (
        <ReportItemModal
          initialType={reportModalType}
          onClose={() => setIsReportModalOpen(false)}
        />
      )}

      {/* Claim Modal */}
      {selectedItemForClaim && (
        <ClaimItemModal
          item={selectedItemForClaim}
          onClose={() => setSelectedItemForClaim(null)}
        />
      )}
    </div>
  );
};
