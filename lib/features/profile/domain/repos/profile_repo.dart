/*
Profile Repository => Defines different operations that can be done in profile page
 */

import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo{
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
}