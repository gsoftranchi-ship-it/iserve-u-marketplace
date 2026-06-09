import 'package:flutter/foundation.dart';

import '../engine/playlist_engine.dart';

import '../../players/android_player/managers/cache_manager.dart';


import '../models/playlist_item_model.dart';

import 'campaign_service.dart';

class SyncService {

  // =========================================================
  // SYNC PLAYLIST
  // =========================================================

  static Future<List<PlaylistItemModel>>
  syncSitePlaylist({

    required String siteId,
  }) async {

    try {

      debugPrint(
        "SYNC STARTED FOR SITE: $siteId",
      );

      // =====================================
      // FETCH CAMPAIGNS
      // =====================================

      final campaigns =
      await CampaignService
          .getSiteCampaigns(
        siteId: siteId,
      );

      debugPrint(
        "CAMPAIGNS FOUND: "
            "${campaigns.length}",
      );

      // =====================================
      // EMPTY
      // =====================================

      if (campaigns.isEmpty) {

        debugPrint(
          "NO ACTIVE CAMPAIGNS",
        );

        return [];
      }

      // =====================================
      // PLAYLIST ITEMS
      // =====================================

      final List<PlaylistItemModel>
      playlistItems = [];

      // =====================================
      // LOAD CAMPAIGNS
      // =====================================

      for (final campaign
      in campaigns) {

        debugPrint(
          "LOADING CAMPAIGN: "
              "${campaign.title}",
        );

        // ===================================
        // ACTIVE CHECK
        // ===================================

        if (
        !campaign
            .isCurrentlyRunning
        ) {

          debugPrint(
            "CAMPAIGN SKIPPED",
          );

          continue;
        }

        // ===================================
        // FETCH ASSETS
        // ===================================

        final assets =
        await CampaignService
            .getCampaignAssets(

          campaignId:
          campaign.id,
        );

        debugPrint(
          "ASSETS FOUND: "
              "${assets.length}",
        );

        // ===================================
        // LEGACY FALLBACK
        // ===================================

        if (
        assets.isEmpty &&

            campaign.hasMedia
        ) {

          debugPrint(
            "LEGACY MODE",
          );

          playlistItems.add(

            PlaylistItemModel(

              campaignId:
              campaign.id,

              assetId:
              "legacy_asset",

              ownerId:
              campaign.ownerId,

              campaignTitle:
              campaign.title,

              priority:
              campaign.priority,

              mediaUrl:
              campaign.mediaUrl,

              mediaType:
              campaign.mediaType,

              thumbnailUrl: "",

              fileName:
              campaign.title,

              durationSeconds:
              campaign.durationSeconds,

              sortOrder: 0,

              isCached: false,

              isOfflineReady:
              false,

              totalPlays: 0,

              totalImpressions:
              0,
            ),
          );

          continue;
        }

        // ===================================
        // MULTI-ASSET MODE
        // ===================================

        for (final asset
        in assets) {

          if (!asset.canPlay) {

            debugPrint(
              "INVALID ASSET SKIPPED",
            );

            continue;
          }

          playlistItems.add(

            PlaylistItemModel(

              campaignId:
              campaign.id,

              assetId:
              asset.id,

              ownerId:
              asset.ownerId,

              campaignTitle:
              campaign.title,

              priority:
              asset.priority,

              mediaUrl:
              asset.mediaUrl,

              mediaType:
              asset.mediaType,

              thumbnailUrl:
              asset.thumbnailUrl,

              fileName:
              asset.fileName,

              durationSeconds:
              asset.durationSeconds,

              sortOrder:
              asset.sortOrder,

              isCached: false,

              isOfflineReady:
              false,

              totalPlays:
              asset.totalPlays,

              totalImpressions:
              asset.totalImpressions,
            ),
          );
        }
      }

      debugPrint(
        "RAW PLAYLIST ITEMS: "
            "${playlistItems.length}",
      );

      // =====================================
      // GENERATE PLAYLIST
      // =====================================

      final playlist =
      PlaylistEngine.generatePlaylist(

        campaigns: campaigns,

        siteId: siteId,

        playlistItems:
        playlistItems,
      );

      debugPrint(
        "FINAL PLAYLIST: "
            "${playlist.length}",
      );

      // =====================================
      // CACHE
      // =====================================

      await _cachePlaylist(
        playlist: playlist,
      );

      debugPrint(
        "SYNC COMPLETED",
      );

      return playlist;

    } catch (e) {

      debugPrint(
        "SYNC ERROR: $e",
      );

      return [];
    }
  }

  // =========================================================
  // CACHE PLAYLIST
  // =========================================================

  static Future<void>
  _cachePlaylist({

    required List<PlaylistItemModel>
    playlist,
  }) async {

    try {

      for (final item
      in playlist) {

        // ===================================
        // WEB MODE
        // ===================================

        if (kIsWeb) {

          debugPrint(
            "WEB STREAM MODE",
          );

          continue;
        }

        final exists =
        await CacheManager
            .isFileCached(

          url: item.mediaUrl,

          mediaType:
          item.mediaType,
        );

        if (exists) {

          debugPrint(
            "MEDIA ALREADY CACHED",
          );

          continue;
        }

        debugPrint(
          "DOWNLOADING MEDIA",
        );

        final result =
        await CacheManager
            .downloadMedia(

          url: item.mediaUrl,

          mediaType:
          item.mediaType,
        );

        if (result == null) {

          debugPrint(
            "CACHE FAILED",
          );
        }
      }

    } catch (e) {

      debugPrint(
        "CACHE PLAYLIST ERROR: $e",
      );
    }
  }

  // =========================================================
  // VALIDATE PLAYLIST
  // =========================================================

  static Future<List<PlaylistItemModel>>
  validateLocalPlaylist({

    required List<PlaylistItemModel>
    playlist,
  }) async {

    final valid =
    <PlaylistItemModel>[];

    try {

      for (final item
      in playlist) {

        // ===================================
        // WEB MODE
        // ===================================

        if (kIsWeb) {

          valid.add(
            item.copyWith(

              isCached: false,

              isOfflineReady:
              false,
            ),
          );

          continue;
        }

        // ===================================
        // CACHE CHECK
        // ===================================

        final exists =
        await CacheManager
            .isFileCached(

          url: item.mediaUrl,

          mediaType:
          item.mediaType,
        );

        if (!exists) {

          debugPrint(
            "MISSING CACHE FILE",
          );

          continue;
        }

        valid.add(

          item.copyWith(

            isCached: true,

            isOfflineReady: true,
          ),
        );
      }

      debugPrint(
        "VALID PLAYLIST: "
            "${valid.length}",
      );

      return valid;

    } catch (e) {

      debugPrint(
        "VALIDATION ERROR: $e",
      );

      return [];
    }
  }

  // =========================================================
  // PRELOAD PLAYLIST
  // =========================================================

  static Future<void>
  preloadPlaylist({

    required List<PlaylistItemModel>
    playlist,
  }) async {

    try {

      debugPrint(
        "PRELOAD STARTED",
      );

      for (final item
      in playlist) {

        if (kIsWeb) {
          continue;
        }

        final exists =
        await CacheManager
            .isFileCached(

          url: item.mediaUrl,

          mediaType:
          item.mediaType,
        );

        if (exists) {
          continue;
        }

        await CacheManager
            .downloadMedia(

          url: item.mediaUrl,

          mediaType:
          item.mediaType,
        );
      }

      debugPrint(
        "PRELOAD COMPLETED",
      );

    } catch (e) {

      debugPrint(
        "PRELOAD ERROR: $e",
      );
    }
  }

  // =========================================================
  // CLEANUP CACHE
  // =========================================================

  static Future<void>
  cleanupUnusedCache({

    required List<PlaylistItemModel>
    playlist,
  }) async {

    try {

      debugPrint(
        "CACHE CLEANUP STARTED",
      );

      // ===================================
      // FUTURE:
      // SMART CACHE CLEANUP
      // ===================================

      debugPrint(
        "CACHE CLEANUP COMPLETED",
      );

    } catch (e) {

      debugPrint(
        "CACHE CLEANUP ERROR: $e",
      );
    }
  }
}