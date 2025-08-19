import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
// Removed BeeColors import as we're now using AppColors exclusively

class ManualLocationEntryScreen extends StatefulWidget {
  static const String route = '/manual-location';
  
  const ManualLocationEntryScreen({Key? key}) : super(key: key);

  @override
  _ManualLocationEntryScreenState createState() => _ManualLocationEntryScreenState();
}

class _ManualLocationEntryScreenState extends State<ManualLocationEntryScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _recentSearches = [
    {'name': 'Home', 'address': '123 Main St, New York, NY'},
    {'name': 'Work', 'address': '456 Business Ave, New York, NY'},
  ];
  
  final List<Map<String, dynamic>> _suggestedLocations = [
    {'name': 'Current Location', 'icon': Icons.my_location},
    {'name': 'New York, NY', 'icon': Icons.location_city},
    {'name': 'Brooklyn, NY', 'icon': Icons.location_city},
    {'name': 'Manhattan, NY', 'icon': Icons.location_city},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enter Location',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary, size: 24.0),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 16.0,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search for area, street name...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 16.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (value) {
                          // TODO: Implement search as you type
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20.0, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          // Clear search results
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24.0),
              
              // Suggested Locations
              Text(
                'Suggested Locations',
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12.0),
              
              // Suggested Locations List
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestedLocations.length,
                  itemBuilder: (context, index) {
                    final location = _suggestedLocations[index];
                    return ListTile(
                      leading: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          location['icon'],
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                      ),
                      title: Text(
                        location['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        // TODO: Handle location selection
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    );
                  },
                ),
              ),
              
              // Recent Searches (if any)
              if (_recentSearches.isNotEmpty) ...[
                Text(
                  'Recent Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12.0),
                
                // Recent Searches List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    final search = _recentSearches[index];
                    return ListTile(
                      leading: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: AppColors.textSecondary,
                          size: 20.0,
                        ),
                      ),
                      title: Text(
                        search['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        search['address'],
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // TODO: Handle recent search selection
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    );
                  },
                ),
              ],
              
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
