import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AndroidVideoWidget
    extends StatefulWidget {

  final String url;

  final VoidCallback?
  onVideoFinished;

  final VoidCallback?
  onHeartbeat;

  const AndroidVideoWidget({

    super.key,

    required this.url,

    this.onVideoFinished,

    this.onHeartbeat,
  });

  @override
  State<AndroidVideoWidget>
  createState() =>
      _AndroidVideoWidgetState();
}

class _AndroidVideoWidgetState
    extends State<AndroidVideoWidget> {

  VideoPlayerController?
  _controller;

  bool _isReady = false;

  bool _hasError = false;

  bool _completed = false;

  Timer? _heartbeatTimer;

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

      late VideoPlayerController
      controller;

      final file =
      File(widget.url);

      final exists =
      await file.exists();

      // ===================================
      // LOCAL FILE
      // ===================================

      if (exists) {

        controller =
            VideoPlayerController.file(
              file,
            );

      } else {

        // =================================
        // NETWORK FALLBACK
        // =================================

        controller =
            VideoPlayerController
                .networkUrl(
              Uri.parse(widget.url),
            );
      }

      _controller = controller;

      await controller.initialize();

      await controller.play();

      controller.addListener(
        _videoListener,
      );

      _heartbeatTimer =
          Timer.periodic(

            const Duration(
              seconds: 5,
            ),

                (_) {

              widget.onHeartbeat
                  ?.call();
            },
          );

      if (!mounted) {
        return;
      }

      setState(() {

        _isReady = true;
      });

    } catch (e) {

      debugPrint(
        "ANDROID VIDEO ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {

        _hasError = true;
      });
    }
  }

  // =========================================================
  // VIDEO LISTENER
  // =========================================================

  void _videoListener() {

    final controller =
        _controller;

    if (controller == null) {
      return;
    }

    final value =
        controller.value;

    if (
    !_completed &&

        value.position >=
            value.duration &&

        !value.isPlaying
    ) {

      _completed = true;

      widget.onVideoFinished
          ?.call();
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    if (_hasError) {

      return Container(

        color: Colors.black,

        child: const Center(

          child: Icon(

            Icons.error,

            color: Colors.white,
          ),
        ),
      );
    }

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

    _heartbeatTimer?.cancel();

    _controller?.dispose();

    super.dispose();
  }
}