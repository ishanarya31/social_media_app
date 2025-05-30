/*
PROFILE STATES
 */

import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState{}

//initial
class ProfileInitial extends ProfileState{}

//loading
class ProfileLoading extends ProfileState{}

//loaded
class ProfileLoaded extends ProfileState{
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
}

//errors
class ProfileError extends ProfileState{
  final String message;
  ProfileError(this.message);
}
