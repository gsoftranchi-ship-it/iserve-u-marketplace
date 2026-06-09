import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/date_helper.dart';

class MediaAssetModel {

  // =========================================================
  // BASIC
  // =========================================================

  final String id;

  final String campaignId;

  final String ownerId;

  // =========================================================
  // MEDIA
  // =========================================================

  final String mediaUrl;

  final String mediaType;

  final String thumbnailUrl;

  final String fileName;

  // =========================================================
  // PLAYBACK
  // =========================================================

  final int durationSeconds;

  final int sortOrder;

  final int priority;

  final bool isActive;

  // =========================================================
  // FILE INFO
  // =========================================================

  final int fileSizeBytes;

  final double aspectRatio;

  final String resolution;

  // =========================================================
  // ANALYTICS
  // =========================================================

  final int totalPlays;

  final int totalImpressions;

  // =========================================================
  // SYSTEM
  // =========================================================

  final DateTime? createdAt;

  final DateTime? updatedAt;

  MediaAssetModel({

    required this.id,

    required this.campaignId,

    required this.ownerId,

    required this.mediaUrl,

    required this.mediaType,

    required this.thumbnailUrl,

    required this.fileName,

    required this.durationSeconds,

    required this.sortOrder,

    required this.priority,

    required this.isActive,

    required this.fileSizeBytes,

    required this.aspectRatio,

    required this.resolution,

    required this.totalPlays,

    required this.totalImpressions,

    required this.createdAt,

    required this.updatedAt,
  });

  // =========================================================
  // FROM MAP
  // =========================================================

  factory MediaAssetModel.fromMap(

      String id,

      Map<String, dynamic> map,
      ) {

    return MediaAssetModel(

      // =====================================================
      // BASIC
      // =====================================================

      id: id,

      campaignId:
      map['campaignId'] ?? '',

      ownerId:
      map['ownerId'] ?? '',

      // =====================================================
      // MEDIA
      // =====================================================

      mediaUrl:
      map['mediaUrl'] ?? '',

      mediaType:
      (
          map['mediaType'] ??
              'image'
      ).toString().toLowerCase(),

      thumbnailUrl:
      map['thumbnailUrl'] ?? '',

      fileName:
      map['fileName'] ?? '',

      // =====================================================
      // PLAYBACK
      // =====================================================

      durationSeconds:
      map['durationSeconds'] ?? 10,

      sortOrder:
      map['sortOrder'] ?? 0,

      priority:
      map['priority'] ?? 1,

      isActive:
      map['isActive'] ?? true,

      // =====================================================
      // FILE INFO
      // =====================================================

      fileSizeBytes:
      map['fileSizeBytes'] ?? 0,

      aspectRatio:
      (
          map['aspectRatio'] ?? 1.0
      ).toDouble(),

      resolution:
      map['resolution'] ?? '',

      // =====================================================
      // ANALYTICS
      // =====================================================

      totalPlays:
      map['totalPlays'] ?? 0,

      totalImpressions:
      map['totalImpressions'] ?? 0,

      // =====================================================
      // SYSTEM
      // =====================================================

      createdAt:
      parseFirestoreDate(
        map['createdAt'],
      ),

      updatedAt:
      parseFirestoreDate(
        map['updatedAt'],
      ),
    );
  }

  // =========================================================
  // TO MAP
  // =========================================================

  Map<String, dynamic> toMap() {

    return {

      // =====================================================
      // BASIC
      // =====================================================

      'campaignId': campaignId,

      'ownerId': ownerId,

      // =====================================================
      // MEDIA
      // =====================================================

      'mediaUrl': mediaUrl,

      'mediaType': mediaType,

      'thumbnailUrl': thumbnailUrl,

      'fileName': fileName,

      // =====================================================
      // PLAYBACK
      // =====================================================

      'durationSeconds':
      durationSeconds,

      'sortOrder': sortOrder,

      'priority': priority,

      'isActive': isActive,

      // =====================================================
      // FILE INFO
      // =====================================================

      'fileSizeBytes':
      fileSizeBytes,

      'aspectRatio':
      aspectRatio,

      'resolution':
      resolution,

      // =====================================================
      // ANALYTICS
      // =====================================================

      'totalPlays': totalPlays,

      'totalImpressions':
      totalImpressions,

      // =====================================================
      // SYSTEM
      // =====================================================

      'createdAt':
      createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    };
  }

  // =========================================================
  // HELPERS
  // =========================================================

  bool get isVideo =>

      mediaType == "video";

  bool get isImage =>

      mediaType == "image";

  bool get hasThumbnail =>

      thumbnailUrl.isNotEmpty;

  bool get isLandscape =>

      aspectRatio >= 1;

  bool get isPortrait =>

      aspectRatio < 1;

  bool get canPlay =>

      isActive &&
          mediaUrl.isNotEmpty;

  // =========================================================
  // DISPLAY
  // =========================================================

  String get readableType {

    switch (mediaType) {

      case "video":
        return "Video";

      case "image":
        return "Image";

      default:
        return "Unknown";
    }
  }

  String get readableFileSize {

    if (fileSizeBytes <= 0) {
      return "0 KB";
    }

    final kb =
        fileSizeBytes / 1024;

    if (kb < 1024) {

      return
        "${kb.toStringAsFixed(1)} KB";
    }

    final mb = kb / 1024;

    return
      "${mb.toStringAsFixed(1)} MB";
  }

  // =========================================================
  // COPY WITH
  // =========================================================

  MediaAssetModel copyWith({

    String? id,

    String? campaignId,

    String? ownerId,

    String? mediaUrl,

    String? mediaType,

    String? thumbnailUrl,

    String? fileName,

    int? durationSeconds,

    int? sortOrder,

    int? priority,

    bool? isActive,

    int? fileSizeBytes,

    double? aspectRatio,

    String? resolution,

    int? totalPlays,

    int? totalImpressions,

    DateTime? createdAt,

    DateTime? updatedAt,
  }) {

    return MediaAssetModel(

      id: id ?? this.id,

      campaignId:
      campaignId ??
          this.campaignId,

      ownerId:
      ownerId ?? this.ownerId,

      mediaUrl:
      mediaUrl ?? this.mediaUrl,

      mediaType:
      mediaType ??
          this.mediaType,

      thumbnailUrl:
      thumbnailUrl ??
          this.thumbnailUrl,

      fileName:
      fileName ?? this.fileName,

      durationSeconds:
      durationSeconds ??
          this.durationSeconds,

      sortOrder:
      sortOrder ??
          this.sortOrder,

      priority:
      priority ??
          this.priority,

      isActive:
      isActive ??
          this.isActive,

      fileSizeBytes:
      fileSizeBytes ??
          this.fileSizeBytes,

      aspectRatio:
      aspectRatio ??
          this.aspectRatio,

      resolution:
      resolution ??
          this.resolution,

      totalPlays:
      totalPlays ??
          this.totalPlays,

      totalImpressions:
      totalImpressions ??
          this.totalImpressions,

      createdAt:
      createdAt ??
          this.createdAt,

      updatedAt:
      updatedAt ??
          this.updatedAt,
    );
  }
}