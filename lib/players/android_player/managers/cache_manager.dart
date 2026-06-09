import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CacheManager {

  // =========================================================
  // CONFIG
  // =========================================================

  static const String rootFolder = "iserveu_cache";

  static const Duration downloadTimeout =
  Duration(minutes: 5);

  static final Map<String, Future<String?>>
  _activeDownloads = {};

  // =========================================================
  // ROOT DIRECTORY
  // =========================================================

  static Future<Directory?> getRootDirectory() async {

    try {

      if (kIsWeb) {
        return null;
      }

      final base =
      await getApplicationDocumentsDirectory();

      final root = Directory(
        "${base.path}/$rootFolder",
      );

      if (!await root.exists()) {

        await root.create(
          recursive: true,
        );
      }

      return root;

    } catch (e) {

      debugPrint(
        "ROOT DIRECTORY ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // MEDIA DIRECTORY
  // =========================================================

  static Future<Directory?> _getMediaDirectory(
      String mediaType,
      ) async {

    try {

      final root =
      await getRootDirectory();

      if (root == null) {
        return null;
      }

      final folder =
      mediaType == "video"
          ? "videos"
          : "images";

      final dir = Directory(
        "${root.path}/$folder",
      );

      if (!await dir.exists()) {

        await dir.create(
          recursive: true,
        );
      }

      return dir;

    } catch (e) {

      debugPrint(
        "MEDIA DIRECTORY ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // FILE NAME
  // =========================================================

  static String generateFileName(
      String url,
      ) {

    try {

      final encoded =
      base64Url.encode(
        utf8.encode(url),
      );

      return encoded
          .replaceAll("=", "");

    } catch (_) {

      return DateTime.now()
          .millisecondsSinceEpoch
          .toString();
    }
  }

  // =========================================================
  // LOCAL FILE PATH
  // =========================================================

  static Future<String?> getLocalFilePath({

    required String url,

    required String mediaType,
  }) async {

    try {

      if (kIsWeb) {
        return url;
      }

      final dir =
      await _getMediaDirectory(
        mediaType,
      );

      if (dir == null) {
        return null;
      }

      final fileName =
      generateFileName(url);

      return
        "${dir.path}/$fileName";

    } catch (e) {

      debugPrint(
        "LOCAL PATH ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // CACHE CHECK
  // =========================================================

  static Future<bool> isFileCached({

    required String url,

    required String mediaType,
  }) async {

    try {

      if (kIsWeb) {
        return true;
      }

      final path =
      await getLocalFilePath(

        url: url,

        mediaType: mediaType,
      );

      if (path == null) {
        return false;
      }

      final file = File(path);

      if (!await file.exists()) {
        return false;
      }

      final size =
      await file.length();

      return size > 1024;

    } catch (_) {

      return false;
    }
  }

  // =========================================================
  // GET CACHED PATH
  // =========================================================

  static Future<String?> getCachedMediaPath({

    required String url,

    required String mediaType,
  }) async {

    try {

      if (kIsWeb) {
        return url;
      }

      final exists =
      await isFileCached(

        url: url,

        mediaType: mediaType,
      );

      if (!exists) {
        return null;
      }

      return await getLocalFilePath(

        url: url,

        mediaType: mediaType,
      );

    } catch (e) {

      debugPrint(
        "CACHE PATH ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // DOWNLOAD MEDIA
  // =========================================================

  static Future<String?> downloadMedia({

    required String url,

    required String mediaType,
  }) async {

    try {

      if (kIsWeb) {
        return url;
      }

      // =====================================
      // ALREADY DOWNLOADING
      // =====================================

      if (_activeDownloads.containsKey(url)) {

        return await _activeDownloads[url];
      }

      final completer =
      _downloadInternal(

        url: url,

        mediaType: mediaType,
      );

      _activeDownloads[url] =
          completer;

      final result =
      await completer;

      _activeDownloads.remove(url);

      return result;

    } catch (e) {

      debugPrint(
        "DOWNLOAD MEDIA ERROR: $e",
      );

      _activeDownloads.remove(url);

      return null;
    }
  }

  // =========================================================
  // INTERNAL DOWNLOAD
  // =========================================================

  static Future<String?> _downloadInternal({

    required String url,

    required String mediaType,
  }) async {

    File? tempFile;

    IOSink? sink;

    http.Client? client;

    StreamSubscription? subscription;

    try {

      final cached =
      await getCachedMediaPath(

        url: url,

        mediaType: mediaType,
      );

      if (cached != null) {

        debugPrint(
          "CACHE EXISTS",
        );

        return cached;
      }

      final localPath =
      await getLocalFilePath(

        url: url,

        mediaType: mediaType,
      );

      if (localPath == null) {
        return null;
      }

      final tempPath =
          "$localPath.download";

      tempFile = File(tempPath);

      if (await tempFile.exists()) {

        await tempFile.delete();
      }

      client = http.Client();

      final request =
      http.Request(
        'GET',
        Uri.parse(url),
      );

      final response =
      await client
          .send(request)
          .timeout(
        downloadTimeout,
      );

      if (
      response.statusCode != 200
      ) {

        debugPrint(
          "DOWNLOAD FAILED",
        );

        return null;
      }

      sink =
          tempFile.openWrite();

      final completer =
      Completer<void>();

      subscription =
          response.stream.listen(

                (chunk) {

              sink?.add(chunk);
            },

            onDone: () async {

              await sink?.flush();

              await sink?.close();

              completer.complete();
            },

            onError: (e) async {

              await sink?.close();

              completer.completeError(e);
            },

            cancelOnError: true,
          );

      await completer.future;

      final finalFile =
      File(localPath);

      if (await finalFile.exists()) {

        await finalFile.delete();
      }

      await tempFile.rename(
        localPath,
      );

      final exists =
      await finalFile.exists();

      if (!exists) {

        debugPrint(
          "FINAL FILE MISSING",
        );

        return null;
      }

      final size =
      await finalFile.length();

      if (size <= 1024) {

        debugPrint(
          "CORRUPTED CACHE FILE",
        );

        await finalFile.delete();

        return null;
      }

      debugPrint(
        "DOWNLOAD COMPLETE",
      );

      return localPath;

    } catch (e) {

      debugPrint(
        "DOWNLOAD INTERNAL ERROR: $e",
      );

      return null;

    } finally {

      try {

        await subscription?.cancel();

      } catch (_) {}

      try {

        await sink?.close();

      } catch (_) {}

      try {

        client?.close();

      } catch (_) {}

      try {

        if (
        tempFile != null &&
            await tempFile.exists()
        ) {

          final size =
          await tempFile.length();

          if (size <= 1024) {

            await tempFile.delete();
          }
        }

      } catch (_) {}
    }
  }

  // =========================================================
  // PRELOAD
  // =========================================================

  static Future<void> preloadMedia({

    required String url,

    required String mediaType,
  }) async {

    try {

      final exists =
      await isFileCached(

        url: url,

        mediaType: mediaType,
      );

      if (exists) {
        return;
      }

      unawaited(
        downloadMedia(

          url: url,

          mediaType: mediaType,
        ),
      );

    } catch (e) {

      debugPrint(
        "PRELOAD ERROR: $e",
      );
    }
  }

  // =========================================================
  // CLEAR CACHE
  // =========================================================

  static Future<void> clearAllCache()
  async {

    try {

      if (kIsWeb) {
        return;
      }

      final root =
      await getRootDirectory();

      if (root == null) {
        return;
      }

      if (await root.exists()) {

        await root.delete(
          recursive: true,
        );
      }

      await getRootDirectory();

    } catch (e) {

      debugPrint(
        "CLEAR CACHE ERROR: $e",
      );
    }
  }
}