import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';

class AssessmentHistoryView extends GetView<AssessmentController> {
  const AssessmentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Screening history',
      child: Obx(
        () {
          if (controller.assessments.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.assignment_late_outlined, size: 48.sp, color: AppColors.primary),
                    ),
                    SizedBox(height: 24.h),
                    Text('No screenings yet', style: AppTextStyles.h3),
                    SizedBox(height: 12.h),
                    Text(
                      'Complete your first screening questionnaire to start saving results here.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: 32.h),
                    PrimaryButton(
                      text: 'Start screening',
                      width: 220.w,
                      onTap: () => Get.toNamed(AppRoutes.questionnaire),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: controller.assessments.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final assessment = controller.assessments[index];
              final color = _colorForCategory(assessment.risk.category);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  onTap: () => Get.toNamed(AppRoutes.results, arguments: assessment.risk),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconForCategory(assessment.risk.category), color: color, size: 24.sp),
                  ),
                  title: Text(
                    assessment.risk.level,
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 4.h),
                      Text(
                        assessment.risk.headline,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.78),
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(assessment.dateIso)),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _confirmDelete(assessment.id),
                    icon: Icon(Icons.delete_outline_rounded, color: AppColors.textTertiary, size: 20.sp),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete screening'),
        content: const Text('Are you sure you want to remove this saved screening result?'),
        actions: <Widget>[
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteAssessment(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'low':
        return AppColors.success;
      case 'high':
      case 'urgent':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'low':
        return Icons.health_and_safety_outlined;
      case 'high':
        return Icons.priority_high_rounded;
      case 'urgent':
        return Icons.local_hospital_outlined;
      default:
        return Icons.insights_outlined;
    }
  }
}
