import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/playlist_item_model.dart';

class PlaybackManager {

  // =========================================================
  // PLAYLIST
  // =========================================================

  List<PlaylistItemModel>
  _playlist;

  List<PlaylistItemModel>
  get playlist => _playlist;

  // =========================================================
  // STREAM
  // =========================================================

  final StreamController<
      PlaylistItemModel>
  _mediaController =
  StreamController.broadcast();

  Stream<PlaylistItemModel>
  get mediaStream =>
      _mediaController.stream;

  // =========================================================
  // STATE
  // =========================================================

  int _currentIndex = 0;

  bool _isDisposed = false;

  bool _started = false;

  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  PlaybackManager({

    required List<PlaylistItemModel>
    playlist,
  }) : _playlist = playlist;

  // =========================================================
  // CURRENT ITEM
  // =========================================================

  PlaylistItemModel?
  get currentItem {

    if (_playlist.isEmpty) {
      return null;
    }

    if (
    _currentIndex >=
        _playlist.length
    ) {

      _currentIndex = 0;
    }

    return _playlist[
    _currentIndex
    ];
  }

  // =========================================================
  // START
  // =========================================================

  Future<void> start()
  async {

    try {

      if (_isDisposed) {
        return;
      }

      if (_started) {
        return;
      }

      _started = true;

      debugPrint(
        "PLAYBACK STARTED",
      );

      // =====================================
      // EMPTY PLAYLIST ALLOWED
      // =====================================

      if (_playlist.isEmpty) {

        debugPrint(
          "PLAYBACK WAITING FOR PLAYLIST",
        );

        return;
      }

      await _emitCurrentMedia();

    } catch (e) {

      debugPrint(
        "PLAYBACK START ERROR: $e",
      );
    }
  }

  // =========================================================
  // EMIT CURRENT MEDIA
  // =========================================================

  Future<void>
  _emitCurrentMedia()
  async {

    try {

      if (_isDisposed) {
        return;
      }

      final media =
          currentItem;

      if (media == null) {
        return;
      }

      debugPrint(
        "EMIT MEDIA: ${media.mediaUrl}",
      );

      if (
      !_mediaController
          .isClosed
      ) {

        _mediaController.add(
          media,
        );
      }

    } catch (e) {

      debugPrint(
        "EMIT MEDIA ERROR: $e",
      );
    }
  }

  // =========================================================
  // NEXT
  // =========================================================

  Future<void>
  next()
  async {

    try {

      if (_isDisposed) {
        return;
      }

      if (_playlist.isEmpty) {
        return;
      }

      _currentIndex++;

      if (
      _currentIndex >=
          _playlist.length
      ) {

        _currentIndex = 0;
      }

      await _emitCurrentMedia();

    } catch (e) {

      debugPrint(
        "NEXT MEDIA ERROR: $e",
      );
    }
  }

  // =========================================================
  // VIDEO COMPLETE
  // =========================================================

  Future<void>
  onVideoCompleted()
  async {

    await next();
  }

  // =========================================================
  // VIDEO ERROR
  // =========================================================

  Future<void>
  onVideoError()
  async {

    await next();
  }

  // =========================================================
  // UPDATE PLAYLIST
  // =========================================================

  Future<void>
  updatePlaylist(
      List<PlaylistItemModel>
      newPlaylist,
      ) async {

    try {

      if (_isDisposed) {
        return;
      }

      if (newPlaylist.isEmpty) {

        debugPrint(
          "PLAYLIST UPDATE IGNORED: EMPTY",
        );

        return;
      }

      debugPrint(
        "PLAYLIST UPDATED",
      );

      final wasEmpty =
          _playlist.isEmpty;

      final currentMedia =
          currentItem;

      _playlist = newPlaylist;

      // =====================================
      // FIRST PLAYLIST LOAD
      // =====================================

      if (wasEmpty) {

        _currentIndex = 0;

        await _emitCurrentMedia();

        return;
      }

      // =====================================
      // KEEP CURRENT MEDIA
      // =====================================

      if (currentMedia != null) {

        final existingIndex =
        _playlist.indexWhere(

              (item) =>

          item.mediaUrl ==
              currentMedia.mediaUrl,
        );

        if (existingIndex >= 0) {

          _currentIndex =
              existingIndex;

          return;
        }
      }

      // =====================================
      // FALLBACK
      // =====================================

      _currentIndex = 0;

      await _emitCurrentMedia();

    } catch (e) {

      debugPrint(
        "PLAYLIST UPDATE ERROR: $e",
      );
    }
  }

  // =========================================================
  // RESTART
  // =========================================================

  Future<void>
  restart()
  async {

    try {

      if (_isDisposed) {
        return;
      }

      _currentIndex = 0;

      await _emitCurrentMedia();

    } catch (e) {

      debugPrint(
        "PLAYBACK RESTART ERROR: $e",
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  void dispose() {

    _isDisposed = true;

    unawaited(
      _mediaController.close(),
    );
  }
}