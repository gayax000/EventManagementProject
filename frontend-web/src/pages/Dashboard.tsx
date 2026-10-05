import React, { useState, useEffect } from 'react';
import { 
  Calendar, 
  Users, 
  DollarSign, 
  CloudRain, 
  CheckCircle, 
  Clock, 
  Sparkles,
  RefreshCw, 
  Image as ImageIcon,
  Eye, 
  X, 
  MapPin, 
  Check, 
  ShieldCheck, 
  Sun, 
  Search, 
  LogIn,
  UserPlus,
  ArrowRight,
  Star,
  Music,
  Camera,
  Layers,
  Info,
  Building2,
  ChevronRight,
  LogOut,
  Award,
  Lock,
  Mail,
  User,
  Phone,
  AlertTriangle,
  Trash2,
  Bell
} from 'lucide-react';
import { eventService, vendorService, notificationService, type EventItem, type VendorItem, type ManagerNotificationItem } from '../services/api';
import { authService } from '../services/authService';

const getEventTypeIcon = (type?: string) => {
  if (!type) return '🎉';
  const lower = type.toLowerCase();
  if (lower.includes('wedding')) return '💍';
  if (lower.includes('birthday')) return '🎂';
  if (lower.includes('engagement') || lower.includes('anniversary')) return '🥂';
  if (lower.includes('corporate') || lower.includes('launch') || lower.includes('award') || lower.includes('gala')) return '🏢';
  return '🎉';
};

// Curated Showcase Gallery of Luxury Celebrations
const CURATED_SHOWCASE_PHOTOS = [
  {
    id: 'ballroom',
    title: 'Royal Grand Ballroom & Crystal Chandeliers',
    category: 'Grand Ballrooms & Venues',
    icon: '🏛️',
    description: 'Opulent 5-star banquet halls with crystal chandelier lighting, round banquet dining, and climate-controlled elegance.',
    imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1200&q=80',
    tag: '5-Star Luxury'
  },
  {
    id: 'outdoor',
    title: 'Sunset Garden & Coastal Reception',
    category: 'Scenic Outdoor Lawns',
    icon: '🌴',
    description: 'Enchanting open-air celebrations beneath fairy-light canopies, backed by automated environmental weather safeguards.',
    imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1200&q=80',
    tag: 'Weather Protected'
  },
  {
    id: 'sound',
    title: 'Concert Line-Array Sound & Beam Lighting',
    category: 'Sound & Intelligent Lighting',
    icon: '🔊',
    description: 'Acoustic line-array audio rigs, digital mixing consoles, and programmable moving-head trusses for electrifying atmospheres.',
    imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1200&q=80',
    tag: 'Tour-Grade Rig'
  },
  {
    id: 'decor',
    title: 'Fresh Floral Stage Cascades & Ceiling Drapes',
    category: 'Floral Art & Stage Design',
    icon: '🌸',
    description: 'Bespoke thematic floral backdrops, entrance tunnel archways, geometric frames, and luxurious ambient tablescapes.',
    imageUrl: 'https://images.unsplash.com/photo-1520854221256-17451cc331bf?auto=format&fit=crop&w=1200&q=80',
    tag: 'Master Florists'
  },
  {
    id: 'cake',
    title: 'Artisanal Fondant Celebration Cakes',
    category: 'Celebration Cakes & Dessert Art',
    icon: '🎂',
    description: 'Handcrafted 3-to-5 tier fondant showstoppers decorated with handcrafted edible sugar blooms and custom branding.',
    imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?auto=format&fit=crop&w=1200&q=80',
    tag: 'Bespoke Confectionery'
  },
  {
    id: 'photo',
    title: 'Cinematic 4K Media & Aerial Drone Coverage',
    category: 'Photography & Cinematography',
    icon: '📸',
    description: 'Award-winning photojournalism, cinematic 4K video reels, drone captures, and handcrafted leather-bound albums.',
    imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=1200&q=80',
    tag: '4K Deliverables'
  }
];

const WEATHER_SAFEGUARD_CATALOG = [
  { id: 'tent_large_premium', name: 'Heavy-Duty Aluminium Marquee Structure & Rain Sidewalls', cost: 150000, desc: '200+ Guests (Grand Outdoor)' },
  { id: 'tent_large_std', name: 'Standard Large-Capacity Rain Canopy Pavilion', cost: 100000, desc: '200+ Guests (Economy Outdoor)' },
  { id: 'tent_med_premium', name: 'Waterproof Stretch Canopy & Rain Drapes', cost: 85000, desc: '100-200 Guests (Standard Outdoor)' },
  { id: 'tent_med_std', name: 'Standard Medium-Capacity Waterproof Pavilion', cost: 60000, desc: '100-200 Guests (Economy Outdoor)' },
  { id: 'tent_compact_std', name: 'Standard High-Peak Modular Canopies', cost: 45000, desc: '<100 Guests (Compact Outdoor)' },
  { id: 'tent_compact_budget', name: 'Economy Compact Rain Protection Canopies', cost: 25000, desc: '<100 Guests (Budget Auto-Fit)' }
];

interface DashboardProps {
  onAuthChange?: () => void;
  onNavigateLogin?: () => void;
  onNavigateRegister?: () => void;
}

export const Dashboard: React.FC<DashboardProps> = ({ 
  onAuthChange,
  onNavigateLogin,
  onNavigateRegister 
}) => {
  const [events, setEvents] = useState<EventItem[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<EventItem | null>(null);
  const [viewModalEvent, setViewModalEvent] = useState<EventItem | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [specialDiscount, setSpecialDiscount] = useState<number>(0);
  const [customAddonCost, setCustomAddonCost] = useState<number>(0);
  const [actionSuccess, setActionSuccess] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [previewImage, setPreviewImage] = useState<string | null>(null);
  const [eventFilterTab, setEventFilterTab] = useState<'all' | 'pending' | 'approved'>('all');
  const [eventSearchQuery, setEventSearchQuery] = useState('');

  const formatEventDate = (rawDateStr: string | undefined | null) => {
    if (!rawDateStr) return '';
    if (rawDateStr.includes('-')) {
      const dateOnlyPart = rawDateStr.split('T')[0];
      const parts = dateOnlyPart.split('-').map(Number);
      if (parts.length >= 3 && parts[0] && parts[1] && parts[2]) {
        return new Date(parts[0], parts[1] - 1, parts[2]).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
      }
    }
    return new Date(rawDateStr).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
  };

  // Custom Delete Confirmation Modal State
  const [deleteModal, setDeleteModal] = useState<{
    isOpen: boolean;
    eventId: string;
    eventTitle: string;
    isDeleting: boolean;
  } | null>(null);

  // Budget Guardrails & Human-in-the-Loop Management State
  const [isBudgetAutoFitted, setIsBudgetAutoFitted] = useState<boolean>(false);
  const [preFitSnapshot, setPreFitSnapshot] = useState<{
    vendorAssignments: Record<string, any>;
    perPlateCost: number | null;
    tentCost: number | null;
    specialDiscount: number;
  } | null>(null);
  const [clientApprovalRequested, setClientApprovalRequested] = useState<boolean>(false);
  const [specialAllocation, setSpecialAllocation] = useState<number>(0);
  const [customHallCost, setCustomHallCost] = useState<number | null>(null);
  const [customPerPlateCost, setCustomPerPlateCost] = useState<number | null>(null);
  const [customSoundsCost, setCustomSoundsCost] = useState<number | null>(null);
  const [customDecoCost, setCustomDecoCost] = useState<number | null>(null);
  const [customPhotoCost, setCustomPhotoCost] = useState<number | null>(null);
  const [customCakeCost, setCustomCakeCost] = useState<number | null>(null);
  const [customTransportCost, setCustomTransportCost] = useState<number | null>(null);
  const [customTentCost, setCustomTentCost] = useState<number | null>(null);
  const [selectedWeatherOptionId, setSelectedWeatherOptionId] = useState<string | null>(null);

  // Manager Notifications System State
  const [managerNotifications, setManagerNotifications] = useState<ManagerNotificationItem[]>([]);
  const [unreadCount, setUnreadCount] = useState<number>(0);
  const [showNotificationMenu, setShowNotificationMenu] = useState<boolean>(false);

  const fetchManagerNotifications = async () => {
    try {
      const data = await notificationService.getManagerNotifications();
      if (data) {
        setManagerNotifications(data.notifications || []);
        setUnreadCount(data.unreadCount || 0);
      }
    } catch (err) {
      console.error("Failed to fetch manager notifications", err);
    }
  };

  const handleMarkAsRead = async (notificationId: string, eventId?: string) => {
    try {
      await notificationService.markAsRead(notificationId);
      setManagerNotifications(prev => prev.map(n => n.notificationId === notificationId ? { ...n, isRead: true } : n));
      setUnreadCount(prev => Math.max(0, prev - 1));
      if (eventId) {
        const targetEvent = events.find(e => e.eventId === eventId);
        if (targetEvent) {
          setSelectedEvent(targetEvent);
          setShowNotificationMenu(false);
        }
      }
    } catch (err) {
      console.error("Failed to mark notification as read", err);
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await notificationService.markAllAsRead();
      setManagerNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
      setUnreadCount(0);
    } catch (err) {
      console.error("Failed to mark all notifications as read", err);
    }
  };

  useEffect(() => {
    fetchManagerNotifications();
    const interval = setInterval(fetchManagerNotifications, 10000);
    return () => clearInterval(interval);
  }, []);

  // Verified Vendors & Assignment State
  const [availableVendors, setAvailableVendors] = useState<VendorItem[]>([]);
  const [selectedVendorAssignments, setSelectedVendorAssignments] = useState<Record<string, { 
    vendorId: string; 
    vendorName: string; 
    packageName?: string;
    agreedPayout?: number;
    catalogPrice?: number;
    isCustomPackage?: boolean;
    isPending?: boolean;
  }>>({});

  const loadVendors = async () => {
    try {
      const data = await vendorService.getVendors();
      if (Array.isArray(data)) {
        const verified = data.filter((v: any) => v.verificationStatus === 'Verified' || v.status === 'Verified');
        setAvailableVendors(prev => {
          const prevKey = prev.map(v => `${v.vendorId || (v as any).id}:${v.packagePrice}:${v.packageName}`).join('|');
          const nextKey = verified.map((v: any) => `${v.vendorId || v.id}:${v.packagePrice}:${v.packageName}`).join('|');
          return prevKey === nextKey ? prev : verified;
        });
      }
    } catch (err) {
      console.error("Failed to load verified vendors", err);
    }
  };

  const getVerifiedVendorsForCategory = (catKey: string) => {
    const norm = catKey.toLowerCase().trim();
    return availableVendors.filter(v => {
      // Must be verified and have an active package name with price > 0
      if ((v.verificationStatus || (v as any).status) !== 'Verified') return false;
      if (!v.packageName || !v.packagePrice || Number(v.packagePrice) <= 0) return false;

      const vCat = (v.category || '').toLowerCase().trim();
      if (norm.includes('photo') || norm.includes('media')) return vCat.includes('photo');
      if (norm.includes('sound') || norm.includes('audio') || norm.includes('light')) return vCat.includes('sound') || vCat.includes('audio');
      if (norm.includes('deco') || norm.includes('flower') || norm.includes('floral')) return vCat.includes('decor') || vCat.includes('flower') || vCat.includes('floral');
      if (norm.includes('cake')) return vCat.includes('cake');
      if (norm.includes('transport') || norm.includes('car') || norm.includes('vip')) return vCat.includes('transport') || vCat.includes('car') || vCat.includes('vip');
      if (norm.includes('cater') || norm.includes('buffet') || norm.includes('food')) return vCat.includes('cater') || vCat.includes('food');
      if (norm.includes('refresh') || norm.includes('drink') || norm.includes('tea') || norm.includes('coffee')) return vCat.includes('refresh') || vCat.includes('tea') || vCat.includes('coffee') || vCat.includes('drink');
      if (norm.includes('tent') || norm.includes('marquee') || norm.includes('weather')) return vCat.includes('tent') || vCat.includes('marquee') || vCat.includes('weather');
      if (norm.includes('power') || norm.includes('generator') || norm.includes('gen')) return vCat.includes('power') || vCat.includes('gen');
      return vCat.includes(norm) || norm.includes(vCat);
    });
  };

  // Autonomous Vendor Allocation Algorithm based on client event budget tier
  const autoAllocateVendorForCategory = (catKey: string, budget: number) => {
    const matching = getVerifiedVendorsForCategory(catKey);
    if (!matching || matching.length === 0) return null;
    
    // Sort by packagePrice ascending (Budget to Luxury)
    const sorted = [...matching].sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0));
    
    let targetIndex = 0;
    if (budget >= 2000000) {
      targetIndex = sorted.length - 1; // Luxury tier
    } else if (budget >= 1200000) {
      targetIndex = Math.min(sorted.length - 1, Math.max(0, sorted.length - 2)); // Premium tier
    } else if (budget >= 700000) {
      targetIndex = Math.min(sorted.length - 1, 1); // Mid tier
    } else {
      targetIndex = 0; // Budget tier
    }
    
    return sorted[targetIndex] || sorted[0];
  };

  // Authentication State & Modal
  const [isUserLoggedIn, setIsUserLoggedIn] = useState<boolean>(authService.isLoggedIn());
  const [currentUserName, setCurrentUserName] = useState<string>(authService.getUserName());
  const [currentUserRole, setCurrentUserRole] = useState<string>(authService.getUserRole());
  const [authModalTab, setAuthModalTab] = useState<'login' | 'register' | null>(null);

  // Auth Form Inputs
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [regFullName, setRegFullName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPhone, setRegPhone] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regRole, setRegRole] = useState<string>('Customer');
  const [authLoading, setAuthLoading] = useState(false);
  const [authError, setAuthError] = useState<string | null>(null);

  const refreshAuthStatus = () => {
    const loggedIn = authService.isLoggedIn();
    setIsUserLoggedIn(loggedIn);
    setCurrentUserName(authService.getUserName());
    setCurrentUserRole(authService.getUserRole());
  };

  // Fetch Live Events from Backend
  const loadEvents = async () => {
    try {
      setLoading(true);
      const data = await eventService.getMyEvents();
      setEvents(data);
      if (data.length > 0 && !selectedEvent) {
        setSelectedEvent(data[0]);
      }
    } catch (err) {
      console.error("Failed to load events from backend", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refreshAuthStatus();
    loadEvents();
    loadVendors();
    const interval = setInterval(loadVendors, 5000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (selectedEvent) {
      let currentMap: Record<string, { 
        vendorId: string; 
        vendorName: string; 
        packageName?: string; 
        agreedPayout?: number; 
        catalogPrice?: number;
        isCustomPackage?: boolean;
        isPending?: boolean;
      }> = {};
      
      // 1. Load previously saved assignments if present
      const evBudgetNum = Number(selectedEvent.budgetLimit) || 1000000;
      const isLegacyTentAssignment = (a: any) =>
        a?.category === 'MarqueeTent' &&
        evBudgetNum >= 2000000 &&
        (a?.packagePrice === 150000 || a?.agreedPayout === 150000) &&
        (!a?.packageName || a.packageName.includes('Aluminium') || a.packageName.includes('Autonomous') || a.packageName.includes('Auto-injected'));

      if (selectedEvent.assignedVendors && Array.isArray(selectedEvent.assignedVendors) && selectedEvent.assignedVendors.length > 0) {
        selectedEvent.assignedVendors.forEach(a => {
          if (a.category && !isLegacyTentAssignment(a)) {
            const matchVendor = availableVendors.find(v => (v.vendorId || (v as any).id) === a.vendorId);
            currentMap[a.category] = {
              vendorId: a.vendorId || '',
              vendorName: a.vendorName || '',
              packageName: a.packageName,
              agreedPayout: a.packagePrice ?? a.agreedPayout,
              catalogPrice: matchVendor?.packagePrice || a.packagePrice || a.agreedPayout
            };
          }
        });
      } else if (selectedEvent.assignedVendorsJson) {
        try {
          const parsed = JSON.parse(selectedEvent.assignedVendorsJson);
          if (Array.isArray(parsed) && parsed.length > 0) {
            parsed.forEach((a: any) => {
              if (a.category && !isLegacyTentAssignment(a)) {
                const matchVendor = availableVendors.find(v => (v.vendorId || (v as any).id) === a.vendorId);
                currentMap[a.category] = {
                  vendorId: a.vendorId || '',
                  vendorName: a.vendorName || '',
                  packageName: a.packageName,
                  agreedPayout: a.packagePrice ?? a.agreedPayout,
                  catalogPrice: matchVendor?.packagePrice || a.packagePrice || a.agreedPayout
                };
              }
            });
          }
        } catch {}
      }

      // 2. Autonomous Verified Vendor Auto-Allocation
      // Matches real verified vendors in the DB based on client budget tier
      const budget = Number(selectedEvent.budgetLimit) || 1000000;
      const services = selectedEvent.selectedServices || [];

      // Catering
      const isHotelInHouse = Boolean(selectedEvent.banquetHallId || (selectedEvent.banquetHallName && !selectedEvent.banquetHallName.toLowerCase().includes('private')));
      if (isHotelInHouse) {
        currentMap['Catering'] = {
          vendorId: 'hotel-in-house',
          vendorName: `${selectedEvent.banquetHallName || selectedEvent.venueName || 'Hotel'} Culinary & Banquet Team`,
          packageName: `${selectedEvent.cateringStyle || 'Hotel Banquet Buffet'} (Contracted Hotel Catering)`,
          agreedPayout: (selectedEvent.perPlatePrice || 5000) * (selectedEvent.guestCount || 100)
        };
      } else if (!currentMap['Catering']) {
        const cat = autoAllocateVendorForCategory('Catering', budget);
        if (cat) {
          currentMap['Catering'] = {
            vendorId: cat.vendorId || (cat as any).id,
            vendorName: cat.businessName || cat.name,
            packageName: cat.packageName,
            agreedPayout: cat.packagePrice
          };
        }
      }

      // Refreshments (Preserves client-selected refreshment items)

      // Sound & Lighting
      const needsSounds = services.some(s => s.toLowerCase().includes('sound') || s.toLowerCase().includes('lighting') || s.toLowerCase().includes('audio'));
      if (needsSounds && !currentMap['SoundLighting']) {
        const snd = autoAllocateVendorForCategory('SoundLighting', budget);
        if (snd) {
          currentMap['SoundLighting'] = {
            vendorId: snd.vendorId || (snd as any).id,
            vendorName: snd.businessName || snd.name,
            packageName: snd.packageName,
            agreedPayout: snd.packagePrice,
            catalogPrice: snd.packagePrice
          };
        }
      }

      // Theme Decor
      const needsDeco = services.some(s => s.toLowerCase().includes('deco') || s.toLowerCase().includes('floral') || s.toLowerCase().includes('flower'));
      if (needsDeco && !currentMap['Decor']) {
        const dec = autoAllocateVendorForCategory('Decor', budget);
        if (dec) {
          currentMap['Decor'] = {
            vendorId: dec.vendorId || (dec as any).id,
            vendorName: dec.businessName || dec.name,
            packageName: dec.packageName,
            agreedPayout: dec.packagePrice,
            catalogPrice: dec.packagePrice
          };
        }
      }

      // Photography & Cinematography (Unseeded for viva demo)
      const needsPhoto = services.some(s => s.toLowerCase().includes('photo') || s.toLowerCase().includes('media'));
      if (needsPhoto && (!currentMap['Photography'] || currentMap['Photography'].isPending)) {
        const pht = autoAllocateVendorForCategory('Photography', budget);
        if (pht) {
          currentMap['Photography'] = {
            vendorId: pht.vendorId || (pht as any).id,
            vendorName: pht.businessName || pht.name,
            packageName: pht.packageName,
            agreedPayout: pht.packagePrice,
            catalogPrice: pht.packagePrice,
            isPending: false
          };
        } else {
          currentMap['Photography'] = {
            vendorId: '',
            vendorName: 'Awaiting Live Registration (Pending Viva Demo)',
            isPending: true
          };
        }
      }

      // Celebration Cakes
      const needsCake = services.some(s => s.toLowerCase().includes('cake'));
      if (needsCake && !currentMap['Cake']) {
        const ck = autoAllocateVendorForCategory('Cake', budget);
        if (ck) {
          currentMap['Cake'] = {
            vendorId: ck.vendorId || (ck as any).id,
            vendorName: ck.businessName || ck.name,
            packageName: ck.packageName,
            agreedPayout: ck.packagePrice,
            catalogPrice: ck.packagePrice
          };
        }
      }

      // VIP Transport
      const needsTransport = services.some(s => s.toLowerCase().includes('transport') || s.toLowerCase().includes('car') || s.toLowerCase().includes('bridal'));
      if (needsTransport && !currentMap['Transport']) {
        const trn = autoAllocateVendorForCategory('Transport', budget);
        if (trn) {
          currentMap['Transport'] = {
            vendorId: trn.vendorId || (trn as any).id,
            vendorName: trn.businessName || trn.name,
            packageName: trn.packageName,
            agreedPayout: trn.packagePrice,
            catalogPrice: trn.packagePrice
          };
        }
      }

      // Marquee Tent (if outdoor and weather safeguard required)
      let evWeather: any = selectedEvent.weatherAssessment;
      if (typeof evWeather === 'string' && evWeather.trim().startsWith('{')) {
        try { evWeather = JSON.parse(evWeather); } catch {}
      }
      const evRainPct = evWeather ? (evWeather.rainProbabilityPercent ?? evWeather.RainProbabilityPercent ?? 0) : 65;
      const evSafeguardCost = evWeather ? (evWeather.safeguardCost ?? evWeather.SafeguardCost ?? 0) : 0;
      const needsWeatherTent = Boolean(selectedEvent.isOutdoor && (evSafeguardCost > 0 || evRainPct >= 60));

      if (needsWeatherTent && !currentMap['MarqueeTent']) {
        const tnt = autoAllocateVendorForCategory('MarqueeTent', budget);
        if (tnt) {
          currentMap['MarqueeTent'] = {
            vendorId: tnt.vendorId || (tnt as any).id,
            vendorName: tnt.businessName || tnt.name,
            packageName: tnt.packageName,
            agreedPayout: tnt.packagePrice,
            catalogPrice: tnt.packagePrice
          };
        }
      }

      setSelectedVendorAssignments(currentMap);
    } else {
      setSelectedVendorAssignments({});
    }
  }, [selectedEvent?.eventId, selectedEvent?.assignedVendorsJson, availableVendors]);

  // Fetch proposal details to synchronize real database pricing and inspiration photos
  useEffect(() => {
    if (selectedEvent?.eventId) {
      setIsBudgetAutoFitted(false);
      setClientApprovalRequested(false);
      setSpecialDiscount(0);
      setSpecialAllocation(0);
      setCustomHallCost(null);
      setCustomPerPlateCost(null);
      setCustomSoundsCost(null);
      setCustomDecoCost(null);
      setCustomPhotoCost(null);
      setCustomCakeCost(null);
      setCustomTransportCost(null);
      setCustomTentCost(null);
      eventService.getProposal(selectedEvent.eventId)
        .then(p => {
          if (p) {
            if (p.specialRequestAllocation && p.specialRequestAllocation > 0) {
              setSpecialAllocation(p.specialRequestAllocation);
            } else {
              setSpecialAllocation(0);
            }
            let parsedImages: string[] = [];
            if (Array.isArray(p.inspirationImages) && p.inspirationImages.length > 0) {
              parsedImages = p.inspirationImages;
            } else if (p.inspirationImageUrl) {
              const raw = p.inspirationImageUrl.trim();
              if (raw.startsWith('[')) {
                try { parsedImages = JSON.parse(raw); } catch (e) { parsedImages = [raw]; }
              } else if (raw.includes('|||')) {
                parsedImages = raw.split('|||').filter(Boolean);
              } else {
                parsedImages = [raw];
              }
            }

            let weatherObj: any = null;
            if (p.weatherAssessment) {
              if (typeof p.weatherAssessment === 'string') {
                try { weatherObj = JSON.parse(p.weatherAssessment); } catch (e) { }
              } else {
                weatherObj = p.weatherAssessment;
              }
            }

            setSelectedEvent(prev => (prev && prev.eventId === selectedEvent.eventId) ? { 
              ...prev, 
              status: p.status || prev.status,
              revisionNotes: p.revisionNotes ?? prev.revisionNotes,
              estimatedTotalCost: p.estimatedTotalCost ?? prev.estimatedTotalCost,
              eventType: p.eventType || prev.eventType,
              venueName: p.venueName || prev.venueName,
              banquetHallName: p.banquetHallName || prev.banquetHallName,
              hallRentalPrice: p.hallRentalPrice ?? prev.hallRentalPrice,
              perPlatePrice: p.perPlatePrice ?? prev.perPlatePrice,
              isOutdoor: p.isOutdoor ?? prev.isOutdoor,
              additionalDetails: p.additionalDetails || prev.additionalDetails,
              weatherAssessment: weatherObj || prev.weatherAssessment,
              selectedServices: p.selectedServices || prev.selectedServices,
              tableRefreshments: p.tableRefreshments || prev.tableRefreshments,
              inspirationImages: parsedImages.length > 0 ? parsedImages : (prev.inspirationImages || []),
            } : prev);
          }
        })
        .catch(e => console.log("Proposal fetch info", e));
    }
  }, [selectedEvent?.eventId]);

  // Auth Handlers
  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!loginEmail || !loginPassword) {
      setAuthError('Please provide both email and password.');
      return;
    }
    setAuthLoading(true);
    setAuthError(null);
    const success = await authService.login(loginEmail, loginPassword);
    setAuthLoading(false);
    if (success) {
      const role = authService.getUserRole();
      if (role === 'Customer') {
        authService.logout();
        setAuthError('Access Restricted: This web portal is exclusively for Vendors, Suppliers, and Administrators. Clients please use the Client Mobile App.');
        return;
      }
      refreshAuthStatus();
      setAuthModalTab(null);
      setActionSuccess(`Welcome back, ${authService.getUserName()}!`);
      loadEvents();
      if (onAuthChange) onAuthChange();
    } else {
      setAuthError('Invalid credentials. Please verify your email and password.');
    }
  };

  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!regFullName || !regEmail || !regPhone || !regPassword) {
      setAuthError('Please fill in all registration fields.');
      return;
    }
    setAuthLoading(true);
    setAuthError(null);
    // Strictly register as 'Vendor'
    const success = await authService.register(regFullName, regEmail, regPassword, regPhone, 'Vendor');
    setAuthLoading(false);
    if (success) {
      // Auto-login or navigate to login tab
      const loginSuccess = await authService.login(regEmail, regPassword);
      if (loginSuccess) {
        refreshAuthStatus();
        setAuthModalTab(null);
        setActionSuccess(`Registration successful! Welcome to EventCraft, ${regFullName}!`);
        loadEvents();
        if (onAuthChange) onAuthChange();
      } else {
        setActionSuccess('Vendor account created successfully! Please sign in with your credentials.');
      }
    } else {
      setAuthError('Registration failed. The email address might already be registered.');
    }
  };

  const handleLogout = () => {
    authService.logout();
    refreshAuthStatus();
    setActionSuccess('You have signed out successfully.');
    if (onAuthChange) onAuthChange();
  };

  // Smart AI Tiered Resource Allocation Engine (Budget & Event-Type Context Aware)
  const getAllocations = (
    ev: EventItem | null, 
    forceAutoFit: boolean = false, 
    customSpecialAllocation?: number,
    overridePhotoCost?: number | null,
    overrideDecoCost?: number | null,
    overrideSoundsCost?: number | null,
    overrideCakeCost?: number | null,
    overrideTransportCost?: number | null
  ) => {
    if (!ev) {
      return {
        hasSounds: false, soundsCost: 0, soundsName: '',
        hasDeco: false, decoCost: 0, decoName: '',
        hasPhoto: false, photoCost: 0, photoName: '',
        hasCake: false, cakeCost: 0, cakeLabel: '',
        hasTransport: false, transportCost: 0, transportName: '',
        hasSpecialRequests: false, otherCost: 0,
      };
    }

    const budget = Number(ev.budgetLimit) || 1000000;
    const eventType = (ev.eventType || 'Wedding').toLowerCase();
    const services = ev.selectedServices || [];

    // 1. Sound & Lighting
    const hasSounds = services.some(s => s.toLowerCase().includes('sound') || s.toLowerCase().includes('lighting') || s.toLowerCase().includes('audio')) || (overrideSoundsCost !== null && overrideSoundsCost !== undefined);
    let soundsCost = 0;
    let soundsName = 'Sound & Stage Lighting';
    if (hasSounds) {
      if (overrideSoundsCost !== undefined && overrideSoundsCost !== null) {
        soundsCost = overrideSoundsCost;
        soundsName = selectedVendorAssignments['SoundLighting']?.packageName || `Sound & Stage Lighting (Adjusted: Rs. ${soundsCost.toLocaleString()})`;
      } else if (selectedVendorAssignments['SoundLighting']?.agreedPayout) {
        soundsCost = selectedVendorAssignments['SoundLighting'].agreedPayout;
        soundsName = selectedVendorAssignments['SoundLighting'].packageName || 'Standard Stage Audio + Warm Ambient LED PAR Cans';
      } else if (budget >= 2000000) {
        soundsCost = 250000;
        soundsName = 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses';
      } else if (budget >= 1200000) {
        soundsCost = 180000;
        soundsName = 'Concert Line-Array Sound & Digital Mixer Package';
      } else if (budget >= 700000) {
        soundsCost = 85000;
        soundsName = 'Standard Stage Audio + Warm Ambient LED PAR Cans';
      } else {
        soundsCost = 40000;
        soundsName = 'Compact Speech PA Kit + 2 Wireless Mics';
      }
    }

    // 2. Decorations
    const hasDeco = services.some(s => s.toLowerCase().includes('deco') || s.toLowerCase().includes('floral') || s.toLowerCase().includes('flower')) || (overrideDecoCost !== null && overrideDecoCost !== undefined);
    let decoCost = 0;
    let decoName = 'Thematic Floral Stage & Decor';
    if (hasDeco) {
      if (overrideDecoCost !== undefined && overrideDecoCost !== null) {
        decoCost = overrideDecoCost;
        decoName = selectedVendorAssignments['Decor']?.packageName || `Theme Decoration (Adjusted: Rs. ${decoCost.toLocaleString()})`;
      } else if (selectedVendorAssignments['Decor']?.agreedPayout) {
        decoCost = selectedVendorAssignments['Decor'].agreedPayout;
        decoName = selectedVendorAssignments['Decor'].packageName || 'Thematic Floral Stage + Table Centerpieces';
      } else if (budget >= 2000000) {
        decoCost = 220000;
        decoName = 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor';
      } else if (budget >= 1200000) {
        decoCost = 140000;
        decoName = 'Thematic Floral Stage + Entrance Tunnel Arch';
      } else if (budget >= 700000) {
        decoCost = 85000;
        decoName = 'Thematic Floral Stage + Table Centerpieces';
      } else {
        decoCost = 45000;
        decoName = 'Minimalist Floral Arch + Cake Table Styling';
      }
    }

    // 3. Photography & Media
    const hasPhoto = services.some(s => s.toLowerCase().includes('photo') || s.toLowerCase().includes('media')) || (overridePhotoCost !== null && overridePhotoCost !== undefined);
    let photoCost = 0;
    let photoName = 'Professional Event Photography';
    if (hasPhoto) {
      if (overridePhotoCost !== undefined && overridePhotoCost !== null) {
        photoCost = overridePhotoCost;
        photoName = selectedVendorAssignments['Photography']?.packageName || `Photography Package (Adjusted: Rs. ${photoCost.toLocaleString()})`;
      } else if (selectedVendorAssignments['Photography']?.agreedPayout) {
        photoCost = selectedVendorAssignments['Photography'].agreedPayout;
        photoName = selectedVendorAssignments['Photography'].packageName || 'Professional Event Coverage';
      } else if (selectedVendorAssignments['Photography']?.isPending) {
        photoCost = 0;
        photoName = 'Awaiting Live Registration (Pending Viva Demo)';
      } else {
        const phtFallback = autoAllocateVendorForCategory('Photography', budget);
        if (phtFallback && phtFallback.packagePrice) {
          photoCost = phtFallback.packagePrice;
          photoName = phtFallback.packageName || phtFallback.businessName;
        } else {
          photoCost = 0;
          photoName = 'Awaiting Live Registration (Pending Viva Demo)';
        }
      }
    }

    // 4. Celebration Cakes
    const hasCake = services.some(s => s.toLowerCase().includes('cake')) || (overrideCakeCost !== null && overrideCakeCost !== undefined);
    let cakeCost = 0;
    let cakeLabel = 'Celebration Cake';
    if (hasCake) {
      if (overrideCakeCost !== undefined && overrideCakeCost !== null) {
        cakeCost = overrideCakeCost;
        cakeLabel = selectedVendorAssignments['Cake']?.packageName || `Celebration Cake (Adjusted: Rs. ${cakeCost.toLocaleString()})`;
      } else if (selectedVendorAssignments['Cake']?.agreedPayout) {
        cakeCost = selectedVendorAssignments['Cake'].agreedPayout;
        cakeLabel = selectedVendorAssignments['Cake'].packageName || '2-Tier Custom Handcrafted Fondant Cake';
      } else if (budget >= 2000000) {
        cakeCost = 65000;
        cakeLabel = '5-Tier Royal Handcrafted Fondant Wedding Cake';
      } else if (budget >= 1200000) {
        cakeCost = 45000;
        cakeLabel = '3-Tier Luxury Floral Wedding Cake';
      } else if (budget >= 700000) {
        cakeCost = 30000;
        cakeLabel = '2-Tier Custom Handcrafted Fondant Cake';
      } else {
        cakeCost = 15000;
        cakeLabel = '2-Tier Classic Buttercream Celebration Cake';
      }
    }

    // 5. Luxury Bridal & VIP Transport
    const hasTransport = services.some(s => 
      s.toLowerCase().includes('transport') || 
      s.toLowerCase().includes('car') || 
      s.toLowerCase().includes('bridal')
    ) || (overrideTransportCost !== null && overrideTransportCost !== undefined);
    let transportCost = 0;
    let transportName = 'VIP Chauffeur Transport';
    if (hasTransport) {
      if (overrideTransportCost !== undefined && overrideTransportCost !== null) {
        transportCost = overrideTransportCost;
        transportName = selectedVendorAssignments['Transport']?.packageName || `VIP Transport (Adjusted: Rs. ${transportCost.toLocaleString()})`;
      } else if (selectedVendorAssignments['Transport']?.agreedPayout) {
        transportCost = selectedVendorAssignments['Transport'].agreedPayout;
        transportName = selectedVendorAssignments['Transport'].packageName || 'BMW 5-Series Executive Bridal Sedan';
      } else if (budget >= 2000000) {
        transportCost = 95000;
        transportName = 'Classic Vintage Rolls Royce / 1954 Jaguar Mark VII';
      } else if (budget >= 1200000) {
        transportCost = 65000;
        transportName = 'Mercedes-Benz S-Class Luxury Chauffeur Sedan';
      } else if (budget >= 700000) {
        transportCost = 50000;
        transportName = 'BMW 5-Series Executive Bridal Sedan';
      } else {
        transportCost = 35000;
        transportName = 'Toyota Premio / Allion Executive Chauffeur Sedan';
      }
    }

    const hasSpecialRequests = Boolean(ev.additionalDetails && ev.additionalDetails.trim().length > 0);
    const otherCost = hasSpecialRequests ? (customSpecialAllocation !== undefined ? customSpecialAllocation : specialAllocation) : 0;

    let refreshmentsCost = 0;
    const refreshmentsItems: { name: string; itemPerHead: number; cost: number }[] = [];
    const isHotelVenue = Boolean(ev.banquetHallId && ev.hallRentalPrice && ev.hallRentalPrice > 0);
    const guestCnt = ev.guestCount || 100;

    let clientSelectedRefreshmentItems: string[] = [];
    let rawRefData = (ev as any).tableRefreshments || (ev as any).tableRefreshmentsJson || (ev as any).TableRefreshmentsJson;
    if (Array.isArray(rawRefData)) {
      clientSelectedRefreshmentItems = rawRefData;
    } else if (typeof rawRefData === 'string' && rawRefData.trim().length > 0) {
      try {
        const parsed = JSON.parse(rawRefData);
        if (Array.isArray(parsed)) clientSelectedRefreshmentItems = parsed;
        else clientSelectedRefreshmentItems = [rawRefData];
      } catch (e) {
        if (rawRefData.includes(',')) clientSelectedRefreshmentItems = rawRefData.split(',').map(s => s.trim());
        else clientSelectedRefreshmentItems = [rawRefData];
      }
    }

    if (selectedVendorAssignments['Refreshments']?.isCustomPackage && selectedVendorAssignments['Refreshments']?.agreedPayout) {
      // Custom or Vendor Assigned Flat Refreshment Package
      refreshmentsCost = selectedVendorAssignments['Refreshments'].agreedPayout;
      refreshmentsItems.push({
        name: selectedVendorAssignments['Refreshments'].packageName || (isHotelVenue ? 'Hotel In-House Refreshment Package' : 'Vendor Beverage & Refreshment Package'),
        itemPerHead: Math.round(refreshmentsCost / guestCnt),
        cost: refreshmentsCost
      });
    } else if (clientSelectedRefreshmentItems.length > 0) {
      // Calculate Flat Item Price for each specific checkbox selected by client
      const rangeIdx = guestCnt <= 150 ? 0 : (guestCnt <= 250 ? 1 : 2);
      const isLuxury = budget >= 2000000;
      const isPremium = budget >= 1000000;

      clientSelectedRefreshmentItems.forEach(rawItem => {
        const item = rawItem.toLowerCase();
        let itemLabel = rawItem;
        let itemPrice = 15000;

        if (item.includes('mocktail') || item.includes('drink')) {
          if (isLuxury) {
            itemLabel = "Artisanal Exotic Fruit Fusion Bar & Signature Mocktails";
            itemPrice = [38000, 58000, 85000][rangeIdx];
          } else if (isPremium) {
            itemLabel = "Tropical Fresh Fruit Juices & Chilled Mocktails";
            itemPrice = [22000, 35000, 52000][rangeIdx];
          } else {
            itemLabel = "Chilled Mint Lime & Fruit Cordial Punch";
            itemPrice = [12000, 20000, 32000][rangeIdx];
          }
        } else if (item.includes('midnight') || item.includes('action')) {
          if (isLuxury) {
            itemLabel = "Live Action Midnight Street Food, Hopper & Satay Bar";
            itemPrice = [55000, 85000, 125000][rangeIdx];
          } else if (isPremium) {
            itemLabel = "Live Kottu & Mini Burger Midnight Station";
            itemPrice = [32000, 50000, 75000][rangeIdx];
          } else {
            itemLabel = "Midnight Hot Savory Snack Station";
            itemPrice = [20000, 30000, 45000][rangeIdx];
          }
        } else if (item.includes('snack') || item.includes('savory') || item.includes('table refreshment')) {
          if (isLuxury) {
            itemLabel = "Gourmet Savory Canapés, Cheese Platters & Vol-au-Vents";
            itemPrice = [42000, 65000, 95000][rangeIdx];
          } else if (isPremium) {
            itemLabel = "Assorted Mini Pastries, Rolls & Samosa Platter";
            itemPrice = [25000, 40000, 60000][rangeIdx];
          } else {
            itemLabel = "Classic Tea-Time Biscuit & Mini Savory Selection";
            itemPrice = [15000, 25000, 38000][rangeIdx];
          }
        } else if (item.includes('dessert') || item.includes('sweet')) {
          if (isLuxury) {
            itemLabel = "Luxury Chocolate Fountain, French Pastries & Fruit Carving";
            itemPrice = [48000, 75000, 110000][rangeIdx];
          } else if (isPremium) {
            itemLabel = "Watalappan, Caramel Pudding & Deluxe Ice Cream Bar";
            itemPrice = [28000, 45000, 68000][rangeIdx];
          } else {
            itemLabel = "Caramel Pudding & Vanilla Ice Cream Station";
            itemPrice = [15000, 25000, 40000][rangeIdx];
          }
        } else if (item.includes('tea') || item.includes('coffee')) {
          if (isLuxury) {
            itemLabel = "Artisanal Ceylon Tea & Brewed Espresso Coffee Lounge";
            itemPrice = [25000, 38000, 55000][rangeIdx];
          } else if (isPremium) {
            itemLabel = "Premium Ceylon Milk Tea & Brewed Coffee Counter";
            itemPrice = [15000, 22000, 32000][rangeIdx];
          } else {
            itemLabel = "Traditional Ceylon Plain & Milk Tea Station";
            itemPrice = [8000, 12000, 18000][rangeIdx];
          }
        }

        refreshmentsCost += itemPrice;
        refreshmentsItems.push({
          name: itemLabel,
          itemPerHead: Math.round(itemPrice / guestCnt),
          cost: itemPrice
        });
      });
    }

    return {
      hasSounds, soundsCost, soundsName,
      hasDeco, decoCost, decoName,
      hasPhoto, photoCost, photoName,
      hasCake, cakeCost, cakeLabel,
      hasTransport, transportCost, transportName,
      hasSpecialRequests, otherCost,
      refreshmentsCost,
      refreshmentsItems,
    };
  };

  // Proposal Approval Action
  const handleApprove = async () => {
    if (!selectedEvent) return;
    const basePerPlate = selectedEvent.perPlatePrice || 5000;
    const perPlate = customPerPlateCost !== null ? customPerPlateCost : basePerPlate;
    const cateringCost = selectedEvent.guestCount * perPlate;
    const isPrivateVenue = !selectedEvent.banquetHallId || selectedEvent.hallRentalPrice === 0 || (
      (selectedEvent.venueName?.toLowerCase().includes('private') ?? false) ||
      (selectedEvent.preferredLocation?.toLowerCase().includes('private') ?? false)
    );
    const baseHallRental = selectedEvent.hallRentalPrice !== null && selectedEvent.hallRentalPrice !== undefined
      ? selectedEvent.hallRentalPrice
      : (isPrivateVenue ? 0 : 350000);
    const hallRental = customHallCost !== null ? customHallCost : baseHallRental;
    const alloc = getAllocations(
      selectedEvent, 
      isBudgetAutoFitted, 
      specialAllocation, 
      customPhotoCost, 
      customDecoCost,
      customSoundsCost,
      customCakeCost,
      customTransportCost
    );

    const isEventOutdoor = selectedEvent.isOutdoor === true;
    let weatherData = selectedEvent.weatherAssessment;
    if (typeof weatherData === 'string' && weatherData.trim().startsWith('{')) {
      try { weatherData = JSON.parse(weatherData); } catch (e) {}
    }
    const rainPct = weatherData ? (weatherData.rainProbabilityPercent ?? weatherData.RainProbabilityPercent ?? 0) : 0;
    const weatherSafeguardCost = weatherData ? (weatherData.safeguardCost ?? weatherData.SafeguardCost ?? 0) : 0;

    let weatherTentCost = 0;
    let weatherTentName = 'Waterproof Marquee Tent (Autonomous Weather Safeguard)';

    if (isEventOutdoor) {
      if (customTentCost !== null) {
        weatherTentCost = customTentCost;
        weatherTentName = selectedVendorAssignments['MarqueeTent']?.packageName || (customTentCost === 0 ? 'Safeguard Waived' : 'Waterproof Marquee Tent (Negotiated Rate)');
      } else if (selectedWeatherOptionId) {
        const found = WEATHER_SAFEGUARD_CATALOG.find(w => w.id === selectedWeatherOptionId);
        if (found) {
          weatherTentCost = found.cost;
          weatherTentName = found.name;
        }
      } else if (selectedVendorAssignments['MarqueeTent']?.agreedPayout !== undefined) {
        weatherTentCost = selectedVendorAssignments['MarqueeTent'].agreedPayout;
        weatherTentName = selectedVendorAssignments['MarqueeTent'].packageName || 'Waterproof Marquee Tent (Autonomous Weather Safeguard)';
      } else if (isBudgetAutoFitted) {
        if ((selectedEvent.guestCount || 0) >= 200) {
          weatherTentCost = 100000;
          weatherTentName = 'Standard Large-Capacity Rain Canopy Pavilion (Budget Auto-Fit)';
        } else if ((selectedEvent.guestCount || 0) >= 100) {
          weatherTentCost = 60000;
          weatherTentName = 'Standard Medium-Capacity Waterproof Pavilion (Budget Auto-Fit)';
        } else {
          weatherTentCost = 25000;
          weatherTentName = 'Economy Compact Rain Protection Canopies (Budget Auto-Fit)';
        }
      } else if (weatherSafeguardCost > 0 || rainPct >= 60) {
        const evBudget = Number(selectedEvent.budgetLimit) || 1500000;
        const tentFallback = autoAllocateVendorForCategory('MarqueeTent', evBudget);
        if (tentFallback && tentFallback.packagePrice) {
          weatherTentCost = tentFallback.packagePrice;
          weatherTentName = tentFallback.packageName || tentFallback.businessName;
        } else if (evBudget >= 2000000) {
          weatherTentCost = 350000;
          weatherTentName = 'Air-Conditioned Transparent German Hangar Marquee (40x80 ft)';
        } else if (evBudget >= 1200000) {
          weatherTentCost = 150000;
          weatherTentName = 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)';
        } else if (evBudget >= 700000) {
          weatherTentCost = 80000;
          weatherTentName = 'High-Peak Waterproof Stretch Canopy (20x30 ft)';
        } else {
          weatherTentCost = 45000;
          weatherTentName = 'Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)';
        }
      }
    }

    const powerBackupCost = selectedVendorAssignments['PowerBackup']?.agreedPayout ? selectedVendorAssignments['PowerBackup'].agreedPayout : 0;
    const computedSubtotal = cateringCost + hallRental + alloc.soundsCost + alloc.decoCost + alloc.photoCost + alloc.cakeCost + alloc.transportCost + alloc.refreshmentsCost + weatherTentCost + powerBackupCost + alloc.otherCost;

    let computedFinalTotal = Math.max(0, computedSubtotal - specialDiscount);
    let targetStatus = 'ApprovedByManager';

    if (clientApprovalRequested) {
      targetStatus = 'PendingClientBudgetApproval';
    }

    // Build verified partner assignments (100% bound to verified DB vendors)
    const finalAssignedVendors: Array<{ category: string; vendorId?: string; vendorName: string; packageName?: string; packagePrice?: number }> = [];

    const getVerifiedFallback = (category: string) => {
      const tierMatch = autoAllocateVendorForCategory(category, Number(selectedEvent.budgetLimit) || 1500000);
      if (tierMatch) return tierMatch;
      const v = getVerifiedVendorsForCategory(category);
      return v.length > 0 ? v[0] : null;
    };

    // 1. Catering
    const cateringAssigned = selectedVendorAssignments['Catering'];
    const cateringFallback = getVerifiedFallback('Catering');
    finalAssignedVendors.push({
      category: 'Catering',
      vendorId: cateringAssigned?.vendorId || cateringFallback?.vendorId,
      vendorName: cateringAssigned?.vendorName || cateringFallback?.businessName || (selectedEvent.banquetHallName || selectedEvent.venueName ? `${selectedEvent.banquetHallName || selectedEvent.venueName} Banquet Kitchen` : 'Perera & Sons (P&S Event Catering)'),
      packageName: cateringAssigned?.packageName || `Banquet Catering Buffet (Rs. ${perPlate.toLocaleString()}/guest)`,
      packagePrice: cateringCost
    });

    // 2. Refreshments
    if (alloc.refreshmentsCost > 0) {
      const refreshAssigned = selectedVendorAssignments['Refreshments'];
      const refreshFallback = getVerifiedFallback('Refreshments');
      finalAssignedVendors.push({
        category: 'Refreshments',
        vendorId: refreshAssigned?.vendorId || refreshFallback?.vendorId,
        vendorName: refreshAssigned?.vendorName || refreshFallback?.businessName || 'Ceylon Tea Trails Mobile Brew Station',
        packageName: refreshAssigned?.packageName || alloc.refreshmentsItems.map(r => r.name).join(', '),
        packagePrice: alloc.refreshmentsCost
      });
    }

    // 3. Sound & Lighting
    if (alloc.hasSounds) {
      const assigned = selectedVendorAssignments['SoundLighting'] || selectedVendorAssignments['AudioVisual'];
      const soundFallback = getVerifiedFallback('SoundLighting');
      finalAssignedVendors.push({
        category: 'SoundLighting',
        vendorId: assigned?.vendorId || soundFallback?.vendorId,
        vendorName: assigned?.vendorName || soundFallback?.businessName || 'Mano Sounds & Acoustic Setup - Moratuwa',
        packageName: assigned?.packageName || alloc.soundsName,
        packagePrice: alloc.soundsCost
      });
    }

    // 4. Floral Decor & Stage
    if (alloc.hasDeco) {
      const assigned = selectedVendorAssignments['Decor'];
      const decoFallback = getVerifiedFallback('Decor');
      finalAssignedVendors.push({
        category: 'Decor',
        vendorId: assigned?.vendorId || decoFallback?.vendorId,
        vendorName: assigned?.vendorName || decoFallback?.businessName || 'Samanmal Flora & Deco Maharagama',
        packageName: assigned?.packageName || alloc.decoName,
        packagePrice: alloc.decoCost
      });
    }

    // 5. Photography & Media
    if (alloc.hasPhoto) {
      const assigned = selectedVendorAssignments['Photography'];
      const photoFallback = getVerifiedFallback('Photography');
      if (assigned?.vendorId && !assigned.isPending) {
        finalAssignedVendors.push({
          category: 'Photography',
          vendorId: assigned.vendorId,
          vendorName: assigned.vendorName,
          packageName: assigned.packageName || alloc.photoName,
          packagePrice: alloc.photoCost
        });
      } else if (!assigned?.isPending && photoFallback) {
        finalAssignedVendors.push({
          category: 'Photography',
          vendorId: photoFallback.vendorId || (photoFallback as any).id,
          vendorName: photoFallback.businessName || photoFallback.name || 'Beyond Horizons Cinema & Aerial Rigs',
          packageName: photoFallback.packageName || alloc.photoName,
          packagePrice: alloc.photoCost
        });
      }
    }

    // 6. Celebration Cakes
    if (alloc.hasCake) {
      const assigned = selectedVendorAssignments['Cake'] || selectedVendorAssignments['Cakes'];
      const cakeFallback = getVerifiedFallback('Cake');
      finalAssignedVendors.push({
        category: 'Cake',
        vendorId: assigned?.vendorId || cakeFallback?.vendorId,
        vendorName: assigned?.vendorName || cakeFallback?.businessName || 'The Fab & Sponge Sweet Treats Colombo',
        packageName: assigned?.packageName || alloc.cakeLabel,
        packagePrice: alloc.cakeCost
      });
    }

    // 7. VIP & Luxury Transport
    if (alloc.hasTransport) {
      const assigned = selectedVendorAssignments['Transport'] || selectedVendorAssignments['VIPTransport'];
      const transFallback = getVerifiedFallback('Transport');
      finalAssignedVendors.push({
        category: 'Transport',
        vendorId: assigned?.vendorId || transFallback?.vendorId,
        vendorName: assigned?.vendorName || transFallback?.businessName || 'SilverLine Executive BMW Fleet',
        packageName: assigned?.packageName || alloc.transportName,
        packagePrice: alloc.transportCost
      });
    }

    // 8. Marquee Tent Weather Safeguard
    if (isEventOutdoor && weatherTentCost > 0) {
      const tentAssigned = selectedVendorAssignments['MarqueeTent'];
      const tentFallback = getVerifiedFallback('MarqueeTent');
      finalAssignedVendors.push({
        category: 'MarqueeTent',
        vendorId: tentAssigned?.vendorId || tentFallback?.vendorId,
        vendorName: tentAssigned?.vendorName || tentFallback?.businessName || 'Ceylon WeatherShield Marquee Tents',
        packageName: tentAssigned?.packageName || weatherTentName,
        packagePrice: weatherTentCost
      });
    }

    // 9. Power Backup (Outdoor Contingency)
    if (isEventOutdoor && selectedVendorAssignments['PowerBackup']?.vendorId) {
      const pwrAssigned = selectedVendorAssignments['PowerBackup'];
      finalAssignedVendors.push({
        category: 'PowerBackup',
        vendorId: pwrAssigned.vendorId,
        vendorName: pwrAssigned.vendorName,
        packageName: pwrAssigned.packageName || 'Backup Diesel Silent Generator (Heavy Duty)',
        packagePrice: pwrAssigned.agreedPayout || 50000
      });
    }

    const assignedVendorsJson = JSON.stringify(finalAssignedVendors);

    const planItems = [
      `Venue Rental: ${selectedEvent.banquetHallName || selectedEvent.venueName || "Selected Venue"} (Rs. ${hallRental.toLocaleString()})`,
      `Hotel Buffet Catering (Rs. ${perPlate.toLocaleString()}/guest) = Rs. ${cateringCost.toLocaleString()}`,
    ];

    if (alloc.refreshmentsItems && alloc.refreshmentsItems.length > 0) {
      alloc.refreshmentsItems.forEach(r => {
        planItems.push(`${r.name} (Rs. ${r.itemPerHead.toLocaleString()}/guest) = Rs. ${r.cost.toLocaleString()}`);
      });
    }

    if (alloc.hasSounds) {
      const vName = selectedVendorAssignments['SoundLighting']?.vendorName || selectedVendorAssignments['AudioVisual']?.vendorName;
      planItems.push(`${alloc.soundsName}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.soundsCost.toLocaleString()})`);
    }
    if (alloc.hasDeco) {
      const vName = selectedVendorAssignments['Decor']?.vendorName;
      planItems.push(`${alloc.decoName}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.decoCost.toLocaleString()})`);
    }
    if (alloc.hasPhoto) {
      const vAssigned = selectedVendorAssignments['Photography'];
      if (vAssigned?.vendorId && !vAssigned.isPending) {
        planItems.push(`${alloc.photoName} [Partner: ${vAssigned.vendorName}] (Rs. ${alloc.photoCost.toLocaleString()})`);
      } else if (alloc.photoCost > 0) {
        planItems.push(`${alloc.photoName} (Rs. ${alloc.photoCost.toLocaleString()})`);
      } else {
        planItems.push(`Photography & Cinematography: Pending Live Photographer Registration (Rs. 0)`);
      }
    }
    if (alloc.hasCake) {
      const vName = selectedVendorAssignments['Cake']?.vendorName || selectedVendorAssignments['Cakes']?.vendorName;
      planItems.push(`${alloc.cakeLabel}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.cakeCost.toLocaleString()})`);
    }
    if (alloc.hasTransport) {
      const vName = selectedVendorAssignments['Transport']?.vendorName || selectedVendorAssignments['VIPTransport']?.vendorName;
      planItems.push(`${alloc.transportName}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.transportCost.toLocaleString()})`);
    }
    if (alloc.hasSpecialRequests) planItems.push(`Special Client Request: ${selectedEvent.additionalDetails} (Rs. ${alloc.otherCost.toLocaleString()})`);
    if (isEventOutdoor && weatherTentCost > 0) planItems.push(`${weatherTentName} [Partner: ${selectedVendorAssignments['MarqueeTent']?.vendorName || 'Ceylon WeatherShield'}] (Rs. ${weatherTentCost.toLocaleString()})`);
    if (isEventOutdoor && selectedVendorAssignments['PowerBackup']?.vendorId) {
      planItems.push(`${selectedVendorAssignments['PowerBackup'].packageName || 'Backup Diesel Silent Generator'} [Partner: ${selectedVendorAssignments['PowerBackup'].vendorName}] (Rs. ${(selectedVendorAssignments['PowerBackup'].agreedPayout || 50000).toLocaleString()})`);
    }
    if (specialDiscount > 0) planItems.push(`Manager Courtesy Discount (-Rs. ${specialDiscount.toLocaleString()})`);

    try {
      await eventService.approveProposal(selectedEvent.eventId, specialDiscount, computedFinalTotal, targetStatus, specialAllocation, planItems, assignedVendorsJson);
      try {
        await vendorService.assignVendorsToEvent(selectedEvent.eventId, finalAssignedVendors);
      } catch (err) {
        console.warn("Assign vendors PUT fallback:", err);
      }
      setActionSuccess(
        clientApprovalRequested
          ? "Proposal flagged & sent to client for budget increase request!"
          : "Proposal approved successfully with verified vendor assignments! Synchronized in PostgreSQL Database."
      );
      setSelectedEvent(prev => prev ? { ...prev, status: targetStatus, estimatedTotalCost: computedFinalTotal, assignedVendors: finalAssignedVendors, assignedVendorsJson } : null);
      setViewModalEvent(prev => prev ? { ...prev, status: targetStatus, estimatedTotalCost: computedFinalTotal, assignedVendors: finalAssignedVendors, assignedVendorsJson } : null);
      loadEvents();
    } catch (err) {
      console.error("Approval failed", err);
      alert("Failed to approve proposal on backend.");
    }
  };

  // Delete Event Request Action - Prompts Custom High-End Modal
  const handleDeleteEvent = (e: React.MouseEvent, eventId: string, eventTitle: string) => {
    e.stopPropagation();
    setDeleteModal({
      isOpen: true,
      eventId,
      eventTitle,
      isDeleting: false
    });
  };

  // Confirmed Delete Event from Custom Modal
  const confirmDeleteEvent = async () => {
    if (!deleteModal) return;
    setDeleteModal(prev => prev ? { ...prev, isDeleting: true } : null);
    try {
      await eventService.deleteEvent(deleteModal.eventId);
      setActionSuccess(`Event "${deleteModal.eventTitle}" deleted successfully!`);
      if (selectedEvent?.eventId === deleteModal.eventId) {
        setSelectedEvent(null);
      }
      if (viewModalEvent?.eventId === deleteModal.eventId) {
        setViewModalEvent(null);
      }
      setDeleteModal(null);
      loadEvents();
    } catch (err) {
      console.error("Failed to delete event proposal", err);
      setActionError("Failed to delete event proposal. Please try again.");
      setDeleteModal(null);
    }
  };

  // View Event Proposal Details in Popup Modal Action
  const handleViewEvent = (e: React.MouseEvent, ev: EventItem) => {
    e.stopPropagation();
    setSelectedEvent(ev);
    setViewModalEvent(ev);
  };

  const activeCount = events.filter(e => e.status !== 'Completed' && e.status !== 'Cancelled').length;
  const pendingCount = events.filter(e => e.status === 'PendingManagerApproval' || e.status === 'UnderReview').length;
  const confirmedCount = events.filter(e => e.status === 'ApprovedByManager' || e.status === 'Confirmed').length;

  // Undo / Reset Auto-Fit Logic - Restores exact pre-fit snapshot
  const handleResetAutoFit = () => {
    if (preFitSnapshot) {
      setSelectedVendorAssignments(JSON.parse(JSON.stringify(preFitSnapshot.vendorAssignments)));
      setCustomPerPlateCost(preFitSnapshot.perPlateCost);
      setCustomTentCost(preFitSnapshot.tentCost);
      setSpecialDiscount(preFitSnapshot.specialDiscount);
    }
    setIsBudgetAutoFitted(false);
  };

  // Smart Budget-Tier Vendor Switching Auto-Fit Logic
  const handleExecuteAutoFit = () => {
    if (!selectedEvent) return;

    // 1. Save Pre-fit snapshot for Undo / Reset
    setPreFitSnapshot({
      vendorAssignments: JSON.parse(JSON.stringify(selectedVendorAssignments)),
      perPlateCost: customPerPlateCost,
      tentCost: customTentCost,
      specialDiscount: specialDiscount
    });

    setIsBudgetAutoFitted(true);
    setClientApprovalRequested(false);

    const budget = Number(selectedEvent.budgetLimit) || 800000;
    const guestCnt = selectedEvent.guestCount || 100;
    const isPrivateVenue = !selectedEvent.banquetHallId || selectedEvent.hallRentalPrice === 0;
    const hallRentalCost = isPrivateVenue ? 0 : (selectedEvent.hallRentalPrice || 0);

    // Calculate current fixed costs
    const cateringCostVal = guestCnt * customPerPlateCost;
    const autoTentCost = selectedEvent.isOutdoor ? customTentCost : 0;

    let autoRefreshmentsCost = 0;
    let clientSelectedItems: string[] = [];
    let rawRefData = (selectedEvent as any).tableRefreshments || (selectedEvent as any).tableRefreshmentsJson || (selectedEvent as any).TableRefreshmentsJson;
    if (Array.isArray(rawRefData)) {
      clientSelectedItems = rawRefData;
    } else if (typeof rawRefData === 'string' && rawRefData.trim().length > 0) {
      try {
        const parsed = JSON.parse(rawRefData);
        if (Array.isArray(parsed)) clientSelectedItems = parsed;
        else clientSelectedItems = [rawRefData];
      } catch (e) {
        if (rawRefData.includes(',')) clientSelectedItems = rawRefData.split(',').map(s => s.trim());
        else clientSelectedItems = [rawRefData];
      }
    }
    const rangeIdx = guestCnt <= 150 ? 0 : (guestCnt <= 250 ? 1 : 2);
    const isLuxury = budget >= 2000000;
    const isPremium = budget >= 1000000;

    clientSelectedItems.forEach(rawItem => {
      const item = rawItem.toLowerCase();
      if (item.includes('mocktail') || item.includes('drink')) {
        autoRefreshmentsCost += isLuxury ? [38000, 58000, 85000][rangeIdx] : (isPremium ? [22000, 35000, 52000][rangeIdx] : [12000, 20000, 32000][rangeIdx]);
      } else if (item.includes('midnight') || item.includes('action')) {
        autoRefreshmentsCost += isLuxury ? [55000, 85000, 125000][rangeIdx] : (isPremium ? [32000, 50000, 75000][rangeIdx] : [20000, 30000, 45000][rangeIdx]);
      } else if (item.includes('snack') || item.includes('savory') || item.includes('table refreshment')) {
        autoRefreshmentsCost += isLuxury ? [42000, 65000, 95000][rangeIdx] : (isPremium ? [25000, 40000, 60000][rangeIdx] : [15000, 25000, 38000][rangeIdx]);
      } else if (item.includes('dessert') || item.includes('sweet')) {
        autoRefreshmentsCost += isLuxury ? [48000, 75000, 110000][rangeIdx] : (isPremium ? [28000, 45000, 68000][rangeIdx] : [15000, 25000, 40000][rangeIdx]);
      } else if (item.includes('tea') || item.includes('coffee')) {
        autoRefreshmentsCost += isLuxury ? [25000, 38000, 55000][rangeIdx] : (isPremium ? [15000, 22000, 32000][rangeIdx] : [8000, 12000, 18000][rangeIdx]);
      }
    });

    const specialReqCost = (selectedEvent.additionalDetails && selectedEvent.additionalDetails.trim().length > 0) ? specialAllocation : 0;
    const currentFixedCostsTotal = hallRentalCost + cateringCostVal + autoTentCost + autoRefreshmentsCost + specialReqCost;

    const currentVendorPayouts = Object.values(selectedVendorAssignments).reduce((sum, v) => sum + (v.agreedPayout || 0), 0);
    const initialSubtotal = currentFixedCostsTotal + currentVendorPayouts;
    const overrunAmount = initialSubtotal - budget;

    // Zero discount if already within budget limit!
    if (overrunAmount <= 0) {
      setSpecialDiscount(0);
      return;
    }

    // SURGICAL MINIMAL AUTO-FIT FOR SMALL OVERRUNS (overrun <= 150,000 LKR)
    if (overrunAmount <= 150000) {
      const surgicalAssignments = { ...selectedVendorAssignments };
      let bestCatToStepDown: string | null = null;
      let bestCheaperVendor: any = null;
      let minDifferenceToOverrun = Infinity;

      Object.keys(surgicalAssignments).forEach(catKey => {
        const currentAssignment = surgicalAssignments[catKey];
        if (currentAssignment && currentAssignment.agreedPayout > 0) {
          const matching = getVerifiedVendorsForCategory(catKey);
          const sorted = [...matching].sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0));
          const cheaper = sorted.find(v => (Number(v.packagePrice) || 0) < currentAssignment.agreedPayout);
          if (cheaper) {
            const savings = currentAssignment.agreedPayout - (Number(cheaper.packagePrice) || 0);
            if (savings >= overrunAmount) {
              const diff = savings - overrunAmount;
              if (diff < minDifferenceToOverrun) {
                minDifferenceToOverrun = diff;
                bestCatToStepDown = catKey;
                bestCheaperVendor = cheaper;
              }
            }
          }
        }
      });

      if (bestCatToStepDown && bestCheaperVendor) {
        surgicalAssignments[bestCatToStepDown] = {
          vendorId: bestCheaperVendor.vendorId,
          vendorName: bestCheaperVendor.businessName,
          packageName: bestCheaperVendor.packageName || bestCheaperVendor.businessName,
          agreedPayout: Number(bestCheaperVendor.packagePrice) || 30000,
          isCustomPackage: false
        };
        setSelectedVendorAssignments(surgicalAssignments);
        const newSubtotal = currentFixedCostsTotal + Object.values(surgicalAssignments).reduce((sum, v) => sum + (v.agreedPayout || 0), 0);
        setSpecialDiscount(newSubtotal > budget ? Math.round(newSubtotal - budget) : 0);
        return;
      }

      // Exact courtesy discount if single vendor step down isn't sufficient
      setSpecialDiscount(Math.round(overrunAmount));
      return;
    }

    // FULL AUTO-FIT TIER RE-ALLOCATION FOR LARGE OVERRUNS (> 150,000 LKR)
    const autoCateringRate = budget >= 2000000 ? 4500 : (budget >= 1200000 ? 3800 : (budget >= 700000 ? 3000 : 2500));
    setCustomPerPlateCost(autoCateringRate);

    const reTentCost = selectedEvent.isOutdoor ? (budget >= 2000000 ? 100000 : (budget >= 1200000 ? 60000 : 45000)) : 0;
    if (selectedEvent.isOutdoor) {
      setCustomTentCost(reTentCost);
    }

    const reCateringCostVal = guestCnt * autoCateringRate;
    const fixedCostsTotal = hallRentalCost + reCateringCostVal + reTentCost + autoRefreshmentsCost + specialReqCost;
    const vendorBudgetPool = Math.max(100000, budget - fixedCostsTotal);

    const categoryWeights: Record<string, number> = {
      'Decor': 0.30,
      'Photography': 0.25,
      'SoundLighting': 0.20,
      'Transport': 0.15,
      'Cake': 0.10
    };

    const newAssignments = { ...selectedVendorAssignments };

    Object.entries(categoryWeights).forEach(([catKey, weight]) => {
      const targetCatBudget = vendorBudgetPool * weight;
      const matching = getVerifiedVendorsForCategory(catKey);

      if (matching && matching.length > 0) {
        const sorted = [...matching].sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0));
        let bestVendor = sorted[0];
        let minDiff = Infinity;

        for (const vendor of sorted) {
          const price = Number(vendor.packagePrice) || 0;
          if (price <= targetCatBudget * 1.25) {
            const diff = Math.abs(targetCatBudget - price);
            if (diff < minDiff) {
              minDiff = diff;
              bestVendor = vendor;
            }
          }
        }

        newAssignments[catKey] = {
          vendorId: bestVendor.vendorId,
          vendorName: bestVendor.businessName,
          packageName: bestVendor.packageName || `${bestVendor.businessName} (Auto-Fit)`,
          agreedPayout: Number(bestVendor.packagePrice) || 35000,
          isCustomPackage: false
        };
      }
    });

    let compiledSubtotal = fixedCostsTotal + Object.values(newAssignments).reduce((sum, v) => sum + (v.agreedPayout || 0), 0);

    if (compiledSubtotal > budget) {
      const catKeys = Object.keys(categoryWeights);
      for (let i = 0; i < 3; i++) {
        if (compiledSubtotal <= budget) break;

        let candidateCat: string | null = null;
        let candidateCheaperVendor: any = null;
        let maxPayout = 0;

        catKeys.forEach(catKey => {
          const currentAssignment = newAssignments[catKey];
          if (currentAssignment && currentAssignment.agreedPayout > maxPayout) {
            const matching = getVerifiedVendorsForCategory(catKey);
            const sorted = [...matching].sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0));
            const cheaper = sorted.find(v => (Number(v.packagePrice) || 0) < currentAssignment.agreedPayout);
            if (cheaper) {
              maxPayout = currentAssignment.agreedPayout;
              candidateCat = catKey;
              candidateCheaperVendor = cheaper;
            }
          }
        });

        if (candidateCat && candidateCheaperVendor) {
          newAssignments[candidateCat] = {
            vendorId: candidateCheaperVendor.vendorId,
            vendorName: candidateCheaperVendor.businessName,
            packageName: candidateCheaperVendor.packageName || candidateCheaperVendor.businessName,
            agreedPayout: Number(candidateCheaperVendor.packagePrice) || 30000,
            isCustomPackage: false
          };
          compiledSubtotal = fixedCostsTotal + Object.values(newAssignments).reduce((sum, v) => sum + (v.agreedPayout || 0), 0);
        } else {
          break;
        }
      }
    }

    setSelectedVendorAssignments(newAssignments);

    if (compiledSubtotal > budget) {
      setSpecialDiscount(Math.round(compiledSubtotal - budget));
    } else {
      setSpecialDiscount(0);
    }
  };

  // Filter events based on active tab and search query
  const filteredEvents = events.filter(ev => {
    const matchesTab = 
      eventFilterTab === 'all' ? true :
      eventFilterTab === 'pending' ? (ev.status === 'PendingManagerApproval' || ev.status === 'UnderReview' || ev.status === 'ClientChoiceSubmitted' || ev.status === 'PendingClientBudgetApproval') :
      eventFilterTab === 'approved' ? (ev.status === 'ApprovedByManager' || ev.status === 'Confirmed') : true;

    const matchesSearch = 
      ev.title.toLowerCase().includes(eventSearchQuery.toLowerCase()) ||
      ev.eventType?.toLowerCase().includes(eventSearchQuery.toLowerCase()) ||
      ev.venueName?.toLowerCase().includes(eventSearchQuery.toLowerCase()) ||
      ev.status.toLowerCase().includes(eventSearchQuery.toLowerCase());

    return matchesTab && matchesSearch;
  });

  // Pricing calculations for current selected event
  const isApproved = selectedEvent?.status === 'ApprovedByManager' || selectedEvent?.status === 'Confirmed';
  const basePerPlate = selectedEvent?.perPlatePrice || 5000;
  const perPlate = customPerPlateCost !== null ? customPerPlateCost : basePerPlate;
  const cateringCost = (selectedEvent?.guestCount || 0) * perPlate;
  const isPrivateVenue = !selectedEvent?.banquetHallId || selectedEvent?.hallRentalPrice === 0 || (
    (selectedEvent?.venueName?.toLowerCase().includes('private') ?? false) ||
    (selectedEvent?.preferredLocation?.toLowerCase().includes('private') ?? false)
  );
  const baseHallRental = selectedEvent?.hallRentalPrice !== null && selectedEvent?.hallRentalPrice !== undefined
    ? selectedEvent.hallRentalPrice
    : (isPrivateVenue ? 0 : 350000);
  const hallRental = customHallCost !== null ? customHallCost : baseHallRental;
  const alloc = getAllocations(
    selectedEvent, 
    isBudgetAutoFitted, 
    specialAllocation, 
    customPhotoCost, 
    customDecoCost,
    customSoundsCost,
    customCakeCost,
    customTransportCost
  );

  const isEventOutdoor = selectedEvent?.isOutdoor === true;
  let weatherData = selectedEvent?.weatherAssessment;
  if (typeof weatherData === 'string' && weatherData.trim().startsWith('{')) {
    try { weatherData = JSON.parse(weatherData); } catch (e) {}
  }
  const rainPct = weatherData ? (weatherData.rainProbabilityPercent ?? weatherData.RainProbabilityPercent ?? 0) : 0;
  const weatherSafeguardCost = weatherData ? (weatherData.safeguardCost ?? weatherData.SafeguardCost ?? 0) : 0;
  const weatherCondition = weatherData?.condition || weatherData?.Condition || (isEventOutdoor ? "Monsoon Showers" : "Indoor Climate Controlled");
  const weatherAction = weatherData?.description || weatherData?.Description || weatherData?.actionRequired || weatherData?.ActionRequired || (isEventOutdoor ? "Rain safeguard applied" : "Indoor venue - No weather safeguard required");

  let weatherTentCost = 0;
  let weatherTentName = 'Waterproof Marquee Tent (Autonomous Weather Safeguard)';

  if (isEventOutdoor) {
    if (customTentCost !== null) {
      weatherTentCost = customTentCost;
      weatherTentName = selectedVendorAssignments['MarqueeTent']?.packageName || (customTentCost === 0 ? 'Safeguard Waived' : 'Waterproof Marquee Tent (Negotiated Rate)');
    } else if (selectedWeatherOptionId) {
      const found = WEATHER_SAFEGUARD_CATALOG.find(w => w.id === selectedWeatherOptionId);
      if (found) {
        weatherTentCost = found.cost;
        weatherTentName = found.name;
      }
    } else if (selectedVendorAssignments['MarqueeTent']?.agreedPayout !== undefined) {
      weatherTentCost = selectedVendorAssignments['MarqueeTent'].agreedPayout;
      weatherTentName = selectedVendorAssignments['MarqueeTent'].packageName || 'Waterproof Marquee Tent (Autonomous Weather Safeguard)';
    } else if (isBudgetAutoFitted) {
      if ((selectedEvent?.guestCount || 0) >= 200) {
        weatherTentCost = 100000;
        weatherTentName = 'Standard Large-Capacity Rain Canopy Pavilion (Budget Auto-Fit)';
      } else if ((selectedEvent?.guestCount || 0) >= 100) {
        weatherTentCost = 60000;
        weatherTentName = 'Standard Medium-Capacity Waterproof Pavilion (Budget Auto-Fit)';
      } else {
        weatherTentCost = 25000;
        weatherTentName = 'Economy Compact Rain Protection Canopies (Budget Auto-Fit)';
      }
    } else if (weatherSafeguardCost > 0 || rainPct >= 60) {
      const evBudget = Number(selectedEvent?.budgetLimit) || 1500000;
      const tentFallback = autoAllocateVendorForCategory('MarqueeTent', evBudget);
      if (tentFallback && tentFallback.packagePrice) {
        weatherTentCost = tentFallback.packagePrice;
        weatherTentName = tentFallback.packageName || tentFallback.businessName;
      } else if (evBudget >= 2000000) {
        weatherTentCost = 350000;
        weatherTentName = 'Air-Conditioned Transparent German Hangar Marquee (40x80 ft)';
      } else if (evBudget >= 1200000) {
        weatherTentCost = 150000;
        weatherTentName = 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)';
      } else if (evBudget >= 700000) {
        weatherTentCost = 80000;
        weatherTentName = 'High-Peak Waterproof Stretch Canopy (20x30 ft)';
      } else {
        weatherTentCost = 45000;
        weatherTentName = 'Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)';
      }
    }
  }

  const powerBackupCost = selectedVendorAssignments['PowerBackup']?.agreedPayout ? selectedVendorAssignments['PowerBackup'].agreedPayout : 0;
  const currentSubtotal = cateringCost + hallRental + alloc.soundsCost + alloc.decoCost + alloc.photoCost + alloc.cakeCost + alloc.transportCost + alloc.refreshmentsCost + weatherTentCost + powerBackupCost + alloc.otherCost;
  const clientBudgetLimit = Number(selectedEvent?.budgetLimit) || 1500000;
  const overrunAmount = Math.max(0, currentSubtotal - clientBudgetLimit);
  const displayedFinalTotal = Math.max(0, currentSubtotal - specialDiscount);

  // Live-sync working proposal draft (including Marquee Tent & vendor tier selections) to backend so Mobile App stays 100% in sync
  useEffect(() => {
    if (!selectedEvent?.eventId || isApproved || availableVendors.length === 0) return;

    const timer = setTimeout(() => {
      const evBudget = Number(selectedEvent.budgetLimit) || 1500000;
      const getDraftFallback = (category: string) => {
        const tierMatch = autoAllocateVendorForCategory(category, evBudget);
        if (tierMatch) return tierMatch;
        const v = getVerifiedVendorsForCategory(category);
        return v.length > 0 ? v[0] : null;
      };

      const draftAssignedVendors: Array<{ category: string; vendorId?: string; vendorName: string; packageName?: string; packagePrice?: number }> = [];

      const catAssigned = selectedVendorAssignments['Catering'];
      const catFallback = getDraftFallback('Catering');
      draftAssignedVendors.push({
        category: 'Catering',
        vendorId: catAssigned?.vendorId || catFallback?.vendorId,
        vendorName: catAssigned?.vendorName || catFallback?.businessName || 'Perera & Sons (P&S Event Catering)',
        packageName: catAssigned?.packageName || `Banquet Catering Buffet (Rs. ${perPlate.toLocaleString()}/guest)`,
        packagePrice: cateringCost
      });

      const draftPlanItems: string[] = [
        `Venue Rental: ${selectedEvent.banquetHallName || selectedEvent.venueName || "Selected Venue"} (Rs. ${hallRental.toLocaleString()})`,
        `Hotel Buffet Catering (Rs. ${perPlate.toLocaleString()}/guest) = Rs. ${cateringCost.toLocaleString()}`,
      ];

      if (alloc.refreshmentsItems && alloc.refreshmentsItems.length > 0) {
        const refAssigned = selectedVendorAssignments['Refreshments'];
        const refFallback = getDraftFallback('Refreshments');
        draftAssignedVendors.push({
          category: 'Refreshments',
          vendorId: refAssigned?.vendorId || refFallback?.vendorId,
          vendorName: refAssigned?.vendorName || refFallback?.businessName || 'Ceylon Tea Trails Mobile Brew Station',
          packageName: refAssigned?.packageName || alloc.refreshmentsItems.map(r => r.name).join(', '),
          packagePrice: alloc.refreshmentsCost
        });
        alloc.refreshmentsItems.forEach(r => {
          draftPlanItems.push(`${r.name} (Rs. ${r.itemPerHead.toLocaleString()}/guest) = Rs. ${r.cost.toLocaleString()}`);
        });
      }

      if (alloc.hasSounds) {
        const sndAssigned = selectedVendorAssignments['SoundLighting'] || selectedVendorAssignments['AudioVisual'];
        const sndFallback = getDraftFallback('SoundLighting');
        const vName = sndAssigned?.vendorName || sndFallback?.businessName;
        draftPlanItems.push(`${alloc.soundsName}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.soundsCost.toLocaleString()})`);
        draftAssignedVendors.push({
          category: 'SoundLighting',
          vendorId: sndAssigned?.vendorId || sndFallback?.vendorId,
          vendorName: vName || 'Mano Sounds & Acoustic Setup - Moratuwa',
          packageName: sndAssigned?.packageName || alloc.soundsName,
          packagePrice: alloc.soundsCost
        });
      }
      if (alloc.hasDeco) {
        const decAssigned = selectedVendorAssignments['Decor'];
        const decFallback = getDraftFallback('Decor');
        const vName = decAssigned?.vendorName || decFallback?.businessName;
        draftPlanItems.push(`${alloc.decoName}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.decoCost.toLocaleString()})`);
        draftAssignedVendors.push({
          category: 'Decor',
          vendorId: decAssigned?.vendorId || decFallback?.vendorId,
          vendorName: vName || 'Samanmal Flora & Deco Maharagama',
          packageName: decAssigned?.packageName || alloc.decoName,
          packagePrice: alloc.decoCost
        });
      }
      if (alloc.hasPhoto) {
        const vAssigned = selectedVendorAssignments['Photography'];
        const phtFallback = getDraftFallback('Photography');
        const phtName = (vAssigned?.vendorId && !vAssigned.isPending) ? vAssigned.vendorName : (!vAssigned?.isPending ? (phtFallback?.businessName || phtFallback?.name) : undefined);
        const phtId = (vAssigned?.vendorId && !vAssigned.isPending) ? vAssigned.vendorId : (!vAssigned?.isPending ? (phtFallback?.vendorId || (phtFallback as any)?.id) : undefined);
        if (phtName && alloc.photoCost > 0) {
          draftPlanItems.push(`${alloc.photoName} [Partner: ${phtName}] (Rs. ${alloc.photoCost.toLocaleString()})`);
          draftAssignedVendors.push({
            category: 'Photography',
            vendorId: phtId,
            vendorName: phtName,
            packageName: vAssigned?.packageName || phtFallback?.packageName || alloc.photoName,
            packagePrice: alloc.photoCost
          });
        } else if (alloc.photoCost > 0) {
          draftPlanItems.push(`${alloc.photoName} (Rs. ${alloc.photoCost.toLocaleString()})`);
        } else {
          draftPlanItems.push(`Photography & Cinematography: Pending Live Photographer Registration (Rs. 0)`);
        }
      }
      if (alloc.hasCake) {
        const ckAssigned = selectedVendorAssignments['Cake'] || selectedVendorAssignments['Cakes'];
        const ckFallback = getDraftFallback('Cake');
        const vName = ckAssigned?.vendorName || ckFallback?.businessName;
        draftPlanItems.push(`${alloc.cakeLabel}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.cakeCost.toLocaleString()})`);
        draftAssignedVendors.push({
          category: 'Cake',
          vendorId: ckAssigned?.vendorId || ckFallback?.vendorId,
          vendorName: vName || 'The Fab & Sponge Sweet Treats Colombo',
          packageName: ckAssigned?.packageName || alloc.cakeLabel,
          packagePrice: alloc.cakeCost
        });
      }
      if (alloc.hasTransport) {
        const trnAssigned = selectedVendorAssignments['Transport'] || selectedVendorAssignments['VIPTransport'];
        const trnFallback = getDraftFallback('Transport');
        const vName = trnAssigned?.vendorName || trnFallback?.businessName;
        draftPlanItems.push(`${alloc.transportName}${vName ? ` [Partner: ${vName}]` : ''} (Rs. ${alloc.transportCost.toLocaleString()})`);
        draftAssignedVendors.push({
          category: 'Transport',
          vendorId: trnAssigned?.vendorId || trnFallback?.vendorId,
          vendorName: vName || 'SilverLine Executive BMW Fleet',
          packageName: trnAssigned?.packageName || alloc.transportName,
          packagePrice: alloc.transportCost
        });
      }
      if (alloc.hasSpecialRequests) {
        draftPlanItems.push(`Special Client Request: ${selectedEvent.additionalDetails} (Rs. ${alloc.otherCost.toLocaleString()})`);
      }
      if (isEventOutdoor && weatherTentCost > 0) {
        const tntAssigned = selectedVendorAssignments['MarqueeTent'];
        const tntFallback = getDraftFallback('MarqueeTent');
        const tntVendorName = tntAssigned?.vendorName || tntFallback?.businessName || 'Ceylon WeatherShield Marquee Tents';
        draftPlanItems.push(`${weatherTentName} [Partner: ${tntVendorName}] (Rs. ${weatherTentCost.toLocaleString()})`);
        draftAssignedVendors.push({
          category: 'MarqueeTent',
          vendorId: tntAssigned?.vendorId || tntFallback?.vendorId,
          vendorName: tntVendorName,
          packageName: weatherTentName,
          packagePrice: weatherTentCost
        });
      }
      if (isEventOutdoor && selectedVendorAssignments['PowerBackup']?.vendorId) {
        const pwr = selectedVendorAssignments['PowerBackup'];
        draftPlanItems.push(`${pwr.packageName || 'Backup Diesel Silent Generator'} [Partner: ${pwr.vendorName}] (Rs. ${(pwr.agreedPayout || 50000).toLocaleString()})`);
        draftAssignedVendors.push({
          category: 'PowerBackup',
          vendorId: pwr.vendorId,
          vendorName: pwr.vendorName,
          packageName: pwr.packageName || 'Backup Diesel Silent Generator',
          packagePrice: pwr.agreedPayout || 50000
        });
      }
      if (specialDiscount > 0) {
        draftPlanItems.push(`Manager Courtesy Discount (-Rs. ${specialDiscount.toLocaleString()})`);
      }

      const draftAssignedVendorsJson = JSON.stringify(draftAssignedVendors);

      eventService.syncProposalDraft(selectedEvent.eventId, {
        finalTotal: displayedFinalTotal,
        weatherTentCost: isEventOutdoor ? weatherTentCost : 0,
        weatherTentName,
        assignedVendorsJson: draftAssignedVendorsJson,
        planItems: draftPlanItems
      }).catch(() => {});

      setEvents(prev => prev.map(ev => ev.eventId === selectedEvent.eventId ? { ...ev, estimatedTotalCost: displayedFinalTotal, assignedVendors: draftAssignedVendors, assignedVendorsJson: draftAssignedVendorsJson } : ev));
    }, 350);

    return () => clearTimeout(timer);
  }, [
    selectedEvent?.eventId,
    isApproved,
    availableVendors.length,
    displayedFinalTotal,
    weatherTentCost,
    weatherTentName,
    selectedVendorAssignments,
    specialAllocation,
    specialDiscount,
    isBudgetAutoFitted
  ]);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-8">

      {/* Success Notification Alert */}
      {actionSuccess && (
        <div className="p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-xs font-medium flex items-center justify-between shadow-xs">
          <div className="flex items-center space-x-2">
            <CheckCircle className="w-4 h-4 text-emerald-600 flex-shrink-0" />
            <span>{actionSuccess}</span>
          </div>
          <button onClick={() => setActionSuccess(null)} className="text-emerald-600 hover:text-emerald-900 font-bold">&times;</button>
        </div>
      )}

      {/* Error Notification Alert */}
      {actionError && (
        <div className="p-4 bg-rose-50 border border-rose-200 text-rose-800 rounded-xl text-xs font-medium flex items-center justify-between shadow-xs">
          <div className="flex items-center space-x-2">
            <AlertTriangle className="w-4 h-4 text-rose-600 flex-shrink-0" />
            <span>{actionError}</span>
          </div>
          <button onClick={() => setActionError(null)} className="text-rose-600 hover:text-rose-900 font-bold">&times;</button>
        </div>
      )}

      {/* ========================================================================= */}
      {/* LIVE CLIENT EVENT PROPOSALS & OPERATIONAL MANAGEMENT HUB                  */}
      {/* ========================================================================= */}
      <div>
        {/* Operational Section Bar */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4 bg-slate-900 text-white p-6 rounded-2xl shadow-lg border border-slate-800">
          <div>
            <div className="flex items-center space-x-2">
              <span className="text-xs font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-sky-500/20 text-sky-300 border border-sky-500/30">
                Client Event Proposals & AI Budgets
              </span>
            </div>
            <h2 className="text-2xl font-black mt-2">Active Celebrations & Curation Workspace</h2>
            <p className="text-slate-400 text-sm mt-1">Review live hotel catering, hall rentals, audio/visual gear, and autonomous weather safeguards.</p>
          </div>
          <div className="flex items-center space-x-3">
            {/* Manager Notification Bell Button & Floating Dropdown */}
            <div className="relative">
              <button 
                onClick={() => setShowNotificationMenu(!showNotificationMenu)}
                className="relative flex items-center justify-center p-2.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-xl shadow-sm transition"
                title="Manager Live Notifications"
              >
                <Bell className="w-4 h-4 text-sky-400" />
                {unreadCount > 0 && (
                  <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-rose-500 text-[10px] font-extrabold text-white shadow-xs animate-pulse">
                    {unreadCount > 9 ? '9+' : unreadCount}
                  </span>
                )}
              </button>

              {/* Floating Notification Menu Panel */}
              {showNotificationMenu && (
                <div className="absolute right-0 mt-3 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-slate-200 z-50 text-slate-800 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-150">
                  <div className="p-4 bg-slate-900 text-white flex items-center justify-between border-b border-slate-800">
                    <div className="flex items-center space-x-2">
                      <Bell className="w-4 h-4 text-sky-400" />
                      <span className="font-bold text-sm">Manager Notifications</span>
                      {unreadCount > 0 && (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-sky-500 text-white">
                          {unreadCount} New
                        </span>
                      )}
                    </div>
                    {unreadCount > 0 && (
                      <button 
                        onClick={handleMarkAllAsRead}
                        className="text-[11px] font-semibold text-sky-400 hover:text-sky-300 transition"
                      >
                        Mark all read
                      </button>
                    )}
                  </div>

                  <div className="max-h-80 overflow-y-auto divide-y divide-slate-100">
                    {managerNotifications.length === 0 ? (
                      <div className="p-6 text-center text-slate-400 text-xs">
                        <CheckCircle className="w-8 h-8 mx-auto mb-2 text-slate-300 opacity-60" />
                        No notifications yet. You're all caught up!
                      </div>
                    ) : (
                      managerNotifications.map((n) => (
                        <div 
                          key={n.notificationId}
                          onClick={() => handleMarkAsRead(n.notificationId, n.eventId)}
                          className={`p-3.5 hover:bg-sky-50/60 cursor-pointer transition flex items-start space-x-3 ${!n.isRead ? 'bg-sky-50/30' : ''}`}
                        >
                          <div className="text-base flex-shrink-0 mt-0.5">
                            {n.type === 'NewEvent' && '🆕'}
                            {n.type === 'RevisionRequest' && '📝'}
                            {n.type === 'PaymentSlipUploaded' && '💳'}
                            {n.type === 'ProposalAccepted' && '✅'}
                            {n.type === 'WeatherAlert' && '🌦️'}
                            {n.type === 'VendorResponse' && '🏬'}
                            {!['NewEvent', 'RevisionRequest', 'PaymentSlipUploaded', 'ProposalAccepted', 'WeatherAlert', 'VendorResponse'].includes(n.type) && '🛎️'}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between gap-1">
                              <h4 className={`text-xs font-bold truncate ${!n.isRead ? 'text-slate-900 font-extrabold' : 'text-slate-700'}`}>
                                {n.title}
                              </h4>
                              {!n.isRead && (
                                <span className="w-2 h-2 rounded-full bg-sky-500 flex-shrink-0"></span>
                              )}
                            </div>
                            <p className="text-[11px] text-slate-500 mt-0.5 line-clamp-2 leading-relaxed">
                              {n.message}
                            </p>
                            <span className="text-[10px] text-slate-400 mt-1 block">
                              {new Date(n.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} • {new Date(n.createdAt).toLocaleDateString()}
                            </span>
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              )}
            </div>

            <button 
              onClick={loadEvents}
              className="flex items-center space-x-1.5 px-4 py-2.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-xl text-xs font-bold shadow-sm transition"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin text-sky-400' : ''}`} />
              <span>Reload</span>
            </button>
          </div>
        </div>

        {/* KPI Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
            <div>
              <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Active Inquiries</p>
              <p className="text-2xl font-black text-slate-800 mt-1">{activeCount}</p>
            </div>
            <div className="p-3 bg-sky-50 rounded-xl text-sky-600 border border-sky-100"><Calendar className="w-5 h-5" /></div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
            <div>
              <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Pending Review</p>
              <p className="text-2xl font-black text-amber-600 mt-1">{pendingCount}</p>
            </div>
            <div className="p-3 bg-amber-50 rounded-xl text-amber-600 border border-amber-100"><Clock className="w-5 h-5" /></div>
          </div>

          <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
            <div>
              <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Approved & Ready</p>
              <p className="text-2xl font-black text-emerald-600 mt-1">{confirmedCount}</p>
            </div>
            <div className="p-3 bg-emerald-50 rounded-xl text-emerald-600 border border-emerald-100"><CheckCircle className="w-5 h-5" /></div>
          </div>
        </div>

        {/* Event Requests Gallery & Filter Controls */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 mb-6">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-5 pb-4 border-b border-slate-100">
            <div>
              <div className="flex items-center space-x-2">
                <Sparkles className="w-4 h-4 text-indigo-600" />
                <h3 className="font-bold text-slate-900 text-base">Client Event Requests ({events.length} Total)</h3>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">Select any event below to inspect AI-curated vendor allocations, weather analysis, and budgets.</p>
            </div>

            {/* Filter Tabs & Search */}
            <div className="flex flex-wrap items-center gap-2 w-full md:w-auto">
              <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200 text-xs">
                <button
                  onClick={() => setEventFilterTab('all')}
                  className={`px-3 py-1.5 rounded-lg font-bold transition ${
                    eventFilterTab === 'all' ? 'bg-white text-slate-900 shadow-xs' : 'text-slate-600 hover:text-slate-900'
                  }`}
                >
                  All ({events.length})
                </button>
                <button
                  onClick={() => setEventFilterTab('pending')}
                  className={`px-3 py-1.5 rounded-lg font-bold transition flex items-center space-x-1 ${
                    eventFilterTab === 'pending' ? 'bg-white text-amber-700 shadow-xs' : 'text-slate-600 hover:text-amber-700'
                  }`}
                >
                  <span>Pending ({pendingCount})</span>
                </button>
                <button
                  onClick={() => setEventFilterTab('approved')}
                  className={`px-3 py-1.5 rounded-lg font-bold transition flex items-center space-x-1 ${
                    eventFilterTab === 'approved' ? 'bg-white text-emerald-700 shadow-xs' : 'text-slate-600 hover:text-emerald-700'
                  }`}
                >
                  <span>Approved ({confirmedCount})</span>
                </button>
              </div>

              <div className="relative flex-1 md:w-56">
                <div className="absolute inset-y-0 left-0 pl-2.5 flex items-center pointer-events-none">
                  <Search className="h-3.5 w-3.5 text-slate-400" />
                </div>
                <input
                  type="text"
                  placeholder="Search events..."
                  value={eventSearchQuery}
                  onChange={e => setEventSearchQuery(e.target.value)}
                  className="w-full pl-8 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-xl text-xs placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>
          </div>

          {/* Cards Grid */}
          {filteredEvents.length === 0 ? (
            <div className="text-center py-12 text-slate-500 text-xs bg-slate-50 rounded-xl border border-dashed border-slate-200">
              <Calendar className="w-8 h-8 mx-auto text-slate-400 mb-2" />
              <p className="font-semibold text-slate-700">No event proposals matching this filter.</p>
              <p className="text-slate-400 mt-1">Submit a new celebration inquiry through the mobile app or web portal!</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {filteredEvents.map((ev) => {
                const isSelected = selectedEvent?.eventId === ev.eventId;
                const isEvApproved = ev.status === 'ApprovedByManager' || ev.status === 'Confirmed';
                const icon = getEventTypeIcon(ev.eventType);

                return (
                  <div
                    key={ev.eventId}
                    onClick={() => setSelectedEvent(ev)}
                    className={`p-4 rounded-xl border text-left transition cursor-pointer flex flex-col justify-between relative ${
                      isSelected
                        ? 'bg-gradient-to-br from-slate-900 to-indigo-950 text-white border-indigo-500 shadow-md ring-2 ring-indigo-500/30'
                        : 'bg-slate-50 hover:bg-white text-slate-800 border-slate-200 hover:border-indigo-300 hover:shadow-xs'
                    }`}
                  >
                    <div>
                      <div className="flex justify-between items-center mb-2">
                        <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full flex items-center space-x-1 ${
                          isSelected 
                            ? 'bg-white/10 text-white border border-white/20' 
                            : 'bg-indigo-50 text-indigo-700 border border-indigo-100'
                        }`}>
                          <span>{icon}</span>
                          <span>{ev.eventType || 'Event'}</span>
                        </span>

                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center space-x-1 ${
                          isEvApproved
                            ? (isSelected ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30' : 'bg-emerald-100 text-emerald-800')
                            : ev.status === 'ClientChoiceSubmitted'
                            ? (isSelected ? 'bg-teal-500/20 text-teal-300 border border-teal-500/30' : 'bg-teal-100 text-teal-800 border border-teal-200')
                            : (isSelected ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30' : 'bg-amber-100 text-amber-800')
                        }`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${isEvApproved ? 'bg-emerald-400' : ev.status === 'ClientChoiceSubmitted' ? 'bg-teal-500' : 'bg-amber-400 animate-pulse'}`} />
                          <span>{isEvApproved ? 'Approved' : ev.status === 'ClientChoiceSubmitted' ? 'Client Agreed' : 'Pending'}</span>
                        </span>
                      </div>

                      <h4 className={`font-bold text-sm leading-snug line-clamp-1 ${isSelected ? 'text-white' : 'text-slate-900'}`}>
                        {ev.title}
                      </h4>

                      <p className={`text-xs mt-1.5 flex items-center truncate ${isSelected ? 'text-slate-300' : 'text-slate-500'}`}>
                        <MapPin className={`w-3 h-3 mr-1 flex-shrink-0 ${isSelected ? 'text-sky-400' : 'text-slate-400'}`} />
                        <span className="truncate">{ev.banquetHallName || ev.venueName || 'Luxury Venue'}</span>
                      </p>
                    </div>

                    <div className={`mt-3 pt-2.5 border-t flex items-center justify-between text-[11px] ${
                      isSelected ? 'border-white/10 text-slate-300' : 'border-slate-200/80 text-slate-500'
                    }`}>
                      <span className="flex items-center">
                        <Calendar className="w-3 h-3 mr-1 opacity-70" />
                        {formatEventDate(ev.targetDate)}
                      </span>
                      <span className="flex items-center">
                        <Users className="w-3 h-3 mr-1 opacity-70" />
                        {ev.guestCount} Guests
                      </span>
                      <span className={`font-bold ${isSelected ? 'text-sky-300' : 'text-indigo-600'}`}>
                        Rs. {Number(ev.estimatedTotalCost || ev.budgetLimit).toLocaleString()}
                      </span>
                    </div>

                    {/* View & Delete Quick Action Bar */}
                    <div className="mt-2.5 pt-2 flex items-center justify-end space-x-2 border-t border-dashed border-slate-200/40">
                      <button
                        type="button"
                        onClick={(e) => handleViewEvent(e, ev)}
                        className={`px-2.5 py-1 rounded-lg text-[11px] font-bold flex items-center space-x-1 transition ${
                          isSelected 
                            ? 'bg-sky-500 hover:bg-sky-400 text-white shadow-xs' 
                            : 'bg-indigo-50 hover:bg-indigo-100 text-indigo-700 border border-indigo-200'
                        }`}
                        title="View proposal details & AI analysis"
                      >
                        <Eye className="w-3 h-3" />
                        <span>View</span>
                      </button>

                      <button
                        type="button"
                        onClick={(e) => handleDeleteEvent(e, ev.eventId, ev.title)}
                        className={`px-2 py-1 rounded-lg text-[11px] font-bold flex items-center space-x-1 transition ${
                          isSelected 
                            ? 'bg-rose-500/30 hover:bg-rose-500/50 text-rose-200 border border-rose-400/40' 
                            : 'bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200'
                        }`}
                        title="Delete event proposal"
                      >
                        <Trash2 className="w-3 h-3" />
                        <span>Delete</span>
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* ========================================================================= */}
      {/* 5. INSTANT CLIENT AUTHENTICATION MODAL (Log In / Sign Up)                */}
      {/* ========================================================================= */}
      {authModalTab && (
        <div 
          className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in duration-200"
          onClick={() => setAuthModalTab(null)}
        >
          <div 
            className="w-full max-w-md bg-slate-900 border border-slate-700 rounded-3xl p-6 sm:p-8 shadow-2xl text-white relative"
            onClick={e => e.stopPropagation()}
          >
            {/* Close Button */}
            <button 
              onClick={() => setAuthModalTab(null)}
              className="absolute top-4 right-4 p-2 text-slate-400 hover:text-white rounded-full hover:bg-slate-800 transition"
            >
              <X className="w-5 h-5" />
            </button>

            {/* Dedicated Modal Header (No Tab Switching) */}
            {authModalTab === 'login' ? (
              <div className="border-b border-slate-800 pb-4 mb-5">
                <div className="flex items-center space-x-2 text-sky-400 mb-1">
                  <LogIn className="w-5 h-5" />
                  <h3 className="text-base font-bold text-white">Vendor & Admin Sign In</h3>
                </div>
                <p className="text-xs text-slate-400">
                  Access your vendor workspace or administrative controls.
                </p>
              </div>
            ) : (
              <div className="border-b border-slate-800 pb-4 mb-5">
                <div className="flex items-center space-x-2 text-indigo-400 mb-1">
                  <Building2 className="w-5 h-5" />
                  <h3 className="text-base font-bold text-white">Vendor & Supplier Registration</h3>
                </div>
                <p className="text-xs text-slate-400">
                  Register your business as an official event vendor or service partner.
                </p>
              </div>
            )}

            {/* Error Message */}
            {authError && (
              <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-xs text-center">
                {authError}
              </div>
            )}

            {/* Log In Form */}
            {authModalTab === 'login' && (
              <form onSubmit={handleLoginSubmit} className="space-y-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Email Address</label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="email"
                      required
                      value={loginEmail}
                      onChange={e => setLoginEmail(e.target.value)}
                      placeholder="client@example.com"
                      className="w-full pl-9 pr-4 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Password</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="password"
                      required
                      value={loginPassword}
                      onChange={e => setLoginPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full pl-9 pr-4 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={authLoading}
                  className="w-full py-3 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white font-bold text-xs rounded-xl shadow-lg shadow-sky-500/20 transition disabled:opacity-50 mt-2"
                >
                  <LogIn className="w-4 h-4 inline-block mr-1.5" />
                  <span>{authLoading ? 'Signing in...' : 'Sign In'}</span>
                </button>
              </form>
            )}

            {/* Sign Up Form */}
            {authModalTab === 'register' && (
              <form onSubmit={handleRegisterSubmit} className="space-y-3">
                <div className="p-2.5 bg-indigo-950/40 border border-indigo-800/50 rounded-xl flex items-center space-x-2 text-indigo-300 text-xs">
                  <Building2 className="w-4 h-4 text-indigo-400 flex-shrink-0" />
                  <span>Account Type: <strong>Vendor / Supplier Partner</strong></span>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Business / Full Name</label>
                  <div className="relative">
                    <User className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="text"
                      required
                      value={regFullName}
                      onChange={e => setRegFullName(e.target.value)}
                      placeholder="e.g. Royal Blooms Floral Decor"
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Email Address</label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="email"
                      required
                      value={regEmail}
                      onChange={e => setRegEmail(e.target.value)}
                      placeholder="contact@royalblooms.lk"
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Phone Number</label>
                  <div className="relative">
                    <Phone className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="tel"
                      required
                      value={regPhone}
                      onChange={e => setRegPhone(e.target.value)}
                      placeholder="+94 77 123 4567"
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-300 mb-1">Password</label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
                    <input
                      type="password"
                      required
                      value={regPassword}
                      onChange={e => setRegPassword(e.target.value)}
                      placeholder="••••••••"
                      className="w-full pl-9 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={authLoading}
                  className="w-full py-3 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white font-bold text-xs rounded-xl shadow-lg shadow-indigo-500/20 transition disabled:opacity-50 mt-3"
                >
                  <UserPlus className="w-4 h-4 inline-block mr-1.5" />
                  <span>{authLoading ? 'Registering Vendor...' : 'Register as Vendor'}</span>
                </button>
              </form>
            )}

          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 7. COMPLETE EVENT PROPOSAL DETAILS POPUP MODAL                            */}
      {/* ========================================================================= */}
      {viewModalEvent && selectedEvent && (
        <div 
          className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-3 sm:p-6 overflow-y-auto animate-in fade-in duration-200"
          onClick={() => setViewModalEvent(null)}
        >
          <div 
            className="w-full max-w-5xl bg-white border border-slate-200 rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[92vh] relative animate-in zoom-in-95 duration-200 text-slate-800"
            onClick={e => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between border-b border-slate-800 flex-shrink-0">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 rounded-xl bg-sky-500/20 text-sky-400 border border-sky-500/30 flex items-center justify-center text-lg font-bold">
                  {getEventTypeIcon(selectedEvent.eventType)}
                </div>
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-white/10 text-sky-300 border border-white/20">
                      {selectedEvent.eventType || "Event Proposal"}
                    </span>
                    <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                      isApproved
                        ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                        : (selectedEvent.revisionNotes?.includes('AcceptedPremium') || selectedEvent.revisionNotes?.includes('ClientChoiceSubmitted') || (selectedEvent.status === 'ClientChoiceSubmitted' && !selectedEvent.revisionNotes?.includes('RequestedBudgetFit')))
                        ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                        : selectedEvent.revisionNotes?.includes('RequestedBudgetFit')
                        ? 'bg-sky-500/20 text-sky-300 border border-sky-500/30'
                        : 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                    }`}>
                      {isApproved 
                        ? '✓ Approved' 
                        : (selectedEvent.revisionNotes?.includes('AcceptedPremium') || selectedEvent.revisionNotes?.includes('ClientChoiceSubmitted') || (selectedEvent.status === 'ClientChoiceSubmitted' && !selectedEvent.revisionNotes?.includes('RequestedBudgetFit')))
                        ? '✓ Client Agreed to Proposal'
                        : selectedEvent.revisionNotes?.includes('RequestedBudgetFit')
                        ? '⚡ Client: Budget-Fit Requested'
                        : '⏳ Awaiting Manager Approval'}
                    </span>
                  </div>
                  <h3 className="font-extrabold text-base sm:text-lg text-white mt-0.5 line-clamp-1">{selectedEvent.title}</h3>
                </div>
              </div>

              <button 
                onClick={() => setViewModalEvent(null)}
                className="p-2 text-slate-400 hover:text-white rounded-xl hover:bg-slate-800 transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Content (Full Parity with Main View) */}
            <div className="p-6 overflow-y-auto flex-1 space-y-6">
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                
                {/* Left 2 Columns: Event Details, Inspirations, Services, Weather, & Compiled Breakdown */}
                <div className="lg:col-span-2 space-y-6">
                  <div>
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="text-xs font-bold uppercase tracking-wider text-sky-600 bg-sky-50 px-2.5 py-1 rounded-md border border-sky-200 flex items-center space-x-1">
                        <span>{getEventTypeIcon(selectedEvent.eventType)}</span>
                        <span>{selectedEvent.eventType || "Event"}</span>
                      </span>
                      <span className={`text-xs font-bold px-2.5 py-1 rounded-md border flex items-center ${
                        selectedEvent.isOutdoor 
                          ? 'text-amber-800 bg-amber-50 border-amber-200' 
                          : 'text-indigo-800 bg-indigo-50 border-indigo-200'
                      }`}>
                        {selectedEvent.isOutdoor ? '🌳 Outdoor Setting' : '🏛️ Indoor Setting'}
                      </span>
                      {selectedEvent.banquetHallName && (
                        <span className="text-xs font-bold text-emerald-800 bg-emerald-50 px-2.5 py-1 rounded-md border border-emerald-200 flex items-center">
                          <MapPin className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                          {selectedEvent.banquetHallName}
                        </span>
                      )}
                    </div>

                    <h3 className="text-xl font-black text-slate-900 mt-3">{selectedEvent.title}</h3>
                    <p className="text-xs text-slate-500 mt-1">
                      Event ID: <span className="font-mono text-xs text-slate-400">{selectedEvent.eventId}</span>
                    </p>

                    {/* Client Owner Information Box */}
                    <div className="mt-2.5 p-3 bg-gradient-to-r from-blue-50/90 to-indigo-50/70 border border-blue-200/80 rounded-xl flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="w-8 h-8 rounded-full bg-blue-600 text-white font-bold text-xs flex items-center justify-center shadow-xs">
                          {(selectedEvent.customerName || 'Kasun Customer').charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <div className="text-xs font-bold text-slate-800 flex items-center">
                            <span>Client: {selectedEvent.customerName || 'Kasun Customer'}</span>
                            <span className="ml-2 px-1.5 py-0.5 text-[10px] font-semibold bg-blue-100 text-blue-800 rounded">Event Owner</span>
                          </div>
                          <div className="text-[11px] text-slate-500 flex items-center gap-3 mt-0.5">
                            <span className="flex items-center"><Mail className="w-3 h-3 mr-1 text-blue-500" />{selectedEvent.customerEmail || 'customer@eventcraft.lk'}</span>
                            <span className="flex items-center"><Phone className="w-3 h-3 mr-1 text-emerald-500" />{selectedEvent.customerPhone || '+94 77 123 4567'}</span>
                          </div>
                        </div>
                      </div>
                    </div>

                    <p className="text-xs text-slate-600 mt-2.5 font-medium">
                      Target Date: <strong>{formatEventDate(selectedEvent.targetDate)}</strong> • Guests: <strong>{selectedEvent.guestCount}</strong> • Budget Limit: <strong>Rs. {Number(selectedEvent.budgetLimit).toLocaleString()}</strong>
                    </p>
                  </div>

                  {/* Client Inspiration Photos */}
                  {selectedEvent.inspirationImages && selectedEvent.inspirationImages.length > 0 && (
                    <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
                      <div className="flex items-center justify-between mb-3">
                        <h4 className="text-xs font-bold uppercase tracking-wider text-slate-700 flex items-center">
                          <ImageIcon className="w-4 h-4 mr-1.5 text-sky-600" />
                          Client Inspiration Photos ({selectedEvent.inspirationImages.length} Uploaded)
                        </h4>
                        <span className="text-[11px] text-slate-400">Click to zoom</span>
                      </div>
                      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                        {selectedEvent.inspirationImages.map((imgUrl, idx) => (
                          <div 
                            key={idx} 
                            onClick={() => setPreviewImage(imgUrl)}
                            className="group relative cursor-pointer overflow-hidden rounded-lg border border-slate-300 aspect-video bg-slate-900 shadow-xs"
                          >
                            <img 
                              src={imgUrl} 
                              alt={`Inspiration ${idx + 1}`} 
                              className="w-full h-full object-cover group-hover:scale-105 transition duration-300"
                            />
                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition flex items-center justify-center text-white text-xs font-semibold">
                              <Eye className="w-4 h-4 mr-1" /> Zoom
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Client Selected Services */}
                  {selectedEvent.selectedServices && selectedEvent.selectedServices.length > 0 && (
                    <div className="p-4 bg-sky-50/50 border border-sky-100 rounded-xl">
                      <h4 className="text-xs font-bold uppercase tracking-wider text-sky-900 mb-2">
                        Client Selected Services & Preferences
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {selectedEvent.selectedServices.map((service, idx) => (
                          <span key={idx} className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-white text-slate-700 border border-slate-200 shadow-xs">
                            <Check className="w-3 h-3 text-emerald-600 mr-1" />
                            {service}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Special Requests */}
                  {selectedEvent.additionalDetails && (
                    <div className="p-4 bg-gradient-to-r from-rose-50 to-pink-50 border border-rose-200 rounded-xl space-y-3">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-2">
                          <span className="text-base">💐</span>
                          <h4 className="text-xs font-bold uppercase tracking-wider text-rose-900">
                            Special Client Custom Requests
                          </h4>
                        </div>
                        <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full border font-mono ${
                          specialAllocation > 0
                            ? 'bg-rose-100 text-rose-800 border-rose-200'
                            : (isApproved || selectedEvent.status === 'PendingClientBudgetApproval' || selectedEvent.status === 'ClientChoiceSubmitted'
                                ? 'bg-emerald-100 text-emerald-800 border-emerald-200'
                                : 'bg-rose-100 text-rose-800 border-rose-200')
                        }`}>
                          {specialAllocation > 0 
                            ? `Allocated: Rs. ${specialAllocation.toLocaleString()}` 
                            : (isApproved || selectedEvent.status === 'PendingClientBudgetApproval' || selectedEvent.status === 'ClientChoiceSubmitted'
                                ? '✓ Complimentary / Included (Rs. 0)' 
                                : '⏳ Pending Manager Pricing (Rs. 0)')}
                        </span>
                      </div>
                      <p className="text-xs text-rose-950 font-medium whitespace-pre-line pl-6 mb-3">
                        "{selectedEvent.additionalDetails}"
                      </p>

                      {!isApproved && selectedEvent.status !== 'PendingClientBudgetApproval' && selectedEvent.status !== 'ClientChoiceSubmitted' ? (
                        <div className="pt-2 border-t border-rose-200/80 flex items-center justify-between text-xs">
                          <label className="font-bold text-rose-900">Set Manager Allocation (LKR):</label>
                          <div className="flex items-center space-x-1">
                            <span className="font-semibold text-rose-700">Rs.</span>
                            <input
                              type="number"
                              value={specialAllocation === 0 ? '' : specialAllocation}
                              placeholder="0 (Enter allocation)"
                              onChange={(e) => setSpecialAllocation(Math.max(0, Number(e.target.value)))}
                              className="w-36 px-2 py-1 bg-white border border-rose-300 rounded text-right font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-rose-400 placeholder:text-slate-400"
                            />
                          </div>
                        </div>
                      ) : null}
                    </div>
                  )}

                  {/* Weather Contingency Assessment */}
                  {!isEventOutdoor ? (
                    <div className="p-4 bg-emerald-50/90 border border-emerald-200 rounded-xl flex items-start space-x-3">
                      <ShieldCheck className="w-6 h-6 text-emerald-600 flex-shrink-0 mt-0.5" />
                      <div>
                        <div className="flex items-center space-x-2">
                          <h4 className="text-sm font-bold text-emerald-950">Weather Assessment: 0% Risk (Indoor Venue)</h4>
                          <span className="text-[11px] bg-emerald-100 text-emerald-800 font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                            Safe & Sheltered
                          </span>
                        </div>
                        <p className="text-xs text-emerald-800 mt-1">
                          Indoor climate-controlled banquet hall. Outdoor rain & monsoon risks do not apply.
                        </p>
                        <p className="text-xs font-semibold text-emerald-700 mt-2 flex items-center">
                          <CheckCircle className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                          Safeguard: None required. Saved Rs. 150,000 marquee tent budget!
                        </p>
                      </div>
                    </div>
                  ) : weatherTentCost > 0 ? (
                    <div className="p-4 bg-amber-50/90 border border-amber-200 rounded-xl flex items-start space-x-3">
                      <CloudRain className="w-6 h-6 text-amber-600 flex-shrink-0 mt-0.5" />
                      <div>
                        <div className="flex items-center space-x-2">
                          <h4 className="text-sm font-bold text-amber-900">
                            Weather Agent Assessment: {rainPct}% Rain Risk ({weatherCondition})
                          </h4>
                          <span className="text-[11px] bg-amber-100 text-amber-800 font-bold px-2 py-0.5 rounded-full border border-amber-200">
                            Outdoor Monsoon Alert
                          </span>
                        </div>
                        <p className="text-xs text-amber-800 mt-1">
                          {`High precipitation probability (${rainPct}%) predicted for outdoor grounds. Autonomous safeguard: ${weatherTentName} (Rs. ${weatherTentCost.toLocaleString()}) included to secure the event.`}
                        </p>
                        <p className="text-xs font-semibold text-emerald-800 mt-2 flex items-center">
                          <CheckCircle className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                          {`Autonomous Safeguard: ${weatherTentName} (Rs. ${weatherTentCost.toLocaleString()}) active in breakdown below.`}
                        </p>
                      </div>
                    </div>
                  ) : (
                    <div className="p-4 bg-sky-50/90 border border-sky-200 rounded-xl flex items-start space-x-3">
                      <Sun className="w-6 h-6 text-amber-500 flex-shrink-0 mt-0.5" />
                      <div>
                        <div className="flex items-center space-x-2">
                          <h4 className="text-sm font-bold text-sky-950">
                            Weather Forecast: {rainPct}% Rain Probability ({weatherCondition})
                          </h4>
                          <span className="text-[11px] bg-sky-100 text-sky-800 font-bold px-2 py-0.5 rounded-full border border-sky-200">
                            Clear & Favorable
                          </span>
                        </div>
                        <p className="text-xs text-sky-800 mt-1">
                          {weatherAction || "Dry weather conditions predicted for outdoor setting. No heavy precipitation expected."}
                        </p>
                        <p className="text-xs font-semibold text-emerald-700 mt-2 flex items-center">
                          <CheckCircle className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                          Safeguard: Not required. Saved Rs. 150,000 marquee tent cost.
                        </p>
                      </div>
                    </div>
                  )}

                  {/* Client Decision / Custom Revision Status Banner */}
                  {(() => {
                    const revText = (selectedEvent.revisionNotes || '').trim();
                    const isClientAgreed =
                      selectedEvent.status === 'ClientChoiceSubmitted' && !revText.includes('RequestedBudgetFit') ||
                      revText.includes('ClientChoiceSubmitted') ||
                      revText.includes('AcceptedPremium');
                    const isBudgetFitReq = revText.includes('RequestedBudgetFit');
                    const hasCustomRevision =
                      selectedEvent.status === 'RevisionRequested' ||
                      (revText.length > 0 && !revText.startsWith('ClientChoice:'));

                    if (isClientAgreed) {
                      return (
                        <div className="p-4 bg-gradient-to-r from-emerald-50 to-teal-50 border-2 border-emerald-300 rounded-xl space-y-2.5 shadow-xs">
                          <div className="flex items-center justify-between flex-wrap gap-2">
                            <div className="flex items-center space-x-2">
                              <CheckCircle className="w-5 h-5 text-emerald-600 flex-shrink-0" />
                              <h4 className="text-sm font-bold text-emerald-950 uppercase tracking-wide">
                                Client Agreed & Accepted Proposal
                              </h4>
                            </div>
                            <span className="text-[10px] bg-emerald-200/80 text-emerald-900 font-bold px-2.5 py-0.5 rounded-full border border-emerald-300">
                              ✓ Ready for Final Approval
                            </span>
                          </div>
                          <div className="bg-white/95 p-3 rounded-lg border border-emerald-200 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                            <div>
                              <p className="text-xs font-semibold text-emerald-950">
                                Client reviewed the itemized AI package breakdown on the Mobile App and officially agreed to proceed.
                              </p>
                              <p className="text-[11px] text-slate-500 mt-0.5">
                                Stated Client Budget: Rs. {Number(selectedEvent.budgetLimit).toLocaleString()} • Status: Awaiting Manager Confirmation
                              </p>
                            </div>
                            <div className="sm:text-right flex-shrink-0 bg-emerald-50 px-3 py-1.5 rounded-lg border border-emerald-200">
                              <span className="text-[10px] uppercase font-bold text-emerald-700 block">Agreed Total</span>
                              <span className="text-sm font-extrabold text-emerald-800">Rs. {displayedFinalTotal.toLocaleString()}</span>
                            </div>
                          </div>
                          <p className="text-[11px] text-emerald-800 font-medium">
                            Click <strong>"Approve & Send to Client"</strong> in the right panel to finalize this booking proposal and unlock the client's bank deposit slip upload.
                          </p>
                        </div>
                      );
                    }

                    if (isBudgetFitReq) {
                      return (
                        <div className="p-4 bg-sky-50 border-2 border-sky-300 rounded-xl space-y-2 shadow-xs">
                          <div className="flex items-center justify-between flex-wrap gap-2">
                            <div className="flex items-center space-x-2">
                              <ShieldCheck className="w-5 h-5 text-sky-600 flex-shrink-0" />
                              <h4 className="text-sm font-bold text-sky-950 uppercase tracking-wide">
                                Client Requested Budget-Fit Standard Package
                              </h4>
                            </div>
                            <span className="text-[10px] bg-sky-200 text-sky-900 font-bold px-2.5 py-0.5 rounded-full">
                              Auto-Fit Requested
                            </span>
                          </div>
                          <div className="bg-white/90 p-3 rounded-lg border border-sky-200">
                            <p className="text-xs font-semibold text-sky-950">
                              The client requested to scale down optional service package tiers to fit within their stated budget limit of <strong>Rs. {Number(selectedEvent.budgetLimit).toLocaleString()}</strong>.
                            </p>
                          </div>
                          <p className="text-[11px] text-sky-800">
                            Use the <strong>"Auto-Fit Packages to Budget"</strong> button on the right panel before giving final approval.
                          </p>
                        </div>
                      );
                    }

                    if (hasCustomRevision) {
                      return (
                        <div className="p-4 bg-rose-50 border-2 border-rose-300 rounded-xl space-y-2 shadow-xs">
                          <div className="flex items-center space-x-2">
                            <AlertTriangle className="w-5 h-5 text-rose-600 flex-shrink-0" />
                            <h4 className="text-sm font-bold text-rose-950 uppercase tracking-wide">
                              Client Requested Custom Proposal Revisions
                            </h4>
                            <span className="text-[10px] bg-rose-200 text-rose-900 font-bold px-2 py-0.5 rounded-full">
                              Action Required
                            </span>
                          </div>
                          <div className="bg-white/90 p-3 rounded-lg border border-rose-200">
                            <p className="text-xs font-semibold text-rose-900 italic">
                              "{revText || 'Client has requested adjustments to this event proposal.'}"
                            </p>
                          </div>
                          <p className="text-[11px] text-rose-700">
                            Review the client's request above. You can adjust service package tiers below, update the special request allocation, or apply courtesy discounts before final approval.
                          </p>
                        </div>
                      );
                    }

                    return null;
                  })()}

                  {/* AI Compiled Package Breakdown List */}
                  <div>
                    <h4 className="text-sm font-bold text-slate-800 mb-3">AI Compiled Package Breakdown</h4>
                    <div className="space-y-3">
                      {/* 1. Venue / Banquet Hall Rental */}
                      <div className="text-sm py-2.5 px-3 bg-slate-50 rounded-lg border border-slate-200">
                        <div className="flex justify-between items-center">
                          <div>
                            <span className="text-slate-800 font-medium">
                              {isPrivateVenue 
                                ? "🏡 Private Residence / Client Venue"
                                : (selectedEvent.banquetHallName ? `🏨 ${selectedEvent.banquetHallName} Rental` : "🏨 Selected Venue Rental")
                              }
                            </span>
                            <p className="text-[11px] text-slate-500">
                              {isPrivateVenue 
                                ? `📍 ${selectedEvent.preferredLocation ? selectedEvent.preferredLocation.replace(/Private Residence -? ?/i, '').replace(/\|/g, '•') : selectedEvent.venueName || "Private Grounds"} — Venue fee waived`
                                : "Exclusive venue access & setup"
                              }
                            </p>
                          </div>
                          <span className="font-semibold text-slate-900">
                            {hallRental === 0 ? "Rs. 0 (Waived)" : `Rs. ${hallRental.toLocaleString()}`}
                          </span>
                        </div>
                        {!isApproved && (
                          <div className="mt-2 pt-2 border-t border-slate-200 flex flex-wrap items-center gap-1.5 text-xs">
                            {Boolean(selectedEvent.banquetHallId || (selectedEvent.hallRentalPrice && selectedEvent.hallRentalPrice > 0 && selectedEvent.banquetHallName)) ? (
                              <span className="text-[11px] text-slate-500 font-medium italic">
                                🏨 Contracted Hotel Banquet Hall: Fixed venue rental per hotel booking agreement.
                              </span>
                            ) : (
                              <>
                                <span className="text-[11px] font-bold text-slate-700">Adjust Venue:</span>
                                {isPrivateVenue ? (
                                  <>
                                    <button
                                      type="button"
                                      onClick={() => setCustomHallCost(0)}
                                      className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${hallRental === 0 ? 'bg-emerald-600 text-white shadow-xs' : 'bg-white text-slate-700 border border-slate-300 hover:bg-slate-100'}`}
                                    >
                                      Waived (Rs. 0)
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => setCustomHallCost(30000)}
                                      className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${hallRental === 30000 ? 'bg-indigo-600 text-white shadow-xs' : 'bg-white text-slate-700 border border-slate-300 hover:bg-slate-100'}`}
                                    >
                                      Logistics (30k)
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => setCustomHallCost(50000)}
                                      className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${hallRental === 50000 ? 'bg-indigo-600 text-white shadow-xs' : 'bg-white text-slate-700 border border-slate-300 hover:bg-slate-100'}`}
                                    >
                                      Logistics (50k)
                                    </button>
                                  </>
                                ) : (
                                  <>
                                    <button
                                      type="button"
                                      onClick={() => setCustomHallCost(350000)}
                                      className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${hallRental === 350000 ? 'bg-indigo-600 text-white shadow-xs' : 'bg-white text-slate-700 border border-slate-300 hover:bg-slate-100'}`}
                                    >
                                      Standard (350k)
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => setCustomHallCost(300000)}
                                      className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${hallRental === 300000 ? 'bg-indigo-600 text-white shadow-xs' : 'bg-white text-slate-700 border border-slate-300 hover:bg-slate-100'}`}
                                    >
                                      Partner (300k)
                                    </button>
                                    <button
                                      type="button"
                                      onClick={() => setCustomHallCost(250000)}
                                      className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${hallRental === 250000 ? 'bg-indigo-600 text-white shadow-xs' : 'bg-white text-slate-700 border border-slate-300 hover:bg-slate-100'}`}
                                    >
                                      Rebate (250k)
                                    </button>
                                  </>
                                )}
                                <div className="flex items-center space-x-1 ml-auto">
                                  <span className="text-[10px] text-slate-500 font-medium">Custom Rs.</span>
                                  <input
                                    type="number"
                                    value={customHallCost ?? ''}
                                    placeholder={String(baseHallRental)}
                                    onChange={(e) => setCustomHallCost(e.target.value === '' ? null : Math.max(0, Number(e.target.value)))}
                                    className="w-24 px-1.5 py-0.5 bg-white border border-slate-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-indigo-500"
                                  />
                                  {customHallCost !== null && (
                                    <button type="button" onClick={() => setCustomHallCost(null)} className="text-[10px] text-indigo-600 hover:underline ml-1">
                                      (Reset)
                                    </button>
                                  )}
                                </div>
                              </>
                            )}
                          </div>
                        )}
                      </div>

                      {/* 2. Hotel Catering Buffet / External Caterer */}
                      {(() => {
                        const isHotelInHouseCatering = Boolean(selectedEvent.banquetHallId || (selectedEvent.banquetHallName && !selectedEvent.banquetHallName.toLowerCase().includes('private')));
                        const cateringPartnerName = isHotelInHouseCatering 
                          ? `${selectedEvent.banquetHallName || selectedEvent.venueName || 'Hotel'} Culinary & Banquet Team`
                          : (selectedVendorAssignments['Catering']?.vendorName || 'Perera & Sons (P&S Event Catering)');
                        const cateringPackageName = isHotelInHouseCatering
                          ? `${selectedEvent.cateringStyle || 'Hotel Banquet Buffet'} (Contracted Hotel Catering)`
                          : (selectedVendorAssignments['Catering']?.packageName || 'Banquet Dinner Buffet');

                        return (
                          <div className="text-sm py-2.5 px-3 bg-slate-50 rounded-lg border border-slate-200">
                            <div className="flex justify-between items-center">
                              <div>
                                <span className="text-slate-800 font-medium">
                                  🍽️ {cateringPackageName} ({selectedEvent.guestCount} Guests x Rs. {perPlate.toLocaleString()})
                                </span>
                                <p className="text-[11px] text-emerald-700 font-semibold flex items-center space-x-1 mt-0.5">
                                  <ShieldCheck className="w-3.5 h-3.5 text-emerald-600 inline mr-1" />
                                  Assigned Partner: <strong>{cateringPartnerName}</strong>
                                  <span className="text-[10px] text-emerald-800 bg-emerald-100 font-bold px-1.5 py-0.2 rounded-full ml-1">
                                    {isHotelInHouseCatering ? 'Hotel In-House Catering' : 'Verified Caterer'}
                                  </span>
                                </p>
                              </div>
                              <span className="font-semibold text-slate-900">Rs. {cateringCost.toLocaleString()}</span>
                            </div>
                            {!isApproved && (
                              isHotelInHouseCatering ? (
                                <div className="mt-2 pt-2 border-t border-slate-200 text-xs text-slate-500 italic">
                                  🏨 Hotel In-House Catering: Contracted direct with venue catering team per client selection. External caterer assignment locked.
                                </div>
                              ) : (
                                <>
                                  <div className="mt-2.5 pt-2 border-t border-slate-200 flex flex-wrap items-center justify-between gap-2 text-xs">
                                    <div className="flex items-center space-x-1.5">
                                      <ShieldCheck className="w-4 h-4 text-emerald-600" />
                                      <span className="font-bold text-slate-800">🔄 Switch Caterer / Menu Tier:</span>
                                    </div>
                                    <select
                                      value={selectedVendorAssignments['Catering']?.vendorId || ''}
                                      onChange={(e) => {
                                        const vId = e.target.value;
                                        const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                        if (found) {
                                          setSelectedVendorAssignments(prev => ({
                                            ...prev,
                                            Catering: {
                                              vendorId: vId,
                                              vendorName: found.businessName || found.name || 'Verified Caterer',
                                              packageName: found.packageName,
                                              agreedPayout: found.packagePrice
                                            }
                                          }));
                                          if (found.packagePrice && found.packagePrice > 0) {
                                            setCustomPerPlateCost(found.packagePrice);
                                          }
                                        }
                                      }}
                                      className="bg-white border border-slate-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-emerald-500 max-w-md w-full sm:w-auto"
                                    >
                                      {getVerifiedVendorsForCategory('Catering')
                                        .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                        .map(v => (
                                          <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                            Rs. {Number(v.packagePrice).toLocaleString()}/plate — {v.businessName || v.name} ({v.packageName})
                                          </option>
                                        ))}
                                    </select>
                                  </div>
                                  <div className="mt-2 flex items-center justify-end space-x-1.5 text-xs">
                                    <span className="text-[11px] text-slate-500 font-medium">Negotiated Custom Rate Rs/plate:</span>
                                    <input
                                      type="number"
                                      value={customPerPlateCost ?? ''}
                                      placeholder={String(perPlate)}
                                      onChange={(e) => setCustomPerPlateCost(e.target.value === '' ? null : Math.max(0, Number(e.target.value)))}
                                      className="w-24 px-2 py-0.5 bg-white border border-slate-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-emerald-500"
                                    />
                                    {customPerPlateCost !== null && (
                                      <button type="button" onClick={() => setCustomPerPlateCost(null)} className="text-[10px] text-emerald-700 hover:underline ml-1">
                                        (Reset)
                                      </button>
                                    )}
                                  </div>
                                </>
                              )
                            )}
                          </div>
                        );
                      })()}

                      {/* Refreshments */}
                      {alloc.refreshmentsItems && alloc.refreshmentsItems.length > 0 && (
                        <div className="text-sm py-2.5 px-3 bg-emerald-50/70 rounded-lg border border-emerald-200 space-y-2">
                          {alloc.refreshmentsItems.map((r, idx) => (
                            <div key={idx} className="flex justify-between items-center border-b border-emerald-100 last:border-0 pb-1.5 last:pb-0">
                              <div>
                                <span className="text-emerald-950 font-medium">🍹 {r.name}</span>
                                <p className="text-[11px] text-emerald-700 font-medium">Flat Item Package Price • {selectedEvent.guestCount} Guests served</p>
                              </div>
                              <span className="font-semibold text-slate-900">Rs. {r.cost.toLocaleString()}</span>
                            </div>
                          ))}
                        </div>
                      )}

                      {/* 3. Sound & Lighting */}
                      {alloc.hasSounds && (
                        <div className="text-sm py-2.5 px-3 bg-violet-50/70 rounded-lg border border-violet-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-violet-950 font-medium">🔊 {selectedVendorAssignments['SoundLighting']?.packageName || alloc.soundsName}</span>
                              <p className="text-[11px] text-violet-700 font-semibold flex items-center space-x-1 mt-0.5">
                                <ShieldCheck className="w-3.5 h-3.5 text-violet-600 inline mr-1" />
                                Assigned Partner: <strong>{selectedVendorAssignments['SoundLighting']?.vendorName || 'Mano Sounds & Acoustic Setup - Moratuwa'}</strong>
                                <span className="text-[10px] text-violet-800 bg-violet-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                              </p>
                            </div>
                            <div className="text-right">
                              <div className="flex items-center justify-end space-x-1.5">
                                {customSoundsCost !== null && selectedVendorAssignments['SoundLighting']?.catalogPrice && selectedVendorAssignments['SoundLighting'].catalogPrice !== alloc.soundsCost && (
                                  <span className="text-xs text-slate-400 line-through">
                                    Rs. {selectedVendorAssignments['SoundLighting'].catalogPrice.toLocaleString()}
                                  </span>
                                )}
                                <span className="font-semibold text-slate-900">Rs. {alloc.soundsCost.toLocaleString()}</span>
                              </div>
                              {customSoundsCost !== null && (
                                <span className="text-[10px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.2 rounded-md inline-block mt-0.5">
                                  Negotiated Rate
                                </span>
                              )}
                            </div>
                          </div>
                          {!isApproved && (
                            <>
                              <div className="mt-2.5 pt-2 border-t border-violet-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                <div className="flex items-center space-x-1.5">
                                  <ShieldCheck className="w-4 h-4 text-violet-700" />
                                  <span className="font-bold text-violet-950">🔄 Switch Sound & Lighting Vendor / Package:</span>
                                </div>
                                <select
                                  value={selectedVendorAssignments['SoundLighting']?.vendorId || ''}
                                  onChange={(e) => {
                                    const vId = e.target.value;
                                    const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                    if (found) {
                                      setSelectedVendorAssignments(prev => ({
                                        ...prev,
                                        SoundLighting: {
                                          vendorId: vId,
                                          vendorName: found.businessName || found.name || 'Verified Audio Partner',
                                          packageName: found.packageName,
                                          agreedPayout: found.packagePrice,
                                          catalogPrice: found.packagePrice
                                        }
                                      }));
                                      setCustomSoundsCost(null);
                                    }
                                  }}
                                  className="bg-white border border-violet-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-violet-500 max-w-md w-full sm:w-auto"
                                >
                                  {getVerifiedVendorsForCategory('SoundLighting')
                                    .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                    .map(v => (
                                      <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                        Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                      </option>
                                    ))}
                                </select>
                              </div>
                              <div className="mt-2 flex items-center justify-end space-x-1.5 text-xs">
                                <span className="text-[11px] text-violet-600 font-medium">Negotiated Rate Rs.</span>
                                <input
                                  type="number"
                                  value={customSoundsCost ?? ''}
                                  placeholder={String(alloc.soundsCost)}
                                  onChange={(e) => {
                                    const val = e.target.value === '' ? null : Math.max(0, Number(e.target.value));
                                    setCustomSoundsCost(val);
                                    setSelectedVendorAssignments(prev => {
                                      if (!prev['SoundLighting']) return prev;
                                      return {
                                        ...prev,
                                        SoundLighting: {
                                          ...prev['SoundLighting'],
                                          agreedPayout: val !== null ? val : (prev['SoundLighting'].catalogPrice || prev['SoundLighting'].agreedPayout)
                                        }
                                      };
                                    });
                                  }}
                                  className="w-24 px-2 py-0.5 bg-white border border-violet-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-violet-500"
                                />
                                {customSoundsCost !== null && (
                                  <button 
                                    type="button" 
                                    onClick={() => {
                                      setCustomSoundsCost(null);
                                      setSelectedVendorAssignments(prev => {
                                        if (!prev['SoundLighting']) return prev;
                                        return {
                                          ...prev,
                                          SoundLighting: {
                                            ...prev['SoundLighting'],
                                            agreedPayout: prev['SoundLighting'].catalogPrice || prev['SoundLighting'].agreedPayout
                                          }
                                        };
                                      });
                                    }} 
                                    className="text-[10px] text-violet-700 hover:underline ml-1"
                                  >
                                    (Reset)
                                  </button>
                                )}
                              </div>
                            </>
                          )}
                        </div>
                      )}

                      {/* 4. Theme Decorations */}
                      {alloc.hasDeco && (
                        <div className="text-sm py-2.5 px-3 bg-rose-50/70 rounded-lg border border-rose-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-rose-950 font-medium">🌸 {selectedVendorAssignments['Decor']?.packageName || alloc.decoName}</span>
                              <p className="text-[11px] text-rose-700 font-semibold flex items-center space-x-1 mt-0.5">
                                <ShieldCheck className="w-3.5 h-3.5 text-rose-600 inline mr-1" />
                                Assigned Partner: <strong>{selectedVendorAssignments['Decor']?.vendorName || 'Samanmal Flora & Deco Maharagama'}</strong>
                                <span className="text-[10px] text-rose-800 bg-rose-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                              </p>
                            </div>
                            <div className="text-right">
                              <div className="flex items-center justify-end space-x-1.5">
                                {customDecoCost !== null && selectedVendorAssignments['Decor']?.catalogPrice && selectedVendorAssignments['Decor'].catalogPrice !== alloc.decoCost && (
                                  <span className="text-xs text-slate-400 line-through">
                                    Rs. {selectedVendorAssignments['Decor'].catalogPrice.toLocaleString()}
                                  </span>
                                )}
                                <span className="font-semibold text-slate-900">Rs. {alloc.decoCost.toLocaleString()}</span>
                              </div>
                              {customDecoCost !== null && (
                                <span className="text-[10px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.2 rounded-md inline-block mt-0.5">
                                  Negotiated Rate
                                </span>
                              )}
                            </div>
                          </div>
                          {!isApproved && (
                            <>
                              <div className="mt-2.5 pt-2 border-t border-rose-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                <div className="flex items-center space-x-1.5">
                                  <ShieldCheck className="w-4 h-4 text-rose-700" />
                                  <span className="font-bold text-rose-950">🔄 Switch Decor Partner / Stage Styling:</span>
                                </div>
                                <select
                                  value={selectedVendorAssignments['Decor']?.vendorId || ''}
                                  onChange={(e) => {
                                    const vId = e.target.value;
                                    const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                    if (found) {
                                      setSelectedVendorAssignments(prev => ({
                                        ...prev,
                                        Decor: {
                                          vendorId: vId,
                                          vendorName: found.businessName || found.name || 'Verified Decor Partner',
                                          packageName: found.packageName,
                                          agreedPayout: found.packagePrice,
                                          catalogPrice: found.packagePrice
                                        }
                                      }));
                                      setCustomDecoCost(null);
                                    }
                                  }}
                                  className="bg-white border border-rose-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-rose-500 max-w-md w-full sm:w-auto"
                                >
                                  {getVerifiedVendorsForCategory('Decor')
                                    .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                    .map(v => (
                                      <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                        Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                      </option>
                                    ))}
                                </select>
                              </div>
                              <div className="mt-2 flex items-center justify-end space-x-1.5 text-xs">
                                <span className="text-[11px] text-rose-600 font-medium">Negotiated Rate Rs.</span>
                                <input
                                  type="number"
                                  value={customDecoCost ?? ''}
                                  placeholder={String(alloc.decoCost)}
                                  onChange={(e) => {
                                    const val = e.target.value === '' ? null : Math.max(0, Number(e.target.value));
                                    setCustomDecoCost(val);
                                    setSelectedVendorAssignments(prev => {
                                      if (!prev['Decor']) return prev;
                                      return {
                                        ...prev,
                                        Decor: {
                                          ...prev['Decor'],
                                          agreedPayout: val !== null ? val : (prev['Decor'].catalogPrice || prev['Decor'].agreedPayout)
                                        }
                                      };
                                    });
                                  }}
                                  className="w-24 px-2 py-0.5 bg-white border border-rose-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-rose-500"
                                />
                                {customDecoCost !== null && (
                                  <button 
                                    type="button" 
                                    onClick={() => {
                                      setCustomDecoCost(null);
                                      setSelectedVendorAssignments(prev => {
                                        if (!prev['Decor']) return prev;
                                        return {
                                          ...prev,
                                          Decor: {
                                            ...prev['Decor'],
                                            agreedPayout: prev['Decor'].catalogPrice || prev['Decor'].agreedPayout
                                          }
                                        };
                                      });
                                    }} 
                                    className="text-[10px] text-rose-700 hover:underline ml-1"
                                  >
                                    (Reset)
                                  </button>
                                )}
                              </div>
                            </>
                          )}
                        </div>
                      )}

                      {/* 5. Photography & Media */}
                      {alloc.hasPhoto && (
                        <div className="text-sm py-2.5 px-3 bg-sky-50/70 rounded-lg border border-sky-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-sky-950 font-medium">📸 {selectedVendorAssignments['Photography']?.packageName || alloc.photoName}</span>
                              {selectedVendorAssignments['Photography']?.vendorName && !selectedVendorAssignments['Photography']?.isPending ? (
                                <p className="text-[11px] text-sky-700 font-semibold flex items-center space-x-1 mt-0.5">
                                  <ShieldCheck className="w-3.5 h-3.5 text-sky-600 inline mr-1" />
                                  Assigned Partner: <strong>{selectedVendorAssignments['Photography'].vendorName}</strong>
                                  <span className="text-[10px] text-sky-800 bg-sky-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                                </p>
                              ) : (
                                <p className="text-[11px] text-amber-700 font-medium">⏳ Unassigned — Register photographer in Vendor Portal to auto-allocate</p>
                              )}
                            </div>
                            <div className="text-right">
                              <div className="flex items-center justify-end space-x-1.5">
                                {customPhotoCost !== null && selectedVendorAssignments['Photography']?.catalogPrice && selectedVendorAssignments['Photography'].catalogPrice !== alloc.photoCost && (
                                  <span className="text-xs text-slate-400 line-through">
                                    Rs. {selectedVendorAssignments['Photography'].catalogPrice.toLocaleString()}
                                  </span>
                                )}
                                <span className="font-semibold text-slate-900">Rs. {alloc.photoCost.toLocaleString()}</span>
                              </div>
                              {customPhotoCost !== null && (
                                <span className="text-[10px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.2 rounded-md inline-block mt-0.5">
                                  Negotiated Rate
                                </span>
                              )}
                            </div>
                          </div>
                          {!isApproved && (
                            <>
                              {getVerifiedVendorsForCategory('Photography').length === 0 ? (
                                <div className="mt-2.5 p-3.5 bg-amber-50/90 border border-amber-300 rounded-lg text-xs space-y-1.5">
                                  <div className="flex items-center space-x-1.5 text-amber-900 font-bold">
                                    <Clock className="w-4 h-4 text-amber-600 animate-pulse" />
                                    <span>⏳ Awaiting Live Photographer Registration (Viva Demo Ready)</span>
                                  </div>
                                  <p className="text-amber-800 text-[11px] leading-relaxed">
                                    No photographer accounts are pre-seeded in the database. During your viva demonstration, navigate to the <strong>Vendor Portal</strong>, register a new photographer (e.g. <em>Ceylon Cine Arts</em>), select a package & verify. Once verified, this system will <strong>automatically match and allocate them in real-time</strong>!
                                  </p>
                                </div>
                              ) : (
                                <>
                                  <div className="mt-2.5 pt-2 border-t border-sky-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                    <div className="flex items-center space-x-1.5">
                                      <ShieldCheck className="w-4 h-4 text-sky-700" />
                                      <span className="font-bold text-sky-950">🔄 Switch Photography Partner / Package:</span>
                                    </div>
                                    <select
                                      value={selectedVendorAssignments['Photography']?.vendorId || ''}
                                      onChange={(e) => {
                                        const vId = e.target.value;
                                        const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                        if (found) {
                                          setSelectedVendorAssignments(prev => ({
                                            ...prev,
                                            Photography: {
                                              vendorId: vId,
                                              vendorName: found.businessName || found.name || 'Verified Photographer',
                                              packageName: found.packageName,
                                              agreedPayout: found.packagePrice,
                                              catalogPrice: found.packagePrice,
                                              isPending: false
                                            }
                                          }));
                                          setCustomPhotoCost(null);
                                        }
                                      }}
                                      className="bg-white border border-sky-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-sky-500 max-w-md w-full sm:w-auto"
                                    >
                                      {getVerifiedVendorsForCategory('Photography')
                                        .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                        .map(v => (
                                          <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                            Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                          </option>
                                        ))}
                                    </select>
                                  </div>
                                  <div className="mt-2 flex items-center justify-end space-x-1.5 text-xs">
                                    <span className="text-[11px] text-sky-700 font-medium">Negotiated Rate Rs.</span>
                                    <input
                                      type="number"
                                      value={customPhotoCost ?? ''}
                                      placeholder={String(alloc.photoCost)}
                                      onChange={(e) => {
                                        const val = e.target.value === '' ? null : Math.max(0, Number(e.target.value));
                                        setCustomPhotoCost(val);
                                        setSelectedVendorAssignments(prev => {
                                          if (!prev['Photography']) return prev;
                                          return {
                                            ...prev,
                                            Photography: {
                                              ...prev['Photography'],
                                              agreedPayout: val !== null ? val : (prev['Photography'].catalogPrice || prev['Photography'].agreedPayout)
                                            }
                                          };
                                        });
                                      }}
                                      className="w-24 px-2 py-0.5 bg-white border border-sky-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-sky-500"
                                    />
                                    {customPhotoCost !== null && (
                                      <button 
                                        type="button" 
                                        onClick={() => {
                                          setCustomPhotoCost(null);
                                          setSelectedVendorAssignments(prev => {
                                            if (!prev['Photography']) return prev;
                                            return {
                                              ...prev,
                                              Photography: {
                                                ...prev['Photography'],
                                                agreedPayout: prev['Photography'].catalogPrice || prev['Photography'].agreedPayout
                                              }
                                            };
                                          });
                                        }} 
                                        className="text-[10px] text-sky-700 hover:underline ml-1"
                                      >
                                        (Reset)
                                      </button>
                                    )}
                                  </div>
                                </>
                              )}
                            </>
                          )}
                        </div>
                      )}

                      {/* 6. Celebration Cakes */}
                      {alloc.hasCake && (
                        <div className="text-sm py-2.5 px-3 bg-amber-50/60 rounded-lg border border-amber-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-amber-950 font-medium">🎂 {selectedVendorAssignments['Cake']?.packageName || alloc.cakeLabel}</span>
                              <p className="text-[11px] text-amber-700 font-semibold flex items-center space-x-1 mt-0.5">
                                <ShieldCheck className="w-3.5 h-3.5 text-amber-600 inline mr-1" />
                                Assigned Partner: <strong>{selectedVendorAssignments['Cake']?.vendorName || 'The Fab & Sponge Sweet Treats Colombo'}</strong>
                                <span className="text-[10px] text-amber-800 bg-amber-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                              </p>
                            </div>
                            <div className="text-right">
                              <div className="flex items-center justify-end space-x-1.5">
                                {customCakeCost !== null && selectedVendorAssignments['Cake']?.catalogPrice && selectedVendorAssignments['Cake'].catalogPrice !== alloc.cakeCost && (
                                  <span className="text-xs text-slate-400 line-through">
                                    Rs. {selectedVendorAssignments['Cake'].catalogPrice.toLocaleString()}
                                  </span>
                                )}
                                <span className="font-semibold text-slate-900">Rs. {alloc.cakeCost.toLocaleString()}</span>
                              </div>
                              {customCakeCost !== null && (
                                <span className="text-[10px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.2 rounded-md inline-block mt-0.5">
                                  Negotiated Rate
                                </span>
                              )}
                            </div>
                          </div>
                          {!isApproved && (
                            <>
                              <div className="mt-2.5 pt-2 border-t border-amber-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                <div className="flex items-center space-x-1.5">
                                  <ShieldCheck className="w-4 h-4 text-amber-700" />
                                  <span className="font-bold text-amber-950">🔄 Switch Cake Artisan / Confectionery Tier:</span>
                                </div>
                                <select
                                  value={selectedVendorAssignments['Cake']?.vendorId || ''}
                                  onChange={(e) => {
                                    const vId = e.target.value;
                                    const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                    if (found) {
                                      setSelectedVendorAssignments(prev => ({
                                        ...prev,
                                        Cake: {
                                          vendorId: vId,
                                          vendorName: found.businessName || found.name || 'Verified Cake Partner',
                                          packageName: found.packageName,
                                          agreedPayout: found.packagePrice,
                                          catalogPrice: found.packagePrice
                                        }
                                      }));
                                      setCustomCakeCost(null);
                                    }
                                  }}
                                  className="bg-white border border-amber-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500 max-w-md w-full sm:w-auto"
                                >
                                  {getVerifiedVendorsForCategory('Cake')
                                    .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                    .map(v => (
                                      <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                        Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                      </option>
                                    ))}
                                </select>
                              </div>
                              <div className="mt-2 flex items-center justify-end space-x-1.5 text-xs">
                                <span className="text-[11px] text-amber-600 font-medium">Negotiated Rate Rs.</span>
                                <input
                                  type="number"
                                  value={customCakeCost ?? ''}
                                  placeholder={String(alloc.cakeCost)}
                                  onChange={(e) => {
                                    const val = e.target.value === '' ? null : Math.max(0, Number(e.target.value));
                                    setCustomCakeCost(val);
                                    setSelectedVendorAssignments(prev => {
                                      if (!prev['Cake']) return prev;
                                      return {
                                        ...prev,
                                        Cake: {
                                          ...prev['Cake'],
                                          agreedPayout: val !== null ? val : (prev['Cake'].catalogPrice || prev['Cake'].agreedPayout)
                                        }
                                      };
                                    });
                                  }}
                                  className="w-24 px-2 py-0.5 bg-white border border-amber-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500"
                                />
                                {customCakeCost !== null && (
                                  <button 
                                    type="button" 
                                    onClick={() => {
                                      setCustomCakeCost(null);
                                      setSelectedVendorAssignments(prev => {
                                        if (!prev['Cake']) return prev;
                                        return {
                                          ...prev,
                                          Cake: {
                                            ...prev['Cake'],
                                            agreedPayout: prev['Cake'].catalogPrice || prev['Cake'].agreedPayout
                                          }
                                        };
                                      });
                                    }} 
                                    className="text-[10px] text-amber-700 hover:underline ml-1"
                                  >
                                    (Reset)
                                  </button>
                                )}
                              </div>
                            </>
                          )}
                        </div>
                      )}

                      {/* 7. Luxury Transport */}
                      {alloc.hasTransport && (
                        <div className="text-sm py-2.5 px-3 bg-amber-50/70 rounded-lg border border-amber-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-amber-950 font-medium">🚗 {selectedVendorAssignments['Transport']?.packageName || alloc.transportName}</span>
                              <p className="text-[11px] text-amber-700 font-semibold flex items-center space-x-1 mt-0.5">
                                <ShieldCheck className="w-3.5 h-3.5 text-amber-600 inline mr-1" />
                                Assigned Partner: <strong>{selectedVendorAssignments['Transport']?.vendorName || 'SilverLine Executive BMW Fleet'}</strong>
                                <span className="text-[10px] text-amber-800 bg-amber-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                              </p>
                            </div>
                            <div className="text-right">
                              <div className="flex items-center justify-end space-x-1.5">
                                {customTransportCost !== null && selectedVendorAssignments['Transport']?.catalogPrice && selectedVendorAssignments['Transport'].catalogPrice !== alloc.transportCost && (
                                  <span className="text-xs text-slate-400 line-through">
                                    Rs. {selectedVendorAssignments['Transport'].catalogPrice.toLocaleString()}
                                  </span>
                                )}
                                <span className="font-semibold text-slate-900">Rs. {alloc.transportCost.toLocaleString()}</span>
                              </div>
                              {customTransportCost !== null && (
                                <span className="text-[10px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.2 rounded-md inline-block mt-0.5">
                                  Negotiated Rate
                                </span>
                              )}
                            </div>
                          </div>
                          {!isApproved && (
                            <>
                              <div className="mt-2.5 pt-2 border-t border-amber-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                <div className="flex items-center space-x-1.5">
                                  <ShieldCheck className="w-4 h-4 text-amber-700" />
                                  <span className="font-bold text-amber-950">🔄 Switch VIP Transport / Chauffeur Fleet:</span>
                                </div>
                                <select
                                  value={selectedVendorAssignments['Transport']?.vendorId || ''}
                                  onChange={(e) => {
                                    const vId = e.target.value;
                                    const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                    if (found) {
                                      setSelectedVendorAssignments(prev => ({
                                        ...prev,
                                        Transport: {
                                          vendorId: vId,
                                          vendorName: found.businessName || found.name || 'Verified Transport Partner',
                                          packageName: found.packageName,
                                          agreedPayout: found.packagePrice,
                                          catalogPrice: found.packagePrice
                                        }
                                      }));
                                      setCustomTransportCost(null);
                                    }
                                  }}
                                  className="bg-white border border-amber-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500 max-w-md w-full sm:w-auto"
                                >
                                  {getVerifiedVendorsForCategory('Transport')
                                    .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                    .map(v => (
                                      <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                        Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                      </option>
                                    ))}
                                </select>
                              </div>
                              <div className="mt-2 flex items-center justify-end space-x-1.5 text-xs">
                                <span className="text-[11px] text-amber-600 font-medium">Negotiated Rate Rs.</span>
                                <input
                                  type="number"
                                  value={customTransportCost ?? ''}
                                  placeholder={String(alloc.transportCost)}
                                  onChange={(e) => {
                                    const val = e.target.value === '' ? null : Math.max(0, Number(e.target.value));
                                    setCustomTransportCost(val);
                                    setSelectedVendorAssignments(prev => {
                                      if (!prev['Transport']) return prev;
                                      return {
                                        ...prev,
                                        Transport: {
                                          ...prev['Transport'],
                                          agreedPayout: val !== null ? val : (prev['Transport'].catalogPrice || prev['Transport'].agreedPayout)
                                        }
                                      };
                                    });
                                  }}
                                  className="w-24 px-2 py-0.5 bg-white border border-amber-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500"
                                />
                                {customTransportCost !== null && (
                                  <button 
                                    type="button" 
                                    onClick={() => {
                                      setCustomTransportCost(null);
                                      setSelectedVendorAssignments(prev => {
                                        if (!prev['Transport']) return prev;
                                        return {
                                          ...prev,
                                          Transport: {
                                            ...prev['Transport'],
                                            agreedPayout: prev['Transport'].catalogPrice || prev['Transport'].agreedPayout
                                          }
                                        };
                                      });
                                    }} 
                                    className="text-[10px] text-amber-700 hover:underline ml-1"
                                  >
                                    (Reset)
                                  </button>
                                )}
                              </div>
                            </>
                          )}
                        </div>
                      )}

                      {/* 8. Special Client Request */}
                      {alloc.hasSpecialRequests && (
                        <div className="text-sm py-2.5 px-3 bg-rose-50/80 rounded-lg border border-rose-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-rose-900 font-medium">
                                💐 Special Client Request: {selectedEvent.additionalDetails}
                              </span>
                              <p className="text-[11px] text-rose-500">Dedicated arrangement budget</p>
                            </div>
                            <span className="font-semibold text-rose-700 font-mono">
                              {specialAllocation > 0 ? `Rs. ${alloc.otherCost.toLocaleString()}` : "⏳ Pending Pricing (Rs. 0)"}
                            </span>
                          </div>
                          {!isApproved && (
                            <div className="mt-2 pt-2 border-t border-rose-200 flex flex-wrap items-center gap-1.5 text-xs">
                              <span className="text-[11px] font-bold text-rose-900">Quick Pricing:</span>
                              <button
                                type="button"
                                onClick={() => setSpecialAllocation(0)}
                                className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${specialAllocation === 0 ? 'bg-rose-600 text-white shadow-xs' : 'bg-white text-rose-800 border border-rose-300 hover:bg-rose-100'}`}
                              >
                                No Cost (Rs. 0)
                              </button>
                              <button
                                type="button"
                                onClick={() => setSpecialAllocation(25000)}
                                className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${specialAllocation === 25000 ? 'bg-rose-600 text-white shadow-xs' : 'bg-white text-rose-800 border border-rose-300 hover:bg-rose-100'}`}
                              >
                                Rs. 25k
                              </button>
                              <button
                                type="button"
                                onClick={() => setSpecialAllocation(50000)}
                                className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${specialAllocation === 50000 ? 'bg-rose-600 text-white shadow-xs' : 'bg-white text-rose-800 border border-rose-300 hover:bg-rose-100'}`}
                              >
                                Rs. 50k
                              </button>
                              <button
                                type="button"
                                onClick={() => setSpecialAllocation(75000)}
                                className={`px-2 py-0.5 rounded text-[11px] font-semibold transition ${specialAllocation === 75000 ? 'bg-rose-600 text-white shadow-xs' : 'bg-white text-rose-800 border border-rose-300 hover:bg-rose-100'}`}
                              >
                                Rs. 75k
                              </button>
                              <div className="flex items-center space-x-1 ml-auto">
                                <span className="text-[10px] text-rose-600 font-medium">Enter Rs.</span>
                                <input
                                  type="number"
                                  value={specialAllocation === 0 ? '' : specialAllocation}
                                  placeholder="0"
                                  onChange={(e) => setSpecialAllocation(Math.max(0, Number(e.target.value)))}
                                  className="w-24 px-1.5 py-0.5 bg-white border border-rose-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-rose-500"
                                />
                              </div>
                            </div>
                          )}
                        </div>
                      )}

                      {/* 9. Quick Add Optional Services Toolbar */}
                      {!isApproved && (!alloc.hasSounds || !alloc.hasDeco || !alloc.hasPhoto || !alloc.hasCake || !alloc.hasTransport || !selectedVendorAssignments['PowerBackup']?.vendorId || (isEventOutdoor && weatherTentCost === 0)) && (
                        <div className="p-3 bg-slate-100/90 rounded-lg border border-dashed border-slate-300 flex flex-wrap items-center gap-2">
                          <span className="text-[11px] font-bold text-slate-700 flex items-center">
                            <Sparkles className="w-3.5 h-3.5 mr-1 text-indigo-600" />
                            + Add Service to Proposal:
                          </span>
                          {!alloc.hasSounds && (
                            <button
                              type="button"
                              onClick={() => setCustomSoundsCost(85000)}
                              className="px-2.5 py-1 bg-white hover:bg-violet-50 text-violet-700 border border-violet-200 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>🔊 + Sound & Lighting</span>
                            </button>
                          )}
                          {!alloc.hasDeco && (
                            <button
                              type="button"
                              onClick={() => setCustomDecoCost(80000)}
                              className="px-2.5 py-1 bg-white hover:bg-rose-50 text-rose-700 border border-rose-200 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>🌸 + Decorations</span>
                            </button>
                          )}
                          {!alloc.hasPhoto && (
                            <button
                              type="button"
                              onClick={() => setCustomPhotoCost(100000)}
                              className="px-2.5 py-1 bg-white hover:bg-sky-50 text-sky-700 border border-sky-200 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>📸 + Photography</span>
                            </button>
                          )}
                          {!alloc.hasCake && (
                            <button
                              type="button"
                              onClick={() => setCustomCakeCost(25000)}
                              className="px-2.5 py-1 bg-white hover:bg-amber-50 text-amber-700 border border-amber-200 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>🎂 + Celebration Cake</span>
                            </button>
                          )}
                          {!alloc.hasTransport && (
                            <button
                              type="button"
                              onClick={() => setCustomTransportCost(45000)}
                              className="px-2.5 py-1 bg-white hover:bg-amber-50 text-amber-700 border border-amber-200 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>🚗 + Luxury Transport</span>
                            </button>
                          )}
                          {!selectedVendorAssignments['PowerBackup']?.vendorId && (
                            <button
                              type="button"
                              onClick={() => {
                                const pwrList = getVerifiedVendorsForCategory('PowerBackup');
                                const pwr = pwrList.length > 0 ? pwrList[0] : null;
                                if (pwr) {
                                  setSelectedVendorAssignments(prev => ({
                                    ...prev,
                                    PowerBackup: {
                                      vendorId: pwr.vendorId || (pwr as any).id,
                                      vendorName: pwr.businessName || pwr.name,
                                      packageName: pwr.packageName,
                                      agreedPayout: pwr.packagePrice,
                                      catalogPrice: pwr.packagePrice
                                    }
                                  }));
                                }
                              }}
                              className="px-2.5 py-1 bg-white hover:bg-amber-50 text-amber-800 border border-amber-300 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>⚡ + Power Backup Generator</span>
                            </button>
                          )}
                          {isEventOutdoor && weatherTentCost === 0 && (
                            <button
                              type="button"
                              onClick={() => {
                                setCustomTentCost(null);
                                const tentList = getVerifiedVendorsForCategory('MarqueeTent');
                                const tnt = tentList.length > 0 ? tentList[0] : null;
                                if (tnt) {
                                  setSelectedVendorAssignments(prev => ({
                                    ...prev,
                                    MarqueeTent: {
                                      vendorId: tnt.vendorId || (tnt as any).id,
                                      vendorName: tnt.businessName || tnt.name,
                                      packageName: tnt.packageName,
                                      agreedPayout: tnt.packagePrice,
                                      catalogPrice: tnt.packagePrice
                                    }
                                  }));
                                }
                              }}
                              className="px-2.5 py-1 bg-white hover:bg-amber-50 text-amber-800 border border-amber-300 rounded text-xs font-semibold flex items-center space-x-1 shadow-2xs transition"
                            >
                              <span>🎪 + Weather Marquee Tent</span>
                            </button>
                          )}
                        </div>
                      )}

                      {/* Weather Tent Safeguard */}
                      {weatherTentCost > 0 && (
                        <div className="text-sm py-2.5 px-3 bg-amber-50/70 rounded-lg border border-amber-200">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-amber-950 font-medium">🎪 {selectedVendorAssignments['MarqueeTent']?.packageName || weatherTentName}</span>
                              <p className="text-[11px] text-amber-700 font-semibold flex items-center space-x-1 mt-0.5">
                                <ShieldCheck className="w-3.5 h-3.5 text-amber-600 inline mr-1" />
                                Assigned Partner: <strong>{selectedVendorAssignments['MarqueeTent']?.vendorName || 'Ceylon WeatherShield Marquee Tents'}</strong>
                                <span className="text-[10px] text-amber-800 bg-amber-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                              </p>
                            </div>
                            <div className="text-right">
                              <div className="flex items-center justify-end space-x-1.5">
                                {customTentCost !== null && selectedVendorAssignments['MarqueeTent']?.catalogPrice && selectedVendorAssignments['MarqueeTent'].catalogPrice !== weatherTentCost && (
                                  <span className="text-xs text-slate-400 line-through">
                                    Rs. {selectedVendorAssignments['MarqueeTent'].catalogPrice.toLocaleString()}
                                  </span>
                                )}
                                <span className="font-semibold text-slate-900">Rs. {weatherTentCost.toLocaleString()}</span>
                              </div>
                              {customTentCost !== null && (
                                <span className="text-[10px] bg-amber-100 text-amber-800 font-bold px-1.5 py-0.2 rounded-md inline-block mt-0.5">
                                  Negotiated Rate
                                </span>
                              )}
                            </div>
                          </div>
                          {!isApproved && (
                            <>
                              <div className="mt-2.5 pt-2 border-t border-amber-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                <div className="flex items-center space-x-1.5">
                                  <ShieldCheck className="w-4 h-4 text-amber-700" />
                                  <span className="font-bold text-amber-950">🔄 Switch Rain Safeguard / Marquee Partner:</span>
                                </div>
                                <select
                                  value={selectedVendorAssignments['MarqueeTent']?.vendorId || ''}
                                  onChange={(e) => {
                                    const vId = e.target.value;
                                    const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                    if (found) {
                                      setSelectedVendorAssignments(prev => ({
                                        ...prev,
                                        MarqueeTent: {
                                          vendorId: vId,
                                          vendorName: found.businessName || found.name || 'Verified Marquee Partner',
                                          packageName: found.packageName,
                                          agreedPayout: found.packagePrice,
                                          catalogPrice: found.packagePrice
                                        }
                                      }));
                                      setCustomTentCost(null);
                                    }
                                  }}
                                  className="bg-white border border-amber-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500 max-w-md w-full sm:w-auto"
                                >
                                  {getVerifiedVendorsForCategory('MarqueeTent')
                                    .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                    .map(v => (
                                      <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                        Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                      </option>
                                    ))}
                                </select>
                              </div>
                              <div className="mt-2 flex items-center justify-between text-xs">
                                <button
                                  type="button"
                                  onClick={() => {
                                    setSelectedVendorAssignments(prev => {
                                      const next = { ...prev };
                                      delete next['MarqueeTent'];
                                      return next;
                                    });
                                    setCustomTentCost(0);
                                  }}
                                  className="text-[11px] text-amber-800 hover:text-rose-600 font-semibold underline"
                                >
                                  (Waive Tent Safeguard)
                                </button>
                                <div className="flex items-center space-x-1.5">
                                  <span className="text-[11px] text-amber-700 font-medium">Negotiated Rate Rs.</span>
                                  <input
                                    type="number"
                                    value={customTentCost ?? ''}
                                    placeholder={String(weatherTentCost)}
                                    onChange={(e) => {
                                      const val = e.target.value === '' ? null : Math.max(0, Number(e.target.value));
                                      setCustomTentCost(val);
                                      setSelectedVendorAssignments(prev => {
                                        if (!prev['MarqueeTent']) return prev;
                                        return {
                                          ...prev,
                                          MarqueeTent: {
                                            ...prev['MarqueeTent'],
                                            agreedPayout: val !== null ? val : (prev['MarqueeTent'].catalogPrice || prev['MarqueeTent'].agreedPayout)
                                          }
                                        };
                                      });
                                    }}
                                    className="w-24 px-2 py-0.5 bg-white border border-amber-300 rounded text-right text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500"
                                  />
                                  {customTentCost !== null && (
                                    <button 
                                      type="button" 
                                      onClick={() => {
                                        setCustomTentCost(null);
                                        setSelectedVendorAssignments(prev => {
                                          if (!prev['MarqueeTent']) return prev;
                                          return {
                                            ...prev,
                                            MarqueeTent: {
                                              ...prev['MarqueeTent'],
                                              agreedPayout: prev['MarqueeTent'].catalogPrice || prev['MarqueeTent'].agreedPayout
                                            }
                                          };
                                        });
                                      }} 
                                      className="text-[10px] text-amber-700 hover:underline ml-1"
                                    >
                                      (Reset)
                                    </button>
                                  )}
                                </div>
                              </div>
                            </>
                          )}
                        </div>
                      )}

                      {/* Outdoor Power Contingency Safeguard */}
                      {Boolean(selectedVendorAssignments['PowerBackup']?.vendorId) && (
                        <div className="text-sm py-2.5 px-3 bg-amber-50/70 rounded-lg border border-amber-200 mt-2.5">
                          <div className="flex justify-between items-center">
                            <div>
                              <span className="text-amber-950 font-medium">⚡ {selectedVendorAssignments['PowerBackup']?.packageName || 'Heavy-Duty Silent Power Backup Generator'}</span>
                              <p className="text-[11px] text-amber-700 font-semibold flex items-center space-x-1 mt-0.5">
                                <ShieldCheck className="w-3.5 h-3.5 text-amber-600 inline mr-1" />
                                Assigned Partner: <strong>{selectedVendorAssignments['PowerBackup']?.vendorName || 'SparkLine Power Contingency'}</strong>
                                <span className="text-[10px] text-amber-800 bg-amber-100 font-bold px-1.5 py-0.2 rounded-full ml-1">Verified Partner</span>
                              </p>
                            </div>
                            <span className="font-semibold text-slate-900">
                              Rs. {(selectedVendorAssignments['PowerBackup']?.agreedPayout || powerBackupCost).toLocaleString()}
                            </span>
                          </div>
                          {!isApproved && (
                            <>
                              <div className="mt-2.5 pt-2 border-t border-amber-200/80 flex flex-wrap items-center justify-between gap-2 text-xs">
                                <div className="flex items-center space-x-1.5">
                                  <ShieldCheck className="w-3.5 h-3.5 text-amber-700" />
                                  <span className="font-bold text-amber-950">🔄 Switch Power Contingency Partner:</span>
                                </div>
                                <select
                                  value={selectedVendorAssignments['PowerBackup']?.vendorId || ''}
                                  onChange={(e) => {
                                    const vId = e.target.value;
                                    const found = availableVendors.find(v => (v.vendorId || (v as any).id) === vId);
                                    setSelectedVendorAssignments(prev => {
                                      const next = { ...prev };
                                      if (found) {
                                        next['PowerBackup'] = {
                                          vendorId: vId,
                                          vendorName: found.businessName || found.name || 'Verified Generator Partner',
                                          packageName: found.packageName,
                                          agreedPayout: found.packagePrice,
                                          catalogPrice: found.packagePrice
                                        };
                                      } else {
                                        delete next['PowerBackup'];
                                      }
                                      return next;
                                    });
                                  }}
                                  className="bg-white border border-amber-300 rounded-lg px-2.5 py-1 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-1 focus:ring-amber-500 max-w-md w-full sm:w-auto"
                                >
                                  {getVerifiedVendorsForCategory('PowerBackup')
                                    .sort((a, b) => (Number(a.packagePrice) || 0) - (Number(b.packagePrice) || 0))
                                    .map(v => (
                                      <option key={v.vendorId || (v as any).id} value={v.vendorId || (v as any).id}>
                                        Rs. {Number(v.packagePrice).toLocaleString()} — {v.businessName || v.name} ({v.packageName})
                                      </option>
                                    ))}
                                </select>
                              </div>
                              <div className="mt-2 flex items-center justify-end text-xs">
                                <button
                                  type="button"
                                  onClick={() => {
                                    setSelectedVendorAssignments(prev => {
                                      const next = { ...prev };
                                      delete next['PowerBackup'];
                                      return next;
                                    });
                                  }}
                                  className="text-[11px] text-rose-700 hover:text-rose-900 font-semibold underline"
                                >
                                  (Remove Contingency)
                                </button>
                              </div>
                            </>
                          )}
                        </div>
                      )}

                      {/* Manager Courtesy Discount */}
                      {specialDiscount > 0 && (
                        <div className="flex justify-between items-center text-sm py-2 px-3 bg-emerald-50 rounded-lg border border-emerald-200">
                          <div>
                            <span className="text-emerald-800 font-medium">🏷️ Manager Courtesy Discount</span>
                            <p className="text-[11px] text-emerald-600">Special courtesy deduction applied</p>
                          </div>
                          <span className="font-semibold text-emerald-700">- Rs. {specialDiscount.toLocaleString()}</span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Right Column: Pricing Summary & Manager Action Box */}
                <div className="bg-slate-50 p-6 rounded-xl border border-slate-200 flex flex-col justify-between">
                  <div>
                    <h4 className="text-base font-bold text-slate-900 mb-4">Pricing Summary & Actions</h4>
                    
                    {/* Smart Budget Overrun Guardrail Box */}
                    {(() => {
                      const isClientAccepted =
                        selectedEvent.revisionNotes?.includes('AcceptedPremium') ||
                        selectedEvent.revisionNotes?.includes('ClientChoiceSubmitted') ||
                        (selectedEvent.status === 'ClientChoiceSubmitted' && !selectedEvent.revisionNotes?.includes('RequestedBudgetFit'));
                      const isClientBudgetFit = selectedEvent.revisionNotes?.includes('RequestedBudgetFit');

                      if (isClientAccepted) {
                        return (
                          <div className="mb-6 p-4 rounded-xl border border-emerald-300 bg-emerald-50/90 space-y-2 shadow-xs">
                            <div className="flex items-start space-x-2.5">
                              <CheckCircle className="w-5 h-5 text-emerald-600 flex-shrink-0 mt-0.5" />
                              <div>
                                <h5 className="text-xs font-bold uppercase tracking-wider text-emerald-950">
                                  ✅ CLIENT AGREED & ACCEPTED PROPOSAL
                                </h5>
                                <p className="text-xs text-emerald-900 mt-1">
                                  Client officially agreed to the proposal total of <strong>Rs. {displayedFinalTotal.toLocaleString()}</strong>. Ready for final manager approval.
                                </p>
                              </div>
                            </div>
                          </div>
                        );
                      }

                      if (isBudgetAutoFitted && !isApproved) {
                        return (
                          <div className="mb-6 p-4 rounded-xl border border-emerald-300 bg-emerald-50/90 space-y-3 shadow-xs">
                            <div className="flex items-start space-x-2.5">
                              <CheckCircle className="w-5 h-5 text-emerald-600 flex-shrink-0 mt-0.5" />
                              <div>
                                <h5 className="text-xs font-bold uppercase tracking-wider text-emerald-950">
                                  ✅ PACKAGES AUTO-ADJUSTED TO FIT BUDGET
                                </h5>
                                <p className="text-xs text-emerald-900 mt-1">
                                  Optional services scaled down to fit client's <strong>Rs. {clientBudgetLimit.toLocaleString()}</strong> budget.
                                </p>
                              </div>
                            </div>

                            <div className="pt-2 border-t border-emerald-200/80 flex justify-between items-center">
                              <span className="text-[11px] font-bold text-emerald-900">Final Fitted Total: Rs. {displayedFinalTotal.toLocaleString()}</span>
                              <button
                                type="button"
                                onClick={handleResetAutoFit}
                                className="text-xs text-emerald-800 hover:text-emerald-950 underline font-semibold flex items-center gap-1 bg-emerald-100/80 px-2.5 py-1 rounded transition"
                              >
                                ↩️ Reset Packages (Undo)
                              </button>
                            </div>
                          </div>
                        );
                      }

                      if (overrunAmount > 0 && !isApproved) {
                        return (
                          <div className="mb-6 p-4 rounded-xl border border-amber-300 bg-amber-50/90 space-y-3 shadow-xs">
                            <div className="flex items-start space-x-2.5">
                              <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                              <div>
                                <h5 className="text-xs font-bold uppercase tracking-wider text-amber-950">
                                  ⚠️ Budget Overrun Triggered
                                </h5>
                                <p className="text-xs text-amber-900 mt-1">
                                  Compiled subtotal (<strong>Rs. {currentSubtotal.toLocaleString()}</strong>) exceeds client limit (<strong>Rs. {clientBudgetLimit.toLocaleString()}</strong>) by <strong className="text-rose-700">Rs. {overrunAmount.toLocaleString()}</strong>.
                                </p>
                              </div>
                            </div>

                            {/* Manager Guardrail Actions */}
                            <div className="pt-2 border-t border-amber-200/80 space-y-2">
                              {isClientBudgetFit && (
                                <div className="p-2.5 bg-sky-100 border border-sky-300 rounded-lg text-xs text-sky-950 font-medium flex items-center space-x-2">
                                  <span>📩</span>
                                  <span><strong>Client Decision:</strong> Requested Budget-Fit Standard Package. Click below to auto-fit.</span>
                                </div>
                              )}

                              <p className="text-[11px] font-bold text-amber-950 uppercase tracking-wider">
                                Human-in-the-Loop Manager Guardrails:
                              </p>

                              <button
                                type="button"
                                onClick={handleExecuteAutoFit}
                                className={`w-full text-left px-3 py-2 rounded-lg text-xs font-semibold flex items-center justify-between border transition ${
                                  isBudgetAutoFitted
                                    ? 'bg-emerald-600 text-white border-emerald-700 shadow-xs'
                                    : isClientBudgetFit
                                    ? 'bg-sky-600 text-white border-sky-700 shadow-sm'
                                    : 'bg-white text-slate-800 border-amber-300 hover:bg-amber-100/50'
                                }`}
                              >
                                <span>⚡ 1. Auto-Fit Packages to Budget</span>
                                <span className="text-[10px] opacity-90 font-mono">
                                  Fit to &le; Rs. {clientBudgetLimit >= 1000000 ? `${(clientBudgetLimit / 1000000).toFixed(1)}M` : `${(clientBudgetLimit / 1000).toFixed(0)}k`}
                                </span>
                              </button>

                              {!isClientBudgetFit && (
                                <button
                                  type="button"
                                  onClick={() => {
                                    setClientApprovalRequested(!clientApprovalRequested);
                                    handleResetAutoFit();
                                  }}
                                  className={`w-full text-left px-3 py-2 rounded-lg text-xs font-semibold flex items-center justify-between border transition ${
                                    clientApprovalRequested
                                      ? 'bg-indigo-600 text-white border-indigo-700 shadow-xs'
                                      : 'bg-white text-slate-800 border-amber-300 hover:bg-amber-100/50'
                                  }`}
                                >
                                  <span>📩 {clientApprovalRequested ? '✓ Flagged: Awaiting Client Budget Increase' : '2. Keep Quality & Request Client Budget Increase'}</span>
                                  <span className="text-[10px] opacity-90">{clientApprovalRequested ? 'Active' : 'Notify Client'}</span>
                                </button>
                              )}
                            </div>
                          </div>
                        );
                      }

                      return null;
                    })()}

                    <div className="space-y-3 mb-6">
                      <div className="flex justify-between text-sm text-slate-600">
                        <span>Subtotal:</span>
                        <span className="font-medium">Rs. {currentSubtotal.toLocaleString()}</span>
                      </div>

                      <div className="flex justify-between items-center text-sm text-slate-600">
                        <span>Special Discount:</span>
                        <div className="flex items-center space-x-1">
                          <span className="text-xs text-slate-400">Rs.</span>
                          <input 
                            type="number" 
                            value={specialDiscount}
                            onChange={(e) => setSpecialDiscount(Number(e.target.value))}
                            disabled={isApproved}
                            className="w-24 px-2 py-1 bg-white border border-slate-300 rounded text-right text-sm font-semibold text-slate-800 disabled:bg-slate-100"
                          />
                        </div>
                      </div>

                      <div className="border-t border-slate-200 pt-3 flex justify-between text-base font-bold text-slate-900">
                        <span>Final Total:</span>
                        <span className="text-emerald-600">
                          Rs. {displayedFinalTotal.toLocaleString()}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Approve Button */}
                  <div className="space-y-2">
                    <button 
                      onClick={handleApprove}
                      disabled={isApproved || selectedEvent.status === 'PendingClientBudgetApproval'}
                      className={`w-full py-2.5 text-white font-medium text-sm rounded-lg shadow transition flex items-center justify-center space-x-2 disabled:opacity-50 ${
                        selectedEvent.status === 'ClientChoiceSubmitted' || selectedEvent.revisionNotes?.includes('AcceptedPremium')
                          ? 'bg-emerald-600 hover:bg-emerald-700 font-bold'
                          : clientApprovalRequested
                          ? 'bg-indigo-600 hover:bg-indigo-700 font-bold'
                          : 'bg-emerald-600 hover:bg-emerald-700'
                      }`}
                    >
                      <CheckCircle className="w-4 h-4" />
                      <span>
                        {isApproved 
                          ? 'Approved & Ready for Signing' 
                          : selectedEvent.status === 'PendingClientBudgetApproval'
                          ? '⏳ Proposal Sent to Client (Awaiting Response)'
                          : selectedEvent.status === 'ClientChoiceSubmitted' || selectedEvent.revisionNotes?.includes('AcceptedPremium')
                          ? 'Approve Finalized Proposal (Unlock Client Deposit)'
                          : clientApprovalRequested 
                          ? 'Send Proposal with Client Budget Increase Request' 
                          : isBudgetAutoFitted 
                          ? 'Approve Auto-Fitted Proposal' 
                          : 'Approve Proposal'}
                      </span>
                    </button>
                  </div>

                </div>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="px-6 py-3 bg-slate-50 border-t border-slate-200 flex items-center justify-between flex-shrink-0">
              <span className="text-[11px] text-slate-500 font-medium">EventCraft AI Management Workspace</span>
              <button
                onClick={() => setViewModalEvent(null)}
                className="px-4 py-1.5 bg-slate-200 hover:bg-slate-300 text-slate-700 rounded-xl text-xs font-bold transition"
              >
                Close Window
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 7. HIGH PRIORITY TOP-OVERLAY LIGHTBOX MODAL FOR PHOTOS (z-[100])         */}
      {/* ========================================================================= */}
      {previewImage && (
        <div 
          className="fixed inset-0 z-[100] bg-slate-950/90 backdrop-blur-md flex items-center justify-center p-4 animate-in fade-in duration-200" 
          onClick={() => setPreviewImage(null)}
        >
          <div 
            className="relative max-w-5xl max-h-[90vh] bg-slate-900 rounded-3xl overflow-hidden shadow-2xl border border-slate-700 animate-in zoom-in-95 duration-200" 
            onClick={e => e.stopPropagation()}
          >
            <button 
              onClick={() => setPreviewImage(null)}
              className="absolute top-4 right-4 p-2.5 bg-black/70 hover:bg-black text-white rounded-full transition z-20 shadow-lg border border-white/20"
            >
              <X className="w-5 h-5" />
            </button>
            <img 
              src={previewImage} 
              alt="High Definition Preview" 
              className="w-full h-auto max-h-[85vh] object-contain" 
            />
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 8. ENTERPRISE CUSTOM DELETE CONFIRMATION MODAL (z-[100])                   */}
      {/* ========================================================================= */}
      {deleteModal && (
        <div 
          className="fixed inset-0 z-[100] bg-slate-950/70 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in duration-200"
          onClick={() => !deleteModal.isDeleting && setDeleteModal(null)}
        >
          <div 
            className="relative bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 animate-in zoom-in-95 duration-200 overflow-hidden"
            onClick={e => e.stopPropagation()}
          >
            {/* Top Accent Gradient Bar */}
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
                  {!deleteModal.isDeleting && (
                    <button 
                      onClick={() => setDeleteModal(null)}
                      className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 transition"
                      title="Cancel"
                    >
                      <X className="w-4 h-4" />
                    </button>
                  )}
                </div>
                <h3 className="text-lg font-black text-slate-900 mt-2">
                  Permanently Delete Proposal?
                </h3>
                <p className="text-xs text-slate-500 mt-1.5 leading-relaxed">
                  Are you sure you want to delete <span className="font-bold text-slate-800">"{deleteModal.eventTitle}"</span>? This will permanently remove the proposal, AI allocated budgets, and associated records from the database.
                </p>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="mt-6 flex items-center justify-end space-x-3 pt-4 border-t border-slate-100">
              <button
                type="button"
                disabled={deleteModal.isDeleting}
                onClick={() => setDeleteModal(null)}
                className="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-700 hover:bg-slate-100 text-xs font-bold transition disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={deleteModal.isDeleting}
                onClick={confirmDeleteEvent}
                className="flex items-center space-x-2 px-5 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold shadow-lg shadow-rose-600/30 transition disabled:opacity-50"
              >
                {deleteModal.isDeleting ? (
                  <>
                    <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                    <span>Deleting...</span>
                  </>
                ) : (
                  <>
                    <Trash2 className="w-3.5 h-3.5" />
                    <span>Permanently Delete</span>
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