import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fit/screens/auth/bloc/auth_bloc.dart';
import 'package:smart_fit/screens/profile/bloc/profile_bloc.dart';
import 'package:smart_fit/screens/splash_screen.dart';
import 'package:smart_fit/screens/wardrobe/bloc/wardrobe_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => WardrobeBloc()),
      ],
      child: MaterialApp(
        title: 'Smart Fit',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
