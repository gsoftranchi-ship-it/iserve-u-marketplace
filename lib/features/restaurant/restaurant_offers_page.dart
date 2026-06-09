import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantOffersPage extends StatelessWidget {
  const RestaurantOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not Logged In'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Offers'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddOfferDialog(context, user.uid);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Offer'),
      ),



      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurant_offers')
            .snapshots(),
        builder: (context, snapshot) {

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
                'No offers available',
              ),
            );
          }

          final offers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: offers.length,
            itemBuilder: (context, index) {

              final offer = offers[index];

              final data =
              offer.data()
              as Map<String, dynamic>;

              return Card(
                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),

                child: ListTile(

                  title: Text(
                    data['title'] ?? '',
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        data['description'] ?? '',
                      ),

                      Text(
                        "${data['discountPercent']}% OFF",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Switch(
                        value: data['active'] ?? true,
                        onChanged: (value) async {
                          await offer.reference.update({
                            'active': value,
                          });
                        },
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await offer.reference.delete();
                        },
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

  void _showAddOfferDialog(
      BuildContext context,
      String restaurantId,
      ) {

    final titleController =
    TextEditingController();

    final descriptionController =
    TextEditingController();

    final discountController =
    TextEditingController();

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
          const Text('Create Offer'),

          content:
          SingleChildScrollView(

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children: [

                TextField(
                  controller:
                  titleController,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Offer Title',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller:
                  descriptionController,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Description',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller:
                  discountController,

                  keyboardType:
                  TextInputType.number,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Discount %',
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
              const Text('Cancel'),
            ),

            ElevatedButton(

              onPressed: () async {

                await FirebaseFirestore
                    .instance
                    .collection('restaurant_offers')
                    .add({

                  'restaurantId': restaurantId,

                  'restaurantName':
                  'G-Soft Restaurant',

                  'title':
                  titleController.text.trim(),

                  'description':
                  descriptionController.text.trim(),

                  'discountPercent':
                  int.tryParse(
                    discountController.text,
                  ) ?? 0,

                  'active': true,

                  'createdAt':
                  FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },

              child:
              const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}