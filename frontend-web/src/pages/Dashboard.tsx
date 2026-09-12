import React, { useState } from 'react';
import { 
  Calendar, 
  Users, 
  DollarSign, 
  CloudRain, 
  CheckCircle, 
  XCircle, 
  Clock, 
  Sparkles,
  ShieldAlert,
  ArrowRight
} from 'lucide-react';

export const Dashboard: React.FC = () => {
  const [reviewStatus, setReviewStatus] = useState<'Pending' | 'Approved' | 'Rejected'>('Pending');
  const [specialDiscount, setSpecialDiscount] = useState<number>(20000);

  // Sample proposal matching the AI Workflow state
  const proposal = {
    eventTitle: "TechCraft 10th Anniversary Dinner",
    targetDate: "Nov 15, 2026",
    guestCount: 120,
    budgetLimit: 1000000,
    venue: "Grand Palm Garden (Outdoor Lawn)",
    weatherForecast: "70% Chance of Rain",
    weatherAlert: "High Rain Risk detected on outdoor target date. Autonomous safeguard added.",
    safeguardSolution: "Waterproof Marquee Tent (Rs. 150,000)",
    breakdown: [
      { item: "Premium Dinner Buffet B (120 x Rs. 5,000)", cost: 600000 },
      { item: "Stage, Lighting & Concert Audio System", cost: 150000 },
      { item: "Waterproof Marquee Tent (Weather Safeguard)", cost: 150000 },
    ],
    subtotal: 900000,
  };

  const finalCost = proposal.subtotal - specialDiscount;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      {/* Top Welcome & KPI Cards */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-slate-900">Event Operations & AI Control Center</h1>
        <p className="text-slate-500 text-sm mt-1">Review autonomous multi-agent proposals, risk alerts, and grant human approvals.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-5 mb-8">
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Active Requests</p>
            <p className="text-2xl font-bold text-slate-800 mt-1">14</p>
          </div>
          <div className="p-3 bg-sky-50 rounded-lg"><Calendar className="w-6 h-6 text-sky-600" /></div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Pending Approvals</p>
            <p className="text-2xl font-bold text-amber-600 mt-1">3</p>
          </div>
          <div className="p-3 bg-amber-50 rounded-lg"><Clock className="w-6 h-6 text-amber-600" /></div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Total Confirmed</p>
            <p className="text-2xl font-bold text-emerald-600 mt-1">28</p>
          </div>
          <div className="p-3 bg-emerald-50 rounded-lg"><CheckCircle className="w-6 h-6 text-emerald-600" /></div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Revenue To Date</p>
            <p className="text-2xl font-bold text-slate-800 mt-1">Rs. 4.2M</p>
          </div>
          <div className="p-3 bg-indigo-50 rounded-lg"><DollarSign className="w-6 h-6 text-indigo-600" /></div>
        </div>
      </div>

      {/* Main Review Section: Human-in-the-Loop AI Approval */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-8">
        <div className="px-6 py-4 bg-slate-900 text-white flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Sparkles className="w-5 h-5 text-sky-400 animate-spin" />
            <h2 className="font-semibold text-base">Human-in-the-Loop Proposal Review (Spec Section 9.1)</h2>
          </div>
          <span className="text-xs font-medium px-3 py-1 bg-amber-500/20 text-amber-300 border border-amber-500/30 rounded-full">
            Status: {reviewStatus === 'Pending' ? 'Under Manager Review' : reviewStatus}
          </span>
        </div>

        <div className="p-6 grid grid-cols-1 lg:grid-cols-3 gap-8">
          
          {/* Column 1 & 2: Proposal Details & AI Breakdown */}
          <div className="lg:col-span-2 space-y-6">
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-sky-600 bg-sky-50 px-2 py-0.5 rounded">Event Objective</span>
              <h3 className="text-xl font-bold text-slate-900 mt-2">{proposal.eventTitle}</h3>
              <p className="text-sm text-slate-500 mt-1">Target Date: {proposal.targetDate} • Guests: {proposal.guestCount} • Budget Limit: Rs. {proposal.budgetLimit.toLocaleString()}</p>
            </div>

            {/* Weather Risk AI Safeguard Alert Card */}
            <div className="p-4 bg-amber-50/80 border border-amber-200 rounded-xl flex items-start space-x-3">
              <CloudRain className="w-6 h-6 text-amber-600 flex-shrink-0 mt-0.5" />
              <div>
                <h4 className="text-sm font-bold text-amber-900">Weather Agent Assessment: {proposal.weatherForecast}</h4>
                <p className="text-xs text-amber-800 mt-1">{proposal.weatherAlert}</p>
                <p className="text-xs font-semibold text-emerald-800 mt-2 flex items-center">
                  <CheckCircle className="w-3.5 h-3.5 mr-1 text-emerald-600" />
                  Auto Safeguard: {proposal.safeguardSolution} included in proposal.
                </p>
              </div>
            </div>

            {/* Cost Breakdown */}
            <div>
              <h4 className="text-sm font-bold text-slate-800 mb-3">AI Optimized Resource Breakdown</h4>
              <div className="space-y-2">
                {proposal.breakdown.map((item, idx) => (
                  <div key={idx} className="flex justify-between items-center text-sm py-2 px-3 bg-slate-50 rounded-lg border border-slate-100">
                    <span className="text-slate-700">{item.item}</span>
                    <span className="font-semibold text-slate-900">Rs. {item.cost.toLocaleString()}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Column 3: Manager Decision & Discount Control */}
          <div className="bg-slate-50 p-6 rounded-xl border border-slate-200 flex flex-col justify-between">
            <div>
              <h4 className="text-base font-bold text-slate-900 mb-4">Manager Final Action</h4>
              
              <div className="space-y-3 mb-6">
                <div className="flex justify-between text-sm text-slate-600">
                  <span>Subtotal:</span>
                  <span className="font-medium">Rs. {proposal.subtotal.toLocaleString()}</span>
                </div>

                <div className="flex justify-between items-center text-sm text-slate-600">
                  <span>Special Discount:</span>
                  <div className="flex items-center space-x-1">
                    <span className="text-xs text-slate-400">Rs.</span>
                    <input 
                      type="number" 
                      value={specialDiscount}
                      onChange={(e) => setSpecialDiscount(Number(e.target.value))}
                      className="w-24 px-2 py-1 bg-white border border-slate-300 rounded text-right text-sm font-semibold text-slate-800"
                    />
                  </div>
                </div>

                <div className="border-t border-slate-200 pt-3 flex justify-between text-base font-bold text-slate-900">
                  <span>Final Total:</span>
                  <span className="text-emerald-600">Rs. {finalCost.toLocaleString()}</span>
                </div>

                <p className="text-xs text-emerald-700 font-medium bg-emerald-50 p-2 rounded text-center">
                  Under client budget by Rs. {(proposal.budgetLimit - finalCost).toLocaleString()}
                </p>
              </div>
            </div>

            {/* Approval Action Buttons */}
            <div className="space-y-2">
              <button 
                onClick={() => setReviewStatus('Approved')}
                disabled={reviewStatus === 'Approved'}
                className="w-full py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-medium text-sm rounded-lg shadow transition flex items-center justify-center space-x-2 disabled:opacity-50"
              >
                <CheckCircle className="w-4 h-4" />
                <span>{reviewStatus === 'Approved' ? 'Approved & Ready for Signing' : 'Approve Proposal'}</span>
              </button>

              <button 
                onClick={() => setReviewStatus('Rejected')}
                disabled={reviewStatus === 'Rejected'}
                className="w-full py-2.5 bg-white hover:bg-rose-50 text-rose-600 border border-rose-200 font-medium text-sm rounded-lg transition flex items-center justify-center space-x-2"
              >
                <XCircle className="w-4 h-4" />
                <span>Request Re-Optimization</span>
              </button>
            </div>

          </div>

        </div>
      </div>

    </div>
  );
};