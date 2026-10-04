import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'policies_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReviewMode;

  const OnboardingScreen({super.key, this.isReviewMode = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _slides = [
    const OnboardingItem(
      badge: "SMART EVENT PLATFORM",
      title: "Design Unforgettable\nExperiences",
      description:
          "Browse curated luxury venues, select world-class catering, and configure custom decor packages in real-time.",
      icon: Icons.celebration_rounded,
      accentColor: Color(0xFF38BDF8),
      gradientColors: [Color(0xFF0284C7), Color(0xFF0369A1)],
      highlights: [
        "Curated Venues & Decor",
        "Real-Time Cost Estimates",
        "Multi-Service Packages",
      ],
    ),
    const OnboardingItem(
      badge: "AGENTIC AI CONCIERGE",
      title: "Autonomous Planning,\nZero Budget Overrun",
      description:
          "Our LangGraph multi-agent AI synthesizes guest headcounts and dietary choices under a strict safety ceiling policy.",
      icon: Icons.auto_awesome_rounded,
      accentColor: Color(0xFFA855F7),
      gradientColors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
      highlights: [
        "Zero-Overrun Safety Guarantee",
        "Dynamic Line-Item Breakdown",
        "Human Manager Oversight",
      ],
    ),
    const OnboardingItem(
      badge: "SEAMLESS EXECUTION",
      title: "Instant Approvals &\nPaperless QR Passes",
      description:
          "Track manager quotations, sign binding contracts digitally, and issue encrypted QR check-in passes for all attendees.",
      icon: Icons.qr_code_scanner_rounded,
      accentColor: Color(0xFF10B981),
      gradientColors: [Color(0xFF059669), Color(0xFF064E3B)],
      highlights: [
        "Legally Binding e-Signatures",
        "Live Booking Status Updates",
        "Instant Staff QR Verification",
      ],
    ),
  ];

  Future<void> _completeOnboarding() async {
    if (!widget.isReviewMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    }

    if (mounted) {
      if (widget.isReviewMode) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand Pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: const Icon(Icons.event_seat_rounded, color: Color(0xFF38BDF8), size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "EventCraft AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),

                  // Skip or Close Button
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      widget.isReviewMode ? "Close" : "Skip",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Body
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (ctx, idx) => _buildSlide(_slides[idx]),
              ),
            ),

            // Bottom Navigation Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == idx ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx
                              ? _slides[_currentPage].accentColor
                              : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? "Get Started" : "Continue",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Policy quick view link
                  GestureDetector(
                    onTap: () => PoliciesScreen.show(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shield_outlined, size: 14, color: Color(0xFF94A3B8)),
                        SizedBox(width: 6),
                        Text(
                          "Read Terms of Service & AI Safety Policy",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF64748B),
                          ),
                        ),
                      ],
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

  Widget _buildSlide(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic Card
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withOpacity(0.35),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: item.accentColor.withOpacity(0.5), width: 2),
            ),
            child: Icon(item.icon, color: Colors.white, size: 64),
          ),
          const SizedBox(height: 28),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: item.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: item.accentColor.withOpacity(0.35)),
            ),
            child: Text(
              item.badge,
              style: TextStyle(
                color: item.accentColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          // Key Highlights Badges
          Column(
            children: item.highlights.map((h) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: item.accentColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      h,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final List<String> highlights;

  const OnboardingItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.highlights,
  });
}
