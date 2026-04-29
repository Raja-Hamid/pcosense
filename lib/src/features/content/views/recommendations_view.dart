import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/content/controllers/recommendation_controller.dart';
import 'package:pcosense/src/features/content/models/personalized_plan_model.dart';

class RecommendationsView extends GetView<RecommendationController> {
  const RecommendationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Health Recommendations',
      child: Obx(() {
        final plan = controller.plan.value;

        if (controller.loading.value && plan == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasAssessment) {
          return _emptyState();
        }

        if (plan == null) {
          return _errorState(controller.errorMessage.value);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshForLatest,
          child: ListView(
            padding: EdgeInsets.all(24.w),
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _heroCard(plan),
              SizedBox(height: 22.h),
              ...plan.sections.map(_sectionCard),
              SizedBox(height: 16.h),
              Text(
                'These suggestions are general lifestyle guidance, not medical advice. Always discuss significant changes with a clinician.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _heroCard(PersonalizedPlan plan) {
    final accent = _accentForCategory(plan.fusedCategory);
    final accentDark = _accentDarkForCategory(plan.fusedCategory);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[accent, accentDark],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(_iconForCategory(plan.fusedCategory), color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  plan.headline,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            plan.summary,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(PlanSection section) {
    final color = _colorForIcon(section.iconKey);
    final bgColor = _bgForIcon(section.iconKey);
    final icon = _materialIconForKey(section.iconKey);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          initiallyExpanded: section.id == 'clinical' || section.id == 'diet',
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          title: Text(section.title, style: AppTextStyles.labelLarge),
          subtitle: Text(
            section.subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
          iconColor: AppColors.textTertiary,
          children: section.items.map((item) => _planItemTile(item, color)).toList(),
        ),
      ),
    );
  }

  Widget _planItemTile(PlanItem item, Color accent) {
    final isHighPriority = item.priority >= 4;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isHighPriority
            ? accent.withValues(alpha: 0.06)
            : AppColors.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isHighPriority
              ? accent.withValues(alpha: 0.25)
              : AppColors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                isHighPriority ? Icons.flag_rounded : Icons.check_circle_rounded,
                size: 18.sp,
                color: accent,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              if (isHighPriority)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'Priority',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 28.w),
            child: Text(
              item.rationale,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.spa_outlined, size: 64.sp, color: AppColors.textTertiary),
            SizedBox(height: 16.h),
            Text('No screening yet', style: AppTextStyles.h2),
            SizedBox(height: 8.h),
            Text(
              'Take the questionnaire so we can tailor recommendations to you.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              text: 'Start screening',
              onTap: () => Get.toNamed(AppRoutes.questionnaire),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 56.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text('Could not load your plan', style: AppTextStyles.h3),
            SizedBox(height: 8.h),
            Text(
              message.isEmpty ? 'Please try again.' : message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PrimaryButton(text: 'Retry', onTap: controller.refreshForLatest),
          ],
        ),
      ),
    );
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'low':
        return AppColors.success;
      case 'high':
      case 'urgent':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _accentDarkForCategory(String category) {
    switch (category) {
      case 'low':
        return const Color(0xFF047857);
      case 'high':
      case 'urgent':
        return const Color(0xFF991B1B);
      default:
        return AppColors.primaryDark;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'low':
        return Icons.health_and_safety_outlined;
      case 'high':
      case 'urgent':
        return Icons.priority_high_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _colorForIcon(String key) {
    switch (key) {
      case 'diet':
        return const Color(0xFF059669);
      case 'exercise':
        return const Color(0xFF0284C7);
      case 'sleep':
        return AppColors.primary;
      case 'mental':
        return const Color(0xFFD97706);
      case 'cycle':
        return const Color(0xFFDB2777);
      case 'clinical':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _bgForIcon(String key) {
    switch (key) {
      case 'diet':
        return const Color(0xFFECFDF5);
      case 'exercise':
        return const Color(0xFFF0F9FF);
      case 'sleep':
        return AppColors.primaryLight;
      case 'mental':
        return const Color(0xFFFFFBEB);
      case 'cycle':
        return const Color(0xFFFCE7F3);
      case 'clinical':
        return AppColors.errorLight;
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _materialIconForKey(String key) {
    switch (key) {
      case 'diet':
        return Icons.restaurant_menu_rounded;
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'sleep':
        return Icons.nights_stay_rounded;
      case 'mental':
        return Icons.psychology_rounded;
      case 'cycle':
        return Icons.calendar_today_rounded;
      case 'clinical':
        return Icons.medical_information_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
