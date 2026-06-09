import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceProfileService {

  // =========================================================
  // FIRESTORE
  // =========================================================

  static final FirebaseFirestore
  _firestore =
      FirebaseFirestore.instance;

  // =========================================================
  // DEVICE INFO
  // =========================================================

  static final DeviceInfoPlugin
  _deviceInfo =
  DeviceInfoPlugin();

  // =========================================================
  // REGISTER DEVICE
  // =========================================================

  static Future<void>
  registerDevice({

    required String deviceId,

    required String siteId,

    required BuildContext context,

    required String screenType,

    required String controllerType,
  }) async {

    try {

      debugPrint(
        "REGISTERING DEVICE",
      );

      // =====================================
      // SCREEN
      // =====================================

      final mediaQuery =
      MediaQuery.of(context);

      final width =
          mediaQuery.size.width;

      final height =
          mediaQuery.size.height;

      final orientation =

      width > height

          ? "landscape"

          : "portrait";

      final resolution =
          "${width.toInt()}x${height.toInt()}";

      final pixelRatio =
          mediaQuery.devicePixelRatio;

      // =====================================
      // DEVICE INFO
      // =====================================

      final deviceData =
      await _collectDeviceInfo();

      // =====================================
      // SAVE
      // =====================================

      await _firestore
          .collection("devices")
          .doc(deviceId)
          .set({

        // ===================================
        // IDS
        // ===================================

        "deviceId":
        deviceId,

        "siteId":
        siteId,

        // ===================================
        // SCREEN
        // ===================================

        "screenType":
        screenType,

        "controllerType":
        controllerType,

        "resolution":
        resolution,

        "screenWidth":
        width,

        "screenHeight":
        height,

        "pixelRatio":
        pixelRatio,

        "orientation":
        orientation,

        // ===================================
        // PLATFORM
        // ===================================

        "platform":
        deviceData['platform'],

        "isWeb":
        kIsWeb,

        // ===================================
        // DEVICE
        // ===================================

        "brand":
        deviceData['brand'],

        "model":
        deviceData['model'],

        "manufacturer":
        deviceData['manufacturer'],

        "systemVersion":
        deviceData['systemVersion'],

        "sdkVersion":
        deviceData['sdkVersion'],

        "deviceType":
        deviceData['deviceType'],

        // ===================================
        // CAPABILITIES
        // ===================================

        "supportsVideo":
        true,

        "supportsImage":
        true,

        "supportsPortrait":
        true,

        "supportsLandscape":
        true,

        "supportsOffline":
        !kIsWeb,

        "supportsTouch":
        true,

        // ===================================
        // SYSTEM
        // ===================================

        "online":
        true,

        "appVersion":
        "2.0.0",

        "runtime":
        "enterprise_signage",

        "registeredAt":
        FieldValue.serverTimestamp(),

        "lastSeen":
        FieldValue.serverTimestamp(),

        "updatedAt":
        FieldValue.serverTimestamp(),

      },

          SetOptions(
            merge: true,
          ));

      debugPrint(
        "DEVICE REGISTERED",
      );

    } catch (e) {

      debugPrint(
        "DEVICE REGISTER ERROR: $e",
      );
    }
  }

  // =========================================================
  // COLLECT DEVICE INFO
  // =========================================================

  static Future<Map<String, dynamic>>
  _collectDeviceInfo() async {

    try {

      // =====================================
      // WEB
      // =====================================

      if (kIsWeb) {

        final webInfo =
        await _deviceInfo
            .webBrowserInfo;

        return {

          "platform": "web",

          "brand": "browser",

          "model":
          webInfo.browserName.name,

          "manufacturer":
          "web",

          "systemVersion":
          webInfo.appVersion,

          "sdkVersion":
          "",

          "deviceType":
          "browser",
        };
      }

      // =====================================
      // ANDROID
      // =====================================

      switch (
      defaultTargetPlatform
      ) {

        case TargetPlatform.android:

          final android =
          await _deviceInfo
              .androidInfo;

          return {

            "platform": "android",

            "brand":
            android.brand,

            "model":
            android.model,

            "manufacturer":
            android.manufacturer,

            "systemVersion":
            android.version.release,

            "sdkVersion":
            android.version.sdkInt
                .toString(),

            "deviceType":
            "android_device",
          };

      // ===================================
      // IOS
      // ===================================

        case TargetPlatform.iOS:

          final ios =
          await _deviceInfo
              .iosInfo;

          return {

            "platform": "ios",

            "brand": "Apple",

            "model":
            ios.model,

            "manufacturer":
            "Apple",

            "systemVersion":
            ios.systemVersion,

            "sdkVersion":
            ios.systemVersion,

            "deviceType":
            "ios_device",
          };

      // ===================================
      // WINDOWS
      // ===================================

        case TargetPlatform.windows:

          final windows =
          await _deviceInfo
              .windowsInfo;

          return {

            "platform": "windows",

            "brand":
            "Microsoft",

            "model":
            windows.computerName,

            "manufacturer":
            "Microsoft",

            "systemVersion":
            windows.displayVersion,

            "sdkVersion":
            windows.buildLab,

            "deviceType":
            "desktop",
          };

      // ===================================
      // MACOS
      // ===================================

        case TargetPlatform.macOS:

          final mac =
          await _deviceInfo
              .macOsInfo;

          return {

            "platform": "macos",

            "brand": "Apple",

            "model":
            mac.model,

            "manufacturer":
            "Apple",

            "systemVersion":
            mac.osRelease,

            "sdkVersion":
            mac.arch,

            "deviceType":
            "desktop",
          };

      // ===================================
      // LINUX
      // ===================================

        case TargetPlatform.linux:

          final linux =
          await _deviceInfo
              .linuxInfo;

          return {

            "platform": "linux",

            "brand":
            linux.name,

            "model":
            linux.prettyName,

            "manufacturer":
            linux.variant ?? "",

            "systemVersion":
            linux.version ?? "",

            "sdkVersion":
            linux.buildId ?? "",

            "deviceType":
            "desktop",
          };

        default:

          return {

            "platform": "unknown",

            "brand": "",

            "model": "",

            "manufacturer": "",

            "systemVersion": "",

            "sdkVersion": "",

            "deviceType": "unknown",
          };
      }

    } catch (e) {

      debugPrint(
        "DEVICE INFO ERROR: $e",
      );

      return {

        "platform": "unknown",

        "brand": "",

        "model": "",

        "manufacturer": "",

        "systemVersion": "",

        "sdkVersion": "",

        "deviceType": "unknown",
      };
    }
  }

  // =========================================================
  // UPDATE RESOLUTION
  // =========================================================

  static Future<void>
  updateResolution({

    required String deviceId,

    required double width,

    required double height,
  }) async {

    try {

      final orientation =

      width > height

          ? "landscape"

          : "portrait";

      await _firestore
          .collection("devices")
          .doc(deviceId)
          .update({

        "resolution":
        "${width.toInt()}x${height.toInt()}",

        "screenWidth":
        width,

        "screenHeight":
        height,

        "orientation":
        orientation,

        "updatedAt":
        FieldValue.serverTimestamp(),
      });

    } catch (e) {

      debugPrint(
        "UPDATE RESOLUTION ERROR: $e",
      );
    }
  }

  // =========================================================
  // UPDATE ONLINE
  // =========================================================

  static Future<void>
  updateOnlineStatus({

    required String deviceId,

    required bool isOnline,
  }) async {

    try {

      await _firestore
          .collection("devices")
          .doc(deviceId)
          .update({

        "online":
        isOnline,

        "lastSeen":
        FieldValue.serverTimestamp(),

        "updatedAt":
        FieldValue.serverTimestamp(),
      });

    } catch (e) {

      debugPrint(
        "ONLINE STATUS ERROR: $e",
      );
    }
  }

  // =========================================================
  // GET PROFILE
  // =========================================================

  static Future<DocumentSnapshot>
  getDeviceProfile({

    required String deviceId,
  }) async {

    return await _firestore
        .collection("devices")
        .doc(deviceId)
        .get();
  }
}