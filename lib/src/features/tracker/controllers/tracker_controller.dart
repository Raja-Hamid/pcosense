import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/tracker/models/symptom_log_model.dart';
import 'package:pcosense/src/features/tracker/services/tracker_service.dart';

class TrackerController extends GetxController {
  static const _kLogsCacheKey = 'pcos_symptom_logs';
  static const _kTasksCacheKey = 'pcos_tracker_tasks';

  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  final TrackerService _service = Get.find<TrackerService>();
  final AuthService _authService = Get.find<AuthService>();

  final symptomLogs = <SymptomLogModel>[].obs;
  final selectedSymptoms = <String>{}.obs;
  final completedTasks = <String>{'water'}.obs;

  final RxBool loading = false.obs;
  final RxBool offline = false.obs;
  final RxString warning = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    _restoreCompletedTasks();

    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _fetchFromFirestore(user.uid);
      } else {
        symptomLogs.clear();
        selectedSymptoms.clear();
        completedTasks
          ..clear()
          ..add('water');
        offline.value = false;
        warning.value = '';
        _prefs.remove(_kLogsCacheKey);
      }
    });

    final current = _authService.currentUser;
    if (current != null) {
      _fetchFromFirestore(current.uid);
    }
  }

  void _loadFromCache() {
    final raw = _prefs.getString(_kLogsCacheKey);
    if (raw == null) return;
    try {
      final decoded = (jsonDecode(raw) as List)
          .cast<Map>()
          .map((e) => SymptomLogModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      symptomLogs.assignAll(decoded);
    } catch (e) {
      Get.log('Failed to parse cached symptom logs: $e');
    }
  }

  void _restoreCompletedTasks() {
    final raw = _prefs.getString(_kTasksCacheKey);
    if (raw == null) return;
    try {
      final stored = (jsonDecode(raw) as Map<String, dynamic>);
      final dateIso = stored['date'] as String?;
      final today = _isoDateOnly(DateTime.now());
      if (dateIso != today) return; // tasks reset each day
      final tasks = ((stored['tasks'] as List?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toSet();
      if (tasks.isNotEmpty) {
        completedTasks
          ..clear()
          ..addAll(tasks);
      }
    } catch (e) {
      Get.log('Failed to restore completed tasks: $e');
    }
  }

  Future<void> _persistCompletedTasks() async {
    await _prefs.setString(
      _kTasksCacheKey,
      jsonEncode({
        'date': _isoDateOnly(DateTime.now()),
        'tasks': completedTasks.toList(),
      }),
    );
  }

  Future<void> _persistLogs() async {
    await _prefs.setString(
      _kLogsCacheKey,
      jsonEncode(symptomLogs.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _fetchFromFirestore(String uid) async {
    loading.value = true;
    warning.value = '';
    try {
      final remote = await _service.getLogs(uid);
      symptomLogs.assignAll(remote);
      offline.value = false;
      await _persistLogs();
    } catch (e) {
      offline.value = true;
      warning.value = 'Showing locally cached symptom logs.';
      Get.log('Tracker fetch failed: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> toggleTask(String id) async {
    if (completedTasks.contains(id)) {
      completedTasks.remove(id);
    } else {
      completedTasks.add(id);
    }
    await _persistCompletedTasks();
  }

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
  }

  Future<void> saveTodayLog({String notes = ''}) async {
    if (selectedSymptoms.isEmpty) return;
    final uid = _authService.currentUser?.uid;
    final localId = uid == null
        ? 'local_${DateTime.now().millisecondsSinceEpoch}'
        : '';

    final draft = SymptomLogModel(
      id: localId,
      dateIso: DateTime.now().toIso8601String(),
      symptoms: selectedSymptoms.toList(),
      notes: notes,
    );

    if (uid == null) {
      _upsert(draft);
      await _persistLogs();
      warning.value = 'Saved locally — sign in to sync.';
      return;
    }

    try {
      final firestoreId = await _service.saveLog(uid, draft);
      final saved = SymptomLogModel(
        id: firestoreId,
        dateIso: draft.dateIso,
        symptoms: draft.symptoms,
        notes: draft.notes,
      );
      _upsert(saved);
      offline.value = false;
      warning.value = '';
    } catch (e) {
      final fallback = SymptomLogModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        dateIso: draft.dateIso,
        symptoms: draft.symptoms,
        notes: draft.notes,
      );
      _upsert(fallback);
      offline.value = true;
      warning.value = 'Cloud save failed. Saved locally for now.';
      Get.log('Tracker save failed: $e');
    } finally {
      await _persistLogs();
      selectedSymptoms.clear();
    }
  }

  Future<void> deleteLog(String id) async {
    final uid = _authService.currentUser?.uid;
    if (uid != null && !id.startsWith('local_')) {
      try {
        await _service.deleteLog(uid, id);
      } catch (e) {
        Get.log('Tracker delete failed: $e');
      }
    }
    symptomLogs.removeWhere((log) => log.id == id);
    await _persistLogs();
  }

  void _upsert(SymptomLogModel log) {
    final idx = symptomLogs.indexWhere((existing) => existing.id == log.id);
    if (idx >= 0) {
      symptomLogs[idx] = log;
      return;
    }
    symptomLogs.insert(0, log);
    if (symptomLogs.length > 100) {
      symptomLogs.removeRange(100, symptomLogs.length);
    }
  }

  String _isoDateOnly(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
