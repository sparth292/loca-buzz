import 'package:supabase_flutter/supabase_flutter.dart';

class FeaturedServices {
  static final supabase = Supabase.instance.client;

  // Fetch all featured services with provider details
  static Future<List<Map<String, dynamic>>> getFeaturedServices() async {
    try {
      final response = await supabase
          .from('service_providers')
          .select('''
            *,
            profiles:profile_id (id, full_name, phone, email)
          ''')
          // You might want to add some filters here later
          // .limit(10) // Limit the number of results if needed
          .then((response) => response as List<dynamic>);

      // Transform the response to match our expected format
      return response.map<Map<String, dynamic>>((service) => {
        'id': service['id'],
        'name': service['service_name'],
        'category': service['category'],
        'description': service['description'],
        'price_range': service['price_range'],
        'image_url': service['image_url'],
        'provider_id': service['profile_id'],
        'provider_name': service['profiles']?['full_name'],
        'provider_phone': service['profiles']?['phone'],
        'provider_email': service['profiles']?['email'],
      }).toList();
    } catch (e) {
      print('Error in getFeaturedServices: $e');
      return [];
    }
  }

  // Fetch a single service by ID with provider details
  static Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
    try {
      final response = await supabase
          .from('service_providers')
          .select('''
            *,
            profiles:profile_id (id, full_name, phone, email)
          ''')
          .eq('id', serviceId)
          .single();

      if (response.isEmpty) return null;

      return {
        'id': response['id'],
        'name': response['service_name'],
        'category': response['category'],
        'description': response['description'],
        'price_range': response['price_range'],
        'experience_years': response['experience_years'],
        'availability': response['availability'],
        'image_url': response['image_url'],
        'provider_id': response['profile_id'],
        'provider_name': response['profiles']?['full_name'],
        'provider_phone': response['profiles']?['phone'],
        'provider_email': response['profiles']?['email'],
        'created_at': response['created_at'],
      };
    } catch (e) {
      print('Error in getServiceById: $e');
      return null;
    }
  }
}
