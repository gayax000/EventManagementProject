import React, { useState, useEffect } from 'react';
import { ShieldCheck, CheckCircle, XCircle, Briefcase, Building2, Phone } from 'lucide-react';
import { vendorService } from '../services/api';

export const VendorsPage: React.FC = () => {
  const [vendors, setVendors] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

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
    // Optimistic UI update
    setVendors(prev => prev.map(v => v.id === id ? { ...v, status: newStatus } : v));
    try {
      await vendorService.verifyVendor(id, newStatus);
    } catch (e) {
      console.warn("Backend verifyVendor call warning", e);
      // Revert on failure (simple refetch)
      fetchVendors();
    }
  };

  const pendingVendors = vendors.filter(v => v.status === 'Pending');
  const confirmedVendors = vendors.filter(v => v.status === 'Verified');

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-slate-900">Partner & Vendor Management</h1>
        <p className="text-slate-500 text-sm mt-1">Review new vendor applications and manage confirmed business partners in the EventCraft network.</p>
      </div>

      {/* SECTION 1: Pending Verifications */}
      <div className="mb-10 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <ShieldCheck className="w-5 h-5 text-sky-400" />
            <h3 className="font-semibold text-base">Pending Vendor Verification Requests</h3>
          </div>
          <span className="text-xs bg-slate-800 text-slate-300 px-3 py-1 rounded-full border border-slate-700">
            {pendingVendors.length} Action(s) Required
          </span>
        </div>

        <div className="divide-y divide-slate-200">
          {pendingVendors.length === 0 ? (
            <div className="p-8 text-center text-slate-500 text-sm">
              No pending verification requests at the moment.
            </div>
          ) : (
            pendingVendors.map(vendor => (
              <div key={vendor.id} className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h4 className="font-bold text-slate-900 text-base">{vendor.name}</h4>
                  <div className="flex items-center text-xs text-slate-500 mt-1 space-x-3">
                    <span className="flex items-center"><Briefcase className="w-3.5 h-3.5 mr-1 text-slate-400" /> {vendor.category}</span>
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
            ))
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
          <span className="text-xs text-slate-500 font-medium">{confirmedVendors.length} Verified Partners</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 p-6 gap-4 bg-slate-50/50">
          {confirmedVendors.length === 0 ? (
            <div className="col-span-full py-8 text-center text-slate-500 text-sm">
              No confirmed vendors yet. Approve pending requests to add them to the network.
            </div>
          ) : (
            confirmedVendors.map(vendor => (
              <div key={vendor.id} className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition">
                <div className="flex justify-between items-start mb-3">
                  <h4 className="font-bold text-slate-900 text-sm line-clamp-1">{vendor.name}</h4>
                  <span className="bg-emerald-100 text-emerald-800 text-[10px] uppercase tracking-wider font-bold px-2 py-0.5 rounded-full">
                    Verified
                  </span>
                </div>
                <div className="space-y-1.5 text-xs text-slate-600">
                  <p className="flex items-center"><Briefcase className="w-3.5 h-3.5 mr-2 text-indigo-400" /> {vendor.category}</p>
                  <p className="flex items-center"><Phone className="w-3.5 h-3.5 mr-2 text-indigo-400" /> {vendor.contactNumber || vendor.contact}</p>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
