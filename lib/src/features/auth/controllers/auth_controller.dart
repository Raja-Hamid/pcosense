import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcosense/src/features/auth/models/user_model.dart';
import 'package:pcosense/src/features/auth/services/auth_service.dart';
import 'package:pcosense/src/features/profile/services/user_profile_service.dart';

class AuthController extends GetxController {
  static const _kUserCache = 'pcos_user_cache';

  final _authService = Get.find<AuthService>();
  final _profileService = Get.find<UserProfileService>();
  final _prefs = Get.find<SharedPreferences>();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final syncWarning = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load from cache initially for fast startup
    final raw = _prefs.getString(_kUserCache);
    if (raw != null) {
      try {
        user.value = UserModel.fromJson(
          (jsonDecode(raw) as Map).cast<String, dynamic>(),
        );
      } catch (e) {
        Get.log('Error parsing cached user: $e');
      }
    }

    // Bind to Firebase Auth state
    _authService.authStateChanges.listen(_handleAuthStateChanged);
  }

  Future<void> _handleAuthStateChanged(firebase.User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        user.value = null;
        syncWarning.value = '';
        await _prefs.remove(_kUserCache);
      } else {
        final profileResult = await _profileService.getUserProfile(
          firebaseUser.uid,
        );
        switch (profileResult.status) {
          case UserProfileFetchStatus.found:
            final profile = profileResult.profile!;
            user.value = profile;
            syncWarning.value = '';
            await _prefs.setString(_kUserCache, jsonEncode(profile.toJson()));
            return;
          case UserProfileFetchStatus.notFound:
            user.value = null;
            syncWarning.value = 'Profile not found. Please sign in again.';
            await _prefs.remove(_kUserCache);
            await _authService.logout();
            return;
          case UserProfileFetchStatus.fetchFailed:
            final cached = user.value;
            if (cached != null &&
                cached.email.isNotEmpty &&
                cached.email != (firebaseUser.email ?? '')) {
              user.value = null;
              await _prefs.remove(_kUserCache);
            }
            syncWarning.value = 'Unable to refresh profile right now.';
            Get.log(
              'Auth state sync failed: ${profileResult.errorMessage ?? 'unknown'}',
            );
            return;
        }
      }
    } catch (e) {
      Get.log('Unhandled auth sync error: $e');
      syncWarning.value = 'Unable to refresh profile right now.';
    }
  }

  Future<String?> login(String email, String password) async {
    syncWarning.value = '';
    return await _authService.login(email, password);
  }

  Future<String?> signup(String name, String email, String password) async {
    syncWarning.value = '';
    final authError = await _authService.signup(email, password);
    if (authError != null) return authError;

    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      final model = UserModel(
        name: name,
        email: email,
        joinedDate: DateFormat('MMMM yyyy').format(DateTime.now()),
      );
      try {
        await _profileService.createUserProfile(firebaseUser.uid, model);
      } catch (e) {
        try {
          await firebaseUser.delete();
        } catch (_) {
          await _authService.logout();
        }
        syncWarning.value = 'Account setup did not complete.';
        user.value = null;
        await _prefs.remove(_kUserCache);
        Get.log('Signup profile creation failed: $e');
        return 'Account setup failed. Please try signing up again.';
      }
    }
    return null;
  }

  Future<void> updateUser({String? name, String? phone, String? dob}) async {
    final current = user.value;
    final firebaseUser = _authService.currentUser;
    if (current == null || firebaseUser == null) return;

    final updated = current.copyWith(name: name, phone: phone, dob: dob);
    user.value = updated;
    await _prefs.setString(_kUserCache, jsonEncode(updated.toJson()));

    await _profileService.updateUserProfile(firebaseUser.uid, {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (dob != null) 'dob': dob,
    });
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      syncWarning.value = '';
      user.value = null;
      await _prefs.remove(_kUserCache);
    }
  }
}
