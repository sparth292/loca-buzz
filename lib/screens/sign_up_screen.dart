import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locabuzz/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'login_screen.dart';

class SignupPage extends StatefulWidget {
  static const String route = '/signup';
  final bool isServiceProvider;
  
  const SignupPage({
    super.key,
    this.isServiceProvider = false,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int currentStep = 0;
  bool acceptedTerms = false;

  Future<void> _handleSignUp() async {
    // TODO: Implement signup logic with your backend
    // After successful signup, save the role and navigate accordingly
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isServiceProvider', widget.isServiceProvider);
    
    // Navigate to home or service provider dashboard based on role
    if (widget.isServiceProvider) {
      // TODO: Navigate to service provider dashboard
      Navigator.pushReplacementNamed(context, LoginPage.route);
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role indicator
                if (widget.isServiceProvider)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: BeeColors.beeYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BeeColors.beeYellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_outlined, size: 16, color: BeeColors.beeBlack),
                        const SizedBox(width: 6),
                        Text(
                          'Service Provider Account',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: BeeColors.beeBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, LoginPage.route),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const BrandTitle(),
                const SizedBox(height: 8),
                const Text(
                  'Join our community today',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BeeColors.beeBlack, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Stepper(
                  type: StepperType.vertical,
                  currentStep: currentStep,
                  onStepContinue: () {
                    if (currentStep < 2) {
                      setState(() => currentStep += 1);
                    } else {
                      _handleSignUp();
                    }
                  },
                  onStepCancel: () {
                    if (currentStep > 0) setState(() => currentStep -= 1);
                  },
                  controlsBuilder: (context, details) {
                    final bool isLast = currentStep == 2;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              child: Text(isLast ? 'Create account' : 'Continue'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (currentStep > 0)
                            TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Account'),
                      isActive: currentStep >= 0,
                      state: currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: Column(
                        children: const [
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'Full name',
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline),
                              hintText: 'Email address',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Profile'),
                      isActive: currentStep >= 1,
                      state: currentStep > 1 ? StepState.complete : StepState.indexed,
                      content: Column(
                        children: const [
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.badge_outlined),
                              hintText: 'Username (optional)',
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone_outlined),
                              hintText: 'Phone number',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Terms'),
                      isActive: currentStep >= 2,
                      state: currentStep >= 2 && acceptedTerms ? StepState.complete : StepState.indexed,
                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            activeColor: BeeColors.beeYellow,
                            value: acceptedTerms,
                            onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'I agree to the Terms & Privacy Policy',
                              style: TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, LoginPage.route),
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}