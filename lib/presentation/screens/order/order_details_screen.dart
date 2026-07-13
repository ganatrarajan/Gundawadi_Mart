import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_state_widget.dart';

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
      Provider.of<OrderProvider>(context, listen: false)
          .fetchOrderDetails(widget.orderId);
    });
  }

  Future<void> _refreshOrder() async {
    await Provider.of<OrderProvider>(context, listen: false)
        .fetchOrderDetails(widget.orderId);
  }

  Future<void> _cancelOrder() async {
    final success = await Provider.of<OrderProvider>(context, listen: false)
        .cancelOrder(widget.orderId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order Cancelled successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.selectedOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order Details #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshOrder,
          ),
        ],
      ),
      body: provider.isLoadingOrders && order == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.error != null && order == null
              ? ErrorStateWidget(
                  errorMessage: provider.error!,
                  onRetry: _refreshOrder,
                )
              : order == null
                  ? const Center(child: Text('Order details not found'))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Shop Name & Status Header Card
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(Dimensions.md),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                                          child: Image.network(
                                            order.shopPhoto,
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 60,
                                                width: 60,
                                                color: AppColors.primaryLight,
                                                child: const Icon(Icons.store_rounded, color: AppColors.primary, size: 28),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Order #${order.id}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: Dimensions.sm,
                                                      vertical: Dimensions.xs,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(order.status).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(Dimensions.radiusMax),
                                                      border: Border.all(
                                                        color: _getStatusColor(order.status).withOpacity(0.5),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      order.status.toUpperCase(),
                                                      style: TextStyle(
                                                        color: _getStatusColor(order.status),
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: Dimensions.xs),
                                              Text(
                                                order.vendorName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: Dimensions.xs),
                                              Text(
                                                'Order Date: ${order.date}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.lg),

                                // Timeline Track
                                const Text(
                                  'Delivery Status Timeline',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.sm),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(Dimensions.md),
                                    child: _buildTimelineWidget(order.timeline),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.lg),

                                // Items Ordered
                                const Text(
                                  'Items Ordered',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.sm),
                                Card(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: order.items.length,
                                    separatorBuilder: (ctx, idx) => const Divider(height: 1, color: AppColors.border),
                                    itemBuilder: (ctx, idx) {
                                      final item = order.items[idx];
                                      return Padding(
                                        padding: const EdgeInsets.all(Dimensions.md),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item.unit} x ${item.quantity}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: Dimensions.lg),

                                // Special Remarks if any
                                if (order.specialInstructions.isNotEmpty) ...[
                                  const Text(
                                    'Special Instructions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.sm),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(Dimensions.md),
                                      child: Text(
                                        '"${order.specialInstructions}"',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.lg),
                                ],

                                // Delivery Location
                                const Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.sm),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(Dimensions.md),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded, color: AppColors.primary),
                                        const SizedBox(width: Dimensions.md),
                                        Expanded(
                                          child: Text(
                                            order.deliveryAddress,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.lg),

                                // Price Details
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(Dimensions.md),
                                    child: Column(
                                      children: [
                                        _DetailSummaryRow(
                                          label: 'Subtotal',
                                          value: '₹${(order.totalAmount - order.deliveryCharge - order.handlingCharge - order.platformFee).toStringAsFixed(0)}',
                                        ),
                                        const SizedBox(height: Dimensions.sm),
                                        _DetailSummaryRow(
                                          label: 'Delivery Charge',
                                          value: order.deliveryCharge == 0
                                              ? 'FREE'
                                              : '₹${order.deliveryCharge.toStringAsFixed(0)}',
                                          valueColor: order.deliveryCharge == 0
                                              ? AppColors.success
                                              : AppColors.textPrimary,
                                        ),
                                        if (order.handlingCharge > 0) ...[
                                          const SizedBox(height: Dimensions.sm),
                                          _DetailSummaryRow(
                                            label: 'Handling Charge',
                                            value: '₹${order.handlingCharge.toStringAsFixed(0)}',
                                          ),
                                        ],
                                        if (order.platformFee > 0) ...[
                                          const SizedBox(height: Dimensions.sm),
                                          _DetailSummaryRow(
                                            label: 'Platform Fee',
                                            value: '₹${order.platformFee.toStringAsFixed(0)}',
                                          ),
                                        ],
                                        const Divider(height: Dimensions.lg, color: AppColors.border),
                                        _DetailSummaryRow(
                                          label: 'Paid via COD',
                                          value: '₹${order.totalAmount.toStringAsFixed(0)}',
                                          isBold: true,
                                          valueColor: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.xxl),
                              ],
                            ),
                          ),
                        ),

                        // Cancel Order footer
                        if (order.status == 'Pending' || order.status == 'Accepted')
                          Container(
                            color: AppColors.surface,
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: CustomButton(
                              text: 'Cancel Order',
                              isOutlined: true,
                              onPressed: () {
                                _showCancelDialog(context);
                              },
                            ),
                          ),
                      ],
                    ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
      case 'packing':
      case 'ready for pickup':
      case 'ready_for_pickup':
      case 'out for delivery':
      case 'out_for_delivery':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildTimelineWidget(List<dynamic> milestones) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      itemBuilder: (ctx, idx) {
        final node = milestones[idx];
        final isLast = idx == milestones.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: node.isCompleted ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: node.isCompleted ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: node.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    height: 36,
                    width: 2,
                    color: node.isCompleted ? AppColors.primary : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: Dimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: node.isCompleted ? AppColors.textPrimary : AppColors.textLight,
                    ),
                  ),
                  if (node.time.isNotEmpty) ...[
                    const SizedBox(height: Dimensions.xs),
                    Text(
                      node.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: Dimensions.md),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cancel Order?'),
          content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Go Back'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _cancelOrder();
              },
              child: const Text('Cancel Order', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}

class _DetailSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailSummaryRow({
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
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
