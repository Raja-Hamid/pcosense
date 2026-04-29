import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';

class AssessmentModel {
  AssessmentModel({
    required this.id,
    required this.dateIso,
    required this.risk,
    required this.answers,
    this.clientRequestId,
    this.createdAt,
  });

  final String id;
  final String dateIso;
  final RiskAssessmentResult risk;
  final List<QuestionnaireAnswer> answers;
  final String? clientRequestId;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': dateIso,
        'risk': risk.toJson(),
        'answers': answers.map((answer) => answer.toJson()).toList(),
        if (clientRequestId != null) 'clientRequestId': clientRequestId,
        // Serialised as ISO string so jsonEncode (used for SharedPreferences
        // cache) can handle it. Firestore writes override this field with
        // FieldValue.serverTimestamp() before set().
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory AssessmentModel.fromJson(Map<String, dynamic> json) => AssessmentModel(
        id: json['id'] as String? ?? '',
        dateIso: json['date'] as String? ?? '',
        risk: RiskAssessmentResult.fromJson(((json['risk'] as Map?) ?? const <String, dynamic>{}).cast<String, dynamic>()),
        answers: _parseAnswers(json['answers']),
        clientRequestId: json['clientRequestId'] as String?,
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  AssessmentModel copyWith({
    String? id,
    String? dateIso,
    RiskAssessmentResult? risk,
    List<QuestionnaireAnswer>? answers,
    String? clientRequestId,
    DateTime? createdAt,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      dateIso: dateIso ?? this.dateIso,
      risk: risk ?? this.risk,
      answers: answers ?? this.answers,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  static List<QuestionnaireAnswer> _parseAnswers(dynamic rawAnswers) {
    if (rawAnswers is List) {
      return rawAnswers
          .whereType<Map>()
          .map((answer) => QuestionnaireAnswer.fromJson(answer.cast<String, dynamic>()))
          .toList();
    }

    if (rawAnswers is Map) {
      return rawAnswers.entries
          .map(
            (entry) => QuestionnaireAnswer(
              questionId: entry.key.toString(),
              questionText: entry.key.toString(),
              value: entry.value.toString(),
              displayValue: entry.value.toString(),
            ),
          )
          .toList();
    }

    return const <QuestionnaireAnswer>[];
  }
}
