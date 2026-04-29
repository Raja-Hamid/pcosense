import 'package:pcosense/src/features/questionnaire/models/questionnaire_question.dart';

class QuestionnaireSection {
  const QuestionnaireSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.questions,
    this.supportingText,
    this.isOptional = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? supportingText;
  final bool isOptional;
  final List<QuestionnaireQuestion> questions;
}
