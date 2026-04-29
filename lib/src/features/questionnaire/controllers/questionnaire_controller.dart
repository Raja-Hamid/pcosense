import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/questionnaire/data/questionnaire_constants.dart';
import 'package:pcosense/src/features/questionnaire/data/questionnaire_content.dart';
import 'package:pcosense/src/features/questionnaire/logic/questionnaire_scoring.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_answer.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_option.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_question.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_section.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';

class QuestionnaireController extends GetxController {
  QuestionnaireController();

  final AssessmentController _assessmentController = Get.find<AssessmentController>();
  final QuestionnaireScoring _scoring = QuestionnaireScoring();

  late final List<QuestionnaireSection> sections = QuestionnaireContent.buildSections();
  late final List<_QuestionnaireScreen> _screens = <_QuestionnaireScreen>[
    const _QuestionnaireScreen.intro(),
    _QuestionnaireScreen.section(_sectionById('basic_profile')),
    _QuestionnaireScreen.section(_sectionById('menstrual_pattern')),
    _QuestionnaireScreen.section(_sectionById('menstrual_context')),
    _QuestionnaireScreen.section(_sectionById('hyperandrogenism')),
    const _QuestionnaireScreen.recommendation(),
    _QuestionnaireScreen.section(_sectionById('metabolic_context')),
    _QuestionnaireScreen.section(_sectionById('wellbeing_context')),
    _QuestionnaireScreen.section(_sectionById('clinical_context')),
    _QuestionnaireScreen.section(_sectionById('safety')),
  ];

  final currentScreenIndex = 0.obs;
  final validationMessage = ''.obs;
  final answers = <String, QuestionnaireAnswer>{}.obs;
  final isSubmitting = false.obs;
  final _textControllers = <String, TextEditingController>{};
  String? _pendingSubmissionId;

  bool _ultrasoundPromptCompleted = false;

  _QuestionnaireScreen get _currentScreen => _screens[currentScreenIndex.value];
  QuestionnaireSection get currentSection => _currentScreen.section!;

  bool get isIntroScreen => _currentScreen.type == _QuestionnaireScreenType.intro;
  bool get isRecommendationScreen => _currentScreen.type == _QuestionnaireScreenType.recommendation;
  bool get isSectionScreen => _currentScreen.type == _QuestionnaireScreenType.section;
  bool get canSkipCurrentSection => isSectionScreen && currentSection.isOptional;
  bool get canGoBack => currentScreenIndex.value > 0;
  bool get isLastSection => isSectionScreen && currentSection.id == sections.last.id;

  int get totalSections => sections.length;

  int get currentProgressStep {
    if (isIntroScreen) {
      return 0;
    }

    if (isRecommendationScreen) {
      return 4;
    }

    return sections.indexWhere((section) => section.id == currentSection.id) + 1;
  }

  double get progress => totalSections == 0 ? 0 : currentProgressStep / totalSections;

  String get title {
    if (isIntroScreen) {
      return 'PCOS screening';
    }

    if (isRecommendationScreen) {
      return 'Suggested next step';
    }

    return 'PCOS screening';
  }

  String get progressLabel {
    if (isIntroScreen) {
      return 'Before you start';
    }

    if (isRecommendationScreen) {
      return 'Recommended follow-up';
    }

    return 'Section $currentProgressStep of $totalSections';
  }

  String get primaryActionLabel {
    if (isIntroScreen) {
      return 'Start screening';
    }

    if (isRecommendationScreen) {
      return 'Continue screening';
    }

    return isLastSection ? 'Finish screening' : 'Next';
  }

  String get recommendationTitle {
    return isMinor
        ? 'Your answers suggest that clinical follow-up may be helpful'
        : 'Ultrasound review may be a helpful next step';
  }

  String get recommendationBody {
    final base =
        'You reported irregular cycle patterns together with skin or hair symptoms. That combination is often a reason to review symptoms with a clinician.';

    if (isMinor) {
      return '$base Because you are under 18, this screening stays intentionally cautious and does not use diagnostic language. If symptoms persist, age-appropriate clinical review can help decide whether ultrasound or other evaluation is useful.';
    }

    return '$base If you already have imaging, you can upload it next. If not, consider asking a clinician whether ultrasound is appropriate for you.';
  }

  bool get isMinor => valueFor(QuestionnaireIds.ageGroup) == QuestionnaireValues.under18;

  List<QuestionnaireQuestion> get visibleQuestions {
    if (!isSectionScreen) {
      return const <QuestionnaireQuestion>[];
    }

    final snapshot = Map<String, QuestionnaireAnswer>.from(answers);
    return currentSection.questions.where((question) => question.isVisible(snapshot)).toList();
  }

  TextEditingController textControllerFor(String questionId) {
    return _textControllers.putIfAbsent(
      questionId,
      () => TextEditingController(text: answers[questionId]?.value ?? ''),
    );
  }

  String? valueFor(String questionId) => answers[questionId]?.value;

  String? displayValueFor(String questionId) => answers[questionId]?.displayValue;

  QuestionnaireOption? selectedOptionFor(QuestionnaireQuestion question) {
    final selectedValue = valueFor(question.id);
    if (selectedValue == null) {
      return null;
    }

    for (final option in question.options) {
      if (option.id == selectedValue) {
        return option;
      }
    }

    return null;
  }

  double? get bmi {
    final heightCm = double.tryParse(valueFor(QuestionnaireIds.heightCm) ?? '');
    final weightKg = double.tryParse(valueFor(QuestionnaireIds.weightKg) ?? '');
    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return null;
    }

    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  bool get shouldShowBmi => bmi != null;

  void selectOption(QuestionnaireQuestion question, QuestionnaireOption option) {
    answers[question.id] = QuestionnaireAnswer(
      questionId: question.id,
      questionText: question.title,
      value: option.id,
      displayValue: option.label,
    );
    _cleanupConditionalAnswers();
    validationMessage.value = '';
    answers.refresh();
  }

  void updateNumberAnswer(QuestionnaireQuestion question, String rawValue) {
    final sanitized = rawValue.replaceAll(RegExp(r'[^0-9.]'), '');
    final controller = _textControllers[question.id];
    if (controller != null && controller.text != sanitized) {
      controller.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }

    if (sanitized.isEmpty) {
      answers.remove(question.id);
    } else {
      answers[question.id] = QuestionnaireAnswer(
        questionId: question.id,
        questionText: question.title,
        value: sanitized,
        displayValue: question.unitLabel == null ? sanitized : '$sanitized ${question.unitLabel}',
      );
    }

    validationMessage.value = '';
    answers.refresh();
  }

  void clearOptionalSectionAnswers() {
    if (!canSkipCurrentSection) {
      return;
    }

    for (final question in currentSection.questions) {
      answers.remove(question.id);
      _textControllers[question.id]?.clear();
    }

    answers.refresh();
    validationMessage.value = '';
  }

  Future<void> next() async {
    if (isSubmitting.value) {
      return;
    }

    validationMessage.value = '';

    if (isIntroScreen) {
      _moveToNextVisibleScreen();
      return;
    }

    if (isRecommendationScreen) {
      _ultrasoundPromptCompleted = true;
      _moveToNextVisibleScreen();
      return;
    }

    final error = _validateCurrentSection();
    if (error != null) {
      validationMessage.value = error;
      return;
    }

    if (isLastSection) {
      await _completeAssessment();
      return;
    }

    _moveToNextVisibleScreen();
  }

  void skipCurrentSection() {
    if (!canSkipCurrentSection) {
      return;
    }

    clearOptionalSectionAnswers();
    _moveToNextVisibleScreen();
  }

  void back() {
    validationMessage.value = '';
    if (!canGoBack) {
      Get.back();
      return;
    }

    final previousIndex = _previousVisibleScreenIndex(from: currentScreenIndex.value);
    if (previousIndex == null) {
      Get.back();
      return;
    }

    currentScreenIndex.value = previousIndex;
  }

  Future<bool> handleSystemBack() async {
    if (!canGoBack) {
      return true;
    }

    back();
    return false;
  }

  List<QuestionnaireAnswer> buildOrderedAnswers() {
    final orderedAnswers = <QuestionnaireAnswer>[];

    for (final section in sections) {
      for (final question in section.questions) {
        final answer = answers[question.id];
        if (answer != null) {
          orderedAnswers.add(answer);
        }
      }
    }

    return orderedAnswers;
  }

  @override
  void onClose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> _completeAssessment() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    _pendingSubmissionId ??= _buildSubmissionId();
    final result = _isUrgentFlow
        ? RiskAssessmentResult.urgentCare(isMinor: isMinor)
        : _scoring.assess(Map<String, QuestionnaireAnswer>.from(answers));

    try {
      await _assessmentController.saveAssessment(
        result,
        buildOrderedAnswers(),
        submissionId: _pendingSubmissionId,
      );
      await Get.toNamed(AppRoutes.results, arguments: result);
    } finally {
      isSubmitting.value = false;
    }
  }

  String _buildSubmissionId() {
    final seed = '${DateTime.now().millisecondsSinceEpoch}|${answers.values.map((answer) => '${answer.questionId}:${answer.value}').join('|')}';
    return seed.hashCode.abs().toString();
  }

  QuestionnaireSection _sectionById(String sectionId) {
    return sections.firstWhere((section) => section.id == sectionId);
  }

  String? _validateCurrentSection() {
    final missingQuestions = visibleQuestions
        .where((question) => question.isRequired && (answers[question.id]?.value.isEmpty ?? true))
        .map((question) => question.title)
        .toList();

    if (missingQuestions.isEmpty) {
      return null;
    }

    if (missingQuestions.length == 1) {
      return 'Please answer "${missingQuestions.first}" before continuing.';
    }

    return 'Please answer the required questions before continuing.';
  }

  void _cleanupConditionalAnswers() {
    if (valueFor(QuestionnaireIds.excessHair) != QuestionnaireValues.yes) {
      answers.remove(QuestionnaireIds.excessHairSeverity);
    }

    if (valueFor(QuestionnaireIds.ovarianUltrasound) != QuestionnaireValues.yes) {
      answers.remove(QuestionnaireIds.polycysticAppearance);
    }
  }

  bool get _shouldShowRecommendationScreen {
    return !_ultrasoundPromptCompleted && _scoring.shouldShowUltrasoundRecommendation(Map<String, QuestionnaireAnswer>.from(answers));
  }

  bool get _isUrgentFlow => valueFor(QuestionnaireIds.urgentSymptoms) == QuestionnaireValues.yes;

  void _moveToNextVisibleScreen() {
    final nextIndex = _nextVisibleScreenIndex(from: currentScreenIndex.value);
    if (nextIndex != null) {
      currentScreenIndex.value = nextIndex;
    }
  }

  int? _nextVisibleScreenIndex({required int from}) {
    for (var index = from + 1; index < _screens.length; index++) {
      if (_isScreenVisible(_screens[index])) {
        return index;
      }
    }

    return null;
  }

  int? _previousVisibleScreenIndex({required int from}) {
    for (var index = from - 1; index >= 0; index--) {
      if (_isScreenVisible(_screens[index])) {
        return index;
      }
    }

    return null;
  }

  bool _isScreenVisible(_QuestionnaireScreen screen) {
    if (screen.type != _QuestionnaireScreenType.recommendation) {
      return true;
    }

    return _shouldShowRecommendationScreen;
  }
}

enum _QuestionnaireScreenType {
  intro,
  section,
  recommendation,
}

class _QuestionnaireScreen {
  const _QuestionnaireScreen.intro()
      : type = _QuestionnaireScreenType.intro,
        section = null;

  const _QuestionnaireScreen.section(this.section) : type = _QuestionnaireScreenType.section;

  const _QuestionnaireScreen.recommendation()
      : type = _QuestionnaireScreenType.recommendation,
        section = null;

  final _QuestionnaireScreenType type;
  final QuestionnaireSection? section;
}
