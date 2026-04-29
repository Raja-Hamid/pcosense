import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/features/content/models/personalized_plan_model.dart';

class RecommendationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stored at `users/{uid}/recommendations/{assessmentId}` so each
  /// assessment owns one plan and re-generation is idempotent.
  Future<void> savePlan(String uid, PersonalizedPlan plan) async {
    if (plan.assessmentId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .doc(plan.assessmentId)
        .set(plan.toJson());
  }

  Future<PersonalizedPlan?> getPlanForAssessment(
    String uid,
    String assessmentId,
  ) async {
    if (assessmentId.isEmpty) return null;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .doc(assessmentId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return PersonalizedPlan.fromJson(doc.data()!);
  }
}
