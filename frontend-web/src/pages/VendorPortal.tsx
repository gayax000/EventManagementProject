import React, { useState, useEffect } from 'react';
import { 
  Building2, 
  ShieldCheck, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  Phone, 
  Sparkles, 
  PlusCircle,
  Layers,
  AlertCircle,
  Tag
} from 'lucide-react';
import { vendorService, type VendorItem } from '../services/api';
import { authService } from '../services/authService';

export const VENDOR_SERVICE_CONFIG: Record<string, {
  label: string;
  shortLabel: string;
  icon: string;
  defaultPackage: string;
  defaultPrice: number;
  placeholderName: string;
  placeholderDescription: string;
}> = {
  Catering: {
    label: 'Catering & Gourmet Buffets',
    shortLabel: 'Catering Buffets',
    icon: '🍽️',
    defaultPackage: '5-Course Royal Gala Dinner Buffet (Per Plate)',
    defaultPrice: 5500,
    placeholderName: 'e.g. Ceylon Grand Banquet Caterers',
    placeholderDescription: 'Describe your buffet menu specialties, live action stations, food hygiene certification, and per-plate packages...'
  },
  AudioVisual: {
    label: 'AudioVisual & Stage Lighting',
    shortLabel: 'Sound & Lighting',
    icon: '🔊',
    defaultPackage: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses',
    defaultPrice: 180000,
    placeholderName: 'e.g. Lumina Pro Audio & Stage Lighting',
    placeholderDescription: 'Describe your line-array sound systems, digital audio consoles, intelligent moving heads, beam trusses, and ambient stage lighting...'
  },
  Decor: {
    label: 'Floral & Event Decoration',
    shortLabel: 'Decor & Stage',
    icon: '🌸',
    defaultPackage: 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor',
    defaultPrice: 80000,
    placeholderName: 'e.g. Royal Blooms Floral & Stage Design',
    placeholderDescription: 'Describe your bespoke floral arches, stage backdrops, ambient tablescapes, theme styling, and entrance decor...'
  },
  Photography: {
    label: 'In-House Photography & Cinematography',
    shortLabel: 'Photography',
    icon: '📸',
    defaultPackage: 'Master Wedding Photography + 4K Highlights Video + Storybook Album',
    defaultPrice: 100000,
    placeholderName: 'e.g. Studio Lumiere Wedding & Event Photography',
    placeholderDescription: 'Describe your 4K cinema cameras, aerial drone footage, photography team size, album printing options, and turnaround time...'
  },
  Cake: {
    label: 'Celebration Cakes & Dessert Art',
    shortLabel: 'Cakes',
    icon: '🎂',
    defaultPackage: '3-Tier Luxury Handcrafted Fondant Floral Wedding Cake',
    defaultPrice: 35000,
    placeholderName: 'e.g. Velvet Crumb Artisan Cake Studio',
    placeholderDescription: 'Describe your handcrafted tiered wedding cakes, flavor profiles, custom fondant sugar flowers, and dessert table spreads...'
  },
  Transport: {
    label: 'Luxury Bridal & VIP Transport',
    shortLabel: 'VIP Transport',
    icon: '🚗',
    defaultPackage: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan',
    defaultPrice: 50000,
    placeholderName: 'e.g. Royal Crown VIP & Bridal Chauffeurs',
    placeholderDescription: 'Describe your fleet of luxury sedans (Mercedes, BMW), vintage Rolls Royce/Jaguar bridal cars, 14-seater VIP vans, and chauffeur service...'
  },
  MarqueeTent: {
    label: 'Marquee & Outdoor Weather Proofing',
    shortLabel: 'Tents & Safeguards',
    icon: '🎪',
    defaultPackage: 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)',
    defaultPrice: 150000,
    placeholderName: 'e.g. Ceylon WeatherShield Marquee Tents',
    placeholderDescription: 'Describe your clear-roof marquee tents, waterproof pagoda canopies, rain guttering, wind resistance ratings, and setup crew...'
  },
  PowerBackup: {
    label: 'Power Backup & Industrial Generators',
    shortLabel: 'Power Backup',
    icon: '⚡',
    defaultPackage: 'Backup Diesel Silent Generator (60 kVA Heavy Duty)',
    defaultPrice: 90000,
    placeholderName: 'e.g. VoltMax Heavy Power & Generator Hire',
    placeholderDescription: 'Describe your soundproof diesel generators (15-100 kVA), automatic transfer switches (ATS), power distribution boards, and on-site technician...'
  }
};

export const getCategoryInfo = (catKey?: string) => {
  if (!catKey) {
    return { 
      label: 'General Vendor Service', 
      shortLabel: 'Service', 
      icon: '🏪', 
      defaultPackage: 'Standard Service Package', 
      defaultPrice: 5000, 
      placeholderName: 'e.g. Event Service Provider', 
      placeholderDescription: 'Describe your services...' 
    };
  }
  
  const normalized = catKey.trim().toLowerCase();
  if (normalized.includes('photo')) return VENDOR_SERVICE_CONFIG.Photography;
  if (normalized.includes('cake')) return VENDOR_SERVICE_CONFIG.Cake;
  if (normalized.includes('transport') || normalized.includes('car') || normalized.includes('vehicle') || normalized.includes('vip')) return VENDOR_SERVICE_CONFIG.Transport;
  if (normalized.includes('sound') || normalized.includes('audio') || normalized.includes('light')) return VENDOR_SERVICE_CONFIG.AudioVisual;
  if (normalized.includes('cater') || normalized.includes('food') || normalized.includes('buffet')) return VENDOR_SERVICE_CONFIG.Catering;
  if (normalized.includes('decor') || normalized.includes('flower') || normalized.includes('floral')) return VENDOR_SERVICE_CONFIG.Decor;
  if (normalized.includes('tent') || normalized.includes('marquee') || normalized.includes('weather')) return VENDOR_SERVICE_CONFIG.MarqueeTent;
  if (normalized.includes('power') || normalized.includes('gen') || normalized.includes('generator')) return VENDOR_SERVICE_CONFIG.PowerBackup;

  return VENDOR_SERVICE_CONFIG[catKey] || {
    label: catKey,
    shortLabel: catKey,
    icon: '📦',
    defaultPackage: 'Standard Service Package',
    defaultPrice: 5000,
    placeholderName: 'e.g. Service Partner',
    placeholderDescription: 'Describe your service offerings...'
  };
};

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

  const selectedCategoryConfig = VENDOR_SERVICE_CONFIG[category] || getCategoryInfo(category);

  // Current Logged-in Vendor Identity
  const userName = authService.getUserName();
  const userEmail = authService.getUserEmail();
  const userKey = (userEmail || userName || 'vendor').toLowerCase().trim();

  // Active vendor strictly tied to the logged-in user
  const [currentVendor, setCurrentVendor] = useState<VendorItem | null>(() => {
    try {
      if (userKey) {
        const savedId = localStorage.getItem(`eventcraft_vendor_id_${userKey}`);
        if (savedId) {
          // Placeholder until fetched from API
          return { id: savedId, businessName: 'Loading...', category: '', contactNumber: '', verificationStatus: 'Pending' } as any;
        }
      }
    } catch {}
    return null;
  });

  // Sync with Backend API
  useEffect(() => {
    const syncStatus = async () => {
      if (!currentVendor || !currentVendor.id) return;
      try {
        const allVendors = await vendorService.getVendors();
        const matched = allVendors.find(v => (v as any).vendorId === currentVendor.id || v.id === currentVendor.id);
        if (matched) {
          const updatedStatus = (matched as any).verificationStatus || matched.status;
          if (updatedStatus !== currentVendor.status && updatedStatus !== (currentVendor as any).verificationStatus) {
            setCurrentVendor({ 
              ...matched, 
              id: (matched as any).vendorId || matched.id, 
              verificationStatus: updatedStatus,
              status: updatedStatus 
            } as any);
          }
        }
      } catch (e) {
        console.error('Sync error', e);
      }
    };

    if (currentVendor?.id && currentVendor.businessName === 'Loading...') {
      syncStatus();
    }

    const interval = setInterval(syncStatus, 5000); // Check every 5 seconds
    return () => clearInterval(interval);
  }, [currentVendor?.id, currentVendor?.status]);

  const handleCategoryChange = (newCat: string) => {
    setCategory(newCat);
    const config = VENDOR_SERVICE_CONFIG[newCat] || getCategoryInfo(newCat);
    if (config) {
      setPackagePrice(config.defaultPrice);
    }
  };

  // Handle New Vendor Registration
  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessName || !contactNumber) return;

    try {
      setSubmitting(true);

      // Save to backend API
      const registeredVendor = await vendorService.registerVendor({
        businessName,
        category,
        contactNumber,
        description: description || packageName || selectedCategoryConfig.defaultPackage
      });

      const newVendorId = (registeredVendor as any).vendorId || registeredVendor.id;
      
      const newVendorData: any = {
        ...registeredVendor,
        id: newVendorId,
        verificationStatus: 'Pending',
        status: 'Pending',
        packageName: packageName || selectedCategoryConfig.defaultPackage,
        packagePrice: packagePrice || selectedCategoryConfig.defaultPrice
      };

      setCurrentVendor(newVendorData);
      if (userKey) {
        localStorage.setItem(`eventcraft_vendor_id_${userKey}`, newVendorId);
      }

      setRegisteredSuccess(true);
      setActiveTab('dashboard');
      // Reset form
      setBusinessName('');
      setContactNumber('');
      setDescription('');
      setPackageName('');
    } catch (err) {
      console.error("Backend vendor registration failed:", err);
      alert("Failed to register vendor. Please ensure backend API is running.");
    } finally {
      setSubmitting(false);
    }
  };

  const activeCategoryInfo = currentVendor ? getCategoryInfo(currentVendor.category) : null;

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
          <p className="text-slate-400 text-sm mt-1">Register your catering, sound, lighting, decor, photography, cakes, VIP transport, marquee or power equipment for AI-assisted event curation.</p>
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
              <strong>Registration Submitted!</strong> Your business profile has been submitted and is currently in <strong>Pending Review</strong> status awaiting Operations Manager audit.
            </span>
          </div>
          <button onClick={() => setRegisteredSuccess(false)} className="text-emerald-700 hover:text-emerald-900 font-bold">&times;</button>
        </div>
      )}

      {/* VIEW 1: MY VENDOR DASHBOARD */}
      {activeTab === 'dashboard' && (
        currentVendor ? (
          <div className="space-y-6">
            
            {/* Status Hero Card */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 pb-6 border-b border-slate-100">
                <div>
                  <span className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Registered Partner Profile</span>
                  <div className="flex items-center space-x-2.5 mt-1">
                    <span className="text-2xl">{activeCategoryInfo?.icon || '🏪'}</span>
                    <h2 className="text-2xl font-black text-slate-900">{currentVendor.businessName || currentVendor.name}</h2>
                  </div>
                  <div className="flex flex-wrap items-center gap-3 mt-2 text-xs text-slate-500">
                    <span className="px-2.5 py-1 bg-indigo-50 text-indigo-700 font-bold rounded-md border border-indigo-100 flex items-center space-x-1">
                      <span>{activeCategoryInfo?.icon}</span>
                      <span>Category: {activeCategoryInfo?.label || currentVendor.category}</span>
                    </span>
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
                          Your services and equipment packages are actively indexed by the <strong>EventCraft Multi-Agent Planner</strong>. When customers submit event requests matching <strong>{activeCategoryInfo?.label || currentVendor.category}</strong>, your services are automatically curated into client proposals!
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
                    <div className="flex items-center space-x-2">
                      <span className="text-lg">{activeCategoryInfo?.icon || '📦'}</span>
                      <h4 className="font-bold text-slate-900 text-sm">{currentVendor.adminRemarks || (currentVendor as any).packageName || activeCategoryInfo?.defaultPackage || 'Standard Service Package'}</h4>
                    </div>
                    <p className="text-xs text-slate-500 mt-1.5 flex items-center space-x-1">
                      <Tag className="w-3 h-3 text-slate-400" />
                      <span>{activeCategoryInfo?.label || currentVendor.category}</span>
                    </p>
                    <p className="text-xs font-bold text-indigo-600 mt-2">
                      Price: Rs. {Number((currentVendor as any).packagePrice || activeCategoryInfo?.defaultPrice || 5000).toLocaleString()}
                    </p>
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
        ) : (
          /* Empty state for a newly registered vendor who hasn't onboarded a business yet */
          <div className="bg-white rounded-2xl border border-dashed border-slate-300 p-12 text-center shadow-sm max-w-2xl mx-auto">
            <div className="w-16 h-16 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-indigo-100 shadow-sm">
              <Building2 className="w-8 h-8" />
            </div>
            <span className="text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-200">
              Account Active • Onboarding Required
            </span>
            <h2 className="text-2xl font-black text-slate-900 mt-4">Welcome to EventCraft, {userName}!</h2>
            <p className="text-slate-500 text-sm max-w-md mx-auto mt-2 leading-relaxed">
              You haven't registered your business profile yet. Register your catering, audiovisual, decor, photography, cakes, VIP transport, marquee tents, or power backup services below to get audited and verified by EventCraft Operations Management.
            </p>
            <div className="pt-6">
              <button
                onClick={() => setActiveTab('register')}
                className="inline-flex items-center space-x-2 px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-sm rounded-xl shadow-md transition hover:scale-[1.02]"
              >
                <PlusCircle className="w-4 h-4" />
                <span>Register Your Business Profile Now</span>
              </button>
            </div>
          </div>
        )
      )}

      {/* VIEW 2: VENDOR REGISTRATION FORM */}
      {activeTab === 'register' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 max-w-2xl mx-auto">
          <div className="mb-6">
            <h2 className="text-xl font-bold text-slate-900">Partner Business Registration Form</h2>
            <p className="text-slate-500 text-xs mt-1">Fill in your business details across any of our 8 certified service categories to apply for verified vendor status.</p>
          </div>

          <form onSubmit={handleRegister} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Business / Company Name *</label>
              <input 
                type="text"
                required
                value={businessName}
                onChange={e => setBusinessName(e.target.value)}
                placeholder={selectedCategoryConfig.placeholderName}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Service Category (8 Categories) *</label>
                <select
                  value={category}
                  onChange={e => handleCategoryChange(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 font-medium"
                >
                  <option value="SoundLighting">🔊 Sound & Lighting</option>
                  <option value="Decor">🌸 Decor & Stage</option>
                  <option value="Photography">📸 Photography</option>
                  <option value="Cake">🎂 Cakes</option>
                  <option value="Transport">🚗 VIP Transport</option>
                  <option value="Catering">🍽️ Catering Buffets</option>
                  <option value="MarqueeTent">🎪 Tents & Safeguards</option>
                  <option value="PowerBackup">⚡ Power Backup</option>
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
                placeholder={selectedCategoryConfig.defaultPackage}
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
                placeholder={selectedCategoryConfig.placeholderDescription}
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
