import React, { useState, useEffect } from 'react';
import { 
  Building2, 
  ShieldCheck, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  Phone, 
  Sparkles, 
  ArrowRight,
  PlusCircle,
  Layers,
  AlertCircle
} from 'lucide-react';
import { vendorService, type VendorItem } from '../services/api';

export const VendorPortal: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'dashboard' | 'register'>('dashboard');

  // Form State
  const [businessName, setBusinessName] = useState('');
  const [category, setCategory] = useState('Catering');
  const [contactNumber, setContactNumber] = useState('');
  const [description, setDescription] = useState('');
  const [packageName, setPackageName] = useState('');
  const [packagePrice, setPackagePrice] = useState(5500);
  const [submitting, setSubmitting] = useState(false);
  const [registeredSuccess, setRegisteredSuccess] = useState(false);

  // Active vendor in current session
  const [currentVendor, setCurrentVendor] = useState<VendorItem | null>(() => {
    try {
      const saved = localStorage.getItem('eventcraft_current_vendor');
      if (saved) return JSON.parse(saved);
    } catch {}
    return {
      id: 'v1',
      businessName: 'Royal Colombo Catering Services',
      category: 'Catering',
      contactNumber: '+94 77 123 4567',
      verificationStatus: 'Verified',
      adminRemarks: 'Audited & approved for 5-star events'
    };
  });

  // Sync with global vendors list from localStorage or DB
  useEffect(() => {
    const syncStatus = () => {
      try {
        const savedVendors = localStorage.getItem('eventcraft_vendors');
        if (savedVendors && currentVendor) {
          const vendors: any[] = JSON.parse(savedVendors);
          const matched = vendors.find(v => 
            (v.id && (v.id === currentVendor.id || v.id === currentVendor.vendorId)) ||
            (v.name && v.name.toLowerCase() === (currentVendor.businessName || '').toLowerCase()) ||
            (v.businessName && v.businessName.toLowerCase() === (currentVendor.businessName || '').toLowerCase())
          );
          if (matched) {
            const updatedStatus = matched.status || matched.verificationStatus || currentVendor.verificationStatus;
            if (updatedStatus !== currentVendor.verificationStatus) {
              const updated = { ...currentVendor, verificationStatus: updatedStatus };
              setCurrentVendor(updated);
              localStorage.setItem('eventcraft_current_vendor', JSON.stringify(updated));
            }
          }
        }
      } catch (e) {
        console.error('Sync error', e);
      }
    };

    syncStatus();
    const interval = setInterval(syncStatus, 1500);
    return () => clearInterval(interval);
  }, [currentVendor]);

  // Handle New Vendor Registration
  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessName || !contactNumber) return;

    try {
      setSubmitting(true);
      const newVendorData: VendorItem = {
        id: 'v-' + Date.now(),
        businessName,
        name: businessName,
        category,
        contact: contactNumber,
        contactNumber,
        status: 'Pending',
        verificationStatus: 'Pending',
        adminRemarks: description || (packageName ? packageName + ' (Rs. ' + Number(packagePrice).toLocaleString() + ')' : '')
      };

      // 1. Try to save to backend API
      try {
        await vendorService.registerVendor({
          businessName,
          category,
          contactNumber,
          description: description || packageName
        });
      } catch (apiErr) {
        console.warn('Backend vendor endpoint offline, saving locally', apiErr);
      }

      // 2. Append to shared vendors list for Manager Dashboard
      try {
        const savedVendors = localStorage.getItem('eventcraft_vendors');
        const list: any[] = savedVendors ? JSON.parse(savedVendors) : [];
        list.unshift(newVendorData);
        localStorage.setItem('eventcraft_vendors', JSON.stringify(list));
      } catch (storageErr) {
        console.error(storageErr);
      }

      // 3. Set as current active vendor in vendor session
      setCurrentVendor(newVendorData);
      localStorage.setItem('eventcraft_current_vendor', JSON.stringify(newVendorData));

      setRegisteredSuccess(true);
      setActiveTab('dashboard');
      // Reset form
      setBusinessName('');
      setContactNumber('');
      setDescription('');
    } catch (err) {
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      {/* Top Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4 bg-slate-900 text-white p-6 rounded-2xl shadow-lg border border-slate-800">
        <div>
          <div className="flex items-center space-x-2">
            <span className="text-xs font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
              Supplier & Partner Portal
            </span>
            <span className="text-xs text-slate-400">• Member 1 Component</span>
          </div>
          <h1 className="text-2xl font-black mt-2">Vendor Business Management & Onboarding</h1>
          <p className="text-slate-400 text-sm mt-1">Register your catering, sound, lighting or marquee equipment for AI-assisted event curation.</p>
        </div>

        {/* Portal Tabs */}
        <div className="flex space-x-2 bg-slate-800 p-1.5 rounded-xl border border-slate-700">
          <button
            onClick={() => setActiveTab('dashboard')}
            className={`px-4 py-2 rounded-lg text-xs font-semibold flex items-center space-x-1.5 transition ${
              activeTab === 'dashboard' ? 'bg-indigo-600 text-white shadow-sm' : 'text-slate-300 hover:text-white'
            }`}
          >
            <Building2 className="w-3.5 h-3.5" />
            <span>My Business Status</span>
          </button>
          <button
            onClick={() => setActiveTab('register')}
            className={`px-4 py-2 rounded-lg text-xs font-semibold flex items-center space-x-1.5 transition ${
              activeTab === 'register' ? 'bg-indigo-600 text-white shadow-sm' : 'text-slate-300 hover:text-white'
            }`}
          >
            <PlusCircle className="w-3.5 h-3.5" />
            <span>Register New Business</span>
          </button>
        </div>
      </div>

      {registeredSuccess && (
        <div className="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl text-emerald-900 text-sm flex items-center justify-between shadow-sm">
          <div className="flex items-center space-x-2">
            <CheckCircle2 className="w-5 h-5 text-emerald-600 flex-shrink-0" />
            <span>
              <strong>Registration Submitted!</strong> Your business is now in <strong>Pending</strong> state. Switch to the <strong>Operations Manager Portal</strong> to verify!
            </span>
          </div>
          <button onClick={() => setRegisteredSuccess(false)} className="text-emerald-700 hover:text-emerald-900 font-bold">&times;</button>
        </div>
      )}

      {/* VIEW 1: MY VENDOR DASHBOARD */}
      {activeTab === 'dashboard' && currentVendor && (
        <div className="space-y-6">
          
          {/* Status Hero Card */}
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 pb-6 border-b border-slate-100">
              <div>
                <span className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Registered Partner Profile</span>
                <h2 className="text-2xl font-black text-slate-900 mt-1">{currentVendor.businessName || currentVendor.name}</h2>
                <div className="flex flex-wrap items-center gap-3 mt-2 text-xs text-slate-500">
                  <span className="px-2.5 py-1 bg-slate-100 text-slate-700 font-medium rounded-md">Category: {currentVendor.category}</span>
                  <span className="flex items-center"><Phone className="w-3 h-3 mr-1 text-slate-400" />{currentVendor.contactNumber || currentVendor.contact}</span>
                </div>
              </div>

              {/* Status Badge */}
              <div className="flex flex-col items-end">
                <span className="text-xs font-semibold text-slate-400 uppercase mb-1">Audit Verification Status</span>
                {currentVendor.verificationStatus === 'Verified' ? (
                  <div className="flex items-center space-x-2 px-4 py-2 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-xl font-bold text-sm shadow-sm">
                    <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                    <span>Verified & Certified Partner</span>
                  </div>
                ) : currentVendor.verificationStatus === 'Rejected' ? (
                  <div className="flex items-center space-x-2 px-4 py-2 bg-rose-50 text-rose-700 border border-rose-200 rounded-xl font-bold text-sm shadow-sm">
                    <XCircle className="w-5 h-5 text-rose-600" />
                    <span>Application Declined</span>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2 px-4 py-2 bg-amber-50 text-amber-700 border border-amber-200 rounded-xl font-bold text-sm shadow-sm animate-pulse">
                    <Clock className="w-5 h-5 text-amber-600" />
                    <span>Under Review (Pending Approval)</span>
                  </div>
                )}
              </div>
            </div>

            {/* Explanation & Instructions based on status */}
            <div className="mt-6">
              {currentVendor.verificationStatus === 'Verified' ? (
                <div className="p-4 bg-emerald-50/70 border border-emerald-200 rounded-xl text-emerald-900 text-sm">
                  <div className="flex items-start space-x-3">
                    <Sparkles className="w-5 h-5 text-emerald-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <h4 className="font-bold">Autonomous AI Recommendation Engine Integration: Active!</h4>
                      <p className="text-xs text-emerald-800 mt-1">
                        Your catering and equipment packages are actively indexed by the <strong>EventCraft Multi-Agent Planner</strong>. When customers submit event requests within your category and budget, your services are automatically curated into client proposals!
                      </p>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="p-4 bg-amber-50/70 border border-amber-200 rounded-xl text-amber-900 text-sm">
                  <div className="flex items-start space-x-3">
                    <AlertCircle className="w-5 h-5 text-amber-600 mt-0.5 flex-shrink-0" />
                    <div>
                      <h4 className="font-bold">Waiting for Operations Manager Verification</h4>
                      <p className="text-xs text-amber-800 mt-1">
                        Your application is currently listed in the <strong>Pending Verification Requests Queue</strong> of the Operations Manager dashboard.
                      </p>
                      <p className="text-xs text-amber-700/80 mt-2 flex items-center">
                        <Clock className="w-3.5 h-3.5 mr-1 text-amber-600" />
                        Audited by EventCraft Operations Management. Once verified, your status will update automatically.
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Catalog & Equipment Breakdown */}
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                <Layers className="w-4 h-4 text-indigo-600" />
                <span>My Registered Services & Equipment</span>
              </h3>
              <span className="text-xs bg-slate-100 text-slate-600 px-2.5 py-1 rounded-md font-semibold">Live Service Sync</span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="p-4 rounded-xl border border-slate-200 bg-slate-50 flex items-start justify-between">
                <div>
                  <h4 className="font-bold text-slate-900 text-sm">{currentVendor.adminRemarks || 'Standard Catering / AV Setup'}</h4>
                  <p className="text-xs text-slate-500 mt-1">Category: {currentVendor.category}</p>
                  <p className="text-xs font-bold text-indigo-600 mt-2">Starting at: Rs. 5,000 - 150,000</p>
                </div>
                <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${
                  currentVendor.verificationStatus === 'Verified' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                }`}>
                  {currentVendor.verificationStatus === 'Verified' ? 'Active in AI Catalog' : 'Pending Verification'}
                </span>
              </div>
            </div>
          </div>

        </div>
      )}

      {/* VIEW 2: VENDOR REGISTRATION FORM */}
      {activeTab === 'register' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 max-w-2xl mx-auto">
          <div className="mb-6">
            <h2 className="text-xl font-bold text-slate-900">Partner Business Registration Form</h2>
            <p className="text-slate-500 text-xs mt-1">Fill in your business details to apply for verified vendor status in the EventCraft platform.</p>
          </div>

          <form onSubmit={handleRegister} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Business / Company Name *</label>
              <input 
                type="text"
                required
                value={businessName}
                onChange={e => setBusinessName(e.target.value)}
                placeholder="e.g. Ceylon Grand Banquet Caterers"
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Service Category *</label>
                <select
                  value={category}
                  onChange={e => setCategory(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  <option value="Catering">Catering & Food Service</option>
                  <option value="AudioVisual">AudioVisual & Stage Lighting</option>
                  <option value="MarqueeTent">Marquee & Outdoor Weather Proofing</option>
                  <option value="PowerBackup">Power Backup & Generators</option>
                  <option value="Decor">Floral & Event Decoration</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Official Contact Number *</label>
                <input 
                  type="text"
                  required
                  value={contactNumber}
                  onChange={e => setContactNumber(e.target.value)}
                  placeholder="e.g. +94 77 987 6543"
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Primary Service Package Name</label>
              <input 
                type="text"
                value={packageName}
                onChange={e => setPackageName(e.target.value)}
                placeholder="e.g. 5-Course Royal Gala Dinner Buffet"
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Starting Unit Price (LKR)</label>
                <input 
                  type="number"
                  value={packagePrice}
                  onChange={e => setPackagePrice(Number(e.target.value))}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Operating Cities</label>
                <input 
                  type="text"
                  placeholder="Colombo, Kandy, Galle"
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Business Description / Accreditation</label>
              <textarea 
                rows={3}
                value={description}
                onChange={e => setDescription(e.target.value)}
                placeholder="Describe your equipment, food hygiene certifications, or previous high-profile events..."
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="pt-2">
              <button
                type="submit"
                disabled={submitting}
                className="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-sm rounded-xl shadow-md transition flex items-center justify-center space-x-2 disabled:opacity-50"
              >
                <ShieldCheck className="w-4 h-4" />
                <span>{submitting ? 'Submitting Application...' : 'Submit Application for Manager Audit'}</span>
              </button>
            </div>
          </form>
        </div>
      )}

    </div>
  );
};
