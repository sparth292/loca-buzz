import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:locabuzz/business_service_provider_dashboard/service_provider_dashboard.dart';
import 'package:locabuzz/screens/onboarding/onboarding_screen.dart';
import 'package:locabuzz/screens/home_page.dart';
import 'package:locabuzz/utils/auth_state.dart' as local_auth;
import '../main.dart' show supabase;

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userRole;

  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    
    // Listen to auth state changes
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((authState) {
      final session = authState.session;
      if (mounted) {
        setState(() {
          _isLoggedIn = session != null;
          _isLoading = false;
          
          // If user is logged out, clear the role
          if (session == null) {
            _userRole = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if we have a valid session
      final session = supabase.auth.currentSession;
      
      if (session != null) {
        // We have a valid session, get user role
        final userRole = await local_auth.AuthState.getUserRole();
        
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _userRole = userRole;
            _isLoading = false;
          });
        }
      } else {
        // No valid session, check local storage as fallback
        final isLoggedIn = await local_auth.AuthState.isLoggedIn();
        
        if (isLoggedIn) {
          // Try to get the user role from local storage
          try {
            final userRole = await local_auth.AuthState.getUserRole();
            if (mounted) {
              setState(() {
                _isLoggedIn = true;
                _userRole = userRole;
                _isLoading = false;
              });
            }
          } catch (e) {
            debugPrint('Error getting user role: $e');
            await local_auth.AuthState.logOut();
          }
        }
        
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _userRole = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userRole = null;
          _isLoading = false;
        });
      }
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
