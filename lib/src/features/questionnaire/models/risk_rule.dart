import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';

typedef RiskPredicate = bool Function(Map<String, QuestionnaireAnswer> answers);

class RiskRule {
  const RiskRule({
    required this.id,
    required this.description,
    required this.contributorLabel,
    required this.weight,
    required this.applies,
  });

  final String id;
  final String description;
  final String contributorLabel;
  final int weight;
  final RiskPredicate applies;
}
