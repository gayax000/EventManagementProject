import React, { useState, useEffect } from 'react';
import { ShieldCheck, CheckCircle, XCircle, Briefcase, Building2, Phone, Search, Tag, Sparkles, Eye, Trash2, X, RefreshCw, Car, Camera, Volume2, Cake, Utensils, Tent, Zap, Store } from 'lucide-react';
import { vendorService } from '../services/api';

const VENDOR_CATEGORIES = [
  { id: 'All', label: 'All', icon: '🏪' },
  { id: 'SoundLighting', label: 'Sound & Lighting', icon: '🔊' },
  { id: 'Decor', label: 'Decor & Stage', icon: '🌸' },
  { id: 'Photography', label: 'Photography', icon: '📸' },
  { id: 'Cake', label: 'Cakes', icon: '🎂' },
  { id: 'Transport', label: 'VIP Transport', icon: '🚗' },
  { id: 'Catering', label: 'Catering Buffets', icon: '🍽️' },
  { id: 'MarqueeTent', label: 'Tents & Safeguards', icon: '🎪' },
  { id: 'PowerBackup', label: 'Power Backup', icon: '⚡' },
];

const matchesCategoryFilter = (vendorCat?: string, filterId: string = 'All') => {
  if (!filterId || filterId === 'All') return true;
  if (!vendorCat) return false;
  const v = vendorCat.toLowerCase().trim();
  const f = filterId.toLowerCase().trim();

  if (f.includes('photo')) return v.includes('photo');
  if (f.includes('cake')) return v.includes('cake');
  if (f.includes('transport') || f.includes('car') || f.includes('vip')) return v.includes('transport') || v.includes('car') || v.includes('vehicle') || v.includes('vip');
  if (f.includes('sound') || f.includes('audio') || f.includes('light')) return v.includes('sound') || v.includes('audio') || v.includes('light');
  if (f.includes('cater') || f.includes('food') || f.includes('buffet')) return v.includes('cater') || v.includes('food') || v.includes('buffet');
  if (f.includes('decor') || f.includes('flower') || f.includes('floral')) return v.includes('decor') || v.includes('flower') || v.includes('floral');
  if (f.includes('tent') || f.includes('marquee') || f.includes('weather')) return v.includes('tent') || v.includes('marquee') || v.includes('weather');
  if (f.includes('power') || f.includes('gen')) return v.includes('power') || v.includes('gen');

  return v === f;
};

const getCategoryBadge = (vendorCat?: string) => {
  if (!vendorCat) return { label: 'General', icon: '🏪' };
  const v = vendorCat.toLowerCase().trim();
  if (v.includes('photo')) return { label: 'Photography', icon: '📸' };
  if (v.includes('cake')) return { label: 'Cakes & Desserts', icon: '🎂' };
  if (v.includes('transport') || v.includes('car') || v.includes('vip')) return { label: 'VIP Transport', icon: '🚗' };
  if (v.includes('sound') || v.includes('audio') || v.includes('light')) return { label: 'Sound & Lighting', icon: '🔊' };
  if (v.includes('cater') || v.includes('food') || v.includes('buffet')) return { label: 'Catering Buffets', icon: '🍽️' };
  if (v.includes('decor') || v.includes('flower') || v.includes('floral')) return { label: 'Decor & Stage', icon: '🌸' };
  if (v.includes('tent') || v.includes('marquee') || v.includes('weather')) return { label: 'Tents & Safeguards', icon: '🎪' };
  if (v.includes('power') || v.includes('gen')) return { label: 'Power Backup', icon: '⚡' };
  return { label: vendorCat, icon: '📦' };
};

const getCategoryIconBadge = (vendorCat?: string) => {
  let Icon = Store;
  let bg = 'bg-indigo-50';
  let text = 'text-indigo-600';
  let border = 'border-indigo-200';

  if (vendorCat) {
    const v = vendorCat.toLowerCase().trim();
    if (v.includes('photo')) {
      Icon = Camera;
      bg = 'bg-sky-50';
      text = 'text-sky-600';
      border = 'border-sky-200';
    } else if (v.includes('cake')) {
      Icon = Cake;
      bg = 'bg-rose-50';
      text = 'text-rose-600';
      border = 'border-rose-200';
    } else if (v.includes('transport') || v.includes('car') || v.includes('vip')) {
      Icon = Car;
      bg = 'bg-purple-50';
      text = 'text-purple-600';
      border = 'border-purple-200';
    } else if (v.includes('sound') || v.includes('audio') || v.includes('light')) {
      Icon = Volume2;
      bg = 'bg-amber-50';
      text = 'text-amber-600';
      border = 'border-amber-200';
    } else if (v.includes('cater') || v.includes('food') || v.includes('buffet')) {
      Icon = Utensils;
      bg = 'bg-emerald-50';
      text = 'text-emerald-600';
      border = 'border-emerald-200';
    } else if (v.includes('decor') || v.includes('flower') || v.includes('floral')) {
      Icon = Sparkles;
      bg = 'bg-pink-50';
      text = 'text-pink-600';
      border = 'border-pink-200';
    } else if (v.includes('tent') || v.includes('marquee') || v.includes('weather')) {
      Icon = Tent;
      bg = 'bg-blue-50';
      text = 'text-blue-600';
      border = 'border-blue-200';
    } else if (v.includes('power') || v.includes('gen')) {
      Icon = Zap;
      bg = 'bg-yellow-50';
      text = 'text-yellow-600';
      border = 'border-yellow-200';
    }
  }

  return {
    Icon,
    bg,
    text,
    border,
  };
};

export const VendorsPage: React.FC = () => {
  const [vendors, setVendors] = useState<any[]>(() => {
    try {
      const saved = localStorage.getItem('eventcraft_system_vendors_v2');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });
  const [loading, setLoading] = useState(false);
  const [selectedVendorForView, setSelectedVendorForView] = useState<any | null>(null);
  const [deleteVendorModal, setDeleteVendorModal] = useState<{
    id: string;
    name: string;
    isDeleting: boolean;
  } | null>(null);
  
  // Separate states for Pending list
  const [pendingSearch, setPendingSearch] = useState('');
  const [pendingCategory, setPendingCategory] = useState('All');

  // Separate states for Confirmed list
  const [confirmedSearch, setConfirmedSearch] = useState('');
  const [confirmedCategory, setConfirmedCategory] = useState('All');

  const fetchVendors = async () => {
    try {
      setLoading(true);
      const data = await vendorService.getVendors();
      if (Array.isArray(data)) {
        const mapped = data.map(v => ({
          ...v,
          id: v.vendorId || v.id,
          name: v.businessName || v.name,
          contactNumber: v.contactNumber || v.contact,
          status: v.verificationStatus || v.status,
          category: v.category,
          adminRemarks: v.adminRemarks,
          packageName: v.packageName,
          packagePrice: v.packagePrice
        }));
        
        setVendors(mapped);
        localStorage.setItem('eventcraft_system_vendors_v2', JSON.stringify(mapped));
      }
    } catch (err) {
      console.error("Failed to fetch vendors from API, using cached state", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVendors();
    const interval = setInterval(fetchVendors, 5000); // Live sync every 5 seconds
    return () => clearInterval(interval);
  }, []);

  const handleVerifyVendor = async (id: string, newStatus: 'Verified' | 'Rejected') => {
    const updated = vendors.map(v => v.id === id ? { ...v, status: newStatus } : v);
    setVendors(updated);
    try {
      localStorage.setItem('eventcraft_system_vendors_v2', JSON.stringify(updated));
      await vendorService.verifyVendor(id, newStatus);
      await fetchVendors();
    } catch (e) {
      console.warn("Backend verifyVendor call warning", e);
    }
  };

  const handleDeleteVendor = (id: string, name: string) => {
    setDeleteVendorModal({ id, name, isDeleting: false });
  };

  const confirmDeleteVendor = async () => {
    if (!deleteVendorModal) return;
    setDeleteVendorModal(prev => prev ? { ...prev, isDeleting: true } : null);
    try {
      const updated = vendors.filter(v => v.id !== deleteVendorModal.id);
      setVendors(updated);
      localStorage.setItem('eventcraft_system_vendors_v2', JSON.stringify(updated));
      await vendorService.deleteVendor(deleteVendorModal.id);
      await fetchVendors();
      setDeleteVendorModal(null);
    } catch (e) {
      console.warn("Backend deleteVendor call warning", e);
      setDeleteVendorModal(null);
    }
  };

  // Filter Pending Vendors
  const pendingVendors = vendors.filter(v => {
    if (v.status !== 'Pending') return false;
    const searchLower = pendingSearch.toLowerCase();
    const matchesSearch = (v.name || '').toLowerCase().includes(searchLower) || 
                          (v.contactNumber || v.contact || '').includes(pendingSearch) ||
                          (v.adminRemarks || '').toLowerCase().includes(searchLower);
    const matchesCategory = matchesCategoryFilter(v.category, pendingCategory);
    return matchesSearch && matchesCategory;
  });

  // Filter Confirmed Vendors
  const confirmedVendors = vendors.filter(v => {
    if (v.status !== 'Verified') return false;
    const searchLower = confirmedSearch.toLowerCase();
    const matchesSearch = (v.name || '').toLowerCase().includes(searchLower) || 
                          (v.contactNumber || v.contact || '').includes(confirmedSearch) ||
                          (v.adminRemarks || '').toLowerCase().includes(searchLower);
    const matchesCategory = matchesCategoryFilter(v.category, confirmedCategory);
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header with Dark Luxury Style matching Dashboard & Venues */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4 bg-slate-900 text-white p-6 rounded-2xl shadow-lg border border-slate-800">
        <div>
          <div className="flex items-center space-x-2">
            <span className="text-xs font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-sky-500/20 text-sky-300 border border-sky-500/30 inline-flex items-center space-x-1">
              <ShieldCheck className="w-3.5 h-3.5 mr-1 text-sky-400" />
              Certified Partner & Vendor Directory
            </span>
          </div>
          <h1 className="text-2xl font-black mt-2">Partner & Vendor Management</h1>
          <p className="text-slate-400 text-sm mt-1">Review new vendor applications and manage confirmed business partners across all 8 certified event service categories.</p>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={fetchVendors}
            disabled={loading}
            className="px-3.5 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-xl text-xs font-semibold flex items-center space-x-2 transition cursor-pointer"
            title="Refresh Vendors Queue"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
            <span>Refresh Vendors</span>
          </button>
        </div>
      </div>

      {/* SECTION 1: Pending Verifications */}
      <div className="mb-10 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <ShieldCheck className="w-5 h-5 text-sky-400" />
            <h3 className="font-semibold text-base">Pending Vendor Verification Requests</h3>
          </div>
          <span className="text-xs bg-slate-800 text-slate-300 px-3 py-1 rounded-full border border-slate-700 font-bold">
            {vendors.filter(v => v.status === 'Pending').length} Total Pending
          </span>
        </div>

        {/* Pending Filters */}
        <div className="p-4 bg-slate-50 border-b border-slate-200 space-y-3">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-4 w-4 text-slate-400" />
            </div>
            <input
              type="text"
              placeholder="Search pending requests (name, contact, service package)..."
              value={pendingSearch}
              onChange={(e) => setPendingSearch(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-slate-300 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-sky-500 bg-white shadow-sm"
            />
          </div>
          <div className="flex overflow-x-auto space-x-2 pb-1 scrollbar-hide">
            {VENDOR_CATEGORIES.map(cat => {
              const count = cat.id === 'All' 
                ? vendors.filter(v => v.status === 'Pending').length
                : vendors.filter(v => v.status === 'Pending' && matchesCategoryFilter(v.category, cat.id)).length;
              return (
                <button
                  key={cat.id}
                  onClick={() => setPendingCategory(cat.id)}
                  className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg border text-xs font-medium whitespace-nowrap transition-colors ${
                    pendingCategory === cat.id 
                      ? 'bg-slate-900 text-white border-slate-900 shadow-sm' 
                      : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-100'
                  }`}
                >
                  <span>{cat.label}</span>
                  <span className={`text-[10px] px-1.5 py-0.2 rounded-full ${
                    pendingCategory === cat.id ? 'bg-slate-700 text-white' : 'bg-slate-100 text-slate-500'
                  }`}>
                    {count}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        <div className="divide-y divide-slate-200">
          {pendingVendors.length === 0 ? (
            <div className="p-8 text-center text-slate-500 text-sm">
              {pendingSearch || pendingCategory !== 'All' 
                ? 'No pending verification requests match your filter.' 
                : 'No pending verification requests at the moment.'}
            </div>
          ) : (
            pendingVendors.map(vendor => {
              const badge = getCategoryBadge(vendor.category);
              const iconBadge = getCategoryIconBadge(vendor.category);
              const CategoryIcon = iconBadge.Icon;
              return (
                <div key={vendor.id} className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50 transition">
                  <div className="flex items-start space-x-3.5">
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 border ${iconBadge.bg} ${iconBadge.border} ${iconBadge.text} shadow-xs mt-0.5`}>
                      <CategoryIcon className="w-5 h-5 stroke-[2.2]" />
                    </div>
                    <div>
                      <div className="flex items-center space-x-2">
                        <h4 className="font-bold text-slate-900 text-base">{vendor.name}</h4>
                      </div>
                      {(vendor.packageName || vendor.adminRemarks) && (
                        <p className="text-xs text-slate-600 mt-1 font-medium">
                          Package: <span className="text-indigo-600 font-semibold">{vendor.packageName || vendor.adminRemarks}</span>
                          {vendor.packagePrice && (
                            <span className="ml-2 text-slate-900 font-bold">| Rs. {Number(vendor.packagePrice).toLocaleString()}</span>
                          )}
                        </p>
                      )}
                      <div className="flex items-center text-xs text-slate-500 mt-1.5 space-x-3">
                        <span className="flex items-center px-2 py-0.5 bg-slate-100 text-slate-700 font-medium rounded-md">
                          <Tag className="w-3 h-3 mr-1 text-slate-400" /> {badge.label}
                        </span>
                        <span className="flex items-center"><Phone className="w-3.5 h-3.5 mr-1 text-slate-400" /> {vendor.contactNumber || vendor.contact}</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 border border-amber-200">
                      Status: {vendor.status}
                    </span>

                    <div className="flex items-center space-x-2">
                      <button 
                        onClick={() => setSelectedVendorForView(vendor)}
                        className="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-medium flex items-center space-x-1 transition"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4 text-sky-600" />
                        <span>View Details</span>
                      </button>
                      <button 
                        onClick={() => handleVerifyVendor(vendor.id, 'Verified')}
                        className="px-3 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-medium flex items-center space-x-1 shadow-sm transition"
                      >
                        <CheckCircle className="w-4 h-4" />
                        <span>Approve</span>
                      </button>
                      <button 
                        onClick={() => handleVerifyVendor(vendor.id, 'Rejected')}
                        className="px-3 py-2 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 rounded-lg text-xs font-medium flex items-center space-x-1 transition"
                      >
                        <XCircle className="w-4 h-4" />
                        <span>Reject</span>
                      </button>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* SECTION 2: Confirmed Members */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Building2 className="w-5 h-5 text-indigo-600" />
            <h3 className="font-bold text-slate-800 text-base">Confirmed Members (Active Network)</h3>
          </div>
          <span className="text-xs text-slate-500 font-bold">{vendors.filter(v => v.status === 'Verified').length} Verified Partners</span>
        </div>

        {/* Confirmed Filters */}
        <div className="p-4 bg-slate-50 border-b border-slate-200 space-y-3">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-4 w-4 text-slate-400" />
            </div>
            <input
              type="text"
              placeholder="Search confirmed members (name, contact, service package)..."
              value={confirmedSearch}
              onChange={(e) => setConfirmedSearch(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-slate-300 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white shadow-sm"
            />
          </div>
          <div className="flex overflow-x-auto space-x-2 pb-1 scrollbar-hide">
            {VENDOR_CATEGORIES.map(cat => {
              const count = cat.id === 'All'
                ? vendors.filter(v => v.status === 'Verified').length
                : vendors.filter(v => v.status === 'Verified' && matchesCategoryFilter(v.category, cat.id)).length;
              return (
                <button
                  key={cat.id}
                  onClick={() => setConfirmedCategory(cat.id)}
                  className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg border text-xs font-medium whitespace-nowrap transition-colors ${
                    confirmedCategory === cat.id 
                      ? 'bg-indigo-600 text-white border-indigo-600 shadow-sm' 
                      : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-100'
                  }`}
                >
                  <span>{cat.label}</span>
                  <span className={`text-[10px] px-1.5 py-0.2 rounded-full ${
                    confirmedCategory === cat.id ? 'bg-indigo-700 text-white' : 'bg-slate-100 text-slate-500'
                  }`}>
                    {count}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        <div className="divide-y divide-slate-200">
          {confirmedVendors.length === 0 ? (
            <div className="p-8 text-center text-slate-500 text-sm">
              {confirmedSearch || confirmedCategory !== 'All' 
                ? 'No confirmed vendors match your filter.' 
                : 'No confirmed vendors yet.'}
            </div>
          ) : (
            confirmedVendors.map(vendor => {
              const badge = getCategoryBadge(vendor.category);
              const iconBadge = getCategoryIconBadge(vendor.category);
              const CategoryIcon = iconBadge.Icon;
              return (
                <div key={vendor.id} className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50 transition">
                  <div className="flex items-start space-x-3.5">
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 border ${iconBadge.bg} ${iconBadge.border} ${iconBadge.text} shadow-xs mt-0.5`}>
                      <CategoryIcon className="w-5 h-5 stroke-[2.2]" />
                    </div>
                    <div>
                      <div className="flex items-center space-x-2">
                        <h4 className="font-bold text-slate-900 text-base">{vendor.name}</h4>
                      </div>
                      {(vendor.packageName || vendor.adminRemarks) && (
                        <p className="text-xs text-slate-600 mt-1 font-medium">
                          Package: <span className="text-indigo-600 font-semibold">{vendor.packageName || vendor.adminRemarks}</span>
                          {vendor.packagePrice && (
                            <span className="ml-2 text-slate-900 font-bold">| Rs. {Number(vendor.packagePrice).toLocaleString()}</span>
                          )}
                        </p>
                      )}
                      <div className="flex items-center text-xs text-slate-500 mt-1.5 space-x-3">
                        <span className="flex items-center px-2 py-0.5 bg-slate-100 text-slate-700 font-medium rounded-md">
                          <Tag className="w-3 h-3 mr-1 text-slate-400" /> {badge.label}
                        </span>
                        <span className="flex items-center"><Phone className="w-3.5 h-3.5 mr-1 text-slate-400" /> {vendor.contactNumber || vendor.contact}</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
                      Verified
                    </span>

                    <div className="flex items-center space-x-2">
                      <button 
                        onClick={() => setSelectedVendorForView(vendor)}
                        className="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-medium flex items-center space-x-1 transition"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4 text-indigo-600" />
                        <span>View Details</span>
                      </button>
                      <button 
                        onClick={() => handleDeleteVendor(vendor.id, vendor.name)}
                        className="px-3 py-2 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 rounded-lg text-xs font-medium flex items-center space-x-1 transition"
                        title="Delete Vendor"
                      >
                        <Trash2 className="w-4 h-4" />
                        <span>Delete</span>
                      </button>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Vendor Details Modal */}
      {selectedVendorForView && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-100 relative animate-in fade-in zoom-in duration-200">
            <button 
              onClick={() => setSelectedVendorForView(null)}
              className="absolute top-4 right-4 p-1 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 transition"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="flex items-center space-x-3.5 mb-4">
              {(() => {
                const modalIconBadge = getCategoryIconBadge(selectedVendorForView.category);
                const ModalCategoryIcon = modalIconBadge.Icon;
                return (
                  <div className={`w-12 h-12 ${modalIconBadge.bg} border ${modalIconBadge.border} rounded-2xl flex items-center justify-center ${modalIconBadge.text} flex-shrink-0 shadow-xs`}>
                    <ModalCategoryIcon className="w-6 h-6 stroke-[2.2]" />
                  </div>
                );
              })()}
              <div>
                <h3 className="text-lg font-bold text-slate-900">{selectedVendorForView.name}</h3>
                <span className={`inline-block px-2.5 py-0.5 text-xs font-semibold rounded-full mt-0.5 ${
                  selectedVendorForView.status === 'Verified' 
                    ? 'bg-emerald-100 text-emerald-800 border border-emerald-200' 
                    : 'bg-amber-100 text-amber-800 border border-amber-200'
                }`}>
                  Status: {selectedVendorForView.status}
                </span>
              </div>
            </div>

            <div className="space-y-3 text-sm text-slate-600 border-t border-b border-slate-100 py-4 my-4">
              <div>
                <span className="text-xs uppercase tracking-wider font-semibold text-slate-400 block mb-1">Service Category</span>
                <p className="font-medium text-slate-800 flex items-center">
                  <Tag className="w-4 h-4 mr-1.5 text-indigo-500" />
                  {getCategoryBadge(selectedVendorForView.category).label} ({selectedVendorForView.category})
                </p>
              </div>

              <div>
                <span className="text-xs uppercase tracking-wider font-semibold text-slate-400 block mb-1">Contact Number</span>
                <p className="font-medium text-slate-800 flex items-center">
                  <Phone className="w-4 h-4 mr-1.5 text-indigo-500" />
                  {selectedVendorForView.contactNumber || selectedVendorForView.contact || 'N/A'}
                </p>
              </div>

              <div>
                <span className="text-xs uppercase tracking-wider font-semibold text-slate-400 block mb-1">Service Package / Rate</span>
                <div className="font-medium text-slate-800 bg-slate-50 p-3 rounded-lg border border-slate-200/80">
                  <p>{selectedVendorForView.packageName || selectedVendorForView.adminRemarks || 'No additional package details provided.'}</p>
                  {selectedVendorForView.packagePrice && (
                    <p className="mt-1 font-bold text-indigo-600 text-sm">Starting Unit Price: Rs. {Number(selectedVendorForView.packagePrice).toLocaleString()}</p>
                  )}
                </div>
              </div>

              <div>
                <span className="text-xs uppercase tracking-wider font-semibold text-slate-400 block mb-1">System Vendor ID</span>
                <p className="font-mono text-xs text-slate-500 bg-slate-100 px-2.5 py-1 rounded w-max">
                  {selectedVendorForView.id}
                </p>
              </div>
            </div>

            <div className="flex justify-end space-x-3">
              {selectedVendorForView.status === 'Pending' && (
                <button
                  onClick={() => {
                    handleVerifyVendor(selectedVendorForView.id, 'Verified');
                    setSelectedVendorForView(null);
                  }}
                  className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-medium flex items-center space-x-1 transition"
                >
                  <CheckCircle className="w-4 h-4" />
                  <span>Approve Vendor</span>
                </button>
              )}
              <button
                onClick={() => setSelectedVendorForView(null)}
                className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-medium transition"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Custom Delete Vendor Confirmation Modal */}
      {deleteVendorModal && (
        <div 
          className="fixed inset-0 z-50 bg-slate-950/70 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in duration-200"
          onClick={() => !deleteVendorModal.isDeleting && setDeleteVendorModal(null)}
        >
          <div 
            className="relative bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200 overflow-hidden"
            onClick={e => e.stopPropagation()}
          >
            <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-rose-500 via-red-500 to-amber-500" />

            <div className="flex items-start space-x-4 pt-1">
              <div className="w-12 h-12 rounded-2xl bg-rose-50 border border-rose-200 flex items-center justify-center flex-shrink-0 text-rose-600 shadow-xs">
                <Trash2 className="w-6 h-6" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-black tracking-wider uppercase text-rose-600 bg-rose-50 px-2 py-0.5 rounded-full border border-rose-200">
                    Irreversible Action
                  </span>
                  {!deleteVendorModal.isDeleting && (
                    <button 
                      onClick={() => setDeleteVendorModal(null)}
                      className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition"
                      title="Cancel"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  )}
                </div>
                <h3 className="text-lg font-black text-slate-900 mt-2">
                  Permanently Delete Vendor?
                </h3>
                <p className="text-xs text-slate-500 mt-1.5 leading-relaxed">
                  Are you sure you want to delete vendor <span className="font-bold text-slate-800">"{deleteVendorModal.name}"</span>? This action cannot be undone and will remove the vendor profile from the directory.
                </p>
              </div>
            </div>

            <div className="mt-6 flex items-center justify-end space-x-3 pt-4 border-t border-slate-100">
              <button
                type="button"
                disabled={deleteVendorModal.isDeleting}
                onClick={() => setDeleteVendorModal(null)}
                className="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-700 hover:bg-slate-100 text-xs font-bold transition disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={deleteVendorModal.isDeleting}
                onClick={confirmDeleteVendor}
                className="flex items-center space-x-2 px-5 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold shadow-lg shadow-rose-600/30 transition disabled:opacity-50"
              >
                {deleteVendorModal.isDeleting ? (
                  <>
                    <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                    <span>Deleting...</span>
                  </>
                ) : (
                  <>
                    <Trash2 className="w-3.5 h-3.5" />
                    <span>Delete Vendor</span>
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};
