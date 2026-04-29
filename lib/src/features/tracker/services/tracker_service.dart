import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/features/tracker/models/symptom_log_model.dart';

class TrackerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _logsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('symptom_logs');
  }

  Future<List<SymptomLogModel>> getLogs(String uid, {int limit = 100}) async {
    final snap = await _logsCollection(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      return SymptomLogModel.fromJson(data);
    }).toList();
  }

  Future<String> saveLog(String uid, SymptomLogModel log) async {
    final col = _logsCollection(uid);
    final docRef = log.id.isEmpty ? col.doc() : col.doc(log.id);
    final payload = <String, dynamic>{
      ...log.toJson(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await docRef.set(payload);
    return docRef.id;
  }

  Future<void> deleteLog(String uid, String id) async {
    if (id.isEmpty) return;
    await _logsCollection(uid).doc(id).delete();
  }
}
