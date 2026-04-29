import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/assessment/logic/risk_fusion.dart';
import 'package:pcosense/src/features/content/controllers/scan_controller.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ultrasound Analysis',
      showBack: false,
      withNav: true,
      child: Obx(
        () => ListView(
          padding: EdgeInsets.all(24.w),
          children: <Widget>[
            _infoBanner(),
            SizedBox(height: 24.h),
            if (!controller.hasQuestionnaire) _questionnairePromptCard(),
            if (!controller.hasQuestionnaire) SizedBox(height: 16.h),
            _imageDropTarget(),
            if (controller.errorMessage.value.isNotEmpty) ...<Widget>[
              SizedBox(height: 16.h),
              _errorBanner(controller.errorMessage.value),
            ],
            SizedBox(height: 24.h),
            _actionArea(),
            if (controller.hasResult) ...<Widget>[
              SizedBox(height: 28.h),
              _resultCard(controller.fusedResult.value!),
              SizedBox(height: 16.h),
              PrimaryButton(
                text: 'View Recommendations',
                onTap: () => Get.toNamed(AppRoutes.recommendations),
              ),
              SizedBox(height: 12.h),
              SecondaryButton(
                text: 'Open Full Report',
                onTap: () => Get.toNamed(AppRoutes.report),
              ),
            ],
            SizedBox(height: 32.h),
            Text(
              'Disclaimer: This analysis is for informational purposes only and is not a substitute for professional medical advice.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Upload an ovarian ultrasound image. The image is analyzed by the PCOSense AI model and combined with your latest questionnaire result.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionnairePromptCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.assignment_outlined, color: AppColors.warning, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'You haven\'t taken the questionnaire yet. The image alone gives a partial signal — take the questionnaire for a combined risk profile.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.questionnaire),
            child: Text(
              'Take it',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageDropTarget() {
    final selected = controller.selectedFile.value;
    return GestureDetector(
      onTap: controller.isBusy ? null : controller.pickImage,
      child: Container(
        height: 280.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: selected == null ? AppColors.border : AppColors.primary,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: selected == null
            ? _emptyDropContents()
            : _previewContents(selected.path),
      ),
    );
  }

  Widget _emptyDropContents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_upload_rounded,
            size: 40.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 20.h),
        Text('Tap to upload image', style: AppTextStyles.bodyLarge),
        SizedBox(height: 8.h),
        Text(
          'PNG, JPG up to 10MB',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _previewContents(String path) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.file(File(path), fit: BoxFit.cover),
        if (!controller.isBusy)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: IconButton(
              onPressed: controller.clearSelection,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        if (controller.isBusy)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 12.h),
                  Text(
                    controller.stage.value == 'uploading'
                        ? 'Uploading… ${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%'
                        : 'Analyzing with AI…',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionArea() {
    if (controller.isBusy) {
      return const SizedBox.shrink();
    }
    if (controller.selectedFile.value == null) {
      return PrimaryButton(text: 'Choose from Gallery', onTap: controller.pickImage);
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: SecondaryButton(
            text: 'Replace',
            onTap: controller.pickImage,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: PrimaryButton(
            text: controller.hasResult ? 'Re-analyze' : 'Analyze Image',
            onTap: controller.analyze,
          ),
        ),
      ],
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(FusedRiskResult fused) {
    final accent = _accentForCategory(fused.fusedCategory);
    final accentLight = _accentLightForCategory(fused.fusedCategory);
    final pred = fused.prediction;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: accentLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_iconForCategory(fused.fusedCategory), color: accent, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Combined risk',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(fused.fusedLevel, style: AppTextStyles.h3.copyWith(color: accent)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(fused.fusedHeadline, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
          SizedBox(height: 18.h),
          if (pred != null && pred.isCompleted) _imageReadingTile(pred, accent, accentLight),
          if (pred != null && pred.isCompleted) SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: accentLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              fused.imageInsight,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageReadingTile(dynamic pred, Color accent, Color accentLight) {
    final isInfected = pred.isInfected as bool;
    final conf = (pred.confidence as double?) ?? 0.0;
    return Row(
      children: <Widget>[
        Expanded(
          child: _statTile(
            label: 'Image label',
            value: isInfected ? 'Polycystic features' : 'No polycystic features',
            color: accent,
            background: accentLight,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statTile(
            label: 'Confidence',
            value: '${(conf * 100).toStringAsFixed(1)}%',
            color: accent,
            background: accentLight,
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _accentForCategory(String category) {
    switch (category) {
      case 'low':
        return AppColors.success;
      case 'high':
      case 'urgent':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _accentLightForCategory(String category) {
    switch (category) {
      case 'low':
        return AppColors.successLight;
      case 'high':
      case 'urgent':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'low':
        return Icons.health_and_safety_outlined;
      case 'high':
      case 'urgent':
        return Icons.priority_high_rounded;
      default:
        return Icons.insights_outlined;
    }
  }
}
