import 'package:flutter/material.dart';
import '../main.dart' show BeeColors;
import 'orders_tab.dart';
import 'reports_tab.dart';
import 'messages_tab.dart';
import 'service_provider_profile.dart';
import 'add_service.dart';
import 'services_tab.dart';

class ServiceProviderDashboard extends StatefulWidget {
  static const String route = '/service-provider-dashboard';
  
  const ServiceProviderDashboard({super.key});

  @override
  State<ServiceProviderDashboard> createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _services = [];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardOverviewTab(onServiceAdded: _handleServiceAdded),
      ServicesTab(),
      const OrdersTab(),
      ReportsTab(),
      MessagesTab(),
    ];
  }

  void _handleServiceAdded(Map<String, String> service) {
    setState(() {
      _services.add(service);
      _currentIndex = 1; // Switch to Services tab
      _pageController.jumpToPage(1);
    });
  }

  // final List<String> _titles = [
  //   'Business Dashboard',
  //   'Listings',
  //   'Orders',
  //   'Reports',
  //   'Messages',
  // ];

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
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
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
          // Profile Avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ServiceProviderProfile.route);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BeeColors.beeYellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
            icon: Icon(Icons.design_services),
            label: 'Services',
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
  final void Function(Map<String, String>) onServiceAdded;
  const DashboardOverviewTab({super.key, required this.onServiceAdded});

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
              _ActionButton(icon: Icons.add_box_outlined, label: 'Add Service', onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddServicePage()),
  );
  if (result is Map<String, String>) {
    onServiceAdded(result);
  }
}), // to add service 
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
