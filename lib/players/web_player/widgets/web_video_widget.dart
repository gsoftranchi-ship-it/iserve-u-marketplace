import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget
    extends StatefulWidget {

  final String url;

  final VoidCallback? onHeartbeat;

  final VoidCallback? onVideoFinished;

  final VoidCallback? onVideoError;

  const VideoPlayerWidget({

    super.key,

    required this.url,

    this.onHeartbeat,

    this.onVideoFinished,

    this.onVideoError,
  });

  @override
  State<VideoPlayerWidget>
  createState() =>
      _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState
    extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {

  // =========================================================
  // CONTROLLER
  // =========================================================

  VideoPlayerController?
  _controller;

  // =========================================================
  // TIMERS
  // =========================================================

  Timer? _heartbeatTimer;

  // =========================================================
  // STATE
  // =========================================================

  bool _isReady = false;

  bool _hasError = false;

  bool _isDisposed = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _initialize();
  }

  // =========================================================
  // APP LIFECYCLE
  // =========================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {

    final controller =
        _controller;

    if (controller == null) {
      return;
    }

    if (
    state ==
        AppLifecycleState.paused
    ) {

      controller.pause();
    }

    if (
    state ==
        AppLifecycleState.resumed
    ) {

      if (
      !_hasError &&
          _isReady
      ) {

        controller.play();
      }
    }
  }

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void>
  _initialize()
  async {

    try {

      if (_isDisposed) {
        return;
      }

      debugPrint(
        "VIDEO INITIALIZING",
      );

      late VideoPlayerController
      controller;

      // =====================================
      // WEB
      // =====================================

      if (kIsWeb) {

        debugPrint(
          "WEB VIDEO PLAYBACK",
        );

        controller =
            VideoPlayerController
                .networkUrl(
              Uri.parse(
                widget.url,
              ),
            );

      } else {

        // ===================================
        // LOCAL FILE
        // ===================================

        final localFile =
        File(widget.url);

        final exists =
        await localFile.exists();

        if (exists) {

          debugPrint(
            "LOCAL VIDEO PLAYBACK",
          );

          controller =
              VideoPlayerController
                  .file(
                localFile,
              );

        } else {

          debugPrint(
            "NETWORK VIDEO FALLBACK",
          );

          controller =
              VideoPlayerController
                  .networkUrl(
                Uri.parse(
                  widget.url,
                ),
              );
        }
      }

      _controller = controller;

      // =====================================
      // INITIALIZE
      // =====================================

      await controller.initialize();

      if (_isDisposed) {
        return;
      }

      // =====================================
      // CONFIG
      // =====================================

      await controller.setLooping(
        true,
      );

      await controller.setVolume(
        1.0,
      );

      // =====================================
      // LISTENER
      // =====================================

      controller.addListener(
        _videoListener,
      );

      // =====================================
      // PLAY
      // =====================================

      await controller.play();

      // =====================================
      // HEARTBEAT
      // =====================================

      _startHeartbeat();

      if (!mounted) {
        return;
      }

      setState(() {

        _isReady = true;

        _hasError = false;
      });

      debugPrint(
        "VIDEO READY",
      );

    } catch (e) {

      debugPrint(
        "VIDEO INIT ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {

        _hasError = true;

        _isReady = false;
      });

      widget.onVideoError
          ?.call();
    }
  }

  // =========================================================
  // VIDEO LISTENER
  // =========================================================

  void _videoListener() {

    try {

      if (_isDisposed) {
        return;
      }

      final controller =
          _controller;

      if (controller == null) {
        return;
      }

      final value =
          controller.value;

      if (!value.isInitialized) {
        return;
      }

      // =====================================
      // ERROR
      // =====================================

      if (value.hasError) {

        debugPrint(
          "VIDEO PLAYER ERROR",
        );

        widget.onVideoError
            ?.call();

        return;
      }

      // =====================================
      // HEARTBEAT
      // =====================================

      widget.onHeartbeat
          ?.call();

    } catch (e) {

      debugPrint(
        "VIDEO LISTENER ERROR: $e",
      );
    }
  }

  // =========================================================
  // HEARTBEAT
  // =========================================================

  void _startHeartbeat() {

    _heartbeatTimer?.cancel();

    _heartbeatTimer =
        Timer.periodic(

          const Duration(
            seconds: 5,
          ),

              (_) {

            if (_isDisposed) {
              return;
            }

            widget.onHeartbeat
                ?.call();
          },
        );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    // =====================================
    // ERROR
    // =====================================

    if (_hasError) {

      return Container(

        color: Colors.black,

        child: const Center(

          child: Icon(

            Icons.video_library,

            color: Colors.white,

            size: 60,
          ),
        ),
      );
    }

    // =====================================
    // LOADING
    // =====================================

    if (
    !_isReady ||

        _controller == null
    ) {

      return Container(

        color: Colors.black,

        child: const Center(

          child:
          CircularProgressIndicator(),
        ),
      );
    }

    // =====================================
    // VIDEO
    // =====================================

    return SizedBox.expand(

      child: FittedBox(

        fit: BoxFit.cover,

        child: SizedBox(

          width:
          _controller!
              .value
              .size
              .width,

          height:
          _controller!
              .value
              .size
              .height,

          child: VideoPlayer(
            _controller!,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {

    _isDisposed = true;

    WidgetsBinding.instance
        .removeObserver(this);

    _heartbeatTimer?.cancel();

    final controller =
        _controller;

    if (controller != null) {

      controller.removeListener(
        _videoListener,
      );

      controller.dispose();
    }

    super.dispose();
  }
}