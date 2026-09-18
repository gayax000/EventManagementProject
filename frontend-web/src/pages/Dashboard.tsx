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
  ArrowRight, 
  TrendingUp, 
  Bot, 
  Activity, 
  FileText, 
  Check, 
  RotateCcw, 
  Sliders, 
  ShieldCheck, 
  AlertTriangle, 
  ChevronRight, 
  Info, 
  Layers,
  MapPin,
  Flame,
  Download
} from 'lucide-react';

export const Dashboard: React.FC = () => {
  const [reviewStatus, setReviewStatus] = useState<'Pending' | 'Approved' | 'Rejected'>('Pending');
  const [specialDiscount, setSpecialDiscount] = useState<number>(20000);
  const [activeTab, setActiveTab] = useState<'overview' | 'trail' | 'breakdown'>('overview');
  const [managerNote, setManagerNote] = useState<string>('Approved with special loyal client discount of Rs. 20,000.');
  const [showReoptimizeModal, setShowReoptimizeModal] = useState<boolean>(false);
  const [reoptimizePrompt, setReoptimizePrompt] = useState<string>('Switch to indoor ballroom or reduce audio package by 15%');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Sample proposal matching the AI Workflow state (Spec Section 9 & 4.2)
  const proposal = {
    id: "PROP-2026-89",
    eventTitle: "TechCraft 10th Anniversary Dinner",
    clientName: "Dimalka Shalintha",
    clientType: "Corporate VIP",
    targetDate: "Nov 15, 2026",
    guestCount: 120,
    budgetLimit: 1000000,
    venue: "Grand Palm Garden (Outdoor Lawn, Nuwara Eliya)",
    weatherForecast: "70% Chance of Heavy Rain",
    weatherAlert: "High Rain Risk detected on outdoor lawn for target date. Autonomous safeguard triggered.",
    safeguardSolution: "Waterproof Marquee Tent (Rs. 150,000)",
    breakdown: [
      { item: "Premium Dinner Buffet B (120 x Rs. 5,000)", category: "Catering", cost: 600000, vendor: "Cinnamon Grand Catering" },
      { item: "Stage, Dynamic Lighting & Audio Rig", category: "AV & Production", cost: 150000, vendor: "SoundLanka Pro" },
      { item: "Waterproof Marquee Tent (AI Safeguard)", category: "Weather Contingency", cost: 150000, vendor: "TentMaster Logistics" },
    ],
    subtotal: 900000,
  };

  const finalCost = proposal.subtotal - specialDiscount;
  const budgetVariance = proposal.budgetLimit - finalCost;
  const budgetUsedPercentage = Math.round((finalCost / proposal.budgetLimit) * 100);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const handleApprove = () => {
    setReviewStatus('Approved');
    showToast('✅ Proposal Approved & Contract Dispatched to Client Mobile App!');
  };

  const handleReoptimizeSubmit = () => {
    setShowReoptimizeModal(false);
    setReviewStatus('Pending');
    showToast('🤖 AI LangGraph Agents re-optimizing proposal with your instructions...');
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100">
      
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-gradient-to-r from-sky-600 to-indigo-600 text-white px-5 py-3.5 rounded-xl shadow-2xl border border-sky-400/30 flex items-center space-x-3 animate-bounce">
          <Sparkles className="w-5 h-5 text-sky-200" />
          <span className="font-semibold text-sm">{toastMessage}</span>
        </div>
      )}

      {/* Main Container */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
        
        {/* ========================================== */}
        {/* TOP HERO & SYSTEM TELEMETRY BANNER        */}
        {/* ========================================== */}
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 border border-slate-700/60 p-6 sm:p-8 shadow-2xl">
          {/* Subtle decorative glow */}
          <div className="absolute top-0 right-0 -mt-8 -mr-8 w-72 h-72 bg-sky-500/10 rounded-full blur-3xl pointer-events-none" />
          <div className="absolute bottom-0 left-1/3 -mb-12 w-64 h-64 bg-indigo-500/10 rounded-full blur-3xl pointer-events-none" />

          <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div>
              <div className="flex items-center space-x-2.5 mb-2">
                <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-sky-500/15 text-sky-400 border border-sky-500/30">
                  <Bot className="w-3.5 h-3.5 mr-1 text-sky-400 animate-pulse" />
                  LangGraph Multi-Agent Engine v2.4
                </span>
                <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping mr-1.5" />
                  Live Orchestration Active
                </span>
              </div>
              <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight text-white">
                Event Operations & <span className="bg-gradient-to-r from-sky-400 to-indigo-400 bg-clip-text text-transparent">AI Command Center</span>
              </h1>
              <p className="text-slate-400 text-sm sm:text-base mt-1.5 max-w-2xl">
                Real-time autonomous multi-agent proposal synthesis, weather safeguard orchestration, and Human-in-the-Loop manager decisions.
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <button 
                onClick={() => showToast("Exporting comprehensive AI event audit report...")}
                className="px-4 py-2.5 bg-slate-800 hover:bg-slate-750 text-slate-200 text-xs font-semibold rounded-xl border border-slate-700 shadow-sm transition flex items-center space-x-2 hover:border-slate-600"
              >
                <Download className="w-4 h-4 text-sky-400" />
                <span>Export Audit CSV</span>
              </button>
              <button 
                onClick={() => showToast("Triggering full Multi-Agent resync...")}
                className="px-4 py-2.5 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-400 hover:to-indigo-500 text-white text-xs font-bold rounded-xl shadow-lg shadow-sky-500/20 transition flex items-center space-x-2"
              >
                <Sparkles className="w-4 h-4" />
                <span>Run AI Agent Sweep</span>
              </button>
            </div>
          </div>

          {/* Autonomous Agents Status Strip */}
          <div className="mt-6 pt-5 border-t border-slate-700/60 grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
            <div className="flex items-center space-x-2.5 bg-slate-800/60 px-3.5 py-2 rounded-xl border border-slate-700/40">
              <div className="p-1.5 bg-amber-500/10 rounded-lg text-amber-400">
                <CloudRain className="w-4 h-4" />
              </div>
              <div>
                <p className="text-slate-400 font-medium">Weather Agent</p>
                <p className="text-slate-200 font-semibold truncate">Rain Alert: 70% risk in Nuwara Eliya</p>
              </div>
            </div>

            <div className="flex items-center space-x-2.5 bg-slate-800/60 px-3.5 py-2 rounded-xl border border-slate-700/40">
              <div className="p-1.5 bg-sky-500/10 rounded-lg text-sky-400">
                <ShieldCheck className="w-4 h-4" />
              </div>
              <div>
                <p className="text-slate-400 font-medium">Venue & Safety Agent</p>
                <p className="text-slate-200 font-semibold truncate">Marquee Tent safeguard locked</p>
              </div>
            </div>

            <div className="flex items-center space-x-2.5 bg-slate-800/60 px-3.5 py-2 rounded-xl border border-slate-700/40">
              <div className="p-1.5 bg-emerald-500/10 rounded-lg text-emerald-400">
                <DollarSign className="w-4 h-4" />
              </div>
              <div>
                <p className="text-slate-400 font-medium">Cost Optimization Agent</p>
                <p className="text-slate-200 font-semibold truncate">Under budget ceiling by 12%</p>
              </div>
            </div>
          </div>
        </div>

        {/* ========================================== */}
        {/* KPI ANALYTICS GRID CARDS                   */}
        {/* ========================================== */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {/* KPI 1 */}
          <div className="bg-slate-800/90 rounded-2xl border border-slate-700/70 p-5 shadow-xl hover:border-sky-500/40 transition duration-300 relative group overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-sky-500/10 rounded-full blur-xl group-hover:bg-sky-500/20 transition" />
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Active Requests</p>
                <div className="flex items-baseline space-x-2 mt-1.5">
                  <span className="text-3xl font-extrabold text-white">14</span>
                  <span className="text-xs font-semibold text-emerald-400 flex items-center">
                    <TrendingUp className="w-3 h-3 mr-0.5" /> +18%
                  </span>
                </div>
              </div>
              <div className="p-3.5 bg-sky-500/15 text-sky-400 rounded-xl border border-sky-500/30">
                <Calendar className="w-6 h-6" />
              </div>
            </div>
            <p className="text-xs text-slate-400 mt-3 flex items-center">
              <Activity className="w-3.5 h-3.5 mr-1 text-sky-400" />
              8 synthesized by AI in last 24h
            </p>
          </div>

          {/* KPI 2 */}
          <div className="bg-slate-800/90 rounded-2xl border border-slate-700/70 p-5 shadow-xl hover:border-amber-500/40 transition duration-300 relative group overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-amber-500/10 rounded-full blur-xl group-hover:bg-amber-500/20 transition" />
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Pending Review</p>
                <div className="flex items-baseline space-x-2 mt-1.5">
                  <span className="text-3xl font-extrabold text-amber-400">3</span>
                  <span className="text-xs font-semibold text-amber-300 bg-amber-500/20 px-1.5 py-0.5 rounded border border-amber-500/30">
                    High Priority
                  </span>
                </div>
              </div>
              <div className="p-3.5 bg-amber-500/15 text-amber-400 rounded-xl border border-amber-500/30">
                <Clock className="w-6 h-6" />
              </div>
            </div>
            <p className="text-xs text-slate-400 mt-3 flex items-center">
              <ShieldAlert className="w-3.5 h-3.5 mr-1 text-amber-400" />
              1 requires weather contingency sign-off
            </p>
          </div>

          {/* KPI 3 */}
          <div className="bg-slate-800/90 rounded-2xl border border-slate-700/70 p-5 shadow-xl hover:border-emerald-500/40 transition duration-300 relative group overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-emerald-500/10 rounded-full blur-xl group-hover:bg-emerald-500/20 transition" />
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Total Confirmed</p>
                <div className="flex items-baseline space-x-2 mt-1.5">
                  <span className="text-3xl font-extrabold text-emerald-400">28</span>
                  <span className="text-xs font-semibold text-emerald-400 flex items-center">
                    <CheckCircle className="w-3 h-3 mr-0.5" /> 96%
                  </span>
                </div>
              </div>
              <div className="p-3.5 bg-emerald-500/15 text-emerald-400 rounded-xl border border-emerald-500/30">
                <CheckCircle className="w-6 h-6" />
              </div>
            </div>
            <p className="text-xs text-slate-400 mt-3 flex items-center">
              <Check className="w-3.5 h-3.5 mr-1 text-emerald-400" />
              QR Entry passes generated & issued
            </p>
          </div>

          {/* KPI 4 */}
          <div className="bg-slate-800/90 rounded-2xl border border-slate-700/70 p-5 shadow-xl hover:border-indigo-500/40 transition duration-300 relative group overflow-hidden">
            <div className="absolute top-0 right-0 w-24 h-24 bg-indigo-500/10 rounded-full blur-xl group-hover:bg-indigo-500/20 transition" />
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Revenue Managed</p>
                <div className="flex items-baseline space-x-2 mt-1.5">
                  <span className="text-3xl font-extrabold text-indigo-300">Rs. 4.2M</span>
                </div>
              </div>
              <div className="p-3.5 bg-indigo-500/15 text-indigo-400 rounded-xl border border-indigo-500/30">
                <DollarSign className="w-6 h-6" />
              </div>
            </div>
            <p className="text-xs text-slate-400 mt-3 flex items-center">
              <TrendingUp className="w-3.5 h-3.5 mr-1 text-indigo-400" />
              +Rs. 380,000 above seasonal baseline
            </p>
          </div>
        </div>

        {/* ========================================================= */}
        {/* MAIN HUMAN-IN-THE-LOOP AI PROPOSAL REVIEW WORKFLOW        */}
        {/* ========================================================= */}
        <div className="bg-slate-800/90 rounded-3xl border border-slate-700/70 shadow-2xl overflow-hidden">
          
          {/* Header Bar */}
          <div className="px-6 py-5 bg-gradient-to-r from-slate-900 via-slate-850 to-slate-900 border-b border-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-gradient-to-br from-sky-400 to-indigo-600 rounded-xl shadow-lg">
                <Sparkles className="w-5 h-5 text-white" />
              </div>
              <div>
                <div className="flex items-center space-x-2">
                  <h2 className="font-bold text-base sm:text-lg text-white">
                    Human-in-the-Loop Proposal Review
                  </h2>
                  <span className="text-xs px-2 py-0.5 rounded bg-sky-500/20 text-sky-300 border border-sky-500/30 font-semibold">
                    Spec 9.1 Core
                  </span>
                </div>
                <p className="text-xs text-slate-400 mt-0.5">
                  Proposal Reference: #{proposal.id} • AI Workflow State ID: #WF-9942
                </p>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <span className={`text-xs font-bold px-3.5 py-1.5 rounded-full border flex items-center space-x-1.5 ${
                reviewStatus === 'Approved' 
                  ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/40' 
                  : (reviewStatus === 'Rejected' ? 'bg-rose-500/20 text-rose-300 border-rose-500/40' : 'bg-amber-500/20 text-amber-300 border-amber-500/40')
              }`}>
                <span className={`w-2 h-2 rounded-full ${
                  reviewStatus === 'Approved' ? 'bg-emerald-400' : (reviewStatus === 'Rejected' ? 'bg-rose-400' : 'bg-amber-400 animate-pulse')
                }`} />
                <span>Status: {reviewStatus === 'Pending' ? 'Under Manager Review' : reviewStatus}</span>
              </span>
            </div>
          </div>

          {/* Tab Navigation */}
          <div className="px-6 border-b border-slate-700 bg-slate-850/50 flex space-x-6 text-sm font-medium">
            <button
              onClick={() => setActiveTab('overview')}
              className={`py-3 border-b-2 transition flex items-center space-x-2 ${
                activeTab === 'overview'
                  ? 'border-sky-400 text-sky-400 font-semibold'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <FileText className="w-4 h-4" />
              <span>Event Proposal & Safeguards</span>
            </button>
            <button
              onClick={() => setActiveTab('trail')}
              className={`py-3 border-b-2 transition flex items-center space-x-2 ${
                activeTab === 'trail'
                  ? 'border-sky-400 text-sky-400 font-semibold'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Layers className="w-4 h-4" />
              <span>Multi-Agent Reasoning Trail</span>
            </button>
            <button
              onClick={() => setActiveTab('breakdown')}
              className={`py-3 border-b-2 transition flex items-center space-x-2 ${
                activeTab === 'breakdown'
                  ? 'border-sky-400 text-sky-400 font-semibold'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Sliders className="w-4 h-4" />
              <span>Cost Matrix & Vendors</span>
            </button>
          </div>

          {/* Main Grid Content */}
          <div className="p-6 lg:p-8 grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            {/* Column 1 & 2: Proposal Details & Safeguards */}
            <div className="lg:col-span-2 space-y-6">
              
              {activeTab === 'overview' && (
                <>
                  {/* Event Overview Card */}
                  <div className="bg-slate-850/70 p-5 rounded-2xl border border-slate-750">
                    <div className="flex flex-wrap items-center justify-between gap-2 mb-3">
                      <div className="flex items-center space-x-2">
                        <span className="text-xs font-bold uppercase tracking-wider text-sky-400 bg-sky-500/15 px-2.5 py-0.5 rounded-md border border-sky-500/30">
                          Corporate Event
                        </span>
                        <span className="text-xs font-medium text-slate-400">
                          Client: <strong className="text-slate-200">{proposal.clientName}</strong> ({proposal.clientType})
                        </span>
                      </div>
                      <span className="text-xs text-slate-400">Submitted via Mobile App</span>
                    </div>

                    <h3 className="text-xl sm:text-2xl font-bold text-white mb-2">{proposal.eventTitle}</h3>
                    
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-4 pt-4 border-t border-slate-700/60 text-xs">
                      <div className="flex items-center space-x-2 text-slate-300">
                        <Calendar className="w-4 h-4 text-sky-400" />
                        <span>Date: <strong className="text-white">{proposal.targetDate}</strong></span>
                      </div>
                      <div className="flex items-center space-x-2 text-slate-300">
                        <Users className="w-4 h-4 text-sky-400" />
                        <span>Capacity: <strong className="text-white">{proposal.guestCount} Guests</strong></span>
                      </div>
                      <div className="flex items-center space-x-2 text-slate-300">
                        <DollarSign className="w-4 h-4 text-sky-400" />
                        <span>Client Budget: <strong className="text-white">Rs. {proposal.budgetLimit.toLocaleString()}</strong></span>
                      </div>
                    </div>

                    <div className="mt-3 flex items-center space-x-2 text-xs text-slate-400">
                      <MapPin className="w-3.5 h-3.5 text-rose-400" />
                      <span>Venue: <strong className="text-slate-200">{proposal.venue}</strong></span>
                    </div>
                  </div>

                  {/* Weather Risk AI Safeguard Alert Card */}
                  <div className="p-5 bg-gradient-to-r from-amber-500/10 via-amber-600/5 to-slate-800 rounded-2xl border border-amber-500/30 shadow-lg relative overflow-hidden">
                    <div className="flex items-start space-x-4">
                      <div className="p-3 bg-amber-500/20 text-amber-400 rounded-xl border border-amber-500/40 mt-0.5 flex-shrink-0">
                        <CloudRain className="w-6 h-6 animate-pulse" />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <h4 className="text-sm font-bold text-amber-300 flex items-center">
                            <AlertTriangle className="w-4 h-4 mr-1.5 text-amber-400" />
                            Weather Intelligence Agent Alert: {proposal.weatherForecast}
                          </h4>
                          <span className="text-[11px] font-bold px-2 py-0.5 bg-amber-500/20 text-amber-300 rounded border border-amber-500/40">
                            Risk Level: High (70%)
                          </span>
                        </div>
                        <p className="text-xs text-slate-300 mt-1.5 leading-relaxed">
                          {proposal.weatherAlert} Target date coincides with historical monsoon precipitation patterns in Nuwara Eliya.
                        </p>
                        
                        <div className="mt-3 p-3 bg-emerald-500/10 border border-emerald-500/30 rounded-xl flex items-center justify-between text-xs">
                          <span className="font-semibold text-emerald-300 flex items-center">
                            <CheckCircle className="w-4 h-4 mr-2 text-emerald-400" />
                            Autonomous Safeguard Applied: {proposal.safeguardSolution}
                          </span>
                          <span className="text-emerald-400 font-bold bg-emerald-500/20 px-2 py-0.5 rounded">
                            Auto-Included
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Quick Resource Preview */}
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <h4 className="text-sm font-bold text-slate-200 uppercase tracking-wider flex items-center">
                        <Bot className="w-4 h-4 mr-2 text-sky-400" />
                        AI Synthesized Package Breakdown
                      </h4>
                      <span className="text-xs text-slate-400">3 optimized packages</span>
                    </div>

                    <div className="space-y-2.5">
                      {proposal.breakdown.map((item, idx) => (
                        <div key={idx} className="flex items-center justify-between p-3.5 bg-slate-850 rounded-xl border border-slate-750 hover:border-slate-650 transition">
                          <div>
                            <p className="text-sm font-semibold text-slate-100">{item.item}</p>
                            <p className="text-xs text-slate-400 mt-0.5">{item.category} • {item.vendor}</p>
                          </div>
                          <span className="text-sm font-bold text-white bg-slate-800 px-3 py-1.5 rounded-lg border border-slate-700">
                            Rs. {item.cost.toLocaleString()}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                </>
              )}

              {activeTab === 'trail' && (
                <div className="space-y-4">
                  <div className="p-4 bg-slate-850 rounded-xl border border-slate-700">
                    <h4 className="text-sm font-bold text-sky-400 mb-2">LangGraph Autonomous Decision Chain</h4>
                    <p className="text-xs text-slate-400 leading-relaxed mb-4">
                      The execution sequence below represents the multi-agent graph traversal validating venue feasibility, weather telemetry, and budget limits.
                    </p>

                    <div className="space-y-3">
                      <div className="p-3 bg-slate-900/80 rounded-lg border-l-4 border-sky-400 text-xs space-y-1">
                        <div className="flex justify-between font-bold text-slate-200">
                          <span>1. Venue & Capacity Agent</span>
                          <span className="text-slate-400">Status: Succeeded (120ms)</span>
                        </div>
                        <p className="text-slate-400">Selected Grand Palm Garden for 120 guests. Verified max capacity of 300.</p>
                      </div>

                      <div className="p-3 bg-slate-900/80 rounded-lg border-l-4 border-amber-400 text-xs space-y-1">
                        <div className="flex justify-between font-bold text-slate-200">
                          <span>2. Weather Intelligence Agent</span>
                          <span className="text-amber-400">Status: Risk Detected (210ms)</span>
                        </div>
                        <p className="text-slate-400">Nuwara Eliya open lawn on Nov 15: 70% rain forecast. Autonomous safeguard triggered.</p>
                      </div>

                      <div className="p-3 bg-slate-900/80 rounded-lg border-l-4 border-emerald-400 text-xs space-y-1">
                        <div className="flex justify-between font-bold text-slate-200">
                          <span>3. Safety & Resource Agent</span>
                          <span className="text-emerald-400">Status: Safeguard Injected (180ms)</span>
                        </div>
                        <p className="text-slate-400">Appended Waterproof Marquee Tent (Rs. 150,000) from TentMaster Logistics to proposal.</p>
                      </div>

                      <div className="p-3 bg-slate-900/80 rounded-lg border-l-4 border-indigo-400 text-xs space-y-1">
                        <div className="flex justify-between font-bold text-slate-200">
                          <span>4. Cost Optimization Agent</span>
                          <span className="text-indigo-400">Status: Budget Verified (90ms)</span>
                        </div>
                        <p className="text-slate-400">Combined cost Rs. 900,000 fits within Rs. 1,000,000 budget with 10% safety cushion.</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {activeTab === 'breakdown' && (
                <div className="space-y-4">
                  <div className="bg-slate-850 p-5 rounded-xl border border-slate-700">
                    <h4 className="text-sm font-bold text-white mb-3">Resource & Vendor Allocation Matrix</h4>
                    <div className="overflow-x-auto">
                      <table className="w-full text-left text-xs">
                        <thead>
                          <tr className="border-b border-slate-700 text-slate-400 font-semibold uppercase">
                            <th className="pb-2">Resource Item</th>
                            <th className="pb-2">Category</th>
                            <th className="pb-2">Assigned Vendor</th>
                            <th className="pb-2 text-right">Cost (LKR)</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-750">
                          {proposal.breakdown.map((b, i) => (
                            <tr key={i} className="text-slate-300">
                              <td className="py-2.5 font-medium text-white">{b.item}</td>
                              <td className="py-2.5 text-slate-400">{b.category}</td>
                              <td className="py-2.5 text-sky-400">{b.vendor}</td>
                              <td className="py-2.5 text-right font-bold text-white">Rs. {b.cost.toLocaleString()}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              )}

            </div>

            {/* Column 3: Manager Final Decision & Discount Control */}
            <div className="bg-gradient-to-b from-slate-850 to-slate-900 p-6 rounded-2xl border border-slate-700 shadow-xl flex flex-col justify-between space-y-6">
              <div>
                <div className="flex items-center justify-between pb-3 border-b border-slate-750 mb-5">
                  <h4 className="text-base font-bold text-white flex items-center">
                    <Sliders className="w-4 h-4 mr-2 text-sky-400" />
                    Manager Final Action
                  </h4>
                  <span className="text-[11px] font-bold text-slate-400 uppercase bg-slate-800 px-2 py-0.5 rounded border border-slate-700">
                    Human Authority
                  </span>
                </div>
                
                {/* Financial Summary */}
                <div className="space-y-3.5 text-sm">
                  <div className="flex justify-between text-slate-300">
                    <span>AI Subtotal:</span>
                    <span className="font-semibold text-white">Rs. {proposal.subtotal.toLocaleString()}</span>
                  </div>

                  {/* Special Loyalty Discount */}
                  <div className="p-3 bg-slate-800/80 rounded-xl border border-slate-700/80 space-y-2">
                    <div className="flex justify-between items-center text-xs text-slate-300">
                      <span className="font-semibold">Special Loyalty Discount:</span>
                      <span className="text-xs text-emerald-400 font-bold">Applies at Sign-off</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <span className="text-xs text-slate-400 font-bold">LKR</span>
                      <input 
                        type="number" 
                        value={specialDiscount}
                        onChange={(e) => setSpecialDiscount(Number(e.target.value))}
                        className="w-full px-3 py-1.5 bg-slate-900 border border-slate-700 rounded-lg text-right text-sm font-bold text-emerald-400 focus:outline-none focus:border-sky-500"
                        placeholder="20000"
                      />
                    </div>
                  </div>

                  {/* Net Final Cost */}
                  <div className="border-t border-slate-750 pt-3 flex justify-between items-baseline text-base font-extrabold text-white">
                    <span>Final Total to Client:</span>
                    <span className="text-emerald-400 text-xl font-black">
                      Rs. {finalCost.toLocaleString()}
                    </span>
                  </div>

                  {/* Budget Ceiling Progress Bar */}
                  <div className="pt-2">
                    <div className="flex justify-between text-xs text-slate-400 mb-1.5">
                      <span>Client Budget Limit:</span>
                      <span className="text-white font-semibold">Rs. {proposal.budgetLimit.toLocaleString()}</span>
                    </div>
                    <div className="w-full bg-slate-800 rounded-full h-2.5 overflow-hidden border border-slate-700">
                      <div 
                        className="bg-gradient-to-r from-emerald-500 to-sky-400 h-2.5 rounded-full transition-all duration-500" 
                        style={{ width: `${budgetUsedPercentage}%` }}
                      />
                    </div>
                    <p className="text-[11px] text-emerald-400 font-bold mt-2 bg-emerald-500/10 p-2 rounded-lg border border-emerald-500/20 text-center">
                      ✓ Under client budget by Rs. {budgetVariance.toLocaleString()} ({100 - budgetUsedPercentage}% cushion)
                    </p>
                  </div>

                  {/* Manager Notes */}
                  <div className="pt-2">
                    <label className="block text-xs font-semibold text-slate-400 mb-1">
                      Manager Audit Notes:
                    </label>
                    <textarea
                      rows={2}
                      value={managerNote}
                      onChange={(e) => setManagerNote(e.target.value)}
                      className="w-full px-3 py-2 bg-slate-900 border border-slate-700 rounded-lg text-xs text-slate-200 focus:outline-none focus:border-sky-500"
                    />
                  </div>
                </div>
              </div>

              {/* Approval Action Buttons */}
              <div className="space-y-2.5 pt-4 border-t border-slate-750">
                <button 
                  onClick={handleApprove}
                  disabled={reviewStatus === 'Approved'}
                  className="w-full py-3 bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-bold text-sm rounded-xl shadow-lg shadow-emerald-500/20 transition flex items-center justify-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <CheckCircle className="w-4 h-4" />
                  <span>{reviewStatus === 'Approved' ? 'Approved & Ready for Signing' : 'Approve Proposal & Dispatch'}</span>
                </button>

                <button 
                  onClick={() => setShowReoptimizeModal(true)}
                  disabled={reviewStatus === 'Approved'}
                  className="w-full py-2.5 bg-slate-800 hover:bg-slate-750 text-slate-300 hover:text-white border border-slate-700 font-semibold text-xs rounded-xl transition flex items-center justify-center space-x-2"
                >
                  <RotateCcw className="w-4 h-4 text-rose-400" />
                  <span>Request AI Re-Optimization</span>
                </button>
              </div>

            </div>

          </div>
        </div>

        {/* ========================================================= */}
        {/* MODAL: AI RE-OPTIMIZATION INSTRUCTIONS                    */}
        {/* ========================================================= */}
        {showReoptimizeModal && (
          <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="bg-slate-850 border border-slate-700 rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2 text-rose-400 font-bold">
                  <RotateCcw className="w-5 h-5" />
                  <h3 className="text-base text-white">Request AI Re-Optimization</h3>
                </div>
                <button onClick={() => setShowReoptimizeModal(false)} className="text-slate-400 hover:text-white">
                  <XCircle className="w-5 h-5" />
                </button>
              </div>

              <p className="text-xs text-slate-400">
                Enter guidance for the multi-agent graph. The Venue, Weather and Resource agents will re-evaluate alternatives based on your criteria.
              </p>

              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">
                  Manager Feedback Instructions:
                </label>
                <textarea
                  rows={3}
                  value={reoptimizePrompt}
                  onChange={(e) => setReoptimizePrompt(e.target.value)}
                  className="w-full p-3 bg-slate-900 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-sky-500"
                />
              </div>

              <div className="flex space-x-3 pt-2">
                <button
                  onClick={() => setShowReoptimizeModal(false)}
                  className="flex-1 py-2.5 bg-slate-800 text-slate-300 text-xs font-semibold rounded-xl"
                >
                  Cancel
                </button>
                <button
                  onClick={handleReoptimizeSubmit}
                  className="flex-1 py-2.5 bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold rounded-xl shadow-lg"
                >
                  Trigger Re-Run
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};