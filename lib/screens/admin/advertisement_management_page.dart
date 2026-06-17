import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets/advertisement_card.dart';
import 'widgets/advertisement_summary_bar.dart';

class AdvertisementManagementPage extends StatefulWidget {
  const AdvertisementManagementPage({
    super.key,
  });

  @override
  State<AdvertisementManagementPage> createState() =>
      _AdvertisementManagementPageState();
}

class _AdvertisementManagementPageState
    extends State<AdvertisementManagementPage> {

  String _selectedFilter = "all";

  @override
  Widget build(BuildContext context) {

    final stream = FirebaseFirestore.instance
        .collection('campaigns')
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Advertisement Management",
        ),
      ),

      body: Column(

        children: [
          const AdvertisementSummaryBar(),

          // =========================
          // FILTERS
          // =========================

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                _buildFilterChip(
                  "All",
                  "all",
                ),

                _buildFilterChip(
                  "Pending",
                  "pending",
                ),

                _buildFilterChip(
                  "Approved",
                  "approved",
                ),

                _buildFilterChip(
                  "Rejected",
                  "rejected",
                ),

                _buildFilterChip(
                  "Verified",
                  "verified",
                ),
              ],
            ),
          ),

          // =========================
          // LIST
          // =========================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: stream,

              builder: (context, snapshot) {

                if (snapshot.hasError) {

                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }

                if (!snapshot.hasData) {

                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                List<QueryDocumentSnapshot> docs =
                    snapshot.data!.docs;


                if (_selectedFilter == "approved") {

                  docs = docs.where((doc) {

                    final ad =
                    doc.data()
                    as Map<String, dynamic>;

                    return ad['status'] ==
                        'approved';

                  }).toList();
                }

                if (_selectedFilter == "pending") {

                  docs = docs.where((doc) {

                    final ad =
                    doc.data()
                    as Map<String, dynamic>;

                    return ad['status'] ==
                        'pending';

                  }).toList();
                }

                if (_selectedFilter == "rejected") {

                  docs = docs.where((doc) {

                    final ad =
                    doc.data()
                    as Map<String, dynamic>;

                    return ad['status'] ==
                        'rejected';

                  }).toList();
                }

                if (_selectedFilter == "verified") {

                  docs = docs.where((doc) {

                    final ad =
                    doc.data()
                    as Map<String, dynamic>;

                    return ad['paymentStatus'] ==
                        'verified';

                  }).toList();
                }

                if (docs.isEmpty) {

                  return const Center(
                    child: Text(
                      "No Advertisements Found",
                    ),
                  );
                }

                return ListView.builder(

                  itemCount:
                  docs.length,

                  itemBuilder:
                      (context, index) {

                    final doc =
                    docs[index];

                    final ad =
                    doc.data() as Map<String, dynamic>;

                    return AdvertisementCard(
                      docId: doc.id,
                      ad: ad,
                      isDuplicate:
                      _isDuplicate(ad, snapshot.data!.docs),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label,
      String value,
      ) {

    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(

        label: Text(label),

        selected:
        _selectedFilter == value,

        onSelected: (_) {

          setState(() {

            _selectedFilter =
                value;
          });
        },
      ),
    );
  }
  bool _isDuplicate(
      Map<String, dynamic> current,
      List<QueryDocumentSnapshot> docs,
      ) {
    final mediaUrl =
        current['mediaUrl'] ?? '';

    if (mediaUrl.isEmpty) {
      return false;
    }

    int count = 0;

    for (final doc in docs) {

      final ad =
      doc.data() as Map<String, dynamic>;

      if (ad['mediaUrl'] == mediaUrl) {
        count++;
      }
    }

    return count > 1;
  }
}