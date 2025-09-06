import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    Widget body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _services.isEmpty
            ? const Center(
                child: Text(
                  'No services added yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - Service details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (service['service_name'] != null) ...[
                                      Text(
                                        service['service_name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (service['category'] != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: BeeColors.beeYellow.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          service['category'][0].toUpperCase() + service['category'].toString().substring(1),
                                          style: TextStyle(
                                            color: Colors.orange[800],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (service['description'] != null) ...[
                                      Text(
                                        service['description'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (service['price_range'] != null) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            service['price_range'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (service['experience_years'] != null) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.workspace_premium,
                                              color: BeeColors.beeYellow, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${service['experience_years']} years exp',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Right side - Image
                              if (service['image_url'] != null && service['image_url'].toString().isNotEmpty) ...[
                                const SizedBox(width: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    service['image_url'],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error_outline, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Delete button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextButton.icon(
                            onPressed: () => _deleteService(service['id']),
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            label: const Text(
                              'Delete Service',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

    return Scaffold(
      backgroundColor: BeeColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddService,
        backgroundColor: BeeColors.beeYellow,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchServices,
        child: body,
      ),
    );
  }
}