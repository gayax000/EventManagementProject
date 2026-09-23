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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your EventCraft account?',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildExecutiveAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadUserAndEvents,
                color: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
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
                          // 1. Executive Metrics Row (Matching Web Dashboard)
                          _buildMetricsRow(),
                          const SizedBox(height: 20),

                          // 2. Hero Action Card (Matching Web Operational Bar)
                          _buildHeroActionCard(),
                          const SizedBox(height: 28),

                          // 3. Quick Inspiration Carousel (Zero Emojis, Pure Vector Icons)
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
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "ACTIVE EVENT REQUESTS",
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 13,
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Text(
                                  "${_events.length} ${_events.length == 1 ? 'Event' : 'Events'}",
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
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

  // --- TOP EXECUTIVE APP BAR (MATCHING WEB NAVBAR) ---
  Widget _buildExecutiveAppBar() {
    final initials = _userName.trim().isNotEmpty ? _userName.trim()[0].toUpperCase() : 'C';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info & VIP Status Pill
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
                    letterSpacing: 0.2,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'EventCraft VIP Client',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8), size: 20),
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

  // --- EXECUTIVE METRICS ROW (MATCHING MANAGER WEB DASHBOARD) ---
  Widget _buildMetricsRow() {
    final pendingCount = _events.where((e) => e.status != 'Confirmed').length;
    final confirmedCount = _events.where((e) => e.status == 'Confirmed').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 450;
        final double spacing = isCompact ? 8.0 : 12.0;

        return Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: isCompact ? "Active\nInquiries" : "Active Inquiries",
                value: "${_events.length}",
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF0284C7), // Sky Blue
                iconBg: const Color(0xFFF0F9FF),
                valueColor: const Color(0xFF0F172A),
                isCompact: isCompact,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildKpiCard(
                label: isCompact ? "Pending\nReview" : "Pending Review",
                value: "$pendingCount",
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFD97706), // Amber
                iconBg: const Color(0xFFFFFBEB),
                valueColor: const Color(0xFFD97706),
                isCompact: isCompact,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildKpiCard(
                label: isCompact ? "Approved\n& Ready" : "Approved & Ready",
                value: "$confirmedCount",
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF059669), // Emerald
                iconBg: const Color(0xFFECFDF5),
                valueColor: const Color(0xFF059669),
                isCompact: isCompact,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color valueColor,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 12 : 14,
        horizontal: isCompact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 6 : 7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: isCompact ? 15 : 18),
              ),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: isCompact ? 18 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 10),
          SizedBox(
            height: isCompact ? 28 : null,
            child: Text(
              label,
              maxLines: 2,
              softWrap: true,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: isCompact ? 10 : 11.5,
                fontWeight: FontWeight.bold,
                height: 1.15,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HERO CELEBRATION ACTION BANNER (MATCHING WEB OPERATIONAL BAR) ---
  Widget _buildHeroActionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToCreateEvent(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.35)),
                      ),
                      child: const Text(
                        "CLIENT EVENT PROPOSALS & AI BUDGETS",
                        style: TextStyle(
                          color: Color(0xFF7DD3FC),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Plan New Event Request",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Review live hotel catering, hall rentals, audio/visual gear, and autonomous weather safeguards.",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
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

  // --- CURATED INSPIRATION / QUICK STARTERS (ZERO EMOJIS, CLEAN VECTOR ICONS) ---
  Widget _buildInspirationSection() {
    final items = [
      {
        'title': 'Royal Wedding',
        'desc': '5-Star Halls & Floral Stages',
        'icon': Icons.favorite_border_rounded,
        'iconBg': const Color(0xFFEEF2FF),
        'iconColor': const Color(0xFF4F46E5),
        'type': 'Wedding',
      },
      {
        'title': 'Milestone Birthday',
        'desc': 'Theme Decor & Bespoke Cakes',
        'icon': Icons.cake_outlined,
        'iconBg': const Color(0xFFFFFBEB),
        'iconColor': const Color(0xFFD97706),
        'type': 'Birthday Party',
      },
      {
        'title': 'Corporate Gala',
        'desc': 'Concert Sound & Intelligent Rig',
        'icon': Icons.business_center_outlined,
        'iconBg': const Color(0xFFF0F9FF),
        'iconColor': const Color(0xFF0284C7),
        'type': 'Dinner/Gala',
      },
      {
        'title': 'Scenic Lawn Party',
        'desc': 'Open-Air with Rain Safeguards',
        'icon': Icons.park_outlined,
        'iconBg': const Color(0xFFECFDF5),
        'iconColor': const Color(0xFF059669),
        'type': 'Family Gathering',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 16),
            SizedBox(width: 6),
            Text(
              "CURATED CELEBRATION INSPIRATION",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final it = items[index];
              return InkWell(
                onTap: () => _navigateToCreateEvent(it['type'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060F172A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: it['iconBg'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(it['icon'] as IconData, color: it['iconColor'] as Color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              it['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              it['desc'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, height: 1.25),
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
        height: 200,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 14),
            Text(
              "Retrieving Your Event Proposals...",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Active Celebrations Yet",
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Submit a new celebration inquiry through the mobile app to trigger automated AI multi-agent orchestration.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildEventCard(_events[index]),
    );
  }

  // --- EXECUTIVE EVENT CARD (MATCHING WEB DESIGN SYSTEM) ---
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF10B981)
              : isApproved
                  ? const Color(0xFFD97706)
                  : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Ribbon & Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? const Color(0xFFECFDF5)
                          : isApproved
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isConfirmed
                            ? const Color(0xFFA7F3D0)
                            : isApproved
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFBAE6FD),
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
                              ? const Color(0xFF059669)
                              : isApproved
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF0284C7),
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
                                ? const Color(0xFF059669)
                                : isApproved
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF0284C7),
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
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        daysUntil == 0 ? "Today!" : "In $daysUntil Days",
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.bold),
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
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: 0.2,
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
                      Expanded(child: _buildMetaPill(Icons.payments_outlined, "Budget", "LKR $formattedBudget")),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // AI Multi-Agent & Weather Safeguard Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 14),
                            SizedBox(width: 6),
                            Text(
                              "AI Multi-Agent Coordination:",
                              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildAiDetailRow(
                          Icons.location_on_rounded,
                          "Venue: ${event.venueName ?? 'Luxury Sri Lankan Hotel Package'}",
                          color: const Color(0xFF475569),
                        ),
                        const SizedBox(height: 4),
                        _buildAiDetailRow(
                          event.isOutdoor ? Icons.cloud_sync_rounded : Icons.shield_rounded,
                          event.isOutdoor
                              ? "Weather Safeguard: Outdoor rain risk monitored"
                              : "Weather Safeguard: Indoor Venue (0% Rain Risk)",
                          color: event.isOutdoor ? const Color(0xFFD97706) : const Color(0xFF059669),
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
                      ? const Color(0xFF059669)
                      : isApproved
                          ? const Color(0xFFD97706)
                          : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF64748B), size: 12),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDetailRow(IconData icon, String text, {required Color color}) {
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

  // --- MODERN EXECUTIVE BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, -3),
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
                  backgroundColor: Color(0xFF0F172A),
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
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF2563EB)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded, color: Color(0xFF2563EB)),
            label: 'Plan Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_rounded),
            activeIcon: Icon(Icons.qr_code_2_rounded, color: Color(0xFF2563EB)),
            label: 'QR Passes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            activeIcon: Icon(Icons.logout_rounded, color: Color(0xFF2563EB)),
            label: 'Sign Out',
          ),
        ],
      ),
    );
  }
}