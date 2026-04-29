class QuestionnaireOption {
  const QuestionnaireOption({
    required this.id,
    required this.label,
    this.description,
    this.semanticLabel,
  });

  final String id;
  final String label;
  final String? description;
  final String? semanticLabel;
}
