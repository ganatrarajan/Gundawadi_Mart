import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
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
      body: provider.isLoadingOrders && provider.orders.isEmpty
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
                      child: _buildOrderList(provider.currentOrders, 'No current orders'),
                    ),
                    RefreshIndicator(
                      onRefresh: _refreshOrders,
                      color: AppColors.primary,
                      child: _buildOrderList(provider.completedOrders, 'No completed orders'),
                    ),
                    RefreshIndicator(
                      onRefresh: _refreshOrders,
                      color: AppColors.primary,
                      child: _buildOrderList(provider.cancelledOrders, 'No cancelled orders'),
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
