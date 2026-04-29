import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';

class SlideIndicator extends StatelessWidget {
  const SlideIndicator({required this.current, required this.total, super.key});
  
  final int current;
  final int total;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: i == current ? 32.w : 10.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: i == current ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: i == current ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
        ),
      ),
    );
  }
}
