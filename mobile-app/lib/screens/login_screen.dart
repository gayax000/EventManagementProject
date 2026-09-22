import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

const String FEATURED_HERO_IMAGE = 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1600&q=85';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Login Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _loginEmailError;
  String? _loginPasswordError;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _regLoading = false;
  String? _regNameError;
  String? _regEmailError;
  String? _regPhoneError;
  String? _regPasswordError;

  // Top Disappearing Validation & Alert Message Banner
  String? _topBannerMessage;
  Timer? _bannerTimer;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _triggerTopMessage(String message, StateSetter? setModalState) {
    _bannerTimer?.cancel();
    void show() {
      _topBannerMessage = message;
    }
    if (setModalState != null) {
      setModalState(show);
    } else {
      setState(show);
    }

    // Automatically disappears after 3.5 seconds
    _bannerTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        void hide() {
          _topBannerMessage = null;
        }
        if (setModalState != null) {
          setModalState(hide);
        } else {
          setState(hide);
        }
      }
    });
  }

  Future<void> _handleLogin(StateSetter? setModalState) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? emailErr;
    String? passwordErr;

    if (email.isEmpty) {
      emailErr = 'Please enter your email';
    } else if (!email.contains('@')) {
      emailErr = 'Email must contain @';
    }

    if (password.isEmpty) {
      passwordErr = 'Please enter your password';
    } else if (password.length < 6) {
      passwordErr = 'Password must be at least 6 characters';
    }

    if (emailErr != null || passwordErr != null) {
      final msg = emailErr ?? passwordErr!;
      void updateErrors() {
        _loginEmailError = emailErr;
        _loginPasswordError = passwordErr;
      }
      if (setModalState != null) {
        setModalState(updateErrors);
      } else {
        setState(updateErrors);
      }
      _triggerTopMessage(msg, setModalState);
      return;
    }

    void startLoading() {
      _isLoading = true;
      _loginEmailError = null;
      _loginPasswordError = null;
      _topBannerMessage = null;
    }

    if (setModalState != null) {
      setModalState(startLoading);
    } else {
      setState(startLoading);
    }

    final result = await AuthService.login(email, password);

    if (setModalState != null) setModalState(() => _isLoading = false);
    else setState(() => _isLoading = false);

    if (result.success) {
      final role = await AuthService.getUserRole();
      if (role == 'Vendor') {
        await AuthService.logout();
        if (mounted) {
          _triggerTopMessage('Access Restricted: This dashboard is exclusively for Clients.', setModalState);
        }
        return;
      }

      if (mounted) {
        _bannerTimer?.cancel();
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      final errorMsg = (result.message != null && result.message!.isNotEmpty)
          ? (result.message!.toLowerCase().contains('invalid')
              ? 'Invalid email or password'
              : result.message!)
          : 'Invalid email or password';

      _triggerTopMessage(errorMsg, setModalState);
    }
  }

  Future<void> _handleRegister(StateSetter setModalState) async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text.trim();

    String? nameErr;
    String? emailErr;
    String? phoneErr;
    String? passwordErr;

    if (name.isEmpty) {
      nameErr = 'Please enter your full name';
    }
    if (email.isEmpty) {
      emailErr = 'Please enter your email';
    } else if (!email.contains('@')) {
      emailErr = 'Email must contain @';
    }
    if (phone.isEmpty) {
      phoneErr = 'Please enter your phone number';
    }
    if (password.isEmpty) {
      passwordErr = 'Please enter your password';
    } else if (password.length < 6) {
      passwordErr = 'Password must be at least 6 characters';
    }

    if (nameErr != null || emailErr != null || phoneErr != null || passwordErr != null) {
      final msg = nameErr ?? emailErr ?? phoneErr ?? passwordErr!;
      setModalState(() {
        _regNameError = nameErr;
        _regEmailError = emailErr;
        _regPhoneError = phoneErr;
        _regPasswordError = passwordErr;
      });
      _triggerTopMessage(msg, setModalState);
      return;
    }

    setModalState(() {
      _regLoading = true;
      _regNameError = null;
      _regEmailError = null;
      _regPhoneError = null;
      _regPasswordError = null;
      _topBannerMessage = null;
    });

    final result = await AuthService.register(name, email, password, phone, role: 'Customer');
    setModalState(() => _regLoading = false);

    if (result.success) {
      final autoLogin = await AuthService.login(email, password);
      if (autoLogin.success && mounted) {
        _bannerTimer?.cancel();
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        _bannerTimer?.cancel();
        Navigator.of(context, rootNavigator: true).pop();
        _showAuthBottomSheet(isRegister: false);
      }
    } else {
      _triggerTopMessage(result.message ?? 'Registration failed. Please try again.', setModalState);
    }
  }

  // Modern Client Auth Bottom Sheet with Disappearing Notification at the Very Top
  void _showAuthBottomSheet({required bool isRegister}) {
    _bannerTimer?.cancel();
    _topBannerMessage = null;
    _loginEmailError = null;
    _loginPasswordError = null;
    _regNameError = null;
    _regEmailError = null;
    _regPhoneError = null;
    _regPasswordError = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool inRegisterMode = isRegister;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // =========================================================
                    // TOP DISAPPEARING VALIDATION / ERROR MESSAGE BANNER
                    // Appears right at the very top of the small form and auto-disappears
                    // =========================================================
                    if (_topBannerMessage != null) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                color: Color(0xFFEF4444),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _topBannerMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _bannerTimer?.cancel();
                                setModalState(() => _topBannerMessage = null);
                              },
                              child: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Header Mode Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          inRegisterMode ? "Client Registration" : "Client Sign In",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            _bannerTimer?.cancel();
                            Navigator.pop(ctx);
                          },
                          child: const Icon(Icons.close, color: Colors.white54, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inRegisterMode 
                        ? "Create your client account to explore venues & plan events."
                        : "Access your personalized AI proposals and live event statuses.",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    if (!inRegisterMode) ...[
                      // Login Fields
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          "Client Email Address",
                          Icons.email_outlined,
                          errorText: _loginEmailError,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) {
                          if (_loginEmailError != null || _topBannerMessage != null) {
                            setModalState(() {
                              _loginEmailError = null;
                              _topBannerMessage = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          "Password",
                          Icons.lock_outline,
                          errorText: _loginPasswordError,
                        ),
                        onChanged: (val) {
                          if (_loginPasswordError != null || _topBannerMessage != null) {
                            setModalState(() {
                              _loginPasswordError = null;
                              _topBannerMessage = null;
                            });
                          }
                        },
                        onSubmitted: (_) => _isLoading ? null : _handleLogin(setModalState),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleLogin(setModalState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // Executive Royal Blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Sign In as Client", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: GestureDetector(
                          onTap: () => setModalState(() {
                            inRegisterMode = true;
                            _bannerTimer?.cancel();
                            _topBannerMessage = null;
                            _loginEmailError = null;
                            _loginPasswordError = null;
                            _regNameError = null;
                            _regEmailError = null;
                            _regPhoneError = null;
                            _regPasswordError = null;
                          }),
                          child: RichText(
                            text: const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                              children: [
                                TextSpan(text: "Sign Up as Client", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Register Fields (Strictly for Clients)
                      TextField(
                        controller: _regNameController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          "Full Name", 
                          Icons.person_outline,
                          errorText: _regNameError,
                        ),
                        onChanged: (val) {
                          if (_regNameError != null) {
                            setModalState(() => _regNameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _regEmailController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          "Email Address", 
                          Icons.email_outlined,
                          errorText: _regEmailError,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) {
                          if (_regEmailError != null) {
                            setModalState(() => _regEmailError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _regPhoneController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          "Phone (+94)", 
                          Icons.phone_outlined,
                          errorText: _regPhoneError,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (val) {
                          if (_regPhoneError != null) {
                            setModalState(() => _regPhoneError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _regPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration(
                          "Password", 
                          Icons.lock_outline,
                          errorText: _regPasswordError,
                        ),
                        onChanged: (val) {
                          if (_regPasswordError != null) {
                            setModalState(() => _regPasswordError = null);
                          }
                        },
                        onSubmitted: (_) => _regLoading ? null : _handleRegister(setModalState),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _regLoading ? null : () => _handleRegister(setModalState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8), // Deep Royal Blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: _regLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Create Client Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: GestureDetector(
                          onTap: () => setModalState(() {
                            inRegisterMode = false;
                            _bannerTimer?.cancel();
                            _topBannerMessage = null;
                            _loginEmailError = null;
                            _loginPasswordError = null;
                            _regNameError = null;
                            _regEmailError = null;
                            _regPhoneError = null;
                            _regPasswordError = null;
                          }),
                          child: RichText(
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                              children: [
                                TextSpan(text: "Sign In", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: errorText != null ? Colors.redAccent : const Color(0xFF0284C7), size: 18),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // =======================================================
          // 1. FULL-PAGE RESPONSIVE PORTRAIT LUXURY BACKGROUND PHOTO
          // =======================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/luxury_event_hero_bg.jpg',
              width: size.width,
              height: size.height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  FEATURED_HERO_IMAGE,
                  width: size.width,
                  height: size.height,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // =======================================================
          // 2. LUXURY CINEMATIC GRADIENT VIGNETTE OVERLAY
          // =======================================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF090D16).withOpacity(0.85),
                    const Color(0xFF090D16).withOpacity(0.40),
                    const Color(0xFF090D16).withOpacity(0.78),
                    const Color(0xFF090D16).withOpacity(0.96),
                  ],
                  stops: const [0.0, 0.32, 0.68, 1.0],
                ),
              ),
            ),
          ),

          // =======================================================
          // 3. RESPONSIVE FOREGROUND CONTENT
          // =======================================================
          SafeArea(
            child: Column(
              children: [
                // Top Navbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(text: "EventCraft", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                TextSpan(text: ".AI", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Top Navbar Log In & Sign Up Buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _showAuthBottomSheet(isRegister: false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () => _showAuthBottomSheet(isRegister: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB), // Royal Blue
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),

                // Middle & Bottom Responsive Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // Portal Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 13),
                              SizedBox(width: 6),
                              Text("Client Experience Portal", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Welcome Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(text: "Welcome to ", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                              TextSpan(text: "EventCraft", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Sri Lanka's premier AI event management platform. We pair certified 5-star hotel banquet halls with verified suppliers, gourmet catering, and real-time weather contingency safeguards for unforgettable celebrations.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Feature Highlights Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeatureBadge(Icons.hotel_rounded, "5-Star Venues"),
                            _buildFeatureBadge(Icons.cloud_done_rounded, "Weather Safeguard"),
                            _buildFeatureBadge(Icons.verified_rounded, "Verified Vendors"),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Autonomous Weather Shield Glass Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 15),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "5-Star Certified Venues & Autonomous Weather Shield",
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text("SE3090 Frameworks • EventCraft AI", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 13),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
