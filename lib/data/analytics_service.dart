import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {

  static final _db =
      FirebaseFirestore.instance;

  // =====================================
  // AD VIEW
  // =====================================

  static Future<void> recordView(
      String campaignId,
      ) async {

    await _db
        .collection('campaigns')
        .doc(campaignId)
        .set({

      'totalViews':
      FieldValue.increment(1),

      'lastViewedAt':
      FieldValue.serverTimestamp(),

    }, SetOptions(
      merge: true,
    ));
  }

  // =====================================
  // PHONE CLICK
  // =====================================

  static Future<void> recordPhoneClick(
      String campaignId,
      ) async {

    await _db
        .collection('campaigns')
        .doc(campaignId)
        .set({

      'phoneClicks':
      FieldValue.increment(1),

    }, SetOptions(
      merge: true,
    ));
  }

  // =====================================
  // WHATSAPP CLICK
  // =====================================

  static Future<void> recordWhatsappClick(
      String campaignId,
      ) async {

    await _db
        .collection('campaigns')
        .doc(campaignId)
        .set({

      'whatsappClicks':
      FieldValue.increment(1),

    }, SetOptions(
      merge: true,
    ));
  }
}