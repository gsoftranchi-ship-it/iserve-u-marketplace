import 'package:iserve_u/core/utils/date_helper.dart';

class CampaignModel {

  // =========================================================
  // IDS
  // =========================================================

  final String id;

  final String ownerId;

  // =========================================================
  // BASIC
  // =========================================================

  final String title;

  final String description;
  final String transactionId;

  final String paymentStatus;

  final String contactInfo;

  final double price;

  final String mediaUrl;

  final String mediaType;

  // =========================================================
  // TARGETING
  // =========================================================

  final List<String> siteIds;

  // =========================================================
  // SCHEDULING
  // =========================================================

  final DateTime startDate;

  final DateTime endDate;

  final int durationDays;

  final String durationLabel;

  // =========================================================
  // PLAYBACK
  // =========================================================

  final int priority;

  final int durationSeconds;

  final bool isActive;

  final String rotationType;

  // =========================================================
  // STATUS
  // =========================================================

  final String status;

  // =========================================================
  // ANALYTICS
  // =========================================================

  final int totalPlays;

  final int totalImpressions;

  // =========================================================
  // TIMESTAMPS
  // =========================================================

  final DateTime createdAt;

  final DateTime updatedAt;

  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  CampaignModel({

    required this.id,

    required this.ownerId,

    required this.title,

    required this.description,
    required this.transactionId,

    required this.paymentStatus,

    required this.contactInfo,

    required this.price,

    required this.mediaUrl,

    required this.mediaType,

    required this.siteIds,

    required this.startDate,

    required this.endDate,

    required this.durationDays,

    required this.durationLabel,

    required this.priority,

    required this.durationSeconds,

    required this.isActive,

    required this.rotationType,

    required this.status,

    required this.totalPlays,

    required this.totalImpressions,

    required this.createdAt,

    required this.updatedAt,
  });

  // =========================================================
  // FROM MAP
  // =========================================================

  factory CampaignModel.fromMap(

      String id,

      Map<String, dynamic> map,
      ) {

    return CampaignModel(

      // =====================================
      // IDS
      // =====================================

      id: id,

      ownerId:
      map['ownerId'] ?? '',

      // =====================================
      // BASIC
      // =====================================

      title:
      map['title'] ?? '',

      description:
      map['description'] ?? '',
      transactionId:
      map['transactionId'] ?? '',

      paymentStatus:
      map['paymentStatus']
          ?? 'pending',

      contactInfo:
      map['contactInfo']
          ?? '',

      price:
      (map['price'] ?? 0)
          .toDouble(),

      mediaUrl:
      map['mediaUrl'] ?? '',

      mediaType:
      map['mediaType'] ?? 'image',

      // =====================================
      // TARGETING
      // =====================================

      siteIds:
      List<String>.from(
        map['siteIds'] ?? [],
      ),

      // =====================================
      // DATES
      // =====================================

      startDate:
      parseFirestoreDate(
        map['startDate'],
      ) ?? DateTime.now(),

      endDate:
      parseFirestoreDate(
        map['endDate'],
      ) ?? DateTime.now(),

      durationDays:
      map['durationDays'] ?? 1,

      durationLabel:
      map['durationLabel'] ?? '1 Day',

      // =====================================
      // PLAYBACK
      // =====================================

      priority:
      map['priority'] ?? 1,

      durationSeconds:
      map['durationSeconds'] ?? 10,

      isActive:
      map['isActive'] ?? false,

      rotationType:
      map['rotationType'] ??
          'loop',

      // =====================================
      // STATUS
      // =====================================

      status:
      map['status'] ??
          'pending_approval',

      // =====================================
      // ANALYTICS
      // =====================================

      totalPlays:
      map['totalPlays'] ?? 0,

      totalImpressions:
      map['totalImpressions']
          ?? 0,

      // =====================================
      // TIMESTAMPS
      // =====================================

      createdAt:
      parseFirestoreDate(
        map['createdAt'],
      ) ?? DateTime.now(),

      updatedAt:
      parseFirestoreDate(
        map['updatedAt'],
      ) ?? DateTime.now(),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  bool get isExpired =>

      DateTime.now().isAfter(
        endDate,
      );

  bool get isStarted =>

      DateTime.now().isAfter(
        startDate,
      );

  bool get hasValidDates =>

      endDate.isAfter(
        startDate,
      );

  bool get hasMedia =>

      mediaUrl.isNotEmpty;

  bool get isApproved =>

      status == 'active';

  bool get isPending =>

      status ==
          'pending_approval';

  bool get isRejected =>

      status == 'rejected';

  bool get isCurrentlyRunning =>

      isActive &&
          isStarted &&
          !isExpired &&
          hasValidDates &&
          isApproved;

  bool get canRun =>

      isCurrentlyRunning;

  String get readableStatus {

    switch (status) {

      case 'active':
        return 'LIVE';

      case 'pending_approval':
        return 'PENDING';

      case 'rejected':
        return 'REJECTED';

      case 'expired':
        return 'EXPIRED';

      default:
        return status.toUpperCase();
    }
  }

  // =========================================================
  // TO MAP
  // =========================================================

  Map<String, dynamic> toMap() {

    return {

      'ownerId': ownerId,

      'title': title,

      'description':
      description,
      'transactionId':
      transactionId,

      'paymentStatus':
      paymentStatus,

      'contactInfo':
      contactInfo,

      'price':
      price,

      'mediaUrl': mediaUrl,

      'mediaType':
      mediaType,

      'siteIds': siteIds,

      'startDate': startDate,

      'endDate': endDate,

      'durationDays':
      durationDays,

      'durationLabel':
      durationLabel,

      'priority': priority,

      'durationSeconds':
      durationSeconds,

      'isActive': isActive,

      'rotationType':
      rotationType,

      'status': status,

      'totalPlays':
      totalPlays,

      'totalImpressions':
      totalImpressions,

      'createdAt':
      createdAt,

      'updatedAt':
      updatedAt,
    };
  }
}