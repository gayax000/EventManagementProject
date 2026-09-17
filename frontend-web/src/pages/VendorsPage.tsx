import React, { useState, useEffect } from 'react';
import { ShieldCheck, CheckCircle, XCircle, Briefcase, Building2, Phone, Search, Tag } from 'lucide-react';
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

export const VendorsPage: React.FC = () => {
  const [vendors, setVendors] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  
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
      setVendors(data.map(v => ({
        ...v,
        id: v.vendorId || v.id,
        name: v.businessName || v.name,
        status: v.verificationStatus || v.status
      })));
    } catch (err) {
      console.error("Failed to fetch vendors", err);
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
    setVendors(prev => prev.map(v => v.id === id ? { ...v, status: newStatus } : v));
    try {
      await vendorService.verifyVendor(id, newStatus);
    } catch (e) {
      console.warn("Backend verifyVendor call warning", e);
      fetchVendors();
    }
  };

  // Filter Pending Vendors
  const pendingVendors = vendors.filter(v => {
    if (v.status !== 'Pending') return false;
    const searchLower = pendingSearch.toLowerCase();
    const matchesSearch = (v.name || '').toLowerCase().includes(searchLower) || 
                          (v.contactNumber || v.contact || '').includes(pendingSearch);
    const matchesCategory = matchesCategoryFilter(v.category, pendingCategory);
    return matchesSearch && matchesCategory;
  });

  // Filter Confirmed Vendors
  const confirmedVendors = vendors.filter(v => {
    if (v.status !== 'Verified') return false;
    const searchLower = confirmedSearch.toLowerCase();
    const matchesSearch = (v.name || '').toLowerCase().includes(searchLower) || 
                          (v.contactNumber || v.contact || '').includes(confirmedSearch);
    const matchesCategory = matchesCategoryFilter(v.category, confirmedCategory);
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-slate-900">Partner & Vendor Management</h1>
        <p className="text-slate-500 text-sm mt-1">Review new vendor applications and manage confirmed business partners across all 8 certified event service categories.</p>
      </div>

      {/* SECTION 1: Pending Verifications */}
      <div className="mb-10 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <ShieldCheck className="w-5 h-5 text-sky-400" />
            <h3 className="font-semibold text-base">Pending Vendor Verification Requests</h3>
          </div>
          <span className="text-xs bg-slate-800 text-slate-300 px-3 py-1 rounded-full border border-slate-700">
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
              placeholder="Search pending requests..."
              value={pendingSearch}
              onChange={(e) => setPendingSearch(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-slate-300 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-sky-500 bg-white shadow-sm"
            />
          </div>
          <div className="flex overflow-x-auto space-x-2 pb-1 scrollbar-hide">
            {VENDOR_CATEGORIES.map(cat => (
              <button
                key={cat.id}
                onClick={() => setPendingCategory(cat.id)}
                className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg border text-xs font-medium whitespace-nowrap transition-colors ${
                  pendingCategory === cat.id 
                    ? 'bg-slate-900 text-white border-slate-900 shadow-sm' 
                    : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-100'
                }`}
              >
                <span>{cat.icon}</span>
                <span>{cat.label}</span>
              </button>
            ))}
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
              return (
                <div key={vendor.id} className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50 transition">
                  <div>
                    <div className="flex items-center space-x-2">
                      <span className="text-lg">{badge.icon}</span>
                      <h4 className="font-bold text-slate-900 text-base">{vendor.name}</h4>
                    </div>
                    <div className="flex items-center text-xs text-slate-500 mt-1.5 space-x-3">
                      <span className="flex items-center px-2 py-0.5 bg-slate-100 text-slate-700 font-medium rounded-md">
                        <Tag className="w-3 h-3 mr-1 text-slate-400" /> {badge.label}
                      </span>
                      <span className="flex items-center"><Phone className="w-3.5 h-3.5 mr-1 text-slate-400" /> {vendor.contactNumber || vendor.contact}</span>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 border border-amber-200">
                      Status: {vendor.status}
                    </span>

                    <div className="flex space-x-2">
                      <button 
                        onClick={() => handleVerifyVendor(vendor.id, 'Verified')}
                        className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-medium flex items-center space-x-1 shadow-sm transition"
                      >
                        <CheckCircle className="w-4 h-4" />
                        <span>Approve</span>
                      </button>
                      <button 
                        onClick={() => handleVerifyVendor(vendor.id, 'Rejected')}
                        className="px-4 py-2 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 rounded-lg text-xs font-medium flex items-center space-x-1 transition"
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
          <span className="text-xs text-slate-500 font-medium">{vendors.filter(v => v.status === 'Verified').length} Verified Partners</span>
        </div>

        {/* Confirmed Filters */}
        <div className="p-4 bg-slate-50 border-b border-slate-200 space-y-3">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-4 w-4 text-slate-400" />
            </div>
            <input
              type="text"
              placeholder="Search confirmed members..."
              value={confirmedSearch}
              onChange={(e) => setConfirmedSearch(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-slate-300 rounded-lg text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 bg-white shadow-sm"
            />
          </div>
          <div className="flex overflow-x-auto space-x-2 pb-1 scrollbar-hide">
            {VENDOR_CATEGORIES.map(cat => (
              <button
                key={cat.id}
                onClick={() => setConfirmedCategory(cat.id)}
                className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg border text-xs font-medium whitespace-nowrap transition-colors ${
                  confirmedCategory === cat.id 
                    ? 'bg-indigo-600 text-white border-indigo-600 shadow-sm' 
                    : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-100'
                }`}
              >
                <span>{cat.icon}</span>
                <span>{cat.label}</span>
              </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 p-6 gap-4 bg-slate-50/50">
          {confirmedVendors.length === 0 ? (
            <div className="col-span-full py-8 text-center text-slate-500 text-sm">
              {confirmedSearch || confirmedCategory !== 'All' 
                ? 'No confirmed vendors match your filter.' 
                : 'No confirmed vendors yet.'}
            </div>
          ) : (
            confirmedVendors.map(vendor => {
              const badge = getCategoryBadge(vendor.category);
              return (
                <div key={vendor.id} className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition hover:border-indigo-200">
                  <div className="flex justify-between items-start mb-3">
                    <div className="flex items-center space-x-2">
                      <span className="text-base">{badge.icon}</span>
                      <h4 className="font-bold text-slate-900 text-sm line-clamp-1">{vendor.name}</h4>
                    </div>
                    <span className="bg-emerald-100 text-emerald-800 text-[10px] uppercase tracking-wider font-bold px-2 py-0.5 rounded-full">
                      Verified
                    </span>
                  </div>
                  <div className="space-y-1.5 text-xs text-slate-600">
                    <p className="flex items-center"><Tag className="w-3.5 h-3.5 mr-2 text-indigo-400" /> {badge.label}</p>
                    <p className="flex items-center"><Phone className="w-3.5 h-3.5 mr-2 text-indigo-400" /> {vendor.contactNumber || vendor.contact}</p>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
};
