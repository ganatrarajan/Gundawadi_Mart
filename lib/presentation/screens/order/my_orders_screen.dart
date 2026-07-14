import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _dateFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrders() async {
    await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
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

    // Apply Date Filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    if (_dateFilter == 'Today') {
      list = list.where((o) {
        if (o.date.isEmpty) return false;
        final date = DateTime.tryParse(o.date);
        if (date == null) return false;
        final orderDate = DateTime(date.year, date.month, date.day);
        return orderDate.isAtSameMomentAs(today);
      }).toList();
    } else if (_dateFilter == 'Yesterday') {
      list = list.where((o) {
        if (o.date.isEmpty) return false;
        final date = DateTime.tryParse(o.date);
        if (date == null) return false;
        final orderDate = DateTime(date.year, date.month, date.day);
        return orderDate.isAtSameMomentAs(yesterday);
      }).toList();
    } else if (_dateFilter == 'Last 7 Days') {
      list = list.where((o) {
        if (o.date.isEmpty) return false;
        final date = DateTime.tryParse(o.date);
        if (date == null) return false;
        final orderDate = DateTime(date.year, date.month, date.day);
        return orderDate.isAfter(sevenDaysAgo.subtract(const Duration(days: 1)));
      }).toList();
    }

    return list;
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
          // Filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search ID, shop name...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dateFilter,
                      icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
                      items: ['All', 'Today', 'Yesterday', 'Last 7 Days']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _dateFilter = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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
