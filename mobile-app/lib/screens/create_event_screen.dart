import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

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
  // Inherently indoor for: Product Launch, Dinner/Gala, Award Ceremony
  bool _isOutdoor = false;

  // Basic Details
  final _titleController = TextEditingController(text: 'Royal Wedding Celebration');
  final _guestController = TextEditingController(text: '200');
  final _budgetController = TextEditingController(text: '1500000');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 45));

  // Dynamic Services Selection
  final Set<String> _selectedServices = {'Photography', 'Decorations'};
  bool _includeOtherServices = false;
  final _customServiceNotesController = TextEditingController();

  // Special Client Requests & Additional Details (e.g. Flower Bouquet)
  final _additionalDetailsController = TextEditingController();

  // Location / Venue Selection
  // Modes: 'hotel' (Luxury Hotels & Halls), 'district' (Districts of SL), 'custom' (Private / Home Venue)
  String _locationMode = 'hotel';

  // Banquet Halls from Backend
  List<BanquetHallItem> _allHalls = [];
  bool _isLoadingHalls = false;
  String? _selectedHotelName;
  BanquetHallItem? _selectedHall;

  // District Mode State
  final List<String> _sriLankaDistricts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Galle',
    'Matara',
    'Hambantota',
    'Kurunegala',
    'Nuwara Eliya',
    'Ratnapura',
    'Badulla',
    'Anuradhapura',
    'Polonnaruwa',
    'Trincomalee',
    'Batticaloa',
    'Jaffna'
  ];
  String _selectedDistrict = 'Colombo';
  final _districtVenueNameController = TextEditingController();

  // Custom / Private Venue State
  final _customAddressController = TextEditingController();

  // Multi-Image Inspiration Photos
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBanquetHalls();
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

  bool get _isInherentlyIndoor {
    final lower = _selectedEventType.toLowerCase();
    return lower == 'product launch' || lower == 'dinner/gala' || lower.contains('award');
  }

  String get _dynamicCakeLabel {
    if (_selectedEventType == 'Wedding') return 'Wedding Cake';
    if (_selectedEventType == 'Birthday Party') return 'Birthday Cake';
    if (_selectedEventType == 'Engagement Party' || _selectedEventType == 'Anniversary') {
      return 'Anniversary / Engagement Cake';
    }
    return 'Celebration Cake';
  }

  List<String> get _hotelNames {
    final names = _allHalls.map((h) => h.venueName).toSet().toList();
    names.sort();
    return names;
  }

  List<BanquetHallItem> get _hallsForSelectedHotel {
    if (_selectedHotelName == null) return [];
    return _allHalls.where((h) => h.venueName == _selectedHotelName).toList();
  }

  void _onEventTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _selectedEventType = newType;
      if (_isInherentlyIndoor) {
        _isOutdoor = false;
      }
      // Auto suggest title
      if (_selectedEventType == 'Wedding') {
        _titleController.text = 'Grand Wedding Celebration';
      } else if (_selectedEventType == 'Birthday Party') {
        _titleController.text = 'Birthday Celebration Party';
      } else if (_selectedEventType == 'Engagement Party') {
        _titleController.text = 'Romantic Engagement Party';
      } else if (_selectedEventType == 'Anniversary') {
        _titleController.text = 'Silver Anniversary Celebration';
      } else if (_selectedEventType == 'Award Ceremony') {
        _titleController.text = 'Annual Corporate Awards Night';
      } else if (_selectedEventType == 'Dinner/Gala') {
        _titleController.text = 'Grand Gala Dinner';
      } else if (_selectedEventType == 'Product Launch') {
        _titleController.text = 'Tech Product Launch Event';
      } else if (_selectedEventType == 'Family Gathering') {
        _titleController.text = 'Family Reunion & Dinner';
      } else if (_selectedEventType == 'Private Party') {
        _titleController.text = 'Exclusive Private Party';
      }
    });
  }

  Future<void> _loadBanquetHalls() async {
    setState(() => _isLoadingHalls = true);
    try {
      final halls = await ApiService.getBanquetHalls(date: _selectedDate);
      setState(() {
        _allHalls = halls;
        if (_allHalls.isNotEmpty) {
          if (_selectedHotelName == null || !_hotelNames.contains(_selectedHotelName)) {
            _selectedHotelName = _hotelNames.first;
          }
          final availableHalls = _hallsForSelectedHotel;
          if (availableHalls.isNotEmpty) {
            _selectedHall = availableHalls.firstWhere(
              (h) => h.isAvailable,
              orElse: () => availableHalls.first,
            );
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading banquet halls: $e');
    } finally {
      if (mounted) setState(() => _isLoadingHalls = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 65,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
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
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadBanquetHalls();
    }
  }

  double get _calculatedVenueTotal {
    if (_locationMode != 'hotel' || _selectedHall == null) return 0.0;
    final guests = int.tryParse(_guestController.text) ?? 100;
    return _selectedHall!.hallRentalPrice + (_selectedHall!.perPlatePrice * guests);
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an event title.')),
        );
        return;
      }
      final g = int.tryParse(_guestController.text);
      if (g == null || g <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid guest count.')),
        );
        return;
      }
      final b = double.tryParse(_budgetController.text);
      if (b == null || b <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid budget limit.')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_locationMode == 'hotel') {
        if (_selectedHall == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a banquet hall.')),
          );
          return;
        }
        if (!_selectedHall!.isAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedHall!.hallName} is already booked. Please choose an available hall or date.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      } else if (_locationMode == 'custom') {
        if (_customAddressController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your venue address.')),
          );
          return;
        }
      }
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
    if (!_formKey.currentState!.validate()) return;

    if (_locationMode == 'hotel') {
      if (_selectedHall == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a luxury hotel and banquet hall.')),
        );
        return;
      }
      if (!_selectedHall!.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedHall!.hallName} is already booked on ${DateFormat.yMMMd().format(_selectedDate)}. Please choose another date or hall.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Convert selected images to Base64 data URLs
      List<String> base64Images = [];
      for (var img in _selectedImages) {
        final bytes = await img.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add('data:image/jpeg;base64,$base64String');
      }

      // 2. Prepare location details
      String? venueId;
      String? banquetHallId;
      String? preferredLocation;

      if (_locationMode == 'hotel') {
        venueId = _selectedHall?.venueId;
        banquetHallId = _selectedHall?.banquetHallId;
        preferredLocation = '${_selectedHall?.venueName} - ${_selectedHall?.hallName}';
      } else if (_locationMode == 'district') {
        final detail = _districtVenueNameController.text.trim();
        preferredLocation = detail.isNotEmpty ? '$_selectedDistrict District ($detail)' : '$_selectedDistrict District';
      } else {
        preferredLocation = _customAddressController.text.trim().isNotEmpty
            ? _customAddressController.text.trim()
            : 'Private Venue / Home';
      }

      // 3. Compile selected services
      final servicesList = _selectedServices.toList();
      final customNotes = _includeOtherServices ? _customServiceNotesController.text.trim() : null;
      final additionalDetails = _additionalDetailsController.text.trim();

      final guestCount = int.tryParse(_guestController.text) ?? 100;
      final budget = double.tryParse(_budgetController.text) ?? 1000000.0;

      final createdEvent = await ApiService.createEvent(
        title: _titleController.text.trim(),
        eventType: _selectedEventType,
        customEventType: _selectedEventType == 'Other' ? _customEventTypeController.text.trim() : null,
        targetDate: _selectedDate,
        guestCount: guestCount,
        budgetLimit: budget,
        isOutdoor: _isInherentlyIndoor ? false : _isOutdoor,
        additionalDetails: additionalDetails.isNotEmpty ? additionalDetails : null,
        venueId: venueId,
        banquetHallId: banquetHallId,
        preferredLocation: preferredLocation,
        selectedServices: servicesList,
        customServiceNotes: customNotes,
        inspirationImages: base64Images.isNotEmpty ? base64Images : null,
      );

      if (createdEvent != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                SizedBox(width: 10),
                Text('Request Submitted!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              'Your event request for "${_titleController.text.trim()}" has been submitted successfully.\n\nOur AI planning agents and Operations Manager will prepare a customized proposal with your requested arrangements.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Go to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit event request. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          'Plan New Event • Step ${_currentStep + 1} of 4',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: _isSubmitting ? null : _buildBottomBar(),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(height: 20),
                  Text(
                    'Generating AI Proposal & Securing Hall...',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Coordinating multi-agent workflows and vendor allocations',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Step Indicator Header
                  _buildStepperHeader(),

                  // Wizard Step Content
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
      {'title': 'Basics', 'icon': Icons.celebration},
      {'title': 'Venue', 'icon': Icons.location_city},
      {'title': 'Services', 'icon': Icons.room_service},
      {'title': 'Review', 'icon': Icons.verified_user},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isDone = _currentStep > index;
          final isActive = _currentStep == index;
          final item = steps[index];

          return Expanded(
            child: InkWell(
              onTap: isDone ? () => setState(() => _currentStep = index) : null,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFD4AF37)
                                : (isDone ? const Color(0xFF10B981) : const Color(0xFF0F172A)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFFD4AF37)
                                  : (isDone ? const Color(0xFF10B981) : Colors.white24),
                              width: isActive ? 2 : 1,
                            ),
                            boxShadow: isActive
                                ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : Icon(
                                    item['icon'] as IconData,
                                    size: 15,
                                    color: isActive ? Colors.black : Colors.white54,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFFD4AF37)
                                : (isDone ? Colors.white70 : Colors.white38),
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
                      color: isDone ? const Color(0xFF10B981) : Colors.white12,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // 2. Dynamic Step View Switcher
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

  // STEP 0: BASICS (Event Type, Title, Date, Guests & Budget)
  Widget _buildStep0Basics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 1: Event Fundamentals', Icons.celebration),
        const SizedBox(height: 4),
        const Text(
          'Tell us about your celebration theme and scale.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 14),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event Type & Occasion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedEventType,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: _eventTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: _onEventTypeChanged,
                  ),
                ),
              ),

              if (_selectedEventType == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customEventTypeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Specify Your Event Type', hint: 'e.g. Graduation Party, Fashion Show'),
                  validator: (v) => _selectedEventType == 'Other' && (v == null || v.trim().isEmpty)
                      ? 'Please specify your event type'
                      : null,
                ),
              ],

              const SizedBox(height: 16),
              const Text('Event Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Event Title', icon: Icons.title, hint: 'e.g. Royal Wedding Celebration'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 16),
              const Text('Event Setting (Indoor vs Outdoor)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),

              if (_isInherentlyIndoor) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$_selectedEventType is conducted in an Indoor (Air-Conditioned) banquet venue.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isOutdoor ? const Color(0xFFD4AF37) : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: !_isOutdoor ? const Color(0xFFD4AF37) : Colors.white24),
                          ),
                          child: Center(
                            child: Text(
                              '🏛️ Indoor (AC Hall)',
                              style: TextStyle(
                                color: !_isOutdoor ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: !_isOutdoor ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOutdoor = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isOutdoor ? const Color(0xFFD4AF37) : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _isOutdoor ? const Color(0xFFD4AF37) : Colors.white24),
                          ),
                          child: Center(
                            child: Text(
                              '🌳 Outdoor (Lawn/Garden)',
                              style: TextStyle(
                                color: _isOutdoor ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: _isOutdoor ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date, Guests & Budget Target', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),

              // Date Picker Card
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Event Date', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text('Change', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _guestController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Guest Count', icon: Icons.people),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Valid count';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Budget Limit (LKR)', icon: Icons.attach_money),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final b = double.tryParse(v ?? '');
                        if (b == null || b <= 0) return 'Valid budget';
                        return null;
                      },
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

  // STEP 1: VENUE & LOCATION SELECTION
  Widget _buildStep1Venue() {
    final curFormat = NumberFormat('#,##0', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 2: Venue & Location', Icons.location_on),
        const SizedBox(height: 4),
        const Text(
          'Select your preferred luxury hotel, banquet hall, or private location.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 14),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Selector Tabs
              Row(
                children: [
                  _buildModeChip('hotel', '🏨 Luxury Hotels'),
                  const SizedBox(width: 8),
                  _buildModeChip('district', '🗺️ Districts'),
                  const SizedBox(width: 8),
                  _buildModeChip('custom', '✏️ Private Venue'),
                ],
              ),
              const Divider(color: Colors.white12, height: 26),

              // MODE 1: HOTEL & BANQUET HALL
              if (_locationMode == 'hotel') ...[
                if (_isLoadingHalls && _allHalls.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    ),
                  )
                else if (_hotelNames.isEmpty)
                  const Text('No hotel halls found.', style: TextStyle(color: Colors.white54))
                else ...[
                  const Text('Select Luxury Hotel / Resort', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedHotelName,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
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
                  const Text('Available Banquet Halls & In-House Catering', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),

                  if (_hallsForSelectedHotel.isEmpty)
                    const Text('No halls found for this hotel.', style: TextStyle(color: Colors.white54))
                  else ...[
                    Column(
                      children: _hallsForSelectedHotel.map((hall) {
                        final isSelected = _selectedHall?.banquetHallId == hall.banquetHallId;
                        final isAvail = hall.isAvailable;
                        final matchesSetting = _isOutdoor ? hall.isOutdoor : !hall.isOutdoor;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD4AF37).withOpacity(0.12)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD4AF37)
                                  : (isAvail ? Colors.white12 : Colors.redAccent.withOpacity(0.4)),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: isAvail
                                ? () => setState(() => _selectedHall = hall)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${hall.hallName} is already booked on this date!'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        color: isSelected ? const Color(0xFFD4AF37) : Colors.white38,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          hall.hallName,
                                          style: TextStyle(
                                            color: isAvail ? Colors.white : Colors.white38,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (hall.isOutdoor)
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.teal.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            matchesSetting ? '🌳 OUTDOOR' : 'OUTDOOR',
                                            style: const TextStyle(color: Colors.tealAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isAvail ? const Color(0xFF10B981).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAvail ? 'AVAILABLE' : 'BOOKED',
                                          style: TextStyle(
                                            color: isAvail ? const Color(0xFF10B981) : Colors.redAccent,
                                            fontSize: 10,
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
                                      Text('Capacity: up to ${hall.maxCapacity} guests',
                                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                      Text('Hall Rental: LKR ${curFormat.format(hall.hallRentalPrice)}',
                                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('In-House Catering (per plate):',
                                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                                      Text('LKR ${curFormat.format(hall.perPlatePrice)} / guest',
                                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: Color(0xFFD4AF37), size: 16),
                              SizedBox(width: 8),
                              Text('In-House Hotel Catering Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hotels provide full in-house gourmet banquet buffet at LKR ${curFormat.format(_selectedHall?.perPlatePrice ?? 0)}/plate.',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          if (_selectedHall != null) ...[
                            const Divider(color: Colors.white12, height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Venue + Food Subtotal (${_guestController.text} guests):', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('LKR ${curFormat.format(_calculatedVenueTotal)}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
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
                const Text('Select Sri Lankan District', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDistrict,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: _sriLankaDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (d) => setState(() => _selectedDistrict = d ?? _selectedDistrict),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _districtVenueNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Specific Venue / Area (Optional)', hint: 'e.g. Waters Edge, Mount Lavinia'),
                ),
              ],

              // MODE 3: CUSTOM / PRIVATE VENUE
              if (_locationMode == 'custom') ...[
                const Text('Private Venue / Residence Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customAddressController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
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

  // STEP 2: SERVICES & SPECIAL REQUESTS
  Widget _buildStep2Services() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 3: Services & Custom Add-ons', Icons.checklist),
        const SizedBox(height: 4),
        const Text(
          'Select production packages, cakes, transport, and special client requests.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 14),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tailored Event Services', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildServiceFilterChip('Photography', Icons.camera_alt),
                  _buildServiceFilterChip('Sound and Lighting', Icons.speaker),
                  _buildServiceFilterChip('Decorations', Icons.park),
                  _buildServiceFilterChip(_dynamicCakeLabel, Icons.cake),
                  _buildServiceFilterChip('Luxury Transport', Icons.directions_car),
                ],
              ),
              const Divider(color: Colors.white12, height: 26),

              // Other requirements toggle
              Row(
                children: [
                  Checkbox(
                    value: _includeOtherServices,
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: Colors.black,
                    onChanged: (val) => setState(() => _includeOtherServices = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Other Custom Requirements / Add-ons',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (_includeOtherServices) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customServiceNotesController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    'Describe Other Services Needed',
                    hint: 'e.g. Traditional Dancers, Live Band, Poruwa Setup, Drone videography',
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.card_giftcard, color: Color(0xFFD4AF37), size: 18),
                  SizedBox(width: 8),
                  Text('Special Client Requests & Arrangements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Personalized touches for your special day (e.g. surprise red rose bouquet, custom welcome gifts, etc.):',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _additionalDetailsController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Special Requests & Arrangements',
                  hint: 'e.g. Arrange surprise red rose flower bouquet on arrival, VIP welcome mocktails...',
                  icon: Icons.local_florist,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.monetization_on_outlined, color: Color(0xFFD4AF37), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A coordination budget allocation of LKR 35,000 will be included in your proposal for these arrangements.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: PHOTOS & FINAL REVIEW
  Widget _buildStep3ReviewAndPhotos() {
    final curFormat = NumberFormat('#,##0', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 4: Inspiration Photos & Final Review', Icons.verified_user),
        const SizedBox(height: 4),
        const Text(
          'Upload inspiration photos and review your complete event parameters before AI compilation.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 14),

        // Inspiration Photos Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.photo_library, color: Color(0xFFD4AF37), size: 18),
                  SizedBox(width: 8),
                  Text('Inspiration & Moodboard Photos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload cake tiers, stage decor ideas, or bridal car styles for our planners & vendors:',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImages,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Pick Photos from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${_selectedImages.length} photo(s) attached:',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                          border: Border.all(color: Colors.white24),
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

        // AI Proposal Summary Card
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 18),
                  const SizedBox(width: 8),
                  const Text('AI Proposal Summary Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Text(
                      _selectedEventType,
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 20),

              _buildSummaryRow('Event Title:', _titleController.text.trim()),
              _buildSummaryRow('Target Date:', DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
              _buildSummaryRow('Setting:', _isInherentlyIndoor ? '🏛️ Indoor (AC Hall)' : (_isOutdoor ? '🌳 Outdoor Lawn' : '🏛️ Indoor AC Hall')),
              _buildSummaryRow('Guests / Budget:', '${_guestController.text} guests  •  LKR ${curFormat.format(double.tryParse(_budgetController.text) ?? 0)}'),

              if (_locationMode == 'hotel')
                _buildSummaryRow('Venue:', '${_selectedHotelName ?? "Hotel"} • ${_selectedHall?.hallName ?? "Banquet Hall"}')
              else if (_locationMode == 'district')
                _buildSummaryRow('District:', '$_selectedDistrict District ${_districtVenueNameController.text.isNotEmpty ? "(${_districtVenueNameController.text})" : ""}')
              else
                _buildSummaryRow('Private Venue:', _customAddressController.text.trim()),

              if (_selectedServices.isNotEmpty)
                _buildSummaryRow('Services (${_selectedServices.length}):', _selectedServices.join(' • ')),

              if (_additionalDetailsController.text.trim().isNotEmpty)
                _buildSummaryRow('Special Requests:', '${_additionalDetailsController.text.trim()} (+ LKR 35,000)'),

              if (_locationMode == 'hotel' && _selectedHall != null) ...[
                const Divider(color: Colors.white12, height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Venue & Catering:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      'LKR ${curFormat.format(_calculatedVenueTotal)}',
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14),
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
            color: const Color(0xFF38BDF8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.psychology, color: Color(0xFF38BDF8), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'When submitted, the Multi-Agent AI system will calculate monsoonal weather risks, allocate vendor packages, and submit for Operations Manager review.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
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
    final nextLabels = ['Next: Venue Selection', 'Next: Choose Services', 'Next: Photos & Review', 'Create Event Request'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton.icon(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white70),
                label: const Text('Back', style: TextStyle(color: Colors.white70)),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentStep == 3 ? (_isSubmitting ? null : _submitEvent) : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentStep == 3) ...[
                      const Icon(Icons.auto_awesome, color: Colors.black, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      nextLabels[_currentStep],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                    ),
                    if (_currentStep < 3) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                    ],
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildModeChip(String mode, String label) {
    final isSelected = _locationMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _locationMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white24,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
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
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.black : const Color(0xFFD4AF37)),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFF0F172A),
      selectedColor: const Color(0xFFD4AF37),
      checkmarkColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? const Color(0xFFD4AF37) : Colors.white24),
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

  InputDecoration _inputDecoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFD4AF37), size: 18) : null,
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
