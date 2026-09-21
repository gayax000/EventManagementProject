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
    _pulseAnimation = Tween<double>(begin: 0.87, end: 1.0).animate(
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
        setState(() { _resultShown = true; });
        await _cameraController.stop();
        _showInvalidDialog('This QR code is not an EventCraft Entry Pass.\n\nPlease scan the official QR code from the customer\'s mobile app.');
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _resultShown = true;
    });
    await _cameraController.stop();

    final result = await ApiService.verifyQrPass(rawValue);
    if (mounted) _showResultSheet(result);
  }

  void _showInvalidDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Invalid QR Code', style: TextStyle(color: Colors.redAccent, fontSize: 17)),
          ],
        ),
        content: Text(msg, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _isProcessing = false; _resultShown = false; });
              _cameraController.start();
            },
            child: const Text('Try Again', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showResultSheet(Map<String, dynamic> data) {
    final statusCode  = data['statusCode'] ?? 0;
    final isValid     = data['isValid'] == true;
    final alreadyUsed = data['alreadyUsed'] == true;

    // Colours & labels
    final Color accentColor = isValid
        ? Colors.greenAccent
        : alreadyUsed
            ? Colors.orangeAccent
            : Colors.redAccent;

    final String statusLabel = isValid
        ? 'ENTRY CLEARED'
        : alreadyUsed
            ? 'PASS ALREADY USED'
            : statusCode == 404
                ? 'INVALID PASS'
                : 'VERIFICATION FAILED';

    // ---------- helpers ----------
    String _fmt(dynamic v) => v?.toString() ?? '—';

    String _fmtDate(dynamic raw) {
      if (raw == null) return '—';
      try {
        final dt = DateTime.parse(raw.toString()).toLocal();
        const months = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
        return '${months[dt.month-1]} ${dt.day.toString().padLeft(2,'0')}, ${dt.year}';
      } catch (_) { return raw.toString(); }
    }

    String _fmtDateTime(dynamic raw) {
      if (raw == null) return '—';
      try {
        final dt = DateTime.parse(raw.toString()).toLocal();
        const months = ['Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
        return '${months[dt.month-1]} ${dt.day.toString().padLeft(2,'0')}, ${dt.year}  '
               '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
      } catch (_) { return raw.toString(); }
    }

    String _fmtAmount(dynamic v) {
      if (v == null) return '—';
      try {
        final n = double.parse(v.toString());
        final formatted = n.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
        return 'LKR $formatted';
      } catch (_) { return v.toString(); }
    }

    List<String> services = [];
    if (data['selectedServices'] != null) {
      services = List<String>.from(data['selectedServices'] as List);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Status banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 18, spreadRadius: 2)],
                ),
                child: Column(
                  children: [
                    Icon(
                      isValid ? Icons.check_circle_rounded
                          : alreadyUsed ? Icons.warning_amber_rounded
                          : Icons.cancel_rounded,
                      color: accentColor, size: 52,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      statusLabel,
                      style: TextStyle(color: accentColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isValid
                          ? 'Guest is verified and cleared for entry'
                          : alreadyUsed
                              ? 'Pass was already scanned at: ${_fmtDateTime(data['scannedAt'])}'
                              : (data['message']?.toString() ?? 'Verification failed'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: accentColor.withOpacity(0.8), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Client Info ────────────────────────────────────────────
              if (data['clientName'] != null) ...[
                _sectionHeader(Icons.person_rounded, 'Client Information', Colors.cyanAccent),
                const SizedBox(height: 10),
                _infoCard([
                  _row(Icons.badge_rounded, 'Client Name', _fmt(data['clientName']), Colors.cyanAccent),
                  if ((data['clientPhone'] ?? '').toString().isNotEmpty)
                    _row(Icons.phone_rounded, 'Phone', _fmt(data['clientPhone']), Colors.cyanAccent),
                ]),
                const SizedBox(height: 16),
              ],

              // ── Booking Info ───────────────────────────────────────────
              if (data['bookingRef'] != null) ...[
                _sectionHeader(Icons.confirmation_number_rounded, 'Booking Details', Colors.amberAccent),
                const SizedBox(height: 10),
                _infoCard([
                  _row(Icons.tag_rounded, 'Booking Reference', _fmt(data['bookingRef']), Colors.amberAccent),
                  if (data['invoiceNumber'] != null)
                    _row(Icons.receipt_long_rounded, 'Invoice Number', _fmt(data['invoiceNumber']), Colors.amberAccent),
                  if (data['totalAmount'] != null)
                    _row(Icons.payments_rounded, 'Total Paid', _fmtAmount(data['totalAmount']), Colors.greenAccent),
                  if (data['confirmedAt'] != null)
                    _row(Icons.verified_rounded, 'Confirmed On', _fmtDateTime(data['confirmedAt']), Colors.greenAccent),
                ]),
                const SizedBox(height: 16),
              ],

              // ── Event Info ─────────────────────────────────────────────
              if (data['eventTitle'] != null) ...[
                _sectionHeader(Icons.celebration_rounded, 'Event Details', Colors.purpleAccent),
                const SizedBox(height: 10),
                _infoCard([
                  _row(Icons.event_rounded, 'Event Name', _fmt(data['eventTitle']), Colors.white),
                  if (data['eventType'] != null)
                    _row(Icons.category_rounded, 'Event Type', _fmt(data['eventType']), Colors.white70),
                  if (data['eventDate'] != null)
                    _row(Icons.calendar_today_rounded, 'Event Date', _fmtDate(data['eventDate']), Colors.white70),
                  if (data['guestCount'] != null)
                    _row(Icons.people_alt_rounded, 'Guest Count', '${data['guestCount']} Guests', Colors.white70),
                ]),
                const SizedBox(height: 16),
              ],

              // ── Venue Info ─────────────────────────────────────────────
              if (data['venueName'] != null) ...[
                _sectionHeader(Icons.location_on_rounded, 'Venue & Hall', Colors.tealAccent),
                const SizedBox(height: 10),
                _infoCard([
                  _row(Icons.hotel_rounded, 'Venue', _fmt(data['venueName']), Colors.tealAccent),
                  if (data['hallName'] != null)
                    _row(Icons.meeting_room_rounded, 'Hall / Lawn', _fmt(data['hallName']), Colors.tealAccent),
                ]),
                const SizedBox(height: 16),
              ],

              // ── Services ───────────────────────────────────────────────
              if (services.isNotEmpty) ...[
                _sectionHeader(Icons.room_service_rounded, 'Booked Services', Colors.pinkAccent),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: services.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.pinkAccent.withOpacity(0.4)),
                      ),
                      child: Text(s, style: const TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Scan timestamp ─────────────────────────────────────────
              if (isValid) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Scanned at: ${_fmtDateTime(data['scannedAt'])}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Buttons ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor.withOpacity(0.15),
                        foregroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: accentColor.withOpacity(0.5)),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Scan Next', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() { _isProcessing = false; _resultShown = false; });
                        _cameraController.start();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // If dismissed without tapping a button, re-enable scanner
      if (mounted && _isProcessing) {
        setState(() { _isProcessing = false; _resultShown = false; });
        _cameraController.start();
      }
    });
  }

  // ─── Helper widgets ─────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: rows.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: w,
        )).toList(),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.white38),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QR Entry Pass Scanner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text('EventCraft Staff Verification', style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
          ],
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: _cameraController,
            builder: (ctx, state, _) => IconButton(
              icon: Icon(
                state.torchState == TorchState.on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: state.torchState == TorchState.on ? Colors.yellowAccent : Colors.white54,
              ),
              onPressed: _cameraController.toggleTorch,
              tooltip: 'Flashlight',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70),
            onPressed: _cameraController.switchCamera,
            tooltip: 'Flip Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera ──
          MobileScanner(controller: _cameraController, onDetect: _onQrDetected),

          // ── Dark overlay with cutout ──
          CustomPaint(size: Size.infinite, painter: _OverlayPainter()),

          // ── Animated scan frame ──
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnimation.value,
                child: SizedBox(
                  width: 260, height: 260,
                  child: Stack(
                    children: [
                      // Full border (faint)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.25), width: 1),
                        ),
                      ),
                      // Corner decorators
                      _corner(top: 0, left: 0, isTop: true, isLeft: true),
                      _corner(top: 0, right: 0, isTop: true, isLeft: false),
                      _corner(bottom: 0, left: 0, isTop: false, isLeft: true),
                      _corner(bottom: 0, right: 0, isTop: false, isLeft: false),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom instruction ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isProcessing ? Icons.hourglass_top_rounded : Icons.qr_code_scanner,
                        color: Colors.cyanAccent, size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isProcessing ? 'Verifying pass with server…' : 'Point at EventCraft QR Pass',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Full booking and client details appear after scan',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (_isProcessing) ...[
                    const SizedBox(height: 14),
                    const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2.5),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Top badge ──
          Positioned(
            top: 14, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.cyanAccent, size: 14),
                    SizedBox(width: 6),
                    Text('EventCraft Staff Entry Verification',
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned _corner({double? top, double? left, double? right, double? bottom,
      required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          border: Border(
            top:    isTop    ? const BorderSide(color: Colors.cyanAccent, width: 3.5) : BorderSide.none,
            bottom: !isTop   ? const BorderSide(color: Colors.cyanAccent, width: 3.5) : BorderSide.none,
            left:   isLeft   ? const BorderSide(color: Colors.cyanAccent, width: 3.5) : BorderSide.none,
            right:  !isLeft  ? const BorderSide(color: Colors.cyanAccent, width: 3.5) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Overlay painter ────────────────────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    final cutout = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 260, height: 260,
      ),
      const Radius.circular(16),
    );
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addRRect(cutout);
    canvas.drawPath(Path.combine(PathOperation.difference, full, hole), paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => false;
}
