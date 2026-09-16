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
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadEvents,
                color: Colors.cyanAccent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWebOrTablet = constraints.maxWidth > 700;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWebOrTablet ? constraints.maxWidth * 0.1 : 16.0, 
                        vertical: 24.0
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickActionCard(),
                          const SizedBox(height: 32),
                          const Text(
                            "ACTIVE EVENT REQUESTS", 
                            style: TextStyle(color: Colors.cyanAccent, fontSize: 14, letterSpacing: 1.2, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 16),
                          _buildContent(isWebOrTablet),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("👋 Welcome back, Kasun!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
              SizedBox(height: 4),
              Text('EventCraft AI Experience', style: TextStyle(fontSize: 13, color: Colors.cyanAccent, fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyan.withOpacity(0.1),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, color: _isLoading ? Colors.grey : Colors.cyanAccent),
              onPressed: _isLoading ? null : _loadEvents,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const CreateEventScreen()),
            );
            if (created == true) {
              _loadEvents();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Create New Event Request", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Plan your next event with AI Multi-Agents", 
                        style: TextStyle(color: Colors.white70, fontSize: 13)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isWebOrTablet) {
    if (_isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.cyanAccent),
      );
    }
    
    if (_events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: const [
            Icon(Icons.event_busy_rounded, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text("No active events found", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Create a new event above to trigger AI agent orchestration.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5)),
          ],
        ),
      );
    }

    if (isWebOrTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
        ),
        itemCount: _events.length,
        itemBuilder: (context, index) => _buildEventCard(_events[index]),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) => _buildEventCard(_events[index]),
      );
    }
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
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfirmed
              ? Colors.greenAccent.withOpacity(0.5)
              : isApproved
                  ? Colors.cyanAccent.withOpacity(0.5)
                  : Colors.white12,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.celebration_rounded, color: Colors.amber, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5)
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.calendar_today_rounded, "Date", formattedDate),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.people_alt_rounded, "Guests", "${event.guestCount}"),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.account_balance_wallet_rounded, "Budget", "LKR $formattedBudget"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status and AI Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? Colors.green.withOpacity(0.15)
                          : isApproved
                              ? Colors.cyan.withOpacity(0.15)
                              : Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isConfirmed
                            ? Colors.greenAccent
                            : isApproved
                                ? Colors.cyanAccent
                                : Colors.amberAccent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isConfirmed ? Icons.check_circle_rounded : isApproved ? Icons.verified_rounded : Icons.pending_rounded,
                          size: 14,
                          color: isConfirmed ? Colors.greenAccent : isApproved ? Colors.cyanAccent : Colors.amberAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConfirmed
                              ? "BOOKING CONFIRMED & PASS ACTIVE"
                              : isApproved
                                  ? "APPROVED BY MANAGER (SIGN NOW)"
                                  : "UNDER MANAGER REVIEW",
                          style: TextStyle(
                            color: isConfirmed
                                ? Colors.greenAccent
                                : isApproved
                                    ? Colors.cyanAccent
                                    : Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // AI Weather Risk Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.smart_toy_rounded, color: Colors.cyanAccent, size: 16),
                            SizedBox(width: 8),
                            Text("AI Workflow Status:", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAiDetailRow(Icons.location_on_rounded, "Venue: ${event.venueName ?? 'Luxury Sri Lankan Hotel Package'}"),
                        const SizedBox(height: 6),
                        _buildAiDetailRow(Icons.cloud_sync_rounded, "Weather Safeguard: Rain risk assessed & Marquee tent included"),
                        if (isApproved) ...[
                          const SizedBox(height: 6),
                          _buildAiDetailRow(Icons.draw_rounded, "Ready for Customer Digital Signature & QR Pass", color: Colors.greenAccent),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApproved ? Colors.green.shade600 : Colors.cyan.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 6),
        Text("$label: ", style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAiDetailRow(IconData icon, String text, {Color color = Colors.white70}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(color: color, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }
}