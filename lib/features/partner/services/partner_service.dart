import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/partner_application_model.dart';

class PartnerService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> submitApplication({

    required String applicationType,
  }) async {

    final user =
        _auth.currentUser;

    if (user == null) {

      throw Exception(
        'User not logged in',
      );
    }

    final profileDoc =
    await _firestore
        .collection('profiles')
        .doc(user.uid)
        .get();

    if (!profileDoc.exists) {

      throw Exception(
        'Profile not found',
      );
    }

    final profile =
        profileDoc.data() ?? {};
    final existingApplication =
    await _firestore
        .collection(
        'partner_applications')
        .where(
      'uid',
      isEqualTo: user.uid,
    )
        .where(
      'applicationType',
      isEqualTo: applicationType,
    )
        .where(
      'status',
      isEqualTo: 'pending',
    )
        .limit(1)
        .get();

    if (existingApplication.docs
        .isNotEmpty) {

      throw Exception(

        'Your application is already under review.',
      );
    }

    final application =
    PartnerApplication(

      uid: user.uid,

      name:
      profile['name'] ?? '',

      phone:
      profile['phone'] ?? '',

      email:
      profile['email'] ?? '',

      applicationType:
      applicationType,

      status:
      'pending',

      createdAt:
      DateTime.now(),
    );

    await _firestore
        .collection(
        'partner_applications')
        .add(
      application.toMap(),
    );
  }
}