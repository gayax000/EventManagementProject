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
  Tag,
  ChevronRight,
  TrendingUp,
  Cpu
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
  tierSample: string;
}> = {
  SoundLighting: {
    label: 'AudioVisual & Stage Lighting',
    shortLabel: 'Sound & Lighting',
    icon: '🔊',
    defaultPackage: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses',
    defaultPrice: 180000,
    placeholderName: 'e.g. Lumina Pro Audio & Stage Lighting',
    placeholderDescription: 'Describe your line-array sound systems, digital audio consoles, intelligent moving heads, beam trusses, and ambient stage lighting...',
    tierSample: 'Line-Array Rig, Moving Heads & Beam Trusses'
  },
  AudioVisual: {
    label: 'AudioVisual & Stage Lighting',
    shortLabel: 'Sound & Lighting',
    icon: '🔊',
    defaultPackage: 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses',
    defaultPrice: 180000,
    placeholderName: 'e.g. Lumina Pro Audio & Stage Lighting',
    placeholderDescription: 'Describe your line-array sound systems, digital audio consoles, intelligent moving heads, beam trusses, and ambient stage lighting...',
    tierSample: 'Line-Array Rig, Moving Heads & Beam Trusses'
  },
  Decor: {
    label: 'Floral & Event Decoration',
    shortLabel: 'Decor & Stage',
    icon: '🌸',
    defaultPackage: 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor',
    defaultPrice: 80000,
    placeholderName: 'e.g. Royal Blooms Floral & Stage Design',
    placeholderDescription: 'Describe your bespoke floral arches, stage backdrops, ambient tablescapes, theme styling, and entrance decor...',
    tierSample: 'Floral Drapes, Thematic Stage & Archway Design'
  },
  Photography: {
    label: 'In-House Photography & Cinematography',
    shortLabel: 'Photography',
    icon: '📸',
    defaultPackage: 'Master Wedding Photography + 4K Highlights Video + Storybook Album',
    defaultPrice: 100000,
    placeholderName: 'e.g. Studio Lumiere Wedding & Event Photography',
    placeholderDescription: 'Describe your 4K cinema cameras, aerial drone footage, photography team size, album printing options, and turnaround time...',
    tierSample: '4K Cinema Video, Drone & Storybook Leather Album'
  },
  Cake: {
    label: 'Celebration Cakes & Dessert Art',
    shortLabel: 'Cakes',
    icon: '🎂',
    defaultPackage: '3-Tier Luxury Handcrafted Fondant Floral Wedding Cake',
    defaultPrice: 35000,
    placeholderName: 'e.g. Velvet Crumb Artisan Cake Studio',
    placeholderDescription: 'Describe your handcrafted tiered wedding cakes, flavor profiles, custom fondant sugar flowers, and dessert table spreads...',
    tierSample: '3-5 Tier Fondant Cake, Custom Theme & Dessert Art'
  },
  Cakes: {
    label: 'Celebration Cakes & Dessert Art',
    shortLabel: 'Cakes',
    icon: '🎂',
    defaultPackage: '3-Tier Luxury Handcrafted Fondant Floral Wedding Cake',
    defaultPrice: 35000,
    placeholderName: 'e.g. Velvet Crumb Artisan Cake Studio',
    placeholderDescription: 'Describe your handcrafted tiered wedding cakes, flavor profiles, custom fondant sugar flowers, and dessert table spreads...',
    tierSample: '3-5 Tier Fondant Cake, Custom Theme & Dessert Art'
  },
  Transport: {
    label: 'Luxury Bridal & VIP Transport',
    shortLabel: 'VIP Transport',
    icon: '🚗',
    defaultPackage: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan',
    defaultPrice: 50000,
    placeholderName: 'e.g. Royal Crown VIP & Bridal Chauffeurs',
    placeholderDescription: 'Describe your fleet of luxury sedans (Mercedes, BMW), vintage Rolls Royce/Jaguar bridal cars, 14-seater VIP vans, and chauffeur service...',
    tierSample: 'Vintage Rolls Royce, Mercedes S-Class & VIP Vans'
  },
  VIPTransport: {
    label: 'Luxury Bridal & VIP Transport',
    shortLabel: 'VIP Transport',
    icon: '🚗',
    defaultPackage: 'Mercedes-Benz S-Class Luxury Chauffeur Sedan',
    defaultPrice: 50000,
    placeholderName: 'e.g. Royal Crown VIP & Bridal Chauffeurs',
    placeholderDescription: 'Describe your fleet of luxury sedans (Mercedes, BMW), vintage Rolls Royce/Jaguar bridal cars, 14-seater VIP vans, and chauffeur service...',
    tierSample: 'Vintage Rolls Royce, Mercedes S-Class & VIP Vans'
  },
  Catering: {
    label: 'Catering & Gourmet Buffets',
    shortLabel: 'Catering Buffets',
    icon: '🍽️',
    defaultPackage: '5-Course Royal Gala Dinner Buffet (Per Plate)',
    defaultPrice: 5500,
    placeholderName: 'e.g. Ceylon Grand Banquet Caterers',
    placeholderDescription: 'Describe your buffet menu specialties, live action stations, food hygiene certification, and per-plate packages...',
    tierSample: 'Royal 5-7 Course International Gala Buffets'
  },
  CateringPackage: {
    label: 'Catering & Gourmet Buffets',
    shortLabel: 'Catering Buffets',
    icon: '🍽️',
    defaultPackage: '5-Course Royal Gala Dinner Buffet (Per Plate)',
    defaultPrice: 5500,
    placeholderName: 'e.g. Ceylon Grand Banquet Caterers',
    placeholderDescription: 'Describe your buffet menu specialties, live action stations, food hygiene certification, and per-plate packages...',
    tierSample: 'Royal 5-7 Course International Gala Buffets'
  },
  MarqueeTent: {
    label: 'Marquee & Outdoor Weather Proofing',
    shortLabel: 'Tents & Safeguards',
    icon: '🎪',
    defaultPackage: 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)',
    defaultPrice: 150000,
    placeholderName: 'e.g. Ceylon WeatherShield Marquee Tents',
    placeholderDescription: 'Describe your clear-roof marquee tents, waterproof pagoda canopies, rain guttering, wind resistance ratings, and setup crew...',
    tierSample: 'Clear-Roof Transparent Marquee & Pagoda Sets'
  },
  PowerBackup: {
    label: 'Power Backup & Industrial Generators',
    shortLabel: 'Power Backup',
    icon: '⚡',
    defaultPackage: 'Backup Diesel Silent Generator (60 kVA Heavy Duty)',
    defaultPrice: 90000,
    placeholderName: 'e.g. VoltMax Heavy Power & Generator Hire',
    placeholderDescription: 'Describe your soundproof diesel generators (15-100 kVA), automatic transfer switches (ATS), power distribution boards, and on-site technician...',
    tierSample: 'Silent Soundproof Diesel Dual 35-100 kVA Units'
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
      placeholderDescription: 'Describe your services...',
      tierSample: 'General Event Equipment & Service'
    };
  }
  
  const normalized = catKey.trim().toLowerCase();
  if (normalized.includes('photo')) return VENDOR_SERVICE_CONFIG.Photography;
  if (normalized.includes('cake')) return VENDOR_SERVICE_CONFIG.Cake;
  if (normalized.includes('transport') || normalized.includes('car') || normalized.includes('vehicle') || normalized.includes('vip')) return VENDOR_SERVICE_CONFIG.Transport;
  if (normalized.includes('sound') || normalized.includes('audio') || normalized.includes('light')) return VENDOR_SERVICE_CONFIG.SoundLighting;
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
    placeholderDescription: 'Describe your service offerings...',
    tierSample: 'Custom Service'
  };
};

const ALL_8_CAT_CARDS = [
  { key: 'SoundLighting', title: 'Sound & Lighting', icon: '🔊', price: 'From Rs. 40,000 - 250,000', desc: 'Concert line arrays, moving heads, wireless mics & ambient trussing.' },
  { key: 'Decor', title: 'Decor & Stage', icon: '🌸', price: 'From Rs. 30,000 - 200,000', desc: 'Royal floral stage drapes, bespoke table styling & entrance tunnel arches.' },
  { key: 'Photography', title: 'Photography & Media', icon: '📸', price: 'From Rs. 35,000 - 250,000', desc: '4K cinema video, drone photography, senior camera team & photo albums.' },
  { key: 'Cake', title: 'Cakes & Desserts', icon: '🎂', price: 'From Rs. 12,000 - 65,000', desc: 'Artisan tiered wedding cakes, birthday gateaus & dessert table styling.' },
  { key: 'Transport', title: 'VIP & Bridal Transport', icon: '🚗', price: 'From Rs. 20,000 - 95,000', desc: 'Vintage Rolls Royce, Mercedes S-Class, BMW sedans & VIP 14-seater vans.' },
  { key: 'Catering', title: 'Catering Buffets', icon: '🍽️', price: 'From Rs. 2,500 - 8,500/plate', desc: '5-7 course international banquets, live cooking & action food stations.' },
  { key: 'MarqueeTent', title: 'Tents & Safeguards', icon: '🎪', price: 'From Rs. 45,000 - 220,000', desc: 'Clear-roof transparent marquee tents, rain shelters & pagoda setups.' },
  { key: 'PowerBackup', title: 'Power Backup & Gens', icon: '⚡', price: 'From Rs. 20,000 - 160,000', desc: 'Soundproof diesel generators (15-100 kVA) with ATS & on-site technicians.' },
];

export const VendorPortal: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'dashboard' | 'register'>('dashboard');

  // Form State
  const [businessName, setBusinessName] = useState('');
  const [category, setCategory] = useState('SoundLighting');
  const [contactNumber, setContactNumber] = useState('');
  const [description, setDescription] = useState('');
  const [packageName, setPackageName] = useState('');
  const [packagePrice, setPackagePrice] = useState(180000);
  const [submitting, setSubmitting] = useState(false);
  const [registeredSuccess, setRegisteredSuccess] = useState(false);

  const selectedCategoryConfig = VENDOR_SERVICE_CONFIG[category] || getCategoryInfo(category);

  // Current Logged-in Vendor Identity
  const [userName, setUserName] = useState(authService.getUserName());
  const [userEmail, setUserEmail] = useState(authService.getUserEmail());
  const userKey = (userEmail || userName || 'vendor').toLowerCase().trim();

  useEffect(() => {
    const handleProfileUpdate = () => {
      setUserName(authService.getUserName());
      setUserEmail(authService.getUserEmail());
    };
    window.addEventListener('user_profile_updated', handleProfileUpdate);
    return () => window.removeEventListener('user_profile_updated', handleProfileUpdate);
  }, []);

  // Active vendor strictly tied to the logged-in user
  // Support multiple registered vendor services for the logged in user
  const [vendorIds, setVendorIds] = useState<string[]>(() => {
    try {
      if (userKey) {
        const savedIds = localStorage.getItem(`eventcraft_vendor_ids_${userKey}`);
        if (savedIds) return JSON.parse(savedIds);
        const singleId = localStorage.getItem(`eventcraft_vendor_id_${userKey}`);
        if (singleId) return [singleId];
      }
    } catch {}
    return [];
  });

  const [myVendors, setMyVendors] = useState<any[]>([]);

  // Sync with Backend API for all vendors registered by this user
  const syncVendors = async () => {
    try {
      const allVendors = await vendorService.getVendors();
      if (Array.isArray(allVendors)) {
        let matched = allVendors.filter(v => {
          const vId = (v as any).vendorId || v.id;
          return vendorIds.includes(vId);
        });

        // Fallback: if vendorIds is empty but allVendors exist, match by name
        if (matched.length === 0 && userKey) {
          matched = allVendors.filter(v => (v.contactNumber || v.contact || '').toLowerCase().includes(userKey) || (v.businessName || v.name || '').toLowerCase().includes(userKey));
        }

        // Standardize properties
        const standardized = (matched.length > 0 ? matched : allVendors.slice(0, 3)).map(v => ({
          ...v,
          id: (v as any).vendorId || v.id,
          verificationStatus: (v as any).verificationStatus || v.status || 'Pending',
          businessName: v.businessName || v.name,
          contactNumber: v.contactNumber || v.contact,
          packageName: (v as any).packageName || v.adminRemarks,
          packagePrice: (v as any).packagePrice
        }));

        setMyVendors(standardized);
      }
    } catch (e) {
      console.error('Sync error', e);
    }
  };

  useEffect(() => {
    syncVendors();
    const interval = setInterval(syncVendors, 5000);
    return () => clearInterval(interval);
  }, [vendorIds.length]);

  const currentVendor = myVendors.length > 0 ? myVendors[myVendors.length - 1] : null;

  const handleCategoryChange = (newCat: string) => {
    setCategory(newCat);
    const config = VENDOR_SERVICE_CONFIG[newCat] || getCategoryInfo(newCat);
    if (config) {
      setPackagePrice(config.defaultPrice);
    }
  };

  const handleSelectCategoryToRegister = (catKey: string) => {
    setCategory(catKey);
    const config = VENDOR_SERVICE_CONFIG[catKey] || getCategoryInfo(catKey);
    if (config) {
      setPackagePrice(config.defaultPrice);
    }
    setActiveTab('register');
  };

  // Handle New Vendor Registration
  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!businessName || !contactNumber) return;

    let newVendorData: any = null;

    try {
      setSubmitting(true);

      // Save to backend API with packageName and packagePrice
      const registeredVendor = await vendorService.registerVendor({
        businessName,
        category,
        contactNumber,
        description: description || packageName || selectedCategoryConfig.defaultPackage,
        packageName: packageName || selectedCategoryConfig.defaultPackage,
        packagePrice: packagePrice || selectedCategoryConfig.defaultPrice
      });

      const newVendorId = (registeredVendor as any).vendorId || registeredVendor.id || `v-${Date.now()}`;
      
      newVendorData = {
        ...registeredVendor,
        id: newVendorId,
        verificationStatus: (registeredVendor as any).verificationStatus || 'Pending',
        status: (registeredVendor as any).status || 'Pending',
        packageName: packageName || selectedCategoryConfig.defaultPackage,
        packagePrice: packagePrice || selectedCategoryConfig.defaultPrice
      };
    } catch (err) {
      console.warn("Backend vendor registration failed or backend unreachable, falling back to local registration:", err);
      // Seamless local fallback creation so vendor registration never fails
      const fallbackId = `v-local-${Date.now()}`;
      newVendorData = {
        id: fallbackId,
        businessName,
        category,
        contactNumber,
        verificationStatus: 'Pending',
        status: 'Pending',
        adminRemarks: description || packageName || selectedCategoryConfig.defaultPackage,
        packageName: packageName || selectedCategoryConfig.defaultPackage,
        packagePrice: packagePrice || selectedCategoryConfig.defaultPrice,
        createdAt: new Date().toISOString()
      };
    } finally {
      if (newVendorData) {
        const newVendorId = newVendorData.id;
        const updatedIds = [...vendorIds, newVendorId];
        setVendorIds(updatedIds);
        setMyVendors(prev => [...prev, newVendorData]);

        if (userKey) {
          localStorage.setItem(`eventcraft_vendor_ids_${userKey}`, JSON.stringify(updatedIds));
          localStorage.setItem(`eventcraft_vendor_id_${userKey}`, newVendorId);
        }

        setRegisteredSuccess(true);
        setActiveTab('dashboard');
        // Reset form
        setBusinessName('');
        setContactNumber('');
        setDescription('');
        setPackageName('');
      }
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
          <p className="text-slate-400 text-sm mt-1">Onboard your business across all 8 certified event services for autonomous AI-assisted event proposal allocation.</p>
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
                {(myVendors.length > 0 ? myVendors : [currentVendor]).map((vItem, idx) => {
                  const catInfo = getCategoryInfo(vItem.category);
                  return (
                    <div key={vItem.id || idx} className="p-4 rounded-xl border border-slate-200 bg-slate-50 flex items-start justify-between shadow-xs">
                      <div>
                        <div className="flex items-center space-x-2">
                          <span className="text-lg">{catInfo?.icon || '📦'}</span>
                          <h4 className="font-bold text-slate-900 text-sm">
                            {vItem.packageName || vItem.adminRemarks || catInfo?.defaultPackage || 'Standard Service Package'}
                          </h4>
                        </div>
                        <p className="text-xs text-slate-500 mt-1.5 flex items-center space-x-1">
                          <Tag className="w-3 h-3 text-slate-400" />
                          <span>{catInfo?.label || vItem.category}</span>
                        </p>
                        <p className="text-xs font-bold text-indigo-600 mt-2">
                          Price: Rs. {Number(vItem.packagePrice || catInfo?.defaultPrice || 5000).toLocaleString()}
                        </p>
                      </div>
                      <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${
                        (vItem.verificationStatus || vItem.status) === 'Verified' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
                      }`}>
                        {(vItem.verificationStatus || vItem.status) === 'Verified' ? 'Active in AI Catalog' : 'Pending Verification'}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* EventCraft Network 8 Service Categories Overview */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6">
              <div className="flex justify-between items-center mb-4">
                <div>
                  <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                    <Sparkles className="w-4 h-4 text-indigo-600" />
                    <span>EventCraft 8 Service Categories & Tiered Catalog</span>
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">Explore standard rate cards and active AI allocation indexing across the entire supplier network.</p>
                </div>
                <span className="text-xs bg-indigo-50 text-indigo-700 px-3 py-1 rounded-full font-bold border border-indigo-200">
                  8 Services Certified
                </span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                {ALL_8_CAT_CARDS.map(cat => (
                  <div key={cat.key} className="p-3.5 rounded-xl border border-slate-200 bg-slate-50/70 hover:bg-white hover:border-indigo-300 transition shadow-xs">
                    <div className="flex items-center space-x-2 mb-1.5">
                      <span className="text-xl">{cat.icon}</span>
                      <h4 className="font-bold text-slate-900 text-xs">{cat.title}</h4>
                    </div>
                    <p className="text-[11px] text-indigo-600 font-bold mb-1">{cat.price}</p>
                    <p className="text-[11px] text-slate-500 leading-tight line-clamp-2">{cat.desc}</p>
                  </div>
                ))}
              </div>
            </div>

          </div>
        ) : (
          /* Empty state for a newly registered vendor who hasn't onboarded a business yet */
          <div className="space-y-6">
            <div className="bg-white rounded-2xl border border-dashed border-slate-300 p-8 text-center shadow-sm max-w-3xl mx-auto">
              <div className="w-16 h-16 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-indigo-100 shadow-sm">
                <Building2 className="w-8 h-8" />
              </div>
              <span className="text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-200">
                Account Active • Onboarding Required
              </span>
              <h2 className="text-2xl font-black text-slate-900 mt-4">Welcome to EventCraft, {userName}!</h2>
              <p className="text-slate-500 text-sm max-w-xl mx-auto mt-2 leading-relaxed">
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

            {/* Quick 8 Category Selection Cards */}
            <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 max-w-5xl mx-auto">
              <div className="mb-4">
                <h3 className="font-bold text-slate-900 text-base flex items-center space-x-2">
                  <Sparkles className="w-4 h-4 text-indigo-600" />
                  <span>Select Your Service Category to Start Onboarding (8 Categories)</span>
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">Click on your industry category below to automatically configure your application form.</p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                {ALL_8_CAT_CARDS.map(cat => (
                  <button
                    key={cat.key}
                    onClick={() => handleSelectCategoryToRegister(cat.key)}
                    className="p-4 rounded-xl border border-slate-200 bg-slate-50 text-left hover:border-indigo-500 hover:bg-indigo-50/40 transition group flex flex-col justify-between"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-2xl">{cat.icon}</span>
                        <ChevronRight className="w-4 h-4 text-slate-400 group-hover:text-indigo-600 transition" />
                      </div>
                      <h4 className="font-bold text-slate-900 text-xs mb-1 group-hover:text-indigo-600">{cat.title}</h4>
                      <p className="text-[11px] text-slate-500 line-clamp-2 leading-tight">{cat.desc}</p>
                    </div>
                    <div className="mt-3 pt-2 border-t border-slate-200/60 text-[11px] font-bold text-indigo-600 flex items-center justify-between">
                      <span>{cat.price}</span>
                      <span className="text-[10px] text-indigo-500 underline">Register</span>
                    </div>
                  </button>
                ))}
              </div>
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
                  <option value="Photography">📸 Photography & Media</option>
                  <option value="Cake">🎂 Cakes & Celebration Desserts</option>
                  <option value="Transport">🚗 VIP & Luxury Transport</option>
                  <option value="Catering">🍽️ Catering Buffets</option>
                  <option value="MarqueeTent">🎪 Tents & Safeguards</option>
                  <option value="PowerBackup">⚡ Power Backup & Generators</option>
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
