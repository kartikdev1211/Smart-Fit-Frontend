abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String fulllName;
  final String email;
  final String password;

  SignUpEvent({
    required this.fulllName,
    required this.email,
    required this.password,
  });
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}
