import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<bool> isProfileComplete() async {

    final currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      return false;
    }

    final doc =
    await _firestore
        .collection('profiles')
        .doc(currentUser.uid)
        .get();

    if (!doc.exists) {
      return false;
    }

    final data =
        doc.data() ?? {};

    final name =
    (data['name'] ?? '')
        .toString()
        .trim();

    final phone =
    (data['phone'] ?? '')
        .toString()
        .trim();

    final address =
    (data['address'] ?? '')
        .toString()
        .trim();

    final pincode =
    (data['pincode'] ?? '')
        .toString()
        .trim();

    return
      name.isNotEmpty &&
          phone.length >= 10 &&
          address.isNotEmpty &&
          pincode.length == 6;
  }
}