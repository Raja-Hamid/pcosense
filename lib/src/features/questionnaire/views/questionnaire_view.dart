import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/questionnaire/controllers/questionnaire_controller.dart';
import 'package:pcosense/src/features/questionnaire/data/questionnaire_content.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_option.dart';
import 'package:pcosense/src/features/questionnaire/models/questionnaire_question.dart';
import 'package:pcosense/src/features/questionnaire/widgets/question_option.dart';

class QuestionnaireView extends GetView<QuestionnaireController> {
  const QuestionnaireView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.back();
        }
      },
      child: Obx(
        () => AppScaffold(
          title: controller.title,
          showBack: true,
          onBack: controller.back,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFF7F7FD), Color(0xFFFDFBFF)],
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  child: _ProgressHeader(controller: controller),
                ),
                if (controller.validationMessage.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                    child: _InlineAlert(
                      icon: Icons.error_outline_rounded,
                      backgroundColor: AppColors.errorLight,
                      foregroundColor: AppColors.error,
                      text: controller.validationMessage.value,
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 620.w),
                        child: controller.isIntroScreen
                            ? _IntroScreen(controller: controller)
                            : controller.isRecommendationScreen
                            ? _RecommendationScreen(controller: controller)
                            : _SectionScreen(controller: controller),
                      ),
                    ),
                  ),
                ),
                _BottomBar(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.controller});

  final QuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.progressLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      controller.isIntroScreen
                          ? 'A short screening questionnaire'
                          : controller.isRecommendationScreen
                          ? controller.recommendationTitle
                          : controller.currentSection.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
              if (controller.isMinor)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'Under 18',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: Semantics(
              label:
                  'Questionnaire progress ${(controller.progress * 100).round()} percent',
              child: LinearProgressIndicator(
                value: controller.progress,
                minHeight: 10.h,
                backgroundColor: AppColors.primaryLight,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroScreen extends StatelessWidget {
  const _IntroScreen({required this.controller});

  final QuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Screen symptoms in a structured way',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontSize: 26.sp,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'We will ask about cycle timing, skin and hair changes, lifestyle context, and any prior ultrasound information.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _InlineAlert(
          icon: Icons.info_outline_rounded,
          backgroundColor: const Color(0xFFF3F6FF),
          foregroundColor: const Color(0xFF334155),
          text: QuestionnaireContent.disclaimer,
        ),
        SizedBox(height: 20.h),
        _ChecklistCard(
          title: 'What to expect',
          items: const <String>[
            'Structured answers only, with optional skip for non-essential clinical context.',
            'This is a preliminary screening and education flow, not a diagnosis.',
            'Higher-risk patterns may trigger a recommendation to upload ultrasound and speak with a clinician.',
          ],
        ),
      ],
    );
  }
}

class _RecommendationScreen extends StatelessWidget {
  const _RecommendationScreen({required this.controller});

  final QuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.warning,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                controller.recommendationTitle,
                style: AppTextStyles.h2.copyWith(fontSize: 24.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                controller.recommendationBody,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.78),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _ChecklistCard(
          title: 'Why this appears',
          items: const <String>[
            'Cycle irregularity plus androgen-related symptoms is a pattern clinicians often review more closely.',
            'Ultrasound can add context, but it still does not replace clinician assessment.',
            'You can keep going with the screening first if you prefer.',
          ],
        ),
        SizedBox(height: 20.h),
        SecondaryButton(
          text: 'Go to ultrasound upload',
          onTap: () => Get.toNamed(AppRoutes.scan),
        ),
      ],
    );
  }
}

class _SectionScreen extends StatelessWidget {
  const _SectionScreen({required this.controller});

  final QuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final section = controller.currentSection;
      final questions = controller.visibleQuestions;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  section.title,
                  style: AppTextStyles.h2.copyWith(fontSize: 24.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  section.subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.55),
                ),
                if (section.supportingText != null) ...<Widget>[
                  SizedBox(height: 14.h),
                  _InlineAlert(
                    icon: section.isOptional
                        ? Icons.skip_next_rounded
                        : Icons.info_outline_rounded,
                    backgroundColor: AppColors.primaryLight.withValues(
                      alpha: 0.65,
                    ),
                    foregroundColor: AppColors.primaryDark,
                    text: section.supportingText!,
                  ),
                ],
                if (controller.shouldShowBmi &&
                    section.id == 'basic_profile') ...<Widget>[
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.monitor_weight_outlined,
                          color: AppColors.success,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Estimated BMI: ${controller.bmi!.toStringAsFixed(1)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 18.h),
          ...questions.map(
            (question) =>
                _QuestionCard(controller: controller, question: question),
          ),
        ],
      );
    });
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.controller, required this.question});

  final QuestionnaireController controller;
  final QuestionnaireQuestion question;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedOption = controller.selectedOptionFor(question);

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    question.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (question.isRequired)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'Required',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'Optional',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            if (question.helperText != null) ...<Widget>[
              SizedBox(height: 8.h),
              Text(
                question.helperText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            switch (question.inputType) {
              QuestionnaireInputType.choice => _ChoiceInput(
                question: question,
                selectedOption: selectedOption,
                onSelected: (option) => controller.selectOption(question, option),
              ),
              QuestionnaireInputType.number => _NumberInput(
                controller: controller,
                question: question,
              ),
              QuestionnaireInputType.dropdown => _DropdownInput(
                controller: controller,
                question: question,
              ),
            },
          ],
        ),
      );
    });
  }
}

class _ChoiceInput extends StatelessWidget {
  const _ChoiceInput({
    required this.question,
    required this.selectedOption,
    required this.onSelected,
  });

  final QuestionnaireQuestion question;
  final QuestionnaireOption? selectedOption;
  final ValueChanged<QuestionnaireOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.options
          .map(
            (option) => QuestionOption(
              text: option.label,
              description: option.description,
              selected: selectedOption?.id == option.id,
              semanticLabel:
                  option.semanticLabel ?? '${question.title}: ${option.label}',
              onTap: () => onSelected(option),
            ),
          )
          .toList(),
    );
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({required this.controller, required this.question});

  final QuestionnaireController controller;
  final QuestionnaireQuestion question;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: question.title,
      child: TextField(
        controller: controller.textControllerFor(question.id),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) => controller.updateNumberAnswer(question, value),
        decoration: InputDecoration(
          hintText: question.placeholder,
          suffixText: question.unitLabel,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 18.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.8),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.8),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
      ),
    );
  }
}

class _DropdownInput extends StatelessWidget {
  const _DropdownInput({required this.controller, required this.question});

  final QuestionnaireController controller;
  final QuestionnaireQuestion question;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedValue = controller.valueFor(question.id);
      return Semantics(
        label: question.title,
        child: DropdownButtonFormField<String>(
          key: ValueKey('${question.id}_${selectedValue ?? ''}'),
          initialValue: selectedValue,
          items: question.options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            final option = question.options.firstWhere(
              (item) => item.id == value,
            );
            controller.selectOption(question, option);
          },
          decoration: InputDecoration(
            hintText: 'Select an option',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 18.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
          ),
        ),
      );
    });
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final QuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (controller.canGoBack) ...<Widget>[
                    Expanded(
                      child: SecondaryButton(
                        text: 'Back',
                        onTap: controller.back,
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: controller.primaryActionLabel,
                      isLoading: controller.isSubmitting.value,
                      enabled: !controller.isSubmitting.value,
                      onTap: controller.next,
                    ),
                  ),
                ],
              ),
              if (controller.canSkipCurrentSection) ...<Widget>[
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: controller.skipCurrentSection,
                  child: Text(
                    'Skip this optional section',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _InlineAlert extends StatelessWidget {
  const _InlineAlert({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.text,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20.sp, color: foregroundColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: foregroundColor,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
          SizedBox(height: 14.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 2.h),
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.82),
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
