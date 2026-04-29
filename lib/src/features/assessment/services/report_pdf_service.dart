import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:pcosense/src/features/assessment/logic/risk_fusion.dart';
import 'package:pcosense/src/features/assessment/models/assessment_model.dart';
import 'package:pcosense/src/features/auth/models/user_model.dart';
import 'package:pcosense/src/features/content/models/personalized_plan_model.dart';
import 'package:pcosense/src/features/content/models/prediction_model.dart';

class ReportPdfService extends GetxService {
  static const PdfColor _primary = PdfColor.fromInt(0xFF7C3AED);
  static const PdfColor _primaryLight = PdfColor.fromInt(0xFFF3E8FF);
  static const PdfColor _success = PdfColor.fromInt(0xFF059669);
  static const PdfColor _warning = PdfColor.fromInt(0xFFD97706);
  static const PdfColor _error = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B7280);

  Future<Uint8List> buildPdf({
    required UserModel? user,
    required AssessmentModel assessment,
    required FusedRiskResult fused,
    PredictionModel? prediction,
    PersonalizedPlan? plan,
  }) async {
    final doc = pw.Document(
      title: 'PCOSense Screening Report',
      author: 'PCOSense',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _header(),
        footer: (context) => _footer(context),
        build: (context) => <pw.Widget>[
          _patientHeader(user, assessment),
          pw.SizedBox(height: 16),
          _summaryBlock(assessment, fused),
          pw.SizedBox(height: 14),
          if (prediction != null && prediction.isCompleted) ...<pw.Widget>[
            _imageAnalysisBlock(prediction),
            pw.SizedBox(height: 14),
          ],
          _contributorsBlock(assessment),
          pw.SizedBox(height: 14),
          _answersBlock(assessment),
          if (plan != null) ...<pw.Widget>[
            pw.SizedBox(height: 16),
            _planBlock(plan),
          ],
          pw.SizedBox(height: 16),
          _disclaimer(assessment.risk.disclaimer),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> previewPdf({
    required UserModel? user,
    required AssessmentModel assessment,
    required FusedRiskResult fused,
    PredictionModel? prediction,
    PersonalizedPlan? plan,
  }) async {
    final bytes = await buildPdf(
      user: user,
      assessment: assessment,
      fused: fused,
      prediction: prediction,
      plan: plan,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> sharePdf({
    required UserModel? user,
    required AssessmentModel assessment,
    required FusedRiskResult fused,
    PredictionModel? prediction,
    PersonalizedPlan? plan,
  }) async {
    final bytes = await buildPdf(
      user: user,
      assessment: assessment,
      fused: fused,
      prediction: prediction,
      plan: plan,
    );
    final filename = 'pcosense-report-${_filenameTimestamp()}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ── Sections ─────────────────────────────────────────────────────────────

  pw.Widget _header() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(
            'PCOSense',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primary),
          ),
          pw.Text(
            'Screening report',
            style: const pw.TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(
            'Generated ${DateFormat('MMMM d, y · h:mm a').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
          pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );
  }

  pw.Widget _patientHeader(UserModel? user, AssessmentModel assessment) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _primaryLight,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  user?.name.isNotEmpty == true ? user!.name : 'PCOSense user',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 2),
                if ((user?.email ?? '').isNotEmpty)
                  pw.Text(user!.email, style: const pw.TextStyle(fontSize: 10, color: _muted)),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Screening date: ${_formatDateIso(assessment.dateIso)}',
                  style: const pw.TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryBlock(AssessmentModel assessment, FusedRiskResult fused) {
    final color = _categoryColor(fused.fusedCategory);
    return _card(
      title: fused.hasImage ? 'Combined screening result' : 'Screening result',
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              fused.fusedLevel.toUpperCase(),
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(fused.fusedHeadline, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(assessment.risk.explanation, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
          if (fused.adjustedDirection == 'up') ...<pw.Widget>[
            pw.SizedBox(height: 6),
            pw.Text(
              'Image analysis raised the questionnaire-only category to ${fused.fusedLevel.toLowerCase()}.',
              style: pw.TextStyle(fontSize: 10, color: color, fontStyle: pw.FontStyle.italic),
            ),
          ],
          pw.SizedBox(height: 6),
          pw.Text(
            'Score: ${assessment.risk.score} / ${assessment.risk.maxScore}',
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );
  }

  pw.Widget _imageAnalysisBlock(PredictionModel pred) {
    final isInfected = pred.isInfected;
    final color = isInfected ? _error : _success;
    return _card(
      title: 'Ultrasound image analysis',
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
            children: <pw.Widget>[
              _statBox(
                label: 'Reading',
                value: isInfected ? 'Polycystic features' : 'No polycystic features',
                color: color,
              ),
              pw.SizedBox(width: 8),
              _statBox(
                label: 'Confidence',
                value: '${((pred.confidence ?? 0) * 100).toStringAsFixed(1)}%',
                color: _primary,
              ),
            ],
          ),
          if (pred.modelVersion != null) ...<pw.Widget>[
            pw.SizedBox(height: 8),
            pw.Text('Model: ${pred.modelVersion}',
                style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
          if (pred.latencyMs != null) ...<pw.Widget>[
            pw.SizedBox(height: 2),
            pw.Text('Inference time: ${pred.latencyMs} ms',
                style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ],
      ),
    );
  }

  pw.Widget _statBox({required String label, required String value, required PdfColor color}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFF8F6FC),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(label, style: pw.TextStyle(fontSize: 9, color: color)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  pw.Widget _contributorsBlock(AssessmentModel assessment) {
    final contributors = assessment.risk.contributors;
    if (contributors.isEmpty) return pw.SizedBox.shrink();
    return _card(
      title: 'Main contributing answers',
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: contributors
            .map(
              (c) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Container(
                      width: 4,
                      height: 4,
                      margin: const pw.EdgeInsets.only(top: 6, right: 6),
                      decoration: const pw.BoxDecoration(color: _primary, shape: pw.BoxShape.circle),
                    ),
                    pw.Expanded(
                      child: pw.Text(c, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _answersBlock(AssessmentModel assessment) {
    return _card(
      title: 'Detailed questionnaire answers',
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: assessment.answers
            .map(
              (a) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(a.questionText,
                        style: const pw.TextStyle(fontSize: 9, color: _muted)),
                    pw.Text(a.displayValue,
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _planBlock(PersonalizedPlan plan) {
    return _card(
      title: 'Recommended plan',
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(plan.headline,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(plan.summary,
              style: const pw.TextStyle(fontSize: 10, color: _muted, lineSpacing: 1.4)),
          pw.SizedBox(height: 8),
          ...plan.sections.map((section) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(section.title,
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _primary)),
                  pw.SizedBox(height: 4),
                  ...section.items.take(4).map((item) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4, left: 4),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Text(item.priority >= 4 ? '★ ' : '· ',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: item.priority >= 4 ? _warning : _muted,
                              )),
                          pw.Expanded(
                            child: pw.Text(item.title,
                                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.3)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _disclaimer(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: _muted,
          fontStyle: pw.FontStyle.italic,
          lineSpacing: 1.4,
        ),
      ),
    );
  }

  pw.Widget _card({required String title, required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(title.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 9,
                color: _primary,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.5,
              )),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  PdfColor _categoryColor(String category) {
    switch (category) {
      case 'low':
        return _success;
      case 'high':
      case 'urgent':
        return _error;
      default:
        return _warning;
    }
  }

  String _formatDateIso(String iso) {
    try {
      return DateFormat('MMMM d, y').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _filenameTimestamp() {
    return DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
  }
}
