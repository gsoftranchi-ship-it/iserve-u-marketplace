import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../core/models/media_asset_model.dart';
import '../../players/web_player/widgets/web_video_widget.dart';
import '../../data/analytics_service.dart';

class AdDetailsPage extends StatefulWidget {
  final Map<String, dynamic> ad;

  const AdDetailsPage({super.key, required this.ad});

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  late PageController _pageController;

  int currentPage = 0;

  List<MediaAssetModel> assets = [];

  bool isLoading = true;
  Timer? _imageTimer;
  bool _isPaused = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();

    final campaignId =
        widget.ad['id'] ??
            widget.ad['campaignId'];

    if (campaignId != null) {
      AnalyticsService.recordView(
        campaignId.toString(),
      );
    }

    _pageController = PageController();

    _loadAssets();
  }

  @override
  void dispose() {
    _imageTimer?.cancel();

    _pageController.dispose();

    super.dispose();
  }

  // =========================================================
  // LOAD ASSETS
  // =========================================================

  Future<void> _loadAssets() async {
    try {
      final campaignId = widget.ad['id'] ?? widget.ad['campaignId'];

      debugPrint("DETAIL PAGE campaignId => $campaignId");

      if (campaignId == null) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(campaignId)
          .collection('media_assets')
          .get();

      debugPrint("DETAIL PAGE assets => ${snapshot.docs.length}");

      final loaded = snapshot.docs.map((doc) {
        return MediaAssetModel.fromMap(doc.id, doc.data());
      }).toList();

      if (mounted) {
        setState(() {
          assets = loaded;

          isLoading = false;
        });

        if (loaded.isNotEmpty && loaded.first.mediaType == 'image') {
          _imageTimer?.cancel();

          _imageTimer = Timer(const Duration(seconds: 15), _nextPage);
        }
      }
    } catch (e) {
      debugPrint("LOAD ASSETS ERROR => $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_isPaused) {
      return;
    }

    if (!mounted || assets.isEmpty) {
      return;
    }

    _imageTimer?.cancel();

    final nextIndex = (currentPage + 1) % assets.length;

    setState(() {
      currentPage = nextIndex;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });

    _imageTimer?.cancel();

    final asset = assets[index];

    if (asset.mediaType == 'image') {
      _imageTimer = Timer(const Duration(seconds: 15), _nextPage);
    }
  }

  void _previousPage() {
    if (!mounted || assets.isEmpty) {
      return;
    }

    _imageTimer?.cancel();

    final previousIndex = currentPage == 0
        ? assets.length - 1
        : currentPage - 1;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        previousIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _imageTimer?.cancel();
    } else {
      _onPageChanged(currentPage);
    }
  }

  Future<void> _toggleFullscreen() async {
    debugPrint("FULLSCREEN CLICKED => $_isFullscreen");

    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  // =========================================================
  // CONTACT
  // =========================================================

  Future<void> _contactClient(String type, String value) async {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.isEmpty) {
      return;
    }

    final Uri url = type == 'tel'
        ? Uri.parse('tel:$clean')
        : Uri.parse('https://wa.me/$clean');

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(title: const Text("Advertisement Details")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =====================================================
                  // MEDIA SLIDER
                  // =====================================================
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),

                    height: _isFullscreen
                        ? MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.height * 0.65
                        : 420,

                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    clipBehavior: Clip.antiAlias,

                    child: assets.isEmpty
                        ? _fallbackMedia()
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: assets.length,
                            onPageChanged: _onPageChanged,
                            itemBuilder: (context, index) {
                              final asset = assets[index];

                              // VIDEO

                              if (asset.mediaType == 'video') {
                                return Container(
                                  color: Colors.black,

                                  child: SizedBox.expand(
                                    child: VideoPlayerWidget(
                                      url: asset.mediaUrl,
                                      onVideoFinished: _nextPage,
                                    ),
                                  ),
                                );
                              }

                              // IMAGE

                              return Container(
                                color: Colors.black,

                                width: double.infinity,

                                height: double.infinity,

                                child: Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      asset.mediaUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange.shade50,
                        child: IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: _previousPage,
                        ),
                      ),

                      const SizedBox(width: 8),

                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange.shade50,
                        child: IconButton(
                          icon: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                          ),
                          onPressed: _togglePause,
                        ),
                      ),

                      const SizedBox(width: 8),

                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange.shade50,
                        child: IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: _nextPage,
                        ),
                      ),

                      const SizedBox(width: 8),

                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange.shade50,
                        child: IconButton(
                          icon: Icon(
                            _isFullscreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                          onPressed: _toggleFullscreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      assets.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 12 : 8,
                        height: currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "${currentPage + 1}/${assets.length}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // =====================================================
                  // DETAILS
                  // =====================================================
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.ad['title'] ?? 'Campaign',

                                    style: const TextStyle(
                                      fontSize: 30,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                _badge(
                                  "P${widget.ad['priority'] ?? 1}",

                                  Colors.orange,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Text(
                              widget.ad['description'] ?? '',

                              style: const TextStyle(
                                fontSize: 16,

                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 25),

                            _infoTile(
                              Icons.campaign,
                              "Advertisement Status",
                              (widget.ad['status'] ?? 'pending')
                                  .toString()
                                  .toUpperCase(),
                            ),

                            _infoTile(
                              Icons.payment,
                              "Payment Status",
                              (widget.ad['paymentStatus'] ?? 'submitted')
                                  .toString()
                                  .toUpperCase(),
                            ),

                            _infoTile(
                              Icons.timer,
                              "Duration",
                              "${widget.ad['durationSeconds'] ?? 10}s",
                            ),

                            _infoTile(
                              Icons.calendar_today,
                              "Start Date",
                              widget.ad['startDate'] != null
                                  ? (widget.ad['startDate'] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .split(' ')[0]
                                  : '-',
                            ),

                            _infoTile(
                              Icons.event,
                              "End Date",
                              widget.ad['endDate'] != null
                                  ? (widget.ad['endDate'] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .split(' ')[0]
                                  : '-',
                            ),

                            _infoTile(
                              Icons.play_arrow,
                              "Total Plays",
                              "${widget.ad['totalPlays'] ?? 0}",
                            ),

                            _infoTile(
                              Icons.visibility,
                              "Impressions",
                              "${widget.ad['totalImpressions'] ?? 0}",
                            ),
                            _infoTile(
                              Icons.photo_library,
                              "Assets",
                              "${assets.length}",
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Advertiser Contact",

                              style: TextStyle(
                                fontSize: 18,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Card(
                              color: Colors.grey.shade100,

                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.orange,

                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),

                                title: Text(
                                  widget.ad['contactInfo'] ?? 'Client',
                                ),

                                subtitle: const Text(
                                  "Usually responds quickly",
                                ),

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.phone,
                                        color: Colors.green,
                                      ),

                                      onPressed: () async {

                                        final campaignId =
                                            widget.ad['id'] ??
                                                widget.ad['campaignId'];

                                        if (campaignId != null) {
                                          await AnalyticsService.recordPhoneClick(
                                            campaignId.toString(),
                                          );
                                        }

                                        _contactClient(
                                          'tel',
                                          widget.ad['contactInfo']
                                              ?.toString() ??
                                              '',
                                        );
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.message,
                                        color: Colors.blue,
                                      ),

                                      onPressed: () async {

                                        final campaignId =
                                            widget.ad['id'] ??
                                                widget.ad['campaignId'];

                                        if (campaignId != null) {
                                          await AnalyticsService.recordWhatsappClick(
                                            campaignId.toString(),
                                          );
                                        }

                                        _contactClient(
                                          'wa',
                                          widget.ad['contactInfo']
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

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        children: [
          Icon(icon, color: Colors.orange),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: const TextStyle(
          color: Colors.white,

          fontSize: 11,

          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // FALLBACK
  // =========================================================

  Widget _fallbackMedia() {
    return Container(
      color: const Color(0xFF0A2540),

      child: const Center(
        child: Icon(Icons.ads_click, color: Colors.white, size: 60),
      ),
    );
  }
}
