import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class ShowcasePhoto {
  final String title;
  final String category;
  final String tag;
  final String imageUrl;
  final String description;

  const ShowcasePhoto({
    required this.title,
    required this.category,
    required this.tag,
    required this.imageUrl,
    required this.description,
  });
}

const List<ShowcasePhoto> CURATED_SHOWCASE_PHOTOS = [
  ShowcasePhoto(
    title: 'Royal Grand Ballroom & Chandeliers',
    category: '5-Star Venues',
    tag: '5-Star Luxury',
    imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
    description: 'Opulent hotel banquet halls with crystal chandelier lighting, round banquet dining, and climate control.',
  ),
  ShowcasePhoto(
    title: 'Sunset Garden & Coastal Reception',
    category: 'Scenic Lawns',
    tag: 'Weather Protected',
    imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
    description: 'Enchanting open-air celebrations beneath fairy-light canopies, backed by autonomous weather safeguards.',
  ),
  ShowcasePhoto(
    title: 'Concert Line-Array Sound & Lights',
    category: 'AudioVisual',
    tag: 'Tour-Grade Rig',
    imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80',
    description: 'Line-array audio rigs, digital mixing consoles, and moving-head beam trusses for electrifying atmospheres.',
  ),
  ShowcasePhoto(
    title: 'Fresh Floral Stage Cascades',
    category: 'Floral Decor',
    tag: 'Master Florists',
    imageUrl: 'https://images.unsplash.com/photo-1520854221256-17451cc331bf?auto=format&fit=crop&w=800&q=80',
    description: 'Bespoke floral backdrops, entrance tunnel archways, geometric frames, and luxurious tablescapes.',
  ),
  ShowcasePhoto(
    title: 'Artisanal Fondant Celebration Cakes',
    category: 'Celebration Cakes',
    tag: 'Bespoke Sugar Art',
    imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13136?auto=format&fit=crop&w=800&q=80',
    description: 'Handcrafted 3-to-5 tier fondant showstoppers decorated with edible sugar blooms and custom branding.',
  ),
  ShowcasePhoto(
    title: 'Cinematic 4K Media & Drone Coverage',
    category: 'Photography',
    tag: '4K Deliverables',
    imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=800&q=80',
    description: 'Award-winning photojournalism, cinematic 4K video reels, drone perspectives, and leather-bound albums.',
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginTab = true;

  // Login Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  String _regRole = 'Customer';
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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in both email and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.login(email, password);
    setState(() => _isLoading = false);

    if (result.success) {
      if (mounted) {
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

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all registration fields', isError: true);
      return;
    }

    setState(() => _regLoading = true);
    final result = await AuthService.register(name, email, password, phone, role: _regRole);
    setState(() => _regLoading = false);

    if (result.success) {
      // Auto login
      final autoLogin = await AuthService.login(email, password);
      if (autoLogin.success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        setState(() {
          _isLoginTab = true;
          _emailController.text = email;
        });
        _showSnackBar('Account created successfully! Please log in.', isError: false);
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
        backgroundColor: isError ? Colors.redAccent.shade700 : Colors.emerald.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showImageZoomModal(ShowcasePhoto photo) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFF0F172A),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InteractiveViewer(
                      clipBehavior: Clip.none,
                      maxScale: 3.5,
                      child: Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 250,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                                ),
                                child: Text(photo.tag, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Text(photo.category, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(photo.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(photo.description, style: TextStyle(color: Colors.grey.shade300, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // =======================================================
              // 1. TOP APP BAR & AUTH TAB SWITCHER
              // =======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // Brand Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.skyBlue, Colors.indigoAccent]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Text("Client & Partner", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Segmented Tabs: [Log In] and [Sign Up / Register]
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131C2E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLoginTab = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _isLoginTab ? Colors.cyan.shade600 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isLoginTab ? [BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login_rounded, size: 14, color: _isLoginTab ? Colors.white : Colors.white60),
                                    const SizedBox(width: 6),
                                    Text("Log In", style: TextStyle(color: _isLoginTab ? Colors.white : Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLoginTab = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: !_isLoginTab ? Colors.indigo.shade600 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isLoginTab ? [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add_alt_1_rounded, size: 14, color: !_isLoginTab ? Colors.white : Colors.white60),
                                    const SizedBox(width: 6),
                                    Text("Sign Up / Register", style: TextStyle(color: !_isLoginTab ? Colors.white : Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =======================================================
              // 2. WELCOME TO EVENTCRAFT HERO CARD
              // =======================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.indigo.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.indigoAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.indigoAccent.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 12),
                                SizedBox(width: 4),
                                Text("Premier AI Platform", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: "Welcome to ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            TextSpan(text: "EventCraft", style: TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Sri Lanka's leading multi-agent AI event platform. We pair 5-star certified hotel halls with verified suppliers and autonomous weather contingency safeguards for flawless celebrations.",
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 12, height: 1.45),
                      ),
                      const SizedBox(height: 16),

                      // Metrics 2x2 Grid
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard("100+", "Star Venues", Colors.cyanAccent)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard("250+", "Elite Vendors", Colors.indigoAccent)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard("100%", "Weather Shield", Colors.emeraldAccent)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard("4.9 ★", "Satisfaction", Colors.amberAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // =======================================================
              // 3. INTERACTIVE AUTH FORM SECTION (LOGIN / REGISTER)
              // =======================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131C2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: _isLoginTab ? _buildLoginForm() : _buildRegisterForm(),
                ),
              ),

              // =======================================================
              // 4. HOW EVENTCRAFT WORKS (5-STEP PROCESS)
              // =======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.layers_outlined, color: Colors.cyanAccent, size: 16),
                    const SizedBox(width: 6),
                    const Text("How EventCraft Works", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildProcessStep("01", "Define Vision", "Choose date, guests & celebration type.", Colors.cyanAccent),
                    _buildProcessStep("02", "AI Curation", "Autonomous matching of halls & buffet pricing.", Colors.indigoAccent),
                    _buildProcessStep("03", "Weather Safeguard", "Real-time rain forecast with marquee tents.", Colors.amberAccent),
                    _buildProcessStep("04", "Verified Vendors", "Concert sound, floral decor, cakes & 4K media.", Colors.pinkAccent),
                    _buildProcessStep("05", "Live Dashboard", "Itemized breakdown & instant booking.", Colors.emeraldAccent),
                  ],
                ),
              ),

              // =======================================================
              // 5. CURATED LUXURY EVENT SHOWCASE CAROUSEL
              // =======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_library_outlined, color: Colors.cyanAccent, size: 16),
                        SizedBox(width: 6),
                        Text("Curated Event Inspirations", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text("Tap to zoom", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: CURATED_SHOWCASE_PHOTOS.length,
                  itemBuilder: (context, index) {
                    final photo = CURATED_SHOWCASE_PHOTOS[index];
                    return GestureDetector(
                      onTap: () => _showImageZoomModal(photo),
                      child: Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.network(
                                    photo.imageUrl,
                                    height: 120,
                                    width: 220,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(height: 120, color: const Color(0xFF0F172A));
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(photo.tag, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(photo.category, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(photo.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(photo.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade400, fontSize: 10, height: 1.3)),
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

              const SizedBox(height: 24),
              // Footer
              Center(
                child: Text("SE3090 Frameworks • EventCraft AI", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String number, String title, String desc, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(number, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade400, fontSize: 9, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Sign In to EventCraft", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Access your AI proposals and live event statuses.", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        const SizedBox(height: 14),

        // Email
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _buildInputDecoration("Email Address", Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        // Password
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _buildInputDecoration("Password", Icons.lock_outline),
        ),
        const SizedBox(height: 16),

        // Login Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan.shade600,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Sign In to Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Join as a client or verified supplier.", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        const SizedBox(height: 14),

        TextField(
          controller: _regNameController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _buildInputDecoration("Full Name", Icons.person_outline),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _regEmailController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _buildInputDecoration("Email Address", Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _regPhoneController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _buildInputDecoration("Phone (+94)", Icons.phone_outlined),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _regPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _buildInputDecoration("Password", Icons.lock_outline),
        ),
        const SizedBox(height: 12),

        // Role Selector Row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _regRole = 'Customer'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _regRole == 'Customer' ? Colors.cyan.withOpacity(0.2) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _regRole == 'Customer' ? Colors.cyanAccent : Colors.white12),
                  ),
                  alignment: Alignment.center,
                  child: Text("Client / User", style: TextStyle(color: _regRole == 'Customer' ? Colors.cyanAccent : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _regRole = 'Vendor'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _regRole == 'Vendor' ? Colors.indigo.withOpacity(0.2) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _regRole == 'Vendor' ? Colors.indigoAccent : Colors.white12),
                  ),
                  alignment: Alignment.center,
                  child: Text("Supplier / Vendor", style: TextStyle(color: _regRole == 'Vendor' ? Colors.indigoAccent : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ElevatedButton(
          onPressed: _regLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _regLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Create My Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 18),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.2),
      ),
    );
  }
}
