import 'package:cloud_firestore/cloud_firestore.dart';

class UploadModel {
  final String id;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String? storagePath;
  final String? downloadUrl;
  final String uploadStatus; // uploading, completed, failed
  final String predictionStatus; // none, pending, demo
  final String? linkedAssessmentId;
  final DateTime? createdAt;

  UploadModel({
    required this.id,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    this.storagePath,
    this.downloadUrl,
    this.uploadStatus = 'uploading',
    this.predictionStatus = 'none',
    this.linkedAssessmentId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'uploadStatus': uploadStatus,
        'predictionStatus': predictionStatus,
        'linkedAssessmentId': linkedAssessmentId,
        // ISO string so jsonEncode-based caches work. Firestore writes can
        // override with FieldValue.serverTimestamp() if a server-stamped
        // value is desired.
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory UploadModel.fromJson(String id, Map<String, dynamic> json) => UploadModel(
        id: id,
        fileName: json['fileName'] as String? ?? 'unknown',
        contentType: json['contentType'] as String? ?? 'application/octet-stream',
        sizeBytes: json['sizeBytes'] as int? ?? 0,
        storagePath: json['storagePath'] as String?,
        downloadUrl: json['downloadUrl'] as String?,
        uploadStatus: json['uploadStatus'] as String? ?? 'completed',
        predictionStatus: json['predictionStatus'] as String? ?? 'none',
        linkedAssessmentId: json['linkedAssessmentId'] as String?,
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  UploadModel copyWith({
    String? id,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    String? storagePath,
    String? downloadUrl,
    String? uploadStatus,
    String? predictionStatus,
    String? linkedAssessmentId,
    DateTime? createdAt,
  }) {
    return UploadModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      predictionStatus: predictionStatus ?? this.predictionStatus,
      linkedAssessmentId: linkedAssessmentId ?? this.linkedAssessmentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
