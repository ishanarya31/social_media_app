import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/Storage/domain/storage_repo.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';

import '../../domain/repos/profile_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  //fetch user profile using repo -> useful for loading user for profile pages
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found!"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }


  //return user profile given uid -> for many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async{
    final user = await profileRepo.fetchUserProfile(uid);
    return user;

  }



  //update bio/profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());
    try {
      //fetch current user first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for Profile Update!"));
        return;
      }

      //profile picture update (only if image is provided)
      String? imageDownloadUrl;

      if (imageMobilePath != null) {
        try {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );

          if (imageDownloadUrl == null) {
            emit(ProfileError("Failed to upload image"));
            return;
          }
        } catch (e) {
          emit(ProfileError("Failed to upload image: $e"));
          return;
        }
      }

      //update new profile
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      await profileRepo.updateProfile(updatedProfile);

      //re-fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating Profile: $e"));
    }
  }
}
