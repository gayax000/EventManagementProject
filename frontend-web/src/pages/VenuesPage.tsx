import React, { useState, useEffect } from 'react';
import { MapPin, Users, DollarSign, Loader2, Building2, X } from 'lucide-react';
import { venueService, banquetHallService, type BanquetHallItem } from '../services/api';

export const VenuesPage: React.FC = () => {
  const [venues, setVenues] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
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
    try {
      const halls = await banquetHallService.getHalls(venueId);
      setVenueHalls(halls);
    } catch (err) {
      console.error("Failed to fetch halls", err);
    } finally {
      setLoadingHalls(false);
    }
  };

  const closeModal = () => {
    setSelectedVenueId(null);
    setVenueHalls([]);
  };

  const selectedVenue = venues.find(v => v.venueId === selectedVenueId);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 relative">
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Sri Lankan Venues Directory</h1>
          <p className="text-slate-500 text-sm mt-1">Search real seeded hotels and venues in Colombo, Kandy, Nuwara Eliya and more.</p>
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
        
        {loading ? (
           <div className="text-center py-10 text-slate-500">Loading venues...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {venues.map((venue: any) => (
              <div 
                key={venue.venueId} 
                className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition cursor-pointer hover:border-sky-300"
                onClick={() => handleVenueClick(venue.venueId)}
              >
                <div className="flex justify-between items-start mb-2">
                  <h3 className="font-bold text-slate-900 text-base line-clamp-1">{venue.name}</h3>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${venue.isOutdoor ? 'bg-amber-50 text-amber-700 border border-amber-200' : 'bg-indigo-50 text-indigo-700 border border-indigo-200'}`}>
                    {venue.isOutdoor ? 'Outdoor' : 'Indoor'}
                  </span>
                </div>
                <p className="text-xs text-slate-500 flex items-center"><MapPin className="w-3.5 h-3.5 mr-1 text-slate-400" />{venue.locationAddress}</p>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Pop-up Modal for Halls */}
      {selectedVenueId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in fade-in zoom-in duration-200">
            {/* Modal Header */}
            <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center bg-slate-50">
              <div>
                <h3 className="font-bold text-lg text-slate-900 flex items-center">
                  <Building2 className="w-5 h-5 mr-2 text-indigo-600" />
                  {selectedVenue?.name || 'Banquet Halls'}
                </h3>
                {selectedVenue?.locationAddress ? (
                  <p className="text-sm text-slate-600 mt-1.5 ml-7 flex items-center">
                    <MapPin className="w-4 h-4 mr-1 text-sky-500" />
                    {selectedVenue.locationAddress}
                  </p>
                ) : (
                  <p className="text-xs text-slate-500 mt-1 ml-7">Select a hall or space available at this venue.</p>
                )}
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
              {loadingHalls ? (
                <div className="flex justify-center items-center py-12 text-slate-500">
                  <Loader2 className="w-6 h-6 animate-spin mr-2" />
                  <span className="text-sm">Loading available spaces...</span>
                </div>
              ) : venueHalls.length === 0 ? (
                <div className="text-center py-12 text-slate-500 bg-white rounded-xl border border-slate-200">
                  <p className="text-sm">No specific halls configured for this venue.</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 gap-4">
                  {venueHalls.map((hall) => (
                    <div key={hall.banquetHallId} className="bg-white border border-slate-200 rounded-xl p-4 shadow-sm hover:border-indigo-300 hover:shadow-md transition group">
                      <div className="flex justify-between items-start mb-4">
                        <div>
                          <h4 className="font-bold text-slate-900 text-base">{hall.hallName}</h4>
                        </div>
                        <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full whitespace-nowrap ${hall.isOutdoor ? 'bg-amber-100 text-amber-800' : 'bg-indigo-100 text-indigo-800'}`}>
                          {hall.isOutdoor ? 'Outdoor Space' : 'Indoor Hall'}
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm text-slate-600 bg-slate-50 p-3 rounded-lg border border-slate-100">
                        <div>
                          <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider mb-0.5">Capacity</span>
                          <span className="font-medium text-slate-800">{hall.maxCapacity} Guests</span>
                        </div>
                        <div>
                          <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider mb-0.5">Hall Rental</span>
                          <span className="font-medium text-indigo-600">Rs. {Number(hall.hallRentalPrice).toLocaleString()}</span>
                        </div>
                        <div>
                          <span className="block text-xs font-semibold text-slate-400 uppercase tracking-wider mb-0.5">Per Plate</span>
                          <span className="font-medium text-indigo-600">Rs. {Number(hall.perPlatePrice).toLocaleString()}</span>
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