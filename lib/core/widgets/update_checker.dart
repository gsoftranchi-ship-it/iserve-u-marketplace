import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/app_version_service.dart';
import '../utils/web_refresh.dart';
class UpdateChecker {

  static const String currentVersion =
      '1.0.4';

  static Future<void> checkForUpdates(
      BuildContext context) async {

    try {

      final remoteVersion =
      await AppVersionService()
          .getRemoteVersion();


      if (remoteVersion ==
          currentVersion) {
        return;
      }

      if (!context.mounted) return;

      showDialog(

        context: context,

        barrierDismissible: false,

        builder: (_) {

          return AlertDialog(

            title: const Text(
              '🚀 New Update Available',
            ),

            content: Text(

              'Current Version: $currentVersion\n'
                  'Latest Version: $remoteVersion\n\n'
                  'Please refresh to continue with the latest update.',
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);
                },

                child: const Text(
                  'Later',
                ),
              ),

              ElevatedButton(

                onPressed: () {

                  _handleUpdate();
                },

                child: Text(
                  kIsWeb
                      ? 'Update Now'
                      : 'Re-download App',
                ),
              ),
            ],
          );
        },
      );

    } catch (e) {

      debugPrint(
        'Update Check Error: $e',
      );
    }
  }

  static void _handleUpdate() {

    if (kIsWeb) {

      refreshWebPage();

      return;
    }
  }
}