import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_provider.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade800;
      case 'accepted':
        return Colors.blue.shade700;
      case 'packing':
        return Colors.purple.shade700;
      case 'ready_for_pickup':
        return Colors.orange.shade800;
      case 'out_for_delivery':
        return Colors.teal.shade700;
      case 'delivered':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: orderProvider.fetchOrders,
        child: orderProvider.isLoading && orderProvider.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : orderProvider.errorMessage != null
                ? Center(child: Text(orderProvider.errorMessage!))
                : orderProvider.orders.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('You have not placed any orders yet.', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: orderProvider.orders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.orders[index];
                          final int orderId = order['id'];
                          final String date = order['created_at'] ?? '';
                          final String shopName = order['vendor_shop_name'] ?? 'Vendor Shop';
                          final double total = double.parse(order['total'].toString());
                          final String status = order['status'] ?? 'pending';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      Text(
                                        'Order #$orderId',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status.replaceAll('_', ' ').toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Shop: $shopName',
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: $date',
                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      Text(
                                        'Total Amount: ₹${total.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E7D32)),
                                      ),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OrderDetailsScreen(orderId: orderId),
                                                ),
                                              );
                                            },
                                            child: const Text('Details'),
                                          ),
                                          const SizedBox(width: 8),
                                          // Allow reorder for completed or cancelled orders
                                          if (status == 'delivered' || status == 'cancelled')
                                            ElevatedButton(
                                              onPressed: () async {
                                                final success = await orderProvider.reorder(orderId);
                                                if (context.mounted) {
                                                  if (success) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Reordered successfully! Waiting for shop response.'),
                                                        backgroundColor: Colors.green,
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(orderProvider.errorMessage ?? 'Reorder failed.'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(90, 36),
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              child: const Text('Reorder', style: TextStyle(fontSize: 13)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
