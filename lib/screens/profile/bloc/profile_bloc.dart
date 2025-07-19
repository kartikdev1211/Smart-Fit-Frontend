import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_fit/screens/profile/bloc/profile_event.dart';
import 'package:smart_fit/screens/profile/bloc/profile_state.dart';
import 'package:smart_fit/services/api_services.dart';
import 'package:smart_fit/models/user_profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final result = await ApiServices.getUserProfile();

        debugPrint("🔍 Profile BLoC - API Result: $result");
        debugPrint("🔍 Profile BLoC - Success: ${result['success']}");
        debugPrint("🔍 Profile BLoC - Data: ${result['data']}");

        if (result['success']) {
          debugPrint("🔍 Profile BLoC - Emitting ProfileLoaded");
          // Parse the response into UserProfile object
          final userProfile = UserProfile.fromJson(result['data']);
          emit(ProfileLoaded(userProfile: userProfile));
        } else {
          debugPrint(
            "🔍 Profile BLoC - Emitting ProfileError: ${result['message']}",
          );
          emit(ProfileError(message: result['message']));
        }
      } catch (e) {
        debugPrint("🔍 Profile BLoC - Exception: $e");
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
