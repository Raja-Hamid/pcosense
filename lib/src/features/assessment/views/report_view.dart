import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/assessment/controllers/assessment_controller.dart';
import 'package:pcosense/src/features/assessment/logic/risk_fusion.dart';
import 'package:pcosense/src/features/assessment/models/assessment_model.dart';
import 'package:pcosense/src/features/assessment/services/report_pdf_service.dart';
import 'package:pcosense/src/features/auth/controllers/auth_controller.dart';
import 'package:pcosense/src/features/content/controllers/prediction_controller.dart';
import 'package:pcosense/src/features/content/controllers/recommendation_controller.dart';
import 'package:pcosense/src/features/content/models/prediction_model.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final assessments = Get.find<AssessmentController>();
    final auth = Get.find<AuthController>();
    final predictions = Get.find<PredictionController>();
    final pdfService = Get.find<ReportPdfService>();
    const fusion = RiskFusion();

    return AppScaffold(
      title: 'Screening report',
      child: Obx(() {
        final latest = assessments.assessments.isEmpty ? null : assessments.assessments.first;
        if (latest == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.description_outlined, size: 64.sp, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text(
                  'No report data yet',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        }

        final prediction = predictions.findByAssessmentId(latest.id);
        final isLoadingPredictions = predictions.loading.value && prediction == null;
        final fused = fusion.fuse(latest.risk, prediction);

        return ListView(
          padding: EdgeInsets.all(24.w),
          children: <Widget>[
            _buildPatientInfo(auth.user.value?.name, latest.dateIso),
            SizedBox(height: 24.h),
            _buildSummaryCard(latest, fused),
            SizedBox(height: 18.h),
            if (prediction != null && prediction.isCompleted)
              _buildImageAnalysisCard(prediction)
            else if (isLoadingPredictions)
              _buildImagePendingCard()
            else
              _buildNoImageCard(),
            SizedBox(height: 24.h),
            _buildContributorsCard(latest, fused),
            SizedBox(height: 32.h),
            Text('Detailed questionnaire answers', style: AppTextStyles.h3),
            SizedBox(height: 16.h),
            ...latest.answers.map((answer) => _buildAnswerTile(answer.questionText, answer.displayValue)),
            SizedBox(height: 32.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryButton(
                    text: 'Download PDF',
                    onTap: () => _downloadPdf(
                      pdfService: pdfService,
                      auth: auth,
                      latest: latest,
                      fused: fused,
                      prediction: prediction,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: SecondaryButton(
                    text: 'Share report',
                    onTap: () => _sharePdf(
                      pdfService: pdfService,
                      auth: auth,
                      latest: latest,
                      fused: fused,
                      prediction: prediction,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        );
      }),
    );
  }

  Widget _buildPatientInfo(String? name, String dateIso) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'REPORT DETAILS',
            style: AppTextStyles.bodySmall.copyWith(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name ?? 'N/A', style: AppTextStyles.labelLarge),
                    Text(
                      'Generated on ${DateFormat('MMMM d, y').format(DateTime.parse(dateIso))}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AssessmentModel latest, FusedRiskResult fused) {
    final color = fused.fusedCategory == 'low'
        ? AppColors.success
        : (fused.fusedCategory == 'high' || fused.fusedCategory == 'urgent')
            ? AppColors.error
            : AppColors.warning;
    final hasImage = fused.hasImage;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              fused.fusedCategory == 'low'
                  ? Icons.health_and_safety_outlined
                  : (fused.fusedCategory == 'high' || fused.fusedCategory == 'urgent')
                      ? Icons.priority_high_rounded
                      : Icons.insights_outlined,
              color: color,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasImage ? 'Combined screening result' : 'Latest screening result',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  fused.fusedLevel,
                  style: AppTextStyles.h3.copyWith(color: color),
                ),
                SizedBox(height: 6.h),
                Text(
                  fused.fusedHeadline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  latest.risk.explanation,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (fused.adjustedDirection == 'up') ...<Widget>[
                  SizedBox(height: 8.h),
                  Text(
                    'Image analysis raised the questionnaire-only category from ${latest.risk.level.toLowerCase()} to ${fused.fusedLevel.toLowerCase()}.',
                    style: AppTextStyles.bodySmall.copyWith(color: color, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysisCard(PredictionModel pred) {
    final isInfected = pred.isInfected;
    final color = isInfected ? AppColors.error : AppColors.success;
    final lightColor = isInfected ? AppColors.errorLight : AppColors.successLight;
    final conf = pred.confidence ?? 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.image_search_outlined, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Ultrasound image analysis', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Reading',
                          style: AppTextStyles.bodySmall.copyWith(color: color)),
                      SizedBox(height: 4.h),
                      Text(
                        isInfected ? 'Polycystic features' : 'No polycystic features',
                        style: AppTextStyles.labelLarge.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Confidence',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                      SizedBox(height: 4.h),
                      Text('${(conf * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (pred.modelVersion != null) ...<Widget>[
            SizedBox(height: 10.h),
            Text(
              'Model: ${pred.modelVersion}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePendingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text('Loading image analysis…',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImageCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.image_not_supported_outlined, color: AppColors.warning, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No ultrasound image is linked to this assessment yet.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorsCard(AssessmentModel latest, FusedRiskResult fused) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Main contributing answers', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
          SizedBox(height: 14.h),
          ...latest.risk.contributors.map(
            (contributor) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.circle, size: 8.sp, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      contributor,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (fused.hasImage) ...<Widget>[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                fused.imageInsight,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _downloadPdf({
    required ReportPdfService pdfService,
    required AuthController auth,
    required AssessmentModel latest,
    required FusedRiskResult fused,
    PredictionModel? prediction,
  }) async {
    try {
      final plan = Get.isRegistered<RecommendationController>()
          ? Get.find<RecommendationController>().plan.value
          : null;
      await pdfService.previewPdf(
        user: auth.user.value,
        assessment: latest,
        fused: fused,
        prediction: prediction,
        plan: plan,
      );
    } catch (e) {
      Get.snackbar(
        'PDF',
        'Could not generate PDF: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sharePdf({
    required ReportPdfService pdfService,
    required AuthController auth,
    required AssessmentModel latest,
    required FusedRiskResult fused,
    PredictionModel? prediction,
  }) async {
    try {
      final plan = Get.isRegistered<RecommendationController>()
          ? Get.find<RecommendationController>().plan.value
          : null;
      await pdfService.sharePdf(
        user: auth.user.value,
        assessment: latest,
        fused: fused,
        prediction: prediction,
        plan: plan,
      );
    } catch (e) {
      Get.snackbar(
        'Share',
        'Could not share PDF: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildAnswerTile(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.help_outline_rounded, size: 18.sp, color: AppColors.textTertiary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(question, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Text(answer, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
