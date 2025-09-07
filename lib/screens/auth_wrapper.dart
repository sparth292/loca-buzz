import 'package:flutter/material.dart';
import 'package:locabuzz/business_service_provider_dashboard/service_provider_dashboard.dart';
import 'package:locabuzz/screens/onboarding/onboarding_screen.dart';
import 'package:locabuzz/screens/home_page.dart';
import 'package:locabuzz/utils/auth_state.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final isLoggedIn = await AuthState.isLoggedIn();
    final userRole = await AuthState.getUserRole();
    
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _userRole = userRole;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn) {
      return const OnboardingScreen();
    }

    // Use a Navigator to prevent going back to auth screens
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) {
          // Role-based navigation
          switch (_userRole) {
            case 'service_provider':
              return const ServiceProviderDashboard();
            case 'admin':
              // TODO: Add admin dashboard
              return const ServiceProviderDashboard(); // Temporary fallback
            default:
              // Default to regular user dashboard
              return const HomePage();
          }
        },
      ),
    );
  }
}
