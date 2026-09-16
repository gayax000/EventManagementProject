import React, { useState } from 'react';
import { CreditCard, TrendingUp, CheckCircle, XCircle, Download, Eye } from 'lucide-react';

export const PaymentsPage: React.FC = () => {
  const [payments, setPayments] = useState([
    { id: 'p1', bookingRef: '#EV-2026-99', clientName: 'Kasun Bandara', amount: 880000, slipUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400', date: '2026-11-10', status: 'Pending' },
    { id: 'p2', bookingRef: '#EV-2026-42', clientName: 'Sahan Perera', amount: 450000, slipUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400', date: '2026-10-28', status: 'Approved' },
  ]);

  const handleVerify = (id: string, newStatus: 'Approved' | 'Rejected') => {
    setPayments(prev => prev.map(p => p.id === id ? { ...p, status: newStatus } : p));
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-slate-900">Payment Verification & Financial Intelligence</h1>
        <p className="text-slate-500 text-sm mt-1">Audit customer bank transfer slips, issue automated invoices, and inspect AI revenue forecasts (Member 4 Component).</p>
      </div>

      {/* AI Revenue Forecast Card */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <div className="bg-gradient-to-tr from-emerald-600 to-teal-700 text-white p-6 rounded-xl shadow-sm">
          <p className="text-xs font-semibold text-emerald-100 uppercase tracking-wider">Total Confirmed Revenue</p>
          <p className="text-3xl font-black mt-2">Rs. 4,280,000</p>
          <p className="text-xs text-emerald-100 mt-2">Verified across 28 confirmed event bookings</p>
        </div>

        <div className="bg-white border border-slate-200 p-6 rounded-xl shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-xs font-semibold text-slate-400 uppercase">AI Projected Q4 Revenue</p>
              <p className="text-2xl font-bold text-slate-900 mt-1">Rs. 6,850,000</p>
            </div>
            <div className="p-2.5 bg-emerald-50 rounded-lg"><TrendingUp className="w-5 h-5 text-emerald-600" /></div>
          </div>
          <p className="text-xs text-slate-500 mt-3">Peak booking months: <strong className="text-slate-700">October, November, December</strong></p>
        </div>

        <div className="bg-white border border-slate-200 p-6 rounded-xl shadow-sm flex flex-col justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Automated Invoices Issued</p>
            <p className="text-2xl font-bold text-slate-900 mt-1">28 Invoices</p>
          </div>
          <button className="w-full mt-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-semibold flex items-center justify-center space-x-1 transition">
            <Download className="w-3.5 h-3.5" />
            <span>Export Financial Audit (CSV)</span>
          </button>
        </div>
      </div>

      {/* Pending Bank Slips Table */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center space-x-2">
            <CreditCard className="w-5 h-5 text-emerald-400" />
            <h3 className="font-semibold text-base">Customer Bank Transfer Slips</h3>
          </div>
          <span className="text-xs bg-slate-800 text-slate-300 px-3 py-1 rounded-full border border-slate-700">Manager Verification Queue</span>
        </div>

        <div className="divide-y divide-slate-200">
          {payments.map(payment => (
            <div key={payment.id} className="p-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div className="space-y-1">
                <div className="flex items-center space-x-2">
                  <span className="font-bold text-slate-900 text-base">{payment.bookingRef}</span>
                  <span className="text-xs text-slate-500">• {payment.clientName}</span>
                </div>
                <p className="text-sm font-semibold text-emerald-600">Paid Amount: Rs. {payment.amount.toLocaleString()}</p>
                <p className="text-xs text-slate-400">Submitted Date: {payment.date}</p>
              </div>

              <div className="flex items-center space-x-3">
                <a 
                  href={payment.slipUrl} 
                  target="_blank" 
                  rel="noreferrer"
                  className="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded text-xs font-medium flex items-center space-x-1 transition"
                >
                  <Eye className="w-3.5 h-3.5" />
                  <span>View Slip</span>
                </a>

                <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${
                  payment.status === 'Approved' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' :
                  payment.status === 'Rejected' ? 'bg-rose-50 text-rose-700 border border-rose-200' :
                  'bg-amber-50 text-amber-700 border border-amber-200'
                }`}>
                  {payment.status}
                </span>

                {payment.status === 'Pending' && (
                  <div className="flex space-x-2">
                    <button 
                      onClick={() => handleVerify(payment.id, 'Approved')}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded text-xs font-medium flex items-center space-x-1"
                    >
                      <CheckCircle className="w-3.5 h-3.5" />
                      <span>Approve & Issue Invoice</span>
                    </button>
                    <button 
                      onClick={() => handleVerify(payment.id, 'Rejected')}
                      className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 rounded text-xs font-medium flex items-center space-x-1"
                    >
                      <XCircle className="w-3.5 h-3.5" />
                      <span>Reject</span>
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};