import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/order.dart';
import '../providers/order_provider.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  final String initialStatusFilter; // 'All', 'Pending', 'Completed', etc.

  const OrderListScreen({super.key, this.initialStatusFilter = 'All'});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabNames = ['ALL', 'PENDING', 'ACTIVE', 'COMPLETED'];

  @override
  void initState() {
    super.initState();
    int initialIdx = 0;
    if (widget.initialStatusFilter == 'Pending') {
      initialIdx = 1;
    } else if (widget.initialStatusFilter == 'Completed') {
      initialIdx = 3;
    }
    _tabController = TabController(length: _tabNames.length, vsync: this, initialIndex: initialIdx);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: _tabNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: AppColors.rejected),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.fetchOrders(),
                      child: const Text('TRY AGAIN'),
                    )
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _tabNames.map((tab) {
              final filteredList = _getFilteredOrders(provider.orders, tab);
              
              if (filteredList.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No orders in $tab',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchOrders(),
                child: ResponsiveLayout(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final order = filteredList[index];
                      return _buildOrderCard(context, order, provider, currencyFormatter);
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<Order> _getFilteredOrders(List<Order> list, String tab) {
    switch (tab) {
      case 'PENDING':
        return list.where((o) => ['accepted', 'packing'].contains(o.status.toLowerCase())).toList();
      case 'ACTIVE':
        final active = ['accepted', 'packing', 'ready for pickup', 'ready_for_pickup', 'out for delivery', 'out_for_delivery'];
        return list.where((o) => active.contains(o.status.toLowerCase())).toList();
      case 'COMPLETED':
        final completed = ['ready_for_pickup', 'ready for pickup', 'completed', 'delivered', 'rejected', 'cancelled'];
        return list.where((o) => completed.contains(o.status.toLowerCase())).toList();
      default:
        return list;
    }
  }

  Widget _buildOrderCard(BuildContext context, Order order, OrderProvider provider, NumberFormat currency) {
    Color statusBgColor;
    Color statusFgColor = Colors.white;
    
    final statusLower = order.status.toLowerCase();
    switch (statusLower) {
      case 'pending':
        statusBgColor = AppColors.pending;
        break;
      case 'accepted':
        statusBgColor = AppColors.accepted;
        break;
      case 'packing':
        statusBgColor = AppColors.packing;
        break;
      case 'ready for pickup':
      case 'ready_for_pickup':
        statusBgColor = AppColors.readyForPickup;
        break;
      case 'completed':
      case 'delivered':
        statusBgColor = AppColors.completed;
        break;
      default:
        statusBgColor = AppColors.rejected;
    }

    final itemsSummary = order.items.map((i) => '${i.name} (${i.quantity} ${i.unit})').join(', ');

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ID & status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(color: statusFgColor, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date-time & customer
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    order.createdAt,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                'Customer: ${order.customerName}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Address: ${order.address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Veggies summary list
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ITEMS:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itemsSummary,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Total block
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Items Total:', style: TextStyle(fontSize: 16)),
                  Text(
                    currency.format(order.totalAmount),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons (Minimal clicks rule)
              if (order.status.toLowerCase() == 'accepted' || order.status.toLowerCase() == 'packing') ...[
                CustomButton(
                  text: 'MARK READY FOR PICKUP',
                  type: ButtonType.primary,
                  height: 50,
                  onPressed: () => _confirmStatusChange(context, order.id, 'Ready For Pickup', provider),
                ),
              ] else ...[
                // Detail shortcut
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(orderId: order.id),
                      ),
                    );
                  },
                  child: const Text('VIEW DETAILS & RECEIPT', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
