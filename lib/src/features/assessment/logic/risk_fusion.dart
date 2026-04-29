import 'package:pcosense/src/features/content/models/prediction_model.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';

/// Combined questionnaire + image-prediction risk signal.
///
/// The questionnaire produces a [RiskAssessmentResult] with a category in
/// `{low, moderate, high, urgent}`. The CNN produces a [PredictionModel]
/// with a label in `{infected, noninfected}` and a `confidence` in `[0, 1]`.
/// [RiskFusion] combines them into a single [FusedRiskResult] the UI can show.
class FusedRiskResult {
  const FusedRiskResult({
    required this.questionnaire,
    required this.prediction,
    required this.fusedCategory,
    required this.fusedLevel,
    required this.fusedHeadline,
    required this.imageInsight,
    required this.imageConfidenceBand,
    required this.adjustedDirection,
  });

  final RiskAssessmentResult questionnaire;
  final PredictionModel? prediction;

  /// One of `low | moderate | high | urgent`.
  final String fusedCategory;
  final String fusedLevel;
  final String fusedHeadline;

  /// Human-readable sentence explaining the image's contribution.
  final String imageInsight;

  /// `high | moderate | low | unknown`.
  final String imageConfidenceBand;

  /// `up | down | hold | none` — direction the image moved the questionnaire
  /// category. `none` means no image was provided.
  final String adjustedDirection;

  bool get hasImage => prediction != null && prediction!.isCompleted;

  Map<String, dynamic> toJson() => {
        'fusedCategory': fusedCategory,
        'fusedLevel': fusedLevel,
        'fusedHeadline': fusedHeadline,
        'imageInsight': imageInsight,
        'imageConfidenceBand': imageConfidenceBand,
        'adjustedDirection': adjustedDirection,
        'questionnaire': questionnaire.toJson(),
        'prediction': prediction?.toJson(),
      };
}

class RiskFusion {
  const RiskFusion();

  static const List<String> _ladder = ['low', 'moderate', 'high'];

  static const double highConfidenceThreshold = 0.75;
  static const double veryHighConfidenceThreshold = 0.85;
  static const double lowConfidenceThreshold = 0.60;

  FusedRiskResult fuse(
    RiskAssessmentResult q,
    PredictionModel? p,
  ) {
    if (q.shouldStopForUrgentCare) {
      return FusedRiskResult(
        questionnaire: q,
        prediction: p,
        fusedCategory: 'urgent',
        fusedLevel: 'Urgent care',
        fusedHeadline: q.headline,
        imageInsight: p == null
            ? 'No ultrasound was attached.'
            : 'Image analysis is set aside — urgent symptoms take priority.',
        imageConfidenceBand: _confidenceBand(p?.confidence),
        adjustedDirection: 'hold',
      );
    }

    if (p == null || !p.isCompleted) {
      return FusedRiskResult(
        questionnaire: q,
        prediction: p,
        fusedCategory: q.category,
        fusedLevel: q.level,
        fusedHeadline: q.headline,
        imageInsight: 'No ultrasound was attached. Result is based on the questionnaire only.',
        imageConfidenceBand: 'unknown',
        adjustedDirection: 'none',
      );
    }

    final conf = p.confidence ?? 0.0;
    final isInfected = p.isInfected;

    if (conf < lowConfidenceThreshold) {
      return FusedRiskResult(
        questionnaire: q,
        prediction: p,
        fusedCategory: q.category,
        fusedLevel: q.level,
        fusedHeadline: q.headline,
        imageInsight:
            'The ultrasound model returned a low-confidence reading (${_pct(conf)}). Treat the image signal with caution and rely on the questionnaire result.',
        imageConfidenceBand: 'low',
        adjustedDirection: 'hold',
      );
    }

    if (isInfected && conf >= highConfidenceThreshold) {
      final bumped = _bumpUp(q.category);
      final changed = bumped != q.category;
      return FusedRiskResult(
        questionnaire: q,
        prediction: p,
        fusedCategory: bumped,
        fusedLevel: _levelFor(bumped),
        fusedHeadline: changed
            ? _headlineFor(bumped)
            : q.headline,
        imageInsight: changed
            ? 'The ultrasound shows polycystic-appearance features (${_pct(conf)} confidence). The combined risk has been raised to ${_levelFor(bumped).toLowerCase()}.'
            : 'The ultrasound shows polycystic-appearance features (${_pct(conf)} confidence), consistent with the questionnaire result.',
        imageConfidenceBand: _confidenceBand(conf),
        adjustedDirection: changed ? 'up' : 'hold',
      );
    }

    if (!isInfected && conf >= veryHighConfidenceThreshold) {
      // Clinical safety: do not downgrade from a high-risk questionnaire just
      // because the image looks normal — symptom-based PCOS without classic
      // imaging is well documented.
      return FusedRiskResult(
        questionnaire: q,
        prediction: p,
        fusedCategory: q.category,
        fusedLevel: q.level,
        fusedHeadline: q.headline,
        imageInsight:
            'The ultrasound did not show classic polycystic-appearance features (${_pct(conf)} confidence). PCOS can still be present without those imaging signs, so the questionnaire result is unchanged.',
        imageConfidenceBand: _confidenceBand(conf),
        adjustedDirection: 'hold',
      );
    }

    // Moderate-confidence agreement / disagreement: keep questionnaire, narrate.
    return FusedRiskResult(
      questionnaire: q,
      prediction: p,
      fusedCategory: q.category,
      fusedLevel: q.level,
      fusedHeadline: q.headline,
      imageInsight: isInfected
          ? 'The ultrasound suggests possible polycystic-appearance features (${_pct(conf)} confidence). This adds weight to the questionnaire result; clinician review is recommended.'
          : 'The ultrasound did not strongly suggest polycystic-appearance features (${_pct(conf)} confidence). Continue with the questionnaire-based plan.',
      imageConfidenceBand: _confidenceBand(conf),
      adjustedDirection: 'hold',
    );
  }

  String _bumpUp(String category) {
    final idx = _ladder.indexOf(category);
    if (idx < 0) return category;
    if (idx >= _ladder.length - 1) return category;
    return _ladder[idx + 1];
  }

  String _levelFor(String category) {
    switch (category) {
      case 'low':
        return 'Low risk';
      case 'high':
        return 'High risk';
      case 'urgent':
        return 'Urgent care';
      default:
        return 'Moderate risk';
    }
  }

  String _headlineFor(String category) {
    switch (category) {
      case 'low':
        return 'Low combined risk';
      case 'high':
        return 'High combined risk — consider clinician review';
      case 'urgent':
        return 'Please seek urgent medical care now';
      default:
        return 'Moderate combined risk';
    }
  }

  String _confidenceBand(double? conf) {
    if (conf == null) return 'unknown';
    if (conf >= veryHighConfidenceThreshold) return 'high';
    if (conf >= highConfidenceThreshold) return 'moderate';
    if (conf >= lowConfidenceThreshold) return 'low';
    return 'low';
  }

  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';
}
