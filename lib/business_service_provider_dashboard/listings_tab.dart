// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../main.dart' show BeeColors, supabase;

// class ServicesTab extends StatefulWidget {
//   const ServicesTab({super.key});

//   @override
//   State<ServicesTab> createState() => _ServicesTabState();
// }

// class _ServicesTabState extends State<ServicesTab> {
//   final _formKey = GlobalKey<FormState>();
//   final List<Map<String, dynamic>> _services = [
//     {
//       'id': '1',
//       'name': 'Mobile Repair Service',
//       'price': '499',
//       'duration': '30', // in minutes
//       'category': 'Electronics',
//       'description': 'Professional mobile repair service for all major brands',
//       'is_available': true,
//     },
//     {
//       'id': '2',
//       'name': 'Haircut & Styling',
//       'price': '299',
//       'duration': '60', // in minutes
//       'category': 'Beauty',
//       'description': 'Haircut and styling for men and women',
//       'is_available': true,
//     },
//   ];

//   // Get appropriate icon based on service category
//   IconData _getServiceIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'electronics':
//         return Icons.phone_android;
//       case 'beauty':
//         return Icons.face_retouching_natural;
//       case 'home':
//         return Icons.home_repair_service;
//       case 'health':
//         return Icons.medical_services;
//       default:
//         return Icons.miscellaneous_services;
//     }
//   }

//   // Toggle service availability
//   void _toggleServiceAvailability(String serviceId) {
//     setState(() {
//       final index = _services.indexWhere((s) => s['id'] == serviceId);
//       if (index != -1) {
//         _services[index]['is_available'] = !_services[index]['is_available'];
//         // TODO: Update in Supabase
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('Building ServicesTab with ${_services.length} services'); // Debug print
    
//     return ListView(
//       children: [
//         // Debug header
//         // Container(
//         //   color: Colors.blue.withOpacity(0.1),
//         //   padding: const EdgeInsets.all(8.0),
//         //   child: Text(
//         //     'DEBUG: ServicesTab is being built with ${_services.length} services',
//         //     style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//         //   ),
//         // ),
        
//         // Header with title and add button
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Your Services',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18, 
//                   fontWeight: FontWeight.w600,
//                   color: BeeColors.beeBlack,
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: _showAddServiceDialog,
//                 icon: const Icon(Icons.add_circle_outline),
//                 label: const Text('Add Service'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: BeeColors.beeYellow,
//                   foregroundColor: Colors.black,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         // Services list
//         ..._services.map((service) {
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(16),
//               leading: Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: BeeColors.beeYellow.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   _getServiceIcon(service['category']),
//                   color: BeeColors.beeYellow,
//                   size: 30,
//                 ),
//               ),
//               title: Text(
//                 service['name'],
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 4),
//                   Text(
//                     service['description'],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '${service['duration']} min',
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '₹${service['price']}',
//                         style: GoogleFonts.poppins(
//                           color: Colors.green,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.edit_outlined, size: 22),
//                     color: Colors.blue,
//                     onPressed: () => _showEditServiceDialog(service),
//                   ),
//                   const SizedBox(width: 4),
//                   IconButton(
//                     icon: Icon(
//                       service['is_available'] 
//                           ? Icons.toggle_on_rounded 
//                           : Icons.toggle_off_rounded,
//                       size: 32,
//                       color: service['is_available'] 
//                           ? Colors.green 
//                           : Colors.grey,
//                     ),
//                     onPressed: () => _toggleServiceAvailability(service['id']),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ],
//     );
    
//   }

//   void _showAddServiceDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => _buildServiceDialog(),
//     );
//   }

//   void _showEditServiceDialog(Map<String, dynamic> service) {
//     showDialog(
//       context: context,
//       builder: (context) => _buildServiceDialog(service: service),
//     );
//   }

//   Widget _buildServiceDialog({Map<String, dynamic>? service}) {
//     final isEditing = service != null;
//     final nameController = TextEditingController(text: service?['name'] ?? '');
//     final priceController = TextEditingController(text: service?['price'] ?? '');
//     final durationController = TextEditingController(text: service?['duration'] ?? '30');
//     final categoryController = TextEditingController(text: service?['category'] ?? '');
//     final descriptionController = TextEditingController(text: service?['description'] ?? '');

//     final categories = ['Electronics', 'Beauty', 'Home', 'Health', 'Other'];
//     String? selectedCategory = service?['category'] ?? categories[0];

//     return AlertDialog(
//       title: Text(
//         isEditing ? 'Edit Service' : 'Add New Service',
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Service Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter service name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter service description';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextFormField(
//                       controller: priceController,
//                       decoration: InputDecoration(
//                         labelText: 'Price',
//                         prefixText: '₹ ',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Enter price';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Enter valid price';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: durationController,
//                       decoration: InputDecoration(
//                         labelText: 'Duration (min)',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Enter duration';
//                         }
//                         if (int.tryParse(value) == null) {
//                           return 'Enter valid duration';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: selectedCategory,
//                 decoration: InputDecoration(
//                   labelText: 'Category',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                 ),
//                 items: categories.map((category) {
//                   return DropdownMenuItem(
//                     value: category,
//                     child: Text(category),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   selectedCategory = value;
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select a category';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text('Cancel'),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState?.validate() ?? false) {
//                         final newService = {
//                           'id': isEditing ? service!['id'] : '${_services.length + 1}',
//                           'name': nameController.text,
//                           'price': priceController.text,
//                           'duration': durationController.text,
//                           'category': selectedCategory,
//                           'description': descriptionController.text,
//                           'is_available': isEditing 
//                               ? service!['is_available'] 
//                               : true,
//                         };

//                         if (isEditing) {
//                           // Update existing service
//                           final index = _services.indexWhere(
//                             (s) => s['id'] == service!['id']
//                           );
//                           if (index != -1) {
//                             setState(() {
//                               _services[index] = newService;
//                             });
//                             // TODO: Update in Supabase
//                           }
//                         } else {
//                           // Add new service
//                           setState(() {
//                             _services.add(newService);
//                           });
//                           // TODO: Save to Supabase
//                         }
                        
//                         if (mounted) {
//                           Navigator.of(context).pop();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 isEditing 
//                                     ? 'Service updated successfully!'
//                                     : 'Service added successfully!',
//                               ),
//                               backgroundColor: Colors.green,
//                             ),
//                           );
//                         }
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: BeeColors.beeYellow,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                     ),
//                     child: Text(
//                       isEditing ? 'Update' : 'Add Service',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _deleteService(String id) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Service'),
//         content: const Text('Are you sure you want to delete this service? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         setState(() {
//           _services.removeWhere((service) => service['id'] == id);
//         });
//         // TODO: Delete from Supabase
        
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Service deleted successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to delete service: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }
// }
