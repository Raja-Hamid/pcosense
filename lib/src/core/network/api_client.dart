import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'api_endpoints.dart';

/// Thin wrapper around [Dio] for the PCOSense local inference backend.
///
/// Base URL is provided at compile time via `--dart-define=BACKEND_URL=...`.
/// Sensible defaults:
///   - Android emulator → `http://10.0.2.2:5000` (special host that maps to
///     the host machine's `localhost`)
///   - iOS simulator    → `http://localhost:5000`
///   - Real device      → pass `--dart-define=BACKEND_URL=http://<computer-ip>:5000`
class ApiClient extends GetxService {
  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  final String _baseUrl;

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Get.log('[api] → ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          Get.log('[api] ← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (e, handler) {
          Get.log('[api] ✗ ${e.requestOptions.uri} → ${e.message}');
          handler.next(e);
        },
      ),
    );

  String get baseUrl => _baseUrl;

  Future<bool> isReachable() async {
    try {
      final res = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.health,
        options: Options(receiveTimeout: const Duration(seconds: 4)),
      );
      return res.statusCode == 200 && res.data?['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
