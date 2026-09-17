import React, { useState, useEffect } from 'react';
import { MapPin, Users, DollarSign } from 'lucide-react';
import { venueService } from '../services/api';

export const VenuesPage: React.FC = () => {
  const [venues, setVenues] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(false);

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

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
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
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {venues.map((venue: any) => (
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
        )}
      </div>
    </div>
  );
};