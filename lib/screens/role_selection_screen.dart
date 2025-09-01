import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import '../main.dart' show BeeColors;

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool? _selectedRole; // null = not selected, false = consumer, true = service provider
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildGetStartedButton() {
    return Material(
      color: BeeColors.beeYellow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _proceedToSignUp,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRole(bool isServiceProvider) {
    setState(() {
      _selectedRole = isServiceProvider;
      if (_selectedRole != null) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _proceedToSignUp() async {
    if (_selectedRole == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isServiceProvider', _selectedRole!);
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignupPage(isServiceProvider: _selectedRole!),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background decorative elements
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: BeeColors.beeYellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: BeeColors.beeBlack.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Main content
                _buildContent(context),
                
                // Animated Get Started Button
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 24,
                  right: 24,
                  bottom: _selectedRole != null ? 40 : -100,
                  child: _buildGetStartedButton(),
                ),
              ],
            ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Title
            Text(
              'Choose your role below',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: BeeColors.beeBlack,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Consumer Card
            _RoleCard(
              title: 'Deaf or Hard of Hearing',
              description: 'Find and book sign language interpreters',
              icon: Icons.accessibility_new_rounded,
              isSelected: _selectedRole == false,
              onTap: () => _selectRole(false),
            ),
            
            const SizedBox(height: 24),
            
            // Divider with "or"
            const Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('or', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Service Provider Card
            _RoleCard(
              title: 'Sign Language Interpreter',
              description: 'Offer your interpretation services',
              icon: Icons.translate_rounded,
              isSelected: _selectedRole == true,
              onTap: () => _selectRole(true),
            ),
            
            const Spacer(),
            
            const Spacer(),
            
            // Get Started Button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedRole != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _buildGetStartedButton(),
                    )
                  : const SizedBox.shrink(),
            ),
            
            // Sign In Prompt
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: GoogleFonts.poppins(
                            color: BeeColors.beeYellow,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? BeeColors.beeYellow.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BeeColors.beeYellow : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? BeeColors.beeYellow.withOpacity(0.2) 
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: 28, 
                color: isSelected ? BeeColors.beeYellow : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? BeeColors.beeBlack : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isSelected ? Colors.grey.shade700 : Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isSelected ? BeeColors.beeYellow : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
