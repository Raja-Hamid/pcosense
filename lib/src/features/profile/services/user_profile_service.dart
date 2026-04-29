import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pcosense/src/features/auth/models/user_model.dart';

enum UserProfileFetchStatus {
  found,
  notFound,
  fetchFailed,
}

class UserProfileFetchResult {
  const UserProfileFetchResult._({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  final UserProfileFetchStatus status;
  final UserModel? profile;
  final String? errorMessage;

  const UserProfileFetchResult.found(UserModel profile)
      : this._(status: UserProfileFetchStatus.found, profile: profile);

  const UserProfileFetchResult.notFound()
      : this._(status: UserProfileFetchStatus.notFound);

  const UserProfileFetchResult.fetchFailed([String? errorMessage])
      : this._(status: UserProfileFetchStatus.fetchFailed, errorMessage: errorMessage);
}

class UserProfileService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfileFetchResult> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileFetchResult.found(UserModel.fromJson(doc.data()!));
      }
      return const UserProfileFetchResult.notFound();
    } catch (e) {
      Get.log('Error fetching user profile: $e');
      return UserProfileFetchResult.fetchFailed(e.toString());
    }
  }

  Future<void> createUserProfile(String uid, UserModel user) async {
    try {
      await _firestore.collection('users').doc(uid).set(user.toFirestore());
    } catch (e) {
      Get.log('Error creating user profile: $e');
      throw Exception('Failed to create user profile');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      Get.log('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }
}

