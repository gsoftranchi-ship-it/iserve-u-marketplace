import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }



          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.notifications_off_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No Notifications Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }


          final notifications =
              snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),

            itemCount: notifications.length,

            separatorBuilder: (_, _) =>
            const SizedBox(height: 10),

            itemBuilder: (context, index) {

              final data =
              notifications[index].data()
              as Map<String, dynamic>;

              final title =
                  data['title'] ?? '';

              final body =
                  data['body'] ?? '';

              final type =
                  data['type'] ?? '';

              final createdAt = data['createdAt'];

              String dateText = '';

              if (createdAt != null) {
                try {
                  dateText = DateFormat(
                    'dd MMM yyyy • hh:mm a',
                  ).format(
                    DateTime.parse(
                      createdAt.toString(),
                    ),
                  );
                } catch (e) {
                  dateText = createdAt.toString();
                }
              }

              return Card(
                elevation: 1,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),

                child: ListTile(
                  contentPadding:
                  const EdgeInsets.all(14),

                  leading: CircleAvatar(
                      backgroundColor:
                      _getNotificationColor(type, title).withValues(alpha: 0.25),

                      child: Icon(
                        _getNotificationIcon(type, title),
                        color: _getNotificationColor(type, title),
                      ),
                  ),

                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 6),

                      Text(body),

                      const SizedBox(height: 4),

                      Text(
                        dateText,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
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

  IconData _getNotificationIcon(String type, String title) {

    if (title.toLowerCase().contains('delivered')) {
      return Icons.check_circle;
    }

    if (title.toLowerCase().contains('ready')) {
      return Icons.restaurant;
    }

    if (title.toLowerCase().contains('new order')) {
      return Icons.receipt_long;
    }

    switch (type) {

      case 'delivery':
        return Icons.delivery_dining;

      case 'payment':
        return Icons.payments;

      case 'order':
        return Icons.receipt_long;

      default:
        return Icons.notifications;
    }
  }
  Color _getNotificationColor(String type, String title) {
    final t = title.toLowerCase().trim();

    if (t.contains('delivered')) {
      return Colors.green;
    }

    if (t.contains('ready')) {
      return Colors.blue;
    }

    if (t.contains('new order')) {
      return Colors.deepOrange;
    }

    if (t.contains('assigned')) {
      return Colors.orange;
    }

    switch (type.toLowerCase()) {
      case 'delivery':
        return Colors.blue;

      case 'payment':
        return Colors.green;

      case 'order':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }
}