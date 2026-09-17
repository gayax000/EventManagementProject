import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isProcessing = false;
  bool _resultShown = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    if (_isProcessing || _resultShown) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // Only process EventCraft QR codes
    if (!rawValue.startsWith('EVENTCRAFT|')) {
      if (!_resultShown) {
        _showResultDialog(
          isValid: false,
          isAlreadyUsed: false,
          title: '❌ Invalid QR Code',
          message: 'This QR code does not belong to an EventCraft Entry Pass.\n\nPlease scan the official pass from the customer\'s mobile app.',
          color: Colors.redAccent,
          icon: Icons.qr_code_scanner,
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _resultShown = true;
    });
    await _cameraController.stop();

    final result = await ApiService.verifyQrPass(rawValue);
    _showResultFromApi(result, rawValue);
  }

  void _showResultFromApi(Map<String, dynamic> result, String rawValue) {
    final statusCode = result['statusCode'] ?? 0;
    final isValid = result['isValid'] == true;
    final message = result['message']?.toString() ?? '';
    final eventTitle = result['eventTitle']?.toString();
    final bookingRef = result['bookingRef']?.toString();
    final scannedAt = result['scannedAt']?.toString();

    if (statusCode == 200 && isValid) {
      // Parse scannedAt for display
      String timeStr = '';
      if (scannedAt != null) {
        try {
          final dt = DateTime.parse(scannedAt).toLocal();
          timeStr =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          timeStr = scannedAt;
        }
      }
      _showResultDialog(
        isValid: true,
        isAlreadyUsed: false,
        title: '✅ VALID ENTRY PASS',
        message: '',
        color: Colors.greenAccent,
        icon: Icons.check_circle_rounded,
        eventTitle: eventTitle,
        bookingRef: bookingRef,
        scannedAt: timeStr,
      );
    } else if (statusCode == 400) {
      // Already scanned
      String usedAt = '';
      final scannedAtRaw = result['scannedAt']?.toString();
      if (scannedAtRaw != null) {
        try {
          final dt = DateTime.parse(scannedAtRaw).toLocal();
          usedAt =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          usedAt = scannedAtRaw;
        }
      }
      _showResultDialog(
        isValid: false,
        isAlreadyUsed: true,
        title: '⚠️ PASS ALREADY USED',
        message: 'This entry pass has already been scanned.\n\nUsed at: $usedAt',
        color: Colors.orangeAccent,
        icon: Icons.warning_amber_rounded,
      );
    } else if (statusCode == 404) {
      _showResultDialog(
        isValid: false,
        isAlreadyUsed: false,
        title: '❌ INVALID PASS',
        message: 'This QR code does not match any valid entry pass in the system.\n\nPlease contact the EventCraft office.',
        color: Colors.redAccent,
        icon: Icons.cancel_rounded,
      );
    } else {
      _showResultDialog(
        isValid: false,
        isAlreadyUsed: false,
        title: '❌ VERIFICATION FAILED',
        message: message.isNotEmpty ? message : 'Unable to verify this pass. Please check your internet connection and try again.',
        color: Colors.redAccent,
        icon: Icons.wifi_off_rounded,
      );
    }
  }

  void _showResultDialog({
    required bool isValid,
    required bool isAlreadyUsed,
    required String title,
    required String message,
    required Color color,
    required IconData icon,
    String? eventTitle,
    String? bookingRef,
    String? scannedAt,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with glow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.4), width: 2),
                ),
                child: Icon(icon, color: color, size: 56),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Event details if valid
              if (isValid && eventTitle != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(Icons.celebration_rounded, 'Event', eventTitle, Colors.amberAccent),
                      const SizedBox(height: 10),
                      if (bookingRef != null)
                        _detailRow(Icons.confirmation_number_rounded, 'Booking Ref', bookingRef, Colors.cyanAccent),
                      if (bookingRef != null) const SizedBox(height: 10),
                      if (scannedAt != null)
                        _detailRow(Icons.access_time_rounded, 'Scanned At', scannedAt, Colors.greenAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'GUEST CLEARED FOR ENTRY',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Error / warning message
              if (!isValid || message.isNotEmpty) ...[
                if (message.isNotEmpty)
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color.withOpacity(0.85),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withOpacity(0.15),
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: color.withOpacity(0.5)),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _isProcessing = false;
                          _resultShown = false;
                        });
                        _cameraController.start();
                      },
                      child: const Text(
                        'Scan Next',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'QR Entry Pass Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          // Torch toggle
          ValueListenableBuilder(
            valueListenable: _cameraController,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: state.torchState == TorchState.on ? Colors.yellowAccent : Colors.white54,
                ),
                onPressed: () => _cameraController.toggleTorch(),
                tooltip: 'Toggle Flashlight',
              );
            },
          ),
          // Flip camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70),
            onPressed: () => _cameraController.switchCamera(),
            tooltip: 'Flip Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view (full screen)
          MobileScanner(
            controller: _cameraController,
            onDetect: _onQrDetected,
          ),

          // Dark overlay with transparent center cutout
          CustomPaint(
            size: Size.infinite,
            painter: _ScanOverlayPainter(),
          ),

          // Scan frame with animated border
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (ctx, _) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.8),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Corner decorations
                      _Corner(top: 0, left: 0, isTop: true, isLeft: true),
                      _Corner(top: 0, right: 0, isTop: true, isLeft: false),
                      _Corner(bottom: 0, left: 0, isTop: false, isLeft: true),
                      _Corner(bottom: 0, right: 0, isTop: false, isLeft: false),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom instruction panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.92), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner, color: Colors.cyanAccent, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isProcessing ? 'Verifying pass...' : 'Point camera at EventCraft QR Pass',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Official EVENTCRAFT QR codes only • Auto-detects on scan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (_isProcessing) ...[
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Top EventCraft badge
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.cyanAccent, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'EventCraft Entry Verification System',
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Corner decoration widget ─────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  final double? top, left, right, bottom;
  final bool isTop, isLeft;
  const _Corner({this.top, this.left, this.right, this.bottom, required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Dark overlay painter with transparent center cutout ─────────────────────

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    const cutoutSize = 260.0;
    const cornerRadius = 16.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: cutoutSize, height: cutoutSize),
      const Radius.circular(cornerRadius),
    );

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cutoutRect);
    final combined = Path.combine(PathOperation.difference, fullPath, cutoutPath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) => false;
}
