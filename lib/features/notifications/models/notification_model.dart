class AppNotification {

  final String title;
  final String body;
  final String type;
  final DateTime createdAt;

  AppNotification({

    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {

    return {

      'title': title,
      'body': body,
      'type': type,
      'createdAt':
      createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(
      Map<String, dynamic> map) {

    return AppNotification(

      title: map['title'] ?? '',

      body: map['body'] ?? '',

      type: map['type'] ?? '',

      createdAt:
      DateTime.tryParse(
        map['createdAt'] ?? '',
      ) ??
          DateTime.now(),
    );
  }
}