import 'package:flutter/material.dart';
import '../main.dart' show BeeColors;

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': '#ORD-1001',
      'customer': 'Rahul Sharma',
      'items': '2 x Mobile Repair, 1 x Screen Guard',
      'amount': '₹1,299',
      'status': 'In Progress',
      'time': '10 min ago',
    },
    {
      'id': '#ORD-1002',
      'customer': 'Priya Patel',
      'items': '1 x Haircut & Styling',
      'amount': '₹299',
      'status': 'Pending',
      'time': '25 min ago',
    },
  ];

  final List<Map<String, dynamic>> _completedOrders = [
    {
      'id': '#ORD-0998',
      'customer': 'Amit Kumar',
      'items': '1 x Laptop Service',
      'amount': '₹1,499',
      'status': 'Completed',
      'time': '2 hours ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: BeeColors.beeYellow,
            unselectedLabelColor: Colors.grey,
            indicatorColor: BeeColors.beeYellow,
            tabs: const [
              Tab(text: 'Active (2)'),
              Tab(text: 'Completed (12)'),
            ],
          ),
        ),
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
      return const Center(
        child: Text('No orders found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              order['id'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${order['customer']} • ${order['time']}'),
            trailing: _buildStatusChip(order['status']),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${order['customer']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Items: ${order['items']}'),
                    const SizedBox(height: 8),
                    Text('Amount: ${order['amount']}'),
                    const SizedBox(height: 16),
                    if (order['status'] != 'Completed') ..._buildOrderActions(order),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case 'in progress':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Reject', style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order['id'], 'In Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeeColors.beeYellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Accept'),
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
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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
    // TODO: Update order status in backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order $orderId marked as $status')),
    );
    
    setState(() {
      // Update local state for demo
      for (var order in _activeOrders) {
        if (order['id'] == orderId) {
          order['status'] = status;
          if (status == 'Completed') {
            _completedOrders.insert(0, Map<String, dynamic>.from(order));
            _activeOrders.removeWhere((o) => o['id'] == orderId);
          }
          break;
        }
      }
    });
  }
}
