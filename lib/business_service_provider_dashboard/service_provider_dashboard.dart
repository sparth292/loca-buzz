import 'package:flutter/material.dart';
import '../main.dart' show BeeColors;
import 'listings_tab.dart';
import 'orders_tab.dart';
import 'reports_tab.dart';
import 'messages_tab.dart';

class ServiceProviderDashboard extends StatefulWidget {
  static const String route = '/service-provider-dashboard';
  
  const ServiceProviderDashboard({super.key});

  @override
  State<ServiceProviderDashboard> createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    DashboardOverviewTab(),
    ListingsTab(),
    OrdersTab(),
    ReportsTab(),
    MessagesTab(),
  ];

  final List<String> _titles = [
    'Business Dashboard',
    'Listings',
    'Orders',
    'Reports',
    'Messages',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Loca',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Buzz',
              style: TextStyle(
                color: BeeColors.beeYellow,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          if (_currentIndex == 0) // Show settings only on dashboard
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black87),
              onPressed: () {
                // TODO: Navigate to settings
              },
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: BeeColors.beeYellow,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Messages',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 1:
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: BeeColors.beeYellow,
          child: const Icon(Icons.add, color: Colors.black),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: BeeColors.beeYellow,
          child: const Icon(Icons.add_shopping_cart, color: Colors.black),
        );
      default:
        return null;
    }
  }
}

// Dashboard Overview Tab
class DashboardOverviewTab extends StatelessWidget {
  const DashboardOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats Cards
          const Row(
            children: [
              Expanded(child: _StatCard(title: 'Total Orders', value: '156', icon: Icons.shopping_bag_outlined)),
              SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Earnings', value: '₹45,200', icon: Icons.attach_money_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _StatCard(title: 'Active Listings', value: '24', icon: Icons.inventory_2_outlined)),
              SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Rating', value: '4.8 ★', icon: Icons.star_border_outlined)),
            ],
          ),
          
          const SizedBox(height: 20),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _ActionButton(icon: Icons.add_box_outlined, label: 'Add Service', onTap: () {}), // to add service 
              _ActionButton(icon: Icons.photo_camera_outlined, label: 'Upload Images', onTap: () {}), // to add images
              _ActionButton(icon: Icons.location_on_outlined, label: 'Update Location', onTap: () {}), // to update location
              _ActionButton(icon: Icons.analytics_outlined, label: 'View Reports', onTap: () {}), // to view reports
            ],
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, color: BeeColors.beeYellow),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: BeeColors.beeYellow),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// Tab components are now in separate files for better organization
