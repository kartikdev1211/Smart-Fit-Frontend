// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fit/screens/auth/auth_screen.dart';
import 'package:smart_fit/screens/profile/bloc/profile_bloc.dart';
import 'package:smart_fit/screens/profile/bloc/profile_event.dart';
import 'package:smart_fit/screens/profile/bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ProfileBloc();
        // Immediately fetch profile data
        bloc.add(FetchProfileEvent());
        return bloc;
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          debugPrint("🔍 Profile Screen - Listener State: $state");
          debugPrint(
            "🔍 Profile Screen - Listener State Type: ${state.runtimeType}",
          );

          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint("🔍 Profile Screen - Current State: $state");
          debugPrint("🔍 Profile Screen - State Type: ${state.runtimeType}");
          debugPrint(
            "🔍 Profile Screen - Is ProfileLoaded: ${state is ProfileLoaded}",
          );
          debugPrint(
            "🔍 Profile Screen - Is ProfileLoading: ${state is ProfileLoading}",
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF1F3F6),
            body: Column(
              children: [
                // 🔹 Header with gradient and avatar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5A4FCF), Color(0xFF786FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF5A4FCF),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (state is ProfileLoaded) ...[
                        Text(
                          state.userProfile.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.userProfile.email,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ] else if (state is ProfileLoading) ...[
                        const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Please wait',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ] else ...[
                        const Text(
                          'User',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'user@example.com',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),

                // 🔹 Details section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state is ProfileLoaded) ...[
                                _infoRow(
                                  Icons.email,
                                  "Email: ${state.userProfile.email}",
                                ),
                                const SizedBox(height: 16),
                                _infoRow(
                                  Icons.badge,
                                  "Full Name: ${state.userProfile.fullName}",
                                ),
                              ] else if (state is ProfileLoading) ...[
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF5A4FCF),
                                  ),
                                ),
                              ] else ...[
                                _infoRow(Icons.error, "Failed to load profile"),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Buttons
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text("Logout"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5A4FCF),
                            side: const BorderSide(color: Color(0xFF5A4FCF)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5A4FCF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}
