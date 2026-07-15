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
  
  String _selectedMonth = 'All'; // 'All', '01', '02', ..., '12'
  String? _selectedDate; // 'YYYY-MM-DD'

  final List<Map<String, String>> _months = [
    {'name': 'All Months', 'value': 'All'},
    {'name': 'January', 'value': '01'},
    {'name': 'February', 'value': '02'},
    {'name': 'March', 'value': '03'},
    {'name': 'April', 'value': '04'},
    {'name': 'May', 'value': '05'},
    {'name': 'June', 'value': '06'},
    {'name': 'July', 'value': '07'},
    {'name': 'August', 'value': '08'},
    {'name': 'September', 'value': '09'},
    {'name': 'October', 'value': '10'},
    {'name': 'November', 'value': '11'},
    {'name': 'December', 'value': '12'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDateFilter == 'Today') {
      _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    int initialIdx = 0;
    if (widget.initialStatusFilter == 'Pending') {
      initialIdx = 1;
    } else if (widget.initialStatusFilter == 'Completed') {
      initialIdx = 3;
    }
    _tabController = TabController(length: _tabNames.length, vsync: this, initialIndex: initialIdx);
    
    // Automatically fetch latest orders when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onFilterChanged();
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
          Consumer<OrderProvider>(
            builder: (context, provider, _) {
              if (provider.orders.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  _buildEarningsCard(provider.orders, currencyFormatter),
                  _buildLimitIndicator(),
                ],
              );
            },
          ),
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
    final sortedList = List<Order>.from(list);
    sortedList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.createdAt);
        final dateB = DateTime.parse(b.createdAt);
        return dateB.compareTo(dateA);
      } catch (e) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA);
      }
    });

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

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tabFiltered = tabFiltered.where((o) {
        return o.id.toLowerCase().contains(query) ||
               o.customerName.toLowerCase().contains(query);
      }).toList();
    }

    return tabFiltered;
  }

  void _onFilterChanged() {
    String? monthParam;
    if (_selectedMonth != 'All') {
      monthParam = _selectedMonth;
    }
    String? yearParam;
    if (monthParam != null) {
      yearParam = DateTime.now().year.toString();
    }

    Provider.of<OrderProvider>(context, listen: false).fetchOrders(
      date: _selectedDate,
      month: monthParam,
      year: yearParam,
    );
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _selectedDate = formatted;
        _selectedMonth = 'All';
      });
      _onFilterChanged();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedMonth = 'All';
      _selectedDate = null;
      _searchQuery = '';
    });
    _onFilterChanged();
  }

  Widget _buildFilterPanel() {
    final hasActiveFilter = _selectedMonth != 'All' || _selectedDate != null || _searchQuery.isNotEmpty;
    
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
      child: Column(
        children: [
          Row(
            children: [
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
                    decoration: const InputDecoration(
                      hintText: 'Search ID, Customer...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      isExpanded: true,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMonth = newValue;
                            _selectedDate = null;
                          });
                          _onFilterChanged();
                        }
                      },
                      items: _months.map<DropdownMenuItem<String>>((Map<String, String> m) {
                        return DropdownMenuItem<String>(
                          value: m['value'],
                          child: Text(m['name']!),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _selectCustomDate(context),
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate != null ? _selectedDate! : 'Choose Date',
                            style: TextStyle(
                              color: _selectedDate != null ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (hasActiveFilter) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Reset', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  double _calculateEarnings(List<Order> list) {
    double total = 0.0;
    for (final order in list) {
      final statusLower = order.status.toLowerCase();
      if (statusLower == 'completed' || statusLower == 'delivered') {
        total += order.totalAmount;
      }
    }
    return total;
  }

  Widget _buildEarningsCard(List<Order> list, NumberFormat currencyFormatter) {
    final completedOrders = list.where((o) => ['completed', 'delivered'].contains(o.status.toLowerCase())).toList();
    final totalEarnings = _calculateEarnings(list);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL COMPLETED EARNINGS',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(totalEarnings),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${completedOrders.length} Orders',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitIndicator() {
    final isFiltering = _selectedMonth != 'All' || _selectedDate != null;
    if (isFiltering) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Showing last 10 orders by default. To view older orders, choose a date or select a month filter.',
              style: TextStyle(color: Colors.black87, fontSize: 11, height: 1.3),
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
