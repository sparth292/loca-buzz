import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import '../main.dart' show BeeColors;

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

  @override
  void initState() {
    super.initState();
    _requestLocation();
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

  void _onConfirmLocation() {
    if (_currentLocation?.latitude == null || _currentLocation?.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location. Please try again.')),
      );
      return;
    }
    
    // Return the location data in 'lat,long' format
    if (mounted) {
      Navigator.of(context).pop({
        'latitude': _currentLocation!.latitude!,
        'longitude': _currentLocation!.longitude!,
      });
    }
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
  