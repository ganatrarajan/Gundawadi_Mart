import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../order/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedDeliverySlot;

  bool _hasSlotPassedToday(String slot) {
    try {
      final parts = slot.split('-');
      if (parts.isEmpty) return false;
      
      final startTimeStr = parts[0].trim().toUpperCase();
      final match = RegExp(r'(\d+):(\d+)\s*(AM|PM)').firstMatch(startTimeStr);
      if (match == null) return false;
      
      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String amPm = match.group(3)!;
      
      if (amPm == 'PM' && hour != 12) {
        hour += 12;
      } else if (amPm == 'AM' && hour == 12) {
        hour = 0;
      }
      
      final now = DateTime.now();
      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      return now.isAfter(slotTime);
    } catch (e) {
      return false;
    }
  }

  List<String> _getAvailableSlots(List<String> slots, bool allowToday) {
    final List<String> available = [];
    
    if (allowToday) {
      for (final slot in slots) {
        if (!_hasSlotPassedToday(slot)) {
          available.add('Today: $slot');
        }
      }
      // Fallback to tomorrow if all today's slots have passed
      if (available.isEmpty) {
        for (final slot in slots) {
          available.add('Tomorrow: $slot');
        }
      }
    } else {
      for (final slot in slots) {
        available.add('Tomorrow: $slot');
      }
    }
    
    return available;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).refreshProfile();
    });
  }

  Future<void> _placeOrder(UserModel user, double deliveryCharge, double handlingCharge, double platformFee) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (user.status != 'approved' || user.address == null || user.deliveryKm == null || user.deliveryCharge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot place order: Your account is pending admin approval.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDeliverySlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery time slot.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await orderProvider.placeOrder(
      vendorId: cart.activeVendorId ?? 0,
      cartItems: cart.items,
      totalAmount: cart.subtotal + deliveryCharge + handlingCharge + platformFee,
      deliveryCharge: deliveryCharge,
      address: user.address!,
      specialInstructions: cart.specialInstructions,
      handlingCharge: handlingCharge,
      platformFee: platformFee,
      deliverySlot: _selectedDeliverySlot ?? '',
    );

    if (success && mounted) {
      cart.clearCart();
      final placedOrder = orderProvider.placedOrder;
      if (placedOrder != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: placedOrder.id,
              estimatedDelivery: '30 - 45 Minutes',
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Failed to place order.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user != null) {
      final availableSlots = _getAvailableSlots(user.deliveryTimeSlots, user.allowTodayDelivery);
      if (_selectedDeliverySlot != null && !availableSlots.contains(_selectedDeliverySlot)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedDeliverySlot = null;
            });
          }
        });
      }
    }

    final isApproved = user?.status == 'approved';
    final hasDistance = user?.deliveryKm != null && user?.deliveryCharge != null;
    final canOrder = isApproved && hasDistance && user?.address != null;

    final deliveryCharge = user?.deliveryCharge ?? 0.0;
    final handlingCharge = (user?.showHandlingCharge ?? true) ? (user?.handlingCharge ?? 5.0) : 0.0;
    final platformFee = (user?.showPlatformFee ?? true) ? (user?.platformFee ?? 10.0) : 0.0;
    final totalAmount = cart.subtotal + deliveryCharge + handlingCharge + platformFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Details'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to continue.'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ordering Validation Warning Banner
                        if (!canOrder) ...[
                          Container(
                            padding: const EdgeInsets.all(Dimensions.md),
                            margin: const EdgeInsets.only(bottom: Dimensions.md),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red),
                                const SizedBox(width: Dimensions.sm),
                                Expanded(
                                  child: Text(
                                    !isApproved
                                        ? 'Account is pending admin verification. You cannot place orders.'
                                        : 'Delivery details have not been assigned by admin yet.',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Customer Details Card
                        const Text(
                          'Customer Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Recipient Name:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    const Spacer(),
                                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.sm),
                                Row(
                                  children: [
                                    const Text('Mobile Number:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    const Spacer(),
                                    Text('+91 ${user.mobile}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),

                        // Delivery Address Card
                        const Text(
                          'Verified Delivery Address (Read Only)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: AppColors.primary),
                                    const SizedBox(width: Dimensions.sm),
                                    const Text(
                                      'Shipping Destination',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.border),
                                const SizedBox(height: Dimensions.xs),
                                if (user.address != null) ...[
                                  Text(
                                    user.address!.fullAddress,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ] else ...[
                                  const Text(
                                    'No verified address found. Please add a saved address from your profile.',
                                    style: TextStyle(color: AppColors.error, fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),

                        // Delivery Time Slot Selection
                        const Text(
                          'Select Delivery Time Slot',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.md, vertical: Dimensions.sm),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDeliverySlot,
                                hint: const Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded, color: AppColors.textSecondary, size: 20),
                                    SizedBox(width: Dimensions.md),
                                    Text(
                                      'Select Delivery Slot',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                                items: _getAvailableSlots(user.deliveryTimeSlots, user.allowTodayDelivery)
                                    .map((String slot) {
                                  return DropdownMenuItem<String>(
                                    value: slot,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 20),
                                        const SizedBox(width: Dimensions.md),
                                        Text(
                                          slot,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedDeliverySlot = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),

                        // Payment Method Details
                        const Text(
                          'Payment Method',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(Dimensions.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                                  ),
                                  child: const Icon(Icons.payments_rounded, color: AppColors.primary),
                                ),
                                const SizedBox(width: Dimensions.md),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cash On Delivery (COD)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Pay cash when order is delivered.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.radio_button_checked_rounded,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),

                        // Pricing Details Summary Card
                        const Text(
                          'Bill Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Items Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                                    Text('₹${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Delivery Charge', style: TextStyle(color: AppColors.textSecondary)),
                                    Text(
                                      isApproved && hasDistance
                                          ? '₹${deliveryCharge.toStringAsFixed(2)}'
                                          : 'Pending Review',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isApproved && hasDistance ? AppColors.textPrimary : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.showHandlingCharge) ...[
                                  const SizedBox(height: Dimensions.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Handling Charge', style: TextStyle(color: AppColors.textSecondary)),
                                      Text('₹${user.handlingCharge.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                                if (user.showPlatformFee) ...[
                                  const SizedBox(height: Dimensions.sm),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Platform Fee', style: TextStyle(color: AppColors.textSecondary)),
                                      Text('₹${user.platformFee.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                                const Divider(color: AppColors.border, height: Dimensions.lg),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount Payable',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      '₹${totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
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

                // Footer Checkout Action
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(Dimensions.md),
                  child: CustomButton(
                    text: 'Place Order (Cash on Delivery)',
                    isLoading: orderProvider.isPlacingOrder,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: canOrder ? () => _placeOrder(user, deliveryCharge, handlingCharge, platformFee) : null,
                  ),
                ),
              ],
            ),
    );
  }
}
