import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order: $orderId'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final orderIndex = provider.orders.indexWhere((o) => o.id == orderId);
          if (orderIndex == -1) {
            return const Center(child: Text('Order not found.'));
          }

          final order = provider.orders[orderIndex];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Tracker Banner
                          _buildStatusTracker(order.status),
                          const SizedBox(height: 20),

                          // Customer Info Panel
                          Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: AppColors.primary, size: 26),
                                      const SizedBox(width: 8),
                                      Text(
                                        'CUSTOMER DETAILS',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Text(
                                    order.customerName,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        order.mobile,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          order.address,
                                          style: const TextStyle(fontSize: 15, height: 1.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Special Delivery Note (Highlight)
                          if (order.specialNote.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.accent, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: AppColors.pending, size: 24),
                                      SizedBox(width: 8),
                                      Text(
                                        'SPECIAL NOTE FROM CUSTOMER',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.pending,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    order.specialNote,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Items List
                          Text(
                            'ORDER ITEMS',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            margin: EdgeInsets.zero,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                return _OrderItemTileWidget(
                                  orderId: order.id,
                                  orderStatus: order.status,
                                  item: item,
                                  provider: provider,
                                  currencyFormatter: currencyFormatter,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Total Card
                          Card(
                            margin: EdgeInsets.zero,
                            color: Colors.grey.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Items Total',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    currencyFormatter.format(order.totalAmount),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Stepper Buttons
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: ResponsiveLayout(
                    child: _buildBottomActions(context, order, provider),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusTracker(String currentStatus) {
    final List<String> statuses = ['pending', 'accepted', 'packing', 'ready_for_pickup', 'completed'];
    
    if (currentStatus.toLowerCase() == 'rejected') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.rejected.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.rejected, size: 28),
            SizedBox(width: 12),
            Text(
              'ORDER REJECTED',
              style: TextStyle(color: AppColors.rejected, fontSize: 18, fontWeight: FontWeight.w900),
            )
          ],
        ),
      );
    }

    final normalized = currentStatus.toLowerCase();
    int currentIndex = statuses.indexOf(normalized);
    if (currentIndex == -1) {
      if (normalized == 'ready for pickup') {
        currentIndex = 3;
      } else if (normalized == 'delivered') {
        currentIndex = 4;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(statuses.length, (index) {
          final isCompleted = index <= currentIndex && currentIndex != -1;
          final isCurrent = index == currentIndex;
          
          return Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isCurrent
                    ? AppColors.primary
                    : isCompleted
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.grey.shade300,
                child: isCompleted && !isCurrent
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                _getStatusShortLabel(statuses[index]),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AppColors.primary : Colors.grey.shade600,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getStatusShortLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'packing':
        return 'Packing';
      case 'ready_for_pickup':
      case 'ready for pickup':
        return 'Ready';
      case 'completed':
      case 'delivered':
        return 'Completed';
      default:
        return status;
    }
  }

  Widget _buildBottomActions(BuildContext context, Order order, OrderProvider provider) {
    final statusLower = order.status.toLowerCase();
    
    if (statusLower == 'accepted' || statusLower == 'packing') {
      return CustomButton(
        text: 'MARK READY FOR PICKUP',
        type: ButtonType.primary,
        onPressed: () => _confirmStatusChange(context, order.id, 'Ready For Pickup', provider),
      );
    }

    return const SizedBox.shrink();
  }

  void _confirmStatusChange(BuildContext context, String orderId, String newStatus, OrderProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Mark Ready for Pickup?'),
          content: const Text('Are you sure you want to mark this order as Ready for Pickup?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await provider.changeStatus(orderId, 'ready_for_pickup');
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order status updated successfully.'),
                      backgroundColor: AppColors.completed,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('YES, CONFIRM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _OrderItemTileWidget extends StatefulWidget {
  final String orderId;
  final String orderStatus;
  final OrderItem item;
  final OrderProvider provider;
  final NumberFormat currencyFormatter;

  const _OrderItemTileWidget({
    required this.orderId,
    required this.orderStatus,
    required this.item,
    required this.provider,
    required this.currencyFormatter,
  });

  @override
  State<_OrderItemTileWidget> createState() => _OrderItemTileWidgetState();
}

class _OrderItemTileWidgetState extends State<_OrderItemTileWidget> {
  late TextEditingController _priceController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.item.price.toString());
  }

  @override
  void didUpdateWidget(covariant _OrderItemTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _priceController.text = widget.item.price.toString();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _savePrice() async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price'), backgroundColor: AppColors.rejected),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await widget.provider.changeItemPrice(widget.orderId, widget.item.id, price);
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item price updated successfully'), backgroundColor: AppColors.completed),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.provider.errorMessage ?? 'Failed to update item price'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemSubtotal = widget.item.price * widget.item.quantity;
    final statusLower = widget.orderStatus.toLowerCase();
    final canEditPrice = statusLower == 'accepted' || statusLower == 'packing';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        widget.item.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity: ${widget.item.quantity.toStringAsFixed(0)} ${widget.item.unit}',
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          _isEditing
              ? Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 38,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          prefixText: '₹',
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : IconButton(
                            icon: const Icon(Icons.check_circle, color: AppColors.completed, size: 24),
                            onPressed: _savePrice,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: AppColors.rejected, size: 24),
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _priceController.text = widget.item.price.toString();
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              : canEditPrice
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Price: ₹${widget.item.price.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: AppColors.primary),
                        ],
                      ),
                    )
                  : Text(
                      'Price: ₹${widget.item.price.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
        ],
      ),
      trailing: Text(
        widget.currencyFormatter.format(itemSubtotal),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
