import 'package:flutter/material.dart';

import '../services/profile_service.dart';

class ProfileGuard {

  static Future<bool>
  checkProfileCompletion(
      BuildContext context,
      ) async {

    final service =
    ProfileService();

    final isComplete =
    await service
        .isProfileComplete();

    if (isComplete) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

     await showDialog(

          context: context,

          builder: (dialogContext) {

            return AlertDialog(

              title: const Text(
                "Profile Incomplete",
              ),

              content: const Text(

                "Please complete your profile details (Name, Phone, Address and Pincode) before placing an order or applying as a partner.",
              ),

              actions: [

                TextButton(

                  onPressed: () {

                    Navigator.pop(
                      dialogContext,
                    );
                  },

                  child: const Text(
                    "OK",
                  ),
                ),
              ],
            );
          },
        );

    return false;
  }
}