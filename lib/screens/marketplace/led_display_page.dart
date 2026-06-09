import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/playlist_item_model.dart';

import '../../players/shared/universal_signage_player.dart';

class LEDDisplayPage
    extends StatefulWidget {

  final String siteName;

  const LEDDisplayPage({

    super.key,

    required this.siteName,
  });

  @override
  State<LEDDisplayPage>
  createState() =>
      _LEDDisplayPageState();
}

class _LEDDisplayPageState
    extends State<LEDDisplayPage> {

  // =========================================================
  // PLAYLIST
  // =========================================================

  late final List<PlaylistItemModel>
  _playlist;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {

    super.initState();

    // =========================================
    // EMPTY INITIAL PLAYLIST
    // =========================================

    _playlist = [];

    // =========================================
    // FULLSCREEN MODE
    // =========================================

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    // =========================================
    // LANDSCAPE LOCK
    // =========================================

    SystemChrome.setPreferredOrientations([

      DeviceOrientation.landscapeLeft,

      DeviceOrientation.landscapeRight,
    ]);
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([

      DeviceOrientation.portraitUp,

      DeviceOrientation.portraitDown,

      DeviceOrientation.landscapeLeft,

      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      body:
      UniversalSignagePlayer(

        playlist:
        _playlist,

        siteId:
        widget.siteName,

        deviceId:
        "WEB_DEVICE",
      ),
    );
  }
}