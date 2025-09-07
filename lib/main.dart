import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'package:locabuzz/screens/onboarding/onboarding_screen.dart';
import 'package:locabuzz/screens/home_page.dart';
import 'package:locabuzz/screens/profile_page.dart';
import 'package:locabuzz/screens/login_screen.dart';
import 'package:locabuzz/screens/sign_up_screen.dart';
import 'package:locabuzz/screens/role_selection_screen.dart';
import 'package:locabuzz/screens/auth_wrapper.dart';

// Dashboards
import 'package:locabuzz/business_service_provider_dashboard/service_provider_dashboard.dart' as dashboard;

// Initialize Supabase
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qzreommjwrqrwtaexdxc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6cmVvbW1qd3Jxcnd0YWV4ZHhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MTM0NTgsImV4cCI6MjA2NzM4OTQ1OH0.7GZTP4ZRbs-ypOl-z4hjH7w7ZQgAjOMkjzXzJ1GBLTM',
  );
  
  runApp(const LocaBuzzApp());
}

class BeeColors {
  static const Color beeYellow = Color(0xFFF6C90E); // honey yellow
  static const Color beeBlack = Color(0xFF111111); // deep blackish
  static const Color beeGrey = Color(0xFF9E9E9E);
  static const Color background = Color(0xFFF9FAFB);
}

class LocaBuzzApp extends StatelessWidget {
  const LocaBuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();

    return MaterialApp(
      title: 'LocaBuzz',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: BeeColors.beeYellow,
          primary: BeeColors.beeYellow,
          secondary: BeeColors.beeBlack,
          background: BeeColors.background,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: BeeColors.beeBlack),
          titleTextStyle: TextStyle(
            color: BeeColors.beeBlack,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BeeColors.beeYellow,
            foregroundColor: BeeColors.beeBlack,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/home': (context) => const HomePage(),
        '/service-provider-dashboard': (context) => const dashboard.ServiceProviderDashboard(),
        '/service-provider-profile': (context) => const ProfilePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class BrandTitle extends StatelessWidget {
  final double fontSize;
  final TextAlign textAlign;
  const BrandTitle({super.key, this.fontSize = 40, this.textAlign = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        children: const [
          TextSpan(text: 'Loca', style: TextStyle(color: BeeColors.beeBlack)),
          TextSpan(text: 'Buzz', style: TextStyle(color: BeeColors.beeYellow)),
        ],
      ),
    );
  }
}





