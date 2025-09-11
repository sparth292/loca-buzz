import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import '../main.dart';
import 'explore_screen.dart';
import 'messages_screen.dart';
import 'profile_page.dart';
import 'show_service.dart';
import '../services/featured_services.dart';
import 'location_setup_screen.dart';

// Apply Poppins font to all text in the app
final TextTheme textTheme = GoogleFonts.poppinsTextTheme();

// Location Selection Dialog Widget
class LocationSelectionDialog extends StatelessWidget {
  final VoidCallback? onCurrentLocationTap;
  
  const LocationSelectionDialog({
    super.key, 
    this.onCurrentLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Select Delivery Address',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Location
            _buildAddressTile(
              context,
              title: 'Use Current Location',
              subtitle: 'Get precise location using GPS',
              icon: Icons.my_location,
              onTap: onCurrentLocationTap ?? () {
                // Fallback if onCurrentLocationTap is not provided
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Saved Addresses
            const Text(
              'SAVED ADDRESSES',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Home Address
            _buildAddressTile(
              context,
              title: 'Home',
              subtitle: '123 Main St, City, Country',
              icon: Icons.home_outlined,
              onTap: () {
                // This would use the saved home address
                Navigator.pop(context, {
                  'address': '123 Main St, City, Country',
                  'latitude': 0.0, // Replace with actual coordinates
                  'longitude': 0.0, // Replace with actual coordinates
                });
              },
            ),
            const SizedBox(height: 12),
            // Work Address
            _buildAddressTile(
              context,
              title: 'Work',
              subtitle: '456 Business Ave, City, Country',
              icon: Icons.work_outline,
              onTap: () {
                // This would use the saved work address
                Navigator.pop(context, {
                  'address': '456 Business Ave, City, Country',
                  'latitude': 0.0, // Replace with actual coordinates
                  'longitude': 0.0, // Replace with actual coordinates
                });
              },
            ),
            const SizedBox(height: 16),
            // Enter Location Manually Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushNamed(context, LocationSetupScreen.route);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: BeeColors.beeYellow),
                ),
                icon: const Icon(Icons.search, color: BeeColors.beeBlack),
                label: const Text(
                  'Enter Location Manually',
                  style: TextStyle(color: BeeColors.beeBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BeeColors.beeYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: BeeColors.beeBlack),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

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
  
  // Location related variables
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

  // Load saved location data
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_locationKey);
      
      if (savedData != null) {
        setState(() {
          _savedLocation = json.decode(savedData);
        });
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Get current location and reverse geocode to address
  Future<Map<String, dynamic>?> _getCurrentLocation() async {
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location services are disabled')),
            );
          }
          return null;
        }
      }

      // Check location permission
      var permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return null;
        }
      }

      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(BeeColors.beeYellow),
            ),
          ),
        );
      }

      // Get current location
      final currentLocation = await location.getLocation();
      
      // In a production app, you would use a geocoding service here
      // For example, using the geocoding package:
      // final placemarks = await placemarkFromCoordinates(
      //   currentLocation.latitude!,
      //   currentLocation.longitude!,
      // );
      // final place = placemarks.first;
      // final address = '${place.street}, ${place.locality}, ${place.postalCode}';
      
      // For now, we'll just return the coordinates as address
      final address = 'Current Location (${currentLocation.latitude!.toStringAsFixed(4)}, ${currentLocation.longitude!.toStringAsFixed(4)})';
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      return {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'address': address,
      };
    } catch (e) {
      // Close loading dialog if it's still open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      return null;
    }
  }

  // Show location selection dialog
  Future<void> _showLocationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) => LocationSelectionDialog(
        onCurrentLocationTap: () async {
          final location = await _getCurrentLocation();
          if (location != null && context.mounted) {
            Navigator.of(context).pop(location);
          }
        },
      ),
    );

    if (result != null) {
      // Save the selected location
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_locationKey, json.encode(result));
        
        setState(() {
          _savedLocation = result;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save location')),
          );
        }
      }
    }
  }

  // This method is kept for future use when navigating to location setup is needed
  // Currently using direct navigation in the LocationSelectionDialog
  // Future<void> _navigateToLocationSetup() async {
  //   final result = await Navigator.pushNamed(
  //     context,
  //     LocationSetupScreen.route,
  //   );

  //   if (result != null && result is Map<String, dynamic>) {
  //     // Update the saved location
  //     setState(() {
  //       _savedLocation = result;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadFeaturedServices();
    _startAutoScroll();
    _loadSavedLocation();
    _carouselController = PageController(
      viewportFraction: 0.95,
      initialPage: 1000, // Start at a high number for infinite scroll
    );
    _startAutoScroll();
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
            ? GestureDetector(
                onTap: _showLocationDialog,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandTitle(fontSize: 20, textAlign: TextAlign.left),
                    const SizedBox(height: 2),
                    _isLoadingLocation
                        ? const SizedBox(
                            width: 120,
                            height: 16,
                            child: LinearProgressIndicator(
                              color: BeeColors.beeYellow,
                              backgroundColor: Colors.grey,
                              minHeight: 2,
                            ),
                          )
                        : Text(
                            _savedLocation?['address']?.toString() ?? 'Tap to set location',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
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
