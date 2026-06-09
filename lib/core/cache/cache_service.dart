import '../../players/android_player/managers/cache_manager.dart';

class CacheService {

  // =========================================================
  // GET LOCAL PATH
  // =========================================================

  static Future<String?>
  getCachedMediaPath({

    required String url,

    required String mediaType,
  }) async {

    return CacheManager
        .getCachedMediaPath(

      url: url,

      mediaType: mediaType,
    );
  }

  // =========================================================
  // CHECK CACHE
  // =========================================================

  static Future<bool>
  isFileCached({

    required String url,

    required String mediaType,
  }) async {

    return CacheManager
        .isFileCached(

      url: url,

      mediaType: mediaType,
    );
  }

  // =========================================================
  // PRELOAD
  // =========================================================

  static Future<void>
  preloadMedia({

    required String url,

    required String mediaType,
  }) async {

    await CacheManager
        .preloadMedia(

      url: url,

      mediaType: mediaType,
    );
  }
}