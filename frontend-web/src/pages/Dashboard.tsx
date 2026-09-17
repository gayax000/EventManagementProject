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
  RefreshCw
} from 'lucide-react';
import { eventService } from '../services/api';

export interface EventItem {
  eventId: string;
  title: string;
  targetDate: string;
  guestCount: number;
  budgetLimit: number;
  status: string;
  venueId?: string;
  venueName?: string;
  estimatedTotalCost?: number;
  createdAt: string;
}

export const Dashboard: React.FC = () => {
  const [events, setEvents] = useState<EventItem[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<EventItem | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [specialDiscount, setSpecialDiscount] = useState<number>(20000);
  const [actionSuccess, setActionSuccess] = useState<string | null>(null);

  // Fetch Live Events from Backend
  const loadEvents = async () => {
    try {
      setLoading(true);
      const data = await eventService.getMyEvents();
      setEvents(data);
      if (data.length > 0) {
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

  // Fetch proposal details to synchronize real database pricing
  useEffect(() => {
    if (selectedEvent?.eventId) {
      eventService.getProposal(selectedEvent.eventId)
        .then(p => {
          if (p && p.estimatedTotalCost !== undefined) {
            setSelectedEvent(prev => (prev && prev.eventId === selectedEvent.eventId) ? { ...prev, estimatedTotalCost: p.estimatedTotalCost } : prev);
          }
        })
        .catch(e => console.log("Proposal fetch info", e));
    }
  }, [selectedEvent?.eventId]);

  // Manager Approve Proposal Action
  const handleApprove = async () => {
    if (!selectedEvent) return;
    const computedFinalTotal = selectedEvent.guestCount * 5000 + 300000 - specialDiscount;
    try {
      await eventService.approveProposal(selectedEvent.eventId, specialDiscount, computedFinalTotal);
      setActionSuccess("Proposal approved successfully! Updated in PostgreSQL Database.");
      // Refresh local state with the exact computed final total
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

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      {/* Top Welcome & Refresh */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Event Operations & AI Control Center</h1>
          <p className="text-slate-500 text-sm mt-1">Live synchronized with ASP.NET Core & PostgreSQL Neon Cloud Database.</p>
        </div>
        <button 
          onClick={loadEvents}
          className="flex items-center space-x-1.5 px-3 py-2 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 rounded-lg text-xs font-semibold shadow-sm transition"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin text-sky-600' : ''}`} />
          <span>Sync Live DB</span>
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-5 mb-8">
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Active Requests</p>
            <p className="text-2xl font-bold text-slate-800 mt-1">{activeCount}</p>
          </div>
          <div className="p-3 bg-sky-50 rounded-lg"><Calendar className="w-6 h-6 text-sky-600" /></div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Pending Approvals</p>
            <p className="text-2xl font-bold text-amber-600 mt-1">{pendingCount}</p>
          </div>
          <div className="p-3 bg-amber-50 rounded-lg"><Clock className="w-6 h-6 text-amber-600" /></div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Confirmed / Approved</p>
            <p className="text-2xl font-bold text-emerald-600 mt-1">{confirmedCount}</p>
          </div>
          <div className="p-3 bg-emerald-50 rounded-lg"><CheckCircle className="w-6 h-6 text-emerald-600" /></div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Total Revenue</p>
            <p className="text-2xl font-bold text-slate-800 mt-1">Rs. 4.2M</p>
          </div>
          <div className="p-3 bg-indigo-50 rounded-lg"><DollarSign className="w-6 h-6 text-indigo-600" /></div>
        </div>
      </div>

      {/* Action Success Alert */}
      {actionSuccess && (
        <div className="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl text-emerald-800 text-sm font-medium flex items-center justify-between">
          <span className="flex items-center"><CheckCircle className="w-4 h-4 mr-2 text-emerald-600" />{actionSuccess}</span>
          <button onClick={() => setActionSuccess(null)} className="text-emerald-600 hover:text-emerald-800 font-bold">&times;</button>
        </div>
      )}

      {/* Events Queue Selector */}
      <div className="mb-6 bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
        <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">Incoming Event Queue (Click an event to review)</h3>
        <div className="flex flex-wrap gap-2">
          {events.map((ev) => (
            <button
              key={ev.eventId}
              onClick={() => setSelectedEvent(ev)}
              className={`px-3 py-2 rounded-lg text-xs font-semibold flex items-center space-x-2 transition border ${
                selectedEvent?.eventId === ev.eventId
                  ? 'bg-sky-50 text-sky-700 border-sky-300 ring-2 ring-sky-400/20'
                  : 'bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100'
              }`}
            >
              <span className={`w-2 h-2 rounded-full ${
                ev.status === 'ApprovedByManager' || ev.status === 'Confirmed' ? 'bg-emerald-500' : 'bg-amber-500 animate-pulse'
              }`} />
              <span className="font-bold">{ev.title}</span>
              <span className="text-[10px] px-1.5 py-0.5 rounded bg-white/70 text-slate-500 border border-slate-200">{ev.status}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Main Review Section: Live Proposal */}
      {selectedEvent ? (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-8">
          <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Sparkles className="w-5 h-5 text-sky-400 animate-spin" />
              <h2 className="font-semibold text-base">Human-in-the-Loop AI Proposal Review (Live DB)</h2>
            </div>
            <span className={`text-xs font-semibold px-3 py-1 rounded-full border ${
              selectedEvent.status === 'ApprovedByManager' || selectedEvent.status === 'Confirmed'
                ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30' 
                : 'bg-amber-500/20 text-amber-300 border-amber-500/30'
            }`}>
              Status: {selectedEvent.status}
            </span>
          </div>

          <div className="p-6 grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            {/* Proposal Details */}
            <div className="lg:col-span-2 space-y-6">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-sky-600 bg-sky-50 px-2 py-0.5 rounded">Event Objective</span>
                <h3 className="text-xl font-bold text-slate-900 mt-2">{selectedEvent.title}</h3>
                <p className="text-sm text-slate-500 mt-1">
                  Event ID: <span className="font-mono text-xs text-slate-400">{selectedEvent.eventId}</span>
                </p>
                <p className="text-sm text-slate-600 mt-1">
                  Date: {new Date(selectedEvent.targetDate).toLocaleDateString()} • Guests: {selectedEvent.guestCount} • Budget Limit: Rs. {Number(selectedEvent.budgetLimit).toLocaleString()}
                </p>
              </div>

              {/* Weather Contingency Alert */}
              <div className="p-4 bg-amber-50/80 border border-amber-200 rounded-xl flex items-start space-x-3">
                <CloudRain className="w-6 h-6 text-amber-600 flex-shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-sm font-bold text-amber-900">Weather Agent Assessment: 70% Monsoon Rain Alert</h4>
                  <p className="text-xs text-amber-800 mt-1">Autonomous environmental contingency triggered on outdoor venue.</p>
                  <p className="text-xs font-semibold text-emerald-800 mt-2 flex items-center">
                    <CheckCircle className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                    Auto Safeguard: Heavy-Duty Waterproof Marquee Tent (Rs. 150,000) added.
                  </p>
                </div>
              </div>

              {/* Breakdown */}
              <div>
                <h4 className="text-sm font-bold text-slate-800 mb-3">AI Compiled Package Breakdown</h4>
                <div className="space-y-2">
                  <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                    <span className="text-slate-700">Premium Dinner Buffet B ({selectedEvent.guestCount} Guests x Rs. 5,000)</span>
                    <span className="font-semibold text-slate-900">Rs. {(selectedEvent.guestCount * 5000).toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                    <span className="text-slate-700">Stage, Line-Array Sound & Intelligent LED Lighting Rig</span>
                    <span className="font-semibold text-slate-900">Rs. 150,000</span>
                  </div>
                  <div className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                    <span className="text-slate-700">Waterproof Marquee Tent (Autonomous Weather Safeguard)</span>
                    <span className="font-semibold text-slate-900">Rs. 150,000</span>
                  </div>
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
                    <span className="font-medium">Rs. {(selectedEvent.guestCount * 5000 + 300000).toLocaleString()}</span>
                  </div>

                  <div className="flex justify-between items-center text-sm text-slate-600">
                    <span>Special Discount:</span>
                    <div className="flex items-center space-x-1">
                      <span className="text-xs text-slate-400">Rs.</span>
                      <input 
                        type="number" 
                        value={specialDiscount}
                        onChange={(e) => setSpecialDiscount(Number(e.target.value))}
                        disabled={selectedEvent.status === 'ApprovedByManager'}
                        className="w-24 px-2 py-1 bg-white border border-slate-300 rounded text-right text-sm font-semibold text-slate-800 disabled:bg-slate-100"
                      />
                    </div>
                  </div>

                  <div className="border-t border-slate-200 pt-3 flex justify-between text-base font-bold text-slate-900">
                    <span>Final Total:</span>
                    <span className="text-emerald-600">
                      Rs. {((selectedEvent.status === 'ApprovedByManager' || selectedEvent.status === 'Confirmed') && selectedEvent.estimatedTotalCost
                        ? selectedEvent.estimatedTotalCost
                        : (selectedEvent.guestCount * 5000 + 300000 - specialDiscount)
                      ).toLocaleString()}
                    </span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="space-y-2">
                <button 
                  onClick={handleApprove}
                  disabled={selectedEvent.status === 'ApprovedByManager'}
                  className="w-full py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-medium text-sm rounded-lg shadow transition flex items-center justify-center space-x-2 disabled:opacity-50"
                >
                  <CheckCircle className="w-4 h-4" />
                  <span>{selectedEvent.status === 'ApprovedByManager' ? 'Approved & Ready for Signing' : 'Approve Proposal'}</span>
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

    </div>
  );
};