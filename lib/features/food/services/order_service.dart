import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../notifications/services/notification_service.dart';
import '../../notifications/constants/notification_types.dart';

class OrderService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final NotificationService
  _notificationService =
  NotificationService();

  Future<void> placeOrder({

    required List<Map<String, dynamic>>
    items,

    required double totalAmount,

    required String paymentMethod,

    required String paymentStatus,

    String? transactionId,

    required String customerPhone,

    required String deliveryAddress,

    required String landmark,

    required String deliveryNote,

    required String pincode,

    double? customerLatitude,
    double? customerLongitude,
  }) async {

    final currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        "User not logged in",
      );
    }

    final userDoc =
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData =
        userDoc.data() ?? {};

    final random = Random();

    final deliveryPin =
        1000 + random.nextInt(9000);

    await _firestore
        .collection('orders')
        .add({

      'userId':
      currentUser.uid,

      'customerName':
      userData['name'] ?? '',

      'customerPhone':
      customerPhone,

      'deliveryAddress':
      deliveryAddress,

      'landmark':
      landmark,

      'deliveryNote':
      deliveryNote,

      'pincode':
      pincode,

      'customerLatitude':
      customerLatitude,

      'customerLongitude':
      customerLongitude,

      'items':
      items,

      'totalAmount':
      totalAmount,

      'paymentMethod':
      paymentMethod,

      'paymentStatus':
      paymentStatus,

      'transactionId':
      transactionId,

      'deliveryPin':
      deliveryPin,

      'status':
      'PENDING',

      'timestamp':
      FieldValue.serverTimestamp(),
    });
    final adminDocs =
    await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    for (final admin in adminDocs.docs) {

      await _notificationService.createNotification(

        userId: admin.id,

        title: 'New Order Received',

        body:
        '${userData['name'] ?? 'Customer'} placed a new order of ₹$totalAmount',

        type: NotificationTypes.orderPlaced,
      );
    }
  }
}