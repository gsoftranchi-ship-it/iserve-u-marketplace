import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/campaign_model.dart';
import '../models/media_asset_model.dart';

class CampaignService {

  // =========================================================
  // FIRESTORE
  // =========================================================

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference
  _campaigns =
  _firestore.collection('campaigns');

  // =========================================================
  // CREATE CAMPAIGN
  // =========================================================

  static Future<String?>
  createCampaign({

    required CampaignModel campaign,
  }) async {

    try {

      final doc =
      await _campaigns.add(
        campaign.toMap(),
      );

      debugPrint(
        "CAMPAIGN CREATED: ${doc.id}",
      );

      return doc.id;

    } catch (e) {

      debugPrint(
        "CREATE CAMPAIGN ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // UPDATE CAMPAIGN
  // =========================================================

  static Future<bool>
  updateCampaign({

    required String campaignId,

    required Map<String, dynamic>
    data,
  }) async {

    try {

      data['updatedAt'] =
          FieldValue.serverTimestamp();

      await _campaigns
          .doc(campaignId)
          .update(data);

      debugPrint(
        "CAMPAIGN UPDATED",
      );

      return true;

    } catch (e) {

      debugPrint(
        "UPDATE CAMPAIGN ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // DELETE CAMPAIGN
  // =========================================================

  static Future<bool>
  deleteCampaign({

    required String campaignId,
  }) async {

    try {

      // =====================================
      // DELETE MEDIA ASSETS
      // =====================================

      final assets =
      await _campaigns
          .doc(campaignId)
          .collection('media_assets')
          .get();

      for (final doc in assets.docs) {

        await doc.reference.delete();
      }

      // =====================================
      // DELETE CAMPAIGN
      // =====================================

      await _campaigns
          .doc(campaignId)
          .delete();

      debugPrint(
        "CAMPAIGN DELETED",
      );

      return true;

    } catch (e) {

      debugPrint(
        "DELETE CAMPAIGN ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // GET SINGLE CAMPAIGN
  // =========================================================

  static Future<CampaignModel?>
  getCampaign({

    required String campaignId,
  }) async {

    try {

      final doc =
      await _campaigns
          .doc(campaignId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return CampaignModel.fromMap(

        doc.id,

        doc.data()
        as Map<String, dynamic>,
      );

    } catch (e) {

      debugPrint(
        "GET CAMPAIGN ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // USER CAMPAIGNS
  // =========================================================

  static Stream<List<CampaignModel>>
  getUserCampaigns({

    required String ownerId,
  }) {

    return _campaigns

        .where(
      'ownerId',
      isEqualTo: ownerId,
    )

        .orderBy(
      'createdAt',
      descending: true,
    )

        .snapshots()

        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return CampaignModel.fromMap(

          doc.id,

          doc.data()
          as Map<String, dynamic>,
        );

      }).toList();
    });
  }

  // =========================================================
  // SITE CAMPAIGNS
  // =========================================================

  static Future<List<CampaignModel>>
  getSiteCampaigns({

    required String siteId,
  }) async {

    try {

      debugPrint(
        "QUERY SITE => $siteId",
      );

      final snapshot =
      await _campaigns

          .where(
        'status',
        isEqualTo: 'active',
      )

          .where(
        'isActive',
        isEqualTo: true,
      )

          .where(
        'siteIds',
        arrayContains: siteId,
      )

          .get();

      debugPrint(
        "CAMPAIGNS FOUND: "
            "${snapshot.docs.length}",
      );

      for (final doc in snapshot.docs) {

        debugPrint(
          "CAMPAIGN DATA => "
              "${doc.data()}",
        );
      }

      final campaigns =
      snapshot.docs.map((doc) {

        return CampaignModel.fromMap(

          doc.id,

          doc.data()
          as Map<String, dynamic>,
        );

      }).toList();

      // =====================================
      // FILTER VALID CAMPAIGNS
      // =====================================

      return campaigns.where(

            (campaign) => campaign.canRun,
      ).toList();

    } catch (e) {

      debugPrint(
        "GET SITE CAMPAIGNS ERROR: $e",
      );

      return [];
    }
  }

  // =========================================================
  // APPROVE CAMPAIGN
  // =========================================================

  static Future<bool>
  approveCampaign({

    required String campaignId,
  }) async {

    try {

      await _campaigns
          .doc(campaignId)
          .update({

        'status': 'active',

        'isActive': true,

        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      debugPrint(
        "CAMPAIGN APPROVED",
      );

      return true;

    } catch (e) {

      debugPrint(
        "APPROVE CAMPAIGN ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // REJECT CAMPAIGN
  // =========================================================

  static Future<bool>
  rejectCampaign({

    required String campaignId,
  }) async {

    try {

      await _campaigns
          .doc(campaignId)
          .update({

        'status': 'rejected',

        'isActive': false,

        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      debugPrint(
        "CAMPAIGN REJECTED",
      );

      return true;

    } catch (e) {

      debugPrint(
        "REJECT CAMPAIGN ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // PAUSE CAMPAIGN
  // =========================================================

  static Future<bool>
  pauseCampaign({

    required String campaignId,
  }) async {

    try {

      await _campaigns
          .doc(campaignId)
          .update({

        'status': 'paused',

        'isActive': false,

        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      debugPrint(
        "CAMPAIGN PAUSED",
      );

      return true;

    } catch (e) {

      debugPrint(
        "PAUSE CAMPAIGN ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // ADD MEDIA ASSET
  // =========================================================

  static Future<String?>
  addMediaAsset({

    required String campaignId,

    required MediaAssetModel asset,
  }) async {

    try {

      final doc =
      await _campaigns

          .doc(campaignId)

          .collection('media_assets')

          .add(
        asset.toMap(),
      );

      debugPrint(
        "MEDIA ASSET ADDED",
      );

      return doc.id;

    } catch (e) {

      debugPrint(
        "ADD MEDIA ASSET ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // GET CAMPAIGN ASSETS
  // =========================================================

  static Future<List<MediaAssetModel>>
  getCampaignAssets({

    required String campaignId,
  }) async {

    try {

      final snapshot =
      await _campaigns

          .doc(campaignId)

          .collection('media_assets')

          .where(
        'isActive',
        isEqualTo: true,
      )

          .orderBy(
        'sortOrder',
      )

          .get();

      return snapshot.docs.map((doc) {

        return MediaAssetModel.fromMap(

          doc.id,

          doc.data(),
        );

      }).toList();

    } catch (e) {

      debugPrint(
        "GET CAMPAIGN ASSETS ERROR: $e",
      );

      return [];
    }
  }

  // =========================================================
  // DELETE MEDIA ASSET
  // =========================================================

  static Future<bool>
  deleteMediaAsset({

    required String campaignId,

    required String assetId,
  }) async {

    try {

      await _campaigns

          .doc(campaignId)

          .collection('media_assets')

          .doc(assetId)

          .delete();

      debugPrint(
        "MEDIA ASSET DELETED",
      );

      return true;

    } catch (e) {

      debugPrint(
        "DELETE MEDIA ASSET ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // UPDATE ANALYTICS
  // =========================================================

  static Future<void>
  incrementCampaignPlay({

    required String campaignId,
  }) async {

    try {

      await _campaigns
          .doc(campaignId)
          .update({

        'totalPlays':
        FieldValue.increment(1),

        'totalImpressions':
        FieldValue.increment(1),
      });

    } catch (e) {

      debugPrint(
        "ANALYTICS UPDATE ERROR: $e",
      );
    }
  }
}