import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:pcosense/src/features/content/models/upload_model.dart';

/// Manages picking ultrasound images and recording an audit row in Firestore.
///
/// Note: this build does NOT push the image bytes to Firebase Storage —
/// the project is on the free Spark plan which does not allow Cloud Storage.
/// The image bytes are sent directly from the device to the local Flask
/// backend in [PredictionService.requestPrediction]; this service only
/// records that an upload happened so the report history can show it.
class UploadService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  static const int _maxBytes = 10 * 1024 * 1024;
  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png'};

  Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2048,
    );
  }

  Future<void> validate(File file) async {
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (ext.isEmpty || !_allowedExtensions.contains(ext)) {
      throw UploadValidationException(
        'Only JPG and PNG ultrasound images are accepted.',
      );
    }
    final size = await file.length();
    if (size <= 0) {
      throw UploadValidationException('Selected file is empty.');
    }
    if (size > _maxBytes) {
      throw UploadValidationException(
        'Image is too large. Max ${_maxBytes ~/ (1024 * 1024)} MB.',
      );
    }
  }

  /// Validates [file] and writes a metadata document under
  /// `users/{uid}/uploads/{id}` for audit. The bytes themselves are not
  /// uploaded anywhere by this service. [onProgress] is invoked once with
  /// `1.0` for UI consistency with the previous Storage-backed flow.
  Future<UploadModel> upload({
    required File file,
    required String uid,
    String? originalFileName,
    String? linkedAssessmentId,
    void Function(double progress)? onProgress,
  }) async {
    await validate(file);

    final uploadsCollection = _firestore
        .collection('users')
        .doc(uid)
        .collection('uploads');
    final docRef = uploadsCollection.doc();
    final uploadId = docRef.id;

    final originalName = originalFileName ?? p.basename(file.path);
    final ext = p.extension(originalName).replaceFirst('.', '').toLowerCase();
    final contentType = _contentTypeForExt(ext);
    final size = await file.length();

    final model = UploadModel(
      id: uploadId,
      fileName: originalName,
      contentType: contentType,
      sizeBytes: size,
      storagePath: null,
      downloadUrl: null,
      uploadStatus: 'completed',
      predictionStatus: 'none',
      linkedAssessmentId: linkedAssessmentId,
      createdAt: DateTime.now(),
    );

    try {
      await docRef.set(model.toJson());
    } catch (e) {
      // Firestore write failed — surface it but don't block the analysis flow.
      Get.log('Upload metadata write failed (non-fatal): $e');
    }

    if (onProgress != null) {
      onProgress(1.0);
    }
    return model;
  }

  Future<void> linkAssessment({
    required String uid,
    required String uploadId,
    required String assessmentId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('uploads')
        .doc(uploadId)
        .update({'linkedAssessmentId': assessmentId});
  }

  String _contentTypeForExt(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}

class UploadValidationException implements Exception {
  UploadValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}
