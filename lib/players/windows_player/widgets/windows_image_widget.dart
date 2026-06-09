import 'dart:io';

import 'package:flutter/material.dart';

class WindowsImageWidget
    extends StatelessWidget {

  final String imagePath;

  const WindowsImageWidget({

    super.key,

    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {

    return Image.file(

      File(imagePath),

      fit: BoxFit.cover,

      gaplessPlayback: true,

      filterQuality:
      FilterQuality.none,

      errorBuilder:
          (
          context,
          error,
          stackTrace,
          ) {

        debugPrint(
          "WINDOWS IMAGE ERROR: $error",
        );

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
      },
    );
  }
}