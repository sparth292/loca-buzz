import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import '../main.dart' show supabase, BeeColors, BrandTitle;

class EmailConfirmationScreen extends StatefulWidget {
  static const String route = '/email-confirmation';
  final String email;
  final String password;
  final bool isServiceProvider;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.isServiceProvider,
  });

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  bool _isEmailVerified = false;
  late final Stream<AuthState> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _authStateChanges = supabase.auth.onAuthStateChange;
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isLoading = true);
    
    try {
      // Get current session
      final session = supabase.auth.currentSession;
      
      if (session != null) {
        // Get user data
        final user = session.user;
        
        // Check if email is verified
        if (user.emailConfirmedAt != null) {
          _handleSuccessfulVerification();
          return;
        }
      }
      
      // If not verified, start listening for auth state changes
      _startAuthStateListener();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAuthStateListener() {
    _authStateChanges.listen((data) async {
      final session = data.session;
      if (session != null && session.user.emailConfirmedAt != null) {
        _handleSuccessfulVerification();
      }
    });
  }

  Future<void> _handleSuccessfulVerification() async {
    if (_isEmailVerified) return;
    
    setState(() => _isEmailVerified = true);
    
    // Save role to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isServiceProvider', widget.isServiceProvider);
    
    if (!mounted) return;
    
    // Navigate to home screen after verification
    // The user will need to log in again after verification
    if (mounted) {
      Navigator.pushReplacementNamed(context, LoginPage.route);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email,
        emailRedirectTo: 'io.supabase.locabuzz://login-callback', // Update with your deep link
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!')),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend verification email')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandTitle(),
              const SizedBox(height: 32),
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: BeeColors.beeYellow,
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification email to:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BeeColors.beeBlack,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _isResending ? null : _resendVerificationEmail,
                          child: _isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Resend Verification Email'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              LoginPage.route,
                            );
                          },
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
