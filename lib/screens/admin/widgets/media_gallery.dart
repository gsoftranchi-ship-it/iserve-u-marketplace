import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaGallery extends StatelessWidget {

  final List<DocumentSnapshot> mediaDocs;

  const MediaGallery({

    super.key,

    required this.mediaDocs,
  });

  @override
  Widget build(BuildContext context) {

    if (mediaDocs.isEmpty) {

      return Container(

        height: 120,

        alignment: Alignment.center,

        decoration: BoxDecoration(

          color: Colors.grey.shade100,

          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),

        child: const Text(

          "No Media Uploaded",

          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(

      height: 150,

      child: ListView.builder(

        scrollDirection:
        Axis.horizontal,

        itemCount:
        mediaDocs.length,

        itemBuilder:
            (context, index) {

          final media =
          mediaDocs[index]
              .data()
          as Map<String, dynamic>;

          final mediaType =
              media['mediaType']
                  ?? '';

          final previewUrl =
              media['thumbnailUrl']
                  ??
                  media['mediaUrl']
                  ??
                  '';

          final fileName =
              media['fileName']
                  ?? '';

          return Container(

            width: 220,

            margin:
            const EdgeInsets.only(
              right: 14,
            ),

            decoration: BoxDecoration(

              borderRadius:
              BorderRadius.circular(
                18,
              ),

              color: Colors.grey.shade200,
            ),

            clipBehavior:
            Clip.antiAlias,

            child: Stack(

              children: [

                // =====================================
                // IMAGE / PREVIEW
                // =====================================

                Positioned.fill(

                  child: Image.network(

                    previewUrl,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {

                      return Container(

                        color:
                        Colors.grey.shade300,

                        child: const Icon(

                          Icons.broken_image,

                          size: 40,

                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // =====================================
                // VIDEO PLAY ICON
                // =====================================

                if (
                mediaType ==
                    'video'
                )

                  const Center(

                    child: Icon(

                      Icons
                          .play_circle_fill,

                      size: 56,

                      color:
                      Colors.white,
                    ),
                  ),

                // =====================================
                // TOP LABEL
                // =====================================

                Positioned(

                  top: 10,

                  right: 10,

                  child: Container(

                    padding:
                    const EdgeInsets.symmetric(

                      horizontal: 10,

                      vertical: 4,
                    ),

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.black54,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(

                      mediaType
                          .toUpperCase(),

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:
                        10,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // =====================================
                // FILE NAME
                // =====================================

                Positioned(

                  bottom: 0,

                  left: 0,

                  right: 0,

                  child: Container(

                    padding:
                    const EdgeInsets.all(
                      10,
                    ),

                    color:
                    Colors.black54,

                    child: Text(

                      fileName,

                      maxLines: 1,

                      overflow:
                      TextOverflow
                          .ellipsis,

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}