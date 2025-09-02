import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show BeeColors, supabase;
import 'email_confirmation_screen.dart';

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
  int _currentStep = 0;
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _previousStep,
            controlsBuilder: (context, details) {
              return _buildStepperControls(details);
            },
            steps: [
              _buildAccountStep(),
              _buildProfileStep(),
              _buildTermsStep(),
            ],
          ),
        ),
      ),
    );
  }

  // Build methods for each step will be added here
  Step _buildAccountStep() {
    return Step(
      title: Text('Account', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      content: Column(
        children: [
          // Will be implemented in next step
          const SizedBox(height: 20),
          Text('Account Step Content', style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Step _buildProfileStep() {
    return Step(
      title: Text('Profile', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      content: const Column(
        children: [
          // Will be implemented in next step
          SizedBox(height: 20),
          Text('Profile Step Content'),
        ],
      ),
    );
  }

  Step _buildTermsStep() {
    return Step(
      title: Text('Terms', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      content: const Column(
        children: [
          // Will be implemented in next step
          SizedBox(height: 20),
          Text('Terms Step Content'),
        ],
      ),
    );
  }

  Widget _buildStepperControls(ControlsDetails details) {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : details.onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: BeeColors.beeYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep == 2 ? 'Create Account' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : details.onStepCancel,
          child: Text(
            _currentStep > 0 ? 'Back' : 'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else if (_acceptedTerms) {
        _handleSignUp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the terms and conditions')),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.locabuzz://login-callback',
        data: {
          'full_name': _fullNameController.text.trim(),
          'username': _usernameController.text.trim().isEmpty
              ? null
              : _usernameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'is_service_provider': widget.isServiceProvider,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      await supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': _fullNameController.text.trim(),
        'username': _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'is_service_provider': widget.isServiceProvider,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailConfirmationScreen(
            email: email,
            password: password,
            isServiceProvider: widget.isServiceProvider,
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during signup')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
