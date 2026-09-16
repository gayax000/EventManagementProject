class EventProposal {
  final String id;
  final String title;
  final String targetDate;
  final int guestCount;
  final double budgetLimit;
  final String status;
  final String weatherAlert;
  final String safeguardSolution;
  final double agreedAmount;
  final String? qrCodeData;

  EventProposal({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.guestCount,
    required this.budgetLimit,
    required this.status,
    required this.weatherAlert,
    required this.safeguardSolution,
    required this.agreedAmount,
    this.qrCodeData,
  });
}