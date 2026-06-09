import 'dart:async';

import 'package:flutter/foundation.dart';

class WatchdogService {

  // =========================================================
  // CALLBACK
  // =========================================================

  final Future<void> Function()
  onFreezeDetected;

  // =========================================================
  // CONFIG
  // =========================================================

  final Duration timeout;

  final Duration checkInterval;

  final Duration recoveryCooldown;

  // =========================================================
  // TIMERS
  // =========================================================

  Timer? _watchdogTimer;

  // =========================================================
  // STATE
  // =========================================================

  DateTime _lastHeartbeat =
  DateTime.now();

  DateTime? _lastRecovery;

  bool _isRunning = false;

  bool _isRecovering = false;

  int _totalHeartbeats = 0;

  int _totalRecoveries = 0;

  // =========================================================
  // CONSTRUCTOR
  // =========================================================

  WatchdogService({

    required this.onFreezeDetected,

    this.timeout =
    const Duration(minutes: 3),

    this.checkInterval =
    const Duration(seconds: 15),

    this.recoveryCooldown =
    const Duration(seconds: 20),
  });

  // =========================================================
  // START
  // =========================================================

  void start() {

    try {

      if (_isRunning) {

        debugPrint(
          "WATCHDOG ALREADY RUNNING",
        );

        return;
      }

      debugPrint(
        "WATCHDOG STARTED",
      );

      _isRunning = true;

      beat();

      _watchdogTimer?.cancel();

      _watchdogTimer =
          Timer.periodic(

            checkInterval,

                (_) async {

              await _checkHealth();
            },
          );

    } catch (e) {

      debugPrint(
        "WATCHDOG START ERROR: $e",
      );
    }
  }

  // =========================================================
  // HEALTH CHECK
  // =========================================================

  Future<void>
  _checkHealth() async {

    try {

      if (
      !_isRunning ||

          _isRecovering
      ) {

        return;
      }

      final difference =
      DateTime.now().difference(
        _lastHeartbeat,
      );

      // =====================================
      // HEALTHY
      // =====================================

      if (difference <= timeout) {
        return;
      }

      if (_totalHeartbeats < 3) {
        return;
      }

      debugPrint(
        "WATCHDOG FREEZE DETECTED",
      );

      // =====================================
      // COOLDOWN
      // =====================================

      if (_lastRecovery != null) {

        final sinceRecovery =
        DateTime.now().difference(
          _lastRecovery!,
        );

        if (
        sinceRecovery <
            recoveryCooldown
        ) {

          debugPrint(
            "WATCHDOG COOLDOWN ACTIVE",
          );

          return;
        }
      }

      // =====================================
      // RECOVER
      // =====================================

      await _recover();

    } catch (e) {

      debugPrint(
        "WATCHDOG CHECK ERROR: $e",
      );
    }
  }

  // =========================================================
  // RECOVER
  // =========================================================

  Future<void> _recover()
  async {

    try {

      if (_isRecovering) {
        return;
      }

      _isRecovering = true;

      _totalRecoveries++;

      _lastRecovery =
          DateTime.now();

      debugPrint(
        "WATCHDOG RECOVERY STARTED",
      );

      await onFreezeDetected();

      beat();

      debugPrint(
        "WATCHDOG RECOVERY SUCCESS",
      );

    } catch (e) {

      debugPrint(
        "WATCHDOG RECOVERY ERROR: $e",
      );

    } finally {

      _isRecovering = false;
    }
  }

  // =========================================================
  // HEARTBEAT
  // =========================================================

  void beat() {

    _lastHeartbeat =
        DateTime.now();

    _totalHeartbeats++;


  }

  // =========================================================
  // FORCE CHECK
  // =========================================================

  Future<void>
  forceCheck() async {

    try {

      debugPrint(
        "WATCHDOG FORCE CHECK",
      );

      await _checkHealth();

    } catch (e) {

      debugPrint(
        "FORCE CHECK ERROR: $e",
      );
    }
  }

  // =========================================================
  // RESET
  // =========================================================

  void reset() {

    beat();

    debugPrint(
      "WATCHDOG RESET",
    );
  }

  // =========================================================
  // STATUS
  // =========================================================

  bool get isHealthy {

    final difference =
    DateTime.now().difference(
      _lastHeartbeat,
    );

    return difference <= timeout;
  }

  bool get isRecovering =>
      _isRecovering;

  int get totalRecoveries =>
      _totalRecoveries;

  int get totalHeartbeats =>
      _totalHeartbeats;

  Duration get lastHeartbeatAge =>

      DateTime.now().difference(
        _lastHeartbeat,
      );

  // =========================================================
  // STOP
  // =========================================================

  void stop() {

    try {

      _isRunning = false;

      _watchdogTimer?.cancel();

      debugPrint(
        "WATCHDOG STOPPED",
      );

    } catch (e) {

      debugPrint(
        "WATCHDOG STOP ERROR: $e",
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  void dispose() {

    stop();
  }
}