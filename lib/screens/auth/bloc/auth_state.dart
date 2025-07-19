abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final Map<String, dynamic> user;

  AuthSuccessState({required this.user});
}

class AuthFailureState extends AuthState {
  final String error;

  AuthFailureState({required this.error});
}
