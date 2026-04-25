import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KemetApp());
}

class KemetApp extends StatelessWidget {
  const KemetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kemet — Discover Egypt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD4941A),
          secondary: const Color(0xFFF5C842),
          surface: const Color(0xFF1A1208),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
