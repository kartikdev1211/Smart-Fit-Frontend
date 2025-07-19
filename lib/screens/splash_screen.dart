// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fit/screens/auth/auth_screen.dart';
import 'package:smart_fit/screen_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _checkAuthStatus();
    super.initState();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        // Token exists, navigate to main screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // No token, navigate to auth screen
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      // In case of error, navigate to auth screen
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset("assets/images/image.png")],
        ),
      ),
    );
  }
}
