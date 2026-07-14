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
  final String initialDateFilter; // 'All', 'Today', 'Yesterday', etc.

  const OrderListScreen({
    super.key,
    this.initialStatusFilter = 'All',
    this.initialDateFilter = 'All',
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabNames = ['ALL', 'PENDING', 'ACTIVE', 'COMPLETED'];
  String _searchQuery = '';
  String _dateFilter = 'All'; // 'All', 'Today', 'Yesterday', 'Last 7 Days'

  @override
  void initState() {
    super.initState();
    _dateFilter = widget.initialDateFilter;
    int initialIdx = 0;
    if (widget.initialStatusFilter == 'Pending') {
      initialIdx = 1;
    } else if (widget.initialStatusFilter == 'Completed') {
      initialIdx = 3;
    }
    _tabController = TabController(length: _tabNames.length, vsync: this, initialIndex: initialIdx);
    
    // Automatically fetch latest orders when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
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
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: Consumer<OrderProvider>(
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
          ),
        ],
      ),
    );
  }

  List<Order> _getFilteredOrders(List<Order> list, String tab) {
    // 1. Sort orders by date-time descending (newest first)
    final sortedList = List<Order>.from(list);
    sortedList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.createdAt);
        final dateB = DateTime.parse(b.createdAt);
        return dateB.compareTo(dateA); // Descending (newest first)
      } catch (e) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA);
      }
    });

    // 2. Filter by tab
    List<Order> tabFiltered;
    switch (tab) {
      case 'PENDING':
        tabFiltered = sortedList.where((o) => ['accepted', 'packing'].contains(o.status.toLowerCase())).toList();
        break;
      case 'ACTIVE':
        final active = ['accepted', 'packing', 'ready for pickup', 'ready_for_pickup', 'out for delivery', 'out_for_delivery'];
        tabFiltered = sortedList.where((o) => active.contains(o.status.toLowerCase())).toList();
        break;
      case 'COMPLETED':
        final completed = ['ready_for_pickup', 'ready for pickup', 'completed', 'delivered', 'rejected', 'cancelled'];
        tabFiltered = sortedList.where((o) => completed.contains(o.status.toLowerCase())).toList();
        break;
      default:
        tabFiltered = sortedList;
    }

    // 3. Filter by search query (Order ID or Customer Name)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tabFiltered = tabFiltered.where((o) {
        return o.id.toLowerCase().contains(query) ||
               o.customerName.toLowerCase().contains(query);
      }).toList();
    }

    // 4. Filter by date option
    if (_dateFilter != 'All') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final sevenDaysAgo = today.subtract(const Duration(days: 7));

      tabFiltered = tabFiltered.where((o) {
        try {
          final orderDate = DateTime.parse(o.createdAt);
          if (_dateFilter == 'Today') {
            return orderDate.isAfter(today);
          } else if (_dateFilter == 'Yesterday') {
            return orderDate.isAfter(yesterday) && orderDate.isBefore(today);
          } else if (_dateFilter == 'Last 7 Days') {
            return orderDate.isAfter(sevenDaysAgo);
          }
        } catch (_) {}
        return true;
      }).toList();
    }

    return tabFiltered;
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search ID, Customer...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Date Filter Dropdown
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dateFilter,
                icon: const Icon(Icons.filter_list, color: AppColors.primary),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _dateFilter = newValue;
                    });
                  }
                },
                items: <String>['All', 'Today', 'Yesterday', 'Last 7 Days']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
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
