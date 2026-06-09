import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createNotification({

    required String userId,

    required String title,

    required String body,

    required String type,
  }) async {

    final notification =
    AppNotification(

      title: title,

      body: body,

      type: type,

      createdAt: DateTime.now(),
    );

    await _firestore

        .collection('users')

        .doc(userId)

        .collection('notifications')

        .add(
      notification.toMap(),
    );
  }
}