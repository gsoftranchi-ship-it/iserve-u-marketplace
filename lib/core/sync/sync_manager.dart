import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/playlist_item_model.dart';

import '../services/sync_service.dart';

import '../../players/shared/managers/playback_manager.dart';

class SyncManager {

  // =========================================================
  // CONFIG
  // =========================================================

  final String siteId;

  final PlaybackManager
  playbackManager;

  // =========================================================
  // TIMER
  // =========================================================

  Timer? _syncTimer;

  // =========================================================
  // STATE
  // =========================================================

  bool _disposed = false;

  bool _syncing = false;

  List<PlaylistItemModel>
  _lastPlaylist = [];

  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  SyncManager({

    required this.siteId,

    required this.playbackManager,
  });

  // =========================================================
  // START
  // =========================================================

  Future<void> start() async {

    try {

      if (_disposed) {
        return;
      }

      debugPrint(
        "SYNC MANAGER STARTED",
      );

      // =====================================
      // INITIAL SYNC
      // =====================================

      await syncNow();

      // =====================================
      // PERIODIC SYNC
      // =====================================

      _syncTimer?.cancel();

      _syncTimer =
          Timer.periodic(

            const Duration(
              minutes: 2,
            ),

                (_) async {

              await syncNow();
            },
          );

    } catch (e) {

      debugPrint(
        "SYNC START ERROR: $e",
      );
    }
  }

  // =========================================================
  // SYNC NOW
  // =========================================================

  Future<void> syncNow()
  async {

    try {

      if (_disposed) {
        return;
      }

      if (_syncing) {
        return;
      }

      _syncing = true;

      debugPrint(
        "SYNC STARTED",
      );

      // =====================================
      // FETCH PLAYLIST
      // =====================================

      final playlist =
      await SyncService
          .syncSitePlaylist(

        siteId: siteId,
      );

      // =====================================
      // VALIDATE
      // =====================================

      final validPlaylist =
      await SyncService
          .validateLocalPlaylist(

        playlist: playlist,
      );

      // =====================================
      // EMPTY
      // =====================================

      if (validPlaylist.isEmpty) {

        debugPrint(
          "SYNC EMPTY PLAYLIST",
        );

        return;
      }

      // =====================================
      // FIRST LOAD
      // =====================================

      if (_lastPlaylist.isEmpty) {

        debugPrint(
          "INITIAL PLAYLIST LOADED",
        );

        _lastPlaylist =
            validPlaylist;

        await playbackManager
            .updatePlaylist(
          validPlaylist,
        );

        return;
      }

      // =====================================
      // CHECK CHANGES
      // =====================================

      final changed =
      _playlistChanged(
        validPlaylist,
      );

      if (!changed) {

        debugPrint(
          "SYNC NO CHANGES",
        );

        return;
      }

      debugPrint(
        "SYNC PLAYLIST UPDATED",
      );

      _lastPlaylist =
          validPlaylist;

      // =====================================
      // UPDATE PLAYBACK
      // =====================================

      await playbackManager
          .updatePlaylist(
        validPlaylist,
      );

    } catch (e) {

      debugPrint(
        "SYNC ERROR: $e",
      );

    } finally {

      _syncing = false;
    }
  }

  // =========================================================
  // PLAYLIST CHANGED
  // =========================================================

  bool _playlistChanged(
      List<PlaylistItemModel>
      newPlaylist,
      ) {

    if (
    _lastPlaylist.length !=
        newPlaylist.length
    ) {

      return true;
    }

    for (
    int i = 0;
    i < newPlaylist.length;
    i++
    ) {

      if (
      _lastPlaylist[i]
          .mediaUrl !=

          newPlaylist[i]
              .mediaUrl
      ) {

        return true;
      }
    }

    return false;
  }

  // =========================================================
  // STOP
  // =========================================================

  void stop() {

    _syncTimer?.cancel();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  void dispose() {

    _disposed = true;

    stop();
  }
}