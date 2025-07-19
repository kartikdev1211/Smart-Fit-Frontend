// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fit/screens/profile/bloc/profile_bloc.dart';
import 'package:smart_fit/screens/profile/bloc/profile_event.dart';
import 'package:smart_fit/screens/profile/bloc/profile_state.dart';
import 'package:smart_fit/screens/suggesstion_screen.dart';
import 'package:smart_fit/screens/wardrobe/wardrobe_screen.dart';
import 'package:smart_fit/screens/occasion_suggestion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeScreen = size.width > 900;

    return BlocProvider(
      create: (context) {
        final bloc = ProfileBloc();
        // Fetch profile data when screen loads
        bloc.add(FetchProfileEvent());
        return bloc;
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          String userName = 'User'; // Default fallback

          if (state is ProfileLoaded) {
            userName = state.userProfile.fullName
                .split(' ')
                .first; // Get first name
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? size.width * 0.1 : 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Greeting
                    Text(
                      'Hello, $userName 👋',
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      'Let Smart Fit pick the perfect outfit for you!',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 30),

                    // 🔹 Suggestion Cards
                    _buildCard(
                      context,
                      title: "Weather-Based Suggestion",
                      subtitle: "Dressed for the weather outside",
                      icon: Icons.cloud,
                      color: Colors.lightBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const SuggestionScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildCard(
                      context,
                      title: "Occasion-Based Suggestion",
                      subtitle: "Impress at your next event",
                      icon: Icons.event_available,
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                const OccasionSuggestionScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildCard(
                      context,
                      title: "Your Wardrobe",
                      subtitle: "Manage clothes you own",
                      icon: Icons.checkroom,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const WardrobeScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildCard(
                      context,
                      title: "Style Tips",
                      subtitle: "Learn what works for you",
                      icon: Icons.lightbulb_outline,
                      color: Colors.orangeAccent,
                      onTap: () {
                        _showStyleTipsDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStyleTipsDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: isTablet
              ? EdgeInsets.symmetric(horizontal: size.width * 0.2, vertical: 40)
              : const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          title: const Text(
            'Style Tips',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StyleTip(
                  title: "Color Coordination",
                  tip:
                      "Stick to a color palette of 3-4 colors that work well together.",
                  icon: Icons.palette,
                ),
                const SizedBox(height: 16),
                _StyleTip(
                  title: "Fit Matters",
                  tip:
                      "Well-fitted clothes look more polished than oversized or tight items.",
                  icon: Icons.check_circle,
                ),
                const SizedBox(height: 16),
                _StyleTip(
                  title: "Layer Smart",
                  tip:
                      "Start with a base layer and add pieces that complement each other.",
                  icon: Icons.layers,
                ),
                const SizedBox(height: 16),
                _StyleTip(
                  title: "Accessorize Wisely",
                  tip: "Simple accessories can elevate your entire outfit.",
                  icon: Icons.style,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  color: Color(0xFF5A4FCF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: isTablet ? 36 : 28,
              child: Icon(icon, color: color, size: isTablet ? 36 : 28),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? 20 : 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleTip extends StatelessWidget {
  final String title;
  final String tip;
  final IconData icon;

  const _StyleTip({required this.title, required this.tip, required this.icon});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: const Color(0xFF5A4FCF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF5A4FCF),
            size: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 16,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                tip,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
