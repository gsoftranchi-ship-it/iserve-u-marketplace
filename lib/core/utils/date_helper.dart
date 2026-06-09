import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? parseFirestoreDate(dynamic value) {

  if (value == null) {
    return null;
  }

  // Firestore Timestamp
  if (value is Timestamp) {
    return value.toDate();
  }

  // Already DateTime
  if (value is DateTime) {
    return value;
  }

  // Milliseconds int
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  // String date
  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}