import React, { useState, useEffect } from 'react';
import { MapPin, Users, DollarSign, CheckCircle, XCircle, ShieldCheck, Plus, Search } from 'lucide-react';
import { venueService, vendorService } from '../services/api';

export interface VendorItem {
  id: string;
  name: string;
  category: string;
  contact: string;
  status: string;
}

export const VenuesPage: React.FC = () => {
  const [venues, setVenues] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(false);
  const [vendors, setVendors] = useState<VendorItem[]>([]);

  // Load Real Venues from our Backend API
  useEffect(() => {
    const fetchVenues = async () => {
      try {
        setLoading(true);
        const data = await venueService.getVenues(searchTerm);
        setVenues(data);
      } catch (err) {
        console.error("Failed to fetch venues from backend", err);
      } finally {
        setLoading(false);
      }
    };
    fetchVenues();
  }, [searchTerm]);

  // Load Vendors from Backend API
  useEffect(() => {
    const fetchVendors = async () => {
      try {
        const data = await vendorService.getVendors();
        setVendors(data.map(v => ({
          ...v,
          id: v.vendorId || v.id,
          name: v.businessName || v.name,
          status: v.verificationStatus || v.status
        } as any)));
      } catch (err) {
        console.error("Failed to fetch vendors", err);
      }
    };
    fetchVendors();
    // Poll every 5 seconds to get new vendor registrations automatically
    const interval = setInterval(fetchVendors, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleVerifyVendor = async (id: string, newStatus: 'Verified' | 'Rejected') => {
    setVendors(prev => prev.map(v => (v.id === id || (v as any).vendorId === id) ? { ...v, status: newStatus } : v));
    try {
      await vendorService.verifyVendor(id, newStatus);
    } catch (e) {
      console.warn("Backend verifyVendor call warning", e);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Sri Lankan Venues & Vendor Directory</h1>
          <p className="text-slate-500 text-sm mt-1">Search real seeded hotels in Colombo, Kandy, Nuwara Eliya and verify vendor onboardings.</p>
        </div>
        <div className="w-full md:w-72">
          <input 
            type="text"
            placeholder="Search city (e.g. Nuwara, Kandy)..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
          />
        </div>
      </div>

      {/* Venues Grid */}
      <div className="mb-10">
        <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center">
          <span>Available Luxury Venues & Hotels</span>
          <span className="ml-2 text-xs bg-sky-100 text-sky-800 font-semibold px-2 py-0.5 rounded-full">{venues.length} Locations</span>
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {venues.slice(0, 9).map((venue: any) => (
            <div key={venue.venueId} className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition">
              <div className="flex justify-between items-start mb-2">
                <h3 className="font-bold text-slate-900 text-base line-clamp-1">{venue.name}</h3>
                <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${venue.isOutdoor ? 'bg-amber-50 text-amber-700 border border-amber-200' : 'bg-indigo-50 text-indigo-700 border border-indigo-200'}`}>
                  {venue.isOutdoor ? 'Outdoor' : 'Indoor'}
                </span>
              </div>
              <p className="text-xs text-slate-500 flex items-center mb-4"><MapPin className="w-3.5 h-3.5 mr-1 text-slate-400" />{venue.locationAddress}</p>
              
              <div className="space-y-2 border-t border-slate-100 pt-3 text-sm text-slate-600">
                <div className="flex justify-between">
                  <span className="flex items-center text-xs"><Users className="w-3.5 h-3.5 mr-1 text-slate-400" />Max Capacity:</span>
                  <span className="font-semibold text-slate-800">{venue.maxCapacity} Guests</span>
                </div>
                <div className="flex justify-between">
                  <span className="flex items-center text-xs"><DollarSign className="w-3.5 h-3.5 mr-1 text-slate-400" />Rental Price:</span>
                  <span className="font-semibold text-sky-600">Rs. {Number(venue.baseRentalPrice).toLocaleString()}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Vendor Verification Table (Business-Specific Operation) */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <ShieldCheck className="w-5 h-5 text-sky-400" />
            <h3 className="font-semibold text-base">Pending Vendor Verification Requests (Member 1 Component)</h3>
          </div>
          <span className="text-xs bg-slate-800 text-slate-300 px-3 py-1 rounded-full border border-slate-700">Admin Action</span>
        </div>

        <div className="divide-y divide-slate-200">
          {vendors.map(vendor => (
            <div key={vendor.id} className="p-5 flex items-center justify-between">
              <div>
                <h4 className="font-bold text-slate-900 text-sm">{vendor.name}</h4>
                <p className="text-xs text-slate-500 mt-0.5">Category: {vendor.category} • Contact: {vendor.contact}</p>
              </div>

              <div className="flex items-center space-x-3">
                <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${
                  vendor.status === 'Verified' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' :
                  vendor.status === 'Rejected' ? 'bg-rose-50 text-rose-700 border border-rose-200' :
                  'bg-amber-50 text-amber-700 border border-amber-200'
                }`}>
                  Status: {vendor.status}
                </span>

                {vendor.status === 'Pending' && (
                  <div className="flex space-x-2">
                    <button 
                      onClick={() => handleVerifyVendor(vendor.id, 'Verified')}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded text-xs font-medium flex items-center space-x-1"
                    >
                      <CheckCircle className="w-3.5 h-3.5" />
                      <span>Verify</span>
                    </button>
                    <button 
                      onClick={() => handleVerifyVendor(vendor.id, 'Rejected')}
                      className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 rounded text-xs font-medium flex items-center space-x-1"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      <span>Reject</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};