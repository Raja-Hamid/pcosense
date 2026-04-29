import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: value ? AppColors.successLight.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: value ? AppColors.success.withValues(alpha: 0.2) : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (_) => onChanged(),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: value ? AppColors.success : AppColors.textPrimary,
            fontWeight: value ? FontWeight.w600 : FontWeight.w500,
            decoration: value ? TextDecoration.lineThrough : null,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.success,
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
