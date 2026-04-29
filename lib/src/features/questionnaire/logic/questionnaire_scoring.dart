import 'dart:math' as math;

import 'package:pcosense/src/features/questionnaire/data/questionnaire_constants.dart';
import 'package:pcosense/src/features/questionnaire/data/questionnaire_content.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_rule.dart';

class QuestionnaireScoring {
  QuestionnaireScoring()
      : _rules = <RiskRule>[
          RiskRule(
            id: 'very_irregular_periods',
            description: 'Very irregular cycles are a major screening feature.',
            contributorLabel: 'Very irregular periods',
            weight: 4,
            applies: (answers) =>
                _value(answers, QuestionnaireIds.periodRegularity) == QuestionnaireValues.veryIrregular,
          ),
          RiskRule(
            id: 'slightly_irregular_periods',
            description: 'Slight irregularity still raises screening concern.',
            contributorLabel: 'Slightly irregular periods',
            weight: 2,
            applies: (answers) =>
                _value(answers, QuestionnaireIds.periodRegularity) == QuestionnaireValues.slightlyIrregular,
          ),
          RiskRule(
            id: 'cycle_length_outside_expected_range',
            description: 'Long or widely variable cycles are highly relevant.',
            contributorLabel: 'Long or widely varying cycles',
            weight: 4,
            applies: (answers) {
              final cycle = _value(answers, QuestionnaireIds.cycleLength);
              return cycle == QuestionnaireValues.cycleOver35 || cycle == QuestionnaireValues.cycleVaries;
            },
          ),
          RiskRule(
            id: 'missed_periods',
            description: 'Missed periods for 3 or more months are strongly relevant.',
            contributorLabel: 'Missed periods for 3+ months',
            weight: 5,
            applies: (answers) => _isYes(answers, QuestionnaireIds.missedPeriods),
          ),
          RiskRule(
            id: 'excess_hair',
            description: 'Clinical hirsutism is one of the highest-weight androgen signs.',
            contributorLabel: 'Excess facial or body hair',
            weight: 5,
            applies: (answers) => _isYes(answers, QuestionnaireIds.excessHair),
          ),
          RiskRule(
            id: 'excess_hair_severity_moderate',
            description: 'Moderate excess hair raises the signal further.',
            contributorLabel: 'Moderate excess hair severity',
            weight: 1,
            applies: (answers) =>
                _value(answers, QuestionnaireIds.excessHairSeverity) == QuestionnaireValues.moderate,
          ),
          RiskRule(
            id: 'excess_hair_severity_severe',
            description: 'Severe excess hair adds meaningful concern.',
            contributorLabel: 'Severe excess hair severity',
            weight: 2,
            applies: (answers) =>
                _value(answers, QuestionnaireIds.excessHairSeverity) == QuestionnaireValues.severe,
          ),
          RiskRule(
            id: 'adult_acne',
            description: 'Persistent adult acne is a medium-weight androgen sign.',
            contributorLabel: 'Persistent adult acne',
            weight: 3,
            applies: (answers) => _isYes(answers, QuestionnaireIds.adultAcne),
          ),
          RiskRule(
            id: 'scalp_hair_loss',
            description: 'Androgenic hair thinning supports screening concern.',
            contributorLabel: 'Scalp hair thinning or hair loss',
            weight: 3,
            applies: (answers) => _isYes(answers, QuestionnaireIds.scalpHairLoss),
          ),
          RiskRule(
            id: 'oily_skin',
            description: 'Oily skin is a lighter supporting feature.',
            contributorLabel: 'Oily skin',
            weight: 1,
            applies: (answers) => _isYes(answers, QuestionnaireIds.oilySkin),
          ),
          RiskRule(
            id: 'bmi_over_25',
            description: 'BMI over 25 adds metabolic context when height and weight are available.',
            contributorLabel: 'BMI above 25',
            weight: 1,
            applies: (answers) {
              final bmi = _bmi(answers);
              return bmi != null && bmi >= 25 && bmi < 30;
            },
          ),
          RiskRule(
            id: 'bmi_over_30',
            description: 'BMI over 30 adds a stronger metabolic contribution.',
            contributorLabel: 'BMI above 30',
            weight: 2,
            applies: (answers) {
              final bmi = _bmi(answers);
              return bmi != null && bmi >= 30;
            },
          ),
          RiskRule(
            id: 'unexplained_weight_gain',
            description: 'Recent unexplained weight gain adds supportive context.',
            contributorLabel: 'Recent unexplained weight gain',
            weight: 2,
            applies: (answers) => _isYes(answers, QuestionnaireIds.unexplainedWeightGain),
          ),
          RiskRule(
            id: 'difficult_weight_loss',
            description: 'Difficulty losing weight adds supportive metabolic context.',
            contributorLabel: 'Difficulty losing weight',
            weight: 2,
            applies: (answers) => _isYes(answers, QuestionnaireIds.difficultWeightLoss),
          ),
          RiskRule(
            id: 'family_history',
            description: 'Family history is a low-medium weight contextual factor.',
            contributorLabel: 'Family history of PCOS, diabetes, or thyroid disorder',
            weight: 2,
            applies: (answers) => _value(answers, QuestionnaireIds.familyHistory) == QuestionnaireValues.yes,
          ),
          RiskRule(
            id: 'sleep_fatigue',
            description: 'Fatigue is a supporting contextual feature.',
            contributorLabel: 'Sleep issues or fatigue',
            weight: 1,
            applies: (answers) => _isYes(answers, QuestionnaireIds.sleepFatigue),
          ),
          RiskRule(
            id: 'low_activity',
            description: 'Low activity is contextual only.',
            contributorLabel: 'Low activity level',
            weight: 1,
            applies: (answers) => _value(answers, QuestionnaireIds.activityLevel) == QuestionnaireValues.low,
          ),
          RiskRule(
            id: 'high_stress',
            description: 'High stress is contextual only.',
            contributorLabel: 'High stress level',
            weight: 1,
            applies: (answers) => _value(answers, QuestionnaireIds.stressLevel) == QuestionnaireValues.high,
          ),
          RiskRule(
            id: 'positive_ultrasound',
            description: 'Reported polycystic ovarian appearance is highly relevant.',
            contributorLabel: 'Past ultrasound mentioned polycystic ovary appearance',
            weight: 6,
            applies: (answers) => _isYes(answers, QuestionnaireIds.polycysticAppearance),
          ),
        ];

  final List<RiskRule> _rules;

  RiskAssessmentResult assess(Map<String, QuestionnaireAnswer> answers) {
    final matchedRules = _rules.where((rule) => rule.applies(answers)).toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));

    final score = matchedRules.fold<int>(0, (sum, rule) => sum + rule.weight);
    final isMinor = _value(answers, QuestionnaireIds.ageGroup) == QuestionnaireValues.under18;
    final hasIrregularPattern = _hasIrregularPattern(answers);
    final hasHyperandrogenismPattern = _hasHyperandrogenismPattern(answers);
    final reportedPositiveUltrasound = _isYes(answers, QuestionnaireIds.polycysticAppearance);
    final onHormonalContraception = _isYes(answers, QuestionnaireIds.hormonalContraception);
    final pregnancyOrPostpartum = _isYes(answers, QuestionnaireIds.pregnancyPostpartum);

    var category = score >= 12 ? 'high' : score >= 6 ? 'moderate' : 'low';

    if (reportedPositiveUltrasound && category == 'low') {
      category = 'moderate';
    } else if (reportedPositiveUltrasound && category == 'moderate') {
      category = 'high';
    }

    final recommendUltrasoundUpload = reportedPositiveUltrasound || hasIrregularPattern && hasHyperandrogenismPattern || category != 'low';
    final recommendClinicianReview = category != 'low' || hasIrregularPattern && hasHyperandrogenismPattern || reportedPositiveUltrasound;

    final contributors = matchedRules.map((rule) => rule.contributorLabel).take(4).toList();
    if (contributors.isEmpty) {
      contributors.add('No strong weighted screening features were selected');
    }

    final explanation = _buildExplanation(
      category: category,
      isMinor: isMinor,
      hasIrregularPattern: hasIrregularPattern,
      hasHyperandrogenismPattern: hasHyperandrogenismPattern,
      reportedPositiveUltrasound: reportedPositiveUltrasound,
      onHormonalContraception: onHormonalContraception,
      pregnancyOrPostpartum: pregnancyOrPostpartum,
    );

    return RiskAssessmentResult(
      category: category,
      headline: _headlineFor(category, isMinor: isMinor),
      explanation: explanation,
      contributors: contributors,
      nextSteps: _nextStepsFor(
        category: category,
        isMinor: isMinor,
        recommendUltrasoundUpload: recommendUltrasoundUpload,
        pregnancyOrPostpartum: pregnancyOrPostpartum,
      ),
      score: score,
      maxScore: _rules.fold<int>(0, (sum, rule) => sum + rule.weight),
      disclaimer: QuestionnaireContent.disclaimer,
      shouldRecommendUltrasoundUpload: recommendUltrasoundUpload,
      shouldRecommendClinicianReview: recommendClinicianReview,
      shouldStopForUrgentCare: false,
      isMinor: isMinor,
    );
  }

  bool shouldShowUltrasoundRecommendation(Map<String, QuestionnaireAnswer> answers) {
    return _hasIrregularPattern(answers) && _hasHyperandrogenismPattern(answers);
  }

  static String? _value(Map<String, QuestionnaireAnswer> answers, String questionId) {
    return answers[questionId]?.value;
  }

  static bool _isYes(Map<String, QuestionnaireAnswer> answers, String questionId) {
    return _value(answers, questionId) == QuestionnaireValues.yes;
  }

  static double? _bmi(Map<String, QuestionnaireAnswer> answers) {
    final heightCm = double.tryParse(_value(answers, QuestionnaireIds.heightCm) ?? '');
    final weightKg = double.tryParse(_value(answers, QuestionnaireIds.weightKg) ?? '');
    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return null;
    }

    final heightM = heightCm / 100;
    return weightKg / math.pow(heightM, 2);
  }

  static bool _hasIrregularPattern(Map<String, QuestionnaireAnswer> answers) {
    final regularity = _value(answers, QuestionnaireIds.periodRegularity);
    final cycleLength = _value(answers, QuestionnaireIds.cycleLength);
    return regularity == QuestionnaireValues.slightlyIrregular ||
        regularity == QuestionnaireValues.veryIrregular ||
        cycleLength == QuestionnaireValues.cycleLessThan21 ||
        cycleLength == QuestionnaireValues.cycleOver35 ||
        cycleLength == QuestionnaireValues.cycleVaries ||
        _isYes(answers, QuestionnaireIds.missedPeriods);
  }

  static bool _hasHyperandrogenismPattern(Map<String, QuestionnaireAnswer> answers) {
    return _isYes(answers, QuestionnaireIds.excessHair) ||
        _isYes(answers, QuestionnaireIds.adultAcne) ||
        _isYes(answers, QuestionnaireIds.scalpHairLoss);
  }

  static String _headlineFor(String category, {required bool isMinor}) {
    if (isMinor) {
      switch (category) {
        case 'low':
          return 'Low screening concern right now';
        case 'high':
          return 'Higher screening concern that deserves follow-up';
        default:
          return 'Moderate screening concern';
      }
    }

    switch (category) {
      case 'low':
        return 'Low screening risk';
      case 'high':
        return 'High screening risk';
      default:
        return 'Moderate screening risk';
    }
  }

  static String _buildExplanation({
    required String category,
    required bool isMinor,
    required bool hasIrregularPattern,
    required bool hasHyperandrogenismPattern,
    required bool reportedPositiveUltrasound,
    required bool onHormonalContraception,
    required bool pregnancyOrPostpartum,
  }) {
    final base = switch (category) {
      'low' =>
        'Your answers did not show a strong PCOS screening pattern right now. This does not rule PCOS in or out.',
      'high' =>
        'Several higher-weight screening features were present, which increases concern and supports clinician follow-up.',
      _ =>
        'Some answers matched patterns that are commonly reviewed during a PCOS assessment, but this screening cannot confirm a diagnosis.',
    };

    final details = <String>[
      if (hasIrregularPattern && hasHyperandrogenismPattern)
        'Cycle changes together with skin or hair symptoms make ultrasound review more relevant.',
      if (reportedPositiveUltrasound)
        'A past ultrasound result that mentioned polycystic ovary appearance raises the screening category.',
      if (onHormonalContraception)
        'Hormonal contraception can change bleeding patterns and may make cycle-based screening harder to interpret.',
      if (pregnancyOrPostpartum)
        'Pregnancy, breastfeeding, and the postpartum period can also change cycles and symptoms.',
    ];

    if (isMinor) {
      details.insert(
        0,
        'Because you are under 18, this wording stays intentionally cautious: puberty-related changes can overlap with PCOS symptoms, so a clinician should interpret persistent symptoms.',
      );
    }

    return <String>[base, ...details].join(' ');
  }

  static List<String> _nextStepsFor({
    required String category,
    required bool isMinor,
    required bool recommendUltrasoundUpload,
    required bool pregnancyOrPostpartum,
  }) {
    final steps = switch (category) {
      'low' => <String>[
          'Keep tracking periods, skin changes, and general wellbeing over time.',
          'Use the education section for lifestyle and symptom-tracking tips.',
          'Consider clinical advice if symptoms persist, worsen, or new symptoms appear.',
        ],
      'high' => <String>[
          'Arrange clinician review for a full assessment.',
          if (recommendUltrasoundUpload) 'Upload an ultrasound if you have one available or if imaging is recommended.',
          'Bring a summary of your cycle pattern and symptom history to the appointment.',
        ],
      _ => <String>[
          'Consider clinician review to discuss these screening answers.',
          if (recommendUltrasoundUpload) 'Ultrasound upload may be helpful, especially when cycle changes and skin or hair symptoms occur together.',
          'Keep tracking symptoms so follow-up decisions are easier.',
        ],
    };

    if (isMinor) {
      steps.add('If symptoms are ongoing, ask for age-appropriate adolescent care and avoid self-diagnosis.');
    }

    if (pregnancyOrPostpartum) {
      steps.add('Mention pregnancy, breastfeeding, or recent postpartum status during follow-up because it can affect interpretation.');
    }

    return steps;
  }
}
