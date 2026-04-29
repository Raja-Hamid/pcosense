import 'package:pcosense/src/features/assessment/logic/risk_fusion.dart';
import 'package:pcosense/src/features/assessment/models/assessment_model.dart';
import 'package:pcosense/src/features/content/models/personalized_plan_model.dart';
import 'package:pcosense/src/features/questionnaire/data/questionnaire_constants.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';

/// Produces a [PersonalizedPlan] for a given assessment + optional ultrasound
/// prediction. Pure function — no I/O.
class RecommendationEngine {
  const RecommendationEngine();

  PersonalizedPlan generate({
    required AssessmentModel assessment,
    FusedRiskResult? fused,
  }) {
    final signals = _extractSignals(assessment, fused);
    final fusedCategory = fused?.fusedCategory ?? assessment.risk.category;

    final sections = <PlanSection>[
      _buildDietSection(signals, fusedCategory),
      _buildExerciseSection(signals, fusedCategory),
      _buildCycleHealthSection(signals, fusedCategory),
      _buildSleepSection(signals, fusedCategory),
      _buildMentalSection(signals, fusedCategory),
      _buildClinicalSection(signals, fusedCategory, fused),
    ];

    final headline = _headlineForCategory(fusedCategory, signals);
    final summary = _summaryFor(signals, fusedCategory, fused);

    return PersonalizedPlan(
      assessmentId: assessment.id,
      fusedCategory: fusedCategory,
      headline: headline,
      summary: summary,
      sections: sections,
      signals: signals,
      generatedAt: DateTime.now(),
    );
  }

  // ── Signal extraction ────────────────────────────────────────────────────

  Map<String, dynamic> _extractSignals(
    AssessmentModel assessment,
    FusedRiskResult? fused,
  ) {
    final byId = <String, QuestionnaireAnswer>{
      for (final a in assessment.answers) a.questionId: a,
    };

    String? value(String id) => byId[id]?.value;
    bool isYes(String id) => value(id) == QuestionnaireValues.yes;

    final heightCm = double.tryParse(value(QuestionnaireIds.heightCm) ?? '');
    final weightKg = double.tryParse(value(QuestionnaireIds.weightKg) ?? '');
    double? bmi;
    String bmiBand = 'unknown';
    if (heightCm != null && weightKg != null && heightCm > 0 && weightKg > 0) {
      final heightM = heightCm / 100;
      bmi = weightKg / (heightM * heightM);
      if (bmi < 18.5) {
        bmiBand = 'underweight';
      } else if (bmi < 25) {
        bmiBand = 'normal';
      } else if (bmi < 30) {
        bmiBand = 'overweight';
      } else {
        bmiBand = 'obese';
      }
    }

    final cycle = value(QuestionnaireIds.periodRegularity);
    final isVeryIrregular = cycle == QuestionnaireValues.veryIrregular;
    final isIrregular = isVeryIrregular || cycle == QuestionnaireValues.slightlyIrregular;

    final hasMissedPeriods = isYes(QuestionnaireIds.missedPeriods);

    final hasExcessHair = isYes(QuestionnaireIds.excessHair);
    final hasAcne = isYes(QuestionnaireIds.adultAcne);
    final hasHairLoss = isYes(QuestionnaireIds.scalpHairLoss);
    final hasHyperandrogenism = hasExcessHair || hasAcne || hasHairLoss;

    final activity = value(QuestionnaireIds.activityLevel);
    final isInactive = activity == QuestionnaireValues.low;

    final hasWeightGain = isYes(QuestionnaireIds.unexplainedWeightGain);
    final hardWeightLoss = isYes(QuestionnaireIds.difficultWeightLoss);

    final familyHistory = isYes(QuestionnaireIds.familyHistory);
    final fatigue = isYes(QuestionnaireIds.sleepFatigue);
    final highStress = value(QuestionnaireIds.stressLevel) == QuestionnaireValues.high;

    final isMinor = value(QuestionnaireIds.ageGroup) == QuestionnaireValues.under18;
    final isPregnantPostpartum = isYes(QuestionnaireIds.pregnancyPostpartum);
    final onHormonalContraception = isYes(QuestionnaireIds.hormonalContraception);

    return <String, dynamic>{
      'bmi': bmi,
      'bmiBand': bmiBand,
      'isIrregular': isIrregular,
      'isVeryIrregular': isVeryIrregular,
      'hasMissedPeriods': hasMissedPeriods,
      'hasHyperandrogenism': hasHyperandrogenism,
      'hasExcessHair': hasExcessHair,
      'hasAcne': hasAcne,
      'hasHairLoss': hasHairLoss,
      'isInactive': isInactive,
      'hasWeightGain': hasWeightGain,
      'hardWeightLoss': hardWeightLoss,
      'familyHistory': familyHistory,
      'fatigue': fatigue,
      'highStress': highStress,
      'isMinor': isMinor,
      'isPregnantPostpartum': isPregnantPostpartum,
      'onHormonalContraception': onHormonalContraception,
      'imageInfected': fused?.prediction?.isInfected ?? false,
      'imageConfidence': fused?.prediction?.confidence,
    };
  }

  // ── Headline + summary ───────────────────────────────────────────────────

  String _headlineForCategory(String category, Map<String, dynamic> s) {
    if (category == 'urgent') {
      return 'Your safety comes first';
    }
    if (s['isPregnantPostpartum'] == true) {
      return 'A gentler, pregnancy/postpartum-aware plan';
    }
    if (s['isMinor'] == true) {
      return 'A teen-friendly wellness plan';
    }
    switch (category) {
      case 'low':
        return 'Keep your healthy habits going';
      case 'high':
        return 'A focused plan to support your hormones';
      default:
        return 'A balanced plan tailored for you';
    }
  }

  String _summaryFor(
    Map<String, dynamic> s,
    String category,
    FusedRiskResult? fused,
  ) {
    if (category == 'urgent') {
      return 'Please act on the safety guidance from your screening before working through these recommendations.';
    }
    final parts = <String>[];
    if (s['hasHyperandrogenism'] == true) {
      parts.add('hormonal/skin signals');
    }
    if (s['isVeryIrregular'] == true || s['hasMissedPeriods'] == true) {
      parts.add('cycle irregularities');
    }
    final band = s['bmiBand'] as String? ?? 'unknown';
    if (band == 'overweight' || band == 'obese') {
      parts.add('metabolic markers');
    }
    if (s['highStress'] == true || s['fatigue'] == true) {
      parts.add('stress/sleep');
    }

    final base = parts.isEmpty
        ? 'These habits are evidence-aligned for general PCOS-friendly living.'
        : 'Tuned for your ${parts.join(", ")}.';

    if (fused != null && fused.hasImage && (fused.prediction?.isInfected ?? false)) {
      return '$base Your ultrasound supports polycystic-appearance features, so insulin-sensitivity habits get extra weight.';
    }
    return base;
  }

  // ── Section builders ────────────────────────────────────────────────────

  PlanSection _buildDietSection(Map<String, dynamic> s, String category) {
    final items = <PlanItem>[
      const PlanItem(
        title: 'Build meals around fibre-rich vegetables and whole grains',
        rationale:
            'A higher-fibre, lower-glycemic load eating pattern is the most consistent dietary recommendation in PCOS guidelines — it supports steadier blood sugar and can improve cycle regularity over time.',
        priority: 3,
      ),
      const PlanItem(
        title: 'Pair every carbohydrate with protein or healthy fat',
        rationale:
            'Combining carbs with protein/fat blunts blood-sugar spikes and helps with satiety, which can ease cravings and weight management in PCOS.',
        priority: 3,
      ),
    ];

    final band = s['bmiBand'] as String? ?? 'unknown';
    if (band == 'overweight' || band == 'obese') {
      items.add(const PlanItem(
        title: 'Aim for a modest 300–500 kcal/day deficit, not extreme restriction',
        rationale:
            'Even a 5–10% reduction in body weight can restore ovulation and improve insulin sensitivity in PCOS — but extreme calorie cuts often backfire on hormones.',
        priority: 5,
      ));
      items.add(const PlanItem(
        title: 'Prioritise 25–30g of protein at breakfast',
        rationale:
            'Front-loaded protein improves daytime appetite control and helps preserve lean mass during weight loss.',
        priority: 4,
      ));
    }

    if (s['hasHyperandrogenism'] == true) {
      items.add(const PlanItem(
        title: 'Try 2 cups of spearmint tea per day for 30 days',
        rationale:
            'Small randomised trials suggest spearmint tea may modestly lower free testosterone in women with hirsutism — low-risk, low-cost trial.',
        priority: 4,
      ));
      if (s['hasAcne'] == true) {
        items.add(const PlanItem(
          title: 'Trial reducing dairy for 4–6 weeks and watch your skin',
          rationale:
              'Some women with PCOS-related acne report improvement when cutting back on dairy, especially skim milk; reintroduce one type at a time to test.',
          priority: 3,
        ));
      }
    }

    if (s['hasMissedPeriods'] == true) {
      items.add(const PlanItem(
        title: 'Don\'t crash diet — your cycle needs energy availability',
        rationale:
            'Severe energy deficits can suppress ovulation further. Focus on nutrient-dense foods and consistent meals rather than restriction.',
        priority: 5,
      ));
    }

    items.add(const PlanItem(
      title: 'Limit sugar-sweetened drinks and ultra-processed snacks',
      rationale:
            'Liquid sugars and refined carbs drive sharper insulin spikes than whole foods, which can worsen the underlying insulin resistance common in PCOS.',
      priority: 2,
    ));

    if (!(s['isMinor'] == true) && !(s['isPregnantPostpartum'] == true)) {
      items.add(const PlanItem(
        title: 'Ask your clinician about myo-inositol + d-chiro-inositol (40:1)',
        rationale:
            'Inositol has reasonable evidence for improving ovulation and insulin sensitivity in PCOS at the 40:1 ratio. Ask before starting if pregnant or on other medications.',
        priority: 3,
      ));
    }

    return PlanSection(
      id: 'diet',
      title: 'Diet & Nutrition',
      subtitle: 'Eat for steady blood sugar and balanced hormones',
      iconKey: 'diet',
      items: _sortByPriority(items),
    );
  }

  PlanSection _buildExerciseSection(Map<String, dynamic> s, String category) {
    final items = <PlanItem>[
      const PlanItem(
        title: 'Aim for 150 minutes of moderate movement weekly',
        rationale:
            'WHO and PCOS guidelines converge on this baseline — it improves insulin sensitivity, mood and cycle regularity even without weight change.',
        priority: 3,
      ),
    ];

    if (s['isInactive'] == true) {
      items.add(const PlanItem(
        title: 'Start with 20-minute daily walks, then add intensity',
        rationale:
            'A consistent walking habit is the most reliable on-ramp to the 150-minute target without flaring stress hormones.',
        priority: 5,
      ));
    } else {
      items.add(const PlanItem(
        title: 'Mix 2–3 strength sessions with your cardio',
        rationale:
            'Resistance training improves muscle insulin sensitivity more than cardio alone — a key lever in PCOS metabolic health.',
        priority: 4,
      ));
    }

    final band = s['bmiBand'] as String? ?? 'unknown';
    if (band == 'overweight' || band == 'obese' || s['hardWeightLoss'] == true) {
      items.add(const PlanItem(
        title: 'Add a short post-meal walk after your largest meal',
        rationale:
            '10–15 minutes of light walking after a big meal blunts the post-meal glucose curve, which compounds over months.',
        priority: 4,
      ));
    }

    if (s['hasHyperandrogenism'] == true) {
      items.add(const PlanItem(
        title: 'Include resistance training 2x per week',
        rationale:
            'Strength work improves insulin signalling and can indirectly reduce androgen excess that drives hair/acne symptoms.',
        priority: 4,
      ));
    }

    if (s['highStress'] == true || s['fatigue'] == true) {
      items.add(const PlanItem(
        title: 'Replace one cardio session with yoga or mobility',
        rationale:
            'High cortisol can worsen PCOS symptoms; mixing in restorative work avoids overtraining stress on top of life stress.',
        priority: 3,
      ));
    }

    return PlanSection(
      id: 'exercise',
      title: 'Exercise & Movement',
      subtitle: 'Move daily, build muscle, manage cortisol',
      iconKey: 'exercise',
      items: _sortByPriority(items),
    );
  }

  PlanSection _buildCycleHealthSection(Map<String, dynamic> s, String category) {
    final items = <PlanItem>[
      const PlanItem(
        title: 'Track your cycle in the Tracker tab',
        rationale:
            'Patterns become much clearer when logged consistently — this is the data your clinician will ask for.',
        priority: 3,
      ),
    ];

    if (s['isVeryIrregular'] == true) {
      items.add(const PlanItem(
        title: 'Log 3 consecutive cycles before drawing conclusions',
        rationale:
            'Cycle length varies naturally; a 3-cycle window reveals whether irregularity is persistent vs. an outlier.',
        priority: 4,
      ));
    }

    if (s['hasMissedPeriods'] == true) {
      items.add(const PlanItem(
        title: 'If you\'ve missed 3+ periods, see a clinician within the next month',
        rationale:
            'Prolonged amenorrhea needs evaluation — pregnancy, thyroid, prolactin and PCOS are all on the differential.',
        priority: 5,
      ));
    }

    if (s['onHormonalContraception'] == true) {
      items.add(const PlanItem(
        title: 'Note: hormonal contraception masks natural cycle signals',
        rationale:
            'Bleeding on the pill is a withdrawal bleed, not ovulation. Discuss any cycle questions in the context of your contraception.',
        priority: 2,
      ));
    }

    items.add(const PlanItem(
      title: 'Note daily symptoms — even just a tag list',
      rationale:
          'Cramps, mood, energy and skin patterns over time are more useful than a single snapshot when reviewing with a clinician.',
      priority: 2,
    ));

    return PlanSection(
      id: 'cycle',
      title: 'Cycle Awareness',
      subtitle: 'Build the data your clinician will want to see',
      iconKey: 'cycle',
      items: _sortByPriority(items),
    );
  }

  PlanSection _buildSleepSection(Map<String, dynamic> s, String category) {
    final items = <PlanItem>[
      const PlanItem(
        title: 'Target 7–9 hours of sleep nightly',
        rationale:
            'Short sleep raises insulin resistance, hunger hormones and stress reactivity — all of which interact poorly with PCOS.',
        priority: 3,
      ),
      const PlanItem(
        title: 'Keep a consistent sleep/wake window',
        rationale:
            'Regular timing entrains the circadian system and improves both sleep quality and metabolic health.',
        priority: 2,
      ),
    ];

    if (s['fatigue'] == true) {
      items.add(const PlanItem(
        title: 'No screens or bright light in the last hour before bed',
        rationale:
            'Evening light suppresses melatonin and shifts your body clock later, fragmenting sleep further.',
        priority: 4,
      ));
      items.add(const PlanItem(
        title: 'Get 5–10 minutes of morning sunlight within an hour of waking',
        rationale:
            'Morning light is one of the strongest signals to set your circadian system, which can lift afternoon fatigue.',
        priority: 4,
      ));
    }

    return PlanSection(
      id: 'sleep',
      title: 'Sleep & Rest',
      subtitle: 'Sleep is a hormone regulator, not a luxury',
      iconKey: 'sleep',
      items: _sortByPriority(items),
    );
  }

  PlanSection _buildMentalSection(Map<String, dynamic> s, String category) {
    final items = <PlanItem>[
      const PlanItem(
        title: 'Practice 5–10 minutes of breathwork or meditation daily',
        rationale:
            'Even short daily mindfulness sessions reduce perceived stress and cortisol responses over weeks.',
        priority: 2,
      ),
    ];

    if (s['highStress'] == true) {
      items.add(const PlanItem(
        title: 'Identify one repeating stressor and a small action against it this week',
        rationale:
            'Chronic stress is a common, under-addressed amplifier of PCOS symptoms; targeting one source beats abstract "manage stress" goals.',
        priority: 5,
      ));
      items.add(const PlanItem(
        title: 'Use a 4-7-8 breath cycle when you notice tension',
        rationale:
            'A simple structured breath pattern activates the parasympathetic nervous system within 1–2 minutes.',
        priority: 4,
      ));
    }

    items.add(const PlanItem(
      title: 'Find a community — online or in person',
      rationale:
          'PCOS is common but often invisible. Talking with others who get it reduces isolation and improves adherence to lifestyle changes.',
      priority: 2,
    ));

    return PlanSection(
      id: 'mental',
      title: 'Mental Wellness',
      subtitle: 'Lower stress, raise resilience',
      iconKey: 'mental',
      items: _sortByPriority(items),
    );
  }

  PlanSection _buildClinicalSection(
    Map<String, dynamic> s,
    String category,
    FusedRiskResult? fused,
  ) {
    final items = <PlanItem>[];

    if (category == 'high' || category == 'urgent') {
      items.add(const PlanItem(
        title: 'Schedule a clinician review within the next 4 weeks',
        rationale:
            'Your screening returned a higher-risk pattern. Confirming with bloodwork (testosterone, SHBG, fasting glucose, HbA1c) and clinician review is the clear next step.',
        priority: 5,
      ));
    } else if (category == 'moderate') {
      items.add(const PlanItem(
        title: 'Bring this report to your next routine clinician visit',
        rationale:
            'Mid-tier risk benefits from a conversation in context — your clinician can decide whether bloodwork or imaging adds value for you.',
        priority: 3,
      ));
    } else {
      items.add(const PlanItem(
        title: 'Keep screening yearly or sooner if symptoms change',
        rationale:
            'Low risk today doesn\'t guarantee tomorrow — re-screening if symptoms shift gives you an early signal.',
        priority: 2,
      ));
    }

    if (s['familyHistory'] == true) {
      items.add(const PlanItem(
        title: 'Mention your family history at your next visit',
        rationale:
            'PCOS clusters in families. A first-degree relative with PCOS, type 2 diabetes or early heart disease changes screening priorities.',
        priority: 3,
      ));
    }

    if (fused != null && (fused.prediction?.isInfected ?? false) && (fused.prediction?.confidence ?? 0) >= 0.75) {
      items.add(const PlanItem(
        title: 'Bring the ultrasound + this report to your clinician',
        rationale:
            'The image-analysis model flagged polycystic-appearance features with high confidence. A clinician can correlate this with your symptoms and bloodwork.',
        priority: 5,
      ));
    }

    if (s['isPregnantPostpartum'] == true) {
      items.add(const PlanItem(
        title: 'Treat any PCOS-related changes through your obstetric team',
        rationale:
            'Diet, exercise and supplement decisions during pregnancy/postpartum should go through the team already managing your perinatal care.',
        priority: 5,
      ));
    }

    if (s['isMinor'] == true) {
      items.add(const PlanItem(
        title: 'PCOS criteria are stricter for adolescents — don\'t self-diagnose',
        rationale:
            'Irregular cycles in the first 1–3 years post-menarche are common and not by themselves a PCOS diagnosis. Age-appropriate clinician review matters here.',
        priority: 4,
      ));
    }

    return PlanSection(
      id: 'clinical',
      title: 'Clinical Follow-up',
      subtitle: 'When and how to bring this to a professional',
      iconKey: 'clinical',
      items: _sortByPriority(items),
    );
  }

  List<PlanItem> _sortByPriority(List<PlanItem> items) {
    final copy = [...items]..sort((a, b) => b.priority.compareTo(a.priority));
    return copy;
  }
}
