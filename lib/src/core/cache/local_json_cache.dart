import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Tiny helper to persist/restore a single JSON-serialisable value (Map or List)
/// to SharedPreferences. Centralises the encode/decode boilerplate so each
/// controller doesn't reinvent it.
class LocalJsonCache {
  const LocalJsonCache(this._prefs);

  final SharedPreferences _prefs;

  Map<String, dynamic>? readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>>? readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> writeJson(String key, Object value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
