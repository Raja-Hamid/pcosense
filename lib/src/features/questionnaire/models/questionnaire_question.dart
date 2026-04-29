import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_option.dart';

enum QuestionnaireInputType {
  choice,
  number,
  dropdown,
}

typedef QuestionVisibility = bool Function(Map<String, QuestionnaireAnswer> answers);

class QuestionnaireQuestion {
  const QuestionnaireQuestion({
    required this.id,
    required this.title,
    required this.inputType,
    this.helperText,
    this.placeholder,
    this.unitLabel,
    this.options = const <QuestionnaireOption>[],
    this.isRequired = false,
    this.isSensitive = false,
    this.visibility,
  });

  final String id;
  final String title;
  final QuestionnaireInputType inputType;
  final String? helperText;
  final String? placeholder;
  final String? unitLabel;
  final List<QuestionnaireOption> options;
  final bool isRequired;
  final bool isSensitive;
  final QuestionVisibility? visibility;

  bool isVisible(Map<String, QuestionnaireAnswer> answers) => visibility?.call(answers) ?? true;
}
