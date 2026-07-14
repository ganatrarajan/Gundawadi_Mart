import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/vendor_card.dart';
import '../cart/cart_screen.dart';
import '../order/my_orders_screen.dart';
import '../order/order_details_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  // List of screens to display in bottom navigation tabs
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screens = [
      const _HomeTab(),
      const CartScreen(isTab: true),
      const MyOrdersScreen(isTab: true),
      const ProfileScreen(isTab: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = Provider.of<CartProvider>(context).totalItemCount;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              label: cartCount > 0 ? Text(cartCount.toString()) : null,
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: cartCount > 0 ? Text(cartCount.toString()) : null,
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Inner Home Tab Widget representing Greeting + Vendor Lists
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initial fetch of vendors list & active orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).fetchVendors(isRefresh: true);
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      Provider.of<AuthProvider>(context, listen: false).refreshProfile();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!vendorProvider.isLoadingVendors && vendorProvider.hasMore) {
        vendorProvider.fetchVendors(search: _searchController.text.trim());
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        Provider.of<VendorProvider>(context, listen: false).fetchVendors(
          search: query.trim(),
          isRefresh: true,
        );
      }
    });
  }

  Future<void> _refreshVendors() async {
    await Provider.of<VendorProvider>(context, listen: false).fetchVendors(
      search: _searchController.text.trim(),
      isRefresh: true,
    );
    await Provider.of<AuthProvider>(context, listen: false).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vendorProvider = Provider.of<VendorProvider>(context);

    final name = authProvider.currentUser?.name ?? 'Guest';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 95,
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: Dimensions.sm),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: authProvider.currentUser?.profilePhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          authProvider.currentUser!.profilePhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 28, color: Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Dimensions.xs),
                    const Text(
                      'Find fresh organic vegetables near you',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
      body: Column(
        children: [
          // Search Bar Section
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(Dimensions.md, 0, Dimensions.md, Dimensions.md),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search vendors or shop owners...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Sticky Warning Banner when no slots are available
          if (authProvider.currentUser != null && authProvider.currentUser!.deliveryTimeSlots.isEmpty)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.md, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: Dimensions.sm),
                  Expanded(
                    child: Text(
                      'Currently no delivery slots are available for today. Please check back later.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Vendor List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshVendors,
              color: AppColors.primary,
              child: _buildListContent(vendorProvider),
            ),
          ),
          
          // Active Order Section
          _buildActiveOrderBanner(context),
        ],
      ),
    );
  }

  Widget _buildActiveOrderBanner(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final activeOrders = orderProvider.currentOrders;
        if (activeOrders.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentOrder = activeOrders.first;
        Color statusColor;
        switch (currentOrder.status.toLowerCase()) {
          case 'pending':
            statusColor = AppColors.warning;
            break;
          case 'accepted':
          case 'packing':
          case 'ready for pickup':
          case 'ready_for_pickup':
          case 'out for delivery':
          case 'out_for_delivery':
            statusColor = AppColors.info;
            break;
          default:
            statusColor = AppColors.primary;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -4),
                blurRadius: 12,
              )
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.md, vertical: 14),
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(orderId: currentOrder.id),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: Dimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ongoing Order #${currentOrder.id}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Status: ${currentOrder.status.replaceAll('_', ' ').toUpperCase()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.sm),
                  const Text(
                    'Track',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListContent(VendorProvider provider) {
    if (provider.isLoadingVendors && provider.vendors.isEmpty) {
      return const LoadingWidget(isList: true, count: 3);
    }

    if (provider.error != null && provider.vendors.isEmpty) {
      return ErrorStateWidget(
        errorMessage: provider.error!,
        onRetry: _refreshVendors,
      );
    }

    if (provider.vendors.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.storefront_rounded,
        title: 'No Vendors Found',
        subtitle: 'We couldn\'t find any grocery stores matching your search.',
        buttonText: 'Clear Search',
        onButtonPressed: () {
          _searchController.clear();
          _refreshVendors();
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(Dimensions.md),
      itemCount: provider.vendors.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.vendors.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.md),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final vendor = provider.vendors[index];
        return VendorCard(vendor: vendor);
      },
    );
  }
}
