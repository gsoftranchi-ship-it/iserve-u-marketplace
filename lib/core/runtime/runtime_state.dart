import '../models/playlist_item_model.dart';

enum RuntimeStatus {

  idle,

  initializing,

  running,

  buffering,

  recovering,

  error,

  disposed,
}

class RuntimeState {

  final RuntimeStatus
  status;

  final PlaylistItemModel?
  currentMedia;

  final int playlistSize;

  final int currentIndex;

  final bool isOnline;

  final bool isRecovering;

  final DateTime updatedAt;

  final String?
  errorMessage;

  const RuntimeState({

    required this.status,

    required this.currentMedia,

    required this.playlistSize,

    required this.currentIndex,

    required this.isOnline,

    required this.isRecovering,

    required this.updatedAt,

    this.errorMessage,
  });

  // =========================================================
  // INITIAL
  // =========================================================

  factory RuntimeState.initial() {

    return RuntimeState(

      status:
      RuntimeStatus.idle,

      currentMedia: null,

      playlistSize: 0,

      currentIndex: 0,

      isOnline: true,

      isRecovering: false,

      updatedAt:
      DateTime.now(),
    );
  }

  // =========================================================
  // COPY WITH
  // =========================================================

  RuntimeState copyWith({

    RuntimeStatus? status,

    PlaylistItemModel?
    currentMedia,

    int? playlistSize,

    int? currentIndex,

    bool? isOnline,

    bool? isRecovering,

    DateTime? updatedAt,

    String? errorMessage,
  }) {

    return RuntimeState(

      status:
      status ?? this.status,

      currentMedia:
      currentMedia ??
          this.currentMedia,

      playlistSize:
      playlistSize ??
          this.playlistSize,

      currentIndex:
      currentIndex ??
          this.currentIndex,

      isOnline:
      isOnline ??
          this.isOnline,

      isRecovering:
      isRecovering ??
          this.isRecovering,

      updatedAt:
      updatedAt ??
          this.updatedAt,

      errorMessage:
      errorMessage ??
          this.errorMessage,
    );
  }
}