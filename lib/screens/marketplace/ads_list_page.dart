import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/models/campaign_model.dart';

import 'ad_details_page.dart';
import 'ad_upload_page.dart';
import 'site_manager_page.dart';

class AdsListPage extends StatelessWidget {

  final String userRole;

  const AdsListPage({
    super.key,
    required this.userRole,
  });

  // =========================================================
  // ROLE HELPERS
  // =========================================================

  bool get isAdmin =>

      userRole == 'admin' ||

          userRole == 'super_admin';

  bool get canSubmit =>

      userRole == 'client' ||

          userRole == 'vendor';

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    final isWide =
        MediaQuery.of(context)
            .size
            .width > 900;

    return Scaffold(

      backgroundColor:
      const Color(0xFFF1F3F6),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
        Colors.white,

        foregroundColor:
        Colors.black,

        title: const Text(

          "Campaign Marketplace",

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [

          // =====================================
          // ADMIN PANEL
          // =====================================

          if (isAdmin)

            TextButton.icon(

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => const SiteManagerPage(),
                  ),
                );
              },

              icon: const Icon(
                Icons.settings,
                size: 18,
              ),

              label: const Text(
                "Manage",
              ),
            ),

          const SizedBox(width: 10),

          // =====================================
          // CREATE CAMPAIGN
          // =====================================

          if (canSubmit)

            ElevatedButton.icon(

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.orange,
              ),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                    const AdvertisementPage(),
                  ),
                );
              },

              icon: const Icon(

                Icons.add,

                color: Colors.white,
              ),

              label: const Text(

                "New Campaign",

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

          const SizedBox(width: 12),
        ],
      ),

      // =====================================================
      // CAMPAIGNS STREAM
      // =====================================================

      body: StreamBuilder<QuerySnapshot>(

        stream:
        FirebaseFirestore
            .instance
            .collection('campaigns')

            .orderBy(
          'createdAt',
          descending: true,
        )

            .snapshots(),

        builder: (context, snapshot) {

          // ===================================
          // LOADING
          // ===================================

          if (
          snapshot.connectionState ==
              ConnectionState.waiting
          ) {

            return const Center(

              child:
              CircularProgressIndicator(),
            );
          }

          // ===================================
          // ERROR
          // ===================================

          if (snapshot.hasError) {

            return Center(

              child: Padding(

                padding:
                const EdgeInsets.all(20),

                child: Text(

                  "Unable to load campaigns\n"
                      "${snapshot.error}",

                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          // ===================================
          // EMPTY
          // ===================================

          if (
          !snapshot.hasData ||

              snapshot.data!.docs.isEmpty
          ) {

            return _buildEmptyState();
          }

          // ===================================
          // MAP CAMPAIGNS
          // ===================================

          final campaigns =
          snapshot.data!.docs.map((doc) {

            return CampaignModel.fromMap(

              doc.id,

              doc.data()
              as Map<String, dynamic>,
            );

          }).toList();

          // ===================================
          // FILTER USER CAMPAIGNS
          // ===================================

          final currentUser =
              FirebaseAuth
                  .instance
                  .currentUser;

          final visibleCampaigns =

          isAdmin

              ? campaigns

              : campaigns.where((c) {

            return c.ownerId ==
                currentUser?.uid;

          }).toList();

          // ===================================
          // EMPTY FILTERED
          // ===================================

          if (
          visibleCampaigns.isEmpty
          ) {

            return _buildEmptyState();
          }

          // ===================================
          // GRID
          // ===================================

          return GridView.builder(

            padding:
            const EdgeInsets.all(16),

            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount:

              isWide

                  ? 3

                  : MediaQuery.of(context)
                  .size
                  .width > 700

                  ? 2

                  : 1,

              mainAxisSpacing: 16,

              crossAxisSpacing: 16,

              childAspectRatio:
              isWide
                  ? 16 / 9
                  : 1.08,
            ),

            itemCount:
            visibleCampaigns.length,

            itemBuilder:
                (context, index) {

              final campaign =
              visibleCampaigns[index];

              return FutureBuilder<int>(

                future:
                _getAssetCount(
                  campaign.id,
                ),

                builder:
                    (context, assetSnapshot) {

                  final assetCount =
                      assetSnapshot.data ?? 0;

                  return GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) => AdDetailsPage(

                            ad: {

                              'id': campaign.id,

                              'title': campaign.title,

                              'description': campaign.description,

                              'status': campaign.status,

                              'priority': campaign.priority,

                              'siteIds': campaign.siteIds,

                              'durationSeconds':
                              campaign.durationSeconds,

                              'totalPlays':
                              campaign.totalPlays,

                              'totalImpressions':
                              campaign.totalImpressions,

                              'contactInfo':
                              campaign.contactInfo,

                              'mediaUrl':
                              campaign.mediaUrl,

                              'mediaType':
                              campaign.mediaType,
                            },
                          ),
                        ),
                      );
                    },

                    child: _buildCampaignCard(

                      context,

                      campaign,

                      assetCount,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // =========================================================
  // ASSET COUNT
  // =========================================================

  Future<int> _getAssetCount(
      String campaignId,
      ) async {

    try {

      final snapshot =
      await FirebaseFirestore
          .instance
          .collection('media_assets')

          .where(
        'campaignId',
        isEqualTo: campaignId,
      )

          .get();

      return snapshot.docs.length;

    } catch (_) {

      return 0;
    }
  }

  // =========================================================
  // CARD
  // =========================================================

  Widget _buildCampaignCard(

      BuildContext context,

      CampaignModel campaign,

      int assetCount,
      ) {

    final imageUrl =
        campaign.mediaUrl;

    final status =
        campaign.status;

    final bool isLive =
        status == "active";

    return Container(

      decoration: BoxDecoration(

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withValues(
              alpha: 0.08,
            ),

            blurRadius: 12,

            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: ClipRRect(

        borderRadius:
        BorderRadius.circular(20),

        child: Stack(

          fit: StackFit.expand,

          children: [

            // =================================
            // IMAGE
            // =================================

            imageUrl.isNotEmpty

                ? Image.network(

              imageUrl,

              fit: BoxFit.cover,

              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {

                return _fallbackImage();
              },
            )

                : _fallbackImage(),

            // =================================
            // OVERLAY
            // =================================

            Container(

              decoration:
              BoxDecoration(

                gradient:
                LinearGradient(

                  begin:
                  Alignment.topCenter,

                  end:
                  Alignment.bottomCenter,

                  colors: [

                    Colors.transparent,

                    Colors.black.withValues(
                      alpha: 0.8,
                    ),
                  ],
                ),
              ),
            ),

            // =================================
            // STATUS
            // =================================

            Positioned(

              top: 15,
              left: 15,

              child: _badge(

                isLive

                    ? "LIVE"

                    : campaign.readableStatus,

                isLive

                    ? Colors.green

                    : Colors.orange,
              ),
            ),

            // =================================
            // DELETE
            // =================================

            Positioned(

              top: 12,
              right: 12,

              child:
              PopupMenuButton<String>(

                color: Colors.white,

                onSelected:
                    (value) async {

                  if (
                  value != "delete"
                  ) {
                    return;
                  }

                  final confirm =
                  await showDialog<bool>(

                    context: context,

                    builder: (_) {

                      return AlertDialog(

                        title:
                        const Text(
                          "Delete Campaign?",
                        ),

                        content:
                        const Text(
                          "This action cannot be undone.",
                        ),

                        actions: [

                          TextButton(

                            onPressed: () {

                              Navigator.pop(
                                context,
                                false,
                              );
                            },

                            child:
                            const Text(
                              "Cancel",
                            ),
                          ),

                          TextButton(

                            onPressed: () {

                              Navigator.pop(
                                context,
                                true,
                              );
                            },

                            child:
                            const Text(

                              "Delete",

                              style:
                              TextStyle(
                                color:
                                Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) {
                    return;
                  }

                  try {

                    await FirebaseFirestore
                        .instance
                        .collection(
                        'campaigns')
                        .doc(campaign.id)
                        .delete();

                    if (context.mounted) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        const SnackBar(

                          content: Text(
                            "Campaign Deleted",
                          ),
                        ),
                      );
                    }

                  } catch (e) {

                    if (context.mounted) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(

                        SnackBar(

                          content: Text(
                            "Delete Failed: $e",
                          ),
                        ),
                      );
                    }
                  }
                },

                itemBuilder:
                    (context) => [

                  const PopupMenuItem(

                    value: 'delete',

                    child: Text(
                      "Delete Campaign",
                    ),
                  ),
                ],

                child: Container(

                  padding:
                  const EdgeInsets.all(6),

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.black54,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: const Icon(

                    Icons.more_vert,

                    color: Colors.white,

                    size: 18,
                  ),
                ),
              ),
            ),

            // =================================
            // CONTENT
            // =================================

            Positioned(

              left: 20,
              right: 20,
              bottom: 20,

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  _badge(
                    "CAMPAIGN",
                    Colors.orange,
                  ),

                  const SizedBox(
                      height: 10),

                  Text(

                    campaign.title,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontSize: 20,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 6),

                  Text(

                    campaign.description,

                    maxLines: 2,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    const TextStyle(

                      color:
                      Colors.white70,

                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                      height: 12),

                  Row(

                    children: [

                      const Icon(

                        Icons.perm_media,

                        color:
                        Colors.white70,

                        size: 15,
                      ),

                      const SizedBox(
                          width: 4),

                      Text(

                        "$assetCount Assets",

                        style:
                        const TextStyle(

                          color:
                          Colors.white70,

                          fontSize: 11,
                        ),
                      ),

                      const Spacer(),

                      Text(

                        "P${campaign.priority}",

                        style:
                        const TextStyle(

                          color:
                          Colors.orange,

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BADGE
  // =========================================================

  Widget _badge(
      String text,
      Color color,
      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal: 8,

        vertical: 4,
      ),

      decoration: BoxDecoration(

        color: color,

        borderRadius:
        BorderRadius.circular(6),
      ),

      child: Text(

        text,

        style: const TextStyle(

          color: Colors.white,

          fontSize: 10,

          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // FALLBACK
  // =========================================================

  Widget _fallbackImage() {

    return Container(

      color:
      const Color(0xFF0A2540),

      child: const Center(

        child: Icon(

          Icons.campaign,

          color: Colors.white,

          size: 50,
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _buildEmptyState() {

    return Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons.campaign_outlined,

            size: 80,

            color:
            Colors.grey.shade400,
          ),

          const SizedBox(
              height: 16),

          const Text(

            "No campaigns available",

            style: TextStyle(

              color: Colors.grey,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}