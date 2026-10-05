import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'proposal_details_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMyPayments();
    if (mounted) {
      setState(() {
        _payments = data;
        _isLoading = false;
      });
    }
  }

  double get _totalPaid {
    double total = 0;
    for (var p in _payments) {
      final st = p['status']?.toString();
      if (st == 'Approved' || st == 'Completed') {
        final amt = p['amountPaid'];
        if (amt is num) total += amt.toDouble();
      }
    }
    return total;
  }

  int get _verifiedCount {
    return _payments.where((p) {
      final st = p['status']?.toString();
      return st == 'Approved' || st == 'Completed';
    }).length;
  }

  int get _pendingCount {
    return _payments.where((p) {
      final st = p['status']?.toString();
      return st == 'PendingVerification' || st == 'PendingPayment';
    }).length;
  }

  void _showInvoiceModal(Map<String, dynamic> payment) {
    final currencyFormat = NumberFormat('#,##0', 'en_US');
    final amount = (payment['amountPaid'] is num) ? (payment['amountPaid'] as num).toDouble() : 0.0;
    final formattedAmt = currencyFormat.format(amount);
    final invoiceNum = payment['invoiceNumber'] ?? 'INV-PENDING';
    final bookingRef = payment['bookingRef'] ?? 'EV-2026-REF';
    final title = payment['eventTitle'] ?? 'Event Reservation';
    final status = payment['status'] ?? 'Pending';
    final isVerified = status == 'Approved' || status == 'Completed';
    final slipUrl = payment['slipImageUrl'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Official Invoice & Receipt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // Invoice Reference Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInvoiceRow('Invoice Reference:', invoiceNum, isBold: true),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Booking Reference:', bookingRef),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Event Title:', title),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Payment Method:', 'Commercial Bank Direct Deposit'),
                    const SizedBox(height: 8),
                    _buildInvoiceRow('Status:', isVerified ? 'Verified & Paid' : 'Pending Verification',
                        color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Total Paid Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rs. $formattedAmt',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (slipUrl != null && slipUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Uploaded Bank Deposit Slip:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFF1F5F9),
                    child: slipUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(slipUrl.split(',').last),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            slipUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('Bank slip attached (secure)', style: TextStyle(color: Color(0xFF64748B))),
                            ),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final evId = payment['eventId']?.toString();
                    if (evId != null && evId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProposalDetailsScreen(eventId: evId)),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Open Event Proposal & Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: Color(0xFF38BDF8), size: 20),
            SizedBox(width: 8),
            Text(
              'Payments & Invoices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8), size: 20),
            tooltip: 'Refresh Transactions',
            onPressed: _loadPayments,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 750;
          return RefreshIndicator(
            onRefresh: _loadPayments,
            color: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? constraints.maxWidth * 0.12 : 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. EXECUTIVE METRICS ROW (BILLING KPI)
                  _buildMetricsRow(currencyFormat),
                  const SizedBox(height: 24),

                  // 2. SECTION HEADER
                  const Text(
                    'Billing Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track verified bank deposit slips, manager approvals, and official tax invoice receipts.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  // 3. TRANSACTIONS LIST / EMPTY STATE
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
                    )
                  else if (_payments.isEmpty)
                    _buildEmptyState()
                  else
                    ..._payments.map((p) => _buildPaymentCard(p, currencyFormat)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- EXECUTIVE METRICS ROW ---
  Widget _buildMetricsRow(NumberFormat currencyFormat) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 450;
        final double spacing = isCompact ? 8.0 : 12.0;

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: isCompact ? 'Total\nPaid' : 'Total Paid',
                value: 'Rs. ${currencyFormat.format(_totalPaid)}',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF0284C7),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildMetricCard(
                label: isCompact ? 'Verified\nInvoices' : 'Verified Invoices',
                value: '$_verifiedCount',
                icon: Icons.verified_rounded,
                color: const Color(0xFF10B981),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildMetricCard(
                label: isCompact ? 'Slips\nPending' : 'Slips Pending',
                value: '$_pendingCount',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // --- PAYMENT CARD ---
  Widget _buildPaymentCard(Map<String, dynamic> payment, NumberFormat currencyFormat) {
    final title = payment['eventTitle'] ?? 'Event Reservation';
    final amount = (payment['amountPaid'] is num) ? (payment['amountPaid'] as num).toDouble() : 0.0;
    final formattedAmt = currencyFormat.format(amount);
    final status = payment['status'] ?? 'Pending';
    final invoiceNum = payment['invoiceNumber'] as String?;
    final bookingRef = payment['bookingRef'] ?? 'EV-2026-REF';

    final isVerified = status == 'Approved' || status == 'Completed';
    final isPendingReview = status == 'PendingVerification';

    final Color badgeBg = isVerified
        ? const Color(0xFFDCFCE7)
        : (isPendingReview ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE));
    final Color badgeText = isVerified
        ? const Color(0xFF059669)
        : (isPendingReview ? const Color(0xFFD97706) : const Color(0xFF2563EB));
    final String badgeLabel = isVerified
        ? 'VERIFIED & INVOICE ISSUED'
        : (isPendingReview ? 'SLIP UNDER VERIFICATION' : 'AWAITING PAYMENT');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showInvoiceModal(payment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bookingRef,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. $formattedAmt',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    if (invoiceNum != null && invoiceNum.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt_rounded, size: 12, color: Color(0xFF0F172A)),
                            const SizedBox(width: 4),
                            Text(
                              invoiceNum,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text(
                          'Tap to view receipt & slip',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        final evId = payment['eventId']?.toString();
                        if (evId != null && evId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProposalDetailsScreen(eventId: evId)),
                          );
                        }
                      },
                      child: const Text(
                        'Open Proposal',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF94A3B8), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Payment Transactions Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'When you book an event and the Manager approves your proposal, you can upload bank slips and track official invoices right here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
          ),
        ],
      ),
    );
  }
}
