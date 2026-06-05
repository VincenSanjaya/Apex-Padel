import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/match_record.dart';
import 'providers/match_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(MatchRecordAdapter());
  Hive.registerAdapter(MatchResultAdapter());
  Hive.registerAdapter(ScoringFormatAdapter());
  
  // Open the main match box
  await Hive.openBox<MatchRecord>(matchBoxName);

  runApp(
    const ProviderScope(
      child: ApexPadelApp(),
    ),
  );
}

class ApexPadelApp extends StatelessWidget {
  const ApexPadelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Base dark theme
    final baseTheme = ThemeData.dark();

    return MaterialApp(
      title: 'Apex Padel',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        primaryColor: const Color(0xFFD4FF00),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4FF00),
          onPrimary: Color(0xFF2a3400),
          surface: Color(0xFF131313),
          onSurface: Color(0xFFe5e2e1),
          surfaceContainer: Color(0xFF201f1f),
          surfaceContainerHigh: Color(0xFF2a2a2a),
          surfaceContainerHighest: Color(0xFF353534),
          outline: Color(0xFF8f9378),
          error: Color(0xFFffb4ab),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.oswald(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.02 * 48,
          ),
          displayMedium: GoogleFonts.oswald(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
          displaySmall: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.oswald(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          labelLarge: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.05 * 14,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
