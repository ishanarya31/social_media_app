import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';

import '../../domain/repos/profile_repo.dart';

class ProfileCubit extends Cubit<ProfileState>{
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}):super(ProfileInitial());

  //fetch user profile using repo
  Future<void> fetchUserProfile(String uid) async{

    try{

      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if(user!=null){
        emit(ProfileLoaded(user));
      }
      else{
        emit(ProfileError("User not found!"));
      }

    }
    catch(e){
      emit(ProfileError(e.toString()));
    }
  }

  //update bio/profile picture
  Future<void> updateProfile({required String uid, String? newBio}) async{

    emit(ProfileLoading());
    try{

      //fetch current user first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if(currentUser == null){
        emit(ProfileError("Failed to fetch user for Profile Update!"));
        return;
      }

      //profile picture update

      //update new profile
      final updatedProfile = currentUser.copyWith(newBio: newBio?? currentUser.bio);

      await profileRepo.updateProfile(updatedProfile);

      //re-fetch the updated profile
      await fetchUserProfile(uid);
    }

    catch(e){
      emit(ProfileError("Error updating Profile: $e"));
    }

  }


}