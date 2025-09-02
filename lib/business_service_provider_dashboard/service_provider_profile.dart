import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' show BeeColors, supabase;

class ServiceProviderProfile extends StatefulWidget {
  static const String route = '/service-provider-profile';
  
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  
  // Form controllers
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }
  
  // Fetch profile data from Supabase
  Future<void> _fetchProfileData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      final response = await supabase
          .from('service_providers')
          .select()
          .eq('user_id', user.id)
          .single();
      
      if (mounted) {
        setState(() {
          _businessNameController.text = response['business_name'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = response['phone'] ?? '';
          _addressController.text = response['address'] ?? '';
          _categoryController.text = response['business_category'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Save profile data to Supabase
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      await supabase.from('service_providers').upsert({
        'user_id': user.id,
        'business_name': _businessNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'business_category': _categoryController.text,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      }
    }
  }
  
  // Sign out the user
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        Icon(icon, color: BeeColors.beeYellow, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: isEditing
              ? TextFormField(
                  controller: controller,
                  decoration: InputDecoration(labelText: label),
                  keyboardType: keyboardType,
                  validator: validator,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.grey)),
                    Text(controller.text.isEmpty ? 'Not set' : controller.text),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _isEditing
              ? TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                )
              : TextButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BeeColors.beeYellow,
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.business, size: 60, color: Colors.white),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!_isEditing) ...[
                      Text(
                        _businessNameController.text,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _emailController.text,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                    ],
                    // Profile Details Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildEditableField(
                              icon: Icons.business,
                              label: 'Business Name',
                              controller: _businessNameController,
                              isEditing: _isEditing,
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const Divider(height: 24),
                            _buildEditableField(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              controller: _emailController,
                              isEditing: false, // Email is read-only
                            ),
                            const Divider(height: 24),
                            _buildEditableField(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              controller: _phoneController,
                              isEditing: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                            const Divider(height: 24),
                            _buildEditableField(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              controller: _addressController,
                              isEditing: _isEditing,
                            ),
                            const Divider(height: 24),
                            _buildEditableField(
                              icon: Icons.category_outlined,
                              label: 'Business Category',
                              controller: _categoryController,
                              isEditing: _isEditing,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BeeColors.beeYellow,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.black)),
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('LOG OUT', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ),

          
        );
      
    
  }
  

}
