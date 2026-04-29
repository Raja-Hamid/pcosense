import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/profile/controllers/profile_controller.dart';
import 'package:pcosense/src/features/profile/widgets/menu_item_tile.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      showBack: false,
      withNav: true,
      child: Obx(
        () => ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildStats(),
            SizedBox(height: 32.h),
            Text('Account Settings', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            MenuItemTile(
              label: 'Edit Profile',
              icon: Icons.person_outline_rounded,
              onTap: () => Get.toNamed(AppRoutes.editProfile),
            ),
            MenuItemTile(
              label: 'Assessment History',
              icon: Icons.history_rounded,
              onTap: () => Get.toNamed(AppRoutes.assessmentHistory),
            ),
            MenuItemTile(
              label: 'My Health Reports',
              icon: Icons.description_outlined,
              onTap: () => Get.toNamed(AppRoutes.report),
            ),
            MenuItemTile(
              label: 'Notifications',
              icon: Icons.notifications_none_rounded,
              onTap: () => Get.toNamed(AppRoutes.notifications),
            ),
            SizedBox(height: 24.h),
            Text('Support & Info', style: AppTextStyles.labelLarge),
            SizedBox(height: 12.h),
            MenuItemTile(
              label: 'Help & FAQ',
              icon: Icons.help_outline_rounded,
              onTap: () => Get.toNamed(AppRoutes.help),
            ),
            MenuItemTile(
              label: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => Get.toNamed(AppRoutes.privacy),
            ),
            MenuItemTile(
              label: 'Terms of Service',
              icon: Icons.gavel_rounded,
              onTap: () => Get.toNamed(AppRoutes.terms),
            ),
            MenuItemTile(
              label: 'About PCOSense',
              icon: Icons.info_outline_rounded,
              onTap: () => Get.toNamed(AppRoutes.about),
            ),
            SizedBox(height: 12.h),
            MenuItemTile(
              label: 'Logout',
              icon: Icons.logout_rounded,
              isDestructive: true,
              onTap: () async {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await controller.auth.logout();
                  Get.offAllNamed(AppRoutes.welcome);
                }
              },
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                'Version 1.0.0 (Build 12)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = controller.auth.user.value;
    final name = user?.name ?? 'User';
    final initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .substring(0, name.contains(' ') ? 2 : 1)
        .toUpperCase();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Member since ${user?.joinedDate ?? 'Recently'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            '${controller.assessments.assessments.length}',
            'Tests Taken',
            Icons.assignment_turned_in_outlined,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _statCard(
            '${controller.tracker.symptomLogs.length}',
            'Days Logged',
            Icons.calendar_today_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp)),
        ],
      ),
    );
  }
}
