class PartnerApplication {

  final String uid;
  final String name;
  final String phone;
  final String email;

  final String applicationType;
  final String status;

  final DateTime createdAt;

  PartnerApplication({

    required this.uid,
    required this.name,
    required this.phone,
    required this.email,

    required this.applicationType,
    required this.status,

    required this.createdAt,
  });

  Map<String, dynamic> toMap() {

    return {

      'uid': uid,

      'name': name,

      'phone': phone,

      'email': email,

      'applicationType':
      applicationType,

      'status':
      status,

      'createdAt':
      createdAt.toIso8601String(),
    };
  }

  factory PartnerApplication.fromMap(
      Map<String, dynamic> map) {

    return PartnerApplication(

      uid:
      map['uid'] ?? '',

      name:
      map['name'] ?? '',

      phone:
      map['phone'] ?? '',

      email:
      map['email'] ?? '',

      applicationType:
      map['applicationType'] ?? '',

      status:
      map['status'] ?? '',

      createdAt:
      DateTime.tryParse(
        map['createdAt'] ?? '',
      ) ??
          DateTime.now(),
    );
  }
}