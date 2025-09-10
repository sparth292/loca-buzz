import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../main.dart' show BeeColors;

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _completedOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  void _loadOrders() {
    // This would typically come from an API
    final now = DateTime.now();
    
    _activeOrders = [
      {
        'id': '#ORD-1001',
        'customer': 'Rahul Sharma',
        'phone': '+91 98765 43210',
        'items': [
          {'name': 'Mobile Repair', 'qty': 2, 'price': 499},
          {'name': 'Screen Guard', 'qty': 1, 'price': 299},
        ],
        'total': 1299,
        'status': 'In Progress',
        'time': now.subtract(const Duration(minutes: 10)),
        'address': '123, ABC Apartment, MG Road, Bangalore - 560001',
      },
      {
        'id': '#ORD-1002',
        'customer': 'Priya Patel',
        'phone': '+91 98765 12345',
        'items': [
          {'name': 'Haircut & Styling', 'qty': 1, 'price': 299},
        ],
        'total': 299,
        'status': 'Pending',
        'time': now.subtract(const Duration(minutes: 25)),
        'address': '456, XYZ Colony, Koramangala, Bangalore - 560034',
      },
    ];

    _completedOrders = [
      {
        'id': '#ORD-0998',
        'customer': 'Amit Kumar',
        'phone': '+91 98765 67890',
        'items': [
          {'name': 'Laptop Service', 'qty': 1, 'price': 1499},
        ],
        'total': 1499,
        'status': 'Completed',
        'time': now.subtract(const Duration(hours: 2)),
        'address': '789, PQR Layout, Indiranagar, Bangalore - 560038',
      },
    ];
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'min' : 'mins'} ago';
    } else {
      return 'Just now';
    }
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with title and filter button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orders',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.filter, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[700],
            indicator: BoxDecoration(
              color: BeeColors.beeYellow,
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Active (${_activeOrders.length})'),
              Tab(text: 'Completed (${_completedOrders.length})'),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Order List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(_activeOrders),
              _buildOrderList(_completedOrders),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.box_remove,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you get new orders, they\'ll appear here',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isCompleted = order['status'] == 'Completed';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['id'],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      _buildStatusChip(order['status']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['customer'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['time'] is DateTime 
                        ? _formatTimeAgo(order['time'])
                        : 'Just now',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              children: [
                Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Items
                      Text(
                        'Order Items',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...order['items'].map<Widget>((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: BeeColors.beeYellow,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${item['qty']} x ${item['name']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              '₹${item['price'] * item['qty']}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      
                      const SizedBox(height: 16),
                      
                      // Order Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '₹${order['total']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: BeeColors.beeYellow,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Customer Info
                      _buildInfoRow(
                        Iconsax.user,
                        'Customer',
                        '${order['customer']} • ${order['phone']}',
                      ),
                      
                      const SizedBox(height: 8),
                      
                      _buildInfoRow(
                        Iconsax.location,
                        'Delivery Address',
                        order['address'],
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Order Actions
                      if (!isCompleted) ..._buildOrderActions(order),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        icon = Iconsax.clock;
        break;
      case 'in progress':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[700]!;
        icon = Iconsax.clock;
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        icon = Iconsax.tick_circle;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrderActions(Map<String, dynamic> order) {
    final actions = <Widget>[];
    
    if (order['status'] == 'Pending') {
      actions.addAll([
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateOrderStatus(order['id'], 'Rejected'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[300]!), 
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.close_circle, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Reject',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order['id'], 'In Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeeColors.beeYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.tick_circle, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Accept',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]);
    } else if (order['status'] == 'In Progress') {
      actions.addAll([
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(order['id'], 'Completed'),
                icon: const Icon(Iconsax.tick_circle, size: 20),
                label: Text(
                  'Mark as Completed',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]);
    }

    return actions;
  }

  void _updateOrderStatus(String orderId, String status) {
    // Show loading state
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          // Update local state
          for (var order in _activeOrders) {
            if (order['id'] == orderId) {
              order['status'] = status;
              if (status == 'Completed' || status == 'Rejected') {
                _completedOrders.insert(0, Map<String, dynamic>.from(order));
                _activeOrders.removeWhere((o) => o['id'] == orderId);
              }
              break;
            }
          }
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order $orderId marked as $status',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: status == 'Rejected' ? Colors.red : Colors.green,
          ),
        );
      }
    });
  }
}
