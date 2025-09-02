import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class ExploreScreen extends StatelessWidget {
  static const String route = '/explore';
  
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.electric_bolt, 'label': 'Electricians', 'color': Colors.orange},
      {'icon': Icons.plumbing, 'label': 'Plumbers', 'color': Colors.blue},
      {'icon': Icons.cleaning_services, 'label': 'Cleaning', 'color': Colors.green},
      {'icon': Icons.delivery_dining, 'label': 'Food Delivery', 'color': Colors.red},
      {'icon': Icons.car_repair, 'label': 'Mechanics', 'color': Colors.blueGrey},
      {'icon': Icons.medical_services, 'label': 'Medical', 'color': Colors.pink},
    ];

    final List<Map<String, dynamic>> trendingBusinesses = [
      {
        'name': 'Sparky Electrics',
        'category': 'Electrician',
        'rating': 4.8,
        'distance': '0.5 km',
        'image': 'assets/images/electrician.jpg',
      },
      {
        'name': 'Fresh Mart',
        'category': 'Grocery Store',
        'rating': 4.5,
        'distance': '1.2 km',
        'image': 'assets/images/grocery.jpg',
      },
      {
        'name': 'Quick Clean',
        'category': 'Cleaning Service',
        'rating': 4.7,
        'distance': '0.8 km',
        'image': 'assets/images/cleaning.jpg',
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            backgroundColor: Colors.white,
            title: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for services...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, color: BeeColors.beeBlack),
                onPressed: () {},
              ),
            ],
          ),
          
          // Categories
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: BeeColors.beeBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110, // Increased from 100 to 140
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _buildCategoryItem(category);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trending Near You
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Near You',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: BeeColors.beeBlack,
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
            ),
          ),

          // Grid View for Trending Businesses
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final business = trendingBusinesses[index % trendingBusinesses.length];
                  return _buildBusinessCard(business);
                },
                childCount: 4, // Show 2x2 grid
              ),
            ),
          ),

          // Popular Services
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Popular Services',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: BeeColors.beeBlack,
                ),
              ),
            ),
          ),

          // Horizontal List of Popular Services
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150, // Reduced height to prevent overflow
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150, // Slightly reduced width
                    margin: const EdgeInsets.only(right: 8),
                    child: _buildServiceItem(
                      'AC Repair',
                      'assets/images/ac_repair.jpg',
                      'Starting at ₹499',
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Container(
      width: 90, // Slightly wider to accommodate larger icons
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16), // Slightly more rounded
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              category['icon'],
              color: category['color'],
              size: 32, // Slightly larger icon
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category['label'],
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Image
          SizedBox(
            height: 100,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                business['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.business, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          // Business Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business['name'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  business['category'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      ' ${business['rating']} • ${business['distance']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildServiceItem(String service, String image, String price) {
    return SizedBox(
      height: 110, // Reduced height to prevent overflow
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            SizedBox(
              height: 70, // Reduced image height
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.miscellaneous_services, size: 30, color: Colors.grey),
                  ),
                ),
              ),
            ),
            // Service Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
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
