import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAdsService {

  final CollectionReference _ads =

  FirebaseFirestore.instance
      .collection('ads');

  // =========================================================
  // ADD AD
  // =========================================================

  Future<void> addAd(
      Map<String, dynamic> ad,
      ) async {

    // =============================================
    // SERVER TIMESTAMP
    // =============================================

    ad['timestamp'] =
        FieldValue.serverTimestamp();

    // =============================================
    // DO NOT OVERRIDE STATUS
    // =============================================

    // status now comes directly
    // from upload flow:
    //
    // pending_approval
    // active
    // rejected
    //
    // So NEVER force:
    // ad['status']='active'

    await _ads.add(ad);
  }

  // =========================================================
  // ACTIVE ADS STREAM
  // =========================================================

  Stream<QuerySnapshot> getAdsStream() {

    return _ads

        .where(
      'status',
      isEqualTo: 'active',
    )

        .orderBy(
      'timestamp',
      descending: true,
    )

        .snapshots();
  }

  // =========================================================
  // SINGLE AD
  // =========================================================

  Future<DocumentSnapshot> getAdById(
      String id,
      ) async {

    return await _ads
        .doc(id)
        .get();
  }

  // =========================================================
  // UPDATE STATUS
  // =========================================================

  Future<void> updateAdStatus(

      String id,
      String status,
      ) async {

    await _ads.doc(id).update({

      'status': status,

      'updatedAt':
      FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // DELETE AD
  // =========================================================

  Future<void> deleteAd(
      String id,
      ) async {

    await _ads.doc(id).delete();
  }
}