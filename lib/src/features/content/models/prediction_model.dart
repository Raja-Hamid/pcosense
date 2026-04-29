import 'package:cloud_firestore/cloud_firestore.dart';

/// Persisted record of a single ML prediction call.
///
/// Stored at `users/{uid}/predictions/{id}` and linked back to an upload + an
/// assessment so reports can show the image-derived signal alongside the
/// questionnaire result.
class PredictionModel {
  PredictionModel({
    required this.id,
    required this.status,
    this.resultCategory,
    this.confidence,
    this.probInfected,
    this.modelVersion,
    this.source,
    required this.uploadId,
    this.assessmentId,
    this.latencyMs,
    this.errorMessage,
    this.createdAt,
  });

  final String id;
  final String status; // pending | completed | failed
  final String? resultCategory; // infected | noninfected
  final double? confidence; // confidence in [0, 1] for the predicted class
  final double? probInfected; // raw probability the image is "infected" in [0, 1]
  final String? modelVersion;
  final String? source; // e.g. "vgg19-server"
  final String uploadId;
  final String? assessmentId;
  final int? latencyMs;
  final String? errorMessage;
  final DateTime? createdAt;

  bool get isInfected => resultCategory == 'infected';
  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'resultCategory': resultCategory,
        'confidence': confidence,
        'probInfected': probInfected,
        'modelVersion': modelVersion,
        'source': source,
        'uploadId': uploadId,
        'assessmentId': assessmentId,
        'latencyMs': latencyMs,
        'errorMessage': errorMessage,
        // ISO string so jsonEncode-based caches work; Firestore writes
        // override with FieldValue.serverTimestamp() at save time.
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory PredictionModel.fromJson(String id, Map<String, dynamic> json) =>
      PredictionModel(
        id: id.isNotEmpty ? id : (json['id'] as String? ?? ''),
        status: json['status'] as String? ?? 'pending',
        resultCategory: json['resultCategory'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
        probInfected: (json['probInfected'] as num?)?.toDouble(),
        modelVersion: json['modelVersion'] as String?,
        source: json['source'] as String?,
        uploadId: json['uploadId'] as String? ?? '',
        assessmentId: json['assessmentId'] as String?,
        latencyMs: (json['latencyMs'] as num?)?.toInt(),
        errorMessage: json['errorMessage'] as String?,
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  PredictionModel copyWith({
    String? status,
    String? resultCategory,
    double? confidence,
    double? probInfected,
    String? modelVersion,
    String? source,
    String? assessmentId,
    int? latencyMs,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return PredictionModel(
      id: id,
      status: status ?? this.status,
      resultCategory: resultCategory ?? this.resultCategory,
      confidence: confidence ?? this.confidence,
      probInfected: probInfected ?? this.probInfected,
      modelVersion: modelVersion ?? this.modelVersion,
      source: source ?? this.source,
      uploadId: uploadId,
      assessmentId: assessmentId ?? this.assessmentId,
      latencyMs: latencyMs ?? this.latencyMs,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
