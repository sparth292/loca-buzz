import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show BeeColors;

const String _locationKey = 'user_location_data';

class LocationSetupScreen extends StatefulWidget {
  static const String route = '/location-setup';
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  LocationData? _currentLocation;
  final Location _location = Location();
  String _statusMessage = 'Getting your location...';
  final TextEditingController _addressController = TextEditingController();
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _requestLocation();
  }

  // Load saved location data if it exists
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_locationKey);
      
      if (savedData != null) {
        final locationData = json.decode(savedData);
        setState(() {
          _addressController.text = locationData['address'] ?? '';
          _currentLocation = LocationData.fromMap({
            'latitude': locationData['latitude'],
            'longitude': locationData['longitude'],
          });
        });
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  // Save location data to shared preferences
  Future<void> _saveLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'latitude': _currentLocation?.latitude,
        'longitude': _currentLocation?.longitude,
        'address': _addressController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_locationKey, json.encode(locationData));
    } catch (e) {
      debugPrint('Error saving location data: $e');
      rethrow;
    }
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusMessage = 'Requesting location access...';
    });

    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled');
        }
      }

      // Check location permission
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('Location permissions are denied');
        }
      }

      // Get current location
      _currentLocation = await _location.getLocation();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location found!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _statusMessage = 'Failed to get location: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _onConfirmLocation() async {
    if (_currentLocation?.latitude == null || _currentLocation?.longitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your location. Please try again.')),
        );
      }
      return;
    }
    
    // Validate address
    if (_addressController.text.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _addressError = 'Please enter your address';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your address')),
        );
      }
      return;
    }
    
    try {
      // Save the location data locally
      await _saveLocationData();
      
      // Return the location data with address
      if (mounted) {
        Navigator.of(context).pop({
          'latitude': _currentLocation!.latitude!,
          'longitude': _currentLocation!.longitude!,
          'address': _addressController.text.trim(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save location. Please try again.')),
        );
      }
    }
  }

  Future<void> _showManualAddressDialog() async {
    final TextEditingController controller = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your full address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your address')),
                  );
                  return;
                }
                setState(() {
                  _addressController.text = controller.text.trim();
                  _addressError = null;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BeeColors.beeYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Loca',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: BeeColors.beeYellow,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Buzz',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: BeeColors.beeBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Share Your Location',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: BeeColors.beeBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We need your location to show you nearby services and businesses.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Status Card
                      Center(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isLoading
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(BeeColors.beeYellow),
                                      )
                                    : Icon(
                                        _hasError ? Icons.error_outline : Icons.check_circle,
                                        color: _hasError ? Colors.red : Colors.green,
                                        size: 48,
                                      ),
                                const SizedBox(height: 20),
                                Text(
                                  _statusMessage,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: _hasError ? Colors.red : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_currentLocation?.latitude != null && _currentLocation?.longitude != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    '${_currentLocation!.latitude!.toStringAsFixed(6)}, ${_currentLocation!.longitude!.toStringAsFixed(6)}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Address display and edit button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Address:',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: _showManualAddressDialog,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: _addressError != null ? Colors.red : Colors.grey[300]!,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _addressController.text.isEmpty 
                                                ? 'Tap to enter your address' 
                                                : _addressController.text,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: _addressController.text.isEmpty 
                                                  ? Colors.grey[500] 
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_addressError != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _addressError!,
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: _showManualAddressDialog,
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: Text(
                                            _addressController.text.isEmpty 
                                                ? 'Enter Address' 
                                                : 'Edit Address',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: BeeColors.beeYellow,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_hasError) ...[
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _requestLocation,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: BeeColors.beeYellow,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hasError || _isLoading ? null : _onConfirmLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BeeColors.beeYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Continue',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Skip button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Skip for now',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
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
  