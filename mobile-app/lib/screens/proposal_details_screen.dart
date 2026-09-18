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
          content: Text("🎉 Bank slip submitted! Manager has been notified for verification."),
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
            content: Text("🎉 Contract Signed & QR Pass Issued!"),
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Event Proposal & Status", style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyan),
            onPressed: _loadProposal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
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
    final isPendingBudgetApproval = proposal.status == 'PendingClientBudgetApproval' || (proposal.estimatedTotalCost > proposal.budgetLimit && !isConfirmed && !isApproved);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Header
          if (isConfirmed)
            _buildBadge("✅ STATUS: BOOKING CONFIRMED & PASS ISSUED", Colors.green, Colors.greenAccent)
          else if (isPendingBudgetApproval)
            _buildBadge("🟣 STATUS: MANAGER RECOMMENDATION (BUDGET OVERRUN)", const Color(0xFF818CF8), const Color(0xFFA5B4FC))
          else if (isApproved) ...[
            if (proposal.paymentStatus == 'Completed' || proposal.paymentStatus == 'Approved')
              _buildBadge("🟢 PAYMENT VERIFIED: READY TO SIGN & ISSUE PASS", Colors.green, Colors.greenAccent)
            else if (proposal.paymentStatus == 'PendingVerification')
              _buildBadge("🟡 PAYMENT SLIP UNDER MANAGER VERIFICATION", Colors.amber, Colors.amberAccent)
            else
              _buildBadge("💳 PROPOSAL APPROVED: AWAITING PAYMENT DEPOSIT", const Color(0xFFD4AF37), const Color(0xFFD4AF37)),
          ] else
            _buildBadge("🟡 STATUS: UNDER MANAGER REVIEW", Colors.amber, Colors.amber),

          const SizedBox(height: 16),

          // 2. Event Title & Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(proposal.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: proposal.isOutdoor ? Colors.amber.withOpacity(0.15) : Colors.cyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: proposal.isOutdoor ? Colors.amber : Colors.cyan),
                      ),
                      child: Text(
                        proposal.isOutdoor ? '🌳 Outdoor' : '🏛️ Indoor',
                        style: TextStyle(
                          color: proposal.isOutdoor ? Colors.amber : Colors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("📅 Date: $formattedDate", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text("👥 Guests: ${proposal.guestCount}  |  📍 Venue: ${proposal.venueName}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text("💰 Customer Budget: LKR $formattedBudget", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Manager Recommendation & Budget Overrun Review Card
          if (proposal.estimatedTotalCost > proposal.budgetLimit && !isConfirmed) ...[
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
                          "👔 HOTEL MANAGER'S RECOMMENDATION",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text(
                          "Action Required",
                          style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
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
                    ),
                  ),
                  const SizedBox(height: 14),
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
                        final ok = await ApiService.acceptOverrunAndApprove(widget.eventId, proposal.estimatedTotalCost);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok 
                                  ? "✓ Premium package accepted! Please proceed to upload your payment deposit slip below." 
                                  : "✓ Accept request submitted to manager."),
                              backgroundColor: Colors.indigo,
                            ),
                          );
                          _loadProposal();
                        }
                      },
                      icon: const Icon(Icons.verified, size: 16, color: Colors.white),
                      label: Text("💎 Accept Premium Package (LKR $formattedCost)", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
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
                        final ok = await ApiService.requestBudgetAutoFit(widget.eventId);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? "⚡ Proposal auto-fitted to your LKR $formattedBudget budget! Optional packages adjusted."
                                  : "⚡ Request submitted to manager for budget auto-fit."),
                              backgroundColor: Colors.teal,
                            ),
                          );
                          _loadProposal();
                        }
                      },
                      icon: const Icon(Icons.bolt, size: 16, color: Colors.amberAccent),
                      label: Text("⚡ Request Budget-Fit Standard Package (LKR $formattedBudget)", style: const TextStyle(fontSize: 11.5, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.amberAccent),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
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
                color: const Color(0xFFE11D48).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE11D48).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('💐', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SPECIAL CLIENT REQUESTS & ADD-ONS',
                          style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        'Budget: LKR 35,000',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    proposal.additionalDetails!,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.photo_library, color: Color(0xFFD4AF37), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Inspiration Photos (${proposal.inspirationImages.length})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                            border: Border.all(color: Colors.white24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(img.split(',').last),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white38),
                                  )
                                : Image.network(
                                    img,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white38),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 18),
                    SizedBox(width: 8),
                    Text("AI AGENTIC BREAKDOWN & SAFEGUARD", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Text("• Venue: ${proposal.venueName}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text("• Catering & Resources: Optimized for ${proposal.guestCount} guests", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
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

                    if (!isOut) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shield_rounded, color: Colors.greenAccent, size: 16),
                                SizedBox(width: 6),
                                Text("Weather Assessment: 0% Risk (Indoor Venue)", 
                                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text("• Indoor Climate-Controlled Banquet Hall. Zero weather risk.", 
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text("• Safeguard: None required. Saved Rs. 150,000 marquee tent cost.", 
                              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    } else if (hasTent) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF78350F).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cloud_sync_rounded, color: Colors.orangeAccent, size: 16),
                                const SizedBox(width: 6),
                                Text("Weather Assessment: $rainPct% Rain Risk ($cond)", 
                                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text("• Outdoor Monsoon contingency safeguard applied.", 
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                            const Text("• Safeguard: Waterproof Marquee Tent Included (Rs. 150,000).", 
                              style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C4A6E).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.wb_sunny_rounded, color: Colors.amberAccent, size: 16),
                                const SizedBox(width: 6),
                                Text("Weather Forecast: $rainPct% Rain Risk ($cond)", 
                                  style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text("• Dry favorable outdoor forecast. No heavy precipitation expected.", 
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                            const Text("• Safeguard: Not required. Saved Rs. 150,000 marquee tent cost.", 
                              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }
                  },
                ),
                if (proposal.selectedServices.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text("📦 Selected Packages & Services:", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  ...proposal.selectedServices.map((s) {
                    IconData ic = Icons.check_circle_outline;
                    String desc = s;
                    if (s.toLowerCase().contains('photo')) {
                      ic = Icons.camera_alt_rounded;
                      desc = "In-House Photography & Cinematography Coverage";
                    } else if (s.toLowerCase().contains('sound') || s.toLowerCase().contains('light')) {
                      ic = Icons.speaker_rounded;
                      desc = "Concert Line-Array Sound & Intelligent Lighting Rig";
                    } else if (s.toLowerCase().contains('deco')) {
                      ic = Icons.park_rounded;
                      desc = "Floral Stage Styling & Theme Decoration";
                    } else if (s.toLowerCase().contains('cake')) {
                      ic = Icons.cake_rounded;
                      desc = "$s (Handcrafted Celebration Tier)";
                    } else if (s.toLowerCase().contains('transport') || s.toLowerCase().contains('car') || s.toLowerCase().contains('bridal')) {
                      ic = Icons.directions_car_rounded;
                      desc = "Luxury Chauffeur-Driven Bridal Car / VIP Transport";
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(ic, size: 13, color: const Color(0xFFD4AF37)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const Divider(color: Colors.white12, height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("FINAL AGREED AMOUNT:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("LKR $formattedCost", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
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
                    const Text("🎟️ OFFICIAL EVENT ENTRY PASS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
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
                          color: const Color(0xFF064E3B).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "PAYMENT VERIFIED: SIGN CONTRACT TO MINT ENTRY PASS",
                                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    "Finance Manager approved your payment (Invoice: ${proposal.invoiceNumber ?? 'INV-PAID'}). Draw your signature below to legally execute the agreement and receive your QR Entry Pass.",
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "✍️ DRAW YOUR DIGITAL SIGNATURE TO CONFIRM",
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
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
                                side: const BorderSide(color: Colors.white24),
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
                                backgroundColor: Colors.green.shade600,
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
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.lock_person_rounded, color: Color(0xFFD4AF37), size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          "🔒 Digital Signature Locked (Payment Required)",
                          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPendingVerification
                              ? "Your bank transfer slip has been uploaded and is currently in the Manager's verification queue. This signature pad and your QR Entry Pass will unlock as soon as your payment is approved."
                              : "Please transfer the required total (LKR $formattedCost) to our Commercial Bank account above and upload your deposit slip. Once our Finance Manager approves the transaction on the Web Dashboard, this pad will unlock automatically.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPendingVerification ? Icons.hourglass_top : Icons.pending_actions,
                                size: 14,
                                color: isPendingVerification ? Colors.amberAccent : Colors.white60,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPendingVerification
                                    ? "Step 2: Awaiting Manager Slip Verification"
                                    : "Step 1: Upload Bank Transfer Slip Above",
                                style: TextStyle(
                                  color: isPendingVerification ? Colors.amberAccent : Colors.white60,
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
            // Under Review Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.hourglass_top, color: Colors.amber, size: 36),
                  SizedBox(height: 8),
                  Text("Awaiting Manager Approval", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    "Our AI Multi-Agent system has crafted the preliminary plan. The Event Operations Manager is currently reviewing packages, vendor availability, and final pricing on the Web Portal. Please check back shortly!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.6)),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPaymentSlipSection(EventProposalDetail proposal, String formattedCost) {
    final isPaid = proposal.paymentStatus == 'Completed' || proposal.paymentStatus == 'Approved';
    final isPendingReview = proposal.paymentStatus == 'PendingVerification';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? const Color(0xFF10B981)
              : (isPendingReview ? const Color(0xFFF59E0B) : const Color(0xFFD4AF37)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: isPaid ? const Color(0xFF10B981) : const Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "BANK TRANSFER & PAYMENT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.2)
                      : (isPendingReview ? Colors.amber.withOpacity(0.2) : const Color(0xFFD4AF37).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPaid
                      ? "🟢 VERIFIED & SETTLED"
                      : (isPendingReview ? "🟡 SLIP UNDER REVIEW" : "PENDING PAYMENT"),
                  style: TextStyle(
                    color: isPaid
                        ? Colors.greenAccent
                        : (isPendingReview ? Colors.amberAccent : const Color(0xFFD4AF37)),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bank Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Official Deposit Account:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Bank:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Commercial Bank of Ceylon", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Account Name:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("EventCraft Pvt Ltd", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Account Number:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("8001234567", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Branch / SWIFT:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Colombo City Branch (CCEYLKLX)", style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const Divider(color: Colors.white12, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Required Amount:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text("LKR $formattedCost", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                if (proposal.invoiceNumber != null && proposal.invoiceNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tax Invoice Number:", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      Text(proposal.invoiceNumber!, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11)),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Slip Verified & Approved",
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          "Official Invoice ${proposal.invoiceNumber ?? 'INV-PAID'} issued. All vendor contracts activated.",
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
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
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, color: Colors.amberAccent, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Deposit Slip Under Verification",
                          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Your bank transfer slip was received and is in the Operations Manager's verification queue. You will receive invoice confirmation once cleared.",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  if (proposal.slipImageUrl != null && proposal.slipImageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.black26,
                        child: proposal.slipImageUrl!.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(proposal.slipImageUrl!.split(',').last),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white30),
                              )
                            : Image.network(
                                proposal.slipImageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white30),
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
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4AF37)),
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
                            icon: const Icon(Icons.refresh, size: 14, color: Colors.white70),
                            label: const Text("Change Slip", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploadingSlip ? null : _submitPaymentSlip,
                            icon: _isUploadingSlip
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : const Icon(Icons.cloud_upload_rounded, size: 14, color: Colors.black),
                            label: Text(
                              _isUploadingSlip ? "Uploading..." : "Submit Slip",
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
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
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.upload_file_rounded, color: Color(0xFFD4AF37), size: 18),
                  label: const Text(
                    "Upload Bank Deposit / Transfer Slip",
                    style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Attach JPG/PNG payment confirmation. Manager will verify within 1 hour.",
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ],
        ],
      ),
    );
  }
}