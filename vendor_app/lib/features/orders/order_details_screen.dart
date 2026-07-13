import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'orders_provider.dart';

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
      Provider.of<OrdersProvider>(context, listen: false).fetchOrderDetails(widget.orderId);
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
    final order = ordersProvider.selectedOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text(order != null ? 'ઓર્ડર #${order['id']}' : 'ઓર્ડર વિગતો'),
      ),
      body: ordersProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Order not found.'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Customer Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ગ્રાહકની માહિતી (Customer)', style: TextStyle(color: Colors.grey, fontSize: 15)),
                                    const Divider(),
                                    Text(
                                      order['customer_name'] ?? 'New Customer',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'મોબાઇલ: ${order['customer_mobile']}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('સરનામું (Address):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(
                                      order['delivery_address'] ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (order['special_note'] != null && order['special_note'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Text('ગ્રાહક ની સૂચના (Note):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                                      Text(
                                        '"${order['special_note']}"',
                                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.orange),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Order Items
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('શાકભાજી ની વિગત (Items)', style: TextStyle(color: Colors.grey, fontSize: 15)),
                                    const Divider(),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: (order['items'] as List?)?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final item = order['items'][index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.between,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['product_name'],
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Text(
                                                '${item['quantity']} x ${item['unit']}',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                      child: _buildActionFooter(order),
                    ),
                  ],
                ),
    );
  }

  Widget _buildActionFooter(Map<String, dynamic> order) {
    final String status = order['status'] ?? 'pending';
    final int orderId = order['id'];

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(orderId, 'accepted', 'ઓર્ડર સ્વીકાર્યો છે (Accepted)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text('મંજૂર (ACCEPT)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(orderId, 'rejected', 'ઓર્ડર ના મંજૂર કર્યો છે (Rejected)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text('ના મંજૂર (REJECT)'),
            ),
          ),
        ],
      );
    } else if (status == 'accepted') {
      return ElevatedButton(
        onPressed: () => _updateStatus(orderId, 'packing', 'પેકિંગ ચાલુ કર્યું છે (Packing started)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade800,
          minimumSize: const Size(double.infinity, 60),
        ),
        child: const Text('પેકિંગ શરૂ કરો (START PACKING)'),
      );
    } else if (status == 'packing') {
      return ElevatedButton(
        onPressed: () => _updateStatus(orderId, 'ready_for_pickup', 'ઓર્ડર ડિલિવરી માટે તૈયાર છે (Order ready)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade800,
          minimumSize: const Size(double.infinity, 60),
        ),
        child: const Text('પેકિંગ પૂરું થયું (READY FOR PICKUP)'),
      );
    } else if (status == 'ready_for_pickup') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'ડિલિવરી બોય ની રાહ જુઓ...\n(Waiting for Delivery Agent)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
