import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalActions
    extends StatelessWidget {

  final String campaignId;

  const ApprovalActions({

    super.key,

    required this.campaignId,
  });

  Future<void>
  _updateStatus(
      String status,
      ) async {

    await FirebaseFirestore
        .instance

        .collection(
      'campaigns',
    )

        .doc(
      campaignId,
    )

        .update({

      'status': status,

      'updatedAt':
      FieldValue
          .serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        Expanded(

          child:
          ElevatedButton.icon(

            style:
            ElevatedButton
                .styleFrom(

              backgroundColor:
              Colors.green,
            ),

            onPressed: () async {

              await _updateStatus(
                'active',
              );
            },

            icon:
            const Icon(

              Icons.check,

              color:
              Colors.white,
            ),

            label:
            const Text(

              "Approve",

              style:
              TextStyle(

                color:
                Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(

          child:
          ElevatedButton.icon(

            style:
            ElevatedButton
                .styleFrom(

              backgroundColor:
              Colors.red,
            ),

            onPressed: () async {

              await _updateStatus(
                'rejected',
              );
            },

            icon:
            const Icon(

              Icons.close,

              color:
              Colors.white,
            ),

            label:
            const Text(

              "Reject",

              style:
              TextStyle(

                color:
                Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}