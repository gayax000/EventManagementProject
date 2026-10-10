import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _userEmail = 'client@eventcraft.lk';
  String _userRole = 'CLIENT';
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
    final email = await AuthService.getUserEmail();
    final role = await AuthService.getUserRole();
    final data = await ApiService.getMyEvents();
    if (mounted) {
      setState(() {
        _userName = (name != null && name.isNotEmpty) ? name : 'Client';
        _userEmail = (email != null && email.isNotEmpty) ? email : 'client@eventcraft.lk';
        _userRole = (role != null && role.isNotEmpty) ? role.toUpperCase() : 'CLIENT';
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
      body: Column(
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
                      vertical: 18.0,
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- EXECUTIVE APP BAR ---
  Widget _buildExecutiveAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF090D1A), // Deep Midnight
            Color(0xFF161533), // Cosmic Violet / Deep Indigo
            Color(0xFF0F172A), // Slate Navy
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // EventCraft Brand Logo & Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1F38BDF8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x3338BDF8)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 16),
                    SizedBox(width: 6),
                    Text(
                      "EventCraft.AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Executive Profile Pill (Web-consistent Pill with Status Dot, Name, Role & Chevron)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showExecutiveProfileSheet(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Green Online Indicator Dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x8010B981),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Truncated User Name
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 85),
                          child: Text(
                            _userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Role Badge (CLIENT or MANAGER)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C4A6E),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF0284C7)),
                          ),
                          child: Text(
                            _userRole,
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Dropdown Arrow
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF94A3B8),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- EXECUTIVE PROFILE BOTTOM SHEET (MATCHING WEB POPUP UX) ---
  void _showExecutiveProfileSheet(BuildContext context) {
    final initials = _userName.trim().isNotEmpty ? _userName.trim()[0].toUpperCase() : 'C';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B132B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
              left: BorderSide(color: Color(0xFF1E293B), width: 1),
              right: BorderSide(color: Color(0xFF1E293B), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header Profile Card with Gradient Avatar, Name, Email and Badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      children: [
                        // Avatar Circle with Neon Blue / Indigo Gradient
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4F46E5), // Indigo
                                Color(0xFF0284C7), // Sky Blue
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x4D0284C7),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name, Email and Role Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0C4A6E),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF0284C7)),
                                    ),
                                    child: Text(
                                      _userRole,
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.mail_outline_rounded,
                                    size: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      _userEmail,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 8),

                  // Menu Option 1: Edit Profile Details
                  _buildProfileMenuItem(
                    icon: Icons.edit_outlined,
                    iconColor: const Color(0xFF818CF8),
                    title: "Edit Profile Details",
                    onTap: () {
                      Navigator.pop(ctx);
                      _showEditProfileModal();
                    },
                  ),

                  // Menu Option 2: App Tour & Overview
                  _buildProfileMenuItem(
                    icon: Icons.explore_outlined,
                    iconColor: const Color(0xFF38BDF8),
                    title: "App Tour & Overview",
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingScreen(isReviewMode: true)),
                      );
                    },
                  ),

                  // Menu Option 3: Legal & Policies
                  _buildProfileMenuItem(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF38BDF8),
                    title: "Legal & Policies",
                    onTap: () {
                      Navigator.pop(ctx);
                      PoliciesScreen.show(context);
                    },
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 8),

                  // Menu Option 4: Sign Out (Red highlight)
                  _buildProfileMenuItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: "Sign Out",
                    textColor: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleLogout();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- REUSABLE PROFILE MENU ITEM ---
  Widget _buildProfileMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF475569),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // --- EDIT PROFILE MODAL ---
  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController();

    AuthService.getUserPhone().then((p) {
      if (p != null && p.isNotEmpty) {
        phoneController.text = p;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0x1F818CF8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x33818CF8)),
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: Color(0xFF818CF8), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Edit Profile Details",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Update your personal account information",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full Name Input
                    const Text(
                      "FULL NAME",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 18),
                        hintText: "Enter full name",
                        hintStyle: const TextStyle(color: Color(0xFF475569)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Email Input
                    const Text(
                      "EMAIL ADDRESS",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B), size: 18),
                        hintText: "Enter email",
                        hintStyle: const TextStyle(color: Color(0xFF475569)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Phone Input
                    const Text(
                      "CONTACT NUMBER",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF64748B), size: 18),
                        hintText: "e.g. 0771234567 or +94 77 123 4567",
                        hintStyle: const TextStyle(color: Color(0xFF475569)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text(
                          "Save Profile Changes",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          final newEmail = emailController.text.trim();
                          final newPhone = phoneController.text.trim();

                          if (newPhone.isNotEmpty) {
                            final phoneRegex = RegExp(r'^(?:\+94|0)[0-9]{9}$');
                            if (!phoneRegex.hasMatch(newPhone.replaceAll(RegExp(r'\s+'), ''))) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a valid mobile number (e.g. 0771234567 or +94771234567)"),
                                  backgroundColor: Colors.amber,
                                ),
                              );
                              return;
                            }
                          }

                          if (newName.isNotEmpty) {
                            await AuthService.updateProfile(
                              name: newName,
                              email: newEmail.isNotEmpty ? newEmail : _userEmail,
                              phone: newPhone,
                            );
                            if (!mounted) return;
                            setState(() {
                              _userName = newName;
                              if (newEmail.isNotEmpty) _userEmail = newEmail;
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                                    SizedBox(width: 8),
                                    Text("Profile details updated successfully!"),
                                  ],
                                ),
                                backgroundColor: Color(0xFF0F172A),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                          SizedBox(height: 3),
                          Text(
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
                  Flexible(
                    child: Container(
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
                          Flexible(
                            child: Text(
                              isConfirmed
                                  ? "BOOKING CONFIRMED & PASS ACTIVE"
                                  : isApproved
                                      ? "APPROVED BY MANAGER (SIGN NOW)"
                                      : "UNDER MANAGER REVIEW",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isConfirmed
                                    ? const Color(0xFF059669)
                                    : isApproved
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF0284C7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (daysUntil >= 0) ...[
                    const SizedBox(width: 8),
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

                  // Metadata Grid (Responsive 2-Row Layout: Target Date & Guests + Full-Width Financial Banner)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaPill(Icons.calendar_today_rounded, "Date", formattedDate),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetaPill(Icons.people_alt_rounded, "Guests", "${event.guestCount} Guests"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Dedicated Full-Width Budget Banner (Never overflows, spacious & executive)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? const Color(0xFFECFDF5)
                          : (isApproved ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isConfirmed
                            ? const Color(0xFFA7F3D0)
                            : (isApproved ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments_rounded,
                          size: 15,
                          color: isConfirmed
                              ? const Color(0xFF059669)
                              : (isApproved ? const Color(0xFFD97706) : const Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$costLabel:",
                          style: TextStyle(
                            color: isApproved ? const Color(0xFF92400E) : const Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "LKR $formattedCost",
                          style: TextStyle(
                            color: isConfirmed
                                ? const Color(0xFF059669)
                                : (isApproved ? const Color(0xFFB45309) : const Color(0xFF0F172A)),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold),
            ),
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

  // --- MODERN EXECUTIVE BOTTOM NAVIGATION BAR (MATCHING DARK CURVE & HIGH CONTRAST) ---
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161533), // Cosmic Violet / Deep Indigo (Matching the Top Header)
            Color(0xFF090D1A), // Deep Midnight
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x38090D1A),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
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
              selectedItemColor: const Color(0xFF38BDF8),
              unselectedItemColor: const Color(0xFFE2E8F0),
              iconSize: 24,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded, color: Color(0xFFCBD5E1)),
                  activeIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_rounded, color: Color(0xFFCBD5E1)),
                  activeIcon: Icon(Icons.restaurant_menu_rounded, color: Color(0xFF38BDF8)),
                  label: 'Packages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment_rounded, color: Color(0xFFCBD5E1)),
                  activeIcon: Icon(Icons.payment_rounded, color: Color(0xFF38BDF8)),
                  label: 'Payments',
                ),
              ],
            ),
          ),
        ),
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