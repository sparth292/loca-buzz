import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locabuzz/screens/role_selection_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../main.dart'; // Import main.dart to access BeeColors

class OnboardingScreen extends StatefulWidget {
  static const String route = '/onboarding';

  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Discover Local\nServices Easily!',
      'description':
      'Find the best businesses and services\nnear you with just a few taps.',
      'image': 'assets/images/search.svg',
    },
    {
      'title': 'Book Appointments\nInstantly',
      'description':
      'Book services on the go with our easy-\nto-use booking system.',
      'image': 'assets/images/appointment.svg',
    },
    {
      'title': 'Manage Your Business\nProfile Smoothly.',
      'description':
      'If you’re a service provider, manage your\nbookings, customers, and reviews seamlessly.',
      'image': 'assets/images/business.svg',
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToNext() {
    if (_currentPage == _numPages - 1) {
      Navigator.pushReplacementNamed(context, '/role-selection');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _numPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration
                        Expanded(
                          child: SvgPicture.asset(
                            _onboardingData[index]['image'],
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: BeeColors.beeBlack,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          _onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: BeeColors.beeBlack.withOpacity(0.7),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ],
                      
                    ),
                  );
                },
              ),
            ),

            // Indicator + Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _numPages,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      activeDotColor: BeeColors.beeYellow,
                      dotColor: BeeColors.beeGrey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _navigateToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BeeColors.beeYellow,
                        foregroundColor: BeeColors.beeBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
