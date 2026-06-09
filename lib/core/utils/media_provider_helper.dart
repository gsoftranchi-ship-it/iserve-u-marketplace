import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MediaProviderHelper {

  static ImageProvider
  getImageProvider(
      String path,
      ) {

    debugPrint(
      "MEDIA PATH => $path",
    );

    // WEB
    if (kIsWeb) {

      debugPrint(
        "USING NETWORK IMAGE WEB",
      );

      return NetworkImage(path);
    }

    // NETWORK URL
    if (
    path.startsWith('http')
    ) {

      debugPrint(
        "USING NETWORK IMAGE",
      );

      return NetworkImage(path);
    }

    // LOCAL FILE
    final normalizedPath =

        File(path)
            .absolute
            .path;

    debugPrint(
      "USING FILE IMAGE",
    );

    debugPrint(
      "NORMALIZED => $normalizedPath",
    );

    return FileImage(
      File(normalizedPath),
    );
  }
}