import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:pcosense/src/core/network/api_client.dart';
import 'package:pcosense/src/core/network/api_endpoints.dart';
import 'package:pcosense/src/features/content/models/prediction_model.dart';

class PredictionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiClient _api = Get.find<ApiClient>();

  Future<PredictionModel> requestPrediction({
    required String uid,
    required String uploadId,
    required File imageFile,
    String? assessmentId,
  }) async {
    final predictionsCollection = _firestore
        .collection('users')
        .doc(uid)
        .collection('predictions');
    final docRef = predictionsCollection.doc();
    final predictionId = docRef.id;

    final pending = PredictionModel(
      id: predictionId,
      status: 'pending',
      uploadId: uploadId,
      assessmentId: assessmentId,
      source: 'vgg19-server',
      createdAt: DateTime.now(),
    );
    await docRef.set(pending.toJson());
    await _setUploadPredictionStatus(uid, uploadId, 'pending');

    try {
      final formData = dio.FormData.fromMap({
        'uid': uid,
        'uploadId': uploadId,
        'image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: p.basename(imageFile.path),
        ),
      });

      final response = await _api.dio.post<Map<String, dynamic>>(
        ApiEndpoints.predict,
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data == null || data['label'] == null) {
        throw const PredictionException('Empty response from inference server.');
      }

      final completed = pending.copyWith(
        status: 'completed',
        resultCategory: data['label'] as String,
        confidence: (data['confidence'] as num?)?.toDouble(),
        probInfected: (data['probInfected'] as num?)?.toDouble(),
        modelVersion: data['modelVersion'] as String?,
        latencyMs: (data['latencyMs'] as num?)?.toInt(),
      );
      await docRef.set(completed.toJson());
      await _setUploadPredictionStatus(uid, uploadId, 'completed');
      return completed;
    } on dio.DioException catch (e) {
      final message = _humanReadable(e);
      final failed = pending.copyWith(status: 'failed', errorMessage: message);
      await docRef.set(failed.toJson());
      await _setUploadPredictionStatus(uid, uploadId, 'failed');
      throw PredictionException(message);
    } catch (e) {
      final failed = pending.copyWith(status: 'failed', errorMessage: e.toString());
      await docRef.set(failed.toJson());
      await _setUploadPredictionStatus(uid, uploadId, 'failed');
      throw PredictionException(e.toString());
    }
  }

  Future<List<PredictionModel>> getPredictionsForUser(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('predictions')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PredictionModel.fromJson(d.id, d.data()))
        .toList();
  }

  Future<PredictionModel?> getLatestForAssessment(
    String uid,
    String assessmentId,
  ) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('predictions')
        .where('assessmentId', isEqualTo: assessmentId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return PredictionModel.fromJson(doc.id, doc.data());
  }

  Future<void> _setUploadPredictionStatus(
    String uid,
    String uploadId,
    String predictionStatus,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('uploads')
          .doc(uploadId)
          .update({'predictionStatus': predictionStatus});
    } catch (e) {
      Get.log('Failed to update upload predictionStatus: $e');
    }
  }

  String _humanReadable(dio.DioException e) {
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        return 'Inference server timed out. Make sure the backend is running.';
      case dio.DioExceptionType.connectionError:
        return 'Cannot reach the inference server at ${_api.baseUrl}. Is it running?';
      case dio.DioExceptionType.badResponse:
        final body = e.response?.data;
        if (body is Map && body['message'] is String) {
          return body['message'] as String;
        }
        return 'Inference server returned ${e.response?.statusCode}.';
      default:
        return e.message ?? 'Unknown error talking to inference server.';
    }
  }
}

class PredictionException implements Exception {
  const PredictionException(this.message);
  final String message;

  @override
  String toString() => message;
}
