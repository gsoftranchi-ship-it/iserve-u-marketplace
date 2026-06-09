import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/campaign_model.dart';
import '../models/playlist_item_model.dart';

class PlaylistEngine {

  // =========================================================
  // GENERATE PLAYLIST
  // =========================================================

  static List<PlaylistItemModel>
  generatePlaylist({

    required List<CampaignModel> campaigns,

    required String siteId,

    required List<PlaylistItemModel>
    playlistItems,
  }) {

    try {

      debugPrint(
        "PLAYLIST ENGINE STARTED",
      );

      // =====================================
      // EMPTY
      // =====================================

      if (playlistItems.isEmpty) {

        debugPrint(
          "NO PLAYLIST ITEMS",
        );

        return [];
      }

      // =====================================
      // FILTER VALID ITEMS
      // =====================================

      final validItems =
      playlistItems.where((item) {

        // ===============================
        // MEDIA URL
        // ===============================

        if (item.mediaUrl.isEmpty) {

          debugPrint(
            "INVALID MEDIA URL",
          );

          return false;
        }

        // ===============================
        // MEDIA TYPE
        // ===============================

        if (

        item.mediaType !=
            "image" &&

            item.mediaType !=
                "video"
        ) {

          debugPrint(
            "INVALID MEDIA TYPE",
          );

          return false;
        }

        return true;

      }).toList();

      // =====================================
      // EMPTY AFTER FILTER
      // =====================================

      if (validItems.isEmpty) {

        debugPrint(
          "NO VALID PLAYLIST ITEMS",
        );

        return [];
      }

      debugPrint(
        "VALID ITEMS: "
            "${validItems.length}",
      );

      // =====================================
      // GROUP BY CAMPAIGN
      // =====================================

      final grouped =
      _groupByCampaign(
        validItems,
      );

      // =====================================
      // WEIGHTED ROTATION
      // =====================================

      final weighted =
      _buildWeightedRotation(
        grouped,
      );

      // =====================================
      // SAFE SHUFFLE
      // =====================================

      final shuffled =
      _safeShuffle(
        weighted,
      );

      // =====================================
      // DIVERSITY PASS
      // =====================================

      final diversified =
      _diversifyPlaylist(
        shuffled,
      );

      debugPrint(
        "FINAL PLAYLIST SIZE: "
            "${diversified.length}",
      );

      return diversified;

    } catch (e) {

      debugPrint(
        "PLAYLIST ENGINE ERROR: $e",
      );

      return [];
    }
  }

  // =========================================================
  // GROUP CAMPAIGNS
  // =========================================================

  static Map<String,
      List<PlaylistItemModel>>

  _groupByCampaign(

      List<PlaylistItemModel>
      items,
      ) {

    final grouped =
    <String,
        List<PlaylistItemModel>>{};

    for (final item in items) {

      grouped.putIfAbsent(

        item.campaignId,

            () => [],
      );

      grouped[item.campaignId]!
          .add(item);
    }

    return grouped;
  }

  // =========================================================
  // WEIGHTED ROTATION
  // =========================================================

  static List<PlaylistItemModel>
  _buildWeightedRotation(

      Map<String,
          List<PlaylistItemModel>>
      grouped,
      ) {

    final weighted =
    <PlaylistItemModel>[];

    grouped.forEach(

          (campaignId, items) {

        // ===================================
        // PRIORITY
        // ===================================

        final priority =
            items.first.priority;

        int weight = 1;

        // ===================================
        // ENTERPRISE WEIGHT
        // ===================================

        if (priority >= 10) {

          weight = 6;

        } else if (priority >= 8) {

          weight = 5;

        } else if (priority >= 6) {

          weight = 4;

        } else if (priority >= 4) {

          weight = 3;

        } else if (priority >= 2) {

          weight = 2;
        }

        // ===================================
        // ADD WEIGHTED ITEMS
        // ===================================

        for (
        int i = 0;
        i < weight;
        i++
        ) {

          weighted.addAll(items);
        }
      },
    );

    debugPrint(
      "WEIGHTED PLAYLIST SIZE: "
          "${weighted.length}",
    );

    return weighted;
  }

  // =========================================================
  // SAFE SHUFFLE
  // =========================================================

  static List<PlaylistItemModel>
  _safeShuffle(

      List<PlaylistItemModel>
      items,
      ) {

    if (items.length <= 1) {
      return items;
    }

    final shuffled =
    List<PlaylistItemModel>
        .from(items);

    shuffled.shuffle(
      Random(),
    );

    // =====================================
    // AVOID SAME CAMPAIGN
    // =====================================

    for (
    int i = 1;
    i < shuffled.length;
    i++
    ) {

      final current =
      shuffled[i];

      final previous =
      shuffled[i - 1];

      if (
      current.campaignId ==
          previous.campaignId
      ) {

        for (
        int j = i + 1;
        j < shuffled.length;
        j++
        ) {

          if (
          shuffled[j].campaignId !=
              current.campaignId
          ) {

            final temp =
            shuffled[i];

            shuffled[i] =
            shuffled[j];

            shuffled[j] = temp;

            break;
          }
        }
      }
    }

    return shuffled;
  }

  // =========================================================
// DIVERSITY PASS
// =========================================================

  static List<PlaylistItemModel>
  _diversifyPlaylist(

      List<PlaylistItemModel>
      items,
      ) {

    if (items.length <= 1) {
      return items;
    }

    final diversified =
    <PlaylistItemModel>[];

    String? lastMediaUrl;

    for (final item in items) {

      // ===================================
      // AVOID IMMEDIATE DUPLICATE
      // ===================================

      if (
      item.mediaUrl ==
          lastMediaUrl
      ) {

        continue;
      }

      diversified.add(item);

      lastMediaUrl =
          item.mediaUrl;
    }

    // =====================================
    // EMPTY PROTECTION
    // =====================================

    if (diversified.isEmpty) {

      return items;
    }

    return diversified;
  }

  // =========================================================
  // DEBUG
  // =========================================================

  static void debugPlaylist(

      List<PlaylistItemModel>
      playlist,
      ) {

    debugPrint(
      "======================",
    );

    debugPrint(
      "PLAYLIST DEBUG",
    );

    debugPrint(
      "======================",
    );

    for (
    int i = 0;
    i < playlist.length;
    i++
    ) {

      final item =
      playlist[i];

      debugPrint(

        "$i | "
            "${item.mediaType} | "
            "P${item.priority} | "
            "${item.campaignTitle}",
      );
    }

    debugPrint(
      "======================",
    );
  }
}