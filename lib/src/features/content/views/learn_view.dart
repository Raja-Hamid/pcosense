import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';

class LearnView extends StatefulWidget {
  const LearnView({super.key});
  @override
  State<LearnView> createState() => _LearnViewState();
}

class _LearnViewState extends State<LearnView> {
  final query = TextEditingController();
  String filter = 'All';
  final categories = const ['All', 'Basics', 'Symptoms', 'Medical', 'Health', 'Treatment'];
  final articles = const [
    ('What is PCOS?', 'Basics', 'PCOS is a hormonal disorder common in reproductive age women. It involves a combination of genetic and environmental factors.'),
    ('Common Symptoms', 'Symptoms', 'Irregular periods, acne, excess hair growth, and weight gain are the most common signs to watch for.'),
    ('Diagnosis Methods', 'Medical', 'Diagnosis typically involves a combination of physical exams, blood tests for hormones, and pelvic ultrasound.'),
    ('PCOS and Fertility', 'Health', 'PCOS can affect ovulation but is highly manageable with proper medical guidance and lifestyle changes.'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = articles.where((a) {
      final matchCategory = filter == 'All' || a.$2 == filter;
      final q = query.text.toLowerCase();
      final matchSearch = a.$1.toLowerCase().contains(q) || a.$3.toLowerCase().contains(q);
      return matchCategory && matchSearch;
    }).toList();

    return AppScaffold(
      title: 'Learning Hub',
      showBack: false,
      withNav: true,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            child: Column(
              children: [
                Container(
                  height: 140.h,
                  width: double.infinity,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.auto_stories_rounded, color: Colors.white, size: 32.sp),
                      SizedBox(height: 12.h),
                      Text(
                        'Knowledge is the first step\nto better health.',
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontSize: 18.sp, height: 1.3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: query,
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20.sp),
                    hintText: 'Search articles...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final c = categories[index];
                      final isSelected = c == filter;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        onSelected: (_) => setState(() => filter = c),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        showCheckmark: false,
                        side: BorderSide.none,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final a = filtered[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20.sp),
                      ),
                      title: Text(a.$1, style: AppTextStyles.labelLarge),
                      subtitle: Text(a.$2, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                          child: Text(
                            a.$3,
                            style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textPrimary.withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
