import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import '../../core/models/playlist_item_model.dart';
import '../android_player/android_signage_player.dart';
import '../windows_player/windows_runtime_player.dart';
import '../web_player/web_signage_player.dart';

class UniversalSignagePlayer
    extends StatelessWidget {

  final List<PlaylistItemModel>
  playlist;

  final String siteId;

  final String deviceId;

  const UniversalSignagePlayer({

    super.key,

    required this.playlist,

    required this.siteId,

    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {

    // =========================
    // WEB
    // =========================

    if (kIsWeb) {

      return WebSignagePlayer(

        playlist: playlist,

        siteId: siteId,

        deviceId: deviceId,
      );
    }

    // =========================
    // WINDOWS
    // =========================

    if (
    Theme.of(context).platform ==
        TargetPlatform.windows
    ) {

      return WindowsRuntimePlayer(
        playlist: playlist,
        siteId: siteId,
        deviceId: deviceId,
      );
    }

    // =========================
    // ANDROID
    // =========================

    return AndroidSignagePlayer(
      playlist: playlist,
      siteId: siteId,
      deviceId: deviceId,
    );
  }
}