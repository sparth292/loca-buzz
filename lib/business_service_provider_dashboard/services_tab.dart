import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:locabuzz/business_service_provider_dashboard/add_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' show BeeColors;

class ServicesTab extends StatefulWidget {
  const ServicesTab({Key? key}) : super(key: key);

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _deleteService(String serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('service_providers')
          .delete()
          .eq('id', serviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
        await _fetchServices(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete service. Please try again.')),
        );
      }
      debugPrint('Error deleting service: $e');
    }
  }

  Future<void> _fetchServices() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // First, get the profile ID from the profiles table
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .single();

      if (profileResponse == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final profileId = profileResponse['id'] as String;

      // Then fetch services that match this profile_id
      final response = await Supabase.instance.client
          .from('service_providers')
          .select()
          .eq('profile_id', profileId);

      if (mounted) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading services')),
        );
      }
      debugPrint('Error fetching services: $e');
    }
  }

  Future<void> _navigateToAddService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddServicePage()),
    );
    
    if (result != null && mounted) {
      await _fetchServices();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.box_remove,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Services Added',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first service',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image or Placeholder
          if (service['image_url'] != null && service['image_url'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                service['image_url'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.photo_camera_outlined, color: Colors.grey, size: 32),
              ),
            ),
          
          // Service Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name and Category
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service['service_name'] ?? 'Untitled Service',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (service['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BeeColors.beeYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (service['category'] as String).isNotEmpty
                              ? '${service['category'][0].toUpperCase()}${service['category'].toString().substring(1)}'
                              : 'General',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                if (service['description'] != null && (service['description'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      service['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                
                // Price and Experience
                Row(
                  children: [
                    // Price
                    if (service['price_range'] != null)
                      Row(
                        children: [
                          Icon(Iconsax.money, size: 16, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Text(
                            service['price_range'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    
                    const Spacer(),
                    
                    // Experience
                    if (service['experience_years'] != null)
                      Row(
                        children: [
                          Icon(Iconsax.award, size: 16, color: BeeColors.beeYellow),
                          const SizedBox(width: 4),
                          Text(
                            '${service['experience_years']} ${int.parse(service['experience_years'].toString()) == 1 ? 'year' : 'years'} exp',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[100]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Edit Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: Implement edit functionality
                    },
                    icon: const Icon(Iconsax.edit_2, size: 18, color: Colors.blue),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Delete Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _deleteService(service['id']),
                    icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(BeeColors.beeYellow),
              ),
            )
          : _services.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: BeeColors.beeYellow,
                  onRefresh: _fetchServices,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'My Services',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      
                      // Services List
                      ..._services.map((service) => _buildServiceCard(service)).toList(),
                      
                      const SizedBox(height: 32), // Extra space at the bottom
                    ],
                  ),
                ),
    );
  }
}