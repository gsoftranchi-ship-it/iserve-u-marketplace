import 'package:cloud_firestore/cloud_firestore.dart';

class AppVersionService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<String> getRemoteVersion() async {

    final doc =
    await _firestore
        .collection('app_settings')
        .doc('version')
        .get();

    if (!doc.exists) {
      return '1.0.0';
    }

    return doc.data()?['currentVersion']
        ?.toString() ??
        '1.0.0';
  }
}