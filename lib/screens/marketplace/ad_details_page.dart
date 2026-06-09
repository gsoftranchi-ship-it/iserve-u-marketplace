import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/media_asset_model.dart';
import '../../players/web_player/widgets/web_video_widget.dart';

class AdDetailsPage extends StatefulWidget {

  final Map<String, dynamic> ad;

  const AdDetailsPage({
    super.key,
    required this.ad,
  });

  @override
  State<AdDetailsPage> createState() =>
      _AdDetailsPageState();
}

class _AdDetailsPageState
    extends State<AdDetailsPage> {

  late PageController _pageController;

  int currentPage = 0;

  List<MediaAssetModel> assets = [];

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    _pageController = PageController();

    _loadAssets();
  }

  @override
  void dispose() {

    _pageController.dispose();

    super.dispose();
  }

  // =========================================================
  // LOAD ASSETS
  // =========================================================

  Future<void> _loadAssets() async {

    try {

      final campaignId =
          widget.ad['id'] ??
              widget.ad['campaignId'];

      debugPrint(
        "DETAIL PAGE campaignId => $campaignId",
      );

      if (campaignId == null) {

        setState(() {
          isLoading = false;
        });

        return;
      }

      final snapshot =
      await FirebaseFirestore.instance

          .collection('campaigns')

          .doc(campaignId)

          .collection('media_assets')

          .get();

      debugPrint(
        "DETAIL PAGE assets => ${snapshot.docs.length}",
      );

      final loaded =
      snapshot.docs.map((doc) {

        return MediaAssetModel.fromMap(
          doc.id,
          doc.data(),
        );

      }).toList();

      if (mounted) {

        setState(() {

          assets = loaded;

          isLoading = false;
        });

        if (assets.length > 1) {

          _startAutoSlide();
        }
      }

    } catch (e) {

      debugPrint(
        "LOAD ASSETS ERROR => $e",
      );

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // AUTO SLIDE
  // =========================================================

  void _startAutoSlide() {

    Future.delayed(
      const Duration(seconds: 4),
          () {

        if (!mounted || assets.isEmpty) {
          return;
        }

        currentPage++;

        if (currentPage >= assets.length) {
          currentPage = 0;
        }

        _pageController.animateToPage(

          currentPage,

          duration:
          const Duration(milliseconds: 500),

          curve: Curves.easeInOut,
        );

        _startAutoSlide();
      },
    );
  }

  // =========================================================
  // CONTACT
  // =========================================================

  Future<void> _contactClient(
      String type,
      String value,
      ) async {

    final clean =
    value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (clean.isEmpty) {
      return;
    }

    final Uri url =

    type == 'tel'

        ? Uri.parse('tel:$clean')

        : Uri.parse(
      'https://wa.me/$clean',
    );

    await launchUrl(
      url,
      mode:
      LaunchMode.externalApplication,
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    final bool isLive =
        widget.ad['status'] == 'active';

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        title: const Text(
          "Campaign Details",
        ),
      ),

      body:

      isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =====================================================
            // MEDIA SLIDER
            // =====================================================

            SizedBox(

              height: 340,

              width: double.infinity,

              child:

              assets.isEmpty

                  ? _fallbackMedia()

                  : PageView.builder(

                controller:
                _pageController,

                itemCount:
                assets.length,

                itemBuilder:
                    (
                    context,
                    index,
                    ) {

                  final asset =
                  assets[index];

                  // VIDEO

                  if (
                  asset.mediaType ==
                      'video'
                  ) {

                    return Container(

                      color:
                      Colors.black,

                      child:
                      SizedBox.expand(

                        child: VideoPlayerWidget(
                          url: asset.mediaUrl,
                        ),
                      ),
                    );
                  }

                  // IMAGE

                  return Container(

                    color: Colors.black,

                    width: double.infinity,

                    height: double.infinity,

                    child: Image.network(

                      asset.mediaUrl,

                      width: double.infinity,

                      height: double.infinity,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                          c,
                          e,
                          s,
                          ) {

                        return _fallbackMedia();
                      },
                    ),
                  );
                },
              ),
            ),

            // =====================================================
            // DETAILS
            // =====================================================

            Padding(

              padding:
              const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Row(

                    children: [

                      Expanded(

                        child: Text(

                          widget.ad['title']
                              ??
                              'Campaign',

                          style:
                          const TextStyle(

                            fontSize: 30,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      _badge(

                        "P${widget.ad['priority'] ?? 1}",

                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(

                    widget.ad[
                    'description'] ??
                        '',

                    style:
                    const TextStyle(

                      fontSize: 16,

                      color:
                      Colors.black54,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  _infoTile(
                    Icons.location_on,
                    "Target Sites",
                    (
                        widget.ad['siteIds']
                        as List?
                    )?.join(', ') ??
                        'N/A',
                  ),

                  _infoTile(
                    Icons.calendar_today,
                    "Campaign Status",
                    isLive
                        ? "LIVE NOW"
                        : "PENDING",
                  ),

                  _infoTile(
                    Icons.timer,
                    "Duration",
                    "${widget.ad['durationSeconds'] ?? 10}s",
                  ),

                  _infoTile(
                    Icons.play_circle,
                    "Total Plays",
                    "${widget.ad['totalPlays'] ?? 0}",
                  ),

                  _infoTile(
                    Icons.visibility,
                    "Impressions",
                    "${widget.ad['totalImpressions'] ?? 0}",
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  const Text(

                    "Advertiser Contact",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Card(

                    color:
                    Colors.grey.shade100,

                    child: ListTile(

                      leading:
                      const CircleAvatar(

                        backgroundColor:
                        Colors.orange,

                        child: Icon(
                          Icons.person,
                          color:
                          Colors.white,
                        ),
                      ),

                      title: Text(

                        widget.ad[
                        'contactInfo'] ??
                            'Client',
                      ),

                      subtitle:
                      const Text(
                        "Usually responds quickly",
                      ),

                      trailing: Row(

                        mainAxisSize:
                        MainAxisSize.min,

                        children: [

                          IconButton(

                            icon: const Icon(
                              Icons.phone,
                              color:
                              Colors.green,
                            ),

                            onPressed: () {

                              _contactClient(

                                'tel',

                                widget.ad[
                                'contactInfo']
                                    ?.toString() ??
                                    '',
                              );
                            },
                          ),

                          IconButton(

                            icon: const Icon(
                              Icons.message,
                              color:
                              Colors.blue,
                            ),

                            onPressed: () {

                              _contactClient(

                                'wa',

                                widget.ad[
                                'contactInfo']
                                    ?.toString() ??
                                    '',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
  // INFO TILE
  // =========================================================

  Widget _infoTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(

        children: [

          Icon(
            icon,
            color: Colors.orange,
          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    color:
                    Colors.grey.shade600,

                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(

                  value,

                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(

        color: color,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(

        text,

        style: const TextStyle(

          color: Colors.white,

          fontSize: 11,

          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // FALLBACK
  // =========================================================

  Widget _fallbackMedia() {

    return Container(

      color:
      const Color(0xFF0A2540),

      child: const Center(

        child: Icon(

          Icons.campaign,

          color: Colors.white,

          size: 60,
        ),
      ),
    );
  }
}