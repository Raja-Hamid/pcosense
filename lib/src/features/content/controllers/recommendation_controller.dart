import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/assessment/logic/risk_fusion.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/content/logic/recommendation_engine.dart';
import 'package:pcosense/src/features/content/models/personalized_plan_model.dart';
import 'package:pcosense/src/features/content/services/prediction_service.dart';
import 'package:pcosense/src/features/content/services/recommendation_service.dart';

class RecommendationController extends GetxController {
  static const _kPlanCacheKey = 'pcos_latest_plan';

  final AssessmentController _assessmentController =
      Get.find<AssessmentController>();
  final PredictionService _predictionService = Get.find<PredictionService>();
  final RecommendationService _service = Get.find<RecommendationService>();
  final AuthService _authService = Get.find<AuthService>();
  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  final RecommendationEngine _engine = const RecommendationEngine();
  final RiskFusion _fusion = const RiskFusion();

  final Rxn<PersonalizedPlan> plan = Rxn<PersonalizedPlan>();
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get hasAssessment => _assessmentController.assessments.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    refreshForLatest();
  }

  void _loadFromCache() {
    final raw = _prefs.getString(_kPlanCacheKey);
    if (raw == null) return;
    try {
      plan.value = PersonalizedPlan.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      Get.log('Failed to parse cached plan: $e');
    }
  }

  Future<void> _writeCache(PersonalizedPlan p) async {
    await _prefs.setString(_kPlanCacheKey, jsonEncode(p.toJson()));
  }

  Future<void> refreshForLatest() async {
    if (loading.value) return;
    if (_assessmentController.assessments.isEmpty) {
      plan.value = null;
      return;
    }

    loading.value = true;
    errorMessage.value = '';

    try {
      final latest = _assessmentController.assessments.first;
      final uid = _authService.currentUser?.uid;

      // 1) Try cached server plan first.
      if (uid != null) {
        try {
          final remote = await _service.getPlanForAssessment(uid, latest.id);
          if (remote != null) {
            plan.value = remote;
            await _writeCache(remote);
          }
        } catch (e) {
          Get.log('Failed to fetch remote plan: $e');
        }
      }

      // 2) Generate locally + persist (best effort).
      final prediction = uid == null
          ? null
          : await _predictionService
              .getLatestForAssessment(uid, latest.id)
              .catchError((_) => null);
      final fused = _fusion.fuse(latest.risk, prediction);
      final generated = _engine.generate(assessment: latest, fused: fused);
      plan.value = generated;
      await _writeCache(generated);

      if (uid != null) {
        try {
          await _service.savePlan(uid, generated);
        } catch (e) {
          Get.log('Failed to save plan to Firestore: $e');
        }
      }
    } catch (e) {
      errorMessage.value = 'Could not generate recommendations: $e';
    } finally {
      loading.value = false;
    }
  }
}
