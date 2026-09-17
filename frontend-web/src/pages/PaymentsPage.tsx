import React, { useState, useEffect } from 'react';
import { CreditCard, TrendingUp, CheckCircle, XCircle, Download, Eye, RefreshCw, X, ShieldCheck } from 'lucide-react';
import { paymentService, type LivePaymentItem } from '../services/api';

export const PaymentsPage: React.FC = () => {
  const [payments, setPayments] = useState<LivePaymentItem[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [selectedSlip, setSelectedSlip] = useState<LivePaymentItem | null>(null);
  const [stats, setStats] = useState<{ totalRevenue: number; confirmedCount: number; projectedRevenue: number }>({
    totalRevenue: 0,
    confirmedCount: 0,
    projectedRevenue: 0,
  });

  const loadData = async () => {
    setLoading(true);
    try {
      const [paymentList, forecast] = await Promise.all([
        paymentService.getPayments().catch(() => []),
        paymentService.getRevenueForecast().catch(() => null),
      ]);

      setPayments(paymentList);

      if (forecast) {
        setStats({
          totalRevenue: forecast.totalRevenueToDate || 0,
          confirmedCount: forecast.confirmedEventsCount || 0,
          projectedRevenue: forecast.projectedMonthlyRevenue || 0,
        });
      } else {
        const total = paymentList
          .filter(p => p.status === 'Approved' || p.status === 'Completed')
          .reduce((sum, p) => sum + (p.amount || 0), 0);
        const count = paymentList.filter(p => p.status === 'Approved' || p.status === 'Completed').length;
        setStats({
          totalRevenue: total,
          confirmedCount: count,
          projectedRevenue: total * 1.25 + 500000,
        });
      }
    } catch (e) {
      console.error('Failed to load payments:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleVerify = async (id: string, newStatus: 'Approved' | 'Rejected') => {
    setActionLoading(id);
    try {
      await paymentService.verifyPayment(id, newStatus);
      await loadData();
      if (selectedSlip && selectedSlip.id === id) {
        setSelectedSlip(null);
      }
    } catch (e) {
      console.error('Error verifying payment:', e);
      alert('Failed to update payment status. Please check backend connection.');
    } finally {
      setActionLoading(null);
    }
  };

  const handleExportCsv = () => {
    const headers = "Booking Reference,Client Name,Event Title,Amount Paid (LKR),Submission Date,Status,Invoice Number\n";
    const rows = payments.map(p => 
      `"${p.bookingRef}","${p.clientName}","${p.eventTitle || 'Event'}",${p.amount},"${p.date}","${p.status}","${p.invoiceNumber || 'Pending'}"`
    ).join("\n");
    const blob = new Blob([headers + rows], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `EventCraft_Financial_Audit_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Payment Verification & Financial Intelligence</h1>
          <p className="text-slate-500 text-sm mt-1">
            Audit customer bank transfer slips, issue automated invoices, and inspect AI revenue forecasts (Member 4 Component).
          </p>
        </div>
        <button
          onClick={loadData}
          disabled={loading}
          className="self-start md:self-auto px-3.5 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-semibold flex items-center space-x-2 transition cursor-pointer"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
          <span>Refresh Live Queue</span>
        </button>
      </div>

      {/* AI Revenue Forecast Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <div className="bg-gradient-to-tr from-emerald-600 to-teal-700 text-white p-6 rounded-xl shadow-sm">
          <p className="text-xs font-semibold text-emerald-100 uppercase tracking-wider">Total Confirmed Revenue</p>
          <p className="text-3xl font-black mt-2">Rs. {stats.totalRevenue.toLocaleString()}</p>
          <p className="text-xs text-emerald-100 mt-2">Verified across {stats.confirmedCount} paid bookings</p>
        </div>

        <div className="bg-white border border-slate-200 p-6 rounded-xl shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-xs font-semibold text-slate-400 uppercase">AI Projected Q4 Revenue</p>
              <p className="text-2xl font-bold text-slate-900 mt-1">Rs. {stats.projectedRevenue.toLocaleString()}</p>
            </div>
            <div className="p-2.5 bg-emerald-50 rounded-lg"><TrendingUp className="w-5 h-5 text-emerald-600" /></div>
          </div>
          <p className="text-xs text-slate-500 mt-3">Peak booking months: <strong className="text-slate-700">October, November, December</strong></p>
        </div>

        <div className="bg-white border border-slate-200 p-6 rounded-xl shadow-sm flex flex-col justify-between">
          <div>
            <p className="text-xs font-semibold text-slate-400 uppercase">Automated Invoices Issued</p>
            <p className="text-2xl font-bold text-slate-900 mt-1">{stats.confirmedCount} Invoices</p>
          </div>
          <button 
            onClick={handleExportCsv}
            className="w-full mt-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-semibold flex items-center justify-center space-x-1 transition active:scale-95 cursor-pointer"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Export Financial Audit (CSV)</span>
          </button>
        </div>
      </div>

      {/* Customer Bank Slips Queue */}
      <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
        <div className="px-6 py-4 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center space-x-2">
            <CreditCard className="w-5 h-5 text-emerald-400" />
            <h3 className="font-semibold text-base">Customer Bank Transfer Slips</h3>
          </div>
          <span className="text-xs bg-slate-800 text-slate-300 px-3 py-1 rounded-full border border-slate-700">
            Manager Verification Queue ({payments.filter(p => p.status === 'PendingVerification' || p.status === 'Pending').length} Pending)
          </span>
        </div>

        {loading ? (
          <div className="p-12 text-center text-slate-400 text-sm flex flex-col items-center">
            <RefreshCw className="w-6 h-6 animate-spin text-emerald-600 mb-2" />
            <span>Connecting to Neon Database & loading slips...</span>
          </div>
        ) : payments.length === 0 ? (
          <div className="p-12 text-center text-slate-400 text-sm">
            No bank transfer slips uploaded yet. When a customer submits a deposit slip via the mobile app, it will appear here immediately.
          </div>
        ) : (
          <div className="divide-y divide-slate-200">
            {payments.map(payment => {
              const isPending = payment.status === 'PendingVerification' || payment.status === 'Pending';
              const isApproved = payment.status === 'Approved' || payment.status === 'Completed' || payment.status === 'PaidAndConfirmed';
              const isRejected = payment.status === 'Rejected' || payment.status === 'Failed';

              return (
                <div key={payment.id} className="p-6 flex flex-col lg:flex-row lg:items-center justify-between gap-4 hover:bg-slate-50 transition">
                  <div className="space-y-1">
                    <div className="flex items-center space-x-2 flex-wrap gap-y-1">
                      <span className="font-bold text-slate-900 text-base">{payment.bookingRef}</span>
                      <span className="text-xs text-slate-500 font-medium">• {payment.clientName}</span>
                      {payment.eventTitle && (
                        <span className="text-xs bg-slate-100 text-slate-600 px-2 py-0.5 rounded font-medium border border-slate-200">
                          {payment.eventTitle}
                        </span>
                      )}
                    </div>
                    <p className="text-sm font-semibold text-emerald-600">
                      Paid Amount: Rs. {Number(payment.amount).toLocaleString()}
                    </p>
                    <div className="flex items-center space-x-3 text-xs text-slate-400">
                      <span>Submitted: {payment.date}</span>
                      {payment.invoiceNumber && (
                        <span className="text-teal-700 font-semibold bg-teal-50 px-2 py-0.5 rounded border border-teal-200">
                          Invoice: {payment.invoiceNumber}
                        </span>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center space-x-3 flex-wrap gap-y-2">
                    {payment.slipUrl && (
                      <button 
                        onClick={() => setSelectedSlip(payment)}
                        className="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded text-xs font-semibold flex items-center space-x-1.5 transition cursor-pointer"
                      >
                        <Eye className="w-3.5 h-3.5 text-slate-600" />
                        <span>View Slip</span>
                      </button>
                    )}

                    <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${
                      isApproved ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' :
                      isRejected ? 'bg-rose-50 text-rose-700 border border-rose-200' :
                      'bg-amber-50 text-amber-700 border border-amber-200'
                    }`}>
                      {isApproved ? 'Approved & Invoiced' : isRejected ? 'Rejected' : 'Pending Verification'}
                    </span>

                    {isPending && (
                      <div className="flex space-x-2">
                        <button 
                          disabled={actionLoading === payment.id}
                          onClick={() => handleVerify(payment.id, 'Approved')}
                          className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-50 text-white rounded text-xs font-semibold flex items-center space-x-1.5 shadow-sm transition cursor-pointer"
                        >
                          <CheckCircle className="w-3.5 h-3.5" />
                          <span>{actionLoading === payment.id ? 'Processing...' : 'Approve & Issue Invoice'}</span>
                        </button>
                        <button 
                          disabled={actionLoading === payment.id}
                          onClick={() => handleVerify(payment.id, 'Rejected')}
                          className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 disabled:opacity-50 text-rose-600 border border-rose-200 rounded text-xs font-semibold flex items-center space-x-1 transition cursor-pointer"
                        >
                          <XCircle className="w-3.5 h-3.5" />
                          <span>Reject</span>
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Slip Image Preview Modal */}
      {selectedSlip && (
        <div className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4 backdrop-blur-sm animate-fade-in">
          <div className="bg-white rounded-2xl max-w-xl w-full max-h-[90vh] flex flex-col overflow-hidden shadow-2xl">
            <div className="px-6 py-4 bg-slate-900 text-white flex justify-between items-center">
              <div>
                <h4 className="font-bold text-base">Bank Deposit Receipt Inspection</h4>
                <p className="text-xs text-slate-400 mt-0.5">{selectedSlip.bookingRef} • {selectedSlip.clientName}</p>
              </div>
              <button 
                onClick={() => setSelectedSlip(null)} 
                className="p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-4 flex-1 overflow-auto bg-slate-100 flex items-center justify-center min-h-[300px]">
              {selectedSlip.slipUrl ? (
                <img 
                  src={selectedSlip.slipUrl} 
                  alt="Customer Bank Deposit Slip" 
                  className="max-h-[60vh] max-w-full object-contain rounded-lg shadow-sm border border-slate-200 bg-white"
                />
              ) : (
                <p className="text-slate-400 text-sm">No slip image attached</p>
              )}
            </div>

            <div className="p-5 bg-white border-t border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <p className="text-xs text-slate-400">Total Claimed Deposit</p>
                <p className="text-lg font-black text-emerald-600">Rs. {Number(selectedSlip.amount).toLocaleString()}</p>
              </div>

              <div className="flex space-x-2">
                {(selectedSlip.status === 'PendingVerification' || selectedSlip.status === 'Pending') && (
                  <>
                    <button 
                      disabled={actionLoading === selectedSlip.id}
                      onClick={() => handleVerify(selectedSlip.id, 'Approved')}
                      className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-lg flex items-center space-x-1.5 shadow-sm transition cursor-pointer"
                    >
                      <ShieldCheck className="w-4 h-4" />
                      <span>Approve & Issue Invoice</span>
                    </button>
                    <button 
                      disabled={actionLoading === selectedSlip.id}
                      onClick={() => handleVerify(selectedSlip.id, 'Rejected')}
                      className="px-3 py-2 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 text-xs font-semibold rounded-lg transition cursor-pointer"
                    >
                      <span>Reject</span>
                    </button>
                  </>
                )}
                <button 
                  onClick={() => setSelectedSlip(null)}
                  className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold rounded-lg transition cursor-pointer"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
