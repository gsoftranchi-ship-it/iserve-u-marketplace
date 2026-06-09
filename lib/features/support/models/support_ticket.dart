class SupportTicket {

  final String userId;
  final String userName;
  final String role;

  final String category;
  final String message;

  final String status;

  SupportTicket({

    required this.userId,
    required this.userName,
    required this.role,

    required this.category,
    required this.message,

    required this.status,
  });

  Map<String, dynamic> toMap() {

    return {

      'userId': userId,
      'userName': userName,
      'role': role,

      'category': category,
      'message': message,

      'status': status,
      'createdAt': DateTime.now(),
    };
  }
}