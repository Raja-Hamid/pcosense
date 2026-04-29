import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/features/assessment/models/assessment_model.dart';

class AssessmentService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AssessmentModel>> getAssessments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('questionnaire_history')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => AssessmentModel.fromJson(doc.data())).toList();
    } catch (e) {
      Get.log('Error fetching assessments: $e');
      throw Exception('Failed to fetch assessment history');
    }
  }

  Future<String> saveAssessment(String userId, AssessmentModel assessment) async {
    try {
      if (assessment.clientRequestId != null && assessment.clientRequestId!.isNotEmpty) {
        final existing = await _firestore
            .collection('users')
            .doc(userId)
            .collection('questionnaire_history')
            .where('clientRequestId', isEqualTo: assessment.clientRequestId)
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          return existing.docs.first.id;
        }
      }

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('questionnaire_history')
          .doc();

      final modelWithId = assessment.copyWith(id: docRef.id);
      
      final payload = modelWithId.toJson();
      payload['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(payload);
      return docRef.id;
    } catch (e) {
      Get.log('Error saving assessment: $e');
      throw Exception('Failed to save assessment');
    }
  }

  Future<void> deleteAssessment(String userId, String assessmentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('questionnaire_history')
          .doc(assessmentId)
          .delete();
    } catch (e) {
      Get.log('Error deleting assessment: $e');
      throw Exception('Failed to delete assessment');
    }
  }
}

