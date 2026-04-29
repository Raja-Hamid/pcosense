import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/assessment/logic/risk_fusion.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/content/models/prediction_model.dart';
import 'package:pcosense/src/features/content/models/upload_model.dart';
import 'package:pcosense/src/features/content/controllers/prediction_controller.dart';
import 'package:pcosense/src/features/content/services/prediction_service.dart';
import 'package:pcosense/src/features/content/services/upload_service.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';

/// Drives the end-to-end ultrasound flow:
///   pick → upload to Firebase Storage → call backend → fuse with latest
///   questionnaire → render a fused result.
class ScanController extends GetxController {
  final UploadService _uploadService = Get.find<UploadService>();
  final PredictionService _predictionService = Get.find<PredictionService>();
  final PredictionController _predictionController =
      Get.find<PredictionController>();
  final AuthService _authService = Get.find<AuthService>();
  final AssessmentController _assessmentController =
      Get.find<AssessmentController>();
  final RiskFusion _fusion = const RiskFusion();

  final Rxn<XFile> selectedFile = Rxn<XFile>();
  final RxString stage = 'idle'.obs; // idle | uploading | predicting | done | error
  final RxDouble uploadProgress = 0.0.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<UploadModel> upload = Rxn<UploadModel>();
  final Rxn<PredictionModel> prediction = Rxn<PredictionModel>();
  final Rxn<FusedRiskResult> fusedResult = Rxn<FusedRiskResult>();

  bool get isBusy => stage.value == 'uploading' || stage.value == 'predicting';
  bool get hasResult => stage.value == 'done' && fusedResult.value != null;
  bool get hasSelectedFile => selectedFile.value != null;
  bool get hasQuestionnaire => _assessmentController.assessments.isNotEmpty;

  Future<void> pickImage() async {
    if (isBusy) return;
    try {
      final picked = await _uploadService.pickFromGallery();
      if (picked == null) return;
      selectedFile.value = picked;
      stage.value = 'idle';
      errorMessage.value = '';
      uploadProgress.value = 0.0;
      upload.value = null;
      prediction.value = null;
      fusedResult.value = null;
    } catch (e) {
      errorMessage.value = 'Could not open the gallery: $e';
      stage.value = 'error';
    }
  }

  void clearSelection() {
    selectedFile.value = null;
    stage.value = 'idle';
    errorMessage.value = '';
    uploadProgress.value = 0.0;
    upload.value = null;
    prediction.value = null;
    fusedResult.value = null;
  }

  Future<void> analyze() async {
    if (isBusy) return;
    final file = selectedFile.value;
    if (file == null) {
      Get.snackbar(
        'Upload required',
        'Please pick an ultrasound image before analyzing.',
      );
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      errorMessage.value = 'You must be signed in to run analysis.';
      stage.value = 'error';
      return;
    }

    final latestAssessment = _assessmentController.assessments.isEmpty
        ? null
        : _assessmentController.assessments.first;

    errorMessage.value = '';
    final ioFile = File(file.path);

    stage.value = 'uploading';
    uploadProgress.value = 0.0;
    UploadModel uploaded;
    try {
      uploaded = await _uploadService.upload(
        file: ioFile,
        uid: uid,
        originalFileName: file.name,
        linkedAssessmentId: latestAssessment?.id,
        onProgress: (p) => uploadProgress.value = p.clamp(0.0, 1.0),
      );
      upload.value = uploaded;
    } on UploadValidationException catch (e) {
      errorMessage.value = e.message;
      stage.value = 'error';
      return;
    } catch (e) {
      errorMessage.value = 'Upload failed: $e';
      stage.value = 'error';
      return;
    }

    stage.value = 'predicting';
    PredictionModel pred;
    try {
      pred = await _predictionService.requestPrediction(
        uid: uid,
        uploadId: uploaded.id,
        imageFile: ioFile,
        assessmentId: latestAssessment?.id,
      );
      prediction.value = pred;
      await _predictionController.registerLocal(pred);
    } on PredictionException catch (e) {
      errorMessage.value = e.message;
      stage.value = 'error';
      return;
    } catch (e) {
      errorMessage.value = 'Prediction failed: $e';
      stage.value = 'error';
      return;
    }

    final baseRisk = latestAssessment?.risk ?? RiskAssessmentResult.fallback();
    fusedResult.value = _fusion.fuse(baseRisk, pred);
    stage.value = 'done';
  }
}
