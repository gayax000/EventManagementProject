import React, { useState, useEffect } from 'react';
import { 
  Calendar, 
  Users, 
  DollarSign, 
  CloudRain, 
  CheckCircle, 
  XCircle, 
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
  Filter,
  ChevronRight
} from 'lucide-react';
import { eventService, type EventItem } from '../services/api';

const getEventTypeIcon = (type?: string) => {
  if (!type) return '🎉';
  const lower = type.toLowerCase();
  if (lower.includes('wedding')) return '💍';
  if (lower.includes('birthday')) return '🎂';
  if (lower.includes('engagement') || lower.includes('anniversary')) return '🥂';
  if (lower.includes('corporate') || lower.includes('launch') || lower.includes('award') || lower.includes('gala')) return '🏢';
  return '🎉';
};

export const Dashboard: React.FC = () => {
  const [events, setEvents] = useState<EventItem[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<EventItem | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [specialDiscount, setSpecialDiscount] = useState<number>(20000);
  const [actionSuccess, setActionSuccess] = useState<string | null>(null);
  const [previewImage, setPreviewImage] = useState<string | null>(null);
  const [eventFilterTab, setEventFilterTab] = useState<'all' | 'pending' | 'approved'>('all');
  const [eventSearchQuery, setEventSearchQuery] = useState('');

  // Fetch Live Events from Backend
  const loadEvents = async () => {
    try {
      setLoading(true);
      const data = await eventService.getMyEvents();
      setEvents(data);
      if (data.length > 0 && !selectedEvent) {
        setSelectedEvent(data[0]); // Select the most recent event
      }
    } catch (err) {
      console.error("Failed to load events from backend", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadEvents();
  }, []);

  // Fetch proposal details to synchronize real database pricing and inspiration photos
  useEffect(() => {
    if (selectedEvent?.eventId) {
      eventService.getProposal(selectedEvent.eventId)
        .then(p => {
          if (p) {
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
              inspirationImages: parsedImages.length > 0 ? parsedImages : (prev.inspirationImages || []),
            } : prev);
          }
        })
        .catch(e => console.log("Proposal fetch info", e));
    }
  }, [selectedEvent?.eventId]);

  // Smart AI Tiered Resource Allocation Engine (Budget & Event-Type Context Aware)
  const getAllocations = (ev: EventItem | null) => {
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
    const services = ev.selectedServices || ['Photography', 'Sound and Lighting', 'Decorations'];

    // 1. Sound & Lighting
    const hasSounds = services.some(s => s.toLowerCase().includes('sound') || s.toLowerCase().includes('lighting'));
    let soundsCost = 0;
    let soundsName = 'Concert Line-Array Sound & Digital Mixer Package';
    if (hasSounds) {
      if (budget >= 2000000) {
        soundsCost = 250000;
        soundsName = 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses';
      } else if (budget >= 1200000) {
        soundsCost = 180000;
        soundsName = 'Concert Line-Array Sound & Digital Mixer Package';
      } else if (budget >= 700000) {
        soundsCost = 120000;
        soundsName = 'Standard Stage Audio + Ambient Warm LED PAR Cans';
      } else {
        soundsCost = 75000;
        soundsName = 'Acoustic PA System + Wireless Dual Mics + Mood Uplights';
      }
    }

    // 2. Decorations
    const hasDeco = services.some(s => s.toLowerCase().includes('deco'));
    let decoCost = 0;
    let decoName = 'Floral Stage & Tablescape Theme Decoration';
    if (hasDeco) {
      if (budget >= 2000000) {
        decoCost = 200000;
        decoName = 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor';
      } else if (budget >= 1200000) {
        decoCost = 130000;
        decoName = 'Thematic Floral Stage + Entrance Tunnel Arch Decor';
      } else if (budget >= 700000) {
        decoCost = 80000;
        decoName = 'Floral Stage & Tablescape Theme Decoration';
      } else {
        decoCost = 50000;
        decoName = 'Fairy-Light Star Backdrop + Geometric Floral Frame';
      }
    }

    // 3. Photography & Media
    const hasPhoto = services.some(s => s.toLowerCase().includes('photo'));
    let photoCost = 0;
    let photoName = 'Professional Event Coverage';
    if (hasPhoto) {
      if (budget >= 2000000) {
        photoCost = 250000;
        photoName = 'Royal Cinematic Rig + Drone + 3 Senior Photographers';
      } else if (budget >= 1200000) {
        photoCost = 160000;
        photoName = 'Master Wedding Photography + 4K Highlights Video + Storybook Album';
      } else if (budget >= 700000) {
        photoCost = 100000;
        photoName = 'Professional Event Coverage (2 Photographers + Unlimited Soft Copies)';
      } else {
        photoCost = 60000;
        photoName = 'Standard Event Photography (Full Day Coverage + Highlights)';
      }
    }

    // 4. Celebration Cakes
    const hasCake = services.some(s => s.toLowerCase().includes('cake'));
    let cakeCost = 0;
    let cakeLabel = 'Celebration Cake';
    if (hasCake) {
      if (eventType.includes('birthday')) {
        if (budget >= 1000000) {
          cakeCost = 35000;
          cakeLabel = '3-Tier Grand Custom Thematic Birthday Cake';
        } else if (budget >= 500000) {
          cakeCost = 20000;
          cakeLabel = '2-Tier Thematic Custom Fondant Birthday Cake';
        } else {
          cakeCost = 12000;
          cakeLabel = 'Classic Celebration Birthday Gateau';
        }
      } else if (eventType.includes('wedding')) {
        if (budget >= 1800000) {
          cakeCost = 65000;
          cakeLabel = '5-Tier Royal Handcrafted Fondant Wedding Cake';
        } else if (budget >= 1000000) {
          cakeCost = 45000;
          cakeLabel = '3-Tier Luxury Floral Wedding Cake';
        } else {
          cakeCost = 30000;
          cakeLabel = '2-Tier Classic Wedding Cake';
        }
      } else if (eventType.includes('anniversary') || eventType.includes('engagement')) {
        if (budget >= 1200000) {
          cakeCost = 40000;
          cakeLabel = '3-Tier Luxury Floral Engagement / Anniversary Cake';
        } else {
          cakeCost = 25000;
          cakeLabel = '2-Tier Signature Handcrafted Engagement Cake';
        }
      } else {
        if (budget >= 1000000) {
          cakeCost = 35000;
          cakeLabel = 'Custom 3D Corporate Logo Reveal Branding Cake';
        } else {
          cakeCost = 18000;
          cakeLabel = 'Signature Celebration Gateau';
        }
      }
    }

    // 5. Luxury Bridal & VIP Transport
    const hasTransport = services.some(s => 
      s.toLowerCase().includes('transport') || 
      s.toLowerCase().includes('car') || 
      s.toLowerCase().includes('bridal')
    );
    let transportCost = 0;
    let transportName = 'Mercedes-Benz S-Class Luxury Chauffeur Sedan';
    if (hasTransport) {
      if (eventType.includes('wedding')) {
        if (budget >= 2000000) {
          transportCost = 95000;
          transportName = 'Classic Vintage Rolls Royce / Jaguar Bridal Car';
        } else if (budget >= 1000000) {
          transportCost = 65000;
          transportName = 'Mercedes-Benz S-Class Luxury Chauffeur Sedan';
        } else {
          transportCost = 50000;
          transportName = 'BMW 5-Series Executive Bridal Sedan';
        }
      } else if (eventType.includes('gala') || eventType.includes('award') || eventType.includes('launch')) {
        transportCost = 50000;
        transportName = 'BMW 5-Series Executive VIP Sedan';
      } else {
        transportCost = 35000;
        transportName = 'Luxury High-Roof VIP Passenger Van (14-Seater)';
      }
    }

    const hasSpecialRequests = Boolean(ev.additionalDetails && ev.additionalDetails.trim().length > 0);
    const otherCost = hasSpecialRequests ? 35000 : 0;

    return {
      hasSounds, soundsCost, soundsName,
      hasDeco, decoCost, decoName,
      hasPhoto, photoCost, photoName,
      hasCake, cakeCost, cakeLabel,
      hasTransport, transportCost, transportName,
      hasSpecialRequests, otherCost,
    };
  };

  // Manager Approve Proposal Action
  const handleApprove = async () => {
    if (!selectedEvent) return;
    const perPlate = selectedEvent.perPlatePrice || 5000;
    const cateringCost = selectedEvent.guestCount * perPlate;
    const hallRental = selectedEvent.hallRentalPrice || 350000;
    const alloc = getAllocations(selectedEvent);

    const isEventOutdoor = selectedEvent.isOutdoor === true;
    const weatherData = selectedEvent.weatherAssessment;
    const rainPct = weatherData ? (weatherData.rainProbabilityPercent ?? weatherData.RainProbabilityPercent ?? 0) : 0;
    const weatherSafeguardCost = weatherData ? (weatherData.safeguardCost ?? weatherData.SafeguardCost ?? 0) : 0;
    const weatherTentCost = isEventOutdoor 
      ? (weatherSafeguardCost > 0 ? weatherSafeguardCost : (rainPct >= 60 ? 150000 : 0))
      : 0;

    const computedSubtotal = cateringCost + hallRental + alloc.soundsCost + alloc.decoCost + alloc.photoCost + alloc.cakeCost + alloc.transportCost + weatherTentCost + alloc.otherCost;
    const computedFinalTotal = Math.max(0, computedSubtotal - specialDiscount);

    try {
      await eventService.approveProposal(selectedEvent.eventId, specialDiscount, computedFinalTotal);
      setActionSuccess("Proposal approved successfully! Synchronized in PostgreSQL Database.");
      setSelectedEvent(prev => prev ? { ...prev, status: 'ApprovedByManager', estimatedTotalCost: computedFinalTotal } : null);
      loadEvents();
    } catch (err) {
      console.error("Approval failed", err);
      alert("Failed to approve proposal on backend.");
    }
  };

  const activeCount = events.filter(e => e.status !== 'Completed' && e.status !== 'Cancelled').length;
  const pendingCount = events.filter(e => e.status === 'PendingManagerApproval' || e.status === 'UnderReview').length;
  const confirmedCount = events.filter(e => e.status === 'ApprovedByManager' || e.status === 'Confirmed').length;

  // Filter events based on active tab and search query
  const filteredEvents = events.filter(ev => {
    const matchesTab = 
      eventFilterTab === 'all' ? true :
      eventFilterTab === 'pending' ? (ev.status === 'PendingManagerApproval' || ev.status === 'UnderReview') :
      (ev.status === 'ApprovedByManager' || ev.status === 'Confirmed');

    const searchLower = eventSearchQuery.toLowerCase();
    const matchesSearch = 
      !eventSearchQuery ||
      ev.title.toLowerCase().includes(searchLower) ||
      (ev.eventType || '').toLowerCase().includes(searchLower) ||
      (ev.venueName || '').toLowerCase().includes(searchLower);

    return matchesTab && matchesSearch;
  });

  // Pricing calculations for current selected event
  const isApproved = selectedEvent?.status === 'ApprovedByManager' || selectedEvent?.status === 'Confirmed';
  const perPlate = selectedEvent?.perPlatePrice || 5000;
  const cateringCost = (selectedEvent?.guestCount || 0) * perPlate;
  const hallRental = selectedEvent?.hallRentalPrice || 350000;
  const alloc = getAllocations(selectedEvent);

  const isEventOutdoor = selectedEvent?.isOutdoor === true;
  const weatherData = selectedEvent?.weatherAssessment;
  const rainPct = weatherData ? (weatherData.rainProbabilityPercent ?? weatherData.RainProbabilityPercent ?? 0) : 0;
  const weatherSafeguardCost = weatherData ? (weatherData.safeguardCost ?? weatherData.SafeguardCost ?? 0) : 0;
  const weatherCondition = weatherData?.condition || weatherData?.Condition || (isEventOutdoor ? "Monsoon Showers" : "Indoor Climate Controlled");
  const weatherAction = weatherData?.actionRequired || weatherData?.ActionRequired || (isEventOutdoor ? "Rain safeguard applied" : "Indoor venue - No weather safeguard required");

  const weatherTentCost = isEventOutdoor 
    ? (weatherSafeguardCost > 0 ? weatherSafeguardCost : (rainPct >= 60 ? 150000 : 0))
    : 0;

  const currentSubtotal = cateringCost + hallRental + alloc.soundsCost + alloc.decoCost + alloc.photoCost + alloc.cakeCost + alloc.transportCost + weatherTentCost + alloc.otherCost;
  const displayedFinalTotal = isApproved && selectedEvent?.estimatedTotalCost
    ? selectedEvent.estimatedTotalCost
    : Math.max(0, currentSubtotal - specialDiscount);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      {/* Top Welcome & Refresh */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4 bg-slate-900 text-white p-6 rounded-2xl shadow-lg border border-slate-800">
        <div>
          <div className="flex items-center space-x-2">
            <span className="text-xs font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
              Operations Manager Control Center
            </span>
            <span className="text-xs text-slate-400">• Multi-Agent AI Workflow</span>
          </div>
          <h1 className="text-2xl font-black mt-2">Event Operations & AI Proposal Management</h1>
          <p className="text-slate-400 text-sm mt-1">Live synchronized with ASP.NET Core & PostgreSQL Neon Cloud Database.</p>
        </div>
        <button 
          onClick={loadEvents}
          className="flex items-center space-x-1.5 px-4 py-2.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-xl text-xs font-bold shadow-sm transition"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin text-sky-400' : ''}`} />
          <span>Sync Live DB</span>
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Active Requests</p>
            <p className="text-2xl font-black text-slate-800 mt-1">{activeCount}</p>
          </div>
          <div className="p-3 bg-sky-50 rounded-xl text-sky-600 border border-sky-100"><Calendar className="w-5 h-5" /></div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Pending Approvals</p>
            <p className="text-2xl font-black text-amber-600 mt-1">{pendingCount}</p>
          </div>
          <div className="p-3 bg-amber-50 rounded-xl text-amber-600 border border-amber-100"><Clock className="w-5 h-5" /></div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Confirmed / Approved</p>
            <p className="text-2xl font-black text-emerald-600 mt-1">{confirmedCount}</p>
          </div>
          <div className="p-3 bg-emerald-50 rounded-xl text-emerald-600 border border-emerald-100"><CheckCircle className="w-5 h-5" /></div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Total Revenue</p>
            <p className="text-2xl font-black text-indigo-600 mt-1">Rs. 4.2M</p>
          </div>
          <div className="p-3 bg-indigo-50 rounded-xl text-indigo-600 border border-indigo-100"><DollarSign className="w-5 h-5" /></div>
        </div>
      </div>

      {/* Success Notification */}
      {actionSuccess && (
        <div className="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-sm font-medium flex items-center justify-between shadow-xs">
          <div className="flex items-center space-x-2">
            <CheckCircle className="w-4 h-4 text-emerald-600 flex-shrink-0" />
            <span>{actionSuccess}</span>
          </div>
          <button onClick={() => setActionSuccess(null)} className="text-emerald-600 hover:text-emerald-900 font-bold">&times;</button>
        </div>
      )}

      {/* Premium Event Requests Gallery */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 mb-8">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-5 pb-4 border-b border-slate-100">
          <div>
            <div className="flex items-center space-x-2">
              <Sparkles className="w-4 h-4 text-indigo-600" />
              <h2 className="font-bold text-slate-900 text-base">Client Event Requests ({events.length} Total)</h2>
            </div>
            <p className="text-xs text-slate-500 mt-0.5">Select an event request below to view AI agent proposal curation, weather risk & pricing.</p>
          </div>

          {/* Search & Tabs Controls */}
          <div className="flex flex-wrap items-center gap-2 w-full md:w-auto">
            {/* Filter Tabs */}
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

            {/* Quick Search */}
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

        {/* Event Cards Grid */}
        {filteredEvents.length === 0 ? (
          <div className="text-center py-10 text-slate-500 text-xs">
            No event requests found matching your filter.
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
                    {/* Top Row: Type & Status */}
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
                          : (isSelected ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30' : 'bg-amber-100 text-amber-800')
                      }`}>
                        <span className={`w-1.5 h-1.5 rounded-full ${isEvApproved ? 'bg-emerald-400' : 'bg-amber-400 animate-pulse'}`} />
                        <span>{isEvApproved ? 'Approved' : 'Pending'}</span>
                      </span>
                    </div>

                    {/* Title */}
                    <h3 className={`font-bold text-sm leading-snug line-clamp-1 ${isSelected ? 'text-white' : 'text-slate-900'}`}>
                      {ev.title}
                    </h3>

                    {/* Venue & Hall */}
                    <p className={`text-xs mt-1.5 flex items-center truncate ${isSelected ? 'text-slate-300' : 'text-slate-500'}`}>
                      <MapPin className={`w-3 h-3 mr-1 flex-shrink-0 ${isSelected ? 'text-sky-400' : 'text-slate-400'}`} />
                      <span className="truncate">{ev.banquetHallName || ev.venueName || 'Luxury Venue'}</span>
                    </p>
                  </div>

                  {/* Bottom Row: Metadata */}
                  <div className={`mt-3 pt-2.5 border-t flex items-center justify-between text-[11px] ${
                    isSelected ? 'border-white/10 text-slate-300' : 'border-slate-200/80 text-slate-500'
                  }`}>
                    <span className="flex items-center">
                      <Calendar className="w-3 h-3 mr-1 opacity-70" />
                      {new Date(ev.targetDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })}
                    </span>
                    <span className="flex items-center">
                      <Users className="w-3 h-3 mr-1 opacity-70" />
                      {ev.guestCount} Guests
                    </span>
                    <span className={`font-bold ${isSelected ? 'text-sky-300' : 'text-indigo-600'}`}>
                      Rs. {(Number(ev.budgetLimit) / 1000000).toFixed(1)}M
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Main Review Section: Live Proposal */}
      {selectedEvent ? (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-8">
          <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Sparkles className="w-5 h-5 text-sky-400 animate-spin" />
              <h2 className="font-bold text-base">Human-in-the-Loop AI Proposal Review (Live DB)</h2>
            </div>
            <span className={`text-xs font-bold px-3 py-1 rounded-full border flex items-center space-x-1.5 ${
              isApproved
                ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30' 
                : 'bg-amber-500/20 text-amber-300 border-amber-500/30 animate-pulse'
            }`}>
              <span>{isApproved ? '✓ Proposal Approved' : '⏳ Awaiting Manager Approval'}</span>
            </span>
          </div>

          <div className="p-6 grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            {/* Proposal Details */}
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
                <p className="text-xs text-slate-600 mt-1 font-medium">
                  Date: <strong>{new Date(selectedEvent.targetDate).toLocaleDateString()}</strong> • Guests: <strong>{selectedEvent.guestCount}</strong> • Budget Limit: <strong>Rs. {Number(selectedEvent.budgetLimit).toLocaleString()}</strong>
                </p>
              </div>

              {/* Client Uploaded Inspiration Photos Gallery */}
              {selectedEvent.inspirationImages && selectedEvent.inspirationImages.length > 0 && (
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-xs font-bold uppercase tracking-wider text-slate-700 flex items-center">
                      <ImageIcon className="w-4 h-4 mr-1.5 text-sky-600" />
                      Client Inspiration Photos ({selectedEvent.inspirationImages.length} Uploaded)
                    </h4>
                    <span className="text-[11px] text-slate-400">Click any photo to zoom</span>
                  </div>
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    {selectedEvent.inspirationImages.map((imgUrl, idx) => (
                      <div 
                        key={idx} 
                        onClick={() => setPreviewImage(imgUrl)}
                        className="group relative cursor-pointer overflow-hidden rounded-lg border border-slate-300 aspect-video bg-slate-900 shadow-sm"
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

              {/* Client Selected Service Options Badges */}
              {selectedEvent.selectedServices && selectedEvent.selectedServices.length > 0 && (
                <div className="p-4 bg-sky-50/50 border border-sky-100 rounded-xl">
                  <h4 className="text-xs font-bold uppercase tracking-wider text-sky-900 mb-2">
                    Client Selected Services & Requirements
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

              {/* Special Client Requests & Add-ons */}
              {selectedEvent.additionalDetails && (
                <div className="p-4 bg-gradient-to-r from-rose-50 to-pink-50 border border-rose-200 rounded-xl">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center space-x-2">
                      <span className="text-base">💐</span>
                      <h4 className="text-xs font-bold uppercase tracking-wider text-rose-900">
                        Special Client Requests & Add-ons
                      </h4>
                    </div>
                    <span className="text-[11px] bg-rose-100 text-rose-800 font-bold px-2 py-0.5 rounded-full border border-rose-200">
                      Budget Allocated: Rs. 35,000
                    </span>
                  </div>
                  <p className="text-xs text-rose-950 font-medium whitespace-pre-line pl-6">
                    "{selectedEvent.additionalDetails}"
                  </p>
                </div>
              )}

              {/* Weather Contingency Assessment Card */}
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
                      {weatherAction || "Autonomous environmental contingency triggered on outdoor venue."}
                    </p>
                    <p className="text-xs font-semibold text-emerald-800 mt-2 flex items-center">
                      <CheckCircle className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                      Auto Safeguard: Heavy-Duty Waterproof Marquee Tent (Rs. {weatherTentCost.toLocaleString()}) added.
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

              {/* Breakdown */}
              <div>
                <h4 className="text-sm font-bold text-slate-800 mb-3">AI Compiled Package Breakdown</h4>
                <div className="space-y-2">
                  <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                    <div>
                      <span className="text-slate-700 font-medium">
                        🏨 {selectedEvent.banquetHallName ? `${selectedEvent.banquetHallName} Rental` : "Selected Venue Rental"}
                      </span>
                      <p className="text-[11px] text-slate-400">Exclusive venue access & setup</p>
                    </div>
                    <span className="font-semibold text-slate-900">Rs. {hallRental.toLocaleString()}</span>
                  </div>

                  <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                    <div>
                      <span className="text-slate-700 font-medium">
                        🍽️ In-House Hotel Dinner Buffet ({selectedEvent.guestCount} Guests x Rs. {perPlate.toLocaleString()})
                      </span>
                      <p className="text-[11px] text-slate-400">Mandatory 5-star hotel catering service</p>
                    </div>
                    <span className="font-semibold text-slate-900">Rs. {cateringCost.toLocaleString()}</span>
                  </div>

                  {alloc.hasSounds && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                      <div>
                        <span className="text-slate-700 font-medium">🔊 {alloc.soundsName}</span>
                        <p className="text-[11px] text-slate-400">Pro audio, digital mixing & intelligent stage lights</p>
                      </div>
                      <span className="font-semibold text-slate-900">Rs. {alloc.soundsCost.toLocaleString()}</span>
                    </div>
                  )}

                  {alloc.hasDeco && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                      <div>
                        <span className="text-slate-700 font-medium">🌸 {alloc.decoName}</span>
                        <p className="text-[11px] text-slate-400">Custom theme stage styling & floral tablescapes</p>
                      </div>
                      <span className="font-semibold text-slate-900">Rs. {alloc.decoCost.toLocaleString()}</span>
                    </div>
                  )}

                  {alloc.hasPhoto && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-sky-50/70 rounded-lg border border-sky-200">
                      <div>
                        <span className="text-sky-950 font-medium">📸 {alloc.photoName}</span>
                        <p className="text-[11px] text-sky-600">In-house media crew, unlimited edited coverage & digital deliverables</p>
                      </div>
                      <span className="font-semibold text-slate-900">Rs. {alloc.photoCost.toLocaleString()}</span>
                    </div>
                  )}

                  {alloc.hasCake && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                      <div>
                        <span className="text-slate-700 font-medium">🎂 {alloc.cakeLabel}</span>
                        <p className="text-[11px] text-slate-400">Handcrafted bespoke celebration tier</p>
                      </div>
                      <span className="font-semibold text-slate-900">Rs. {alloc.cakeCost.toLocaleString()}</span>
                    </div>
                  )}

                  {alloc.hasTransport && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-amber-50/70 rounded-lg border border-amber-200">
                      <div>
                        <span className="text-amber-950 font-medium">🚗 {alloc.transportName}</span>
                        <p className="text-[11px] text-amber-700">Dedicated chauffeur-driven luxury transport & bridal escort</p>
                      </div>
                      <span className="font-semibold text-slate-900">Rs. {alloc.transportCost.toLocaleString()}</span>
                    </div>
                  )}

                  {alloc.hasSpecialRequests && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-rose-50/80 rounded-lg border border-rose-200">
                      <div>
                        <span className="text-rose-900 font-medium">
                          💐 Special Client Request: {selectedEvent.additionalDetails}
                        </span>
                        <p className="text-[11px] text-rose-500">Dedicated arrangement budget (e.g. surprise flower bouquet / welcome add-ons)</p>
                      </div>
                      <span className="font-semibold text-rose-700">Rs. {alloc.otherCost.toLocaleString()}</span>
                    </div>
                  )}

                  {weatherTentCost > 0 && (
                    <div className="flex justify-between items-center text-sm py-2 px-3 bg-amber-50/50 rounded-lg border border-amber-200">
                      <div>
                        <span className="text-slate-700 font-medium">🎪 Waterproof Marquee Tent (Autonomous Weather Safeguard)</span>
                        <p className="text-[11px] text-amber-700">Outdoor rain contingency safeguard</p>
                      </div>
                      <span className="font-semibold text-slate-900">Rs. {weatherTentCost.toLocaleString()}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Manager Approval Box */}
            <div className="bg-slate-50 p-6 rounded-xl border border-slate-200 flex flex-col justify-between">
              <div>
                <h4 className="text-base font-bold text-slate-900 mb-4">Manager Final Action</h4>
                
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

              {/* Action Buttons */}
              <div className="space-y-2">
                <button 
                  onClick={handleApprove}
                  disabled={isApproved}
                  className="w-full py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-medium text-sm rounded-lg shadow transition flex items-center justify-center space-x-2 disabled:opacity-50"
                >
                  <CheckCircle className="w-4 h-4" />
                  <span>{isApproved ? 'Approved & Ready for Signing' : 'Approve Proposal'}</span>
                </button>
              </div>

            </div>

          </div>
        </div>
      ) : (
        <div className="bg-white p-12 text-center rounded-2xl border border-slate-200 text-slate-500">
          No active event requests in database. Create one using Swagger or Flutter mobile app!
        </div>
      )}

      {/* Lightbox / Zoom Modal for Inspiration Images */}
      {previewImage && (
        <div className="fixed inset-0 z-50 bg-black/80 flex items-center justify-center p-4" onClick={() => setPreviewImage(null)}>
          <div className="relative max-w-4xl max-h-[90vh] bg-slate-900 rounded-2xl overflow-hidden shadow-2xl" onClick={e => e.stopPropagation()}>
            <button 
              onClick={() => setPreviewImage(null)}
              className="absolute top-3 right-3 p-2 bg-black/60 hover:bg-black text-white rounded-full transition z-10"
            >
              <X className="w-5 h-5" />
            </button>
            <img src={previewImage} alt="Inspiration Preview" className="w-full h-auto max-h-[85vh] object-contain" />
          </div>
        </div>
      )}

    </div>
  );
};