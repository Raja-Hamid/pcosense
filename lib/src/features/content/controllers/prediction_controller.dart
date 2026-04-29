import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcosense/src/core/cache/local_json_cache.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/content/models/prediction_model.dart';
import 'package:pcosense/src/features/content/services/prediction_service.dart';

/// Reactive list of recent predictions for the current user with offline-first
/// caching, mirroring the pattern in [AssessmentController].
class PredictionController extends GetxController {
  static const _kCacheKey = 'pcos_predictions';

  final AuthService _authService = Get.find<AuthService>();
  final PredictionService _service = Get.find<PredictionService>();
  late final LocalJsonCache _cache = LocalJsonCache(Get.find<SharedPreferences>());

  final RxList<PredictionModel> predictions = <PredictionModel>[].obs;
  final RxBool loading = false.obs;
  final RxBool offline = false.obs;
  final RxString warning = ''.obs;

  PredictionModel? findByAssessmentId(String assessmentId) {
    if (assessmentId.isEmpty) return null;
    final matches = predictions.where((p) => p.assessmentId == assessmentId).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) {
      final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    return matches.first;
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();

    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _refresh(user.uid);
      } else {
        predictions.clear();
        offline.value = false;
        warning.value = '';
        _cache.remove(_kCacheKey);
      }
    });

    final current = _authService.currentUser;
    if (current != null) {
      _refresh(current.uid);
    }
  }

  void _loadFromCache() {
    final raw = _cache.readList(_kCacheKey);
    if (raw == null) return;
    try {
      predictions.assignAll(
        raw.map((m) => PredictionModel.fromJson(m['_id'] as String? ?? '', m)).toList(),
      );
    } catch (e) {
      Get.log('Failed to parse cached predictions: $e');
    }
  }

  Future<void> _persist() async {
    final list = predictions
        .map((p) => {
              ...p.toJson(),
              '_id': p.id,
            })
        .toList();
    await _cache.writeJson(_kCacheKey, list);
  }

  Future<void> _refresh(String uid) async {
    if (loading.value) return;
    loading.value = true;
    warning.value = '';
    try {
      final remote = await _service.getPredictionsForUser(uid);
      predictions.assignAll(remote);
      offline.value = false;
      await _persist();
    } catch (e) {
      offline.value = true;
      warning.value = 'Showing cached predictions.';
      Get.log('Prediction fetch failed: $e');
    } finally {
      loading.value = false;
    }
  }

  /// Adds a freshly produced prediction (e.g. right after the scan flow
  /// completes) to the local list and persists the cache.
  Future<void> registerLocal(PredictionModel prediction) async {
    final idx = predictions.indexWhere((p) => p.id == prediction.id);
    if (idx >= 0) {
      predictions[idx] = prediction;
    } else {
      predictions.insert(0, prediction);
    }
    await _persist();
  }

  Future<void> refreshNow() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _refresh(uid);
  }
}
