import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';

import '../../players/web_player/widgets/web_video_widget.dart';

class SiteManagerPage extends StatelessWidget {
  const SiteManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F3F6),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF0A2540),
          foregroundColor: Colors.white,
          title: const Text(
            "Digital Signage Manager",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: Icon(Icons.location_on),
                text: "Sites",
              ),
              Tab(
                icon: Icon(Icons.pending_actions),
                text: "Pending Approvals",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SitesTab(),
            _PendingAdsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.orange,
          icon: const Icon(Icons.add_location_alt),
          label: const Text(
            "Hire New Site",
          ),
          onPressed: () {
            _addSiteDialog(context);
          },
        ),
      ),
    );
  }

  // =========================================================
  // ADD SITE DIALOG
  // =========================================================

  static void _addSiteDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final monthlyRentalController = TextEditingController();
    final oneDayController = TextEditingController();

    final videoMultiplierController = TextEditingController(
      text: '1.5',
    );

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Register LED Site",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Site Name",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: monthlyRentalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Monthly Rental Cost",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: oneDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Base 1 Day Ad Price",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: videoMultiplierController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Video Price Multiplier",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      return;
                    }

                    setState(() {
                      isSaving = true;
                    });

                    try {
                      final existing = await FirebaseFirestore.instance
                          .collection('signage_sites')
                          .where(
                        'name',
                        isEqualTo: name,
                      )
                          .limit(1)
                          .get();

                      if (existing.docs.isNotEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Site already exists",
                              ),
                            ),
                          );
                        }

                        return;
                      }

                      final int oneDayPrice =
                          int.tryParse(oneDayController.text) ?? 0;

                      await FirebaseFirestore.instance
                          .collection('signage_sites')
                          .add({
                        // =================================
                        // BASIC
                        // =================================

                        'name': name,

                        'location':
                        locationController.text.trim(),

                        'monthlyRental':
                        int.tryParse(
                          monthlyRentalController.text,
                        ) ??
                            0,

                        // =================================
                        // PRICING
                        // =================================

                        'pricing': {
                          '1_day': oneDayPrice,
                        },

                        'videoMultiplier':
                        double.tryParse(
                          videoMultiplierController.text,
                        ) ??
                            1.5,

                        // =================================
                        // LIVE DISPLAY
                        // =================================

                        'currentAdUrl': '',

                        'currentAdType': '',

                        // =================================
                        // SYSTEM
                        // =================================

                        'isActive': true,

                        'isOnline': true,

                        'createdAt':
                        FieldValue.serverTimestamp(),

                        'lastUpdated':
                        FieldValue.serverTimestamp(),
                      });

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "LED Site Registered",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Unable to create site: $e",
                            ),
                          ),
                        );
                      }
                    } finally {
                      setState(() {
                        isSaving = false;
                      });
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Create Site",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ===========================================================
// SITES TAB
// ===========================================================

class _SitesTab extends StatelessWidget {
  const _SitesTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('signage_sites')
          .orderBy(
        'createdAt',
        descending: true,
      )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Unable to load sites\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Sites Found"),
          );
        }

        final sites = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: sites.length,
          itemBuilder: (context, index) {
            final doc = sites[index];

            final data = doc.data() as Map<String, dynamic>?;

            final String siteName =
                data?['name'] ?? 'Unnamed Site';

            final String imageUrl =
                data?['currentAdUrl'] ?? '';

            final bool isOnline =
                data?['isOnline'] ?? true;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                        ),
                      );
                    },
                  )
                      : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  siteName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  isOnline
                      ? (imageUrl.isNotEmpty
                      ? 'Live Ad Running'
                      : 'Idle')
                      : 'Offline',
                  style: TextStyle(
                    color: !isOnline
                        ? Colors.red
                        : imageUrl.isNotEmpty
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.blue,
                        size: 22,
                      ),
                      onPressed: () {
                        _uploadAdToSite(
                          context,
                          doc.id,
                        );
                      },
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 22,
                      ),
                      onPressed: () {
                        _confirmDelete(
                          context,
                          doc,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================
  // MANUAL AD UPLOAD
  // =========================================================

  Future<void> _uploadAdToSite(
      BuildContext context,
      String siteId,
      ) async {
    final picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image == null) {
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Uploading Campaign...",
            ),
          ),
        );
      }

      final fileName =
          'ads/${siteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance
          .ref()
          .child(fileName);

      if (kIsWeb) {
        await ref.putData(
          await image.readAsBytes(),
          SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );
      } else {
        await ref.putFile(
          File(image.path),
        );
      }

      final downloadUrl =
      await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('signage_sites')
          .doc(siteId)
          .update({
        'currentAdUrl': downloadUrl,
        'currentAdType': 'image',
        'lastUpdated':
        FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Ad is now LIVE!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Upload Failed: $e",
            ),
          ),
        );
      }
    }
  }

  // =========================================================
  // DELETE SITE
  // =========================================================

  void _confirmDelete(
      BuildContext context,
      DocumentSnapshot doc,
      ) {
    final data =
    doc.data() as Map<String, dynamic>?;

    final name =
        data?['name'] ?? 'Unknown Site';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Site?",
          ),
          content: Text(
            "This will remove '$name' from your network.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await doc.reference.delete();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          "Delete Failed: $e",
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===========================================================
// PENDING APPROVALS
// ===========================================================

class _PendingAdsTab extends StatelessWidget {
  const _PendingAdsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaigns')
          .where(
        'status',
        isEqualTo: 'pending_approval',
      )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No ads waiting for approval.",
            ),
          );
        }

        final ads = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: ads.length,
          itemBuilder: (context, index) {
            final ad = ads[index];

            final data =
            ad.data() as Map<String, dynamic>?;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ),
                child: Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                              Colors.orange.shade100,
                              child: const Icon(
                                Icons.campaign,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data?['title'] ??
                                        'Untitled Ad',
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data?['category'] ?? '',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 420,
                          child:_FirebaseCampaignPreview(
                            campaignId: ad.id,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius:
                            BorderRadius.circular(14),
                            border: Border.all(
                              color:
                              Colors.orange.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "LED Site: ${(data?['siteIds'] as List?)?.join(', ') ?? 'N/A'}",
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Duration: ${data?['durationLabel'] ?? '1 Day'}",
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Price: ${data?['price'] ?? '₹0'}",
                              ),
                              const SizedBox(height: 6),
                              SelectableText(
                                "Transaction ID: ${data?['transactionId'] ?? 'Pending'}",
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Contact: ${data?['contactInfo'] ?? 'N/A'}",
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Payment Status: ${data?['paymentStatus'] ?? 'Pending'}",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          data?['description'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.green,
                                  padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await ad.reference.update({

                                      'status': 'active',

                                      'isActive': true,

                                      'updatedAt':
                                      FieldValue.serverTimestamp(),
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Ad Approved & Published Live",
                                          ),
                                          backgroundColor:
                                          Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Approval Failed: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  "Approve & Live",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {

                                  try {

                                    await ad.reference.update({

                                      'status': 'rejected',

                                      'isActive': false,

                                      'updatedAt':
                                      FieldValue.serverTimestamp(),
                                    });

                                    if (context.mounted) {

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(

                                        const SnackBar(

                                          content: Text(
                                            "Campaign Rejected",
                                          ),
                                        ),
                                      );
                                    }

                                  } catch (e) {

                                    if (context.mounted) {

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(

                                        SnackBar(

                                          content: Text(
                                            "Reject Failed: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  "Reject",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AutoMediaPreview extends StatefulWidget {
  final List<String> images;
  final String video;

  const _AutoMediaPreview({
    required this.images,
    required this.video,
  });

  @override
  State<_AutoMediaPreview> createState() =>
      _AutoMediaPreviewState();
}

class _AutoMediaPreviewState
    extends State<_AutoMediaPreview> {
  late final List<Map<String, String>> media;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    media = [];

    if (widget.video.isNotEmpty) {
      media.add({
        'type': 'video',
        'url': widget.video,
      });
    }

    for (final image in widget.images) {
      media.add({
        'type': 'image',
        'url': image,
      });
    }

    _startRotation();
  }

  void _startRotation() async {
    while (mounted && media.length > 1) {
      await Future.delayed(
        const Duration(seconds: 4),
      );

      if (!mounted) return;

      setState(() {
        currentIndex =
            (currentIndex + 1) % media.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = media[currentIndex];

    final type = item['type'];

    final url = item['url'] ?? '';

    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 500,
      ),
      child: Container(
        key: ValueKey(
          "$type$currentIndex",
        ),
        width: double.infinity,
        height: 420,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: type == 'video'
            ? Stack(
          children: [
            Positioned.fill(
              child: VideoPlayerWidget(
                url: url,

              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: const Text(
                  "VIDEO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
            : Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                url,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  "${currentIndex + 1}/${media.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _FirebaseCampaignPreview
    extends StatelessWidget {

  final String campaignId;

  const _FirebaseCampaignPreview({

    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(

      stream:
      FirebaseFirestore.instance
          .collection(
          'campaigns')
          .doc(campaignId)
          .collection(
          'media_assets')
          .orderBy(
        'sortOrder',
      )
          .snapshots(),

      builder:
          (context, snapshot) {

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {

          return const Center(
            child: Text(
              "No Media Found",
            ),
          );
        }

        final media =
            snapshot.data!.docs;

        return ListView.builder(

          scrollDirection:
          Axis.horizontal,

          itemCount:
          media.length,

          itemBuilder:
              (context, index) {

            final data =
            media[index].data()
            as Map<String, dynamic>?;

            final mediaType =
                data?['mediaType']
                    ?.toString() ?? '';

            final mediaUrl =
                data?['mediaUrl']
                    ?.toString() ?? '';

            return Container(

              width: 320,

              margin:
              const EdgeInsets.only(
                right: 12,
              ),

              decoration:
              BoxDecoration(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                color:
                Colors.black,
              ),

              clipBehavior:
              Clip.antiAlias,

              child:
              mediaType ==
                  'video'

                  ? VideoPlayerWidget(
                url: mediaUrl,
              )

                  : Image.network(
                mediaUrl,
                fit: BoxFit.contain,
              ),
            );
          },
        );
      },
    );
  }
}
