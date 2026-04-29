import 'package:get/get.dart';
import 'package:pcosense/src/core/routing/app_routes.dart';
import 'package:pcosense/src/features/assessment/bindings/assessment_pages_binding.dart';
import 'package:pcosense/src/features/assessment/views/assessment_history_view.dart';
import 'package:pcosense/src/features/assessment/views/report_view.dart';
import 'package:pcosense/src/features/assessment/views/results_view.dart';
import 'package:pcosense/src/features/auth/bindings/forgot_password_binding.dart';
import 'package:pcosense/src/features/auth/bindings/login_binding.dart';
import 'package:pcosense/src/features/auth/bindings/signup_binding.dart';
import 'package:pcosense/src/features/auth/bindings/welcome_binding.dart';
import 'package:pcosense/src/features/auth/views/forgot_password_view.dart';
import 'package:pcosense/src/features/auth/views/login_view.dart';
import 'package:pcosense/src/features/auth/views/signup_view.dart';
import 'package:pcosense/src/features/auth/views/welcome_view.dart';
import 'package:pcosense/src/features/content/bindings/content_binding.dart';
import 'package:pcosense/src/features/content/bindings/scan_binding.dart';
import 'package:pcosense/src/features/content/views/learn_view.dart';
import 'package:pcosense/src/features/content/views/recommendations_view.dart';
import 'package:pcosense/src/features/content/views/scan_view.dart';
import 'package:pcosense/src/features/content/views/static_info_view.dart';
import 'package:pcosense/src/features/home/bindings/home_binding.dart';
import 'package:pcosense/src/features/home/views/home_view.dart';
import 'package:pcosense/src/features/onboarding/bindings/onboarding_binding.dart';
import 'package:pcosense/src/features/onboarding/views/onboarding_view.dart';
import 'package:pcosense/src/features/profile/bindings/edit_profile_binding.dart';
import 'package:pcosense/src/features/profile/bindings/profile_binding.dart';
import 'package:pcosense/src/features/profile/views/edit_profile_view.dart';
import 'package:pcosense/src/features/profile/views/profile_view.dart';
import 'package:pcosense/src/features/questionnaire/bindings/questionnaire_binding.dart';
import 'package:pcosense/src/features/questionnaire/views/questionnaire_view.dart';
import 'package:pcosense/src/features/tracker/bindings/tracker_binding.dart';
import 'package:pcosense/src/features/tracker/views/symptom_history_view.dart';
import 'package:pcosense/src/features/tracker/views/tracker_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeView(), binding: WelcomeBinding()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(name: AppRoutes.signup, page: () => const SignupView(), binding: SignupBinding()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView(), binding: ForgotPasswordBinding()),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: AppRoutes.questionnaire, page: () => const QuestionnaireView(), binding: QuestionnaireBinding()),
    GetPage(name: AppRoutes.results, page: () => const ResultsView(), binding: AssessmentPagesBinding()),
    GetPage(name: AppRoutes.scan, page: () => const ScanView(), binding: ScanBinding()),
    GetPage(name: AppRoutes.recommendations, page: () => const RecommendationsView(), binding: ContentBinding()),
    GetPage(name: AppRoutes.learn, page: () => const LearnView(), binding: ContentBinding()),
    GetPage(name: AppRoutes.tracker, page: () => const TrackerView(), binding: TrackerBinding()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView(), binding: EditProfileBinding()),
    GetPage(name: AppRoutes.assessmentHistory, page: () => const AssessmentHistoryView(), binding: AssessmentPagesBinding()),
    GetPage(name: AppRoutes.report, page: () => const ReportView(), binding: AssessmentPagesBinding()),
    GetPage(name: AppRoutes.symptomHistory, page: () => const SymptomHistoryView(), binding: TrackerBinding()),
    GetPage(name: AppRoutes.terms, page: () => const StaticInfoView(title: 'Terms of Service'), binding: ContentBinding()),
    GetPage(name: AppRoutes.privacyPolicy, page: () => const StaticInfoView(title: 'Privacy Policy'), binding: ContentBinding()),
    GetPage(name: AppRoutes.notifications, page: () => const StaticInfoView(title: 'Notifications'), binding: ContentBinding()),
    GetPage(name: AppRoutes.help, page: () => const StaticInfoView(title: 'Help & FAQ'), binding: ContentBinding()),
    GetPage(name: AppRoutes.about, page: () => const StaticInfoView(title: 'About PCOS Care'), binding: ContentBinding()),
    GetPage(name: AppRoutes.privacy, page: () => const StaticInfoView(title: 'Privacy & Data'), binding: ContentBinding()),
    GetPage(name: AppRoutes.periodCalendar, page: () => const StaticInfoView(title: 'Period Calendar'), binding: ContentBinding()),
    GetPage(name: AppRoutes.changePassword, page: () => const StaticInfoView(title: 'Change Password'), binding: ContentBinding()),
  ];
}
