import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';

class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: icon != null
            ? Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDestructive ? AppColors.errorLight : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                ),
              )
            : null,
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 20.sp,
          color: isDestructive ? AppColors.error.withValues(alpha: 0.5) : AppColors.textTertiary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }
}
