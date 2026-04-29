import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/tracker/controllers/tracker_controller.dart';
import 'package:pcosense/src/features/tracker/widgets/task_card.dart';

class TrackerView extends GetView<TrackerController> {
  const TrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final symptoms = const [
      'Cramps', 'Bloating', 'Headache', 'Fatigue', 
      'Acne', 'Mood Swings', 'Cravings', 'Back Pain'
    ];
    
    const taskLabels = {
      'water': 'Drink 8 glasses of water',
      'sleep': '7+ hours of sleep',
      'exercise': '30 min exercise',
      'meditation': '10 min meditation',
    };

    return AppScaffold(
      title: 'Daily Tracker',
      showBack: false,
      withNav: true,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.symptomHistory),
          icon: const Icon(Icons.history_rounded, color: AppColors.primary),
        ),
      ],
      child: Obx(
        () => ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                ),
                Text('Track Your Progress', style: AppTextStyles.h2),
              ],
            ),
            SizedBox(height: 24.h),
            
            Text('Daily Habits', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            ...['water', 'sleep', 'exercise', 'meditation'].map((e) => TaskCard(
                  label: taskLabels[e]!,
                  value: controller.completedTasks.contains(e),
                  onChanged: () => controller.toggleTask(e),
                )),
            
            SizedBox(height: 24.h),
            Text('Symptoms Today', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 0,
              children: symptoms.map((s) {
                final isSelected = controller.selectedSymptoms.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleSymptom(s),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                );
              }).toList(),
            ),
            
            SizedBox(height: 32.h),
            PrimaryButton(
              text: "Save Today's Log",
              onTap: controller.saveTodayLog,
            ),
            
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Consistency is key to hormonal health. Keep it up!',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
