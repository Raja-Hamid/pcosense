import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/questionnaire/models/risk_assessment_result.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final result = (Get.arguments as RiskAssessmentResult?) ?? RiskAssessmentResult.fallback();

    if (result.shouldStopForUrgentCare) {
      return _UrgentResultsView(result: result);
    }

    final accentColor = _accentColor(result);
    final accentLight = _accentLightColor(result);
    final icon = _iconFor(result);

    return AppScaffold(
      title: 'Screening result',
      showBack: false,
      child: ListView(
        padding: EdgeInsets.all(24.w),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accentColor,
                  accentColor.withValues(alpha: 0.78),
                ],
              ),
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30.sp),
                ),
                SizedBox(height: 18.h),
                Text(
                  result.level,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 30.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  result.headline,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          _DisclaimerCard(text: result.disclaimer),
          SizedBox(height: 18.h),
          _SectionCard(
            title: 'What this means',
            child: Text(
              result.explanation,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                height: 1.65,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          _SectionCard(
            title: 'What contributed most',
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: result.contributors
                  .map(
                    (contributor) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: accentLight,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        contributor,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 18.h),
          _SectionCard(
            title: 'Recommended next steps',
            child: Column(
              children: result.nextSteps
                  .map(
                    (step) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: accentLight,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Icon(Icons.arrow_forward_rounded, size: 14.sp, color: accentColor),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              step,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary.withValues(alpha: 0.82),
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 24.h),
          if (result.shouldRecommendUltrasoundUpload) ...<Widget>[
            PrimaryButton(
              text: 'Continue to ultrasound upload',
              onTap: () => Get.toNamed(AppRoutes.scan),
            ),
            SizedBox(height: 12.h),
          ] else ...<Widget>[
            PrimaryButton(
              text: 'View health education',
              onTap: () => Get.toNamed(AppRoutes.learn),
            ),
            SizedBox(height: 12.h),
          ],
          SecondaryButton(
            text: 'Retake questionnaire',
            onTap: () => Get.offNamed(AppRoutes.questionnaire),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.learn),
            child: Text(
              'Open learning resources',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  static Color _accentColor(RiskAssessmentResult result) {
    switch (result.category) {
      case 'low':
        return AppColors.success;
      case 'high':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  static Color _accentLightColor(RiskAssessmentResult result) {
    switch (result.category) {
      case 'low':
        return AppColors.successLight;
      case 'high':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  static IconData _iconFor(RiskAssessmentResult result) {
    switch (result.category) {
      case 'low':
        return Icons.health_and_safety_outlined;
      case 'high':
        return Icons.priority_high_rounded;
      default:
        return Icons.insights_outlined;
    }
  }
}

class _UrgentResultsView extends StatelessWidget {
  const _UrgentResultsView({required this.result});

  final RiskAssessmentResult result;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Safety guidance',
      showBack: false,
      child: ListView(
        padding: EdgeInsets.all(24.w),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(Icons.local_hospital_outlined, color: Colors.white, size: 30.sp),
                ),
                SizedBox(height: 18.h),
                Text(
                  result.headline,
                  style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 28.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  result.explanation,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          _DisclaimerCard(text: result.disclaimer),
          SizedBox(height: 18.h),
          _SectionCard(
            title: 'What to do now',
            child: Column(
              children: result.nextSteps
                  .map(
                    (step) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Icon(Icons.warning_amber_rounded, size: 14.sp, color: AppColors.error),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              step,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary.withValues(alpha: 0.82),
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 24.h),
          PrimaryButton(
            text: 'Return to home',
            onTap: () => Get.offAllNamed(AppRoutes.home),
          ),
          SizedBox(height: 12.h),
          SecondaryButton(
            text: 'Retake later',
            onTap: () => Get.offNamed(AppRoutes.questionnaire),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
