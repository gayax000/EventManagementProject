import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signature/signature.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class ProposalDetailsScreen extends StatefulWidget {
  final String eventId;

  const ProposalDetailsScreen({super.key, required this.eventId});

  @override
  State<ProposalDetailsScreen> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalDetailsScreen> {
  bool _isLoading = true;
  EventProposalDetail? _proposal;
  bool _isSubmittingSignature = false;
  bool _isUploadingSlip = false;
  final ImagePicker _slipPicker = ImagePicker();
  Uint8List? _selectedSlipBytes;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _loadProposal();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickSlipImage() async {
    try {
      final XFile? image = await _slipPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedSlipBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick slip: $e')),
        );
      }
    }
  }

  Future<void> _submitPaymentSlip() async {
    if (_selectedSlipBytes == null || _proposal == null) return;
    setState(() => _isUploadingSlip = true);

    try {
      final base64Image = 'data:image/jpeg;base64,${base64Encode(_selectedSlipBytes!)}';
      await ApiService.uploadPaymentSlip(
        bookingId: _proposal!.bookingId,
        eventId: widget.eventId,
        amount: _proposal!.estimatedTotalCost,
        slipImageBase64: base64Image,
        bankReferenceNumber: 'MOB-TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        notes: 'Bank Deposit Slip uploaded via Mobile App for ${_proposal!.title}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bank slip submitted! Manager has been notified for verification."),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedSlipBytes = null;
      });
      _loadProposal();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error uploading slip: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingSlip = false);
    }
  }

  Future<void> _loadProposal() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getProposalDetails(widget.eventId);
    if (mounted) {
      setState(() {
        _proposal = data;
        _isLoading = false;
      });
    }
  }

  void _showRevisionDialog(EventProposalDetail proposal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Color(0xFFF43F5E), size: 24),
            SizedBox(width: 8),
            Text('Request Custom Revision', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe the specific changes or adjustments you would like the Operations Manager to make for your event proposal:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g., Please change photography package, adjust food menu options, add welcome drinks...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFF43F5E))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final notes = controller.text.trim();
              if (notes.isEmpty) return;
              Navigator.of(ctx).pop();
              setState(() => _isLoading = true);
              final ok = await ApiService.submitClientBudgetChoice(
                widget.eventId,
                'request_revision',
                proposal.estimatedTotalCost,
                revisionNotes: notes,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? '⚠️ Revision request submitted to Manager!' : 'Failed to submit revision request.'),
                    backgroundColor: ok ? const Color(0xFFF43F5E) : Colors.redAccent,
                  ),
                );
                _loadProposal();
              }
            },
            child: const Text('Submit Revision Request', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSign() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide your digital signature first."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmittingSignature = true);

    try {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      final String signatureBase64 = signatureBytes != null
          ? 'data:image/png;base64,${base64Encode(signatureBytes)}'
          : 'signature_ok';

      final result = await ApiService.signContract(
        eventId: widget.eventId,
        agreedAmount: _proposal?.estimatedTotalCost ?? 0,
        signatureData: signatureBase64,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Contract Signed & QR Pass Issued!"),
            backgroundColor: Colors.green,
          ),
        );
        _loadProposal(); // Reload to display newly minted QR Pass
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error signing contract: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingSignature = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Event Proposal & Status",
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
            onPressed: _loadProposal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _proposal == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Failed to load proposal details.", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadProposal, child: const Text("Retry")),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final proposal = _proposal!;
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final m = proposal.targetDate.month >= 1 && proposal.targetDate.month <= 12 ? months[proposal.targetDate.month - 1] : '';
    final formattedDate = '$m ${proposal.targetDate.day.toString().padLeft(2, '0')}, ${proposal.targetDate.year}';
    final formattedCost = proposal.estimatedTotalCost.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formattedBudget = proposal.budgetLimit.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    final isApproved = proposal.status == 'ApprovedByManager';
    final isConfirmed = proposal.isConfirmed || proposal.status == 'Confirmed';
    final isChoiceSubmitted = proposal.status == 'ClientChoiceSubmitted';
    final isPendingBudgetApproval = proposal.status == 'PendingClientBudgetApproval';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Header
          if (isConfirmed)
            _buildBadge("STATUS: BOOKING CONFIRMED & PASS ISSUED", const Color(0xFFDCFCE7), const Color(0xFF059669))
          else if (isApproved) ...[
            if (proposal.paymentStatus == 'Completed' || proposal.paymentStatus == 'Approved')
              _buildBadge("PAYMENT VERIFIED: READY TO SIGN & ISSUE PASS", const Color(0xFFDCFCE7), const Color(0xFF059669))
            else if (proposal.paymentStatus == 'PendingVerification')
              _buildBadge("PAYMENT SLIP UNDER MANAGER VERIFICATION", const Color(0xFFFEF3C7), const Color(0xFFD97706))
            else
              _buildBadge("PROPOSAL APPROVED: AWAITING PAYMENT DEPOSIT", const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
          ] else if (isChoiceSubmitted)
            _buildBadge("CHOICE SUBMITTED: AWAITING MANAGER FINAL CONFIRMATION", const Color(0xFFEEF2FF), const Color(0xFF4F46E5))
          else if (isPendingBudgetApproval)
            _buildBadge("STATUS: MANAGER RECOMMENDATION (BUDGET OVERRUN)", const Color(0xFFFEF3C7), const Color(0xFFD97706))
          else
            _buildBadge("STATUS: UNDER MANAGER REVIEW", const Color(0xFFFEF3C7), const Color(0xFFD97706)),

          const SizedBox(height: 12),

          // Visual Responsive Timeline Stepper Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineStep(
                  stepNumber: "1",
                  title: "1. AI Plan",
                  isActive: true,
                  isDone: isPendingBudgetApproval || isChoiceSubmitted || isApproved || isConfirmed,
                  hasLineBefore: false,
                  hasLineAfter: true,
                  isLineAfterActive: isPendingBudgetApproval || isChoiceSubmitted || isApproved || isConfirmed,
                ),
                _buildTimelineStep(
                  stepNumber: "2",
                  title: "2. Budget Review",
                  isActive: isPendingBudgetApproval || isChoiceSubmitted,
                  isDone: isApproved || isConfirmed,
                  hasLineBefore: true,
                  isLineBeforeActive: isPendingBudgetApproval || isChoiceSubmitted || isApproved || isConfirmed,
                  hasLineAfter: true,
                  isLineAfterActive: isApproved || isConfirmed,
                ),
                _buildTimelineStep(
                  stepNumber: "3",
                  title: "3. Deposit",
                  isActive: isApproved && !isConfirmed,
                  isDone: isConfirmed,
                  hasLineBefore: true,
                  isLineBeforeActive: isApproved || isConfirmed,
                  hasLineAfter: true,
                  isLineAfterActive: isConfirmed,
                ),
                _buildTimelineStep(
                  stepNumber: "4",
                  title: "4. Pass Issued",
                  isActive: isConfirmed,
                  isDone: isConfirmed,
                  hasLineBefore: true,
                  isLineBeforeActive: isConfirmed,
                  hasLineAfter: false,
                  isLineAfterActive: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Event Title & Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        proposal.title,
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: proposal.isOutdoor ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: proposal.isOutdoor ? const Color(0xFFFCD34D) : const Color(0xFFBAE6FD)),
                      ),
                      child: Text(
                        proposal.isOutdoor ? 'Outdoor' : 'Indoor',
                        style: TextStyle(
                          color: proposal.isOutdoor ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(formattedDate, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text("Guests: ${proposal.guestCount}  |  Venue: ${proposal.venueName}", style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text("Customer Budget: LKR $formattedBudget", style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Manager Recommendation & Budget Overrun Review Card
          if ((isPendingBudgetApproval || isChoiceSubmitted) && !isConfirmed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF312E81).withOpacity(0.95), const Color(0xFF1E1B4B)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF818CF8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Color(0xFFA5B4FC), size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "HOTEL MANAGER'S RECOMMENDATION",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isChoiceSubmitted ? Colors.cyan.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isChoiceSubmitted ? Colors.cyan : Colors.amber),
                        ),
                        child: Text(
                          isChoiceSubmitted ? "Choice Sent" : "Action Required",
                          style: TextStyle(color: isChoiceSubmitted ? Colors.cyanAccent : Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We compiled your ${proposal.title} with premium 4K Video Coverage & Fresh Floral Tunnel Arch to match your venue luxury.",
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Recommended Package Total:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("LKR $formattedCost", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Your Stated Budget Limit:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("LKR $formattedBudget", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        if (proposal.estimatedTotalCost > proposal.budgetLimit) ...[
                          const Divider(color: Colors.white12, height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Budget Difference:", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(
                                "+LKR ${(proposal.estimatedTotalCost - proposal.budgetLimit).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (proposal.status == 'RevisionRequested') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF43F5E)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.mark_chat_read, color: Color(0xFFF43F5E), size: 28),
                          const SizedBox(height: 6),
                          const Text(
                            "⚠️ Custom Revision Request Submitted to Manager",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Notes sent: \"${proposal.revisionNotes ?? 'Revision requested'}\"\nHotel Operations Manager is reviewing your requested modifications.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isChoiceSubmitted) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF818CF8)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.mark_email_read, color: Colors.cyanAccent, size: 28),
                          const SizedBox(height: 6),
                          const Text(
                            "✓ Budget Choice Submitted to Manager",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "You selected package total LKR $formattedCost. The Hotel Operations Manager has been notified on the Web Portal to confirm and unlock your deposit payment slip.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "Please select how you would like to proceed:",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 10),

                    // Option A: Accept Overrun & Proceed
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          final ok = await ApiService.submitClientBudgetChoice(widget.eventId, 'AcceptedPremium', proposal.estimatedTotalCost);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok 
                                    ? "✓ Choice submitted! Waiting for Manager's final confirmation on Web Dashboard." 
                                    : "✓ Request submitted to manager."),
                                backgroundColor: Colors.indigo,
                              ),
                            );
                            _loadProposal();
                          }
                        },
                        icon: const Icon(Icons.verified, size: 16, color: Colors.white),
                        label: Text("Accept Premium Package (LKR $formattedCost)", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Option B: Request Auto-Fit to Budget
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          final ok = await ApiService.submitClientBudgetChoice(widget.eventId, 'RequestedBudgetFit', proposal.budgetLimit);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? "Request submitted! Waiting for Manager's final confirmation on Web Dashboard."
                                    : "Request submitted to manager."),
                                backgroundColor: Colors.teal,
                              ),
                            );
                            _loadProposal();
                          }
                        },
                        icon: const Icon(Icons.bolt, size: 16, color: Colors.amberAccent),
                        label: Text("Request Budget-Fit Standard Package (LKR $formattedBudget)", style: const TextStyle(fontSize: 11.5, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amberAccent),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Option C: Request Custom Revision
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRevisionDialog(proposal),
                        icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFF43F5E)),
                        label: const Text("⚠️ Request Custom Revision Notes", style: TextStyle(fontSize: 11.5, color: Color(0xFFF43F5E), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF43F5E)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Special Client Requests (Flower Bouquet / Add-ons)
          if (proposal.additionalDetails != null && proposal.additionalDetails!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Executive Soft Blue
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)), // Sky Blue Border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'SPECIAL CLIENT REQUESTS & ADD-ONS',
                            style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold, fontSize: 11.5, letterSpacing: 0.3),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF93C5FD)),
                        ),
                        child: Text(
                          proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0
                            ? 'Allocated: LKR ${proposal.specialRequestAllocation!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                            : 'Priced by Manager',
                          style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    proposal.additionalDetails!,
                    softWrap: true,
                    style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Inspiration Photos Thumbnail Preview
          if (proposal.inspirationImages.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Inspiration Photos (${proposal.inspirationImages.length})',
                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: proposal.inspirationImages.length,
                      itemBuilder: (ctx, idx) {
                        final img = proposal.inspirationImages[idx];
                        return Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(img.split(',').last),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
                                  )
                                : Image.network(
                                    img,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 3. AI Generated Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 18),
                    SizedBox(width: 8),
                    Text(
                      "AI AGENTIC BREAKDOWN & SAFEGUARD",
                      style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("• Venue: ${proposal.venueName}", style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                Text("• Catering & Resources: Optimized for ${proposal.guestCount} guests", style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    Map<String, dynamic>? wMap;
                    if (proposal.weatherAssessment != null && proposal.weatherAssessment!.startsWith('{')) {
                      try {
                        wMap = jsonDecode(proposal.weatherAssessment!) as Map<String, dynamic>;
                      } catch (_) {}
                    }
                    final bool isOut = proposal.isOutdoor;
                    final int rainPct = wMap != null ? (wMap['RainProbabilityPercent'] ?? wMap['rainProbabilityPercent'] ?? 0) : (isOut ? 65 : 0);
                    final String cond = wMap != null ? (wMap['Condition'] ?? wMap['condition'] ?? 'Clear') : (isOut ? 'Monsoon Showers' : 'Climate Controlled');
                    final num safeguardCost = wMap != null ? (wMap['SafeguardCost'] ?? wMap['safeguardCost'] ?? 0) : 0;
                    final bool hasTent = isOut && (safeguardCost > 0 || rainPct >= 60);

                    // Shorten verbose weather conditions for clean mobile responsiveness
                    final String cleanCond = cond
                        .replaceAll('North-East Monsoon Showers', 'Monsoon Showers')
                        .replaceAll('Inter-Monsoon Thunderstorms', 'Monsoon Storms');

                    if (!isOut) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.shield_rounded, color: Color(0xFF16A34A), size: 16),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Weather Assessment: 0% Risk (Indoor Venue)", 
                                    softWrap: true,
                                    style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text("• Indoor Climate-Controlled Hall. Zero weather risk.", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFF15803D), fontSize: 11)),
                            SizedBox(height: 2),
                            Text("• Safeguard: None needed (Saved Rs. 150,000 tent cost).", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    } else if (hasTent) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.cloud_sync_rounded, color: Color(0xFFD97706), size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Weather Assessment: $rainPct% Rain Risk ($cleanCond)", 
                                    softWrap: true,
                                    style: const TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text("• Outdoor contingency safeguard applied.", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFF92400E), fontSize: 11)),
                            const SizedBox(height: 2),
                            const Text("• Safeguard: Waterproof Marquee Tent (Rs. 150,000).", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.wb_sunny_rounded, color: Color(0xFF0284C7), size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Weather Assessment: $rainPct% Rain Risk ($cleanCond)", 
                                    softWrap: true,
                                    style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text("• Favorable outdoor forecast. No heavy rain expected.", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFF0369A1), fontSize: 11)),
                            const SizedBox(height: 2),
                            const Text("• Safeguard: Not needed (Saved Rs. 150,000 tent cost).", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }
                  },
                ),
                if (proposal.selectedServices.isNotEmpty || (proposal.additionalDetails != null && proposal.additionalDetails!.trim().isNotEmpty))
                  _buildItemizedBreakdown(proposal),
                const Divider(color: Color(0xFFE2E8F0), height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text("FINAL AGREED AMOUNT:", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12.5)),
                    ),
                    Text("LKR $formattedCost", style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Bank Transfer & Payment Slip Section (Member 4 Mobile Integration)
          if (isApproved || isConfirmed) ...[
            _buildPaymentSlipSection(proposal, formattedCost),
            const SizedBox(height: 16),
          ],

          // 5. Action / Signature / QR Pass based on State
          if (isConfirmed && proposal.qrCodeData != null) ...[
            // QR Entry Pass View
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text("OFFICIAL EVENT ENTRY PASS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text("Present this QR at the venue entrance gate", style: TextStyle(color: Colors.black54, fontSize: 11)),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: proposal.qrCodeData!,
                      version: QrVersions.auto,
                      size: 190.0,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      proposal.bookingRef ?? "REF: EV-2026-LIVE",
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    const Text("Status: Verified & Active in Neon DB", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ] else if (isApproved) ...[
            Builder(
              builder: (context) {
                final isPaymentVerified = proposal.paymentStatus == 'Completed' || proposal.paymentStatus == 'Approved';

                if (isPaymentVerified) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "PAYMENT VERIFIED: SIGN CONTRACT TO MINT ENTRY PASS",
                                    style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    "Finance Manager approved your payment (Invoice: ${proposal.invoiceNumber ?? 'INV-PAID'}). Draw your signature below to legally execute the agreement and receive your QR Entry Pass.",
                                    style: const TextStyle(color: Color(0xFF047857), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.draw_rounded, size: 16, color: Color(0xFF0F172A)),
                          SizedBox(width: 6),
                          Text(
                            "DRAW YOUR DIGITAL SIGNATURE TO CONFIRM",
                            style: TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.greenAccent, width: 2),
                        ),
                        child: Signature(
                          controller: _signatureController,
                          height: 140,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _signatureController.clear(),
                              child: const Text("Clear Signature", style: TextStyle(color: Colors.white70)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _isSubmittingSignature ? null : _confirmAndSign,
                              child: _isSubmittingSignature
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text("CONFIRM & ISSUE PASS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // LOCKED STATE (Option 1: Strict Payment First)
                  final isPendingVerification = proposal.paymentStatus == 'PendingVerification';
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.lock_person_rounded, color: Color(0xFF2563EB), size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          "Digital Signature Locked (Payment Required)",
                          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPendingVerification
                              ? "Your bank transfer slip has been uploaded and is currently in the Manager's verification queue. This signature pad and your QR Entry Pass will unlock as soon as your payment is approved."
                              : "Please transfer the required total (LKR $formattedCost) to our Commercial Bank account above and upload your deposit slip. Once our Finance Manager approves the transaction on the Web Dashboard, this pad will unlock automatically.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isPendingVerification ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isPendingVerification ? const Color(0xFFFCD34D) : const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPendingVerification ? Icons.hourglass_top : Icons.pending_actions,
                                size: 14,
                                color: isPendingVerification ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPendingVerification
                                    ? "Step 2: Awaiting Manager Slip Verification"
                                    : "Step 1: Upload Bank Transfer Slip Above",
                                style: TextStyle(
                                  color: isPendingVerification ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ] else ...[
            // Payment Slip Locked Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_clock, color: Color(0xFFD97706), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    isChoiceSubmitted
                      ? "Bank Slip Upload Locked (Awaiting Manager Final Approval)"
                      : isPendingBudgetApproval
                      ? "Bank Slip Upload Locked (Awaiting Budget Choice)"
                      : "Bank Slip Upload Locked (Awaiting Manager Review)",
                    style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isChoiceSubmitted
                      ? "You submitted your budget choice. Once the Operations Manager gives final confirmation on the Web Dashboard, this payment deposit section will unlock automatically!"
                      : isPendingBudgetApproval
                      ? "Please review the Manager's recommendation card above and select your budget choice to proceed."
                      : "Our AI Multi-Agent system has compiled your preliminary plan. The Event Manager is reviewing vendor packages and pricing on the Web Portal. Please check back shortly!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB45309), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required bool isActive,
    required bool isDone,
    required bool hasLineBefore,
    bool isLineBeforeActive = false,
    required bool hasLineAfter,
    bool isLineAfterActive = false,
  }) {
    const Color activeColor = Color(0xFF2563EB);
    const Color doneColor = Color(0xFF059669);
    const Color inactiveColor = Color(0xFF64748B);
    const Color inactiveLine = Color(0xFFE2E8F0);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2.5,
                  color: hasLineBefore
                      ? (isLineBeforeActive ? doneColor : inactiveLine)
                      : Colors.transparent,
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? doneColor
                      : (isActive ? activeColor : const Color(0xFFF1F5F9)),
                  border: Border.all(
                    color: isDone
                        ? doneColor
                        : (isActive ? activeColor : const Color(0xFFCBD5E1)),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                      : Text(
                          stepNumber,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2.5,
                  color: hasLineAfter
                      ? (isLineAfterActive ? doneColor : inactiveLine)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
                color: isDone
                    ? doneColor
                    : (isActive ? activeColor : inactiveColor),
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.35)),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
    );
  }

  Widget _buildPaymentSlipSection(EventProposalDetail proposal, String formattedCost) {
    final isPaid = proposal.paymentStatus == 'Completed' || proposal.paymentStatus == 'Approved';
    final isPendingReview = proposal.paymentStatus == 'PendingVerification';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPaid
              ? const Color(0xFF10B981)
              : (isPendingReview ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Bank Icon & Title with Expanded
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: isPaid ? const Color(0xFF059669) : const Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "BANK TRANSFER & PAYMENT",
                  softWrap: true,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status Badge: Positioned below title with generous space & modern pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xFFDCFCE7)
                  : (isPendingReview ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPaid
                    ? const Color(0xFF86EFAC)
                    : (isPendingReview ? const Color(0xFFFCD34D) : const Color(0xFFBFDBFE)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPaid
                      ? Icons.check_circle_rounded
                      : (isPendingReview ? Icons.hourglass_top_rounded : Icons.pending_actions_rounded),
                  size: 13,
                  color: isPaid
                      ? const Color(0xFF059669)
                      : (isPendingReview ? const Color(0xFFD97706) : const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 5),
                Text(
                  isPaid
                      ? "VERIFIED & SETTLED"
                      : (isPendingReview ? "SLIP UNDER REVIEW" : "PENDING PAYMENT"),
                  style: TextStyle(
                    color: isPaid
                        ? const Color(0xFF059669)
                        : (isPendingReview ? const Color(0xFFD97706) : const Color(0xFF2563EB)),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bank Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Official Deposit Account:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 8),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text("Bank:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        "Commercial Bank of Ceylon",
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text("Account Name:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        "EventCraft Pvt Ltd",
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text("Account Number:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        "8001234567",
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text("Branch / SWIFT:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(
                        "Colombo City Branch (CCEYLKLX)",
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text("Required Amount:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Text("LKR $formattedCost", style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                if (proposal.invoiceNumber != null && proposal.invoiceNumber!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Tax Invoice Number:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ),
                      Text(proposal.invoiceNumber!, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Slip Status & Upload Controls
          if (isPaid) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Slip Verified & Approved",
                          style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          "Official Invoice ${proposal.invoiceNumber ?? 'INV-PAID'} issued. All vendor contracts activated.",
                          style: const TextStyle(color: Color(0xFF047857), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isPendingReview || (proposal.slipImageUrl != null && proposal.slipImageUrl!.isNotEmpty && _selectedSlipBytes == null)) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFD97706), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Deposit Slip Under Verification",
                          style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Your bank transfer slip was received and is in the Operations Manager's verification queue. You will receive invoice confirmation once cleared.",
                    style: TextStyle(color: Color(0xFFB45309), fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  if (proposal.slipImageUrl != null && proposal.slipImageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.black12,
                        child: proposal.slipImageUrl!.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(proposal.slipImageUrl!.split(',').last),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.black26),
                              )
                            : Image.network(
                                proposal.slipImageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.black26),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            if (_selectedSlipBytes != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2563EB)),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        _selectedSlipBytes!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickSlipImage,
                            icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF64748B)),
                            label: const Text("Change Slip", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFCBD5E1))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploadingSlip ? null : _submitPaymentSlip,
                            icon: _isUploadingSlip
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.cloud_upload_rounded, size: 14, color: Colors.white),
                            label: Text(
                              _isUploadingSlip ? "Uploading..." : "Submit Slip",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickSlipImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.upload_file_rounded, color: Color(0xFF2563EB), size: 18),
                  label: const Text(
                    "Upload Bank Deposit / Transfer Slip",
                    style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Attach JPG/PNG payment confirmation. Manager will verify within 1 hour.",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildItemizedBreakdown(EventProposalDetail proposal) {
    final Map<String, double> parsedCosts = {};
    if (proposal.generatedPlan != null && proposal.generatedPlan!.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(proposal.generatedPlan!);
        if (decoded is List) {
          for (var item in decoded) {
            final str = item.toString();
            final matches = RegExp(r'(?:Rs\.|LKR)\s*([\d,]+)').allMatches(str);
            if (matches.isNotEmpty) {
              final val = double.tryParse(matches.last.group(1)!.replaceAll(',', '')) ?? 0.0;
              final lower = str.toLowerCase();
              if (lower.contains('photo')) {
                parsedCosts['photo'] = val;
              } else if (lower.contains('sound') || lower.contains('audio')) {
                parsedCosts['sound'] = val;
              } else if (lower.contains('deco') || lower.contains('floral') || lower.contains('stage')) {
                parsedCosts['deco'] = val;
              } else if (lower.contains('cake') || lower.contains('gateau')) {
                parsedCosts['cake'] = val;
              } else if (lower.contains('transport') || lower.contains('sedan') || lower.contains('car') || lower.contains('van')) {
                parsedCosts['transport'] = val;
              } else if (lower.contains('special') || lower.contains('request')) {
                parsedCosts['special'] = val;
              } else if (lower.contains('tent') || lower.contains('safeguard') || lower.contains('canopy') || lower.contains('marquee')) {
                parsedCosts['tent'] = val;
              } else if (lower.contains('venue') || lower.contains('hall')) {
                parsedCosts['hall'] = val;
              } else if (lower.contains('buffet') || lower.contains('catering')) {
                parsedCosts['catering'] = val;
              }
            }
          }
        }
      } catch (_) {}
    }

    final double hallPrice = parsedCosts['hall'] ?? proposal.hallRentalPrice ?? 350000.0;
    double cateringPrice = parsedCosts['catering'] ?? ((proposal.perPlatePrice ?? 5000.0) * proposal.guestCount);
    if (cateringPrice < 20000 && proposal.guestCount > 1) {
      cateringPrice = cateringPrice * proposal.guestCount;
    }
    
    final bool isAutoFit = proposal.status == 'ApprovedByManager' || proposal.status == 'Confirmed' || proposal.estimatedTotalCost <= proposal.budgetLimit;

    final List<Map<String, dynamic>> items = [];

    // 1. Venue Rental
    items.add({
      'icon': '',
      'label': '${proposal.banquetHallName ?? proposal.venueName} Rental',
      'cost': hallPrice,
      'isSpecial': false,
    });

    // 2. Hotel Catering
    items.add({
      'icon': '',
      'label': 'Hotel Dinner Buffet (${proposal.guestCount} Guests)',
      'cost': cateringPrice,
      'isSpecial': false,
    });

    // 3. Selected Services
    for (var s in proposal.selectedServices) {
      String desc = s;
      double cost = 100000;
      String icon = '';
      if (s.toLowerCase().contains('photo')) {
        icon = '';
        desc = 'Photography & 4K Video';
        cost = parsedCosts['photo'] ?? (isAutoFit ? 60000.0 : (proposal.budgetLimit >= 1200000 ? 160000.0 : 100000.0));
      } else if (s.toLowerCase().contains('sound') || s.toLowerCase().contains('light')) {
        icon = '';
        desc = 'Sound & Intelligent Lighting';
        cost = parsedCosts['sound'] ?? (isAutoFit ? 80000.0 : (proposal.budgetLimit >= 1200000 ? 180000.0 : 120000.0));
      } else if (s.toLowerCase().contains('deco')) {
        icon = '';
        desc = 'Stage Styling & Theme Decor';
        cost = parsedCosts['deco'] ?? (isAutoFit ? 50000.0 : (proposal.budgetLimit >= 1200000 ? 130000.0 : 80000.0));
      } else if (s.toLowerCase().contains('cake')) {
        icon = '';
        desc = 'Luxury Celebration Cake';
        cost = parsedCosts['cake'] ?? (isAutoFit ? 20000.0 : (proposal.budgetLimit >= 1200000 ? 45000.0 : 25000.0));
      } else if (s.toLowerCase().contains('transport') || s.toLowerCase().contains('car') || s.toLowerCase().contains('bridal')) {
        icon = '';
        desc = 'Chauffeur VIP Transport';
        cost = parsedCosts['transport'] ?? (isAutoFit ? 35000.0 : (proposal.budgetLimit >= 1200000 ? 65000.0 : 50000.0));
      }
      items.add({
        'icon': icon,
        'label': desc,
        'cost': cost,
        'isSpecial': false,
      });
    }

    // 3.5 Food Menu Refreshments & Add-ons
    if (proposal.tableRefreshments.isNotEmpty) {
      for (var r in proposal.tableRefreshments) {
        double rCostPerHead = 0.0;
        if (r.contains('Mocktail') || r.contains('Drink')) {
          rCostPerHead = proposal.budgetLimit >= 2000000 ? 800.0 : (proposal.budgetLimit >= 1000000 ? 500.0 : 350.0);
        } else if (r.contains('Snack') || r.contains('Savory')) {
          rCostPerHead = proposal.budgetLimit >= 2000000 ? 950.0 : (proposal.budgetLimit >= 1000000 ? 650.0 : 450.0);
        } else if (r.contains('Dessert') || r.contains('Sweet')) {
          rCostPerHead = proposal.budgetLimit >= 2000000 ? 1200.0 : (proposal.budgetLimit >= 1000000 ? 800.0 : 500.0);
        } else if (r.contains('Tea') || r.contains('Coffee')) {
          rCostPerHead = proposal.budgetLimit >= 2000000 ? 450.0 : (proposal.budgetLimit >= 1000000 ? 300.0 : 200.0);
        } else if (r.contains('Midnight') || r.contains('Action')) {
          rCostPerHead = proposal.budgetLimit >= 2000000 ? 1100.0 : (proposal.budgetLimit >= 1000000 ? 750.0 : 500.0);
        }

        double totalRCost = rCostPerHead * proposal.guestCount;
        items.add({
          'icon': '🍹',
          'label': '$r (${proposal.guestCount} Guests @ LKR ${rCostPerHead.toStringAsFixed(0)})',
          'cost': totalRCost,
          'isSpecial': false,
        });
      }
    }

    // 4. Special Client Request
    if (proposal.additionalDetails != null && proposal.additionalDetails!.trim().isNotEmpty) {
      double specialCost = parsedCosts['special'] ?? proposal.specialRequestAllocation ?? 0.0;
      items.add({
        'icon': '',
        'label': 'Special Request (${proposal.additionalDetails})',
        'cost': specialCost,
        'isSpecial': true,
      });
    }

    // 5. Outdoor Weather Safeguard Tent
    if (proposal.isOutdoor) {
      double tentCost = parsedCosts['tent'] ?? (isAutoFit ? 100000.0 : 150000.0);
      if (tentCost > 0) {
        items.add({
          'icon': '',
          'label': 'Waterproof Weather Safeguard Tent',
          'cost': tentCost,
          'isSpecial': false,
        });
      }
    }

    // Balance check against estimatedTotalCost if target total is set
    double currentItemsSum = items.fold(0.0, (sum, item) => sum + (item['cost'] as double));
    if (proposal.estimatedTotalCost > 0 && (currentItemsSum - proposal.estimatedTotalCost).abs() > 0.01) {
      double diff = proposal.estimatedTotalCost - currentItemsSum;
      for (var item in items) {
        if ((item['label'] as String).contains('Sound') || (item['label'] as String).contains('Photography') || (item['label'] as String).contains('Decor')) {
          item['cost'] = (item['cost'] as double) + diff;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text("Itemized Package Breakdown:", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        ...items.map((item) {
          final costStr = (item['cost'] as double).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "${item['icon']} ${item['label']}".trim(), 
                    softWrap: true,
                    style: TextStyle(
                      color: item['isSpecial'] == true ? const Color(0xFF2563EB) : const Color(0xFF475569), 
                      fontSize: 11.5,
                      fontWeight: item['isSpecial'] == true ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['cost'] > 0 ? "LKR $costStr" : "Priced by Manager", 
                  style: TextStyle(
                    color: item['isSpecial'] == true ? const Color(0xFF2563EB) : const Color(0xFF0F172A), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}