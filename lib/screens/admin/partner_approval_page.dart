import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerApprovalPage extends StatelessWidget {
  const PartnerApprovalPage({super.key});

  Future<void> _approve(
      BuildContext context,
      DocumentSnapshot application,
      ) async {

    final data =
    application.data()
    as Map<String, dynamic>;

    final uid = data['uid'];

    final role =
    data['applicationType'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({

      'role': role,

      'active': true,
    });

    await application.reference.update({

      'status': 'approved',
    });

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text('Application Approved'),
        ),
      );
    }
  }

  Future<void> _reject(
      BuildContext context,
      DocumentSnapshot application,
      ) async {

    await application.reference.update({

      'status': 'rejected',
    });

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text('Application Rejected'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Partner Approvals',
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection(
            'partner_applications')
            .where(
          'status',
          isEqualTo: 'pending',
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {

            return const Center(
              child: Text(
                'No Pending Applications',
              ),
            );
          }

          return ListView.builder(

            itemCount: docs.length,

            itemBuilder: (context, index) {

              final application =
              docs[index];

              final data =
              application.data()
              as Map<String, dynamic>;

              return Card(

                margin:
                const EdgeInsets.all(12),

                child: Padding(

                  padding:
                  const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        data['name'] ?? '',
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        data['email'] ?? '',
                      ),

                      Text(
                        data['phone'] ?? '',
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Chip(
                        label: Text(
                          data['applicationType']
                              ?? '',
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Row(

                        children: [

                          Expanded(
                            child:
                            ElevatedButton(

                              onPressed: () {

                                _approve(
                                  context,
                                  application,
                                );
                              },

                              child:
                              const Text(
                                'APPROVE',
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                            ElevatedButton(

                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.blueGrey[50],
                              ),

                              onPressed: () {

                                _reject(
                                  context,
                                  application,
                                );
                              },

                              child:
                              const Text(
                                'REJECT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                color: Colors.deepOrangeAccent,
                              ),
                             ),
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