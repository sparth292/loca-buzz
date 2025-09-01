  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  import '../main.dart' show BeeColors, BrandTitle, supabase;
  import 'email_confirmation_screen.dart';
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

    // Future<void> _handleSignUp() async {
    //   if (!_formKey.currentState!.validate()) return;
    //   if (!acceptedTerms) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Please accept the terms and conditions')),
    //     );
    //     return;
    //   }

    //   setState(() => _isLoading = true);

    //   try {
    //     // 1. Sign up the user with email confirmation
    //     final email = _emailController.text.trim();
    //     final password = _passwordController.text.trim();
        
    //     final authResponse = await supabase.auth.signUp(
    //       email: email,
    //       password: password,
    //       emailRedirectTo: 'io.supabase.locabuzz://login-callback', // Update with your deep link
    //       data: {
    //         'full_name': _fullNameController.text.trim(),
    //         'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
    //         'phone': _phoneController.text.trim(),
    //         'is_service_provider': widget.isServiceProvider,
    //       },
    //     );

    //     if (authResponse.user == null) {
    //       throw Exception('Failed to create user account');
    //     }

    //     // 2. Create user profile in the database
    //     await supabase.from('profiles').insert({
    //       'id': authResponse.user!.id,
    //       'email': email,
    //       'full_name': _fullNameController.text.trim(),
    //       'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
    //       'phone': _phoneController.text.trim(),
    //       'is_service_provider': widget.isServiceProvider,
    //       'created_at': DateTime.now().toIso8601String(),
    //     });

    //     if (!mounted) return;
        
    //     // 3. Navigate to email confirmation screen
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => EmailConfirmationScreen(
    //           email: email,
    //           password: password,
    //           isServiceProvider: widget.isServiceProvider,
    //         ),
    //       ),
    //     );
        
    //   } on AuthException catch (error) {
    //     if (!mounted) return;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(error.message)),
    //     );
    //   } catch (error) {
    //     if (!mounted) return;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('An error occurred during signup')),
    //     );
    //   } finally {
    //     if (mounted) {
    //       setState(() => _isLoading = false);
    //     }
    //   }
    // }

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
                        onPressed: () => Navigator.pushReplacementNamed(context, EmailConfirmationScreen.route),
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Username (optional)
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username (optional)',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Terms and Conditions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              activeColor: BeeColors.beeYellow,
                              value: acceptedTerms,
                              onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms & Privacy Policy',
                                style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () {
                              // Navigate to email confirmation screen with required parameters
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailConfirmationScreen(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    isServiceProvider: widget.isServiceProvider,
                                  ),
                                ),
                              );
                            },
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Create Account'),
                          ),
                        ),
                      ],
                    ),
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

  