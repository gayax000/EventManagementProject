import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  final String? initialEventType;
  const CreateEventScreen({super.key, this.initialEventType});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Wizard Step State: 0: Basics, 1: Venue, 2: Services, 3: Photos & Review
  int _currentStep = 0;

  // Event Type
  final List<String> _eventTypes = [
    'Wedding',
    'Birthday Party',
    'Engagement Party',
    'Anniversary',
    'Award Ceremony',
    'Dinner/Gala',
    'Family Gathering',
    'Private Party',
    'Product Launch',
    'Other'
  ];
  String _selectedEventType = 'Wedding';
  final _customEventTypeController = TextEditingController();

  // Smart Indoor / Outdoor Selection
  bool _isOutdoor = false;

  // Basic Details
  final _titleController = TextEditingController(text: 'Royal Wedding Celebration');
  final _guestController = TextEditingController(text: '200');
  final _budgetController = TextEditingController(text: '1500000');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 45));

  // Dynamic Session, Catering & Food Checkbox Options
  String _selectedSession = 'DayLunch'; // DayLunch, NightDinner, EveningHighTea
  String _selectedCateringStyle = 'InternationalBuffet'; // InternationalBuffet, OutdoorBBQ, HighTeaCanape, SriLankanHeritage
  
  bool _hasWelcomeMocktails = true;
  bool _hasTableRefreshments = true;
  bool _hasDesserts = true;
  bool _hasCoffeeBar = true;
  bool _hasMidnightSnack = false;

  List<String> get _selectedTableRefreshments {
    return [
      if (_hasWelcomeMocktails) 'Welcome Mocktails & Refreshing Drinks Bar',
      if (_hasTableRefreshments) 'Table Refreshments & Savory Snacks',
      if (_hasDesserts) 'Desserts & Sweet Counters',
      if (_hasCoffeeBar) 'Ceylon Tea & Artisanal Coffee Bar',
      if (_hasMidnightSnack) 'Midnight Snack / Live Food Action Station',
    ];
  }

  void _applyOccasionAutoPreset(String occasion) {
    final occ = occasion.toLowerCase();
    _selectedServices.clear();

    // Reset Food Addon Checkboxes
    _hasWelcomeMocktails = true;
    _hasTableRefreshments = true;
    _hasDesserts = true;
    _hasCoffeeBar = true;
    _hasMidnightSnack = _selectedSession == 'NightDinner';

    if (occ.contains('wedding')) {
      _selectedServices.addAll({'Photography', 'Decorations', 'Cake Tiering', 'Bridal Transport'});
      _selectedCateringStyle = 'InternationalBuffet';
    } else if (occ.contains('birthday')) {
      _selectedServices.addAll({'Photography', 'Decorations', 'Sound and Lighting', 'Cake Tiering'});
      _selectedServices.remove('Bridal Transport');
      _selectedCateringStyle = 'OutdoorBBQ';
    } else if (occ.contains('engagement') || occ.contains('anniversary')) {
      _selectedServices.addAll({'Photography', 'Decorations', 'Cake Tiering'});
      if (occ.contains('engagement')) _selectedServices.add('Bridal Transport');
      else _selectedServices.remove('Bridal Transport');
      _selectedCateringStyle = 'HighTeaCanape';
    } else {
      _selectedServices.addAll({'Photography', 'Decorations', 'Sound and Lighting'});
      _selectedServices.remove('Bridal Transport');
      _selectedCateringStyle = 'InternationalBuffet';
    }
  }

  // Dynamic Services Selection
  final Set<String> _selectedServices = {'Photography', 'Decorations'};
  final _customServiceNotesController = TextEditingController();

  // Special Client Requests & Additional Details
  final _additionalDetailsController = TextEditingController();

  // Location / Venue Selection
  String _locationMode = 'hotel';

  // Mode 1: Hotel & Banquet Hall Dropdowns
  List<BanquetHallItem> _allHalls = [];
  bool _isLoadingHalls = false;
  String? _selectedHotelName;
  BanquetHallItem? _selectedHall;

  // Mode 2: District Selection
  String _selectedDistrict = 'Colombo';
  final _districtVenueNameController = TextEditingController();

  // Mode 3: Custom / Private Venue
  final _customAddressController = TextEditingController();

  // Photo / Moodboard upload (up to 5 images)
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  final List<String> _sriLankaDistricts = [
    'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya',
    'Galle', 'Matara', 'Hambantota', 'Jaffna', 'Kilinochchi', 'Mannar',
    'Vavuniya', 'Mullaitivu', 'Batticaloa', 'Ampara', 'Trincomalee',
    'Kurunegala', 'Puttalam', 'Anuradhapura', 'Polonnaruwa', 'Badulla',
    'Monaragala', 'Ratnapura', 'Kegalle'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialEventType != null && _eventTypes.contains(widget.initialEventType)) {
      _selectedEventType = widget.initialEventType!;
      _titleController.text = '$_selectedEventType Celebration';
    }
    _applyOccasionDefaults();
    _fetchHalls();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _guestController.dispose();
    _budgetController.dispose();
    _customEventTypeController.dispose();
    _customServiceNotesController.dispose();
    _additionalDetailsController.dispose();
    _districtVenueNameController.dispose();
    _customAddressController.dispose();
    super.dispose();
  }

  void _applyOccasionDefaults() {
    switch (_selectedEventType) {
      case 'Wedding':
        _guestController.text = '250';
        _budgetController.text = '2500000';
        _selectedServices.addAll({'Photography', 'Decorations', 'Live Band / DJ', 'Wedding Cake Tier'});
        _isOutdoor = false;
        break;
      case 'Birthday Party':
        _guestController.text = '80';
        _budgetController.text = '600000';
        _selectedServices.addAll({'Photography', 'Decorations', 'Birthday Cake'});
        _isOutdoor = false;
        break;
      case 'Engagement Party':
        _guestController.text = '120';
        _budgetController.text = '1200000';
        _selectedServices.addAll({'Photography', 'Decorations', 'Live Band / DJ'});
        _isOutdoor = false;
        break;
      case 'Dinner/Gala':
      case 'Award Ceremony':
      case 'Product Launch':
        _guestController.text = '300';
        _budgetController.text = '3500000';
        _selectedServices.addAll({'Photography', 'Sound and Lighting', 'Decorations', 'Luxury Transport'});
        _isOutdoor = false;
        break;
      case 'Family Gathering':
        _guestController.text = '150';
        _budgetController.text = '900000';
        _selectedServices.addAll({'Photography', 'Decorations'});
        _isOutdoor = true;
        break;
      default:
        break;
    }
  }

  bool get _isInherentlyIndoor {
    return _selectedEventType == 'Product Launch' ||
        _selectedEventType == 'Dinner/Gala' ||
        _selectedEventType == 'Award Ceremony';
  }

  void _onEventTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _selectedEventType = newType;
      _applyOccasionAutoPreset(newType);
      if (_titleController.text.isEmpty ||
          _titleController.text.endsWith('Celebration') ||
          _titleController.text.endsWith('Party') ||
          _titleController.text.endsWith('Event')) {
        _titleController.text = '$_selectedEventType Celebration';
      }
      _applyOccasionDefaults();
    });
  }

  Future<void> _fetchHalls() async {
    setState(() => _isLoadingHalls = true);
    try {
      final halls = await ApiService.getBanquetHalls(date: _selectedDate, session: _selectedSession);
      if (mounted) {
        setState(() {
          _allHalls = halls;
          _isLoadingHalls = false;
          if (_hotelNames.isNotEmpty) {
            if (_selectedHotelName == null || !_hotelNames.contains(_selectedHotelName)) {
              _selectedHotelName = _hotelNames.first;
            }
            final available = _hallsForSelectedHotel;
            if (available.isNotEmpty) {
              _selectedHall = available.firstWhere(
                (h) => h.isAvailable,
                orElse: () => available.first,
              );
            }
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHalls = false);
    }
  }

  int get _currentGuestCount {
    return int.tryParse(_guestController.text.trim()) ?? 0;
  }

  List<BanquetHallItem> get _filteredHalls {
    final guests = _currentGuestCount;
    return _allHalls.where((h) {
      // 1. Capacity check: Must accommodate the client's guest count
      if (guests > 0 && h.maxCapacity < guests) {
        return false;
      }
      // 2. Setting check: Indoor vs Outdoor
      if (_isOutdoor != h.isOutdoor) {
        return false;
      }
      return true;
    }).toList();
  }

  void _syncSelectedHall() {
    final hotels = _hotelNames;
    if (hotels.isNotEmpty) {
      if (_selectedHotelName == null || !hotels.contains(_selectedHotelName)) {
        _selectedHotelName = hotels.first;
      }
      final available = _hallsForSelectedHotel;
      if (available.isNotEmpty) {
        if (_selectedHall == null || !available.any((h) => h.banquetHallId == _selectedHall?.banquetHallId)) {
          _selectedHall = available.firstWhere(
            (h) => h.isAvailable,
            orElse: () => available.first,
          );
        }
      } else {
        _selectedHall = null;
      }
    } else {
      _selectedHotelName = null;
      _selectedHall = null;
    }
  }

  List<String> get _hotelNames {
    return _filteredHalls.map((h) => h.venueName).toSet().toList();
  }

  List<BanquetHallItem> get _hallsForSelectedHotel {
    if (_selectedHotelName == null) return [];
    return _filteredHalls.where((h) => h.venueName == _selectedHotelName).toList();
  }

  double get _calculatedVenueTotal {
    if (_selectedHall == null) return 0;
    final guests = double.tryParse(_guestController.text) ?? 100;
    return _selectedHall!.hallRentalPrice + (_selectedHall!.perPlatePrice * guests);
  }



  String get _dynamicCakeLabel {
    if (_selectedEventType == 'Wedding') return 'Wedding Cake Tier';
    if (_selectedEventType == 'Birthday Party') return 'Birthday Cake';
    if (_selectedEventType == 'Anniversary') return 'Anniversary Cake';
    return 'Custom Celebration Cake';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchHalls();
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 inspiration moodboard photos allowed.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        for (var img in picked) {
          if (_selectedImages.length < 5) {
            _selectedImages.add(img);
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      _syncSelectedHall();
    }
    if (_currentStep == 1 && _locationMode == 'hotel' && _selectedHall == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available banquet hall for your hotel venue.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }

    final double budget = double.tryParse(_budgetController.text) ?? 0;
    final int guests = int.tryParse(_guestController.text) ?? 100;

    if (budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target budget'), backgroundColor: Color(0xFFEF4444)),
      );
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final List<String> base64Images = [];
      for (var img in _selectedImages) {
        final bytes = await img.readAsBytes();
        final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        base64Images.add(b64);
      }

      String? venueId;
      String? banquetHallId;
      String? venueLocationStr;
      if (_locationMode == 'hotel') {
        venueId = _selectedHall?.venueId;
        banquetHallId = _selectedHall?.banquetHallId;
        venueLocationStr = '${_selectedHall?.venueName} - ${_selectedHall?.hallName}';
      } else if (_locationMode == 'district') {
        final detail = _districtVenueNameController.text.trim();
        venueLocationStr = detail.isNotEmpty ? '$_selectedDistrict District ($detail)' : '$_selectedDistrict District';
      } else {
        venueLocationStr = _customAddressController.text.trim().isNotEmpty
            ? _customAddressController.text.trim()
            : 'Private Venue / Home';
      }

      final customNotes = _customServiceNotesController.text.trim();
      final additionalDetails = _additionalDetailsController.text.trim();

      final createdEvent = await ApiService.createEvent(
        title: _titleController.text.trim(),
        eventType: _selectedEventType,
        customEventType: _selectedEventType == 'Other' ? _customEventTypeController.text.trim() : null,
        targetDate: _selectedDate,
        guestCount: guests,
        budgetLimit: budget,
        isOutdoor: _isInherentlyIndoor ? false : _isOutdoor,
        additionalDetails: additionalDetails.isNotEmpty ? additionalDetails : null,
        venueId: venueId,
        banquetHallId: banquetHallId,
        preferredLocation: venueLocationStr,
        selectedServices: _selectedServices.toList(),
        customServiceNotes: customNotes.isNotEmpty ? customNotes : null,
        inspirationImages: base64Images.isNotEmpty ? base64Images : null,
        eventSession: _selectedSession,
        tableRefreshments: _selectedTableRefreshments,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (createdEvent != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Celebration Inquiry Created! AI agents are generating your proposal.'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create event inquiry. Please check details and retry.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        var cleanMsg = e.toString().replaceAll('Exception: ', '');
        if (cleanMsg.contains('ClientException') || cleanMsg.contains('Failed to fetch') || cleanMsg.contains('SocketException')) {
          cleanMsg = "Cloud server connection timed out or is warming up. Please tap 'Submit Request' again in a few seconds.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: $cleanMsg'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Plan New Event • Step ${_currentStep + 1} of 4',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16, letterSpacing: 0.2),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      bottomNavigationBar: _isSubmitting ? null : _buildBottomBar(),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2563EB)),
                  SizedBox(height: 20),
                  Text(
                    'Generating AI Proposal & Securing Hall...',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Coordinating multi-agent workflows and vendor allocations',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildStepperHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: _buildCurrentStepView(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 1. Top Stepper Header Bar
  Widget _buildStepperHeader() {
    final steps = [
      {'title': 'Basics', 'subtitle': 'Scale & Date', 'icon': Icons.tune_rounded},
      {'title': 'Venue', 'subtitle': 'Hall & Catering', 'icon': Icons.location_city_rounded},
      {'title': 'Services', 'subtitle': 'Decor & Vision', 'icon': Icons.room_service_rounded},
      {'title': 'Review', 'subtitle': 'AI Quotation', 'icon': Icons.verified_user_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isDone = _currentStep > index;
          final isActive = _currentStep == index;
          final item = steps[index];

          return Expanded(
            child: InkWell(
              onTap: isDone ? () => setState(() => _currentStep = index) : null,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF2563EB)
                                : (isDone ? const Color(0xFF059669) : const Color(0xFFF1F5F9)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF2563EB)
                                  : (isDone ? const Color(0xFF059669) : const Color(0xFFE2E8F0)),
                              width: isActive ? 2 : 1,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                                : Icon(
                                    item['icon'] as IconData,
                                    size: 17,
                                    color: isActive ? Colors.white : const Color(0xFF64748B),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF2563EB)
                                : (isDone ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < 3)
                    Container(
                      width: 14,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 2. Wizard Current Step Switcher
  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep0Basics();
      case 1:
        return _buildStep1Venue();
      case 2:
        return _buildStep2Services();
      case 3:
        return _buildStep3ReviewAndPhotos();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 0: BASICS (Event Type, Title, Date, Guests & Budget) - ZERO EMOJIS
  Widget _buildStep0Basics() {
    final eventCards = [
      {'name': 'Wedding', 'icon': Icons.favorite_border_rounded},
      {'name': 'Birthday Party', 'icon': Icons.cake_outlined},
      {'name': 'Dinner/Gala', 'icon': Icons.business_center_outlined},
      {'name': 'Engagement Party', 'icon': Icons.wine_bar_outlined},
      {'name': 'Anniversary', 'icon': Icons.auto_awesome_outlined},
      {'name': 'Award Ceremony', 'icon': Icons.emoji_events_outlined},
      {'name': 'Product Launch', 'icon': Icons.rocket_launch_outlined},
      {'name': 'Family Gathering', 'icon': Icons.groups_outlined},
      {'name': 'Private Party', 'icon': Icons.celebration_outlined},
      {'name': 'Other', 'icon': Icons.more_horiz_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 1: Event Fundamentals', Icons.celebration_rounded),
        const SizedBox(height: 4),
        const Text(
          'Select your celebration occasion and scale for AI multi-agent orchestration.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 16),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Occasion & Event Theme',
                style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: eventCards.any((ec) => ec['name'] == _selectedEventType)
                    ? _selectedEventType
                    : eventCards.first['name'] as String,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB), size: 24),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                isExpanded: true,
                items: eventCards.map((ec) {
                  return DropdownMenuItem<String>(
                    value: ec['name'] as String,
                    child: Row(
                      children: [
                        Icon(ec['icon'] as IconData, size: 18, color: const Color(0xFF2563EB)),
                        const SizedBox(width: 10),
                        Text(
                          ec['name'] as String,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _onEventTypeChanged(val);
                  }
                },
              ),

              if (_selectedEventType == 'Other') ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _customEventTypeController,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration('Specify Your Event Occasion', hint: 'e.g. Graduation Ball, Fashion Runway'),
                  validator: (v) => _selectedEventType == 'Other' && (v == null || v.trim().isEmpty)
                      ? 'Please specify your event type'
                      : null,
                ),
              ],

              const SizedBox(height: 18),
              const Text('Event Title', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: _inputDecoration(null, icon: Icons.title_rounded, hint: 'e.g. Royal Wedding Celebration'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 18),
              const Text('Event Setting', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),

              if (_isInherentlyIndoor) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$_selectedEventType is conducted in an Indoor banquet venue.',
                          style: const TextStyle(color: Color(0xFF0369A1), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOutdoor = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isOutdoor ? const Color(0xFFEFF6FF) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !_isOutdoor ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: !_isOutdoor ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            'Indoor',
                            style: TextStyle(
                              color: !_isOutdoor ? const Color(0xFF2563EB) : const Color(0xFF334155),
                              fontSize: 14,
                              fontWeight: !_isOutdoor ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOutdoor = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isOutdoor ? const Color(0xFFEFF6FF) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isOutdoor ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: _isOutdoor ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            'Outdoor',
                            style: TextStyle(
                              color: _isOutdoor ? const Color(0xFF2563EB) : const Color(0xFF334155),
                              fontSize: 14,
                              fontWeight: _isOutdoor ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isOutdoor) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_sync_rounded, color: Color(0xFF0284C7), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "AI Weather Agent will compute monsoonal probability and provide canopy quotation.",
                            style: TextStyle(color: Color(0xFF0369A1), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 18),
              const Text('Preferred Event Time Slot / Session', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedSession = 'DayLunch');
                        _fetchHalls();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(
                          color: _selectedSession == 'DayLunch' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedSession == 'DayLunch' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: _selectedSession == 'DayLunch' ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('☀️', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(
                              'Day Lunch',
                              style: TextStyle(
                                color: _selectedSession == 'DayLunch' ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '10 AM - 3:30 PM',
                              style: TextStyle(
                                color: _selectedSession == 'DayLunch' ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedSession = 'NightDinner');
                        _fetchHalls();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(
                          color: _selectedSession == 'NightDinner' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedSession == 'NightDinner' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: _selectedSession == 'NightDinner' ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('🌙', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(
                              'Night Dinner',
                              style: TextStyle(
                                color: _selectedSession == 'NightDinner' ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '6 PM - 11:30 PM',
                              style: TextStyle(
                                color: _selectedSession == 'NightDinner' ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedSession = 'EveningHighTea');
                        _fetchHalls();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(
                          color: _selectedSession == 'EveningHighTea' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedSession == 'EveningHighTea' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: _selectedSession == 'EveningHighTea' ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('☕', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(
                              'High Tea',
                              style: TextStyle(
                                color: _selectedSession == 'EveningHighTea' ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '3:30 PM - 7 PM',
                              style: TextStyle(
                                color: _selectedSession == 'EveningHighTea' ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Date, Guests & Budget Target
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Target Date, Guests & Budget', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),

              // Date Picker Card
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TARGET EVENT DATE', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, letterSpacing: 0.8)),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Change', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Guest Count with +/- Stepper & Budget
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Guest Count', style: TextStyle(color: Color(0xFF475569), fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, color: Color(0xFF2563EB), size: 18),
                                onPressed: () {
                                  final n = int.tryParse(_guestController.text) ?? 100;
                                  if (n > 25) {
                                    setState(() => _guestController.text = '${n - 25}');
                                  }
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _guestController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_rounded, color: Color(0xFF2563EB), size: 18),
                                onPressed: () {
                                  final n = int.tryParse(_guestController.text) ?? 100;
                                  setState(() => _guestController.text = '${n + 25}');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Budget Limit (LKR)', style: TextStyle(color: Color(0xFF475569), fontSize: 12)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                          decoration: _inputDecoration(null, icon: Icons.payments_outlined),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 1: VENUE & LOCATION SELECTION (ZERO EMOJIS)
  Widget _buildStep1Venue() {
    final curFormat = NumberFormat('#,##0', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 2: Venue & Location', Icons.location_on),
        const SizedBox(height: 4),
        const Text(
          'Select your preferred luxury hotel, banquet hall, or private location.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 14),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Selector Tabs (Zero Emojis)
              Row(
                children: [
                  _buildModeChip('hotel', 'Hotels', Icons.apartment_rounded),
                  const SizedBox(width: 8),
                  _buildModeChip('district', 'Districts', Icons.map_outlined),
                  const SizedBox(width: 8),
                  _buildModeChip('custom', 'Private', Icons.edit_location_alt_outlined),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 26),

              // MODE 1: HOTEL & BANQUET HALL
              if (_locationMode == 'hotel') ...[
                if (_isLoadingHalls && _allHalls.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    ),
                  )
                else if (_hotelNames.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No ${_isOutdoor ? "outdoor venues" : "indoor banquet halls"} found with capacity for ${_currentGuestCount > 0 ? "$_currentGuestCount guests" : "your event"}.\n\nPlease go back to Step 1 to adjust your guest count or switch setting to ${_isOutdoor ? "Indoor" : "Outdoor"}.',
                            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Text('Select Luxury Hotel / Resort', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedHotelName,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                        items: _hotelNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                        onChanged: (name) {
                          if (name != null) {
                            setState(() {
                              _selectedHotelName = name;
                              final halls = _hallsForSelectedHotel;
                              if (halls.isNotEmpty) {
                                _selectedHall = halls.firstWhere(
                                  (h) => h.isAvailable,
                                  orElse: () => halls.first,
                                );
                              } else {
                                _selectedHall = null;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Available Banquet Halls & In-House Catering', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),

                  if (_hallsForSelectedHotel.isEmpty)
                    const Text('No halls found for this hotel.', style: TextStyle(color: Color(0xFF64748B)))
                  else ...[
                    Column(
                      children: _hallsForSelectedHotel.map<Widget>((hall) {
                        final isSelected = _selectedHall?.banquetHallId == hall.banquetHallId;
                        final isAvail = hall.isAvailable;
                        final matchesSetting = _isOutdoor ? hall.isOutdoor : !hall.isOutdoor;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : (isAvail ? const Color(0xFFE2E8F0) : const Color(0xFFEF4444).withOpacity(0.3)),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withOpacity(0.12),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: InkWell(
                            onTap: isAvail
                                ? () => setState(() => _selectedHall = hall)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${hall.hallName} is already booked on this date!'),
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                    );
                                  },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                        size: 19,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          hall.hallName,
                                          style: TextStyle(
                                            color: isAvail ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (hall.isOutdoor)
                                        Container(
                                          margin: const EdgeInsets.only(right: 5),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFA7F3D0)),
                                          ),
                                          child: const Text(
                                            'OUTDOOR',
                                            style: TextStyle(color: Color(0xFF059669), fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isAvail ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: isAvail ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                                        ),
                                        child: Text(
                                          isAvail ? 'AVAILABLE' : 'BOOKED',
                                          style: TextStyle(
                                            color: isAvail ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.people_alt_rounded, color: Color(0xFF64748B), size: 14),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Up to ${hall.maxCapacity} guests',
                                                style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Hall: LKR ${curFormat.format(hall.hallRentalPrice)}',
                                        style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12.5, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.restaurant_rounded, color: Color(0xFF64748B), size: 14),
                                            const SizedBox(width: 4),
                                            const Flexible(
                                              child: Text(
                                                'Buffet:',
                                                style: TextStyle(color: Color(0xFF475569), fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'LKR ${curFormat.format(hall.perPlatePrice)} / plate',
                                        style: const TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),
                    Container(
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
                              Icon(Icons.restaurant_menu_rounded, color: Color(0xFF2563EB), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'In-House Catering Policy',
                                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hotels provide banquet buffet service at LKR ${curFormat.format(_selectedHall?.perPlatePrice ?? 0)}/plate.',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          ),
                          if (_selectedHall != null) ...[
                            const Divider(color: Color(0xFFE2E8F0), height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Subtotal (${_guestController.text.trim()} guests):',
                                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'LKR ${curFormat.format(_calculatedVenueTotal)}',
                                  style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ],

              // MODE 2: DISTRICT SELECTION
              if (_locationMode == 'district') ...[
                const Text('Select Sri Lankan District', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDistrict,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                      items: _sriLankaDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (d) => setState(() => _selectedDistrict = d ?? _selectedDistrict),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _districtVenueNameController,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration('Specific Venue / Area (Optional)', hint: 'e.g. Waters Edge, Mount Lavinia'),
                ),
              ],

              // MODE 3: CUSTOM / PRIVATE VENUE
              if (_locationMode == 'custom') ...[
                const Text('Private Venue / Residence Address', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customAddressController,
                  maxLines: 2,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: _inputDecoration(
                    'Enter Address / Location Details',
                    hint: 'e.g. No. 45, Flower Road, Colombo 07 (Private Residence Lawn)',
                  ),
                  validator: (v) => _locationMode == 'custom' && (v == null || v.trim().isEmpty)
                      ? 'Please enter venue location'
                      : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: SERVICES, INSPIRATION PHOTOS & CLIENT VISION CHATBOX
  Widget _buildStep2Services() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 3: Services, Inspiration & Vision', Icons.checklist_rounded),
        const SizedBox(height: 4),
        const Text(
          'Select production packages, attach moodboard photos, and describe your vision for our Operations Manager.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 14),

        // 1. Catering Style Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.restaurant_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text('Catering Package & Culinary Style', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  {'id': 'InternationalBuffet', 'name': 'International Buffet', 'icon': '🍽️'},
                  {'id': 'OutdoorBBQ', 'name': 'Outdoor Live BBQ', 'icon': '🍖'},
                  {'id': 'HighTeaCanape', 'name': 'High Tea Canapé', 'icon': '☕'},
                  {'id': 'SriLankanHeritage', 'name': 'Sri Lankan Heritage', 'icon': '🍲'},
                ].map((c) {
                  final isSel = _selectedCateringStyle == c['id'];
                  return InkWell(
                    onTap: () => setState(() => _selectedCateringStyle = c['id']!),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          width: isSel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c['icon']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            c['name']!,
                            style: TextStyle(
                              color: isSel ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
                              fontSize: 11.5,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Event Food & Refreshment Add-Ons (Smart Budget Engine)', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('🍹 Welcome Mocktails & Refreshing Drinks Bar', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w500)),
                activeColor: const Color(0xFF2563EB),
                checkColor: Colors.white,
                value: _hasWelcomeMocktails,
                onChanged: (val) => setState(() => _hasWelcomeMocktails = val ?? false),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('🥪 Table Refreshments & Savory Snacks', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w500)),
                activeColor: const Color(0xFF2563EB),
                checkColor: Colors.white,
                value: _hasTableRefreshments,
                onChanged: (val) => setState(() => _hasTableRefreshments = val ?? false),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('🍨 Desserts & Sweet Counters', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w500)),
                activeColor: const Color(0xFF2563EB),
                checkColor: Colors.white,
                value: _hasDesserts,
                onChanged: (val) => setState(() => _hasDesserts = val ?? false),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('☕ Ceylon Tea & Artisanal Coffee Bar', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w500)),
                activeColor: const Color(0xFF2563EB),
                checkColor: Colors.white,
                value: _hasCoffeeBar,
                onChanged: (val) => setState(() => _hasCoffeeBar = val ?? false),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('🍕 Midnight Snack / Live Food Action Station', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w500)),
                activeColor: const Color(0xFF2563EB),
                checkColor: Colors.white,
                value: _hasMidnightSnack,
                onChanged: (val) => setState(() => _hasMidnightSnack = val ?? false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Service Selection Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tailored Event Services (Auto-Preset Engine)', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildServiceFilterChip('Photography', Icons.camera_alt),
                  _buildServiceFilterChip('Sound and Lighting', Icons.speaker),
                  _buildServiceFilterChip('Decorations', Icons.park),
                  _buildServiceFilterChip(_dynamicCakeLabel, Icons.cake),
                  if (_selectedEventType == 'Wedding' || _selectedEventType == 'Engagement')
                    _buildServiceFilterChip('Bridal Transport', Icons.directions_car),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Inspiration Photos Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text('Inspiration & Moodboard Photos', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload cake tiers, stage decor ideas, or bridal car styles for our planners & vendors:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImages,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('Pick Photos from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${_selectedImages.length} photo(s) attached:',
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final xfile = _selectedImages[index];
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(xfile.path, fit: BoxFit.cover)
                                  : Image.file(File(xfile.path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Client Vision & Requirements Chatbox Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text('Client Vision & Special Notes Chatbox', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Type your custom vision, specific photo instructions, theme preferences, or special requests for our Operations Manager:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _additionalDetailsController,
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: _inputDecoration(
                  'Client Vision & Special Notes',
                  hint: 'e.g. I want a pastel floral theme on stage with warm fairy lights, like in photo 1. Please arrange VIP welcome mocktails on arrival...',
                  icon: Icons.edit_note_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: FINAL REVIEW & SUBMISSION (ZERO EMOJIS)
  Widget _buildStep3ReviewAndPhotos() {
    final curFormat = NumberFormat('#,##0', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 4: Final Review & Submission', Icons.verified_user_outlined),
        const SizedBox(height: 4),
        const Text(
          'Review your complete event parameters, attached photos, and client vision notes before AI compilation.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 14),

        // AI Proposal Summary Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 8),
                  const Text('AI Proposal Summary Preview', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      _selectedEventType,
                      style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 20),

              _buildSummaryRow('Event Title:', _titleController.text.trim()),
              _buildSummaryRow('Target Date:', DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
              _buildSummaryRow('Setting:', _isInherentlyIndoor ? 'Indoor' : (_isOutdoor ? 'Outdoor' : 'Indoor')),
              _buildSummaryRow('Guests / Budget:', '${_guestController.text} guests  •  LKR ${curFormat.format(double.tryParse(_budgetController.text) ?? 0)}'),

              if (_locationMode == 'hotel')
                _buildSummaryRow('Venue:', '${_selectedHotelName ?? "Hotel"} • ${_selectedHall?.hallName ?? "Banquet Hall"}')
              else if (_locationMode == 'district')
                _buildSummaryRow('District:', '$_selectedDistrict District ${_districtVenueNameController.text.isNotEmpty ? "(${_districtVenueNameController.text})" : ""}')
              else
                _buildSummaryRow('Private Venue:', _customAddressController.text.trim()),

              if (_selectedServices.isNotEmpty)
                _buildSummaryRow('Services (${_selectedServices.length}):', _selectedServices.join(' • ')),

              if (_selectedTableRefreshments.isNotEmpty)
                _buildSummaryRow('Food Refreshments (${_selectedTableRefreshments.length}):', _selectedTableRefreshments.join(' • ')),

              if (_selectedImages.isNotEmpty)
                _buildSummaryRow('Inspiration Photos:', '${_selectedImages.length} photo(s) attached'),

              if (_additionalDetailsController.text.trim().isNotEmpty)
                _buildSummaryRow('Client Vision Notes:', '${_additionalDetailsController.text.trim()} (Priced by Manager upon Review)'),

              if (_locationMode == 'hotel' && _selectedHall != null) ...[
                const Divider(color: Color(0xFFE2E8F0), height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimated Venue & Catering:',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LKR ${curFormat.format(_calculatedVenueTotal)}',
                      style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Multi-Agent Notice Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: const [
              Icon(Icons.psychology_outlined, color: Color(0xFF0284C7), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'When submitted, the Multi-Agent AI system will calculate monsoonal weather risks, allocate vendor packages, and submit for Operations Manager review.',
                  style: TextStyle(color: Color(0xFF0369A1), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Bottom Navigation Bar
  Widget _buildBottomBar() {
    final nextLabels = ['Next: Venue ➔', 'Next: Services ➔', 'Next: Review ➔', 'Submit Request'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton.icon(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF475569)),
                label: const Text('Back', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentStep == 3 ? (_isSubmitting ? null : _submitEvent) : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentStep == 3) ...[
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      nextLabels[_currentStep],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildModeChip(String mode, String label, IconData icon) {
    final isSelected = _locationMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _locationMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceFilterChip(String label, IconData icon) {
    final isSelected = _selectedServices.contains(label);
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFEFF6FF),
      checkmarkColor: const Color(0xFF2563EB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedServices.add(label);
          } else {
            _selectedServices.remove(label);
          }
        });
      },
    );
  }

  InputDecoration _inputDecoration(String? label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF2563EB), size: 18) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
