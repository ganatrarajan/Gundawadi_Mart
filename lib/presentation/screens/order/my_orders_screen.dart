import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/order_card.dart';

class MyOrdersScreen extends StatefulWidget {
  final bool isTab;

  const MyOrdersScreen({super.key, this.isTab = false});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onFilterChanged();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _refreshOrders() async {
    _onFilterChanged();
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
        _selectedMonth = 'All'; // Clear month filter
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

  List<OrderModel> _getFilteredOrders(List<OrderModel> ordersList) {
    List<OrderModel> list = List.from(ordersList);

    // Apply Search Filter (by Order ID or Vendor/Shop Name)
    if (_searchQuery.isNotEmpty) {
      list = list.where((o) {
        final idStr = '#${o.id}';
        final shopName = o.vendorName.toLowerCase();
        return idStr.contains(_searchQuery.toLowerCase()) ||
            o.id.toString().contains(_searchQuery) ||
            shopName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return list;
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
                      hintText: 'Search ID, shop name...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
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
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
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
                        const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
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

  Widget _buildLimitIndicator() {
    final isFiltering = _selectedMonth != 'All' || _selectedDate != null;
    if (isFiltering) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        automaticallyImplyLeading: !widget.isTab,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Current'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          _buildLimitIndicator(),
          Expanded(
            child: provider.isLoadingOrders && provider.orders.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : provider.error != null && provider.orders.isEmpty
                    ? ErrorStateWidget(
                        errorMessage: provider.error!,
                        onRetry: _refreshOrders,
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: _refreshOrders,
                            color: AppColors.primary,
                            child: _buildOrderList(
                              _getFilteredOrders(provider.currentOrders),
                              'No current orders',
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: _refreshOrders,
                            color: AppColors.primary,
                            child: _buildOrderList(
                              _getFilteredOrders(provider.completedOrders),
                              'No completed orders',
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: _refreshOrders,
                            color: AppColors.primary,
                            child: _buildOrderList(
                              _getFilteredOrders(provider.cancelledOrders),
                              'No cancelled orders',
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String emptyMsg) {
    if (orders.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: EmptyStateWidget(
            icon: Icons.receipt_long_rounded,
            title: 'No Orders Found',
            subtitle: emptyMsg,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.md),
      itemCount: orders.length,
      itemBuilder: (ctx, index) {
        final order = orders[index];
        return OrderCard(order: order);
      },
    );
  }
}
