import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 🔹 GENERIC UPLOAD HELPER (Dry Logic)
  Future<String> _uploadFile(
      XFile file, String folder, String ext, String contentType, Function(double) onProgress) async {

    final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";
    final ref = _storage.ref().child("$folder/$fileName");

    final metadata = SettableMetadata(contentType: contentType);
    UploadTask uploadTask;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      uploadTask = ref.putData(bytes, metadata);
    } else {
      uploadTask = ref.putFile(File(file.path), metadata);
    }

    uploadTask.snapshotEvents.listen((event) {
      if (event.totalBytes > 0) {
        onProgress(event.bytesTransferred / event.totalBytes);
      }
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadImageWithProgress(XFile file, Function(double) onProgress) =>
      _uploadFile(file, "ads_images", "jpg", "image/jpeg", onProgress);

  Future<String> uploadVideoWithProgress(XFile file, Function(double) onProgress) =>
      _uploadFile(file, "ads_videos", "mp4", "video/mp4", onProgress);
}
