import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/featured_services.dart';
import '../main.dart';

class ShowServiceScreen extends StatefulWidget {
  final String serviceId;
  
  const ShowServiceScreen({Key? key, required this.serviceId}) : super(key: key);

  @override
  State<ShowServiceScreen> createState() => _ShowServiceScreenState();
}

class _ShowServiceScreenState extends State<ShowServiceScreen> {
  Map<String, dynamic>? _service;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  Future<void> _loadService() async {
    setState(() => _isLoading = true);
    try {
      final service = await FeaturedServices.getServiceById(widget.serviceId);
      if (mounted) {
        setState(() {
          _service = service;
          _isLoading = false;
          _error = service == null ? 'Service not found' : '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load service details';
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: Colors.white,
        foregroundColor: BeeColors.beeBlack,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _service == null
                  ? const Center(child: Text('Service not found'))
                  : _buildServiceDetails(),
    );
  }

  Widget _buildServiceDetails() {
    final service = _service!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: service['image_url'] != null
                ? Image.network(
                    service['image_url'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(height: 20),
          
          // Service Info
          Text(service['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(service['category'] ?? 'No Category',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          
          const Divider(height: 30),
          
          // Details
          _buildInfoRow('Price', service['price_range'] ?? 'Not specified'),
          _buildInfoRow('Experience', 
              service['experience_years'] != null ? '${service['experience_years']} years' : 'Not specified'),
          _buildInfoRow('Availability', service['availability'] ?? 'Not specified'),
          
          const Divider(height: 30),
          
          // Description
          const Text('Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(service['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5)),
          
          const SizedBox(height: 30),
          
          // Provider Info
          const Text('Service Provider',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: BeeColors.beeYellow,
                      child: Icon(Icons.person, color: BeeColors.beeBlack),
                    ),
                    title: Text(service['provider_name'] ?? 'Unknown Provider',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(service['provider_email'] ?? ''),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: service['provider_phone'] != null
                          ? () => _makePhoneCall(service['provider_phone'])
                          : null,
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BeeColors.beeYellow,
                        foregroundColor: BeeColors.beeBlack,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }
}
