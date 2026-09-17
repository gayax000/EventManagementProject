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
    final curFormat = NumberFormat('#,##0', 'en_US');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Plan New Event',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  // SECTION 1: Event Type & Basics
                  _buildSectionHeader('1. Event Type & Basics', Icons.celebration),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Event Type',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
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
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              items: _eventTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: _onEventTypeChanged,
                            ),
                          ),
                        ),
                        if (_selectedEventType == 'Other') ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _customEventTypeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Specify Your Event Type',
                              hint: 'e.g. Graduation Party, Fashion Show',
                            ),
                            validator: (v) {
                              if (_selectedEventType == 'Other' && (v == null || v.trim().isEmpty)) {
                                return 'Please specify your event type';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),

                        // SMART INDOOR / OUTDOOR SELECTION
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
                          const SizedBox(height: 14),
                        ] else ...[
                          const Text(
                            'Event Setting (Indoor vs Outdoor)',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isOutdoor = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !_isOutdoor ? const Color(0xFFD4AF37) : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: !_isOutdoor ? const Color(0xFFD4AF37) : Colors.white24,
                                      ),
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
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isOutdoor ? const Color(0xFFD4AF37) : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _isOutdoor ? const Color(0xFFD4AF37) : Colors.white24,
                                      ),
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
                          const SizedBox(height: 14),
                        ],

                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Event Title', icon: Icons.title),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION 2: Date, Guests & Budget
                  _buildSectionHeader('2. Date, Guests & Budget', Icons.calendar_month),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      children: [
                        // Date Picker
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
                                const Icon(Icons.event, color: Color(0xFFD4AF37)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Target Event Date', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                    Text(
                                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Text('Change', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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

                  const SizedBox(height: 24),

                  // SECTION 3: Venue & Location Selection
                  _buildSectionHeader('3. Venue & Location Selection', Icons.location_on),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode Selector Chips
                        Row(
                          children: [
                            _buildModeChip('hotel', '🏨 Luxury Hotels & Halls'),
                            const SizedBox(width: 8),
                            _buildModeChip('district', '🗺️ Districts'),
                            const SizedBox(width: 8),
                            _buildModeChip('custom', '✏️ Private Venue'),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 28),

                        // MODE 1: HOTEL & BANQUET HALL
                        if (_locationMode == 'hotel') ...[
                          if (_isLoadingHalls && _allHalls.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                              ),
                            )
                          else if (_hotelNames.isEmpty)
                            const Text('No hotels found.', style: TextStyle(color: Colors.white54))
                          else ...[
                            const Text(
                              'Select Luxury Hotel / Resort',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
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
                                  items: _hotelNames.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    );
                                  }).toList(),
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
                            const Text(
                              'Select Banquet Hall & In-House Catering',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
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
                                                  isSelected
                                                      ? Icons.radio_button_checked
                                                      : Icons.radio_button_off,
                                                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white38,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    hall.hallName,
                                                    style: TextStyle(
                                                      color: isAvail ? Colors.white : Colors.white38,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
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
                                                      matchesSetting ? '🌳 OUTDOOR MATCH' : 'OUTDOOR',
                                                      style: const TextStyle(color: Colors.tealAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isAvail
                                                        ? const Color(0xFF10B981).withOpacity(0.2)
                                                        : Colors.redAccent.withOpacity(0.2),
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
                              const SizedBox(height: 10),
                              // In-House catering policy note
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blueGrey.withOpacity(0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.restaurant_menu, color: Color(0xFFD4AF37), size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'In-House Hotel Catering Policy',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Hotels do not allow external food catering. When booking ${_selectedHotelName ?? "this hotel"}, buffet catering is provided directly at LKR ${curFormat.format(_selectedHall?.perPlatePrice ?? 0)}/plate.',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    if (_selectedHall != null) ...[
                                      const Divider(color: Colors.white12, height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Venue + Food Subtotal (${_guestController.text} guests):',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                          Text(
                                            'LKR ${curFormat.format(_calculatedVenueTotal)}',
                                            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],

                        // MODE 2: DISTRICT SELECTION
                        if (_locationMode == 'district') ...[
                          const Text(
                            'Select Sri Lankan District',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
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
                                items: _sriLankaDistricts.map((d) {
                                  return DropdownMenuItem<String>(value: d, child: Text(d));
                                }).toList(),
                                onChanged: (d) => setState(() => _selectedDistrict = d ?? _selectedDistrict),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _districtVenueNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Specific Venue / Area (Optional)',
                              hint: 'e.g. Waters Edge, Mount Lavinia, Local Community Hall',
                            ),
                          ),
                        ],

                        // MODE 3: CUSTOM / PRIVATE VENUE
                        if (_locationMode == 'custom') ...[
                          const Text(
                            'Private Venue / Home Address',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _customAddressController,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Enter Address / Location Details',
                              hint: 'e.g. No. 45, Flower Road, Colombo 07 (Private Residence Lawn)',
                            ),
                            validator: (v) {
                              if (_locationMode == 'custom' && (v == null || v.trim().isEmpty)) {
                                return 'Please enter venue location';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION 4: Dynamic Services Checklist
                  _buildSectionHeader('4. Select Services & Requirements', Icons.checklist),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap to include or exclude services tailored for your event:',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const Divider(color: Colors.white12, height: 24),
                        // Other requirements switch
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
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        if (_includeOtherServices) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _customServiceNotesController,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Describe Other Services Needed',
                              hint: 'e.g. Traditional Dancers, Live Band, Poruwa Ceremony Setup, Drone videography',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION 5: Special Client Requests & Additional Details
                  _buildSectionHeader('5. Special Requests & Additional Details', Icons.card_giftcard),
                  const SizedBox(height: 6),
                  const Text(
                    'Special arrangements for the day (e.g. surprise flower bouquet, custom welcome gifts, etc.):',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _additionalDetailsController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            'Special Requests & Arrangements',
                            hint: 'e.g. Arrange surprise red rose flower bouquet on arrival, VIP welcome mocktails, custom backdrop monogram...',
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
                                  'A budget allocation of LKR 35,000 will be included in your AI proposal for coordinating these custom arrangements.',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION 6: Client Inspiration & Venue Photos
                  _buildSectionHeader('6. Inspiration & Venue Photos', Icons.photo_library),
                  const SizedBox(height: 6),
                  const Text(
                    'Upload theme photos, cake designs, or decor ideas for our planners & vendors:',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImages,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD4AF37),
                            side: const BorderSide(color: Color(0xFFD4AF37)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Pick Photos from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            '${_selectedImages.length} photo(s) selected:',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                final xfile = _selectedImages[index];
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: kIsWeb
                                            ? Image.network(xfile.path, fit: BoxFit.cover)
                                            : Image.file(File(xfile.path), fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(3),
                                            child: const Icon(Icons.close, size: 16, color: Colors.white),
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

                  const SizedBox(height: 32),

                  // SUBMIT BUTTON
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.black),
                          SizedBox(width: 10),
                          Text(
                            'Create Event Request',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
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
        fontSize: 13,
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
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFD4AF37), size: 20) : null,
      filled: true,
      fillColor: const Color(0xFF0F172A),
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