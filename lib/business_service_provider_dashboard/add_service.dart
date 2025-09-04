import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _availabilityOptions = [
    'Weekdays',
    'Weekends',
    '24/7',
    'Custom',
  ];
  String? _selectedAvailability;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}_${_profileId ?? 'unknown'}.jpg';
      final storageResponse = await Supabase.instance.client.storage
          .from('service-images')
          .upload(fileName, image);
      if (storageResponse.isNotEmpty) {
        final publicUrl = Supabase.instance.client.storage
            .from('service-images')
            .getPublicUrl(fileName);
        return publicUrl;
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
    }
    return null;
  }

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
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }
      setState(() => _isLoading = true);

      // Upload image to Supabase Storage
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
        if (imageUrl == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed')),
          );
          return;
        }
      }

      final newService = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'profile_id': _profileId!,
        'service_name': _serviceNameController.text,
        'description': _serviceDescController.text,
        'experience_years': _experienceYearsController.text,
        'price_range': _priceRangeController.text,
        'image_url': imageUrl,
        'availability': _selectedAvailability,
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
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD600), Color(0xFFFFF8E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              const Icon(Icons.add_box, color: Colors.black87),
              const SizedBox(width: 10),
              Text('Add Service', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          centerTitle: false,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF8E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Center(
            child: Card(
              elevation: 8,
              shadowColor: Colors.amberAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.amber, width: 2),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (_pickedImage != null)
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.18),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: _pickedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _pickedImage!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.camera_alt, size: 46, color: Colors.amber),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Service Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber[900])),
                      const SizedBox(height: 18),
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
                      const SizedBox(height: 18),
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceRangeController,
                              decoration: InputDecoration(
                                labelText: 'Price Range',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.attach_money),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Enter a price range' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: _selectedAvailability,
                        decoration: InputDecoration(
                          labelText: 'Availability',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.access_time),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _availabilityOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAvailability = value;
                          });
                        },
                        validator: (val) => val == null || val.isEmpty ? 'Select availability' : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          elevation: 6,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                            : const Text('Add Service'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}