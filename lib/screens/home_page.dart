import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../main.dart';
import 'messages_screen.dart';
import 'explore_screen.dart';


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

  void _onItemTapped(int index) {
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

  final List<Map<String, dynamic>> _featuredBusinesses = [
    {
      'name': 'Sparky Electrics',
      'category': 'Electrician',
      'rating': 4.8,
      'distance': 1.2,
      'image': 'assets/images/electrician.jpg',
    },
    {
      'name': 'Fresh Mart',
      'category': 'Grocery Store',
      'rating': 4.5,
      'distance': 0.8,
      'image': 'assets/images/grocery.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandTitle(fontSize: 24, textAlign: TextAlign.left),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: BeeColors.beeBlack,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: BeeColors.beeYellow,
                child: Icon(Icons.person_outline, color: BeeColors.beeBlack, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping between pages
        children: [
          // Home Page Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel with PageView
                SizedBox(
                  height: 160,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _carouselController,
                          itemCount: _carouselItems.length,
                          onPageChanged: (index) {},
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: _carouselItems[index]['backgroundColor'],
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
                                            _carouselItems[index]['icon'],
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
                                            _carouselItems[index]['title'],
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _carouselItems[index]['subtitle'],
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
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SmoothPageIndicator(
                        controller: _carouselController,
                        count: _carouselItems.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: BeeColors.beeYellow,
                          dotColor: Colors.grey,
                        ),
                        onDotClicked: (index) {
                          _carouselController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
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
                  height: 220, // Further reduced height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredBusinesses.length,
                    itemBuilder: (context, index) => _buildBusinessCard(_featuredBusinesses[index]),
                    padding: const EdgeInsets.only(bottom: 2, left: 12, right: 4), // Reduced bottom padding
                  ),
                ),
                // Single spacing after featured businesses
              ],
            ),
          ),
          // Explore Screen
          const ExploreScreen(),
          // Messages Screen
          const MessagesScreen(),
          // Profile Tab
          _buildProfileTab(),
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
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    _selectedBottomNavIndex == 0 
                        ? Icons.home_rounded 
                        : Icons.home_outlined,
                  ),
                ),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.chat_bubble_outline),
                    if (_selectedBottomNavIndex != 2)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: _selectedBottomNavIndex == 3 
                    ? Icon(Icons.person) 
                    : Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
            selectedItemColor: BeeColors.beeBlack,
            unselectedItemColor: BeeColors.beeGrey,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildProfileTab() {
    final List<Map<String, dynamic>> profileOptions = [
      {'icon': Icons.person_outline, 'title': 'Edit Profile', 'trailing': Icons.chevron_right},
      {'icon': Icons.location_on_outlined, 'title': 'Saved Addresses', 'trailing': Icons.chevron_right},
      {'icon': Icons.credit_card_outlined, 'title': 'Payment Methods', 'trailing': Icons.chevron_right},
      {'icon': Icons.history, 'title': 'Order History', 'trailing': Icons.chevron_right},
      {'icon': Icons.favorite_border, 'title': 'Favorites', 'trailing': Icons.chevron_right},
      {'icon': Icons.settings_outlined, 'title': 'Settings', 'trailing': Icons.chevron_right},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'trailing': Icons.chevron_right},
      {'icon': Icons.logout, 'title': 'Logout', 'trailing': Icons.chevron_right, 'isLogout': true},
    ];

    Widget _buildProfileOption(Map<String, dynamic> option) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          minLeadingWidth: 24,
          dense: true,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: option['isLogout'] == true 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              option['icon'],
              color: option['isLogout'] == true ? Colors.red : BeeColors.beeBlack,
              size: 20,
            ),
          ),
          title: Text(
            option['title'],
            style: GoogleFonts.openSans(
              fontSize: 15,
              color: option['isLogout'] == true ? Colors.red : BeeColors.beeBlack,
              fontWeight: option['isLogout'] == true ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: option['isLogout'] == true
              ? null
              : Icon(option['trailing'], color: Colors.grey.shade400, size: 20),
          onTap: () {
            if (option['isLogout'] == true) {
              _showLogoutConfirmation(context);
            }
          },
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: BeeColors.beeYellow,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/images/profile_placeholder.jpg'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'John Doe',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat('24', 'Bookings'),
                    _buildProfileStat('12', 'Favorites'),
                    _buildProfileStat('4.8', 'Rating'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Profile Options
          ...profileOptions.map((option) => _buildProfileOption(option)).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.openSans(
            color: BeeColors.beeBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.openSans(
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.openSans(
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle logout
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.openSans(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    return Container(
      width: 250, // Further reduced width
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              business['image'],
              height: 90, // Further reduced image height
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 90,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Business Name and Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        business['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 14, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: BeeColors.beeYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: BeeColors.beeBlack),
                          const SizedBox(width: 2),
                          Text(
                            business['rating'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: BeeColors.beeBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Category and Distance
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business['category'],
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle, size: 3, color: BeeColors.beeGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${business['distance']} km',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message_outlined, size: 12),
                        label: Text(
                          'Message',
                          style: GoogleFonts.poppins(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BeeColors.beeBlack,
                          side: const BorderSide(color: BeeColors.beeGrey),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          minimumSize: const Size(0, 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone_outlined, size: 12),
                        label: Text(
                          'Call',
                          style: GoogleFonts.poppins(fontSize: 10),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BeeColors.beeYellow,
                          foregroundColor: BeeColors.beeBlack,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          minimumSize: const Size(0, 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
