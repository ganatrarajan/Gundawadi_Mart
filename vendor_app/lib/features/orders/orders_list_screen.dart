import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'orders_provider.dart';
import 'order_details_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    });
  }

  void _updateStatus(int orderId, String status, String messageText) async {
    final success = await Provider.of<OrdersProvider>(context, listen: false)
        .updateOrderStatus(orderId, status);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(messageText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ભૂલ આવી છે (Error updating status).'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);

    // Filter out delivered or cancelled orders to keep the screen focused on active orders
    final activeOrders = ordersProvider.orders.where((o) {
      final status = o['status']?.toString().toLowerCase() ?? '';
      return status != 'delivered' && status != 'cancelled';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ઓર્ડર ની યાદી'),
      ),
      body: RefreshIndicator(
        onRefresh: ordersProvider.fetchOrders,
        child: ordersProvider.isLoading && ordersProvider.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : activeOrders.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('નવા કોઈ ઓર્ડર નથી.\n(No active orders)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 18)),
                          ],
                        ),
                      )
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: activeOrders.length,
                    itemBuilder: (context, index) {
                      final order = activeOrders[index];
                      final int orderId = order['id'];
                      final String date = order['created_at'] ?? '';
                      final String customerName = order['customer_name'] ?? 'New Customer';
                      final String customerMobile = order['customer_mobile'] ?? '';
                      final double total = double.parse(order['total'].toString());
                      final String status = order['status'] ?? 'pending';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(orderId: orderId),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.between,
                                  children: [
                                    Text(
                                      'ઓર્ડર #$orderId',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1B5E20)),
                                    ),
                                    Text(
                                      date.split(' ').first,
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ગ્રાહક: $customerName',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Text(
                                  'મોબાઇલ: $customerMobile',
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'કુલ રકમ: ₹${total.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                                ),
                                const Divider(height: 24),
                                // Actions section
                                if (status == 'pending')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _updateStatus(orderId, 'accepted', 'ઓર્ડર સ્વીકાર્યો છે (Accepted)'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade800,
                                            minimumSize: const Size(double.infinity, 54),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('મંજૂર (ACCEPT)', style: TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _updateStatus(orderId, 'rejected', 'ઓર્ડર ના મંજૂર કર્યો છે (Rejected)'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade800,
                                            minimumSize: const Size(double.infinity, 54),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('ના મંજૂર (REJECT)', style: TextStyle(fontSize: 15)),
                                        ),
                                      ),
                                    ],
                                  )
                                else if (status == 'accepted')
                                  ElevatedButton(
                                    onPressed: () => _updateStatus(orderId, 'packing', 'પેકિંગ ચાલુ કર્યું છે (Packing started)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade800,
                                      minimumSize: const Size(double.infinity, 56),
                                    ),
                                    child: const Text('પેકિંગ શરૂ કરો (START PACKING)'),
                                  )
                                else if (status == 'packing')
                                  ElevatedButton(
                                    onPressed: () => _updateStatus(orderId, 'ready_for_pickup', 'ઓર્ડર ડિલિવરી માટે તૈયાર છે (Order ready)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade800,
                                      minimumSize: const Size(double.infinity, 56),
                                    ),
                                    child: const Text('પેકિંગ પૂરું થયું (READY FOR PICKUP)'),
                                  )
                                else if (status == 'ready_for_pickup')
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'ડિલિવરી ની રાહ જુઓ...\n(Waiting for Admin Pickup)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
