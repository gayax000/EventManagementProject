import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'create_event_screen.dart';
import 'proposal_details_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<EventSummary> _events = [];
  String _userName = 'Client';
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndEvents();
  }

  Future<void> _loadUserAndEvents() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
      return;
    }

    setState(() => _isLoading = true);
    final name = await AuthService.getUserName();
    final data = await ApiService.getMyEvents();
    if (mounted) {
      setState(() {
        _userName = (name != null && name.isNotEmpty) ? name : 'Client';
        _events = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131C31),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your EventCraft account?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  void _navigateToCreateEvent([String? presetType]) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateEventScreen(initialEventType: presetType)),
    );
    if (created == true) {
      _loadUserAndEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Column(
          children: [
            _buildExecutiveAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadUserAndEvents,
                color: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF131C31),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 750;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? constraints.maxWidth * 0.12 : 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Executive Metrics Row
                          _buildMetricsRow(),
                          const SizedBox(height: 20),

                          // 2. Hero Action Card
                          _buildHeroActionCard(),
                          const SizedBox(height: 28),

                          // 3. Quick Inspiration Carousel
                          _buildInspirationSection(),
                          const SizedBox(height: 28),

                          // 4. Section Header for Active Events
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "ACTIVE EVENT REQUESTS",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                                ),
                                child: Text(
                                  "${_events.length} ${(_events.length == 1) ? 'Event' : 'Events'}",
                                  style: const TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 5. Active Content
                          _buildContent(isWide),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- TOP EXECUTIVE APP BAR ---
  Widget _buildExecutiveAppBar() {
    final initials = _userName.trim().isNotEmpty ? _userName.trim()[0].toUpperCase() : 'C';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131C31),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // VIP User Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome back, $_userName!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'EventCraft VIP Client',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
              tooltip: 'Refresh Events',
              onPressed: _loadUserAndEvents,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              tooltip: 'Sign Out',
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  // --- EXECUTIVE METRICS ROW ---
  Widget _buildMetricsRow() {
    final activeCount = _events.where((e) => e.status != 'Confirmed').length;
    final confirmedCount = _events.where((e) => e.status == 'Confirmed').length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: "Total Events",
            value: "${_events.length}",
            icon: Icons.celebration_rounded,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            label: "AI Proposals",
            value: "$activeCount",
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            label: "Confirmed",
            value: "$confirmedCount",
            icon: Icons.verified_rounded,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131C31),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- HERO CELEBRATION ACTION BANNER ---
  Widget _buildHeroActionCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2644), Color(0xFF0F1A30)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToCreateEvent(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add_rounded, color: Colors.black, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Plan New Event Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Orchestrate 5-star banquet halls, decor, cakes & weather protection with AI agents.",
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CURATED INSPIRATION / QUICK STARTERS ---
  Widget _buildInspirationSection() {
    final items = [
      {
        'title': 'Royal Wedding',
        'desc': '5-Star Halls & Floral Stages',
        'icon': '💍',
        'type': 'Wedding',
      },
      {
        'title': 'Milestone Birthday',
        'desc': 'Theme Decor & Bespoke Cakes',
        'icon': '🎂',
        'type': 'Birthday Party',
      },
      {
        'title': 'Corporate Gala',
        'desc': 'Concert Sound & Intelligent Rig',
        'icon': '🏢',
        'type': 'Dinner/Gala',
      },
      {
        'title': 'Scenic Lawn Party',
        'desc': 'Open-Air with Rain Safeguards',
        'icon': '🌴',
        'type': 'Family Gathering',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 16),
            SizedBox(width: 6),
            Text(
              "CURATED CELEBRATION INSPIRATION",
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final it = items[index];
              return InkWell(
                onTap: () => _navigateToCreateEvent(it['type']),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131C31),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Text(it['icon']!, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              it['title']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              it['desc']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- CONTENT SECTION (EMPTY OR POPULATED) ---
  Widget _buildContent(bool isWide) {
    if (_isLoading) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
            SizedBox(height: 14),
            Text(
              "Retrieving Your Event Proposals...",
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF131C31),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_rounded, color: Color(0xFFD4AF37), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Active Celebrations Yet",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ready to organize your next milestone? Create your first event request above to trigger automated AI multi-agent orchestration.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _navigateToCreateEvent(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                "Create Your First Event",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) => _buildEventCard(_events[index]),
    );
  }

  // --- LUXURY EVENT CARD ---
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
    final daysUntil = event.targetDate.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131C31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF10B981).withOpacity(0.6)
              : isApproved
                  ? const Color(0xFFD4AF37).withOpacity(0.6)
                  : Colors.white12,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Ribbon & Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: const Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : isApproved
                              ? const Color(0xFFD4AF37).withOpacity(0.15)
                              : Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isConfirmed
                            ? const Color(0xFF10B981)
                            : isApproved
                                ? const Color(0xFFD4AF37)
                                : Colors.amber,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isConfirmed
                              ? Icons.verified_rounded
                              : isApproved
                                  ? Icons.draw_rounded
                                  : Icons.hourglass_top_rounded,
                          size: 13,
                          color: isConfirmed
                              ? const Color(0xFF10B981)
                              : isApproved
                                  ? const Color(0xFFD4AF37)
                                  : Colors.amber,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isConfirmed
                              ? "BOOKING CONFIRMED & PASS ACTIVE"
                              : isApproved
                                  ? "APPROVED BY MANAGER (SIGN NOW)"
                                  : "UNDER MANAGER REVIEW",
                          style: TextStyle(
                            color: isConfirmed
                                ? const Color(0xFF10B981)
                                : isApproved
                                    ? const Color(0xFFD4AF37)
                                    : Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (daysUntil >= 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        daysUntil == 0 ? "Today!" : "In $daysUntil Days",
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata Grid
                  Row(
                    children: [
                      Expanded(child: _buildMetaPill(Icons.calendar_today_rounded, "Date", formattedDate)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMetaPill(Icons.people_alt_rounded, "Guests", "${event.guestCount}")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMetaPill(Icons.account_balance_wallet_rounded, "Budget", "LKR $formattedBudget")),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // AI Multi-Agent & Weather Safeguard Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFF06B6D4), size: 14),
                            SizedBox(width: 6),
                            Text(
                              "AI Multi-Agent Coordination:",
                              style: TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildAiDetailRow(
                          Icons.location_on_rounded,
                          "Venue: ${event.venueName ?? 'Luxury Sri Lankan Hotel Package'}",
                        ),
                        const SizedBox(height: 4),
                        _buildAiDetailRow(
                          event.isOutdoor ? Icons.cloud_sync_rounded : Icons.shield_rounded,
                          event.isOutdoor
                              ? "Weather Safeguard: Outdoor rain risk monitored"
                              : "Weather Safeguard: Indoor Venue (0% Rain Risk)",
                          color: event.isOutdoor ? Colors.white70 : const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Trigger
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConfirmed
                      ? const Color(0xFF10B981)
                      : isApproved
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF06B6D4),
                  foregroundColor: (isConfirmed || !isApproved) ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final refresh = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => ProposalDetailsScreen(eventId: event.eventId)),
                  );
                  if (refresh == true) {
                    _loadUserAndEvents();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConfirmed
                          ? Icons.qr_code_rounded
                          : isApproved
                              ? Icons.draw_rounded
                              : Icons.visibility_rounded,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConfirmed
                          ? "View VIP QR Entry Pass"
                          : isApproved
                              ? "Review & Sign Digital Contract"
                              : "View Live AI Proposal Status",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 12),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDetailRow(IconData icon, String text, {Color color = Colors.white70}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 11, height: 1.3),
          ),
        ),
      ],
    );
  }

  // --- FLOATING MODERN BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131C31),
        border: const Border(top: BorderSide(color: Colors.white10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) {
            _navigateToCreateEvent();
          } else if (index == 2) {
            final confirmed = _events.where((e) => e.status == 'Confirmed').toList();
            if (confirmed.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProposalDetailsScreen(eventId: confirmed.first.eventId)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No confirmed events with QR Passes yet."),
                  backgroundColor: Color(0xFF131C31),
                ),
              );
            }
          } else if (index == 3) {
            _handleLogout();
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard_rounded, color: Color(0xFFD4AF37)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded, color: Color(0xFFD4AF37)),
            label: 'Plan Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_rounded),
            activeIcon: Icon(Icons.qr_code_2_rounded, color: Color(0xFFD4AF37)),
            label: 'QR Passes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            activeIcon: Icon(Icons.logout_rounded, color: Color(0xFFD4AF37)),
            label: 'Sign Out',
          ),
        ],
      ),
    );
  }
}