import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/content/widgets/info_card.dart';

class StaticInfoView extends StatelessWidget {
  const StaticInfoView({required this.title, this.withNav = false, super.key, this.icon});
  
  final String title;
  final bool withNav;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      withNav: withNav,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        physics: const BouncingScrollPhysics(),
        child: InfoCard(
          title: title,
          icon: icon ?? _getIconForTitle(title),
          subtitle: _getPlaceholderTextForTitle(title),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    if (title.contains('Terms')) return Icons.gavel_rounded;
    if (title.contains('Privacy')) return Icons.privacy_tip_rounded;
    if (title.contains('Notifications')) return Icons.notifications_active_rounded;
    if (title.contains('Help')) return Icons.help_center_rounded;
    if (title.contains('About')) return Icons.info_rounded;
    if (title.contains('Calendar')) return Icons.calendar_month_rounded;
    return Icons.article_rounded;
  }

  String _getPlaceholderTextForTitle(String title) {
    return 'This section contains important information regarding $title. In a production environment, this would be replaced with the actual legal or informative text required for the application.\n\nAt PCOSense, we are committed to providing you with the most accurate information and protecting your health data at all times.';
  }
}
