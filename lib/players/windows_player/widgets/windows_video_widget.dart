import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class WindowsVideoWidget
    extends StatefulWidget {

  final String videoPath;

  final VoidCallback?
  onVideoFinished;

  final VoidCallback?
  onHeartbeat;

  final VoidCallback?
  onVideoError;

  const WindowsVideoWidget({

    super.key,

    required this.videoPath,

    this.onVideoFinished,

    this.onHeartbeat,

    this.onVideoError,
  });

  @override
  State<WindowsVideoWidget>
  createState() =>
      _WindowsVideoWidgetState();
}

class _WindowsVideoWidgetState
    extends State<WindowsVideoWidget> {

  late final Player _player;

  late final VideoController
  _controller;

  Timer? _heartbeatTimer;

  bool _hasError = false;

  bool _completed = false;
  StreamSubscription? _completedSubscription;

  StreamSubscription? _errorSubscription;

  bool _disposed = false;

  @override
  void initState() {

    super.initState();

    _initialize();
  }

  Future<void>
  _initialize()
  async {

    try {

      debugPrint(
        "MEDIAKIT WINDOWS VIDEO",
      );

      _player = Player();

      _controller =
          VideoController(
            _player,
          );

      await _player.open(

        Media(
          widget.videoPath,
        ),

        play: true,
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

      _completedSubscription =
          _player.stream.completed
              .listen((completed) {

            if (_disposed) {
              return;
            }

            if (
            completed &&
                !_completed
            ) {

              _completed = true;

              debugPrint(
                "WINDOWS VIDEO COMPLETE",
              );

              widget.onVideoFinished
                  ?.call();
            }
          });

      _errorSubscription =
          _player.stream.error.listen(

                (error) {

              if (_disposed) {
                return;
              }

              debugPrint(
                "MEDIAKIT VIDEO ERROR: $error",
              );

              if (!mounted) {
                return;
              }

              setState(() {

                _hasError = true;
              });

              widget.onVideoError
                  ?.call();
            },
          );

    } catch (e) {

      debugPrint(
        "MEDIAKIT INIT ERROR: $e",
      );

      if (_disposed) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {

        _hasError = true;
      });

      widget.onVideoError
          ?.call();
    }
  }

  @override
  void dispose() {

    _disposed = true;

    _heartbeatTimer?.cancel();

    _completedSubscription
        ?.cancel();

    _errorSubscription
        ?.cancel();

    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_hasError) {

      return Container(

        color: Colors.black,

        child: const Center(

          child: Icon(

            Icons.broken_image,

            color: Colors.white,

            size: 60,
          ),
        ),
      );
    }

    return SizedBox.expand(

      child: Video(
        controller:
        _controller,
      ),
    );
  }
}