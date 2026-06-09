import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/playlist_item_model.dart';
import '../windows_player/widgets/windows_video_widget.dart';
import 'widgets/android_image_widget.dart';
import 'widgets/android_video_widget.dart';
import '../../core/runtime/runtime_coordinator.dart';

class AndroidSignagePlayer
    extends StatefulWidget {

  final List<PlaylistItemModel>
  playlist;

  final String siteId;

  final String deviceId;

  const AndroidSignagePlayer({

    super.key,

    required this.playlist,

    required this.siteId,

    required this.deviceId,
  });

  @override
  State<AndroidSignagePlayer>
  createState() =>
      _AndroidSignagePlayerState();
}

class _AndroidSignagePlayerState
    extends State<AndroidSignagePlayer> {


  RuntimeCoordinator?
  _runtimeCoordinator;

  StreamSubscription?
  _subscription;

  PlaylistItemModel?
  _currentMedia;

  bool _loading = true;
  bool _runtimeReady = false;

  bool _disposed = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {

    super.initState();

    _initialize();
  }

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void> _initialize()
  async {

    try {
      _runtimeCoordinator =
          RuntimeCoordinator(

            playlist:
            widget.playlist,

            siteId:
            widget.siteId,

            deviceId:
            widget.deviceId,
          );

      await _runtimeCoordinator!
          .initialize();

      _subscription =
          _runtimeCoordinator!
              .mediaStream
              .listen(
            _onMediaChanged,
          );

      if (!mounted) {
        return;
      }

      setState(() {

        _loading = false;

        _runtimeReady = true;
      });

    } catch (e) {

      debugPrint(
        "ANDROID MEDIA UPDATE ERROR: $e",
      );
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

      if (!mounted) {
        return;
      }

      setState(() {

        _currentMedia = media;
      });

    } catch (e) {

      debugPrint(
        "ANDROID MEDIA ERROR: $e",
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    if (_loading) {

      return Container(

        color: Colors.black,

        child: const Center(

          child:
          CircularProgressIndicator(),
        ),
      );
    }

    // =========================
    // RUNTIME NOT READY
    // =========================

    if (!_runtimeReady) {

      return Container(
        color: Colors.black,
      );
    }

    final media =
        _currentMedia;

    _runtimeCoordinator?.beat();

    if (media == null) {

      return Container(
        color: Colors.black,
      );
    }

    // =====================================
    // IMAGE
    // =====================================

    if (media.isImage) {

      return AndroidImageWidget(

        key: ValueKey(
          media.mediaUrl,
        ),

        imagePath:
        media.mediaUrl,
      );
    }

    // =====================================
    // WINDOWS VIDEO
    // =====================================

    if (
    Theme.of(context)
        .platform ==
        TargetPlatform.windows
    ) {

      return WindowsVideoWidget(

        key: ValueKey(
          media.mediaUrl,
        ),

        videoPath:
        media.mediaUrl,

        onHeartbeat: () {

          _runtimeCoordinator?.beat();
        },

        onVideoFinished:
            () async {

              await _runtimeCoordinator
                  ?.onVideoCompleted();
        },

        onVideoError:
            () async {

              await _runtimeCoordinator
                  ?.onVideoError();
        },
      );
    }

    // =====================================
    // ANDROID VIDEO
    // =====================================

    return AndroidVideoWidget(

      key: ValueKey(
        media.mediaUrl,
      ),

      url:
      media.mediaUrl,

      onHeartbeat: () {

        _runtimeCoordinator?.beat();
      },

      onVideoFinished:
          () async {

            await _runtimeCoordinator
                ?.onVideoCompleted();
      },
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {

    _disposed = true;

    _subscription?.cancel();

    unawaited(
      _runtimeCoordinator
          ?.dispose(),
    );

    super.dispose();
  }
}