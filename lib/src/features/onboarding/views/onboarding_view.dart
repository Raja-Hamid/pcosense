import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/onboarding/controllers/onboarding_controller.dart';
import 'package:pcosense/src/features/onboarding/widgets/slide_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final slides = const [
      (
        'Symptom Assessment',
        'Answer a quick questionnaire to evaluate your potential PCOS risk factors with AI precision.',
        Icons.medical_services_rounded,
      ),
      (
        'Ultrasound Analysis',
        'Our intelligent system analyzes ovarian ultrasound images to help detect signs of PCOS early.',
        Icons.document_scanner_rounded,
      ),
      (
        'Personalized Care',
        'Receive tailored dietary, exercise, and lifestyle guidance designed specifically for your needs.',
        Icons.auto_awesome_rounded,
      ),
    ];

    return Obx(() {
      final s = slides[controller.index.value];
      final isLast = controller.index.value == slides.length - 1;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.welcome),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey<int>(controller.index.value),
                    children: [
                      Container(
                        padding: EdgeInsets.all(32.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          s.$3,
                          size: 80.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 48.h),
                      Text(
                        s.$1,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        s.$2,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SlideIndicator(
                  current: controller.index.value,
                  total: slides.length,
                ),
                SizedBox(height: 40.h),
                PrimaryButton(
                  text: isLast ? 'Get Started' : 'Next Step',
                  onTap: controller.next,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      );
    });
  }
}
