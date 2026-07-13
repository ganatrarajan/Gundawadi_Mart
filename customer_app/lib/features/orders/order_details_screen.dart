import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrderDetails(widget.orderId);
    });
  }

  // Define steps for custom status track
  final List<String> _stages = [
    'pending',
    'accepted',
    'packing',
    'ready_for_pickup',
    'out_for_delivery',
    'delivered'
  ];

  final Map<String, String> _stageLabels = {
    'pending': 'Order Placed',
    'accepted': 'Accepted by Shop',
    'packing': 'Packing Vegetables',
    'ready_for_pickup': 'Ready for Delivery',
    'out_for_delivery': 'Out for Delivery',
    'delivered': 'Delivered Successfully'
  };

  int _getStageIndex(String currentStatus) {
    if (currentStatus == 'cancelled') return -1;
    return _stages.indexOf(currentStatus.toLowerCase());
  }

  Widget _buildTimeline(String currentStatus) {
    if (currentStatus.toLowerCase() == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'This order has been cancelled.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final activeIndex = _getStageIndex(currentStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status Tracker',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stages.length,
              itemBuilder: (context, index) {
                final stage = _stages[index];
                final label = _stageLabels[stage]!;
                final isCompleted = index <= activeIndex;
                final isCurrent = index == activeIndex;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                          ),
                          child: isCompleted
                              ? Icon(
                                  isCurrent ? Icons.radio_button_checked : Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        if (index < _stages.length - 1)
                          Container(
                            width: 2,
                            height: 32,
                            color: index < activeIndex ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCompleted ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.selectedOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text(order != null ? 'Order #${order['id']}' : 'Order Details'),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.errorMessage != null
              ? Center(child: Text(orderProvider.errorMessage!))
              : order == null
                  ? const Center(child: Text('Order not found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Custom timeline tracking
                          _buildTimeline(order['status'] ?? 'pending'),
                          const SizedBox(height: 16),
                          // Bill breakdown
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bill Details',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                  const Divider(),
                                  // Items list
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (order['items'] as List?)?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final item = order['items'][index];
                                      final double price = double.parse(item['price'].toString());
                                      final int qty = item['quantity'];
                                      final double itemTotal = double.parse(item['total_price'].toString());
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.between,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['product_name']} (${item['unit']} x $qty)',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Text(
                                              '₹${itemTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      const Text('Subtotal'),
                                      Text('₹${double.parse(order['subtotal'].toString()).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      const Text('Delivery Charge'),
                                      Text(
                                        double.parse(order['delivery_charge'].toString()) > 0
                                            ? '₹${double.parse(order['delivery_charge'].toString()).toStringAsFixed(2)}'
                                            : 'Review Pending by Admin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: double.parse(order['delivery_charge'].toString()) > 0 ? Colors.black87 : Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('₹${double.parse(order['total'].toString()).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Delivery details
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Destination',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                  const Divider(),
                                  Text(
                                    order['delivery_address'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                  if (order['special_note'] != null && order['special_note'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text('Special Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('"${order['special_note']}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Shop contact
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.store, color: Color(0xFF2E7D32), size: 40),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(order['vendor_shop_name'] ?? 'Vendor Shop', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text('Owner: ${order['vendor_owner_name'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  if (order['vendor_mobile'] != null)
                                    IconButton(
                                      icon: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
                                      onPressed: () {
                                        // Simple alert or open phone logic
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
