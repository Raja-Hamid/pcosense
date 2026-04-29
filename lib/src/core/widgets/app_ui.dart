import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.child,
    this.showBack = true,
    this.withNav = false,
    this.actions,
    this.onBack,
    super.key,
  });

  final String title;
  final Widget child;
  final bool showBack;
  final bool withNav;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(title, style: AppTextStyles.h3),
        leading: showBack
            ? IconButton(
                onPressed: onBack ?? () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.textPrimary,
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: withNav ? const BottomNav() : null,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    this.width,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.w,
                width: 20.w,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(text, style: AppTextStyles.button),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.text,
    required this.onTap,
    this.width,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 54.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Text(text, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final route = Get.currentRoute;
    final tabs = <({String label, IconData icon, String route})>[
      (label: 'Home', icon: Icons.grid_view_rounded, route: AppRoutes.home),
      (label: 'Track', icon: Icons.calendar_today_rounded, route: AppRoutes.tracker),
      (label: 'Scan', icon: Icons.add_circle_outline_rounded, route: AppRoutes.scan),
      (label: 'Learn', icon: Icons.auto_stories_rounded, route: AppRoutes.learn),
      (label: 'Profile', icon: Icons.person_outline_rounded, route: AppRoutes.profile),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 12.h,
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tab) {
          final isSelected = route == tab.route;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!isSelected) Get.offAllNamed(tab.route);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 24.sp,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
