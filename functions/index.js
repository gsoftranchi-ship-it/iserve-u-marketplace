const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = onDocumentCreated(
    "users/{userId}/notifications/{notificationId}",
    async (event) => {

      const userId = event.params.userId;

      const notification =
        event.data?.data();

      if (!notification) {
        return;
      }

      const userDoc =
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

      if (!userDoc.exists) {
        return;
      }

      const userData =
        userDoc.data();

      const token =
        userData.fcmToken;

      if (!token) {
        console.log(
            "No FCM token found",
        );
        return;
      }

      await admin.messaging().send({
        token: token,

        notification: {
          title: notification.title,
          body: notification.body,
        },

        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            priority: "high",
          },
        },

        apns: {
          headers: {
            "apns-priority": "10",
          },
        },
      });

      console.log(
          "Notification sent to:",
          userId,
      );
    },
);