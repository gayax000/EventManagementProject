import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ToastType { success, warning, error, info }

class FeedbackDetailRow {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final Widget? badge;

  const FeedbackDetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.badge,
  });
}

class AppFeedback {
  /// 🌟 1. Modern Floating Pill Toast
  /// A floating, rounded pill banner that replaces the legacy flat SnackBar.
  static void showToast(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    Color bg;
    Color border;
    IconData icon;
    Color iconColor;

    switch (type) {
      case ToastType.success:
        bg = const Color(0xFF064E3B); // Deep emerald
        border = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF34D399);
        break;
      case ToastType.warning:
        bg = const Color(0xFF78350F); // Deep amber
        border = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFFBBF24);
        break;
      case ToastType.error:
        bg = const Color(0xFF7F1D1D); // Deep rose
        border = const Color(0xFFEF4444);
        icon = Icons.error_outline_rounded;
        iconColor = const Color(0xFFF87171);
        break;
      case ToastType.info:
      default:
        bg = const Color(0xFF0F172A); // Slate 900
        border = const Color(0xFF38BDF8);
        icon = Icons.info_outline_rounded;
        iconColor = const Color(0xFF38BDF8);
        break;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg.withOpacity(0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border.withOpacity(0.6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: border.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty) ...[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌟 2. Generic Modern Bottom Sheet Modal
  static Future<T?> showModernBottomSheet<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    List<FeedbackDetailRow>? details,
    String? noticeText,
    String primaryButtonText = 'Done',
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: barrierDismissible,
      enableDrag: barrierDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 25,
                offset: Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Swipe Handle Bar
                Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // Glowing Hero Icon Badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 36),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Optional Details Card (Receipt Box)
                if (details != null && details.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: details.map((row) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                row.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              if (row.badge != null)
                                row.badge!
                              else
                                Text(
                                  row.value,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: row.isBold ? FontWeight.bold : FontWeight.w600,
                                    color: row.valueColor ?? const Color(0xFF0F172A),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Optional Notice Banner
                if (noticeText != null && noticeText.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF475569)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            noticeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ] else ...[
                  const SizedBox(height: 12),
                ],

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (onPrimaryPressed != null) onPrimaryPressed();
                    },
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                // Optional Secondary Action Button
                if (secondaryButtonText != null && secondaryButtonText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (onSecondaryPressed != null) onSecondaryPressed();
                      },
                      child: Text(
                        secondaryButtonText,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
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
  }

  // -------------------------------------------------------------
  // 🌟 3. Pre-configured Specialty Sheets
  // -------------------------------------------------------------

  /// 💳 Payment Slip Uploaded Sheet
  static Future<void> showPaymentSlipSubmittedSheet(
    BuildContext context, {
    required String bookingRef,
    required double amount,
    String? eventTitle,
    VoidCallback? onDone,
  }) {
    final currencyFmt = NumberFormat('#,##0', 'en_US');
    return showModernBottomSheet(
      context,
      title: 'Payment Slip Submitted! 💳',
      subtitle: 'Your bank transfer deposit slip has been securely uploaded.',
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFF059669),
      iconBgColor: const Color(0xFFD1FAE5),
      details: [
        FeedbackDetailRow(
          label: 'Booking Ref:',
          value: bookingRef,
          isBold: true,
        ),
        if (eventTitle != null && eventTitle.isNotEmpty)
          FeedbackDetailRow(
            label: 'Event Title:',
            value: eventTitle,
          ),
        FeedbackDetailRow(
          label: 'Deposit Amount:',
          value: 'LKR ${currencyFmt.format(amount)}',
          isBold: true,
          valueColor: const Color(0xFF059669),
        ),
        FeedbackDetailRow(
          label: 'Status:',
          value: 'Pending Verification',
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '⏳ Verification Pending',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ),
      ],
      noticeText: 'Our Event Manager will verify your slip and auto-generate the official Tax Invoice & Receipt shortly.',
      primaryButtonText: 'Done',
      onPrimaryPressed: onDone,
    );
  }

  /// 📜 Contract Signed & QR Pass Issued Sheet
  static Future<void> showContractSignedSheet(
    BuildContext context, {
    required String bookingRef,
    required String eventTitle,
    VoidCallback? onViewPass,
  }) {
    return showModernBottomSheet(
      context,
      title: 'Contract Legally Signed! 📜✨',
      subtitle: 'Your digital agreement is complete and confirmed in the cloud.',
      icon: Icons.verified_rounded,
      iconColor: const Color(0xFF2563EB),
      iconBgColor: const Color(0xFFDBEAFE),
      details: [
        FeedbackDetailRow(
          label: 'Event:',
          value: eventTitle,
          isBold: true,
        ),
        FeedbackDetailRow(
          label: 'Reference Code:',
          value: bookingRef,
        ),
        FeedbackDetailRow(
          label: 'Entry Pass Status:',
          value: 'QR Pass Active',
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '✓ QR Pass Ready',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ),
      ],
      noticeText: 'You can now present your official QR entry pass at venue entry on the celebration day.',
      primaryButtonText: 'View Entry Pass',
      onPrimaryPressed: onViewPass,
      secondaryButtonText: 'Close',
    );
  }

  /// 📝 Revision Request Submitted Sheet
  static Future<void> showRevisionSubmittedSheet(
    BuildContext context, {
    required String eventTitle,
    VoidCallback? onDone,
  }) {
    return showModernBottomSheet(
      context,
      title: 'Revision Request Sent! 📝',
      subtitle: 'The event manager has been notified of your requested changes.',
      icon: Icons.edit_note_rounded,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFEF3C7),
      details: [
        FeedbackDetailRow(
          label: 'Event:',
          value: eventTitle,
          isBold: true,
        ),
        FeedbackDetailRow(
          label: 'Target Action:',
          value: 'Proposal Adjustment',
        ),
        FeedbackDetailRow(
          label: 'Queue Status:',
          value: 'Assigned to Manager',
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Under Review',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4338CA),
              ),
            ),
          ),
        ),
      ],
      noticeText: 'Your event planner will update the timeline, catering, or budget and notify you once ready.',
      primaryButtonText: 'Understood',
      onPrimaryPressed: onDone,
    );
  }

  /// 🤝 Proposal Agreement Confirmed Sheet
  static Future<void> showProposalAgreedSheet(
    BuildContext context, {
    required String choiceLabel,
    required double totalCost,
    VoidCallback? onDone,
  }) {
    final currencyFmt = NumberFormat('#,##0', 'en_US');
    return showModernBottomSheet(
      context,
      title: 'Agreement Confirmed! 🤝',
      subtitle: 'Your package choice has been submitted for final manager verification.',
      icon: Icons.handshake_rounded,
      iconColor: const Color(0xFF4F46E5),
      iconBgColor: const Color(0xFFEEF2FF),
      details: [
        FeedbackDetailRow(
          label: 'Package Choice:',
          value: choiceLabel,
          isBold: true,
        ),
        FeedbackDetailRow(
          label: 'Agreed Total:',
          value: 'LKR ${currencyFmt.format(totalCost)}',
          isBold: true,
          valueColor: const Color(0xFF4F46E5),
        ),
      ],
      noticeText: 'Once verified by the event manager, you will receive the digital agreement contract to sign.',
      primaryButtonText: 'Great, Thanks!',
      onPrimaryPressed: onDone,
    );
  }

  /// 🎉 Registration Success Sheet
  static Future<void> showRegistrationSuccessSheet(
    BuildContext context, {
    required String email,
    VoidCallback? onProceedToLogin,
  }) {
    return showModernBottomSheet(
      context,
      title: 'Welcome to EventCraft! 🎉',
      subtitle: 'Your client account has been created successfully.',
      icon: Icons.celebration_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      details: [
        FeedbackDetailRow(
          label: 'Account Email:',
          value: email,
          isBold: true,
        ),
        FeedbackDetailRow(
          label: 'Status:',
          value: 'Active & Verified',
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803D),
              ),
            ),
          ),
        ),
      ],
      noticeText: 'Please log in with your email and password to start planning your luxury celebrations.',
      primaryButtonText: 'Proceed to Login',
      onPrimaryPressed: onProceedToLogin,
      barrierDismissible: false,
    );
  }
}
