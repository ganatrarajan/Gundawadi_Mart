import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state_widget.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final bool isTab;

  const CartScreen({super.key, this.isTab = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    _instructionsController.text = cart.specialInstructions;
    _instructionsController.addListener(() {
      cart.setSpecialInstructions(_instructionsController.text);
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final groupedItems = <String, List<CartItem>>{};
    for (var item in cart.items) {
      groupedItems.putIfAbsent(item.vendorName, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () {
                _showClearConfirmationDialog(context, cart);
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? EmptyStateWidget(
              icon: Icons.shopping_basket_outlined,
              title: 'Your Cart is Empty',
              subtitle: 'Add fresh vegetables from your local vendors to get started!',
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grouped Products list
                        ...groupedItems.entries.map((MapEntry<String, List<CartItem>> entry) {
                          final vendorName = entry.key;
                          final vendorItems = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vendor Header Banner
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: Dimensions.sm),
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.md, vertical: Dimensions.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                                    const SizedBox(width: Dimensions.sm),
                                    Expanded(
                                      child: Text(
                                        vendorName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // List of items for this vendor
                              ...vendorItems.map((CartItem item) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: Dimensions.sm),
                                  child: Padding(
                                    padding: const EdgeInsets.all(Dimensions.md),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                                          child: Image.network(
                                            item.product.imageUrl,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 50,
                                                width: 50,
                                                color: AppColors.primaryLight,
                                                child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 20),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                'Option: ${item.optionLabel}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.xs),
                                              Text(
                                                '₹${item.totalPrice.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Qty Modifier
                                        Row(
                                          children: [
                                            _QtyAction(
                                              icon: Icons.remove_rounded,
                                              onTap: () => cart.updateQuantity(
                                                item.product.id,
                                                item.optionLabel,
                                                -1,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
                                              child: Text(
                                                item.quantity.toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _QtyAction(
                                              icon: Icons.add_rounded,
                                              onTap: () => cart.updateQuantity(
                                                item.product.id,
                                                item.optionLabel,
                                                1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: Dimensions.md),
                            ],
                          );
                        }).toList(),

                        // Special Instructions
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        TextField(
                          controller: _instructionsController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Example: "Please send ripe tomatoes."',
                            fillColor: AppColors.surface,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),

                        // Bill Summary
                        const Text(
                          'Bill Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Column(
                              children: [
                                _SummaryRow(
                                  label: 'Subtotal',
                                  value: '₹${cart.subtotal.toStringAsFixed(0)}',
                                ),
                                const SizedBox(height: Dimensions.sm),
                                _SummaryRow(
                                  label: 'Delivery Charge',
                                  value: cart.deliveryCharge == 0
                                      ? 'FREE'
                                      : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
                                  valueColor: cart.deliveryCharge == 0
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                                const Divider(height: Dimensions.lg, color: AppColors.border),
                                _SummaryRow(
                                  label: 'To Pay',
                                  value: '₹${cart.total.toStringAsFixed(0)}',
                                  isBold: true,
                                  valueColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.sm),
                        // Highlight Note
                        Container(
                          padding: const EdgeInsets.all(Dimensions.md),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Note: This is not a fixed amount. The final amount may change according to the vendor. If it is reduced, it will reduce in your bill; if it is greater, it will be added. It depends on the vendor.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),
                      ],
                    ),
                  ),
                ),

                // Footer checkout trigger
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(Dimensions.md),
                  child: CustomButton(
                    text: 'Continue Checkout',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Clear Cart?'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cart.clearCart();
                Navigator.pop(ctx);
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}

class _QtyAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.xs),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
