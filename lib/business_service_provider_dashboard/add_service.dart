import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
            border: Border.all(
              color: _pickedImage != null 
                  ? BeeColors.beeYellow.withOpacity(0.5) 
                  : Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              _pickedImage != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: Image.file(
                        _pickedImage!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: BeeColors.beeYellow.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.gallery_add,
                              size: 32,
                              color: BeeColors.beeYellow,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to add service image',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recommended size: 800x600px',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _pickedImage != null ? Colors.grey[50] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Text(
                    _pickedImage != null ? 'Change Image' : 'Upload Image',
                    style: GoogleFonts.poppins(
                      color: _pickedImage != null ? Colors.blue : BeeColors.beeYellow,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines! > 1 ? 12 : 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: BeeColors.beeYellow, width: 2),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  hint,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
              ...items.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  )),
            ],
            validator: (value) => value == null ? 'Please select $label' : null,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Add New Service',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Service Image
              _buildImagePicker(),
              
              const SizedBox(height: 24),
              
              // Service Name
              _buildFormField(
                label: 'Service Name',
                hint: 'e.g., Plumbing, Electrician, Cleaning',
                controller: _serviceNameController,
                validator: (val) => val == null || val.trim().isEmpty 
                    ? 'Please enter a service name' 
                    : null,
              ),
              
              const SizedBox(height: 20),
              
              // Category Dropdown
              _buildDropdownField(
                label: 'Category',
                hint: 'Select a category',
                items: _categoryOptions,
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Service Description
              _buildFormField(
                label: 'Service Description',
                hint: 'Describe your service in detail',
                controller: _serviceDescController,
                maxLines: 4,
                validator: (val) => val == null || val.trim().isEmpty 
                    ? 'Please enter a description' 
                    : null,
              ),
              
              const SizedBox(height: 20),
              
              // Price and Experience Row
              Row(
                children: [
                  // Price Range
                  Expanded(
                    child: _buildFormField(
                      label: 'Price Range',
                      hint: 'e.g., ₹500 - ₹1000',
                      controller: _priceRangeController,
                      validator: (val) => val == null || val.trim().isEmpty 
                          ? 'Enter price range' 
                          : null,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Experience Years
                  Expanded(
                    child: _buildFormField(
                      label: 'Experience (Years)',
                      hint: 'e.g., 5',
                      controller: _experienceYearsController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.trim().isEmpty 
                          ? 'Enter years' 
                          : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Availability Dropdown
              _buildDropdownField(
                label: 'Availability',
                hint: 'Select availability',
                items: _availabilityOptions,
                value: _selectedAvailability,
                onChanged: (value) {
                  setState(() {
                    _selectedAvailability = value;
                  });
                },
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
              const SizedBox(height: 32),
              
              // Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: BeeColors.beeYellow.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BeeColors.beeYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Publish Service',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}