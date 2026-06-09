import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminTicketsPage extends StatelessWidget {
  const AdminTicketsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support Tickets',
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_tickets')
            .orderBy(
          'createdAt',
          descending: true,
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
              child:
              CircularProgressIndicator(),
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
            padding:
            const EdgeInsets.all(12),

            itemCount:
            snapshot.data!.docs.length,

            itemBuilder:
                (context, index) {

              final ticketDoc =
              snapshot.data!.docs[index];

              final data =
              ticketDoc.data()
              as Map<String, dynamic>;

              final currentStatus =
              (data['status'] ?? 'OPEN')
                  .toString();

              return Card(
                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),

                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    12,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Text(
                        data['category'] ??
                            '',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'Customer: ${data['userName'] ?? ''}',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        data['message'] ??
                            '',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Row(
                        children: [

                          Expanded(
                            child:
                            DropdownButtonFormField<String>(

                              initialValue:
                              currentStatus,

                              decoration:
                              const InputDecoration(
                                labelText:
                                'Status',
                                border:
                                OutlineInputBorder(),
                              ),

                              items: const [

                                DropdownMenuItem(
                                  value:
                                  'OPEN',
                                  child: Text(
                                    'OPEN',
                                  ),
                                ),

                                DropdownMenuItem(
                                  value:
                                  'IN_PROGRESS',
                                  child: Text(
                                    'IN_PROGRESS',
                                  ),
                                ),

                                DropdownMenuItem(
                                  value:
                                  'RESOLVED',
                                  child: Text(
                                    'RESOLVED',
                                  ),
                                ),

                                DropdownMenuItem(
                                  value:
                                  'CLOSED',
                                  child: Text(
                                    'CLOSED',
                                  ),
                                ),
                              ],

                              onChanged:
                                  (value) async {

                                if (value ==
                                    null) {
                                  return;
                                }

                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                  'support_tickets',
                                )
                                    .doc(
                                  ticketDoc.id,
                                )
                                    .update({

                                  'status':
                                  value,

                                  'updatedAt':
                                  FieldValue
                                      .serverTimestamp(),
                                });
                              },
                            ),
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