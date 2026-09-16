class EventSummary {
  final String eventId;
  final String title;
  final DateTime targetDate;
  final int guestCount;
  final double budgetLimit;
  final String status;
  final String? venueName;
  final DateTime createdAt;

  EventSummary({
    required this.eventId,
    required this.title,
    required this.targetDate,
    required this.guestCount,
    required this.budgetLimit,
    required this.status,
    this.venueName,
    required this.createdAt,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      guestCount: json['guestCount'] ?? 0,
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'UnderReview',
      venueName: json['venueName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class EventProposalDetail {
  final String eventId;
  final String title;
  final DateTime targetDate;
  final int guestCount;
  final double budgetLimit;
  final String status;
  final String venueName;
  final double estimatedTotalCost;
  final String? weatherAssessment;
  final String? generatedPlan;
  final String? bookingRef;
  final String? qrCodeData;
  final bool isConfirmed;

  EventProposalDetail({
    required this.eventId,
    required this.title,
    required this.targetDate,
    required this.guestCount,
    required this.budgetLimit,
    required this.status,
    required this.venueName,
    required this.estimatedTotalCost,
    this.weatherAssessment,
    this.generatedPlan,
    this.bookingRef,
    this.qrCodeData,
    required this.isConfirmed,
  });

  factory EventProposalDetail.fromJson(Map<String, dynamic> json) {
    return EventProposalDetail(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      guestCount: json['guestCount'] ?? 0,
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PendingManagerApproval',
      venueName: json['venueName'] ?? 'Selected Luxury Resort',
      estimatedTotalCost: (json['estimatedTotalCost'] as num?)?.toDouble() ?? 0.0,
      weatherAssessment: json['weatherAssessment']?.toString(),
      generatedPlan: json['generatedPlan']?.toString(),
      bookingRef: json['bookingRef']?.toString(),
      qrCodeData: json['qrCodeData']?.toString(),
      isConfirmed: json['isConfirmed'] == true,
    );
  }
}