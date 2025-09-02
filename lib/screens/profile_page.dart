import 'package:flutter/material.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  static const String route = '/profile';
  
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, dynamic>> _profileOptions = [
    {'icon': Icons.person_outline, 'title': 'Edit Profile', 'trailing': Icons.chevron_right},
    {'icon': Icons.location_on_outlined, 'title': 'Saved Addresses', 'trailing': Icons.chevron_right},
    {'icon': Icons.credit_card_outlined, 'title': 'Payment Methods', 'trailing': Icons.chevron_right},
    {'icon': Icons.history, 'title': 'Order History', 'trailing': Icons.chevron_right},
    {'icon': Icons.favorite_border, 'title': 'Favorites', 'trailing': Icons.chevron_right},
    {'icon': Icons.settings_outlined, 'title': 'Settings', 'trailing': Icons.chevron_right},
    {'icon': Icons.help_outline, 'title': 'Help & Support', 'trailing': Icons.chevron_right},
    {'icon': Icons.logout, 'title': 'Logout', 'trailing': Icons.chevron_right, 'isLogout': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [BeeColors.beeYellow, Colors.white],
                stops: [0.6, 1.0],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: BeeColors.beeBlack),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BeeColors.beeBlack,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: BeeColors.beeBlack, size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage('assets/images/profile_placeholder.jpg'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BeeColors.beeBlack,
                  ),
                ),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: BeeColors.beeGrey,
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('24', 'Bookings'),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      _buildStatItem('12', 'Favorites'),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      _buildStatItem('4.8', 'Rating'),
                    ],
                  ),
                ),
              ),
            ),
          // Profile Options
          ..._profileOptions.map((option) => _buildProfileOption(option)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BeeColors.beeBlack,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(Map<String, dynamic> option) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minLeadingWidth: 24,
        dense: true,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: option['isLogout'] == true 
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            option['icon'],
            size: 18,
            color: option['isLogout'] == true ? Colors.red : BeeColors.beeBlack,
          ),
        ),
        title: Text(
          option['title'],
          style: TextStyle(
            fontSize: 14,
            color: option['isLogout'] == true ? Colors.red : BeeColors.beeBlack,
            fontWeight: option['isLogout'] == true ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: option['isLogout'] == true
            ? null
            : Icon(option['trailing'], color: Colors.grey.shade400, size: 18),
        onTap: () {
          if (option['isLogout'] == true) {
            _showLogoutConfirmation(context);
          }
          // Handle other options
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
