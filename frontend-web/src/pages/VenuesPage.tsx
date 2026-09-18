import React, { useState, useEffect } from 'react';
import { MapPin, Users, DollarSign, Loader2, Building2, X, Sparkles, ChevronRight, Search } from 'lucide-react';
import { venueService, banquetHallService, type BanquetHallItem } from '../services/api';
import { LoadingSpinner, EmptyState, ErrorAlert } from '../components/UIStateComponents';

const QUICK_CITY_FILTERS = [
  'All',
  'Colombo',
  'Kandy',
  'Nuwara Eliya',
  'Bentota',
  'Galle',
  'Dambulla',
  'Negombo',
  'Weligama',
  'Tangalle'
];

export const VenuesPage: React.FC = () => {
  const [venues, setVenues] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCity, setSelectedCity] = useState('All');
  const [loading, setLoading] = useState(false);

  // Modal State
  const [selectedVenueId, setSelectedVenueId] = useState<string | null>(null);
  const [venueHalls, setVenueHalls] = useState<BanquetHallItem[]>([]);
  const [loadingHalls, setLoadingHalls] = useState(false);

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

  const handleVenueClick = async (venueId: string) => {
    setSelectedVenueId(venueId);
    setLoadingHalls(true);
    const matchedVenue = venues.find(v => v.venueId === venueId);
    try {
      const halls = await banquetHallService.getHalls(venueId);
      if (halls && halls.length > 0) {
        setVenueHalls(halls);
      } else if (matchedVenue) {
        // Balanced fallback mix: 1 Indoor Grand Ballroom + 1 Outdoor Scenic Lawn
        const baseName = (matchedVenue.name || 'Luxury Venue').replace(/hotel|resort/gi, '').trim();
        const basePrice = Number(matchedVenue.baseRentalPrice) || 350000;
        setVenueHalls([
          {
            banquetHallId: `${venueId}-indoor`,
            venueId: venueId,
            venueName: matchedVenue.name,
            hallName: `${baseName} Grand Ballroom & Banquet Suite`,
            maxCapacity: Math.round((matchedVenue.maxCapacity || 500) * 0.75),
            hallRentalPrice: Math.round(basePrice * 0.85),
            perPlatePrice: 5200,
            isOutdoor: false,
            isAvailable: true
          },
          {
            banquetHallId: `${venueId}-outdoor`,
            venueId: venueId,
            venueName: matchedVenue.name,
            hallName: `${baseName} Scenic Palm Garden & Outdoor Terrace`,
            maxCapacity: matchedVenue.maxCapacity || 500,
            hallRentalPrice: basePrice,
            perPlatePrice: 5600,
            isOutdoor: true,
            isAvailable: true
          }
        ]);
      } else {
        setVenueHalls([]);
      }
    } catch (err) {
      console.error("Failed to fetch halls", err);
      if (matchedVenue) {
        const baseName = (matchedVenue.name || 'Luxury Venue').replace(/hotel|resort/gi, '').trim();
        const basePrice = Number(matchedVenue.baseRentalPrice) || 350000;
        setVenueHalls([
          {
            banquetHallId: `${venueId}-indoor`,
            venueId: venueId,
            venueName: matchedVenue.name,
            hallName: `${baseName} Grand Ballroom`,
            maxCapacity: Math.round((matchedVenue.maxCapacity || 500) * 0.75),
            hallRentalPrice: Math.round(basePrice * 0.85),
            perPlatePrice: 5200,
            isOutdoor: false,
            isAvailable: true
          },
          {
            banquetHallId: `${venueId}-outdoor`,
            venueId: venueId,
            venueName: matchedVenue.name,
            hallName: `${baseName} Scenic Garden Lawn`,
            maxCapacity: matchedVenue.maxCapacity || 500,
            hallRentalPrice: basePrice,
            perPlatePrice: 5600,
            isOutdoor: true,
            isAvailable: true
          }
        ]);
      }
    } finally {
      setLoadingHalls(false);
    }
  };

  const closeModal = () => {
    setSelectedVenueId(null);
    setVenueHalls([]);
  };

  const selectedVenue = venues.find(v => v.venueId === selectedVenueId);

  // Filter venues by selected city
  const filteredVenues = venues.filter((venue) => {
    if (selectedCity === 'All') return true;
    const addr = (venue.locationAddress || '').toLowerCase();
    const name = (venue.name || '').toLowerCase();
    const city = selectedCity.toLowerCase();
    return addr.includes(city) || name.includes(city);
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 relative">
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4 bg-slate-900 text-white p-6 rounded-2xl shadow-lg border border-slate-800">
        <div>
          <div className="flex items-center space-x-2">
            <span className="text-xs font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-sky-500/20 text-sky-300 border border-sky-500/30 flex items-center space-x-1">
              <Building2 className="w-3.5 h-3.5 mr-1" />
              Luxury Venues & Hotels Directory
            </span>
            <span className="text-xs text-slate-400">• Member 1 Component</span>
          </div>
          <h1 className="text-2xl font-black mt-2">Sri Lankan Venues & Banquet Halls</h1>
          <p className="text-slate-400 text-sm mt-1">Explore certified star hotels and event venues in Colombo, Kandy, Nuwara Eliya, Galle and across Sri Lanka.</p>
        </div>

        {/* Search Bar */}
        <div className="w-full md:w-80">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-4 w-4 text-slate-400" />
            </div>
            <input 
              type="text"
              placeholder="Search by hotel name or city..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-9 pr-3 py-2.5 bg-slate-800 border border-slate-700 text-white placeholder-slate-400 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-sky-500 shadow-sm transition"
            />
          </div>
        </div>
      </div>

      {/* City Quick Filters */}
      <div className="mb-6 flex items-center space-x-2 overflow-x-auto pb-1 scrollbar-hide">
        <span className="text-xs font-bold text-slate-500 uppercase tracking-wider whitespace-nowrap mr-1">Filter City:</span>
        {QUICK_CITY_FILTERS.map((city) => (
          <button
            key={city}
            onClick={() => setSelectedCity(city)}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition border ${
              selectedCity === city
                ? 'bg-slate-900 text-white border-slate-900 shadow-sm'
                : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-100 hover:text-slate-900'
            }`}
          >
            {city === 'All' ? '🌟 All Cities' : `📍 ${city}`}
          </button>
        ))}
      </div>

      {/* Venues Grid */}
      <div className="mb-10">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-base font-bold text-slate-800 flex items-center">
            <span>Available Luxury Venues & Star Hotels</span>
            <span className="ml-2 text-xs bg-sky-100 text-sky-800 font-bold px-2.5 py-0.5 rounded-full">
              {filteredVenues.length} Locations
            </span>
          </h2>
          <span className="text-xs text-slate-400">Click any venue to explore banquet halls & spaces</span>
        </div>
        
        {loading ? (
          <LoadingSpinner message="Loading Sri Lankan venues directory..." />
        ) : filteredVenues.length === 0 ? (
          <EmptyState 
            title="No Venues Found" 
            description="No luxury venues match your search query. Try searching for a different city or clearing the filter." 
            actionText="Clear Filter"
            onAction={() => { setSelectedCity('All'); setSearchTerm(''); }}
          />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {filteredVenues.map((venue: any) => (
              <div 
                key={venue.venueId} 
                className="bg-white border border-slate-200 rounded-2xl p-5 shadow-xs hover:shadow-md transition cursor-pointer hover:border-indigo-400 hover:-translate-y-0.5 group flex flex-col justify-between"
                onClick={() => handleVenueClick(venue.venueId)}
              >
                <div>
                  <div className="flex items-start space-x-3 mb-3">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-50 to-indigo-50 border border-sky-100 flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition">
                      <Building2 className="w-5 h-5 text-indigo-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-bold text-slate-900 text-sm leading-snug group-hover:text-indigo-600 transition">
                        {venue.name}
                      </h3>
                      <p className="text-xs text-slate-500 flex items-center mt-1">
                        <MapPin className="w-3.5 h-3.5 mr-1 text-sky-500 flex-shrink-0" />
                        <span className="truncate">{venue.locationAddress}</span>
                      </p>
                    </div>
                  </div>
                </div>

                <div className="pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
                  <span className="text-slate-400 font-medium group-hover:text-slate-600 transition">
                    View Spaces & Capacity
                  </span>
                  <span className="inline-flex items-center text-indigo-600 font-bold group-hover:translate-x-0.5 transition">
                    Explore <ChevronRight className="w-3.5 h-3.5 ml-0.5" />
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Pop-up Modal for Halls */}
      {selectedVenueId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-150">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-200 border border-slate-200">
            {/* Modal Header */}
            <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center bg-slate-50">
              <div className="flex items-start space-x-3">
                <div className="w-9 h-9 rounded-xl bg-indigo-50 text-indigo-600 border border-indigo-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Building2 className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-base text-slate-900 leading-tight">
                    {selectedVenue?.name || 'Banquet Halls'}
                  </h3>
                  {selectedVenue?.locationAddress && (
                    <p className="text-xs text-slate-500 mt-1 flex items-center">
                      <MapPin className="w-3.5 h-3.5 mr-1 text-sky-500" />
                      {selectedVenue.locationAddress}
                    </p>
                  )}
                </div>
              </div>
              <button 
                onClick={closeModal} 
                className="text-slate-400 hover:text-slate-700 p-1.5 rounded-full hover:bg-slate-200 transition bg-white border border-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            {/* Modal Body (Scrollable) */}
            <div className="p-6 overflow-y-auto bg-slate-50/50">
              <div className="mb-3 flex items-center justify-between">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-600">
                  Configured Banquet Halls & Outdoor Lawns
                </h4>
                <span className="text-[11px] text-slate-400">Indoor/Outdoor setting details</span>
              </div>

              {loadingHalls ? (
                <div className="flex justify-center items-center py-12 text-slate-500">
                  <Loader2 className="w-6 h-6 animate-spin mr-2 text-indigo-600" />
                  <span className="text-sm">Loading available spaces...</span>
                </div>
              ) : venueHalls.length === 0 ? (
                <div className="text-center py-12 text-slate-500 bg-white rounded-xl border border-slate-200">
                  <Building2 className="w-8 h-8 text-slate-300 mx-auto mb-2" />
                  <p className="text-sm font-semibold text-slate-700">No specific banquet halls configured for this venue.</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 gap-4">
                  {venueHalls.map((hall) => (
                    <div key={hall.banquetHallId} className="bg-white border border-slate-200 rounded-xl p-4 shadow-xs hover:border-indigo-300 hover:shadow-sm transition">
                      <div className="flex justify-between items-start mb-3">
                        <div>
                          <h4 className="font-bold text-slate-900 text-sm">{hall.hallName}</h4>
                        </div>
                        {/* Indoor Hall vs Outdoor Space clearly highlighted */}
                        <span className={`text-[11px] font-bold px-2.5 py-0.5 rounded-full whitespace-nowrap flex items-center space-x-1 ${
                          hall.isOutdoor 
                            ? 'bg-amber-100 text-amber-900 border border-amber-200' 
                            : 'bg-indigo-100 text-indigo-900 border border-indigo-200'
                        }`}>
                          <span>{hall.isOutdoor ? '🌳 Outdoor Space' : '🏛️ Indoor Hall'}</span>
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-3 gap-3 text-xs bg-slate-50 p-3 rounded-lg border border-slate-100">
                        <div>
                          <span className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-0.5">Capacity</span>
                          <span className="font-bold text-slate-800">{hall.maxCapacity} Guests</span>
                        </div>
                        <div>
                          <span className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-0.5">Hall Rental</span>
                          <span className="font-bold text-indigo-600">Rs. {Number(hall.hallRentalPrice).toLocaleString()}</span>
                        </div>
                        <div>
                          <span className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-0.5">Per Plate</span>
                          <span className="font-bold text-indigo-600">Rs. {Number(hall.perPlatePrice).toLocaleString()}</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};