import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createTicket({

    required String category,
    required String message,
  }) async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final userDoc =
    await _firestore
        .collection('profiles')
        .doc(user.uid)
        .get();

    final userData =
        userDoc.data() ?? {};

    await _firestore
        .collection('support_tickets')
        .add({

      'userId': user.uid,

      'userName':
      userData['name'] ?? '',

      'role':
      userData['role'] ?? '',

      'category': category,

      'message': message,

      'status': 'OPEN',

      'createdAt':
      FieldValue.serverTimestamp(),
    });
  }
}