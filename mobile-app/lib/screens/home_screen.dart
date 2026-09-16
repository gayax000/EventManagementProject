import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';
import 'proposal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<EventSummary> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getMyEvents();
    if (mounted) {
      setState(() {
        _events = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👋 Welcome back, Kasun!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('"EventCraft AI Experience"', style: TextStyle(fontSize: 12, color: Colors.cyanAccent)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _isLoading ? Colors.grey : Colors.cyan),
            onPressed: _isLoading ? null : _loadEvents,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        color: Colors.cyan,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Action Card
              const Text("⚡ QUICK ACTION", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                  );
                  if (created == true) {
                    _loadEvents();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.cyan, size: 28),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("+ Create New Event Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Plan your next event with AI Multi-Agents", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Event Request Section
              const Text("📊 ACTIVE EVENT REQUEST", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              if (_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.cyan),
                  ),
                )
              else if (_events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.event_busy, color: Colors.white38, size: 40),
                      const SizedBox(height: 10),
                      const Text("No active events found", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Create a new event above to trigger AI agent orchestration.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                )
              else
                ..._events.map((ev) => _buildEventCard(ev)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventSummary event) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = event.targetDate.month >= 1 && event.targetDate.month <= 12 ? months[event.targetDate.month - 1] : '';
    final formattedDate = '$m ${event.targetDate.day.toString().padLeft(2, '0')}, ${event.targetDate.year}';
    final formattedBudget = event.budgetLimit.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    final isConfirmed = event.status == 'Confirmed';
    final isApproved = event.status == 'ApprovedByManager';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfirmed
              ? Colors.green.withOpacity(0.5)
              : isApproved
                  ? Colors.cyan.withOpacity(0.5)
                  : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🎪 ${event.title}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text("📅 Date: $formattedDate  |  👥 Guests: ${event.guestCount}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text("💰 Budget: LKR $formattedBudget", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Divider(color: Colors.white12, height: 20),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? Colors.green.withOpacity(0.2)
                  : isApproved
                      ? Colors.cyan.withOpacity(0.2)
                      : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isConfirmed
                    ? Colors.green
                    : isApproved
                        ? Colors.cyan
                        : Colors.amber,
              ),
            ),
            child: Text(
              isConfirmed
                  ? "🟢 STATUS: BOOKING CONFIRMED & PASS ACTIVE"
                  : isApproved
                      ? "🟢 STATUS: APPROVED BY MANAGER (SIGN NOW)"
                      : "🟡 STATUS: UNDER MANAGER REVIEW",
              style: TextStyle(
                color: isConfirmed
                    ? Colors.greenAccent
                    : isApproved
                        ? Colors.cyanAccent
                        : Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // AI Weather Risk Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🤖 AI Workflow Status:", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text("• Venue: ${event.venueName ?? 'Luxury Sri Lankan Hotel Package'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const Text("• 🌦️ Weather Safeguard: Rain risk assessed & Marquee tent included", style: TextStyle(color: Colors.white70, fontSize: 12)),
                if (isApproved)
                  const Text("• ✍️ Ready for Customer Digital Signature & QR Pass", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproved ? Colors.green.shade700 : Colors.cyan.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final refresh = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => ProposalDetailsScreen(eventId: event.eventId)),
                );
                if (refresh == true) {
                  _loadEvents();
                }
              },
              child: Text(
                isConfirmed
                    ? "View QR Entry Pass"
                    : isApproved
                        ? "Review & Sign Digital Contract"
                        : "View Live AI Proposal Status",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}