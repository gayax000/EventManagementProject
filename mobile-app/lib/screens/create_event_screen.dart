import 'dart:io';
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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 45));
  bool _isLoading = false;

  // New state for Device Features
  List<XFile> _selectedImages = [];
  String _locationName = "Location not selected";
  bool _isGettingLocation = false;

  // --- Device Feature 1: Image Picker ---
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  // --- Device Feature 2: GPS Location Selection ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationName = "Detecting GPS...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationName = "Location services disabled";
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
      
      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _locationName = "${place.locality ?? place.subAdministrativeArea}, ${place.administrativeArea}";
        });
      } else {
        setState(() {
          _locationName = "Lat: ${position.latitude.toStringAsFixed(2)}, Lng: ${position.longitude.toStringAsFixed(2)}";
        });
      }
    } catch (e) {
      setState(() {
        _locationName = "Failed to get location";
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
            const SizedBox(height: 20),

            // Device Feature 1: Camera / Photos (Image Picker)
            const Text("📸 EVENT VENUE / INSPIRATION PHOTOS", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickImages,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.cyan.withOpacity(0.5))),
                child: Row(
                  children: [
                    const Icon(Icons.add_photo_alternate, color: Colors.cyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedImages.isEmpty 
                          ? "Tap to select photos..." 
                          : "${_selectedImages.length} photo(s) selected", 
                        style: TextStyle(color: _selectedImages.isEmpty ? Colors.white54 : Colors.cyanAccent, fontSize: 13)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _selectedImages.map((e) => e.name).take(2).join(" | ") + (_selectedImages.length > 2 ? " ..." : ""),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            const SizedBox(height: 20),

            // Device Feature 2: GPS Location Selection
            const Text("📍 LOCATION SELECTION (GPS)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _isGettingLocation ? null : _getCurrentLocation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                child: Row(
                  children: [
                    _isGettingLocation 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2))
                      : const Icon(Icons.location_on, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_locationName, style: TextStyle(color: _locationName.contains("not selected") ? Colors.white54 : Colors.white, fontSize: 13)),
                    ),
                  ],
                ),
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