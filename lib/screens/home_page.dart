import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'explore_screen.dart';
import 'messages_screen.dart';
import 'profile_page.dart';
import 'show_service.dart';
import '../services/featured_services.dart';

// Apply Poppins font to all text in the app
final TextTheme textTheme = GoogleFonts.poppinsTextTheme();

class HomePage extends StatefulWidget {
  static const String route = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  int _selectedBottomNavIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // Handle tab selection
  void _onItemTapped(int index) {
    // Normal tab navigation
    setState(() {
      _selectedBottomNavIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.electrical_services, 'label': 'Electrician'},
    {'icon': Icons.shopping_cart, 'label': 'Groceries'},
    {'icon': Icons.restaurant, 'label': 'Street Food'},
    {'icon': Icons.plumbing, 'label': 'Plumber'},
    {'icon': Icons.car_repair, 'label': 'Mechanic'},
    {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
    {'icon': Icons.more_horiz, 'label': 'More'},
  ];

  // Remove profile tab from bottom navigation
  // Navigation method for profile avatar
  Future<void> _navigateToProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          onProfileUpdated: () {
            // This will be called when the profile is updated
            setState(() {});
          },
        ),
      ),
    );
    
    // If we return from profile with a result, refresh the page
    if (result == true) {
      setState(() {});
    }
  }

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Special Offers',
      'subtitle': 'Up to 50% off on all services',
      'icon': Icons.local_offer_outlined,
      'backgroundColor': const Color(0xFF6E5DE7),
    },
    {
      'title': 'New Services',
      'subtitle': 'Discover our latest service providers',
      'icon': Icons.explore,
      'backgroundColor': const Color(0xFF4CAF50),
    },
    {
      'title': 'Top Rated',
      'subtitle': 'Check out our highest rated professionals',
      'icon': Icons.star_border,
      'backgroundColor': const Color(0xFFFF9800),
    },
  ];
  
  final PageController _carouselController = PageController(viewportFraction: 0.95);

  List<Map<String, dynamic>> _featuredBusinesses = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFeaturedServices();
  }

  Future<void> _loadFeaturedServices() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final services = await FeaturedServices.getFeaturedServices();
      if (mounted) {
        setState(() {
          _featuredBusinesses = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load services. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  // Get the current page title based on the selected tab
  String _getAppBarTitle() {
    switch (_selectedBottomNavIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Explore';
      case 2:
        return 'Messages';
      default:
        return 'LocaBuzz';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedBottomNavIndex == 0 
            ? const BrandTitle(fontSize: 24, textAlign: TextAlign.left)
            : Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: BeeColors.beeBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: BeeColors.beeBlack,
        actions: [
          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: _navigateToProfile,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(Icons.person_outline, size: 20, color: Colors.black54),
              ),
            ),
          ),
          // Notification Icon
          SizedBox(width: 5,),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
        },
        children: [
          // Home Tab
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel with PageView
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _carouselController,
                        itemCount: _carouselItems.length,
                        itemBuilder: (context, index) {
                          final item = _carouselItems[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: item['backgroundColor'],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  bottom: 16,
                                  width: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: Colors.white.withOpacity(0.2),
                                      child: Icon(
                                        item['icon'],
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['subtitle'],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Removed page indicator dots as requested
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Categories
                Text(
                  'Categories',
                  style: GoogleFonts.poppins(
                    color: BeeColors.beeBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) => _buildCategoryItem(
                      _categories[index]['icon'],
                      _categories[index]['label'],
                      index == _selectedCategoryIndex,
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Featured Businesses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Near You',
                      style: GoogleFonts.poppins(
                        color: BeeColors.beeBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: GoogleFonts.poppins(
                          color: BeeColors.beeYellow,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _error,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : _featuredBusinesses.isEmpty
                              ? const Center(
                                  child: Text('No services available'),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _featuredBusinesses.length,
                                  itemBuilder: (context, index) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShowServiceScreen(
                                            serviceId: _featuredBusinesses[index]['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildBusinessCard(_featuredBusinesses[index]),
                                  ),
                                  padding: const EdgeInsets.only(bottom: 2, left: 12, right: 4),
                                ),
                ),
                // Single spacing after featured businesses
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Explore Screen
          const ExploreScreen(),
          // Messages Screen
          const MessagesScreen(),
          // Removed profile page from PageView since we're using app bar avatar
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedBottomNavIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Messages',
              ),
            ],
            selectedItemColor: BeeColors.beeBlack,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BeeColors.beeYellow : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? BeeColors.beeBlack : BeeColors.beeGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: isSelected ? BeeColors.beeBlack : BeeColors.beeGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Image - Fixed height
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: business['image_url'] != null
                  ? Image.network(
                      business['image_url']!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            
            // Content with flexible space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row with name and price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Name
                        Expanded(
                          child: Text(
                            business['name'] ?? 'No Name',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Price on the right side
                        if (business['price_range'] != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              business['price_range'],
                              style: GoogleFonts.poppins(
                                color: Colors.green[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Category
                    Text(
                      business['category'] ?? 'No Category',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Buttons Row
                    Row(
                      children: [
                        // Call Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: business['provider_phone'] != null
                                ? () => _makePhoneCall(business['provider_phone'])
                                : null,
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BeeColors.beeYellow,
                              foregroundColor: BeeColors.beeBlack,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8), // Space between buttons
                        
                        // Message Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement message functionality
                            },
                            icon: const Icon(Icons.message, size: 16),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: BeeColors.beeBlack,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
    );
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone')),
      );
    }
  }
}
