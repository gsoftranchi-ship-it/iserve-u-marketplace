import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/playlist_item_model.dart';
import '../../core/runtime/runtime_coordinator.dart';
import '../../core/utils/media_provider_helper.dart';

import 'widgets/web_image_widget.dart';
import 'widgets/web_video_widget.dart';

class WebSignagePlayer
    extends StatefulWidget {

  final List<PlaylistItemModel>
  playlist;

  final String siteId;

  final String deviceId;

  const WebSignagePlayer({

    super.key,

    required this.playlist,

    required this.siteId,

    required this.deviceId,
  });

  @override
  State<WebSignagePlayer>
  createState() =>
      _WebSignagePlayerState();
}

class _WebSignagePlayerState
    extends State<WebSignagePlayer> {

  // =========================================================
  // RUNTIME
  // =========================================================

  RuntimeCoordinator?
  _runtimeCoordinator;

  StreamSubscription?
  _playbackSubscription;

  // =========================================================
  // MEDIA
  // =========================================================

  PlaylistItemModel?
  _currentMedia;

  // =========================================================
  // STATE
  // =========================================================

  bool _isLoading = true;

  bool _hasError = false;

  bool _isDisposed = false;

  String _errorMessage = "";

  // =========================================================
  // FIREBASE THROTTLE
  // =========================================================

  DateTime _lastFirebaseUpdate =
  DateTime.now();

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {

    super.initState();

    _initializePlayer();
  }

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void>
  _initializePlayer()
  async {

    try {

      if (_isDisposed) {
        return;
      }

      debugPrint(
        "WEB PLAYER INITIALIZING",
      );

      if (mounted) {

        setState(() {

          _isLoading = true;

          _hasError = false;

          _errorMessage = "";
        });
      }

      // =====================================
      // CLEANUP OLD
      // =====================================

      unawaited(
        _cleanupPlayer(),
      );

      // =====================================
      // EMPTY PLAYLIST
      // =====================================

      if (widget.playlist.isEmpty) {

        if (mounted) {

          setState(() {

            _hasError = true;

            _isLoading = false;

            _errorMessage =
            "No Media Available";
          });
        }

        return;
      }

      // =====================================
      // RUNTIME
      // =====================================

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

      // =====================================
      // MEDIA STREAM
      // =====================================

      _playbackSubscription =
          _runtimeCoordinator!
              .mediaStream
              .listen(
            _onMediaChanged,
          );

      debugPrint(
        "WEB PLAYER READY",
      );

    } catch (e, stack) {

      debugPrint(
        "WEB PLAYER INIT ERROR: $e",
      );

      debugPrint(
        stack.toString(),
      );

      if (mounted) {

        setState(() {

          _hasError = true;

          _isLoading = false;

          _errorMessage =
              e.toString();
        });
      }
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

      if (_isDisposed) {
        return;
      }

      debugPrint(
        "WEB MEDIA CHANGED",
      );

      // =====================================
      // FIREBASE THROTTLE
      // =====================================

      final now = DateTime.now();

      final difference =
      now.difference(
        _lastFirebaseUpdate,
      );

      if (
      difference >
          const Duration(
            seconds: 20,
          )
      ) {

        _lastFirebaseUpdate =
            now;

        unawaited(
          _updateFirebaseStatus(
            media,
          ),
        );
      }

      // =====================================
      // IMAGE PRELOAD
      // =====================================

      if (media.isImage) {

        try {

          final imageProvider =

          MediaProviderHelper
              .getImageProvider(

            media.mediaUrl,
          );

          WidgetsBinding.instance
              .addPostFrameCallback(
                  (_) {

                if (!mounted) {
                  return;
                }

                precacheImage(
                  imageProvider,
                  context,
                );
              });

        } catch (e) {

          debugPrint(
            "IMAGE PRECACHE ERROR: $e",
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {

        _currentMedia = media;

        _isLoading = false;

        _hasError = false;
      });

    } catch (e) {

      debugPrint(
        "MEDIA CHANGE ERROR: $e",
      );
    }
  }

  // =========================================================
  // FIREBASE STATUS
  // =========================================================

  Future<void>
  _updateFirebaseStatus(
      PlaylistItemModel media,
      ) async {

    try {

      await FirebaseFirestore
          .instance

          .collection(
        'campaigns',
      )

          .doc(
        media.campaignId,
      )

          .update({

        'liveStatus': true,

        'currentlyPlaying': true,

        'lastPlayedAt':
        FieldValue.serverTimestamp(),

        'lastSiteId':
        widget.siteId,

        'lastDeviceId':
        widget.deviceId,
      });

    } catch (e) {

      debugPrint(
        "FIREBASE STATUS ERROR: $e",
      );
    }
  }

  // =========================================================
  // CLEANUP
  // =========================================================

  Future<void>
  _cleanupPlayer()
  async {

    try {

      await _playbackSubscription
          ?.cancel();

      await _runtimeCoordinator
          ?.dispose();

    } catch (e) {

      debugPrint(
        "CLEANUP ERROR: $e",
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    // =====================================
    // LOADING
    // =====================================

    if (_isLoading) {

      return Container(

        color: Colors.black,

        child: const Center(

          child:
          CircularProgressIndicator(

            color: Colors.orange,
          ),
        ),
      );
    }

    // =====================================
    // ERROR
    // =====================================

    if (
    _hasError ||

        _currentMedia == null
    ) {

      return _buildErrorScreen();
    }

    final media =
    _currentMedia!;

    _runtimeCoordinator?.beat();

    // =====================================
    // IMAGE
    // =====================================

    if (media.isImage) {

      return AnimatedSwitcher(

        duration:
        const Duration(
          milliseconds: 250,
        ),

        switchInCurve:
        Curves.easeOut,

        switchOutCurve:
        Curves.easeOut,

        layoutBuilder:
            (
            currentChild,
            previousChildren,
            ) {

          return Stack(

            children: [

              ...previousChildren,

              currentChild ??
                  const SizedBox(),
            ],
          );
        },

        child: SizedBox.expand(

          key: ValueKey(
            media.mediaUrl,
          ),

          child: WebImageWidget(

            imageUrl:
            media.mediaUrl,
          ),
        ),
      );
    }

    // =====================================
    // VIDEO
    // =====================================

    return AnimatedSwitcher(

      duration:
      const Duration(
        milliseconds: 250,
      ),

      switchInCurve:
      Curves.easeOut,

      switchOutCurve:
      Curves.easeOut,

      child: SizedBox.expand(

        key: ValueKey(
          media.mediaUrl,
        ),

        child: VideoPlayerWidget(

          url:
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
        ),
      ),
    );
  }

  // =========================================================
  // ERROR SCREEN
  // =========================================================

  Widget _buildErrorScreen() {

    return Container(

      color: Colors.black,

      child: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.tv_off,

              color: Colors.white,

              size: 90,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(

              "Playback Error",

              style: TextStyle(

                color: Colors.white,

                fontSize: 22,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 30,
              ),

              child: Text(

                _errorMessage,

                textAlign:
                TextAlign.center,

                style: const TextStyle(

                  color:
                  Colors.white70,
                ),
              ),
            ),
          ],
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

    unawaited(
      _cleanupPlayer(),
    );

    super.dispose();
  }
}