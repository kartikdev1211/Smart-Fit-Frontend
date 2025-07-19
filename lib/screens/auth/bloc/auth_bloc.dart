import 'package:bloc/bloc.dart';
import 'package:smart_fit/screens/auth/bloc/auth_event.dart';
import 'package:smart_fit/screens/auth/bloc/auth_state.dart';
import 'package:smart_fit/services/api_services.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await ApiServices.signupUser(
          fullName: event.fulllName,
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccessState(user: user));
      } catch (e) {
        emit(
          AuthFailureState(error: e.toString().replaceFirst("Exception: ", "")),
        );
      }
    });
    on<LoginEvent>((event, emit) async {
      try {
        emit(AuthLoadingState());
        final user = await ApiServices.loginUser(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccessState(user: user));
      } catch (e) {
        emit(
          AuthFailureState(error: e.toString().replaceFirst("Exception: ", "")),
        );
      }
    });
  }
}
