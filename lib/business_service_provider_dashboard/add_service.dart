import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' show BeeColors;

class AddServicePage extends StatefulWidget {
  static const String route = '/add-service';
  const AddServicePage({Key? key}) : super(key: key);

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescController = TextEditingController();
  final TextEditingController _experienceYearsController = TextEditingController();
  final TextEditingController _priceRangeController = TextEditingController();
  bool _isLoading = false;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _fetchProfileId();
  }

  Future<void> _fetchProfileId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _profileId = response?['id'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescController.dispose();
    _experienceYearsController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  void _submitService() async {
    if (_formKey.currentState!.validate()) {
      if (_profileId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not loaded yet')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final newService = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'profile_id': _profileId!,
        'service_name': _serviceNameController.text,
        'description': _serviceDescController.text,
        'experience_years': _experienceYearsController.text,
        'price_range': _priceRangeController.text,
      };

      // later you’ll replace this with actual Supabase insert
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, newService);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BeeColors.beeYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.design_services, size: 60, color: Colors.amber),
                    const SizedBox(height: 12),
                    Text(
                      'Let customers know what you offer!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _serviceNameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a service name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _serviceDescController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _experienceYearsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Experience (years)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.workspace_premium),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter experience in years' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceRangeController,
                decoration: InputDecoration(
                  labelText: 'Price Range',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a price range' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeeColors.beeYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                      )
                    : const Text('Add Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
