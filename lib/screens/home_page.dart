import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'explore_screen.dart';
import 'location_setup_screen.dart';
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
  Map<String, dynamic>? _savedLocation;
  bool _isLoadingLocation = true;
  final String _locationKey = 'user_location_data';

  // Handle tab selection
  void _onItemTapped(int index) {
    // Normal tab navigation
    setState(() {
      _selectedBottomNavIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.all_inclusive, 'label': 'All', 'value': 'all'},
    {'icon': Icons.electrical_services, 'label': 'Electrician', 'value': 'electrician'},
    {'icon': Icons.shopping_cart, 'label': 'Groceries', 'value': 'groceries'},
    {'icon': Icons.restaurant, 'label': 'Food', 'value': 'food'},
    {'icon': Icons.plumbing, 'label': 'Plumber', 'value': 'plumber'},
    {'icon': Icons.car_repair, 'label': 'Mechanic', 'value': 'mechanic'},
    {'icon': Icons.cleaning_services, 'label': 'Cleaning', 'value': 'cleaning'},
    {'icon': Icons.more_horiz, 'label': 'Others', 'value': 'others'},
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
      'backgroundColor': BeeColors.beeBlack,
      'textColor': Colors.white,
    },
    {
      'title': 'New Services',
      'subtitle': 'Discover our latest service providers',
      'icon': Icons.explore,
      'backgroundColor': BeeColors.beeBlack,
      'textColor': Colors.white,
    },
    {
      'title': 'Top Rated',
      'subtitle': 'Check out our highest rated professionals',
      'icon': Icons.star_border,
      'backgroundColor': BeeColors.beeBlack,
      'textColor': Colors.white,
    },
    {
      'title': '24/7 Support',
      'subtitle': 'We\'re here to help you anytime',
      'icon': Icons.support_agent,
      'backgroundColor': BeeColors.beeBlack,
      'textColor': Colors.white,
    },
    {
      'title': 'Premium Services',
      'subtitle': 'Exclusive services for our valued customers',
      'icon': Icons.workspace_premium,
      'backgroundColor': BeeColors.beeBlack,
      'textColor': Colors.white,
    },
  ];
  
  late final PageController _carouselController;
  Timer? _timer;
  int _currentPage = 0;
  
  List<Map<String, dynamic>> _featuredBusinesses = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _loadFeaturedServices();
    _carouselController = PageController(
      viewportFraction: 0.95,
      initialPage: 1000, // Start at a high number for infinite scroll
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }
  
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_carouselController.hasClients) {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Load saved location data
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_locationKey);
      
      if (savedData != null) {
        setState(() {
          _savedLocation = json.decode(savedData);
          _isLoadingLocation = false;
        });
        // Show location popup after a short delay to allow the UI to build
        Future.delayed(const Duration(milliseconds: 500), _showLocationPopup);
      } else {
        setState(() => _isLoadingLocation = false);
        // Show location popup if no saved location
        Future.delayed(const Duration(milliseconds: 500), _showLocationPopup);
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  // Build address tile widget
  Widget _buildAddressTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? BeeColors.beeYellow.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BeeColors.beeYellow : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? BeeColors.beeYellow : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: BeeColors.beeBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: BeeColors.beeYellow, size: 20),
          ],
        ),
      ),
    );
  }

  // Show location popup
  Future<void> _showLocationPopup() async {
    if (!mounted) return;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Delivery Address',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BeeColors.beeBlack,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: BeeColors.beeBlack),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Location permission banner
                  if (_savedLocation == null)
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context, rootNavigator: false).pushNamed(
                          LocationSetupScreen.route,
                        );
                        if (result != null && mounted) {
                          await _loadSavedLocation();
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: BeeColors.beeYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_off, color: BeeColors.beeBlack),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location Permission is Off',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: BeeColors.beeBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enable location to find services near you',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: BeeColors.beeYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ENABLE',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: BeeColors.beeBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Saved addresses
                  if (_savedLocation != null) ...[
                    // Current location
                    _buildAddressTile(
                      icon: Icons.my_location,
                      title: 'Current Location',
                      subtitle: _savedLocation!['address'] ?? 'Using your current location',
                      isSelected: true,
                      onTap: () {
                        // Use current location
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Home address if available
                    if (_savedLocation!['address'] != null)
                      _buildAddressTile(
                        icon: Icons.home,
                        title: 'Home',
                        subtitle: _savedLocation!['address'],
                        isSelected: false,
                        onTap: () {
                          // Use home address
                          Navigator.pop(context);
                        },
                      ),
                    
                    // Add new address button
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.of(context, rootNavigator: false).pushNamed(
                          LocationSetupScreen.route,
                          arguments: {'preventLeadingIcon': true},
                        );
                        if (result != null && mounted) {
                          await _loadSavedLocation();
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add_location_alt, color: BeeColors.beeYellow),
                      label: Text(
                        'Add a new address',
                        style: GoogleFonts.poppins(
                          color: BeeColors.beeYellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 23),
                  // Manual entry button
                  
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Show location popup when the location icon is tapped in the app bar
  void _showLocationPopupOnTap() {
    _showLocationPopup();
  }

  Future<void> _loadFeaturedServices({String? category}) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final services = await FeaturedServices.getFeaturedServices(category: category);
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
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deliver to',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: _showLocationPopupOnTap,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6, // Limit width to 60% of screen
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _savedLocation?['address'] ?? 'Select your location',
                              style: const TextStyle(
                                color: BeeColors.beeBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              )
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
          if (_selectedBottomNavIndex == 0)
            IconButton(
              icon: const Icon(Icons.location_on_outlined, color: BeeColors.beeYellow),
              onPressed: _showLocationPopupOnTap,
            ),
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
                // Carousel
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _carouselController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index % _carouselItems.length;
                      });
                    },
                    itemCount: null, // Infinite items
                    itemBuilder: (context, index) {
                      final itemIndex = index % _carouselItems.length;
                      final item = _carouselItems[itemIndex];
                      return Container(
                        margin: const EdgeInsets.only(left: 0, right: 6, top: 8, bottom: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: item['backgroundColor'],
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                item['backgroundColor'],
                                item['backgroundColor'].withOpacity(0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: item['textColor'] == Colors.white 
                                        ? Colors.white.withOpacity(0.1) 
                                        : BeeColors.beeBlack.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    size: 40,
                                    color: item['textColor'] == Colors.white 
                                        ? Colors.white 
                                        : BeeColors.beeBlack,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                top: 0,
                                bottom: 0,
                                right: 120, // Leave space for the icon
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item['title'],
                                        style: GoogleFonts.openSans(
                                          color: item['textColor'],
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      child: Text(
                                        item['subtitle'],
                                        style: GoogleFonts.openSans(
                                          color: item['textColor'].withOpacity(0.9),
                                          fontSize: 13,
                                          height: 1.3,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.only(left: 0, right: 6, top: 8, bottom: 0),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryItem(
                        category['icon'],
                        category['label'],
                        _selectedCategoryIndex == index,
                        value: category['value'],
                        
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                          // Reload services with the selected category
                          _loadFeaturedServices(
                            category: category['value'] == 'all' ? null : category['value']
                          );
                        },
                      );
                    },
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

  Widget _buildCategoryItem(IconData icon, String label, bool isSelected, {required String value, VoidCallback? onTap}) {
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
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: isSelected ? BeeColors.beeBlack : BeeColors.beeGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
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
