import 'package:flutter/material.dart';

import '../../core/models/playlist_item_model.dart';

import 'widgets/windows_image_widget.dart';

import 'widgets/windows_video_widget.dart';

class WindowsSignagePlayer
    extends StatelessWidget {

  final PlaylistItemModel media;

  final VoidCallback
  onHeartbeat;

  final Future<void> Function()
  onVideoFinished;

  final Future<void> Function()
  onVideoError;

  const WindowsSignagePlayer({

    super.key,

    required this.media,

    required this.onHeartbeat,

    required this.onVideoFinished,

    required this.onVideoError,
  });

  @override
  Widget build(BuildContext context) {

    // =========================
    // IMAGE
    // =========================

    if (media.isImage) {

      return WindowsImageWidget(

        key: ValueKey(
          media.mediaUrl,
        ),

        imagePath:
        media.mediaUrl,
      );
    }

    // =========================
    // VIDEO
    // =========================

    return WindowsVideoWidget(

      key: ValueKey(
        media.mediaUrl,
      ),

      videoPath:
      media.mediaUrl,

      onHeartbeat:
      onHeartbeat,

      onVideoFinished:
          () async {

        await onVideoFinished();
      },

      onVideoError:
          () async {

        await onVideoError();
      },
    );
  }
}