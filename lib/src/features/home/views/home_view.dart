import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/home/controllers/home_controller.dart';
import 'package:pcosense/src/features/home/widgets/quick_action_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.h,
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.background,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                            ),
                            Text(
                              controller.auth.user.value?.name.split(' ').first ?? 'User',
                              style: AppTextStyles.h2,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.notifications),
                        icon: const Icon(Icons.notifications_none_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.profile),
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              ((controller.auth.user.value?.name ?? 'U').split(' ').map((e) => e[0]).join()).substring(0, 1).toUpperCase(),
                              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 12.h),
                  _buildRiskCard(),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quick Actions', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
                      TextButton(
                        onPressed: () {},
                        child: Text('View All', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      QuickActionCard(
                        title: 'Assessment',
                        icon: Icons.assignment_outlined,
                        onTap: () => Get.toNamed(AppRoutes.questionnaire),
                      ),
                      QuickActionCard(
                        title: 'Upload Scan',
                        icon: Icons.document_scanner_outlined,
                        onTap: () => Get.toNamed(AppRoutes.scan),
                      ),
                      QuickActionCard(
                        title: 'Diet Plan',
                        icon: Icons.restaurant_menu_outlined,
                        onTap: () => Get.toNamed(AppRoutes.recommendations),
                      ),
                      QuickActionCard(
                        title: 'Learning Hub',
                        icon: Icons.menu_book_outlined,
                        onTap: () => Get.toNamed(AppRoutes.learn),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text('Your Daily Insights', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.success, size: 24.sp),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Daily Tip', style: AppTextStyles.labelLarge.copyWith(color: AppColors.success)),
                              SizedBox(height: 4.h),
                              Text(
                                '30 minutes of moderate exercise can improve insulin sensitivity significantly.',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildRiskCard() {
    final hasAssessment = controller.assessments.assessments.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasAssessment ? [AppColors.primary, AppColors.secondary] : [const Color(0xFF4B5563), const Color(0xFF1F2937)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: (hasAssessment ? AppColors.primary : Colors.black).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasAssessment ? 'Latest screening result' : 'Action required',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
              Icon(Icons.info_outline_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20.sp),
            ],
          ),
          SizedBox(height: 12.h),
          if (hasAssessment) ...[
            Text(
              controller.assessments.assessments.first.risk.level,
              style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              controller.assessments.assessments.first.risk.headline,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ] else ...[
            Text(
              'No Assessment Yet',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            SizedBox(height: 8.h),
            Text(
              'Take a structured questionnaire to review symptoms and next steps.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.questionnaire),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: hasAssessment ? AppColors.primary : const Color(0xFF1F2937),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(hasAssessment ? 'Retake screening' : 'Start screening', style: AppTextStyles.labelLarge),
            ),
          ),
        ],
      ),
    );
  }
}
