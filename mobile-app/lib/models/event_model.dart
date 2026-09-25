import 'dart:convert';

class EventSummary {
  final String eventId;
  final String title;
  final String? eventType;
  final DateTime targetDate;
  final int guestCount;
  final double budgetLimit;
  final bool isOutdoor;
  final String? additionalDetails;
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
    this.isOutdoor = false,
    this.additionalDetails,
    required this.status,
    this.venueName,
    this.banquetHallName,
    this.estimatedTotalCost,
    required this.createdAt,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    int parsedGuestCount = 0;
    final rawGuests = json['guestCount'];
    if (rawGuests is int) {
      parsedGuestCount = rawGuests;
    } else if (rawGuests != null) {
      parsedGuestCount = int.tryParse(rawGuests.toString()) ?? 0;
    }

    double parsedBudget = 0.0;
    final rawBudget = json['budgetLimit'];
    if (rawBudget is num) {
      parsedBudget = rawBudget.toDouble();
    } else if (rawBudget != null) {
      parsedBudget = double.tryParse(rawBudget.toString()) ?? 0.0;
    }

    double? parsedEstCost;
    final rawEstCost = json['estimatedTotalCost'];
    if (rawEstCost is num) {
      parsedEstCost = rawEstCost.toDouble();
    } else if (rawEstCost != null) {
      parsedEstCost = double.tryParse(rawEstCost.toString());
    }

    DateTime parsedTarget = DateTime.now();
    final rawTarget = json['targetDate']?.toString();
    if (rawTarget != null && rawTarget.isNotEmpty) {
      parsedTarget = DateTime.tryParse(rawTarget) ?? DateTime.now();
    }

    DateTime parsedCreated = DateTime.now();
    final rawCreated = json['createdAt']?.toString();
    if (rawCreated != null && rawCreated.isNotEmpty) {
      parsedCreated = DateTime.tryParse(rawCreated) ?? DateTime.now();
    }

    return EventSummary(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Event',
      eventType: json['eventType']?.toString(),
      targetDate: parsedTarget,
      guestCount: parsedGuestCount,
      budgetLimit: parsedBudget,
      isOutdoor: json['isOutdoor'] == true || json['isOutdoor']?.toString().toLowerCase() == 'true',
      additionalDetails: json['additionalDetails']?.toString(),
      status: json['status']?.toString() ?? 'UnderReview',
      venueName: json['venueName']?.toString(),
      banquetHallName: json['banquetHallName']?.toString(),
      estimatedTotalCost: parsedEstCost,
      createdAt: parsedCreated,
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
  final bool isOutdoor;
  final String? additionalDetails;
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
  final String? bookingId;
  final String? paymentStatus;
  final String? slipImageUrl;
  final String? invoiceNumber;
  final String? eventSession;
  final String? cateringStyle;
  final List<String> tableRefreshments;
  final String? revisionNotes;
  final double? specialRequestAllocation;

  EventProposalDetail({
    required this.eventId,
    required this.title,
    this.eventType = 'Wedding',
    required this.targetDate,
    required this.guestCount,
    required this.budgetLimit,
    this.isOutdoor = false,
    this.additionalDetails,
    this.eventSession,
    this.cateringStyle,
    this.tableRefreshments = const [],
    this.revisionNotes,
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
    this.bookingId,
    this.paymentStatus,
    this.slipImageUrl,
    this.invoiceNumber,
    this.specialRequestAllocation,
  });

  factory EventProposalDetail.fromJson(Map<String, dynamic> json) {
    List<String> services = [];
    if (json['selectedServices'] is List) {
      services = (json['selectedServices'] as List).map((e) => e.toString()).toList();
    }
    List<String> refreshments = [];
    if (json['tableRefreshments'] is List) {
      refreshments = (json['tableRefreshments'] as List).map((e) => e.toString()).toList();
    }
    List<String> images = [];
    if (json['inspirationImages'] is List && (json['inspirationImages'] as List).isNotEmpty) {
      images = (json['inspirationImages'] as List).map((e) => e.toString()).toList();
    } else if (json['inspirationImageUrl'] is String && (json['inspirationImageUrl'] as String).isNotEmpty) {
      final raw = (json['inspirationImageUrl'] as String).trim();
      if (raw.startsWith('[')) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) images = decoded.map((e) => e.toString()).toList();
        } catch (_) {
          images = [raw];
        }
      } else if (raw.contains('|||')) {
        images = raw.split('|||').where((s) => s.isNotEmpty).toList();
      } else {
        images = [raw];
      }
    }

    return EventProposalDetail(
      eventId: json['eventId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Event',
      eventType: json['eventType']?.toString() ?? 'Wedding',
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      guestCount: json['guestCount'] ?? 0,
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble() ?? 0.0,
      isOutdoor: json['isOutdoor'] == true,
      additionalDetails: json['additionalDetails']?.toString(),
      eventSession: json['eventSession']?.toString(),
      cateringStyle: json['cateringStyle']?.toString(),
      tableRefreshments: refreshments,
      revisionNotes: json['revisionNotes']?.toString(),
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
      bookingId: json['bookingId']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      slipImageUrl: json['slipImageUrl']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      specialRequestAllocation: (json['specialRequestAllocation'] as num?)?.toDouble(),
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

  String get hotelName => venueName;
}

typedef BanquetHallSummary = BanquetHallItem;