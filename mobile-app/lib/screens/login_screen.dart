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

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _regLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(StateSetter? setModalState) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in both email and password', isError: true);
      return;
    }

    if (setModalState != null) setModalState(() => _isLoading = true);
    else setState(() => _isLoading = true);

    final result = await AuthService.login(email, password);

    if (setModalState != null) setModalState(() => _isLoading = false);
    else setState(() => _isLoading = false);

    if (result.success) {
      // Check if user is a Vendor -> strictly restrict access to Clients only
      final role = await AuthService.getUserRole();
      if (role == 'Vendor') {
        await AuthService.logout();
        if (mounted) {
          _showSnackBar('Access Restricted: This dashboard is exclusively for Clients. Suppliers & Vendors please use the Supplier Web Portal.', isError: true);
        }
        return;
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close modal if open
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        _showSnackBar(result.message ?? 'Login failed. Please check your credentials.', isError: true);
      }
    }
  }

  Future<void> _handleRegister(StateSetter setModalState) async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all registration fields', isError: true);
      return;
    }

    setModalState(() => _regLoading = true);
    // Strictly register as Client/Customer
    final result = await AuthService.register(name, email, password, phone, role: 'Customer');
    setModalState(() => _regLoading = false);

    if (result.success) {
      final autoLogin = await AuthService.login(email, password);
      if (autoLogin.success && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showAuthBottomSheet(isRegister: false);
        _showSnackBar('Client account created! Please sign in with your password.', isError: false);
      }
    } else {
      if (mounted) {
        _showSnackBar(result.message ?? 'Registration failed. Please try again.', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Modern Client Auth Bottom Sheet
  void _showAuthBottomSheet({required bool isRegister}) {
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
                top: 20,
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
                    const SizedBox(height: 16),

                    // Header Mode Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          inRegisterMode ? "Client Registration" : "Client Sign In",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
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
                    const SizedBox(height: 18),

                    if (!inRegisterMode) ...[
                      // Login Fields
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration("Client Email Address", Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration("Password", Icons.lock_outline),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleLogin(setModalState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Sign In as Client", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: GestureDetector(
                          onTap: () => setModalState(() => inRegisterMode = true),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              children: const [
                                TextSpan(text: "Sign Up as Client", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
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
                        decoration: _buildInputDecoration("Full Name", Icons.person_outline),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _regEmailController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration("Email Address", Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _regPhoneController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration("Phone (+94)", Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _regPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _buildInputDecoration("Password", Icons.lock_outline),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _regLoading ? null : () => _handleRegister(setModalState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _regLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Create Client Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: GestureDetector(
                          onTap: () => setModalState(() => inRegisterMode = false),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              children: const [
                                TextSpan(text: "Sign In", style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 18),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            
            // =======================================================
            // 1. TOP NAVBAR: Logo on Left, Log In & Sign Up on Right
            // =======================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.lightBlue, Colors.indigoAccent]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: "EventCraft", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            TextSpan(text: ".AI", style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Right: Log In and Sign Up buttons (Strictly Client Access)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showAuthBottomSheet(isRegister: false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text("Log In", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () => _showAuthBottomSheet(isRegister: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // =======================================================
            // 2. MIDDLE CONTENT & SINGLE FULL-SIZE LUXURY PHOTO
            // =======================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    
                    // Center Hero Text
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131C2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 12),
                          SizedBox(width: 4),
                          Text("Client Experience Portal", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(text: "Welcome to ", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          TextSpan(text: "EventCraft", style: TextStyle(color: Colors.cyanAccent, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "EventCraft is Sri Lanka's premier AI event management platform. We pair certified 5-star hotel banquet halls with verified suppliers, gourmet catering, and real-time environmental weather contingency safeguards for unforgettable weddings, galas, and celebrations.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade300, fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 20),

                    // =======================================================
                    // 3. ONLY ONE FULL-SIZE LUXURY EVENT PHOTO
                    // =======================================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Stack(
                          children: [
                            Image.network(
                              FEATURED_HERO_IMAGE,
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 240,
                                  color: const Color(0xFF131C2E),
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified_outlined, color: Colors.cyanAccent, size: 14),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "5-Star Certified Venues & Autonomous Weather Shield",
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text("SE3090 Frameworks • EventCraft AI", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    const SizedBox(height: 12),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
