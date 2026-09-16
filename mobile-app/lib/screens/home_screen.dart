import 'package:flutter/material.dart';
import 'create_event_screen.dart';
import 'proposal_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Theme from wireframe
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👋 Welcome back, Kasun!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('"Your peaceful escape"', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Action Card
            const Text("⚡ QUICK ACTION", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen()));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.cyan, size: 28),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("+ Create New Event Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("Plan your next gathering with AI assistance", style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Event Request Card (Wireframe Page 2)
            const Text("📊 ACTIVE EVENT REQUEST", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🎪 TechCraft 10th Anniversary Dinner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text("📅 Date: Nov 15, 2026  |  👥 Guests: 120", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text("💰 Budget: Rs. 1,000,000", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Divider(color: Colors.white12, height: 20),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: const Text("🟡 STATUS: UNDER MANAGER REVIEW", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),

                  // AI Weather Risk Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🤖 AI Summary:", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 4),
                        Text("• Outdoor package selected", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("• ⚠️ Weather Alert: 70% Rain forecast", style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("• 🎪 Marquee Tent added to proposal", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProposalDetailsScreen()));
                      },
                      child: const Text("View Full Proposal & Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}