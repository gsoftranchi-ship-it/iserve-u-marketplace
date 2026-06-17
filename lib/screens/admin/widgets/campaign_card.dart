import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
class CampaignCard extends StatelessWidget {

  final DocumentSnapshot campaignDoc;

  const CampaignCard({
    super.key,
    required this.campaignDoc,
  });

  @override
  Widget build(BuildContext context) {

    final campaign =
    campaignDoc.data()
    as Map<String, dynamic>;

    final title =
        campaign['title']
            ?? 'Untitled Campaign';

    final description =
        campaign['description']
            ?? '';

    final ownerId =
        campaign['ownerId']
            ?? '';

    final status =
        campaign['status']
            ?? 'pending_approval';

    final priority =
        campaign['priority']
            ?? 1;

    final durationLabel =
        campaign['durationLabel']
            ?? '1 Day';
    final totalViews =
        campaign['totalViews'] ?? 0;

    final phoneClicks =
        campaign['phoneClicks'] ?? 0;

    final whatsappClicks =
        campaign['whatsappClicks'] ?? 0;


        campaign['paymentStatus']
            ?? 'pending';


        campaign['transactionId']
            ?? 'Not Provided';

    final siteIds =
    List<String>.from(
      campaign['siteIds']
          ?? [],
    );

    return StreamBuilder<QuerySnapshot>(



      stream:
      FirebaseFirestore.instance

          .collection(
        'campaigns',
      )

          .doc(
        campaignDoc.id,
      )

          .collection(
        'media_assets',
      )

          .snapshots(),

      builder:
          (
          context,
          snapshot,
          ) {
            debugPrint(
              "DASHBOARD PROJECT => "
                  "${FirebaseFirestore.instance.app.options.projectId}",
            );
            if (snapshot.hasError) {

              return Container(

                padding:
                const EdgeInsets.all(20),

                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }

            if (!snapshot.hasData) {

              return const Padding(

                padding:
                EdgeInsets.all(20),

                child:
                CircularProgressIndicator(),
              );
            }

            final mediaDocs =
                snapshot.data?.docs
                    ?? [];

            return Container(

          margin:
          const EdgeInsets.only(
            bottom: 22,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(
              24,
            ),

            boxShadow: [

              BoxShadow(

                color: Colors.black
                    .withValues(alpha:
                  0.05,
                ),

                blurRadius: 18,

                offset:
                const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [

              // =========================================
              // TOP SECTION
              // =========================================

              Padding(

                padding:
                const EdgeInsets.all(
                  18,
                ),

                child: Row(

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Container(

                      width: 62,

                      height: 62,

                      decoration:
                      BoxDecoration(

                        color:
                        const Color(
                          0xFF0A2540,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          18,
                        ),
                      ),

                      child: const Icon(

                        Icons.campaign,

                        color:
                        Colors.white,

                        size: 30,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          Text(

                            title,

                            style:
                            const TextStyle(

                              fontSize:
                              20,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(

                            "Advertiser ID",

                            style:
                            TextStyle(

                              color:
                              Colors.grey
                                  .shade600,

                              fontSize:
                              11,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(

                            ownerId,

                            style:
                            const TextStyle(

                              fontSize:
                              12,

                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _statusChip(
                      status,
                    ),
                  ],
                ),
              ),

              // =========================================
              // DESCRIPTION
              // =========================================

              if (
              description
                  .isNotEmpty
              )

                Padding(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  child: Text(

                    description,

                    style: TextStyle(

                      color:
                      Colors.grey
                          .shade800,

                      height: 1.5,
                    ),
                  ),
                ),

              const SizedBox(
                height: 18,
              ),

              // =========================================
              // INFO BAR
              // =========================================

              Padding(

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: Wrap(

                  spacing: 10,

                  runSpacing: 10,

                  children: [

                    _infoChip(
                      Icons.image,
                      "${mediaDocs.length} Assets",
                    ),

                    _infoChip(
                      Icons.priority_high,
                      "P$priority",
                    ),

                    _infoChip(
                      Icons.location_on,
                      "${siteIds.length} Sites",
                    ),

                    _infoChip(
                      Icons.calendar_month,
                      durationLabel,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              // =========================================
              // MEDIA GALLERY
              // =========================================

              if (
              mediaDocs.isNotEmpty
              )

              // =========================================
// MEDIA GALLERY
// =========================================

                SizedBox(

                  height: 220,

                  child: mediaDocs.isEmpty

                      ? Container(

                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.grey.shade200,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: const Center(

                      child: Text(

                        "No Media Found",

                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )

                      : ListView.builder(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),

                    scrollDirection:
                    Axis.horizontal,

                    itemCount:
                    mediaDocs.length,

                    itemBuilder:
                        (
                        context,
                        index,
                        ) {

                      final media =
                      mediaDocs[index]
                          .data()
                      as Map<String, dynamic>;

                      final mediaType =
                          media['mediaType']
                              ?? '';

                      final previewUrl =

                      media['thumbnailUrl']
                          ?.toString()
                          .isNotEmpty == true

                          ? media['thumbnailUrl']

                          : media['mediaUrl'];

                      final fileName =
                          media['fileName']
                              ?? '';

                      return GestureDetector(

                        onTap: () async {

                          final url =
                              media['mediaUrl']
                                  ?? '';

                          if (url.isNotEmpty) {

                            await launchUrl(
                              Uri.parse(url),
                              mode:
                              LaunchMode
                                  .externalApplication,
                            );
                          }
                        },

                          child: Container(

                        width: 320,

                        margin:
                        const EdgeInsets.only(
                          right: 16,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.grey.shade300,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),

                        clipBehavior:
                        Clip.antiAlias,

                        child: Stack(

                          children: [

                            Positioned.fill(

                              child:
                              Image.network(

                                previewUrl,

                                fit:
                                BoxFit.cover,

                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {

                                  return Container(

                                    color:
                                    Colors.grey
                                        .shade300,

                                    child:
                                    const Center(

                                      child:
                                      Icon(

                                        Icons
                                            .broken_image,

                                        size:
                                        50,

                                        color:
                                        Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // =====================
                            // VIDEO PLAY BUTTON
                            // =====================

                            if (
                            mediaType ==
                                'video'
                            )

                              const Center(

                                child: Icon(

                                  Icons
                                      .play_circle_fill,

                                  color:
                                  Colors.white,

                                  size: 70,
                                ),
                              ),

                            // =====================
                            // BOTTOM OVERLAY
                            // =====================

                            Positioned(

                              left: 0,

                              right: 0,

                              bottom: 0,

                              child: Container(

                                padding:
                                const EdgeInsets.all(
                                  14,
                                ),

                                decoration:
                                const BoxDecoration(

                                  gradient:
                                  LinearGradient(

                                    begin:
                                    Alignment
                                        .bottomCenter,

                                    end:
                                    Alignment
                                        .topCenter,

                                    colors: [

                                      Colors.black87,

                                      Colors.transparent,
                                    ],
                                  ),
                                ),

                                child: Column(

                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [

                                    Container(

                                      padding:
                                      const EdgeInsets.symmetric(

                                        horizontal:
                                        10,

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

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    Text(

                                      fileName,

                                      maxLines: 1,

                                      overflow:
                                      TextOverflow
                                          .ellipsis,

                                      style:
                                      const TextStyle(

                                        color:
                                        Colors.white,

                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                       ),
                      );
                    },
                  ),
                ),

              const SizedBox(
                height: 22,
              ),
              // =========================================
// ANALYTICS
// =========================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "ADVERTISEMENT ANALYTICS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [

                          Expanded(
                            child: _infoChip(
                              Icons.visibility,
                              "$totalViews Views",
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _infoChip(
                              Icons.phone,
                              "$phoneClicks Calls",
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _infoChip(
                              Icons.message,
                              "$whatsappClicks WhatsApp",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =========================================
              // PAYMENT SECTION
              // =========================================

              Padding(

                padding:
                const EdgeInsets.all(
                  18,
                ),

                child: Container(

                  padding:
                  const EdgeInsets.all(18),

                  decoration:
                  BoxDecoration(

                    color:
                    const Color(
                      0xFFF5F0E6,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      const Text(

                        "PAYMENT VERIFICATION",

                        style: TextStyle(

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(
                        "Transaction ID: "
                            "${campaign['transactionId'] ?? 'Not Provided'}",
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "Payment Status: "
                            "${campaign['paymentStatus'] ?? 'pending'}",
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "Contact Info: "
                            "${campaign['contactInfo'] ?? 'Not Provided'}",
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "Price: ₹"
                            "${campaign['price'] ?? 0}",
                      ),
                    ],
                  ),
                ),
              ),

              // =========================================
              // ACTIONS
              // =========================================

              Padding(

                padding:
                const EdgeInsets.only(

                  left: 18,

                  right: 18,

                  bottom: 18,
                ),

                child:

                status == 'pending_approval'

                    ? Row(

                  children: [

                    Expanded(

                      child:
                      SizedBox(

                        height: 52,

                        child:
                        ElevatedButton.icon(

                          style:
                          ElevatedButton
                              .styleFrom(

                            backgroundColor:
                            Colors.green,

                            shape:
                            RoundedRectangleBorder(

                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),

                          onPressed: () async {

                            try {

                              await FirebaseFirestore.instance

                                  .collection(
                                'campaigns',
                              )

                                  .doc(
                                campaignDoc.id,
                              )

                                  .update({

                                'status': 'active',

                                'isActive': true,

                                'updatedAt':
                                FieldValue.serverTimestamp(),
                              });

                              debugPrint(
                                "CAMPAIGN APPROVED",
                              );

                              if (context.mounted) {

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(

                                  const SnackBar(

                                    content: Text(
                                      'Campaign Approved Successfully',
                                    ),
                                  ),
                                );
                              }

                            } catch (e) {

                              debugPrint(
                                "APPROVAL ERROR => $e",
                              );
                            }
                          },

                          icon:
                          const Icon(
                            Icons.check,
                            color:
                            Colors.white,
                          ),

                          label:
                          const Text(

                            "Approve",

                            style:
                            TextStyle(

                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(

                      child:
                      SizedBox(

                        height: 52,

                        child:
                        ElevatedButton.icon(

                          style:
                          ElevatedButton
                              .styleFrom(

                            backgroundColor:
                            Colors.red,

                            shape:
                            RoundedRectangleBorder(

                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),

                          onPressed:
                              () async {

                            await FirebaseFirestore
                                .instance

                                .collection(
                              'campaigns',
                            )

                                .doc(
                              campaignDoc.id,
                            )

                                .update({

                              'status':
                              'rejected',

                              'updatedAt':
                              FieldValue
                                  .serverTimestamp(),
                            });
                          },

                          icon:
                          const Icon(
                            Icons.close,
                            color:
                            Colors.white,
                          ),

                          label:
                          const Text(

                            "Reject",

                            style:
                            TextStyle(

                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                 )
                : const SizedBox(),
                ),
             ],
          ),
        );
      },

    );
  }

  Widget _statusChip(
      String status,
      ) {

    Color color =
        Colors.orange;

    if (status == 'active') {
      color = Colors.green;
    }

    if (status == 'rejected') {
      color = Colors.red;
    }

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration:
      BoxDecoration(

        color:
        color.withValues(alpha:
          0.12,
        ),

        borderRadius:
        BorderRadius.circular(
          30,
        ),
      ),

      child: Text(

        status
            .replaceAll(
          '_',
          ' ',
        )
            .toUpperCase(),

        style: TextStyle(

          color: color,

          fontWeight:
          FontWeight.bold,

          fontSize: 11,
        ),
      ),
    );
  }

  Widget _infoChip(
      IconData icon,
      String text,
      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration:
      BoxDecoration(

        color:
        Colors.grey.shade100,

        borderRadius:
        BorderRadius.circular(
          30,
        ),
      ),

      child: Row(

        mainAxisSize:
        MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 14,
            color:
            Colors.grey.shade700,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(

            text,

            style:
            const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}