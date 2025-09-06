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

  Future<void> _fetchServices() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('service_providers')
          .select()
          .eq('profile_id', user.id);

      if (mounted) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (service['service_name'] != null) ...[
                            Text(
                              service['service_name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (service['description'] != null) ...[
                            Text(service['description']),
                            const SizedBox(height: 8),
                          ],
                          if (service['price_range'] != null) ...[
                            Text(
                              'Price: ${service['price_range']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (service['experience_years'] != null) ...[
                            Row(
                              children: [
                                Icon(Icons.workspace_premium,
                                    color: BeeColors.beeYellow, size: 18),
                                const SizedBox(width: 6),
                                Text('Experience: ${service['experience_years']} years'),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (service['availability'] != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text('Available: ${service['availability']}'),
                              ],
                            ),
                          ],
                        ],
                      ),
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