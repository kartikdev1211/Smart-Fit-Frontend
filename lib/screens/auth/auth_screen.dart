// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_fit/screen_layout.dart';
import 'package:smart_fit/screens/auth/bloc/auth_bloc.dart';
import 'package:smart_fit/screens/auth/bloc/auth_event.dart';
import 'package:smart_fit/screens/auth/bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  final Duration _animDuration = const Duration(milliseconds: 400);

  void toggle() => setState(() => isLogin = !isLogin);

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final authBloc = BlocProvider.of<AuthBloc>(context);
      if (isLogin) {
        debugPrint(
          "Logging in: ${emailController.text}, ${passwordController.text}",
        );
        // Fluttertoast.showToast(
        //   msg: "Login Successful!",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.black87,
        //   textColor: Colors.white,
        //   fontSize: 14.0,
        // );
        // Future.delayed(const Duration(seconds: 2), () {
        //   Navigator.pushReplacement(
        //     context,
        //     CupertinoPageRoute(builder: (context) => const MainScreen()),
        //   );
        // });
        authBloc.add(
          LoginEvent(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ),
        );
      } else {
        debugPrint(
          "Signing up: ${nameController.text}, ${emailController.text}, ${passwordController.text}",
        );
        // setState(() {
        //   isLogin = true;
        //   passwordController.clear();
        //   nameController.clear();
        // });
        // Fluttertoast.showToast(
        //   msg: "Account created! Please log in.",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   backgroundColor: Colors.black87,
        //   textColor: Colors.white,
        //   fontSize: 14.0,
        // );
        authBloc.add(
          SignUpEvent(
            fulllName: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFf2eafc), Color(0xFFe0d6f5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔹 Glassmorphic Auth Card
          Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: _animDuration,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) async {
                    if (state is AuthLoadingState) {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      debugPrint("⏳ Auth in progress...");
                    } else if (state is AuthSuccessState) {
                      // Dismiss loading dialog if open
                      Navigator.of(context, rootNavigator: true).pop();
                      Fluttertoast.showToast(
                        msg: isLogin ? "Login Success!" : "Signup Success!",
                        backgroundColor: Colors.green[600],
                        textColor: Colors.white,
                      );

                      if (isLogin) {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const MainScreen(),
                          ),
                        );
                      } else {
                        // Switch to login mode after signup
                        setState(() {
                          isLogin = true;
                          passwordController.clear();
                          nameController.clear();
                        });
                      }
                    } else if (state is AuthFailureState) {
                      // Dismiss loading dialog if open
                      Navigator.of(context, rootNavigator: true).pop();
                      debugPrint("❌ Auth Error:  [31m");
                      Fluttertoast.showToast(
                        msg: state.error,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: _buildForm(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return AnimatedSize(
      duration: _animDuration,
      curve: Curves.easeInOut,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: _animDuration,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Icon(
                Icons.checkroom,
                size: 70,
                color: const Color(0xFF111827),
                key: ValueKey<bool>(isLogin),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: _animDuration,
              transitionBuilder: (child, animation) => SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.2), end: Offset.zero),
                ),
                child: child,
              ),
              child: Text(
                isLogin ? "Welcome Back" : "Create Account",
                key: ValueKey<bool>(isLogin),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isLogin ? "Login to Smart Fit" : "Join Smart Fit Now!",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 30),

            if (!isLogin)
              AnimatedOpacity(
                duration: _animDuration,
                opacity: isLogin ? 0 : 1,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: nameController,
                      label: "Full Name",
                      validator: (val) =>
                          val!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            _buildInputField(
              controller: emailController,
              label: "Email",
              validator: (val) => val != null && val.contains("@")
                  ? null
                  : "Enter a valid email",
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: passwordController,
              label: "Password",
              obscure: true,
              validator: (val) =>
                  val != null && val.length >= 6 ? null : "Password too short",
            ),
            const SizedBox(height: 30),

            // 🔹 Animated Button (Scale on tap)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 150),
              tween: Tween(begin: 1.0, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLogin ? "Login" : "Sign Up",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: toggle,
              child: AnimatedSwitcher(
                duration: _animDuration,
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Log in",
                  key: ValueKey<bool>(isLogin),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscure = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: TextFormField(
        controller: controller,
        obscureText: obscure && !_isPasswordVisible,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          // Add password visibility toggle for password field
          suffixIcon: obscure
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
