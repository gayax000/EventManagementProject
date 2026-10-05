import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'create_event_screen.dart';
import 'proposal_details_screen.dart';
import 'login_screen.dart';
import 'packages_screen.dart';
import 'payments_screen.dart';
import 'policies_screen.dart';
import 'onboarding_screen.dart';

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
                          // 1. Sleek Hero Action Card with Abstract Artwork Background & Smooth Transition
                          _buildHeroActionCard(),
                          const SizedBox(height: 24),

                          // 2. Section Header for Active Events
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
                                  const Icon(Icons.event_note_rounded, color: Color(0xFF2563EB), size: 18),
                                  const SizedBox(width: 6),
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

                          // 3. Active Events List Content
                          _buildContent(isWide),
                          const SizedBox(height: 30),
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

  // --- EXECUTIVE APP BAR ---
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

          // User Info & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome, $_userName",
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
                    const Text(
                      "Client Dashboard",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Legal, Policies & App Tour Button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 20),
              tooltip: 'Legal, Policies & App Tour',
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              onSelected: (val) {
                if (val == 'policies') {
                  PoliciesScreen.show(context);
                } else if (val == 'tour') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen(isReviewMode: true)),
                  );
                } else if (val == 'about') {
                  _showAboutDialog();
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'tour',
                  child: Row(
                    children: [
                      Icon(Icons.explore_outlined, color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 10),
                      Text('App Tour & Overview', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'policies',
                  child: Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 10),
                      Text('Legal & Policies', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 18),
                      SizedBox(width: 10),
                      Text('About EventCraft AI', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
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

  // --- HERO ACTION CARD WITH UPLOADED ARTWORK BACKGROUND & SMOOTH FADE ---
  Widget _buildHeroActionCard() {
    return Container(
      height: 125,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x290F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Background Artwork Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_banner_bg.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Smooth Dark Gradient Transition Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xF50F172A), // Dense navy for text clarity
                    Color(0xCC0F172A), // Smooth transition fade
                    Color(0x550F172A), // Glowing abstract background highlight
                  ],
                ),
              ),
            ),
          ),

          // 3. Banner Touch Content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToCreateEvent(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Plan Your Next Event",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            "Create & customize with AI assistant",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.5),
                            blurRadius: 12,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTENT SECTION (EMPTY OR POPULATED LIST) ---
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
              "No Active Events Yet",
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Submit a new event request to get automated AI budget plans and hotel venue options.",
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
                "Plan Your Next Event",
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

  // --- EXECUTIVE EVENT CARD ---
  Widget _buildEventCard(EventSummary event) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = event.targetDate.month >= 1 && event.targetDate.month <= 12 ? months[event.targetDate.month - 1] : '';
    final formattedDate = '$m ${event.targetDate.day.toString().padLeft(2, '0')}, ${event.targetDate.year}';

    final isConfirmed = event.status == 'Confirmed';
    final isApproved = event.status == 'ApprovedByManager';
    final double displayCost = (event.estimatedTotalCost != null && event.estimatedTotalCost! > 0)
        ? event.estimatedTotalCost!
        : event.budgetLimit;
    final formattedCost = displayCost.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final String costLabel = isConfirmed
        ? "Agreed Total"
        : (isApproved
            ? "Approved Budget"
            : (event.estimatedTotalCost != null && event.estimatedTotalCost! > 0
                ? "Total Estimate"
                : "Budget Limit"));
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
            // Top Ribbon & Status (Zero Emojis, Pure Vector Icons)
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
                                  ? Icons.rate_review_rounded
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
                        daysUntil == 0 ? "Today" : "In $daysUntil Days",
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

                  // Metadata Grid (Pure Vector Icons)
                  Row(
                    children: [
                      Expanded(child: _buildMetaPill(Icons.calendar_today_rounded, "Date", formattedDate)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMetaPill(Icons.people_alt_rounded, "Guests", "${event.guestCount}")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMetaPill(Icons.payments_outlined, costLabel, "LKR $formattedCost")),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // AI Multi-Agent & Weather Safeguard Box
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
                        const Row(
                          children: [
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

            // Bottom Action Button
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

  // --- MODERN EXECUTIVE BOTTOM NAVIGATION BAR (3 CLEAN TABS) ---
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PackagesScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentsScreen()),
            );
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
            icon: Icon(Icons.restaurant_menu_rounded),
            activeIcon: Icon(Icons.restaurant_menu_rounded, color: Color(0xFF2563EB)),
            label: 'Packages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_rounded),
            activeIcon: Icon(Icons.payment_rounded, color: Color(0xFF2563EB)),
            label: 'Payments',
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
            SizedBox(width: 10),
            Text('About EventCraft AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('EventCraft Executive Suite', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Version 2.4.0 (Build 2026.10)', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text('Powered by Google Antigravity Multi-Agent Architecture for luxury Sri Lankan hotel banquet reservations and autonomous vendor coordination.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}