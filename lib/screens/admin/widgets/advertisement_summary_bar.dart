import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdvertisementSummaryBar extends StatelessWidget {
  const AdvertisementSummaryBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaigns')
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;

        final totalAds = docs.length;

        final pendingAds = docs.where((doc) {
          final ad =
          doc.data() as Map<String, dynamic>;

          return ad['status'] == 'pending';
        }).length;

        final approvedAds = docs.where((doc) {
          final ad =
          doc.data() as Map<String, dynamic>;

          return ad['status'] == 'approved';
        }).length;

        final revenue = docs.fold<double>(
          0,
              (sum, doc) {
            final ad =
            doc.data() as Map<String, dynamic>;

            return sum +
                ((ad['price'] ?? 0) as num)
                    .toDouble();
          },
        );

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [

              _card(
                "Total Ads",
                totalAds.toString(),
                Icons.campaign,
              ),

              _card(
                "Pending",
                pendingAds.toString(),
                Icons.pending_actions,
              ),

              _card(
                "Approved",
                approvedAds.toString(),
                Icons.check_circle,
              ),

              _card(
                "Revenue",
                "₹${revenue.toStringAsFixed(0)}",
                Icons.currency_rupee,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [

          Icon(icon, size: 32),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(title),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}