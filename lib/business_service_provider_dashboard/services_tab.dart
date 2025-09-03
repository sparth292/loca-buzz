import 'package:flutter/material.dart';
import '../main.dart' show BeeColors;

class ServicesTab extends StatefulWidget {
  final List<Map<String, String>> services;
  const ServicesTab({Key? key, required this.services}) : super(key: key);

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeeColors.background,
      body: widget.services.isEmpty
          ? const Center(child: Text('No services added yet.', style: TextStyle(fontSize: 18)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = widget.services[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['name'] ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(service['description'] ?? '', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${service['price'] ?? ''}',
                                style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                            Icon(Icons.design_services, color: BeeColors.beeYellow),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
