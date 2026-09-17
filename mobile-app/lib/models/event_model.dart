class EventSummary {
  final String eventId;
  final String title;
  final String? eventType;
  final DateTime targetDate;
  final int guestCount;
  final double budgetLimit;
  final String status;
  final String? venueName;
  final String? banquetHallName;
  final double? estimatedTotalCost;
  final DateTime createdAt;

  EventSummary({
    required this.eventId,
    required this.title,
    this.eventType,
    required this.targetDate,
    required this.guestCount,
    required this.budgetLimit,
    required this.status,
    this.venueName,
    this.banquetHallName,
    this.estimatedTotalCost,
    required this.createdAt,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      eventType: json['eventType']?.toString(),
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      guestCount: json['guestCount'] ?? 0,
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'UnderReview',
      venueName: json['venueName'],
      banquetHallName: json['banquetHallName'],
      estimatedTotalCost: (json['estimatedTotalCost'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class EventProposalDetail {
  final String eventId;
  final String title;
  final String eventType;
  final DateTime targetDate;
  final int guestCount;
  final double budgetLimit;
  final String status;
  final String venueName;
  final String? banquetHallName;
  final double? hallRentalPrice;
  final double? perPlatePrice;
  final List<String> selectedServices;
  final List<String> inspirationImages;
  final double estimatedTotalCost;
  final String? weatherAssessment;
  final String? generatedPlan;
  final String? bookingRef;
  final String? qrCodeData;
  final bool isConfirmed;

  EventProposalDetail({
    required this.eventId,
    required this.title,
    this.eventType = 'Wedding',
    required this.targetDate,
    required this.guestCount,
    required this.budgetLimit,
    required this.status,
    required this.venueName,
    this.banquetHallName,
    this.hallRentalPrice,
    this.perPlatePrice,
    this.selectedServices = const [],
    this.inspirationImages = const [],
    required this.estimatedTotalCost,
    this.weatherAssessment,
    this.generatedPlan,
    this.bookingRef,
    this.qrCodeData,
    required this.isConfirmed,
  });

  factory EventProposalDetail.fromJson(Map<String, dynamic> json) {
    List<String> services = [];
    if (json['selectedServices'] is List) {
      services = (json['selectedServices'] as List).map((e) => e.toString()).toList();
    }
    List<String> images = [];
    if (json['inspirationImages'] is List) {
      images = (json['inspirationImages'] as List).map((e) => e.toString()).toList();
    } else if (json['inspirationImageUrl'] is String && (json['inspirationImageUrl'] as String).isNotEmpty) {
      images = (json['inspirationImageUrl'] as String).split(',');
    }

    return EventProposalDetail(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      eventType: json['eventType']?.toString() ?? 'Wedding',
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      guestCount: json['guestCount'] ?? 0,
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PendingManagerApproval',
      venueName: json['venueName'] ?? 'Selected Luxury Resort',
      banquetHallName: json['banquetHallName']?.toString(),
      hallRentalPrice: (json['hallRentalPrice'] as num?)?.toDouble(),
      perPlatePrice: (json['perPlatePrice'] as num?)?.toDouble(),
      selectedServices: services,
      inspirationImages: images,
      estimatedTotalCost: (json['estimatedTotalCost'] as num?)?.toDouble() ?? 0.0,
      weatherAssessment: json['weatherAssessment']?.toString(),
      generatedPlan: json['generatedPlan']?.toString(),
      bookingRef: json['bookingRef']?.toString(),
      qrCodeData: json['qrCodeData']?.toString(),
      isConfirmed: json['isConfirmed'] == true,
    );
  }
}

class BanquetHallItem {
  final String banquetHallId;
  final String venueId;
  final String venueName;
  final String hallName;
  final int maxCapacity;
  final double hallRentalPrice;
  final double perPlatePrice;
  final bool isOutdoor;
  final bool isAvailable;

  BanquetHallItem({
    required this.banquetHallId,
    required this.venueId,
    required this.venueName,
    required this.hallName,
    required this.maxCapacity,
    required this.hallRentalPrice,
    required this.perPlatePrice,
    required this.isOutdoor,
    required this.isAvailable,
  });

  factory BanquetHallItem.fromJson(Map<String, dynamic> json) {
    return BanquetHallItem(
      banquetHallId: json['banquetHallId']?.toString() ?? '',
      venueId: json['venueId']?.toString() ?? '',
      venueName: json['venueName']?.toString() ?? 'Selected Hotel',
      hallName: json['hallName']?.toString() ?? 'Banquet Hall',
      maxCapacity: json['maxCapacity'] ?? 0,
      hallRentalPrice: (json['hallRentalPrice'] as num?)?.toDouble() ?? 0.0,
      perPlatePrice: (json['perPlatePrice'] as num?)?.toDouble() ?? 5000.0,
      isOutdoor: json['isOutdoor'] == true,
      isAvailable: json['isAvailable'] != false,
    );
  }
}