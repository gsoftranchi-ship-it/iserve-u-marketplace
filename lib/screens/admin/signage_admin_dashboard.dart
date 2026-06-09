import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/campaign_card.dart';

class SignageAdminDashboard
    extends StatelessWidget {

  const SignageAdminDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF1F3F6),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
        const Color(0xFF0A2540),

        title: const Text(

          "Digital Signage Manager",

          style: TextStyle(

            color: Colors.white,

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore
            .instance

            .collection(
          'campaigns',
        )

            .orderBy(
          'createdAt',
          descending: true,
        )

            .snapshots(),

        builder:
            (context, snapshot) {

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

              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          // ===================================
          // EMPTY
          // ===================================

          if (
          !snapshot.hasData ||

              snapshot
                  .data!
                  .docs
                  .isEmpty
          ) {

            return _buildEmptyState();
          }

          final docs =
              snapshot.data!.docs;

          // ===================================
          // ANALYTICS
          // ===================================

          int active = 0;

          int pending = 0;

          int rejected = 0;

          for (final doc in docs) {

            final data =
            doc.data()
            as Map<String, dynamic>;

            final status =
                data['status']
                    ?? '';


            if (status == 'active') {
              active++;
            }

            if (
            status ==
                'pending_approval'
            ) {
              pending++;
            }


            if (status == 'rejected') {
              rejected++;
            }
          }

          // ===================================
          // BODY
          // ===================================

          return Column(

            children: [

              _buildStatsHeader(

                active,
                pending,
                rejected,
              ),

              const Padding(

                padding:
                EdgeInsets.all(16),

                child: Align(

                  alignment:
                  Alignment.centerLeft,

                  child: Text(

                    "CAMPAIGN MODERATION",

                    style: TextStyle(

                      fontWeight:
                      FontWeight.w900,

                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              Expanded(

                child: ListView.builder(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount:
                  docs.length,

                  itemBuilder:
                      (context, index) {

                    return CampaignCard(

                      campaignDoc:
                      docs[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // STATS HEADER
  // =========================================================

  Widget _buildStatsHeader(

      int active,

      int pending,

      int rejected,
      ) {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.symmetric(

        vertical: 28,

        horizontal: 20,
      ),

      decoration:
      const BoxDecoration(

        color:
        Color(0xFF0A2540),

        borderRadius:
        BorderRadius.only(

          bottomLeft:
          Radius.circular(30),

          bottomRight:
          Radius.circular(30),
        ),
      ),

      child: Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceAround,

        children: [

          _statTile(
            "ACTIVE",
            active.toString(),
            Colors.greenAccent,
          ),

          _statTile(
            "PENDING",
            pending.toString(),
            Colors.orangeAccent,
          ),

          _statTile(
            "REJECTED",
            rejected.toString(),
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _statTile(

      String label,

      String value,

      Color color,
      ) {

    return Column(

      children: [

        Text(

          label,

          style: const TextStyle(

            color:
            Colors.white70,

            fontSize: 12,
          ),
        ),

        const SizedBox(
            height: 6),

        Text(

          value,

          style: TextStyle(

            color: color,

            fontSize: 24,

            fontWeight:
            FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {

    return const Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons.tv_off,

            size: 70,

            color: Colors.grey,
          ),

          SizedBox(height: 20),

          Text(

            "No campaigns found.",

            style: TextStyle(

              fontSize: 16,

              color: Colors.grey,

              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}