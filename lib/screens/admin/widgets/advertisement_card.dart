import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';




class AdvertisementCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> ad;
  final bool isDuplicate;


  const AdvertisementCard({
    super.key,
    required this.docId,
    required this.ad,
    this.isDuplicate = false,

  });


  Future<void> _showApproveDialog(
      BuildContext context,
      ) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Approve Advertisement",
        ),
        content: const Text(
          "Are you sure you want to approve this advertisement?",
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('campaigns')
        .doc(docId)
        .update({

      'status': 'approved',
      'isActive': true,
      'approvedAt': Timestamp.now(),
      'approvedBy': 'Admin',
    });
  }

  Future<void> _showRejectDialog(
      BuildContext context,
      ) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Reject Advertisement",
        ),
        content: const Text(
          "Are you sure you want to reject this advertisement?",
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('campaigns')
        .doc(docId)
        .update({

      'status': 'rejected',
      'isActive': false,
      'rejectedAt': Timestamp.now(),
      'rejectedBy': 'Admin',
    });
  }
  Future<void> _verifyPayment() async {

    await FirebaseFirestore.instance
        .collection('campaigns')
        .doc(docId)
        .update({

      'paymentStatus': 'verified',

      'verifiedAt': Timestamp.now(),

      'verifiedBy': 'Admin',
    });
  }
  void _showDetails(
      BuildContext context,
      ) {

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: Text(
            ad['title'] ?? '',
          ),


          content: SizedBox(
          width: 600,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('campaigns')
                .doc(docId)
                .collection('media_assets')
                .get(),

            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final assets = snapshot.data!.docs;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Transaction: ${ad['transactionId']}",
                    ),

                    Text(
                      "Payment: ${ad['paymentStatus']}",
                    ),

                    Text(
                      "Status: ${ad['status']}",
                    ),

                    const Divider(),

                    const Text(
                      "Media Assets",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...assets.map((assetDoc) {

                      final asset =
                      assetDoc.data()
                      as Map<String, dynamic>;

                      final mediaUrl =
                          asset['mediaUrl'] ?? '';

                      final mediaType =
                          asset['mediaType'] ?? 'image';

                      return Card(
                        child: ListTile(

                          leading: Icon(
                            mediaType == 'video'
                                ? Icons.video_file
                                : Icons.image,
                          ),

                          title: Text(
                            mediaType.toUpperCase(),
                          ),

                          subtitle: Text(
                            asset['fileName'] ?? '',
                          ),

                          trailing: Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                ),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(mediaUrl),
                                  );
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () async {

                                  final url =
                                      asset['mediaUrl'] ?? '';

                                  if (url.isEmpty) {
                                    return;
                                  }

                                  await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child:
              const Text(
                "Close",
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> _openMedia() async {

    final assets = await FirebaseFirestore.instance
        .collection('campaigns')
        .doc(docId)
        .collection('media_assets')
        .limit(1)
        .get();

    if (assets.docs.isEmpty) {
      return;
    }

    final asset =
    assets.docs.first.data();

    final mediaUrl =
        asset['mediaUrl'] ?? '';

    if (mediaUrl.isEmpty) {
      return;
    }

    await launchUrl(
      Uri.parse(mediaUrl),
      mode: LaunchMode.externalApplication,
    );
  }


  @override
  Widget build(BuildContext context) {
    final title = ad['title'] ?? '';
    final mediaUrl = ad['mediaUrl'] ?? '';
    final mediaType = ad['mediaType'] ?? '';
    final phone = ad['contactInfo'] ?? '';
    final status = ad['status'] ?? '';
    final transactionId =
        ad['transactionId'] ?? '';
    final price = ad['price'] ?? 0;


    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            Row(
              children: [

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: mediaUrl.isEmpty
                      ? const Icon(
                    Icons.image_not_supported,
                    size: 40,
                  )
                      : mediaType == 'image'
                      ? Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                  )
                      : Stack(
                    fit: StackFit.expand,
                    children: [

                      Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                      ),

                      Container(
                        color: Colors.black26,
                      ),

                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      if (isDuplicate)

                        Container(
                          margin: const EdgeInsets.only(
                            top: 6,
                          ),
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "DUPLICATE MEDIA",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 5),

                      Text("Phone: $phone"),

                      Text(
                        "Txn ID: $transactionId",
                      ),

                      Text(
                        "₹ $price",
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == "approved"
                              ? Colors.green.shade100
                              : status == "rejected"
                              ? Colors.red.shade100
                              : Colors.orange.shade100,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == "approved"
                                ? Colors.green
                                : status == "rejected"
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Payment: ${ad['paymentStatus'] ?? ''}",
                      ),

                      Text(
                        "Views: ${ad['totalViews'] ?? 0}",
                      ),

                      Text(
                        "Calls: ${ad['phoneClicks'] ?? 0}",
                      ),

                      Text(
                        "WhatsApp: ${ad['whatsappClicks'] ?? 0}",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [

                OutlinedButton.icon(
                  onPressed: _openMedia,
                  icon: const Icon(Icons.image),
                  label: const Text("View Media"),
                ),

                OutlinedButton.icon(
                  onPressed: () => _showDetails(context),
                  icon: const Icon(Icons.info_outline),
                  label: const Text("Details"),
                ),


                if (ad['paymentStatus'] != 'verified')
                  OutlinedButton.icon(
                    onPressed: _verifyPayment,
                  icon: const Icon(
                    Icons.payments,
                  ),
                  label: const Text(
                    "Verify Payment",
                  ),
                ),

                if (status != "approved" &&
                    status != "rejected")

                  OutlinedButton.icon(
                    onPressed: () =>
                        _showRejectDialog(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                    ),
                    label: const Text(
                      "Reject",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),

                if (status != "approved")
                  ElevatedButton.icon(
                  onPressed: () =>
                      _showApproveDialog(context),
                  icon: const Icon(
                    Icons.check_rounded,
                  ),
                  label: const Text(
                    "Approve",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (status == "approved")

                  Chip(
                    avatar: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    label: const Text(
                      "Approved",
                    ),
                    backgroundColor:
                    Colors.green.shade50,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}