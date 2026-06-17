import 'package:flutter/material.dart';

import '../../../core/utils/media_provider_helper.dart';

class WebImageWidget
    extends StatelessWidget {

  final String imageUrl;

  const WebImageWidget({

    super.key,

    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {

    return Image(

      image:
      MediaProviderHelper
          .getImageProvider(
        imageUrl,
      ),

      fit: BoxFit.contain,

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
          "WEB IMAGE ERROR: $error",
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