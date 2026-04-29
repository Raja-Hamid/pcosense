class RiskAssessmentResult {
  const RiskAssessmentResult({
    required this.category,
    required this.headline,
    required this.explanation,
    required this.contributors,
    required this.nextSteps,
    required this.score,
    required this.maxScore,
    required this.disclaimer,
    required this.shouldRecommendUltrasoundUpload,
    required this.shouldRecommendClinicianReview,
    required this.shouldStopForUrgentCare,
    required this.isMinor,
  });

  final String category;
  final String headline;
  final String explanation;
  final List<String> contributors;
  final List<String> nextSteps;
  final int score;
  final int maxScore;
  final String disclaimer;
  final bool shouldRecommendUltrasoundUpload;
  final bool shouldRecommendClinicianReview;
  final bool shouldStopForUrgentCare;
  final bool isMinor;

  String get level {
    if (shouldStopForUrgentCare) {
      return 'Urgent care';
    }

    switch (category) {
      case 'low':
        return 'Low risk';
      case 'high':
        return 'High risk';
      default:
        return 'Moderate risk';
    }
  }

  String get compactLabel {
    if (shouldStopForUrgentCare) {
      return 'Urgent care';
    }

    switch (category) {
      case 'low':
        return 'Low';
      case 'high':
        return 'High';
      default:
        return 'Moderate';
    }
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'headline': headline,
        'explanation': explanation,
        'contributors': contributors,
        'nextSteps': nextSteps,
        'score': score,
        'maxScore': maxScore,
        'disclaimer': disclaimer,
        'shouldRecommendUltrasoundUpload': shouldRecommendUltrasoundUpload,
        'shouldRecommendClinicianReview': shouldRecommendClinicianReview,
        'shouldStopForUrgentCare': shouldStopForUrgentCare,
        'isMinor': isMinor,
      };

  factory RiskAssessmentResult.fromJson(Map<String, dynamic> json) {
    final category = _normalizedCategory(
      json['category'] as String? ?? json['level'] as String?,
      urgent: json['shouldStopForUrgentCare'] as bool? ?? false,
    );

    return RiskAssessmentResult(
      category: category,
      headline: json['headline'] as String? ?? _defaultHeadlineFor(category),
      explanation: json['explanation'] as String? ?? _defaultExplanationFor(category),
      contributors: ((json['contributors'] as List?) ?? const <dynamic>[]).cast<String>(),
      nextSteps: ((json['nextSteps'] as List?) ?? _defaultNextStepsFor(category)).cast<String>(),
      score: json['score'] as int? ?? 0,
      maxScore: json['maxScore'] as int? ?? 0,
      disclaimer: json['disclaimer'] as String? ??
          'This tool is for screening and educational purposes only and is not a substitute for professional medical advice.',
      shouldRecommendUltrasoundUpload: json['shouldRecommendUltrasoundUpload'] as bool? ?? category != 'low',
      shouldRecommendClinicianReview: json['shouldRecommendClinicianReview'] as bool? ?? category != 'low',
      shouldStopForUrgentCare: json['shouldStopForUrgentCare'] as bool? ?? category == 'urgent',
      isMinor: json['isMinor'] as bool? ?? false,
    );
  }

  factory RiskAssessmentResult.urgentCare({required bool isMinor}) {
    return RiskAssessmentResult(
      category: 'urgent',
      headline: 'Please seek urgent medical care now',
      explanation:
          'Severe pelvic pain, sudden heavy bleeding, fainting, or other urgent symptoms should be assessed promptly by a clinician or emergency service.',
      contributors: const <String>[
        'Urgent symptoms were selected',
      ],
      nextSteps: const <String>[
        'Seek urgent medical care now or contact local emergency services if symptoms are severe.',
        'Do not wait for this screening to finish before getting medical help.',
        'Return to the questionnaire later only after urgent symptoms have been addressed.',
      ],
      score: 0,
      maxScore: 0,
      disclaimer:
          'This tool is for screening and educational purposes only and is not a substitute for professional medical advice.',
      shouldRecommendUltrasoundUpload: false,
      shouldRecommendClinicianReview: true,
      shouldStopForUrgentCare: true,
      isMinor: isMinor,
    );
  }

  factory RiskAssessmentResult.fallback() {
    return RiskAssessmentResult(
      category: 'moderate',
      headline: 'Moderate screening risk',
      explanation:
          'Some answers matched patterns that may deserve follow-up, but this screening cannot confirm or rule out PCOS on its own.',
      contributors: const <String>[
        'Saved screening result',
      ],
      nextSteps: const <String>[
        'Review your symptoms with a clinician if they continue or get worse.',
        'Consider ultrasound review if a clinician recommends imaging.',
      ],
      score: 0,
      maxScore: 0,
      disclaimer:
          'This tool is for screening and educational purposes only and is not a substitute for professional medical advice.',
      shouldRecommendUltrasoundUpload: true,
      shouldRecommendClinicianReview: true,
      shouldStopForUrgentCare: false,
      isMinor: false,
    );
  }

  static String _normalizedCategory(String? raw, {required bool urgent}) {
    if (urgent) {
      return 'urgent';
    }

    switch ((raw ?? '').toLowerCase()) {
      case 'low':
      case 'low risk':
        return 'low';
      case 'high':
      case 'high risk':
        return 'high';
      case 'urgent':
      case 'urgent care':
        return 'urgent';
      default:
        return 'moderate';
    }
  }

  static String _defaultHeadlineFor(String category) {
    switch (category) {
      case 'low':
        return 'Low screening risk';
      case 'high':
        return 'High screening risk';
      case 'urgent':
        return 'Please seek urgent medical care now';
      default:
        return 'Moderate screening risk';
    }
  }

  static String _defaultExplanationFor(String category) {
    switch (category) {
      case 'low':
        return 'Your previous screening did not record many PCOS-related features, but this does not replace clinical advice.';
      case 'high':
        return 'Your previous screening recorded several PCOS-related features and follow-up with a clinician is recommended.';
      case 'urgent':
        return 'Urgent symptoms need prompt medical review.';
      default:
        return 'Your previous screening recorded some features that may deserve follow-up with a clinician.';
    }
  }

  static List<String> _defaultNextStepsFor(String category) {
    switch (category) {
      case 'low':
        return const <String>[
          'Keep tracking symptoms and cycles over time.',
          'Speak with a clinician if symptoms continue or worsen.',
        ];
      case 'high':
        return const <String>[
          'Arrange clinician review.',
          'Consider ultrasound review if clinically appropriate.',
        ];
      case 'urgent':
        return const <String>[
          'Seek urgent medical care now.',
        ];
      default:
        return const <String>[
          'Review symptoms with a clinician.',
          'Consider ultrasound review if clinically appropriate.',
        ];
    }
  }
}
