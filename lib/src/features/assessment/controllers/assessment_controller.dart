import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcosense/src/features/assessment/models/assessment_model.dart';
import 'package:pcosense/src/features/assessment/services/assessment_service.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/profile/services/user_profile_service.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';

class AssessmentController extends GetxController {
  static const _kAssessments = 'pcos_assessments';

  final prefs = Get.find<SharedPreferences>();
  final _service = Get.find<AssessmentService>();
  final _authService = Get.find<AuthService>();
  final _profileService = Get.find<UserProfileService>();

  final assessments = <AssessmentModel>[].obs;

  final loading = false.obs;
  final offline = false.obs;
  final error = ''.obs;
  final warning = ''.obs;
  final operationState =
      'idle'.obs; // idle | loading | success | cachedFallback | failure

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();

    // Listen to Firebase Auth state
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _fetchFromFirestore(user.uid);
      } else {
        assessments.clear();
        prefs.remove(_kAssessments);
        loading.value = false;
        offline.value = false;
        error.value = '';
        warning.value = '';
        operationState.value = 'idle';
      }
    });

    if (_authService.currentUser != null) {
      _fetchFromFirestore(_authService.currentUser!.uid);
    }
  }

  void _loadFromCache() {
    final raw = prefs.getString(_kAssessments);
    if (raw != null) {
      try {
        final decoded = (jsonDecode(raw) as List)
            .cast<Map>()
            .map((e) => AssessmentModel.fromJson(e.cast<String, dynamic>()))
            .toList();
        assessments.assignAll(decoded);
      } catch (e) {
        Get.log('Error parsing cached assessments: $e');
      }
    }
  }

  Future<void> _fetchFromFirestore(String uid) async {
    loading.value = true;
    error.value = '';
    warning.value = '';
    offline.value = false;
    operationState.value = 'loading';

    try {
      final data = await _service.getAssessments(uid);
      assessments.assignAll(data);
      await _persistCache();
      operationState.value = 'success';
    } catch (e) {
      offline.value = true;
      error.value = 'Offline: Showing cached history.';
      operationState.value = 'cachedFallback';
    } finally {
      loading.value = false;
    }
  }

  Future<void> saveAssessment(
    RiskAssessmentResult risk,
    List<QuestionnaireAnswer> answers, {
    String? submissionId,
  }) async {
    loading.value = true;
    error.value = '';
    warning.value = '';
    operationState.value = 'loading';

    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      error.value = 'You must be logged in to save assessments.';
      loading.value = false;
      operationState.value = 'failure';
      return;
    }

    final dateStr = DateTime.now().toIso8601String();
    final draft = AssessmentModel(
      id: '',
      dateIso: dateStr,
      createdAt: DateTime.now(),
      risk: risk,
      answers: answers,
      clientRequestId: submissionId,
    );

    // Phase A: authoritative assessment save.
    String? newId;
    try {
      newId = await _service.saveAssessment(uid, draft);
      final finalModel = draft.copyWith(id: newId);
      _upsertAssessment(finalModel);
      await _persistCache();
      offline.value = false;
      operationState.value = 'success';
    } catch (e) {
      warning.value = 'Cloud save failed. Saved locally for now.';
      offline.value = true;
      operationState.value = 'cachedFallback';

      final fallbackId = submissionId == null || submissionId.isEmpty
          ? 'local_${DateTime.now().millisecondsSinceEpoch}'
          : 'local_$submissionId';
      _upsertAssessment(draft.copyWith(id: fallbackId));
      await _persistCache();
      loading.value = false;
      return;
    }

    // Phase B: best-effort profile metadata sync. Do not fail saved assessment.
    try {
      await _profileService.updateUserProfile(uid, {
        'totalAssessments': FieldValue.increment(1),
        'lastAssessmentDate': dateStr,
        'lastRiskLevel': risk.category,
      });

      // Update Local Auth Controller State for UI
      try {
        final authCtrl = Get.find<AuthController>();
        final curr = authCtrl.user.value;
        if (curr != null) {
          authCtrl.user.value = curr.copyWith(
            totalAssessments: (curr.totalAssessments ?? 0) + 1,
            lastAssessmentDate: dateStr,
            lastRiskLevel: risk.category,
          );
        }
      } catch (_) {}
    } catch (e) {
      warning.value = 'Assessment saved, but profile sync did not complete.';
      Get.log(
        'Profile metadata sync failed after assessment save ($newId): $e',
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteAssessment(String id) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    try {
      loading.value = true;
      // Do not try to delete local-only files from cloud
      if (!id.startsWith('local_')) {
        await _service.deleteAssessment(uid, id);
      }
      assessments.removeWhere((e) => e.id == id);
      await _persistCache();
      offline.value = false;
      operationState.value = 'success';
    } catch (e) {
      error.value = 'Failed to delete assessment.';
      offline.value = true;
      operationState.value = 'failure';
    } finally {
      loading.value = false;
    }
  }

  void _upsertAssessment(AssessmentModel model) {
    final existingIndex = assessments.indexWhere((item) => item.id == model.id);
    if (existingIndex >= 0) {
      assessments[existingIndex] = model;
      return;
    }
    assessments.insert(0, model);
  }

  Future<void> _persistCache() async {
    await prefs.setString(
      _kAssessments,
      jsonEncode(assessments.map((e) => e.toJson()).toList()),
    );
  }
}
