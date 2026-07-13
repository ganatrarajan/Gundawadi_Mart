import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_provider.dart';
import '../orders/order_history_screen.dart';
import 'address_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  void _addAddressModal() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final houseCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final landmarkCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add New Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Recipient Full Name *'),
                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                ),
                TextFormField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact Mobile Number *'),
                  validator: (v) => v!.isEmpty ? 'Enter contact number' : null,
                ),
                TextFormField(
                  controller: houseCtrl,
                  decoration: const InputDecoration(labelText: 'House/Shop Number *'),
                  validator: (v) => v!.isEmpty ? 'Enter house number' : null,
                ),
                TextFormField(
                  controller: streetCtrl,
                  decoration: const InputDecoration(labelText: 'Street/Lane *'),
                  validator: (v) => v!.isEmpty ? 'Enter street' : null,
                ),
                TextFormField(
                  controller: areaCtrl,
                  decoration: const InputDecoration(labelText: 'Area/Colony (Gundawadi, etc.) *'),
                  validator: (v) => v!.isEmpty ? 'Enter area' : null,
                ),
                TextFormField(
                  controller: landmarkCtrl,
                  decoration: const InputDecoration(labelText: 'Landmark (Optional)'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final success = await Provider.of<AddressProvider>(context, listen: false).saveAddress(
                        fullName: nameCtrl.text.trim(),
                        mobile: mobileCtrl.text.trim(),
                        houseNumber: houseCtrl.text.trim(),
                        street: streetCtrl.text.trim(),
                        area: areaCtrl.text.trim(),
                        landmark: landmarkCtrl.text.trim(),
                      );
                      if (ctx.mounted) {
                        if (success) {
                          Navigator.pop(ctx);
                        } else {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Failed to save address.')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Save Address'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitOrder(CartProvider cartProvider, AddressProvider addressProvider) async {
    final address = addressProvider.selectedAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add a delivery address.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final itemsList = cartProvider.items
          .map((item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
              })
          .toList();

      final response = await addressProvider.apiClient.dio.post('/customer/orders', data: {
        'vendor_id': cartProvider.currentVendorId,
        'address_id': address['id'],
        'items': itemsList,
        'special_note': cartProvider.specialNote,
      });

      if (mounted) {
        if (response.data['success'] == true) {
          cartProvider.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully! Cash on Delivery.'), backgroundColor: Colors.green),
          );
          // Redirect to orders history
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            (route) => route.isFirst,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Failed to place order.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error placing order. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: addressProvider.isLoading && addressProvider.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Address list section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          const Text(
                            'Delivery Address',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _addAddressModal,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add New'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      addressProvider.addresses.isEmpty
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Text('No addresses found.', style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _addAddressModal,
                                      style: ElevatedButton.styleFrom(minimumSize: const Size(150, 40)),
                                      child: const Text('Add Address'),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Card(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: addressProvider.addresses.length,
                                itemBuilder: (context, index) {
                                  final addr = addressProvider.addresses[index];
                                  final isSelected = addressProvider.selectedAddress?['id'] == addr['id'];
                                  return RadioListTile<int>(
                                    value: addr['id'],
                                    groupValue: addressProvider.selectedAddress?['id'],
                                    onChanged: (_) {
                                      addressProvider.selectAddress(addr);
                                    },
                                    activeColor: const Color(0xFF2E7D32),
                                    title: Text(
                                      addr['full_name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${addr['house_number']}, ${addr['street']}, ${addr['area']}\nMobile: ${addr['mobile']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 24),
                      // Payment method section
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: RadioListTile<String>(
                          value: 'cod',
                          groupValue: 'cod',
                          onChanged: (_) {},
                          activeColor: const Color(0xFF2E7D32),
                          title: const Text('Cash On Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Pay when you receive the vegetables at your door.'),
                          secondary: const Icon(Icons.payments, color: Color(0xFF2E7D32)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bill details
                      const Text(
                        'Billing Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal'),
                                  Text('₹${cartProvider.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Delivery Charge'),
                                  Text('Manual assignment by Admin', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text('₹${cartProvider.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Submit Button footer
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitOrder(cartProvider, addressProvider),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Place Order (Cash on Delivery)'),
                  ),
                ),
              ],
            ),
    );
  }
}
