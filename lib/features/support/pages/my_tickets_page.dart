import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tickets',
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_tickets')
            .where(
          'userId',
          isEqualTo: currentUserId,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No support tickets found',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),

            itemCount:
            snapshot.data!.docs.length,

            itemBuilder:
                (context, index) {

              final data =
              snapshot.data!.docs[index]
                  .data()
              as Map<String, dynamic>;

              return Card(

                margin: const EdgeInsets.only(
                  bottom: 12,
                ),

                child: Padding(

                  padding: const EdgeInsets.all(12),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        data['category'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        data['message'] ?? '',
                      ),

                      const SizedBox(height: 12),

                      Row(

                        children: [

                          Container(

                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(

                              color:
                              (data['status'] == 'OPEN')
                                  ? Colors.orange
                                  .withValues(alpha: 0.2)
                                  : Colors.green
                                  .withValues(alpha: 0.2),

                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),

                            child: Text(
                              data['status'] ?? '',
                            ),
                          ),

                          const Spacer(),

                          if (data['status'] == 'OPEN')

                            ElevatedButton.icon(

                              icon: const Icon(
                                Icons.check_circle,
                              ),

                              label: const Text(
                                'Close Ticket',
                              ),

                              onPressed: () async {

                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                  'support_tickets',
                                )
                                    .doc(
                                  snapshot
                                      .data!
                                      .docs[index]
                                      .id,
                                )
                                    .update({

                                  'status':
                                  'CLOSED',

                                  'closedAt':
                                  FieldValue
                                      .serverTimestamp(),
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}