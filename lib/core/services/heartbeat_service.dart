import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';

class HeartbeatService {

  // =========================================================
  // FIRESTORE
  // =========================================================

  static final FirebaseFirestore
  _firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // TIMER
  // =========================================================

  Timer? _heartbeatTimer;

  // =========================================================
  // DEVICE
  // =========================================================

  final String deviceId;

  final String siteId;

  // =========================================================
  // PLAYBACK STATE
  // =========================================================

  String _currentMedia = "";

  bool _isOnline = true;

  String _appVersion = "1.0.0";

  int _playlistSize = 0;

  int _totalPlaybackErrors = 0;

  // =========================================================
  // SYSTEM STATE
  // =========================================================



  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  HeartbeatService({

    required this.deviceId,

    required this.siteId,
  });

  // =========================================================
  // START
  // =========================================================

  void start({

    required String currentMedia,

    required bool isOnline,

    required String appVersion,

    int playlistSize = 0,
  }) {

    debugPrint(
      "HEARTBEAT STARTED",
    );

    _currentMedia =
        currentMedia;

    _isOnline =
        isOnline;

    _appVersion =
        appVersion;

    _playlistSize =
        playlistSize;

    // =====================================
    // SEND IMMEDIATELY
    // =====================================

    _sendHeartbeat();

    // =====================================
    // LOOP
    // =====================================

    _heartbeatTimer?.cancel();

    _heartbeatTimer =
        Timer.periodic(

          const Duration(
            seconds: 30,
          ),

              (_) {

            _sendHeartbeat();
          },
        );
  }

  // =========================================================
  // UPDATE PLAYBACK
  // =========================================================

  Future<void>
  updatePlayback({

    required String currentMedia,

    int? playlistSize,
  }) async {

    try {

      _currentMedia =
          currentMedia;

      if (playlistSize != null) {

        _playlistSize =
            playlistSize;
      }



      await _firestore
          .collection("devices")
          .doc(deviceId)
          .update({

        // ===================================
        // PLAYBACK
        // ===================================

        "currentMedia":
        currentMedia,

        "playlistSize":
        _playlistSize,

        // ===================================
        // TIMESTAMPS
        // ===================================

        "lastPlaybackUpdate":
        FieldValue.serverTimestamp(),
      });

      debugPrint(
        "PLAYBACK UPDATED",
      );

    } catch (e) {

      debugPrint(
        "PLAYBACK UPDATE ERROR: $e",
      );
    }
  }

  // =========================================================
  // PLAYBACK ERROR
  // =========================================================

  Future<void>
  reportPlaybackError({

    required String error,
  }) async {

    try {

      _totalPlaybackErrors++;

      await _firestore
          .collection("devices")
          .doc(deviceId)
          .update({

        "lastPlaybackError":
        error,

        "totalPlaybackErrors":
        _totalPlaybackErrors,

        "lastPlaybackErrorAt":
        FieldValue.serverTimestamp(),
      });

      debugPrint(
        "PLAYBACK ERROR REPORTED",
      );

    } catch (e) {

      debugPrint(
        "REPORT ERROR FAILED: $e",
      );
    }
  }

  // =========================================================
  // HEARTBEAT
  // =========================================================

  Future<void>
  _sendHeartbeat() async {

    try {



      await _firestore
          .collection("devices")
          .doc(deviceId)
          .set({

        // ===================================
        // DEVICE
        // ===================================

        "deviceId":
        deviceId,

        "siteId":
        siteId,

        // ===================================
        // STATUS
        // ===================================

        "online":
        _isOnline,

        "currentMedia":
        _currentMedia,

        "playlistSize":
        _playlistSize,

        // ===================================
        // APP
        // ===================================

        "appVersion":
        _appVersion,

        // ===================================
        // PLATFORM
        // ===================================

        "platform":
        _platformName,

        "isWeb":
        kIsWeb,

        // ===================================
        // ANALYTICS
        // ===================================

        "totalPlaybackErrors":
        _totalPlaybackErrors,

        // ===================================
        // TIMESTAMPS
        // ===================================

        "lastSeen":
        FieldValue.serverTimestamp(),

        "updatedAt":
        FieldValue.serverTimestamp(),

      },

          SetOptions(
            merge: true,
          ));

      debugPrint(
        "HEARTBEAT SENT",
      );

    } catch (e) {

      debugPrint(
        "HEARTBEAT ERROR: $e",
      );
    }
  }

  // =========================================================
  // OFFLINE
  // =========================================================

  Future<void>
  markOffline() async {

    try {

      await _firestore
          .collection("devices")
          .doc(deviceId)
          .update({

        "online": false,

        "lastOffline":
        FieldValue.serverTimestamp(),
      });

      debugPrint(
        "DEVICE OFFLINE",
      );

    } catch (e) {

      debugPrint(
        "OFFLINE ERROR: $e",
      );
    }
  }

  // =========================================================
  // PLATFORM
  // =========================================================

  String get _platformName {

    if (kIsWeb) {
      return "web";
    }

    try {

      return defaultTargetPlatform
          .name;

    } catch (_) {

      return "unknown";
    }
  }

  // =========================================================
  // STOP
  // =========================================================

  Future<void> stop() async {

    try {

      _heartbeatTimer?.cancel();

      await markOffline();

      debugPrint(
        "HEARTBEAT STOPPED",
      );

    } catch (e) {

      debugPrint(
        "STOP HEARTBEAT ERROR: $e",
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  Future<void> dispose() async {

    await stop();
  }
}