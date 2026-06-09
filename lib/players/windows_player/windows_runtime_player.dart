import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/playlist_item_model.dart';
import '../../core/runtime/runtime_coordinator.dart';
import 'widgets/windows_image_widget.dart';
import 'widgets/windows_video_widget.dart';

class WindowsRuntimePlayer
    extends StatefulWidget {

  final List<PlaylistItemModel>
  playlist;

  final String siteId;

  final String deviceId;

  const WindowsRuntimePlayer({

    super.key,

    required this.playlist,

    required this.siteId,

    required this.deviceId,
  });

  @override
  State<WindowsRuntimePlayer>
  createState() =>
      _WindowsRuntimePlayerState();
}

class _WindowsRuntimePlayerState
    extends State<WindowsRuntimePlayer> {

  RuntimeCoordinator?
  _runtimeCoordinator;

  StreamSubscription?
  _subscription;

  PlaylistItemModel?
  _currentMedia;

  bool _loading = true;

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
      });

    } catch (e) {

      debugPrint(
        "WINDOWS RUNTIME ERROR: $e",
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
        "WINDOWS MEDIA ERROR: $e",
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

      return WindowsImageWidget(

        key: ValueKey(
          media.mediaUrl,
        ),

        imagePath:
        media.mediaUrl,
      );
    }

    // =====================================
    // VIDEO
    // =====================================

    return WindowsVideoWidget(

      key: ValueKey(
        media.mediaUrl,
      ),

      videoPath:
      media.mediaUrl,

      onHeartbeat: () {

        _runtimeCoordinator
            ?.beat();
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