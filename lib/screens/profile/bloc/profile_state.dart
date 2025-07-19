import 'package:smart_fit/models/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  ProfileLoaded({required this.userProfile});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
