import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController(text: "Luxury Gala Dinner & Awards");
  final _guestController = TextEditingController(text: "150");
  final _budgetController = TextEditingController(text: "1200000");
  final _customLocationController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 45));
  bool _isLoading = false;

  // Multi-Image Gallery State
  final List<XFile> _selectedImages = [];

  // Location Selection State
  // Mode: 'hotel' | 'district' | 'gps' | 'custom'
  String _locationMode = 'hotel';
  String _selectedHotel = "Cinnamon Grand Colombo";
  String _selectedDistrict = "Colombo";
  String _locationName = "Cinnamon Grand Colombo";
  bool _isGettingLocation = false;

  final List<String> _popularHotels = [
    "Cinnamon Grand Colombo",
    "Shangri-La Hotel Colombo",
    "The Kingsbury Colombo",
    "Hilton Colombo",
    "Cinnamon Lakeside Colombo",
    "Mount Lavinia Hotel",
    "Heritance Kandalama (Dambulla)",
    "Jetwing Lighthouse (Galle)",
    "Grand Hotel (Nuwara Eliya)",
    "Earl's Regency (Kandy)",
    "Amaya Hills (Kandy)",
    "Aliya Resort & Spa (Sigiriya)",
    "Anantara Peace Haven (Tangalle)",
    "Cape Weligama Resort",
    "Jetwing Blue (Negombo)",
  ];

  final List<String> _districts = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Mullaitivu",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Kurunegala",
    "Puttalam",
    "Anuradhapura",
    "Polonnaruwa",
    "Badulla",
    "Monaragala",
    "Ratnapura",
    "Kegalle"
  ];

  @override
  void initState() {
    super.initState();
    _locationName = _selectedHotel;
  }

  // --- Feature 1: Multi-Image Picker with Gallery Preview ---
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // --- Feature 2: GPS Location Auto-Detection ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationName = "Detecting GPS coordinates...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationName = "Location services disabled on device";
          _isGettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationName = "Location permission denied";
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationName = "Location permissions permanently denied";
          _isGettingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _locationName = "${place.locality ?? place.subAdministrativeArea ?? 'City'}, ${place.administrativeArea ?? 'Sri Lanka'} (GPS)";
          });
        } else {
          setState(() {
            _locationName = "Lat: ${position.latitude.toStringAsFixed(3)}, Lng: ${position.longitude.toStringAsFixed(3)} (GPS)";
          });
        }
      } catch (_) {
        setState(() {
          _locationName = "Lat: ${position.latitude.toStringAsFixed(3)}, Lng: ${position.longitude.toStringAsFixed(3)} (GPS)";
        });
      }
    } catch (e) {
      setState(() {
        _locationName = "GPS Detection unavailable";
      });
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _submitEvent() async {
    final title = _titleController.text.trim();
    final guestCount = int.tryParse(_guestController.text.trim()) ?? 0;
    final budgetLimit = double.tryParse(_budgetController.text.trim()) ?? 0.0;

    if (title.isEmpty || guestCount <= 0 || budgetLimit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields with valid numbers."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final created = await ApiService.createEvent(
        title: title,
        targetDate: _selectedDate.toUtc(),
        guestCount: guestCount,
        budgetLimit: budgetLimit,
        preferredLocation: _locationName,
        inspirationImages: _selectedImages.map((e) => e.name).toList(),
      );

      if (!mounted) return;

      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚀 Event Created! AI Multi-Agent analysis executed successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Pop back and trigger refresh
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating event: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan,
              onPrimary: Colors.black,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
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

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = _selectedDate.month >= 1 && _selectedDate.month <= 12 ? months[_selectedDate.month - 1] : '';
    final formattedDate = '$m ${_selectedDate.day.toString().padLeft(2, '0')}, ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Create Event Request", style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField("Event Title", _titleController),
            const SizedBox(height: 14),

            // Date Picker Field
            const Text("Target Event Date", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const Icon(Icons.calendar_today, color: Colors.cyan, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            _buildInputField("Guest Count", _guestController, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            _buildInputField("Budget Limit (LKR)", _budgetController, keyboardType: TextInputType.number),
            const SizedBox(height: 22),

            // --- Feature 1: Multi-Photo Inspiration Gallery ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "📸 EVENT VENUE / INSPIRATION PHOTOS", 
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                ),
                if (_selectedImages.isNotEmpty)
                  Text(
                    "${_selectedImages.length} photo(s)", 
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Image Gallery Thumbnails
            if (_selectedImages.isNotEmpty)
              Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      // Add More Button tile
                      return InkWell(
                        onTap: _pickImages,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 85,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyan.withOpacity(0.4), style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate, color: Colors.cyan, size: 24),
                              SizedBox(height: 4),
                              Text("Add More", style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    }

                    final file = _selectedImages[index];
                    return Stack(
                      children: [
                        Container(
                          width: 85,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FutureBuilder<Uint8List>(
                            future: file.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(snapshot.data!, fit: BoxFit.cover);
                              }
                              return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan)));
                            },
                          ),
                        ),
                        // Remove button badge
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Add Photos Button
            InkWell(
              onTap: _pickImages,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), 
                  borderRadius: BorderRadius.circular(8), 
                  border: Border.all(color: Colors.cyan.withOpacity(0.5))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_photo_alternate_rounded, color: Colors.cyan, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedImages.isEmpty 
                          ? "Select photos from your device gallery..." 
                          : "Upload more inspiration photos from gallery", 
                        style: TextStyle(color: _selectedImages.isEmpty ? Colors.white54 : Colors.cyanAccent, fontSize: 13)
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // --- Feature 2: Flexible Location Selection (Hotels / Districts / GPS) ---
            const Text(
              "📍 VENUE & LOCATION SELECTION", 
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)
            ),
            const SizedBox(height: 8),

            // Segmented mode selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildModeChip("🏨 Luxury Hotels", 'hotel'),
                  const SizedBox(width: 8),
                  _buildModeChip("🗺️ Districts", 'district'),
                  const SizedBox(width: 8),
                  _buildModeChip("📍 Auto GPS", 'gps'),
                  const SizedBox(width: 8),
                  _buildModeChip("✏️ Custom Venue", 'custom'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Location Input based on mode
            if (_locationMode == 'hotel')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedHotel,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.cyan),
                    items: _popularHotels.map((hotel) {
                      return DropdownMenuItem<String>(
                        value: hotel,
                        child: Text(hotel, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedHotel = val;
                          _locationName = val;
                        });
                      }
                    },
                  ),
                ),
              )
            else if (_locationMode == 'district')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDistrict,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.cyan),
                    items: _districts.map((district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text("$district District", overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDistrict = val;
                          _locationName = "$val District, Sri Lanka";
                        });
                      }
                    },
                  ),
                ),
              )
            else if (_locationMode == 'gps')
              InkWell(
                onTap: _isGettingLocation ? null : _getCurrentLocation,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), 
                    borderRadius: BorderRadius.circular(8), 
                    border: Border.all(color: Colors.redAccent.withOpacity(0.6))
                  ),
                  child: Row(
                    children: [
                      _isGettingLocation 
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2))
                        : const Icon(Icons.my_location_rounded, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tap to detect current GPS location", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_locationName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_locationMode == 'custom')
              TextField(
                controller: _customLocationController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  setState(() {
                    _locationName = val.isEmpty ? "Custom Location" : val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter hotel, banquet hall, or city name...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.cyan)),
                ),
              ),

            // Location Confirmation Display Card
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Target Location: $_locationName", 
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _submitEvent,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text("AI AGENTS ORCHESTRATING PLAN...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      )
                    : const Text("SUBMIT TO AI AGENTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(String label, String mode) {
    final isSelected = _locationMode == mode;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _locationMode = mode;
            if (mode == 'hotel') {
              _locationName = _selectedHotel;
            } else if (mode == 'district') {
              _locationName = "$_selectedDistrict District, Sri Lanka";
            } else if (mode == 'custom') {
              _locationName = _customLocationController.text.isNotEmpty ? _customLocationController.text : "Custom Venue";
            } else if (mode == 'gps') {
              _getCurrentLocation();
            }
          });
        }
      },
      selectedColor: Colors.cyan.shade700,
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60, 
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      side: BorderSide(color: isSelected ? Colors.cyanAccent : Colors.white12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.cyan)),
          ),
        ),
      ],
    );
  }
}