import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signature/signature.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

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
    final Set<String> selectedCategories = {};
    final categories = [
      'Photography',
      'Decoration',
      'Sound & DJ',
      'Catering / Food',
      'Cake',
      'Transport',
      'Venue Rental',
      'Special Request',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Color(0xFFF43F5E), size: 24),
              SizedBox(width: 8),
              Text('Request Custom Revision', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select categories you want to adjust:',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: categories.map((cat) {
                    final isSel = selectedCategories.contains(cat);
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          if (isSel) {
                            selectedCategories.remove(cat);
                          } else {
                            selectedCategories.add(cat);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFF43F5E) : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? const Color(0xFFFB7185) : Colors.white12,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Describe your requested modifications in detail:',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g., Please reduce flower decor cost, reduce catering per plate, change cake size...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFF43F5E))),
                  ),
                ),
              ],
            ),
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
                String notes = controller.text.trim();
                if (selectedCategories.isNotEmpty) {
                  final catHeader = "[Categories: ${selectedCategories.join(', ')}]";
                  notes = notes.isNotEmpty ? "$catHeader $notes" : catHeader;
                }
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0F172A).withOpacity(0.12)),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 16),
              ),
            ),
            tooltip: 'Back',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),
        ),
        titleSpacing: 4,
        title: const Text(
          "Event Proposal & Status",
          style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2),
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
                      const Text("Failed to load proposal details.", style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text("Please check network or tap Retry below.", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
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
    final double effectiveTotalCost = _getEffectiveProposalTotal(proposal);
    final formattedCost = effectiveTotalCost.toStringAsFixed(0).replaceAllMapped(
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
                // Responsive Event Meta Info (Properly wrapped and constrained within card)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.people_alt_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      "${proposal.guestCount} Guests",
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Venue: ${proposal.venueName}",
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5, height: 1.3),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments_outlined, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Text(
                          "Proposal Total:",
                          style: TextStyle(color: Color(0xFF475569), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      "LKR $formattedCost",
                      style: const TextStyle(color: Color(0xFF059669), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
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
                          color: (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
                              ? const Color(0xFFDBEAFE)
                              : (isApproved || isConfirmed || proposal.status == 'PendingClientBudgetApproval' || proposal.status == 'ClientChoiceSubmitted'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
                                ? const Color(0xFF93C5FD)
                                : (isApproved || isConfirmed || proposal.status == 'PendingClientBudgetApproval' || proposal.status == 'ClientChoiceSubmitted'
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFCD34D)),
                          ),
                        ),
                        child: Text(
                          proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0
                            ? 'Allocated: LKR ${proposal.specialRequestAllocation!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                            : (isApproved || isConfirmed || proposal.status == 'PendingClientBudgetApproval' || proposal.status == 'ClientChoiceSubmitted'
                                ? '✓ Complimentary (Included)'
                                : '⏳ Pending Manager Costing'),
                          style: TextStyle(
                            color: (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
                                ? const Color(0xFF1E40AF)
                                : (isApproved || isConfirmed || proposal.status == 'PendingClientBudgetApproval' || proposal.status == 'ClientChoiceSubmitted'
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFFB45309)),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
                    final num rawSafeguardCost = wMap != null ? (wMap['SafeguardCost'] ?? wMap['safeguardCost'] ?? 0) : 0;
                    final String rawSafeguardName = wMap != null ? (wMap['Safeguard'] ?? wMap['safeguard'] ?? 'Waterproof Marquee Tent') : 'Waterproof Marquee Tent';

                    double resolvedTentCost = rawSafeguardCost.toDouble();
                    String resolvedTentLabel = rawSafeguardName.toString();
                    bool planExplicitlyChecked = false;
                    bool foundTentInPlan = false;

                    if (proposal.generatedPlan != null && proposal.generatedPlan!.isNotEmpty) {
                      try {
                        final dynamic decodedPlan = jsonDecode(proposal.generatedPlan!);
                        if (decodedPlan is List && decodedPlan.isNotEmpty) {
                          planExplicitlyChecked = true;
                          for (var rawLine in decodedPlan) {
                            final String s = rawLine.toString();
                            final String lower = s.toLowerCase();
                            if (lower.startsWith('no marquee tent') || lower.contains('safeguard waived')) {
                              foundTentInPlan = false;
                              resolvedTentCost = 0;
                              break;
                            }
                            if (!lower.startsWith('weather') &&
                                (lower.contains('marquee') || lower.contains('canopy') || lower.contains('hangar') || lower.contains('tent safeguard'))) {
                              final m = RegExp(r'=\s*(?:Rs\.|LKR)\s*(-?[\d,]+)|\((?:Rs\.|LKR|-Rs\.|-LKR)\s*(-?[\d,]+)\)').firstMatch(s);
                              if (m != null) {
                                final vStr = m.group(1) ?? m.group(2);
                                final parsed = double.tryParse(vStr?.replaceAll(',', '') ?? '');
                                if (parsed != null && parsed > 0) {
                                  resolvedTentCost = parsed;
                                  foundTentInPlan = true;
                                  resolvedTentLabel = s
                                      .replaceAll(RegExp(r'\((?:Rs\.|LKR)\s*[\d,]+\)'), '')
                                      .replaceAll(RegExp(r'\[Partner:.*?\]'), '')
                                      .trim();
                                  if (!isApproved && !isConfirmed && proposal.budgetLimit >= 2000000 && resolvedTentCost == 150000 &&
                                      (lower.contains('auto-injected') || lower.contains('aluminium'))) {
                                    resolvedTentCost = 350000;
                                    resolvedTentLabel = 'Air-Conditioned Transparent German Hangar Marquee (40x80 ft)';
                                  }
                                  break;
                                }
                              }
                            }
                          }
                          if (planExplicitlyChecked && !foundTentInPlan) {
                            resolvedTentCost = 0;
                          }
                        }
                      } catch (_) {}
                    }

                    if (isOut && (!planExplicitlyChecked || (!isApproved && !isConfirmed && proposal.budgetLimit >= 2000000 && resolvedTentCost == 150000)) && (resolvedTentCost > 0 || rainPct >= 60)) {
                      if (resolvedTentCost <= 0 || resolvedTentCost == 150000) {
                        if (proposal.budgetLimit >= 2000000) {
                          resolvedTentCost = 350000;
                          resolvedTentLabel = 'Air-Conditioned Transparent German Hangar Marquee (40x80 ft)';
                        } else if (proposal.budgetLimit >= 1200000) {
                          resolvedTentCost = 150000;
                          resolvedTentLabel = 'Heavy-Duty Waterproof Marquee Tent (20x40 ft)';
                        } else if (proposal.budgetLimit >= 700000) {
                          resolvedTentCost = 80000;
                          resolvedTentLabel = 'High-Peak Waterproof Stretch Canopy (20x30 ft)';
                        } else {
                          resolvedTentCost = 45000;
                          resolvedTentLabel = 'Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)';
                        }
                      }
                    }

                    final bool hasTent = isOut && resolvedTentCost > 0;
                    final String formattedTentCost = resolvedTentCost
                        .toStringAsFixed(0)
                        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

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
                            Text("• Safeguard: None needed (Indoor weather-sheltered venue).", 
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
                            Text("• Safeguard: $resolvedTentLabel (Rs. $formattedTentCost).", 
                              softWrap: true,
                              style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600)),
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
                            const Text("• Safeguard: Not needed.", 
                              softWrap: true,
                              style: TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }
                  },
                ),
                _buildItemizedBreakdown(proposal),
                const Divider(color: Color(0xFFE2E8F0), height: 24),
                Builder(
                  builder: (context) {
                    final bool isOverBudget = proposal.budgetLimit > 0 && proposal.estimatedTotalCost > proposal.budgetLimit;
                    final double overrunDiff = isOverBudget ? (proposal.estimatedTotalCost - proposal.budgetLimit) : 0.0;
                    final String formattedOverrun = overrunDiff.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    );

                    final String totalLabel = isConfirmed 
                      ? "FINAL AGREED AMOUNT:" 
                      : (isApproved 
                          ? "MANAGER PROPOSED TOTAL:" 
                          : (proposal.status == 'RevisionRequested' 
                              ? "ESTIMATED TOTAL (UNDER REVISION):" 
                              : (isChoiceSubmitted 
                                  ? "SUBMITTED CLIENT CHOICE TOTAL:" 
                                  : "ESTIMATED AI PROPOSAL TOTAL:")));

                    final Color costColor = (isConfirmed || isApproved)
                        ? const Color(0xFF059669)
                        : (isOverBudget ? const Color(0xFFD97706) : const Color(0xFF059669));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                totalLabel,
                                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ),
                            Text(
                              "LKR $formattedCost",
                              style: TextStyle(color: costColor, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        ),
                        if (proposal.budgetLimit > 0) ...[
                          const SizedBox(height: 8),
                          if (isOverBudget)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFCD34D)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
                                        children: [
                                          const TextSpan(text: "Exceeds Stated Budget by "),
                                          TextSpan(
                                            text: "+LKR $formattedOverrun",
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                                          ),
                                          TextSpan(
                                            text: " (Budget: LKR $formattedBudget)",
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF059669)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Fits within your stated budget limit (LKR $formattedBudget)",
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF065F46), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Client Action & Revision Section (Accessible during review phase)
          if (!isApproved && !isConfirmed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: proposal.status == 'RevisionRequested' 
                      ? const Color(0xFFFDA4AF) 
                      : isChoiceSubmitted
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFFCBD5E1),
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (proposal.status == 'RevisionRequested') ...[
                    Row(
                      children: [
                        const Icon(Icons.mark_chat_read, color: Color(0xFFE11D48), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Revision Request Submitted to Manager",
                            style: TextStyle(color: Color(0xFF9F1239), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Under Review", style: TextStyle(color: Color(0xFFBE123C), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Your Notes: \"${proposal.revisionNotes ?? 'Revision requested'}\"\n\nHotel Operations Manager has been notified on the Web Portal to review your requested adjustments.",
                        style: const TextStyle(color: Color(0xFF881337), fontSize: 12, height: 1.35),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRevisionDialog(proposal),
                        icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFE11D48)),
                        label: const Text("Update Revision Notes", style: TextStyle(fontSize: 12, color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFDA4AF)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ] else if (isChoiceSubmitted) ...[
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Proposal Agreement Submitted",
                            style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF6EE7B7)),
                          ),
                          child: const Text(
                            "✓ Agreed",
                            style: TextStyle(color: Color(0xFF047857), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You have officially agreed to this proposal (LKR $formattedCost). The Hotel Operations Manager has been notified to give final confirmation and unlock your bank deposit slip.",
                              style: const TextStyle(color: Color(0xFF065F46), fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRevisionDialog(proposal),
                        icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF64748B)),
                        label: const Text("Need Modifications Instead? Request Changes", style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Row(
                      children: [
                        Icon(Icons.touch_app_rounded, color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Client Review & Action Options",
                          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              final ok = await ApiService.submitClientBudgetChoice(widget.eventId, 'ClientChoiceSubmitted', effectiveTotalCost);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok 
                                        ? "✓ Agreement submitted! Manager has been notified to finalize your proposal." 
                                        : "✓ Agreement submitted to manager."),
                                    backgroundColor: const Color(0xFF059669),
                                  ),
                                );
                                _loadProposal();
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                            label: const Text("Agree to Proposal", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showRevisionDialog(proposal),
                            icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFE11D48)),
                            label: const Text("Request Changes", style: TextStyle(fontSize: 11.5, color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFDA4AF)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // 4. Bank Transfer & Payment Slip Section
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

  double _getEffectiveProposalTotal(EventProposalDetail proposal) {
    final res = _resolveBreakdownItems(proposal);
    final bool wasLegacyUpgraded = res['wasLegacyUpgraded'] == true;
    final List<Map<String, dynamic>> items = res['items'] as List<Map<String, dynamic>>;
    if (wasLegacyUpgraded) {
      return items.fold(0.0, (acc, it) => acc + ((it['cost'] as num?)?.toDouble() ?? 0.0));
    }
    if (proposal.estimatedTotalCost > 0) {
      return proposal.estimatedTotalCost;
    }
    return items.fold(0.0, (acc, it) => acc + ((it['cost'] as num?)?.toDouble() ?? 0.0));
  }

  Map<String, dynamic> _resolveBreakdownItems(EventProposalDetail proposal) {
    final List<Map<String, dynamic>> items = [];
    bool wasLegacyUpgraded = false;

    if (proposal.generatedPlan != null && proposal.generatedPlan!.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(proposal.generatedPlan!);
        if (decoded is List) {
          for (var rawItem in decoded) {
            final str = rawItem.toString();
            if (str.startsWith('Weather Assessment') || str.startsWith('No Marquee Tent') || str.startsWith('Event Session') || str.startsWith('Weather Forecast')) {
              continue;
            }

            final bool isDiscount = str.toLowerCase().contains('discount') || str.contains('-Rs.') || str.contains('- LKR') || str.contains('(-Rs.');

            // Prioritize '=' match first (which represents the item total e.g. '= Rs. 1,300,000')
            final eqMatch = RegExp(r'=\s*(?:Rs\.|LKR)\s*(-?[\d,]+)').firstMatch(str);
            final match = eqMatch ?? RegExp(r'\((?:[^)]*?(?:Rs\.|LKR|-Rs\.|-LKR))\s*(-?[\d,]+)\)|(-Rs\.|-LKR)\s*([\d,]+)').firstMatch(str);

            if (match != null) {
              final valStr = eqMatch != null 
                  ? eqMatch.group(1) 
                  : (match.group(1) ?? match.group(2) ?? match.group(3));
              double cost = double.tryParse(valStr?.replaceAll(',', '') ?? '') ?? 0.0;
              if (isDiscount && cost > 0) {
                cost = -cost;
              }

              String label;
              if (eqMatch != null) {
                // If matched by '=', label is everything before '='
                label = str.split('=').first.trim();
              } else {
                label = str
                    .replaceAll(RegExp(r'\((?:[^)]*?(?:Rs\.|LKR|-Rs\.|-LKR))\s*-?[\d,]+\)'), '')
                    .replaceAll(RegExp(r'(-Rs\.|-LKR)\s*[\d,]+'), '')
                    .trim();
              }

              if (label.startsWith('Catering Style:')) {
                label = label.replaceFirst('Catering Style:', '').trim();
              }

              final bool isUnfinalized = proposal.status != 'ApprovedByManager' && proposal.status != 'Confirmed';
              if (isUnfinalized && proposal.budgetLimit >= 2000000) {
                final String lowerLabel = label.toLowerCase();
                if (lowerLabel.contains('auto-injected') || lowerLabel.contains('aluminium marquee')) {
                  label = 'Air-Conditioned Transparent German Hangar Marquee (40x80 ft) [Partner: Grand Royal German Hangar Marquees]';
                  cost = 350000.0;
                } else if (cost == 200000 && lowerLabel.contains('royal fresh flower')) {
                  cost = 220000.0;
                }
              }

              items.add({
                'label': label,
                'cost': cost,
                'isDiscount': isDiscount,
                'isSpecial': label.toLowerCase().contains('special client request'),
              });
            }
          }

          // Prepend Venue Rental if not already in items
          final hasVenue = items.any((it) => it['label'].toString().toLowerCase().contains('rental') || it['label'].toString().toLowerCase().contains('venue'));
          if (!hasVenue) {
            final bool isPrivateOrCustomVenue = (proposal.banquetHallName == null || proposal.banquetHallName!.isEmpty) && (proposal.hallRentalPrice == null || proposal.hallRentalPrice == 0);
            String venueTitle = proposal.venueName.isNotEmpty ? proposal.venueName : "Selected Venue";
            if (proposal.banquetHallName != null && proposal.banquetHallName!.isNotEmpty) {
              venueTitle = proposal.banquetHallName!;
            }
            final double hallPrice = isPrivateOrCustomVenue ? 0.0 : (proposal.hallRentalPrice ?? 350000.0);
            if (hallPrice > 0 || !isPrivateOrCustomVenue) {
              items.insert(0, {
                'label': '$venueTitle Rental',
                'cost': hallPrice,
                'isDiscount': false,
                'isSpecial': false,
              });
            }
          }

          // Append Special Client Request if missing
          final hasSpecial = items.any((it) => it['isSpecial'] == true || it['label'].toString().toLowerCase().contains('special client request'));
          if (!hasSpecial && proposal.additionalDetails != null && proposal.additionalDetails!.trim().isNotEmpty) {
            final double specialCost = (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
                ? proposal.specialRequestAllocation!.toDouble()
                : 0.0;
            items.add({
              'label': 'Special Client Request: ${proposal.additionalDetails}',
              'cost': (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
                  ? proposal.specialRequestAllocation!.toDouble()
                  : 0.0,
              'isDiscount': false,
              'isSpecial': true,
            });
          }
        }
      } catch (_) {}
    }

    if (items.isEmpty) {
      if (proposal.isOutdoor) {
        double tentCost = 45000.0;
        String tentLabel = 'Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)';
        if (proposal.budgetLimit >= 2000000) {
          tentCost = 350000.0;
          tentLabel = 'Air-Conditioned Transparent German Hangar Marquee (40x80 ft) [Partner: Grand Royal German Hangar Marquees]';
        } else if (proposal.budgetLimit >= 1200000) {
          tentCost = 150000.0;
          tentLabel = 'Heavy-Duty Waterproof Marquee Tent (20x40 ft) [Partner: Ceylon WeatherShield Marquee Tents]';
        } else if (proposal.budgetLimit >= 700000) {
          tentCost = 80000.0;
          tentLabel = 'High-Peak Waterproof Stretch Canopy (20x30 ft) [Partner: SunShade Canopies & Pergolas Colombo]';
        }
        items.add({
          'label': tentLabel,
          'cost': tentCost,
          'isDiscount': false,
          'isSpecial': false,
        });
      }

      final bool isPrivateOrCustomVenue = (proposal.banquetHallName == null || proposal.banquetHallName!.isEmpty) && (proposal.hallRentalPrice == null || proposal.hallRentalPrice == 0);
      final double hallPrice = isPrivateOrCustomVenue ? 0.0 : (proposal.hallRentalPrice ?? 350000.0);
      String venueTitle = proposal.venueName.isNotEmpty ? proposal.venueName : "Selected Venue";
      if (proposal.banquetHallName != null && proposal.banquetHallName!.isNotEmpty) {
        venueTitle = proposal.banquetHallName!;
      }
      double cateringPrice = (proposal.perPlatePrice ?? 5200.0) * proposal.guestCount;

      if (hallPrice > 0 || !isPrivateOrCustomVenue) {
        items.add({
          'label': '$venueTitle Rental',
          'cost': hallPrice,
          'isDiscount': false,
          'isSpecial': false,
        });
      }

      items.add({
        'label': 'Banquet Catering Buffet (Rs. ${(proposal.perPlatePrice ?? 5200.0).toStringAsFixed(0)}/guest)',
        'cost': cateringPrice,
        'isDiscount': false,
        'isSpecial': false,
      });

      for (var s in proposal.selectedServices) {
        String desc = s;
        double cost = 100000;
        if (s.toLowerCase().contains('photo')) {
          if (proposal.budgetLimit >= 2000000) {
            desc = 'Royal Cinematic Rig + Drone + 3 Senior Photographers';
            cost = 180000.0;
          } else if (proposal.budgetLimit >= 1200000) {
            desc = 'Cinematic 4K Rig + Drone Coverage + 2 Photographers';
            cost = 120000.0;
          } else {
            desc = 'Professional Event Photography & Coverage';
            cost = 100000.0;
          }
        } else if (s.toLowerCase().contains('sound') || s.toLowerCase().contains('light')) {
          if (proposal.budgetLimit >= 2000000) {
            desc = 'Concert Line-Array Rig + 16 Moving Heads + Beam Trusses';
            cost = 250000.0;
          } else if (proposal.budgetLimit >= 1200000) {
            desc = 'Concert Line-Array Sound & Digital Mixer Package';
            cost = 180000.0;
          } else if (proposal.budgetLimit >= 700000) {
            desc = 'Standard Stage Audio + Warm Ambient LED PAR Cans';
            cost = 85000.0;
          } else {
            desc = 'Compact Speech PA Kit + 2 Wireless Mics';
            cost = 40000.0;
          }
        } else if (s.toLowerCase().contains('deco')) {
          if (proposal.budgetLimit >= 2000000) {
            desc = 'Royal Fresh Flower Ceiling Drapes & Grand Stage Decor';
            cost = 220000.0;
          } else if (proposal.budgetLimit >= 1200000) {
            desc = 'Thematic Floral Stage + Entrance Tunnel Arch';
            cost = 140000.0;
          } else if (proposal.budgetLimit >= 700000) {
            desc = 'Thematic Floral Stage + Table Centerpieces';
            cost = 85000.0;
          } else {
            desc = 'Minimalist Floral Arch + Cake Table Styling';
            cost = 45000.0;
          }
        } else if (s.toLowerCase().contains('cake')) {
          if (proposal.budgetLimit >= 2000000) {
            desc = '5-Tier Royal Handcrafted Fondant Wedding Cake';
            cost = 65000.0;
          } else if (proposal.budgetLimit >= 1200000) {
            desc = '3-Tier Luxury Floral Wedding Cake';
            cost = 45000.0;
          } else if (proposal.budgetLimit >= 700000) {
            desc = '2-Tier Custom Handcrafted Fondant Cake';
            cost = 30000.0;
          } else {
            desc = '2-Tier Classic Buttercream Celebration Cake';
            cost = 15000.0;
          }
        } else if (s.toLowerCase().contains('transport') || s.toLowerCase().contains('car') || s.toLowerCase().contains('bridal')) {
          if (proposal.budgetLimit >= 2000000) {
            desc = 'Classic Vintage Rolls Royce / 1954 Jaguar Mark VII';
            cost = 95000.0;
          } else if (proposal.budgetLimit >= 1200000) {
            desc = 'Mercedes-Benz S-Class Luxury Chauffeur Sedan';
            cost = 65000.0;
          } else if (proposal.budgetLimit >= 700000) {
            desc = 'BMW 5-Series Executive Bridal Sedan';
            cost = 50000.0;
          } else {
            desc = 'Toyota Premio / Allion Executive Chauffeur Sedan';
            cost = 35000.0;
          }
        }
        items.add({
          'label': desc,
          'cost': cost,
          'isDiscount': false,
          'isSpecial': false,
        });
      }

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

          items.add({
            'label': '$r (Rs. ${rCostPerHead.toStringAsFixed(0)}/guest)',
            'cost': rCostPerHead * proposal.guestCount,
            'isDiscount': false,
            'isSpecial': false,
          });
        }
      }

      if (proposal.additionalDetails != null && proposal.additionalDetails!.trim().isNotEmpty) {
        final double specialCost = (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
            ? proposal.specialRequestAllocation!.toDouble()
            : 0.0;
        items.add({
          'label': 'Special Client Request: ${proposal.additionalDetails}',
          'cost': (proposal.specialRequestAllocation != null && proposal.specialRequestAllocation! > 0)
              ? proposal.specialRequestAllocation!.toDouble()
              : 0.0,
          'isDiscount': false,
          'isSpecial': true,
        });
      }
    }

    // Exact Synchronized Balance Guardrail between breakdown items and proposal.estimatedTotalCost
    if (!wasLegacyUpgraded && proposal.estimatedTotalCost > 0) {
      double currentSum = items.fold(0.0, (acc, it) => acc + ((it['cost'] as num?)?.toDouble() ?? 0.0));
      final double diff = currentSum - proposal.estimatedTotalCost;
      if (diff > 100 && !items.any((it) => it['isDiscount'] == true)) {
        items.add({
          'label': 'Manager Courtesy Discount',
          'cost': -diff,
          'isDiscount': true,
          'isSpecial': false,
        });
      } else if (diff < -100 && !items.any((it) => it['isSpecial'] == true)) {
        items.add({
          'label': 'Special Custom Add-ons / Manager Allocation',
          'cost': -diff,
          'isDiscount': false,
          'isSpecial': true,
        });
      }
    }

    return {
      'items': items,
      'wasLegacyUpgraded': wasLegacyUpgraded,
    };
  }

  Widget _buildItemizedBreakdown(EventProposalDetail proposal) {
    final res = _resolveBreakdownItems(proposal);
    final List<Map<String, dynamic>> items = res['items'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text("Itemized Package Breakdown:", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        ...items.map((item) {
          final double cost = ((item['cost'] as num?)?.toDouble() ?? 0.0);
          final bool isDiscount = item['isDiscount'] == true || cost < 0;
          final costStr = cost.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
          final isPendingSpecial = item['isSpecial'] == true && cost <= 0;

          final String rawLabel = item['label'].toString().trim();
          String mainLabel = rawLabel;
          String? partnerName;

          // Extract partner tag e.g. [Partner: Royal Blooms Floral & Botanical Artistry] or (Partner: ...)
          final partnerMatch = RegExp(r'\[Partner:\s*([^\]]+)\]|\(Partner:\s*([^)]+)\)', caseSensitive: false).firstMatch(rawLabel);
          if (partnerMatch != null) {
            partnerName = (partnerMatch.group(1) ?? partnerMatch.group(2))?.trim();
            mainLabel = rawLabel
                .replaceAll(RegExp(r'\[Partner:\s*[^\]]+\]|\(Partner:\s*[^)]+\)', caseSensitive: false), '')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
          }

          // Extract guest rate tags to display neatly UNDER the item (e.g. (Rs. 5,000/guest))
          String? guestRate;
          final guestRateMatch = RegExp(
            r'\(\s*(?:(?:\d+\s*[Gg]uests?\s*(?:@|at)\s*(?:Rs\.?|LKR)?\s*([\d,]+))|(?:(?:Rs\.?|LKR)?\s*([\d,]+)\s*(?:\/|\s*per\s*)(?:guest|plate)))\s*\)',
            caseSensitive: false,
          ).firstMatch(mainLabel);

          if (guestRateMatch != null) {
            final rateVal = (guestRateMatch.group(1) ?? guestRateMatch.group(2))?.trim();
            if (rateVal != null && rateVal.isNotEmpty) {
              guestRate = '(Rs. $rateVal/guest)';
              mainLabel = mainLabel.replaceFirst(guestRateMatch.group(0)!, '').replaceAll(RegExp(r'\s+'), ' ').trim();
            }
          } else if (proposal.guestCount > 0 && cost > 0) {
            final lower = mainLabel.toLowerCase();
            if (lower.contains('catering') || lower.contains('buffet') || lower.contains('refreshment') || lower.contains('canapé') || lower.contains('mocktail')) {
              final double perHead = cost / proposal.guestCount;
              if (perHead >= 50 && perHead <= 25000) {
                final formatted = NumberFormat('#,##0', 'en_US').format(perHead.round());
                guestRate = '(Rs. $formatted/guest)';
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainLabel,
                        softWrap: true,
                        style: TextStyle(
                          color: isDiscount 
                              ? const Color(0xFF16A34A) 
                              : (item['isSpecial'] == true ? const Color(0xFF2563EB) : const Color(0xFF334155)), 
                          fontSize: 11.5,
                          fontWeight: (item['isSpecial'] == true || isDiscount) ? FontWeight.w600 : FontWeight.normal,
                          height: 1.25,
                        ),
                      ),
                      if (guestRate != null && guestRate.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          guestRate,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                      if (partnerName != null && partnerName.isNotEmpty) ...[
                        const SizedBox(height: 3.5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 11,
                                color: Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "Partner: $partnerName",
                                  style: const TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isDiscount 
                      ? "- LKR $costStr" 
                      : (cost > 0 
                          ? "LKR $costStr" 
                          : (item['isSpecial'] == true 
                              ? (proposal.isConfirmed || proposal.status == 'Confirmed' || proposal.status == 'ApprovedByManager' || proposal.status == 'PendingClientBudgetApproval' || proposal.status == 'ClientChoiceSubmitted'
                                  ? "✓ Complimentary (LKR 0)" 
                                  : "⏳ Pending Manager Costing") 
                              : "Priced by Manager")), 
                  style: TextStyle(
                    color: isDiscount 
                        ? const Color(0xFF16A34A) 
                        : (item['isSpecial'] == true 
                            ? (proposal.isConfirmed || proposal.status == 'Confirmed' || proposal.status == 'ApprovedByManager' || proposal.status == 'PendingClientBudgetApproval' || proposal.status == 'ClientChoiceSubmitted'
                                ? const Color(0xFF16A34A) 
                                : const Color(0xFFB45309))
                            : const Color(0xFF0F172A)), 
                    fontWeight: FontWeight.bold, 
                    fontSize: isPendingSpecial ? 11.0 : 11.5,
                    fontStyle: isPendingSpecial ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          );
        }),
        if (items.any((it) => it['isSpecial'] == true && ((it['cost'] as num?)?.toDouble() ?? 0.0) <= 0)) ...[
          const SizedBox(height: 6),
          const Text(
            "* Note: Special client requests are reviewed and quoted by the Hotel Manager upon final proposal approval.",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}