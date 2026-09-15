import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signature/signature.dart';

class ProposalDetailsScreen extends StatefulWidget {
  const ProposalDetailsScreen({super.key});

  @override
  State<ProposalDetailsScreen> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalDetailsScreen> {
  bool _isSigned = false;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Event Proposal & Status", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: const Text("🟢 STATUS: APPROVED BY MANAGER", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            // AI Breakdown Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🤖 AI GENERATED BREAKDOWN", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 8),
                  Text("• Grand Palm Garden (Outdoor Lawn)", style: TextStyle(color: Colors.white70)),
                  Text("• Premium Dinner Buffet B (120 x Rs. 5,000) = Rs. 600,000", style: TextStyle(color: Colors.white70)),
                  Text("• Stage & Sound System Package = Rs. 150,000", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("⚠️ Weather Contingency:", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  Text("• Added Solution: Waterproof Marquee Tent = Rs. 150,000", style: TextStyle(color: Colors.white70)),
                  Divider(color: Colors.white12, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TOTAL AGREED AMOUNT:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Rs. 880,000", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (!_isSigned) ...[
              // Digital Signature Section (Wireframe Page 11 - Spec Device Feature)
              const Text("✍️ DRAW YOUR DIGITAL SIGNATURE", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _signatureController,
                  height: 140,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                      onPressed: () => _signatureController.clear(),
                      child: const Text("Clear Signature", style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                      onPressed: () {
                        setState(() {
                          _isSigned = true;
                        });
                      },
                      child: const Text("CONFIRM & ISSUE PASS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // QR Pass Section (Wireframe Page 6 - Spec Device Feature)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text("🎟️ OFFICIAL ENTRY PASS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text("Scan at venue gate entrance", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: "EVENTCRAFT|#EV-2026-99|Kasun|Confirmed",
                        version: QrVersions.auto,
                        size: 180.0,
                      ),
                      const SizedBox(height: 12),
                      const Text("Ref Code: #EV-2026-99", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}