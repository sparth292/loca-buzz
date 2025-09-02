import 'package:flutter/material.dart';
import 'package:locabuzz/business_service_provider_dashboard/service_provider_profile.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/location_setup_screen.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'business_service_provider_dashboard/service_provider_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qzreommjwrqrwtaexdxc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6cmVvbW1qd3Jxcnd0YWV4ZHhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MTM0NTgsImV4cCI6MjA2NzM4OTQ1OH0.7GZTP4ZRbs-ypOl-z4hjH7w7ZQgAjOMkjzXzJ1GBLTM',
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LocaBuzzApp(),
  ));
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
      debugShowCheckedModeBanner: false,
      title: 'LocaBuzz',
      theme: base.copyWith(
        scaffoldBackgroundColor: BeeColors.background,
        primaryColor: BeeColors.beeYellow,
        colorScheme: const ColorScheme.light(
          primary: BeeColors.beeYellow,
          secondary: BeeColors.beeYellow,
          surface: Colors.white,
          onPrimary: BeeColors.beeBlack,
          onSurface: BeeColors.beeBlack,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: BeeColors.beeBlack,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BeeColors.beeYellow,
            foregroundColor: BeeColors.beeBlack,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: BeeColors.beeGrey.withValues(alpha: 0.9)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
          ),
        ),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        LoginPage.route: (context) => const LoginPage(),
        SignupPage.route: (context) => const SignupPage(),
        HomePage.route: (context) => const HomePage(),
        LocationSetupScreen.route: (context) => const LocationSetupScreen(),
        ProfilePage.route: (context) => const ProfilePage(),
        ServiceProviderDashboard.route: (context) => const ServiceProviderDashboard(),
        ServiceProviderProfile.route: (context) => const ServiceProviderProfile(),
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





