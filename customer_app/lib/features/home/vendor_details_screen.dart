import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_provider.dart';
import 'home_provider.dart';

class VendorDetailsScreen extends StatefulWidget {
  final int vendorId;
  final String shopName;

  const VendorDetailsScreen({
    super.key,
    required this.vendorId,
    required this.shopName,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  int _selectedCategoryIndex = 0; // 0 for All, 1 for Vegetables, 2 for Fruits, etc.
  final List<String> _categories = ['All', 'Vegetables', 'Fruits'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchVendorDetails(widget.vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    // Apply category filter locally
    List<dynamic> filteredProducts = homeProvider.products;
    if (_selectedCategoryIndex > 0) {
      final categoryName = _categories[_selectedCategoryIndex].toLowerCase();
      filteredProducts = homeProvider.products.where((p) {
        final cat = p['category_name']?.toString().toLowerCase() ?? '';
        return cat.contains(categoryName);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName),
      ),
      body: homeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeProvider.errorMessage != null
              ? Center(child: Text(homeProvider.errorMessage!))
              : Column(
                  children: [
                    // Category Chips Filter
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_categories[index]),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                }
                              },
                              selectedColor: const Color(0xFF2E7D32),
                              textColor: isSelected ? Colors.white : Colors.black87,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    // Products Grid/List
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(child: Text('No vegetables available in this category.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final int productId = product['id'];
                                final double price = double.parse(product['today_price'].toString());
                                final String unit = product['unit'];
                                final String name = product['name'];
                                final String? image = product['image'];

                                final cartQty = cartProvider.getProductQuantity(productId);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            color: Colors.green.shade50,
                                            child: image != null
                                                ? Image.network(
                                                    image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 30),
                                                  )
                                                : const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 30),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Product Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹${price.toStringAsFixed(2)} / $unit',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Cart Controls
                                        cartQty == 0
                                            ? SizedBox(
                                                width: 90,
                                                height: 38,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // Ensure cart isn't mixing items from different vendors
                                                    if (cartProvider.currentVendorId != null &&
                                                        cartProvider.currentVendorId != widget.vendorId) {
                                                      _showMixVendorDialog(context, cartProvider, widget.vendorId, product, price, unit);
                                                    } else {
                                                      cartProvider.addToCart(
                                                        vendorId: widget.vendorId,
                                                        productId: productId,
                                                        name: name,
                                                        price: price,
                                                        unit: unit,
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text('ADD'),
                                                ),
                                              )
                                            : Container(
                                                width: 110,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xFF2E7D32)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(Icons.remove, size: 18, color: Color(0xFF2E7D32)),
                                                      onPressed: () {
                                                        cartProvider.updateQuantity(productId, cartQty - 1);
                                                      },
                                                    ),
                                                    Text(
                                                      '$cartQty',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF2E7D32)),
                                                      onPressed: () {
                                                        cartProvider.updateQuantity(productId, cartQty + 1);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  void _showMixVendorDialog(BuildContext context, CartProvider cartProvider, int vendorId, dynamic product, double price, String unit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace Cart Items?'),
        content: const Text('Your cart contains items from a different shop. Adding this product will clear your current cart. Do you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              cartProvider.addToCart(
                vendorId: vendorId,
                productId: product['id'],
                name: product['name'],
                price: price,
                unit: unit,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}
