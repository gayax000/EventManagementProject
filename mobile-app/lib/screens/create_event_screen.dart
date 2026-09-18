import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'proposal_details_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController(text: "TechCraft 10th Anniversary Dinner");
  final _guestController = TextEditingController(text: "120");
  final _budgetController = TextEditingController(text: "1000000");

  DateTime _selectedDate = DateTime(2026, 11, 15);
  String _selectedCategory = "Corporate Gala";
  String _selectedLocation = "Nuwara Eliya Grounds (GPS: 6.9497° N, 80.7891° E)";

  bool _weatherSafeguardEnabled = true;
  bool _budgetOptimizationEnabled = true;

  final List<String> _photos = [
    "photo_1.jpg",
    "venue_setup.png",
    "inspiration_theme.jpg",
  ];

  final List<Map<String, dynamic>> _categories = [
    {"label": "Corporate Gala", "icon": Icons.business_center_rounded},
    {"label": "Wedding & Reception", "icon": Icons.favorite_rounded},
    {"label": "Concert & Music", "icon": Icons.music_note_rounded},
    {"label": "Private Celebration", "icon": Icons.cake_rounded},
    {"label": "Conference / Tech", "icon": Icons.laptop_mac_rounded},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _guestController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C6FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _triggerAiAgentPipeline() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AiOrchestrationProgressSheet(
        eventTitle: _titleController.text,
        dateStr: _formatDate(_selectedDate),
        guestCount: _guestController.text,
        location: _selectedLocation,
        onComplete: () {
          Navigator.pop(ctx); // Close sheet
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProposalDetailsScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create Event Request",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // AI Standing By Badge
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 13),
                const SizedBox(width: 5),
                Text(
                  "AI AGENTS ACTIVE",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // HERO AI ORCHESTRATION BANNER
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F2647).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFF00C6FF).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00C6FF).withOpacity(0.15),
                      ),
                      child: const Icon(Icons.hub_rounded, color: Color(0xFF38BDF8), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Autonomous Multi-Agent Orchestration",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Submit your vision. Our Weather, Venue & Resource AI Agents will cross-evaluate risks and auto-generate an optimized proposal.",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 1: EVENT CATEGORY SELECTION
              // ==========================================
              _buildSectionTitle("SELECT EVENT CATEGORY"),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat["label"];
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat["label"];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0284C7).withOpacity(0.25)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00C6FF)
                                : Colors.white10,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat["icon"],
                              size: 16,
                              color: isSelected ? const Color(0xFF00C6FF) : Colors.white60,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat["label"],
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // ==========================================
              // SECTION 2: BASIC SPECIFICATIONS
              // ==========================================
              _buildSectionTitle("EVENT SPECIFICATIONS"),
              const SizedBox(height: 10),

              // Event Title
              _buildInputCard(
                label: "Event Title",
                hint: "e.g. Annual Gala, Launch Party",
                icon: Icons.title_rounded,
                controller: _titleController,
              ),
              const SizedBox(height: 14),

              // Target Date Picker Card
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Target Event Date",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatDate(_selectedDate),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Change",
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF38BDF8), size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Expected Guests & Quick Selector Chips
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Expected Guest Count",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _guestController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        hintText: "Enter guest count",
                        hintStyle: const TextStyle(color: Colors.white30),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quick selector chips
                    Row(
                      children: [
                        const Text("Quick: ", style: TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(width: 4),
                        ...["50", "100", "120", "250", "500+"].map((count) {
                          final countVal = count.replaceAll("+", "");
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                setState(() {
                                  _guestController.text = countVal;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _guestController.text == countVal
                                        ? const Color(0xFF00C6FF)
                                        : Colors.white12,
                                  ),
                                ),
                                child: Text(
                                  count,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _guestController.text == countVal
                                        ? const Color(0xFF00C6FF)
                                        : Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Budget Limit Input
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payments_rounded, color: Color(0xFF38BDF8), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Budget Ceiling (LKR)",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "AI Tier: Premium",
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF4ADE80),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text("Rs.", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        hintText: "1000000",
                        hintStyle: const TextStyle(color: Colors.white30),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // DEVICE FEATURE 1: PHOTOS & INSPIRATION (SPEC PAGE 4)
              // ==========================================
              _buildSectionTitle("📷 VENUE & THEME INSPIRATION (CAMERA / PHOTOS)"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnails list
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._photos.map((photo) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00C6FF).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image_rounded, size: 14, color: Color(0xFF00C6FF)),
                              const SizedBox(width: 6),
                              Text(
                                photo,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photos.remove(photo);
                                  });
                                },
                                child: const Icon(Icons.close, size: 14, color: Colors.white38),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons for Camera & Gallery
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF38BDF8)),
                            label: Text(
                              "Take Photo",
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() {
                                _photos.add("camera_capture_${_photos.length + 1}.jpg");
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Photo captured from Camera (Simulated)"), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library_rounded, size: 16, color: Color(0xFF38BDF8)),
                            label: Text(
                              "Upload Idea",
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() {
                                _photos.add("layout_blueprint.png");
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Selected from Gallery"), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // DEVICE FEATURE 2: GPS LOCATION (SPEC PAGE 4)
              // ==========================================
              _buildSectionTitle("📍 GPS VENUE SELECTION"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Color(0xFFF87171), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Target Coordinates",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedLocation,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4ADE80),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "GPS Locked (Accuracy: ± 4m)",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF4ADE80),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF38BDF8)),
                        label: Text(
                          "Detect Current Device GPS Location",
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedLocation = "Nuwara Eliya Grounds (GPS: 6.9497° N, 80.7891° E)";
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("📍 Device GPS Location synced: Nuwara Eliya Grounds"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // SECTION 3: AUTONOMOUS SAFEGUARD TOGGLES
              // ==========================================
              _buildSectionTitle("🤖 AUTONOMOUS AI SAFEGUARDS"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: "Autonomous Weather Risk Safeguard",
                      subtitle: "Auto-adds Marquee Tent / Indoor contingency if rain forecast > 50%",
                      value: _weatherSafeguardEnabled,
                      onChanged: (val) => setState(() => _weatherSafeguardEnabled = val),
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _buildSwitchTile(
                      title: "Autonomous Resource Optimizer",
                      subtitle: "AI balances catering and AV audio packages within budget limits",
                      value: _budgetOptimizationEnabled,
                      onChanged: (val) => setState(() => _budgetOptimizationEnabled = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==========================================
              // SUBMIT BUTTON BAR
              // ==========================================
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00C6FF),
                      Color(0xFF0072FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C6FF).withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _triggerAiAgentPipeline,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "SUBMIT TO AI AGENTS",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Triggers LangGraph Weather, Venue & Resource Multi-Agent Pipeline",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF38BDF8),
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00C6FF),
          activeTrackColor: const Color(0xFF0284C7).withOpacity(0.4),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white10,
        ),
      ],
    );
  }
}

// ==========================================
// AI MULTI-AGENT PIPELINE PROGRESS SHEET
// ==========================================
class _AiOrchestrationProgressSheet extends StatefulWidget {
  final String eventTitle;
  final String dateStr;
  final String guestCount;
  final String location;
  final VoidCallback onComplete;

  const _AiOrchestrationProgressSheet({
    required this.eventTitle,
    required this.dateStr,
    required this.guestCount,
    required this.location,
    required this.onComplete,
  });

  @override
  State<_AiOrchestrationProgressSheet> createState() => _AiOrchestrationProgressSheetState();
}

class _AiOrchestrationProgressSheetState extends State<_AiOrchestrationProgressSheet> {
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _startOrchestrationSimulation();
  }

  Future<void> _startOrchestrationSimulation() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _currentStep = 2);

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _currentStep = 3);

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _currentStep = 4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF00C6FF), width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00C6FF).withOpacity(0.15),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Multi-Agent Orchestration",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "LangGraph Coordinator Synthesizing Proposal",
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Steps list
          _buildAgentStep(
            index: 1,
            title: "Venue & Capacity Agent",
            detail: "Confirmed Nuwara Eliya grounds for ${widget.guestCount} guests",
            isDone: _currentStep > 1,
            isActive: _currentStep == 1,
          ),
          const SizedBox(height: 12),
          _buildAgentStep(
            index: 2,
            title: "Weather Intelligence Agent",
            detail: "Target date ${widget.dateStr}: Rain probability 70% detected",
            isDone: _currentStep > 2,
            isActive: _currentStep == 2,
          ),
          const SizedBox(height: 12),
          _buildAgentStep(
            index: 3,
            title: "Safety & Resource Safeguard Agent",
            detail: "Auto-included Waterproof Marquee Tent safeguard (Rs. 150,000)",
            isDone: _currentStep > 3,
            isActive: _currentStep == 3,
          ),
          const SizedBox(height: 12),
          _buildAgentStep(
            index: 4,
            title: "Proposal Ready for Manager Approval",
            detail: "Subtotal Rs. 900,000 compiled under budget ceiling",
            isDone: _currentStep >= 4,
            isActive: _currentStep == 4,
          ),

          const SizedBox(height: 26),

          if (_currentStep < 4)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C6FF)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Agents communicating...",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onComplete,
                child: Text(
                  "VIEW GENERATED PROPOSAL",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAgentStep({
    required int index,
    required String title,
    required String detail,
    required bool isDone,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFF10B981)
                : (isActive ? const Color(0xFF0284C7) : const Color(0xFF1E293B)),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : (isActive
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text("$index", style: const TextStyle(color: Colors.white38, fontSize: 11))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: isDone || isActive ? Colors.white : Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: GoogleFonts.plusJakartaSans(
                  color: isDone || isActive ? Colors.white70 : Colors.white24,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}