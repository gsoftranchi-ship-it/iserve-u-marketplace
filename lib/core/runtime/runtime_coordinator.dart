import 'dart:async';
import 'runtime_state.dart';
import 'package:flutter/foundation.dart';
import '../models/playlist_item_model.dart';
import '../services/heartbeat_service.dart';
import '../services/watchdog_service.dart';
import '../../players/shared/managers/playback_manager.dart';
import '../sync/sync_manager.dart';

class RuntimeCoordinator {

  // =========================================================
  // CONFIG
  // =========================================================

  final List<PlaylistItemModel> playlist;

  final String siteId;

  final String deviceId;

  // =========================================================
  // SERVICES
  // =========================================================

  PlaybackManager? _playbackManager;

  HeartbeatService? _heartbeatService;

  WatchdogService? _watchdogService;

  SyncManager? _syncManager;

  // =========================================================
  // STREAM
  // =========================================================

  StreamSubscription? _mediaSubscription;

  final StreamController<PlaylistItemModel>
  _mediaStreamController =
  StreamController.broadcast();

  Stream<PlaylistItemModel>
  get mediaStream =>
      _mediaStreamController.stream;

  // =========================================================
  // STATE
  // =========================================================

  bool _initialized = false;
  bool _disposed = false;
  RuntimeState _state =
  RuntimeState.initial();

  RuntimeState
  get state => _state;

  final StreamController<
      RuntimeState>
  _stateController =
  StreamController.broadcast();

  Stream<RuntimeState>
  get stateStream =>
      _stateController.stream;

  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  RuntimeCoordinator({

    required this.playlist,

    required this.siteId,

    required this.deviceId,
  });

  // =========================================================
  // INITIALIZE
  // =========================================================

  void _updateState(
      RuntimeState newState,
      ) {

    _state = newState;

    if (
    !_stateController.isClosed
    ) {

      _stateController.add(
        _state,
      );
    }
  }
  Future<void> initialize() async {

    try {

      if (_initialized) {
        return;
      }

      debugPrint(
        "RUNTIME INITIALIZING",
      );
      _updateState(

        _state.copyWith(

          status:
          RuntimeStatus.initializing,

          updatedAt:
          DateTime.now(),
        ),
      );

      // =====================================
      // PLAYBACK
      // =====================================

      _playbackManager =
          PlaybackManager(
            playlist: playlist,
          );

      // =====================================
      // HEARTBEAT
      // =====================================

      _heartbeatService =
          HeartbeatService(
            deviceId: deviceId,
            siteId: siteId,
          );

      // =====================================
      // WATCHDOG
      // =====================================

      _watchdogService =
          WatchdogService(
            onFreezeDetected:
            _recoverPlayback,
          );

      _watchdogService?.start();

      // =====================================
      // PLAYBACK STREAM
      // =====================================

      _mediaSubscription =
          _playbackManager!
              .mediaStream
              .listen(_onMediaChanged);

      // =====================================
      // START PLAYBACK
      // =====================================

      await _playbackManager!
          .start();

      _syncManager =
          SyncManager(

            siteId: siteId,

            playbackManager:
            _playbackManager!,
          );

      await _syncManager!
          .start();

      // =====================================
      // START HEARTBEAT
      // =====================================

      _heartbeatService?.start(

        currentMedia: "",

        isOnline: true,

        appVersion: "3.0.0",

        playlistSize:
        playlist.length,
      );

      _initialized = true;
      _updateState(

        _state.copyWith(

          status:
          RuntimeStatus.running,

          playlistSize:
          playlist.length,

          updatedAt:
          DateTime.now(),
        ),
      );

      debugPrint(
        "RUNTIME READY",
      );

    } catch (e, stack) {

      debugPrint(
        "RUNTIME INIT ERROR: $e",
      );

      debugPrint(
        stack.toString(),
      );

      rethrow;
    }
  }

  // =========================================================
  // MEDIA CHANGED
  // =========================================================

  Future<void>
  _onMediaChanged(
      PlaylistItemModel media,
      ) async {

    try {

      if (_disposed) {
        return;
      }

      _watchdogService?.beat();

      await _heartbeatService
          ?.updatePlayback(

        currentMedia:
        media.mediaUrl,

        playlistSize:
        playlist.length,
      );

      _updateState(

        _state.copyWith(

          currentMedia:
          media,

          status:
          RuntimeStatus.running,

          updatedAt:
          DateTime.now(),
        ),
      );

      if (
      !_mediaStreamController
          .isClosed
      ) {

        _mediaStreamController
            .add(media);
      }

    } catch (e) {

      debugPrint(
        "RUNTIME MEDIA ERROR: $e",
      );
    }
  }

  // =========================================================
  // VIDEO COMPLETE
  // =========================================================

  Future<void>
  onVideoCompleted()
  async {

    try {

      await _playbackManager
          ?.onVideoCompleted();

    } catch (e) {

      debugPrint(
        "VIDEO COMPLETE ERROR: $e",
      );
    }
  }

  // =========================================================
  // VIDEO ERROR
  // =========================================================

  Future<void>
  onVideoError()
  async {

    try {

      await _playbackManager
          ?.onVideoError();

    } catch (e) {

      debugPrint(
        "VIDEO ERROR: $e",
      );
    }
  }

  // =========================================================
  // WATCHDOG RECOVERY
  // =========================================================

  Future<void>
  _recoverPlayback()
  async {

    try {

      if (_disposed) {
        return;
      }

      _updateState(

        _state.copyWith(

          status:
          RuntimeStatus.recovering,

          isRecovering: true,

          updatedAt:
          DateTime.now(),
        ),
      );

      debugPrint(
        "RUNTIME RECOVERY",
      );

      await _playbackManager
          ?.restart();
      _updateState(

        _state.copyWith(

          status:
          RuntimeStatus.running,

          isRecovering: false,

          updatedAt:
          DateTime.now(),
        ),
      );

    } catch (e) {

      debugPrint(
        "RECOVERY ERROR: $e",
      );
    }
  }

  // =========================================================
  // HEARTBEAT
  // =========================================================

  void beat() {

    _watchdogService?.beat();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  Future<void> dispose()
  async {

    try {

      if (_disposed) {
        return;
      }

      _disposed = true;

      _updateState(

        _state.copyWith(

          status:
          RuntimeStatus.disposed,

          updatedAt:
          DateTime.now(),
        ),
      );
      _syncManager
          ?.dispose();

      await _mediaSubscription
          ?.cancel();

      _playbackManager
          ?.dispose();

      await _heartbeatService
          ?.dispose();

      _watchdogService
          ?.dispose();

      await _mediaStreamController
          .close();
      await _stateController.close();

      debugPrint(
        "RUNTIME DISPOSED",
      );

    } catch (e) {

      debugPrint(
        "RUNTIME DISPOSE ERROR: $e",
      );
    }

  }
}