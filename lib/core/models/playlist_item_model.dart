class PlaylistItemModel {

  // =========================================================
  // IDs
  // =========================================================

  final String campaignId;

  final String assetId;

  final String ownerId;

  // =========================================================
  // CAMPAIGN
  // =========================================================

  final String campaignTitle;

  final int priority;

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

  final bool isCached;

  final bool isOfflineReady;

  // =========================================================
  // ANALYTICS
  // =========================================================

  final int totalPlays;

  final int totalImpressions;

  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  PlaylistItemModel({

    required this.campaignId,

    required this.assetId,

    required this.ownerId,

    required this.campaignTitle,

    required this.priority,

    required this.mediaUrl,

    required this.mediaType,

    required this.thumbnailUrl,

    required this.fileName,

    required this.durationSeconds,

    required this.sortOrder,

    required this.isCached,

    required this.isOfflineReady,

    required this.totalPlays,

    required this.totalImpressions,
  });

  // =========================================================
  // HELPERS
  // =========================================================

  bool get isVideo =>

      mediaType == "video";

  bool get isImage =>

      mediaType == "image";

  bool get hasThumbnail =>

      thumbnailUrl.isNotEmpty;

  bool get canPlay =>

      mediaUrl.isNotEmpty;

  // =========================================================
  // TO MAP
  // =========================================================

  Map<String, dynamic> toMap() {

    return {

      'campaignId': campaignId,

      'assetId': assetId,

      'ownerId': ownerId,

      'campaignTitle':
      campaignTitle,

      'priority': priority,

      'mediaUrl': mediaUrl,

      'mediaType': mediaType,

      'thumbnailUrl':
      thumbnailUrl,

      'fileName': fileName,

      'durationSeconds':
      durationSeconds,

      'sortOrder': sortOrder,

      'isCached': isCached,

      'isOfflineReady':
      isOfflineReady,

      'totalPlays': totalPlays,

      'totalImpressions':
      totalImpressions,
    };
  }

  // =========================================================
  // FROM MAP
  // =========================================================

  factory PlaylistItemModel.fromMap(
      Map<String, dynamic> map,
      ) {

    return PlaylistItemModel(

      campaignId:
      map['campaignId'] ?? '',

      assetId:
      map['assetId'] ?? '',

      ownerId:
      map['ownerId'] ?? '',

      campaignTitle:
      map['campaignTitle'] ?? '',

      priority:
      map['priority'] ?? 1,

      mediaUrl:
      map['mediaUrl'] ?? '',

      mediaType:
      map['mediaType'] ?? 'image',

      thumbnailUrl:
      map['thumbnailUrl'] ?? '',

      fileName:
      map['fileName'] ?? '',

      durationSeconds:
      map['durationSeconds'] ?? 10,

      sortOrder:
      map['sortOrder'] ?? 0,

      isCached:
      map['isCached'] ?? false,

      isOfflineReady:
      map['isOfflineReady'] ?? false,

      totalPlays:
      map['totalPlays'] ?? 0,

      totalImpressions:
      map['totalImpressions'] ?? 0,
    );
  }

  // =========================================================
  // COPY WITH
  // =========================================================

  PlaylistItemModel copyWith({

    String? campaignId,

    String? assetId,

    String? ownerId,

    String? campaignTitle,

    int? priority,

    String? mediaUrl,

    String? mediaType,

    String? thumbnailUrl,

    String? fileName,

    int? durationSeconds,

    int? sortOrder,

    bool? isCached,

    bool? isOfflineReady,

    int? totalPlays,

    int? totalImpressions,
  }) {

    return PlaylistItemModel(

      campaignId:
      campaignId ??
          this.campaignId,

      assetId:
      assetId ?? this.assetId,

      ownerId:
      ownerId ?? this.ownerId,

      campaignTitle:
      campaignTitle ??
          this.campaignTitle,

      priority:
      priority ?? this.priority,

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

      isCached:
      isCached ??
          this.isCached,

      isOfflineReady:
      isOfflineReady ??
          this.isOfflineReady,

      totalPlays:
      totalPlays ??
          this.totalPlays,

      totalImpressions:
      totalImpressions ??
          this.totalImpressions,
    );
  }
}