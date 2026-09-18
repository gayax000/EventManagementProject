import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_event_screen.dart';
import 'proposal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Toggle between active proposal and empty state for demonstration
  bool _hasActiveEvents = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        toolbarHeight: 74,
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text("👋 ", style: TextStyle(fontSize: 16)),
                      Flexible(
                        child: Text(
                          "Welcome back, Dimalka Shalintha!",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "EventCraft AI Experience",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF38BDF8), // Cyan Accent
                    ),
                  ),
                ],
              ),
            ),
            // Sleek Logout Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 20),
                tooltip: "Logout",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Session active • Dimalka Shalintha"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // HERO: CREATE NEW EVENT REQUEST BUTTON CARD
            // ==========================================
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00C6FF), // Electric Cyan
                    Color(0xFF0072FF), // Vibrant Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0072FF).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                    child: Row(
                      children: [
                        // Frosted Glass Circular Plus Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title and AI Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Create New Event Request",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Plan your next event with AI Multi-Agents",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chevron Arrow Icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==========================================
            // SECTION: ACTIVE EVENT REQUESTS HEADER
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ACTIVE EVENT REQUESTS",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                // Demo State Switcher
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasActiveEvents = !_hasActiveEvents;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      _hasActiveEvents ? "View Empty State" : "View Active Card",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ==========================================
            // ACTIVE PROPOSAL OR EMPTY STATE
            // ==========================================
            if (!_hasActiveEvents) ...[
              // Empty State matching screenshot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Calendar icon with X
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(
                        Icons.event_busy_rounded,
                        color: Colors.white38,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No active events found",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Create a new event above to trigger AI agent orchestration.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Active Event Request Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.festival_rounded, color: Color(0xFF38BDF8), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "TechCraft 10th Anniversary Dinner",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick Specs
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSpecItem(Icons.calendar_today_rounded, "Nov 15, 2026"),
                          Container(width: 1, height: 16, color: Colors.white12),
                          _buildSpecItem(Icons.people_alt_rounded, "120 Guests"),
                          Container(width: 1, height: 16, color: Colors.white12),
                          _buildSpecItem(Icons.payments_rounded, "Rs. 1,000,000"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "STATUS: UNDER MANAGER REVIEW",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // AI Weather Risk Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1329),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "AI Autonomous Summary",
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF38BDF8),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint("Outdoor package selected (Grand Palm Garden)"),
                          const SizedBox(height: 4),
                          _buildBulletPoint(
                            "⚠️ Weather Alert: 70% Rain forecast detected",
                            textColor: const Color(0xFFFB923C),
                            isBold: true,
                          ),
                          const SizedBox(height: 4),
                          _buildBulletPoint(
                            "🎪 Marquee Tent auto-added to proposal safeguard",
                            textColor: const Color(0xFF4ADE80),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProposalDetailsScreen()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View Full Proposal & Status",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
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
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF38BDF8)),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, {Color textColor = Colors.white70, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 6.0),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 11.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}