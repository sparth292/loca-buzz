import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show BeeColors, BrandTitle;

class LocationSetupScreen extends StatefulWidget {
  static const String route = '/location-setup';
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  double _searchRadius = 5.0; // Default 5km radius
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  bool _locationEnabled = false;
  LocationData? _currentLocation;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _locationEnabled = false;
        });
        return;
      }
    }

    // Check location permission
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _locationEnabled = false;
        });
        return;
      }
    }

    setState(() {
      _locationEnabled = true;
    });

    // Get current location if permission granted
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentLocation = await _location.getLocation();
      
      if (_currentLocation != null) {
        setState(() {
          _locationController.text = "${_currentLocation!.latitude!.toStringAsFixed(4)}, ${_currentLocation!.longitude!.toStringAsFixed(4)}";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onConfirmLocation() {
    if (_locationController.text.isEmpty || _currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait while we get your location')),
      );
      return;
    }
    
    // Return the location data in 'lat,long' format
    if (mounted) {
      Navigator.of(context).pop({
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'address': _locationController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const BrandTitle(),
              const SizedBox(height: 24),
              const Text(
                'Set Your Location',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: BeeColors.beeBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Help us find the best local businesses around you',
                style: TextStyle(
                  color: BeeColors.beeGrey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Location Access Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: BeeColors.beeYellow.withOpacity(0.2), // moved opacity calculation to build method
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: BeeColors.beeYellow,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Location Access',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Switch(
                            value: _locationEnabled,
                            onChanged: (value) {
                              if (value) {
                                _checkLocationPermission();
                              } else {
                                setState(() {
                                  _locationEnabled = false;
                                  _locationController.clear();
                                });
                              }
                            },
                            activeColor: BeeColors.beeYellow,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter your location',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.my_location),
                                  onPressed: _locationEnabled ? _getCurrentLocation : null,
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        readOnly: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Search Radius Slider
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Radius',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_searchRadius.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BeeColors.beeYellow,
                        ),
                      ),
                      Slider(
                        value: _searchRadius,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: '${_searchRadius.toStringAsFixed(1)} km',
                        activeColor: BeeColors.beeYellow,
                        inactiveColor: BeeColors.beeYellow.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            _searchRadius = value;
                          });
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 km'),
                          Text('20 km'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Confirm Button
              ElevatedButton(
                onPressed: _onConfirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeeColors.beeYellow,
                  foregroundColor: BeeColors.beeBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip for now button
              TextButton(
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
