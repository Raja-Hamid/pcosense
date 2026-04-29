import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/tracker/controllers/tracker_controller.dart';

class SymptomHistoryView extends GetView<TrackerController> {
  const SymptomHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Symptom History',
      child: Obx(
        () {
          if (controller.symptomLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 64.sp, color: AppColors.textTertiary),
                  SizedBox(height: 16.h),
                  Text('No history recorded yet', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(24.w),
            children: [
              Text('Weekly Overview', style: AppTextStyles.h3),
              SizedBox(height: 24.h),
              Container(
                height: 220.h,
                padding: EdgeInsets.fromLTRB(10.w, 20.h, 20.w, 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 8,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < controller.symptomLogs.length) {
                              final date = DateTime.parse(controller.symptomLogs[value.toInt()].dateIso);
                              return Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  DateFormat('E').format(date),
                                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      controller.symptomLogs.length.clamp(0, 7),
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: controller.symptomLogs[i].symptoms.length.toDouble().clamp(0.5, 8.0),
                            color: AppColors.primary,
                            width: 16.w,
                            borderRadius: BorderRadius.circular(4.r),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 8,
                              color: AppColors.primaryLight.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text('Recent Logs', style: AppTextStyles.h3),
              SizedBox(height: 16.h),
              ...controller.symptomLogs.reversed.map((e) => _buildLogTile(e)),
              SizedBox(height: 20.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogTile(dynamic log) {
    final date = DateTime.parse(log.dateIso);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        title: Text(
          DateFormat('EEEE, MMM d').format(date),
          style: AppTextStyles.labelLarge,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: log.symptoms.map<Widget>((s) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                s.toString(),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
            )).toList(),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      ),
    );
  }
}
