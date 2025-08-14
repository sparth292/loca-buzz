import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'sign_up_screen.dart';
import '../business_service_provider_dashboard/service_provider_dashboard.dart';
import '../main.dart' show BeeColors, BrandTitle;

class LoginPage extends StatefulWidget {
  static const String route = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;

  Future<void> _handleLogin() async {
    // TODO: Implement actual login logic
    // For now, we'll just check the role and navigate
    final prefs = await SharedPreferences.getInstance();
    final isServiceProvider = prefs.getBool('isServiceProvider') ?? false;
    
    if (!mounted) return;
    
    if (isServiceProvider) {
      // Navigate to service provider dashboard
      Navigator.pushReplacementNamed(context, ServiceProviderDashboard.route);
    } else {
      // Navigate to regular home page
      Navigator.pushReplacementNamed(context, HomePage.route);
    }
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const BrandTitle(),
              const SizedBox(height: 8),
              const Text(
                'Discover local businesses near you',
                textAlign: TextAlign.center,
                style: TextStyle(color: BeeColors.beeBlack, fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline),
                  hintText: 'Email or phone',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: _obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final isServiceProvider = prefs.getBool('isServiceProvider') ?? false;
                  
                  if (isServiceProvider) {
                    // Navigate to service provider dashboard
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, ServiceProviderDashboard.route);
                  } else {
                    // Navigate to regular home page
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, HomePage.route);
                  }
                },
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, color: BeeColors.beeBlack),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Continue with Google', style: TextStyle(color: BeeColors.beeBlack)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.facebook, color: BeeColors.beeBlack),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Continue with Facebook', style: TextStyle(color: BeeColors.beeBlack)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: _navigateToSignUp,
                    child: const Text('Sign up'),
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