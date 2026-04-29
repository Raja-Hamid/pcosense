import 'package:cloud_firestore/cloud_firestore.dart';

/// A personalized lifestyle/diet plan generated from the user's questionnaire
/// + ultrasound prediction (if any).
class PersonalizedPlan {
  const PersonalizedPlan({
    required this.assessmentId,
    required this.fusedCategory,
    required this.headline,
    required this.summary,
    required this.sections,
    required this.signals,
    this.generatedAt,
  });

  final String assessmentId;
  final String fusedCategory; // low | moderate | high | urgent
  final String headline;
  final String summary;
  final List<PlanSection> sections;

  /// Diagnostic signals the engine derived from the user's data — exposed so
  /// the UI can show "why these recommendations?" if useful.
  final Map<String, dynamic> signals;
  final DateTime? generatedAt;

  Map<String, dynamic> toJson() => {
        'assessmentId': assessmentId,
        'fusedCategory': fusedCategory,
        'headline': headline,
        'summary': summary,
        'sections': sections.map((s) => s.toJson()).toList(),
        'signals': signals,
        // ISO string so this round-trips through jsonEncode for the cache.
        if (generatedAt != null) 'generatedAt': generatedAt!.toIso8601String(),
      };

  factory PersonalizedPlan.fromJson(Map<String, dynamic> json) {
    return PersonalizedPlan(
      assessmentId: json['assessmentId'] as String? ?? '',
      fusedCategory: json['fusedCategory'] as String? ?? 'moderate',
      headline: json['headline'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      sections: ((json['sections'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((m) => PlanSection.fromJson(m.cast<String, dynamic>()))
          .toList(),
      signals: ((json['signals'] as Map?) ?? const <String, dynamic>{}).cast<String, dynamic>(),
      generatedAt: _parseDate(json['generatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

class PlanSection {
  const PlanSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey; // logical key resolved to IconData in the view
  final List<PlanItem> items;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'iconKey': iconKey,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory PlanSection.fromJson(Map<String, dynamic> json) {
    return PlanSection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? 'sparkle',
      items: ((json['items'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((m) => PlanItem.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class PlanItem {
  const PlanItem({
    required this.title,
    required this.rationale,
    required this.priority,
  });

  /// Short imperative advice line.
  final String title;

  /// Explanation of *why* this item is in the plan.
  final String rationale;

  /// 1 = baseline, 5 = highest priority.
  final int priority;

  Map<String, dynamic> toJson() => {
        'title': title,
        'rationale': rationale,
        'priority': priority,
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    return PlanItem(
      title: json['title'] as String? ?? '',
      rationale: json['rationale'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 1,
    );
  }
}
