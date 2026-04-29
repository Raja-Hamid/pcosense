import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/core/theme/app_colors.dart';
import 'package:pcosense/src/core/theme/app_text_styles.dart';
import 'package:pcosense/src/core/widgets/app_ui.dart';
import 'package:pcosense/src/features/auth/widgets/auth_input.dart';
import 'package:pcosense/src/features/profile/controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit Profile',
      child: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Icon(Icons.person_rounded, size: 50.sp, color: AppColors.primary),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 16.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          AuthInput(
            controller: controller.nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20.h),
          AuthInput(
            controller: controller.phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 40.h),
          PrimaryButton(
            text: 'Save Changes',
            onTap: controller.save,
          ),
          SizedBox(height: 16.h),
          Center(
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
