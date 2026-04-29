class QuestionnaireAnswer {
  const QuestionnaireAnswer({
    required this.questionId,
    required this.questionText,
    required this.value,
    required this.displayValue,
  });

  final String questionId;
  final String questionText;
  final String value;
  final String displayValue;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'questionText': questionText,
        'value': value,
        'displayValue': displayValue,
      };

  factory QuestionnaireAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionnaireAnswer(
      questionId: json['questionId'] as String? ?? '',
      questionText: json['questionText'] as String? ?? json['questionId'] as String? ?? '',
      value: json['value'] as String? ?? '',
      displayValue: json['displayValue'] as String? ?? json['value'] as String? ?? '',
    );
  }
}
