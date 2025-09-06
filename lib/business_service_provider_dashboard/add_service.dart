import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../main.dart' show BeeColors;

// add services page where users can add servies details

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

  final List<String> _categoryOptions = [
    'electrician',
    'groceries',
    'food',
    'plumber',
    'mechanic',
    'cleaning',
    'others',
  ];
  String? _selectedCategory;

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
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
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
        'profile_id': _profileId!,
        'service_name': _serviceNameController.text,
        'description': _serviceDescController.text,
        'experience_years': int.tryParse(_experienceYearsController.text) ?? 0,
        'price_range': _priceRangeController.text,
        'image_url': imageUrl,
        'category': _selectedCategory,
        'availability': _selectedAvailability,
      };

      try {
        await Supabase.instance.client
            .from('service_providers')
            .insert(newService);
            
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service added successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add service. Please try again.')),
          );
        }
        debugPrint('Error adding service: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: BeeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BeeColors.beeBlack,
        elevation: 0,
        centerTitle: true,
        title: const Text('Add Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: BeeColors.beeGrey.withOpacity(0.4), width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (_pickedImage != null)
                            BoxShadow(
                              color: BeeColors.beeYellow.withOpacity(0.18),
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
                                color: BeeColors.beeYellow.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.camera_alt, size: 46, color: BeeColors.beeYellow),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _serviceNameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g., Plumbing, Electrician, Cleaning',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: BeeColors.beeGrey.withAlpha(180)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a service name' : null,
              ),
              const SizedBox(height: 18),
              const SizedBox(height: 8),
              Text(
                'Service Description',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serviceDescController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
                  ),
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
                        labelText: 'Experience',
                        hintText: 'e.g., 5',
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(color: BeeColors.beeGrey.withAlpha(180)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
                        ),
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
                        hintText: 'e.g., 500-1000 INR',
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(color: BeeColors.beeGrey.withAlpha(180)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Enter a price range' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                hint: const Text('Select category'),
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: BeeColors.beeGrey.withAlpha(180)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
                  ),
                ),
                items: _categoryOptions.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category[0].toUpperCase() + category.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (val) => val == null || val.isEmpty ? 'Please select a category' : null,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _selectedAvailability,
                isExpanded: true,
                hint: const Text('Select availability'),
                decoration: InputDecoration(
                  labelText: 'Availability',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: BeeColors.beeGrey.withAlpha(180)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: BeeColors.beeGrey.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
                  ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeeColors.beeYellow,
                  foregroundColor: BeeColors.beeBlack,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                onPressed: _isLoading ? null : _submitService,
                child: _isLoading
                    ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 3, color: BeeColors.beeBlack))
                    : const Text('Add Service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}