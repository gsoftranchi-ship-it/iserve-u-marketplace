import 'dart:io';

import 'package:flutter/material.dart';

class AndroidImageWidget
    extends StatefulWidget {

  final String imagePath;

  const AndroidImageWidget({

    super.key,

    required this.imagePath,
  });

  @override
  State<AndroidImageWidget>
  createState() =>
      _AndroidImageWidgetState();
}

class _AndroidImageWidgetState
    extends State<AndroidImageWidget> {

  final bool _hasError = false;

  @override
  Widget build(BuildContext context) {

    if (_hasError) {

      return _buildBrokenImage();
    }

    final file =
    File(widget.imagePath);

    return FutureBuilder<bool>(

      future: file.exists(),

      builder:
          (context, snapshot) {

        final exists =
            snapshot.data ?? false;

        // ===================================
        // LOCAL FILE
        // ===================================

        if (exists) {

          return Image.file(

            file,

            fit: BoxFit.cover,

            gaplessPlayback: true,

            filterQuality:
            FilterQuality.high,

            errorBuilder:
                (
                context,
                error,
                stackTrace,
                ) {

              return _buildBrokenImage();
            },
          );
        }

        // ===================================
        // NETWORK FALLBACK
        // ===================================

        return Image.network(

          widget.imagePath,

          fit: BoxFit.cover,

          gaplessPlayback: true,

          filterQuality:
          FilterQuality.high,

          errorBuilder:
              (
              context,
              error,
              stackTrace,
              ) {

            return _buildBrokenImage();
          },
        );
      },
    );
  }

  // =========================================================
  // BROKEN IMAGE
  // =========================================================

  Widget _buildBrokenImage() {

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
}