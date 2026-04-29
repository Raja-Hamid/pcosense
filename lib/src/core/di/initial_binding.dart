import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pcosense/src/core/network/api_client.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/profile/services/user_profile_service.dart';
import 'package:pcosense/src/features/assessment/services/assessment_service.dart';
import 'package:pcosense/src/features/content/services/upload_service.dart';
import 'package:pcosense/src/features/content/services/prediction_service.dart';
import 'package:pcosense/src/features/content/services/recommendation_service.dart';
import 'package:pcosense/src/features/tracker/services/tracker_service.dart';
import 'package:pcosense/src/features/assessment/services/report_pdf_service.dart';

class InitialBinding {
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!Get.isRegistered<SharedPreferences>()) {
      Get.put<SharedPreferences>(prefs, permanent: true);
    }

    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }

    // Register services once.
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }
    if (!Get.isRegistered<UserProfileService>()) {
      Get.put(UserProfileService(), permanent: true);
    }
    if (!Get.isRegistered<AssessmentService>()) {
      Get.put(AssessmentService(), permanent: true);
    }
    if (!Get.isRegistered<UploadService>()) {
      Get.put(UploadService(), permanent: true);
    }
    if (!Get.isRegistered<PredictionService>()) {
      Get.put(PredictionService(), permanent: true);
    }
    if (!Get.isRegistered<RecommendationService>()) {
      Get.put(RecommendationService(), permanent: true);
    }
    if (!Get.isRegistered<TrackerService>()) {
      Get.put(TrackerService(), permanent: true);
    }
    if (!Get.isRegistered<ReportPdfService>()) {
      Get.put(ReportPdfService(), permanent: true);
    }
  }
}

