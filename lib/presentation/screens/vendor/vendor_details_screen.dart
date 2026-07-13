import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/product_card.dart';

class VendorDetailsScreen extends StatefulWidget {
  final int vendorId;

  const VendorDetailsScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _productSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false)
          .fetchVendorDetails(widget.vendorId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshDetails() async {
    await Provider.of<VendorProvider>(context, listen: false)
        .fetchVendorDetails(widget.vendorId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorProvider>(context);
    final vendor = provider.selectedVendor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: provider.isLoadingDetails
          ? const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          : provider.error != null
              ? Scaffold(
                  appBar: AppBar(title: const Text('Vendor Details')),
                  body: ErrorStateWidget(
                    errorMessage: provider.error!,
                    onRetry: _refreshDetails,
                  ),
                )
              : vendor == null
                  ? Scaffold(
                      appBar: AppBar(title: const Text('Vendor Details')),
                      body: const Center(child: Text('Vendor not found')),
                    )
                  : CustomScrollView(
                      slivers: [
                        // Premium collapsible AppBar
                        SliverAppBar(
                          expandedHeight: 220,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  vendor.shopPhoto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.primaryLight,
                                      child: const Icon(
                                        Icons.store_rounded,
                                        size: 64,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              vendor.shopName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          iconTheme: const IconThemeData(color: Colors.white),
                        ),

                        // Shop Meta & Status
                        SliverToBoxAdapter(
                          child: Container(
                            color: AppColors.surface,
                            padding: const EdgeInsets.all(Dimensions.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_rounded,
                                              size: 18,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: Dimensions.xs),
                                            Text(
                                              'Owner: ${vendor.ownerName}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.md,
                                        vertical: Dimensions.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: vendor.isOpen ? AppColors.success : AppColors.error,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusMax),
                                      ),
                                      child: Text(
                                        vendor.isOpen ? 'OPEN' : 'CLOSED',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.md),
                                
                                // Local Search inside Products
                                TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _productSearchQuery = val.trim().toLowerCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search vegetables in shop...',
                                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Products Catalog List
                        _buildProductsList(vendor),
                      ],
                    ),
    );
  }

  Widget _buildProductsList(VendorModel vendor) {
    final List<ProductModel> filteredProducts = vendor.products.where((ProductModel p) {
      return p.name.toLowerCase().contains(_productSearchQuery);
    }).toList();

    if (filteredProducts.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.lg),
            child: Text(
              'No matching vegetables found in this shop.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    // Group products by Category
    final Map<String, List<dynamic>> grouped = {};
    for (var product in filteredProducts) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final categoryName = grouped.keys.elementAt(index);
          final products = grouped[categoryName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Dimensions.md, Dimensions.lg, Dimensions.md, Dimensions.sm),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
                itemCount: products.length,
                itemBuilder: (ctx, pIdx) {
                  final prod = products[pIdx];
                  return ProductCard(
                    product: prod,
                    vendorId: vendor.id,
                    vendorName: vendor.shopName,
                  );
                },
              ),
            ],
          );
        },
        childCount: grouped.keys.length,
      ),
    );
  }
}
