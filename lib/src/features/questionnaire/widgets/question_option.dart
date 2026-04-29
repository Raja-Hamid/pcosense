import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';

class QuestionOption extends StatelessWidget {
  const QuestionOption({
    required this.text,
    required this.selected,
    required this.onTap,
    this.description,
    this.semanticLabel,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final String? description;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: ListTile(
          onTap: onTap,
          minVerticalPadding: 14.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: description == null
              ? null
              : Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: selected
                ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                : null,
          ),
        ),
      ),
    );
  }
}
