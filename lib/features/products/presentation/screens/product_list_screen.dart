import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/price_update_dialog.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Vegetables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false).fetchProducts();
            },
          )
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.errorMessage != null && provider.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: AppColors.rejected),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.fetchProducts(),
                      child: const Text('TRY AGAIN'),
                    )
                  ],
                ),
              ),
            );
          }

          final products = provider.products;
          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'No vegetables listed yet.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the green button below to list your first item.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 56)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('ADD VEGETABLE', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          }

          return ResponsiveLayout(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 90, left: 8, right: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCardWidget(product: product, provider: provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        label: const Text(
          'ADD NEW VEGETABLE',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ProductCardWidget extends StatefulWidget {
  final Product product;
  final ProductProvider provider;

  const _ProductCardWidget({required this.product, required this.provider});

  @override
  State<_ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<_ProductCardWidget> {
  late TextEditingController _priceController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.product.price.toString());
  }

  @override
  void didUpdateWidget(covariant _ProductCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _priceController.text = widget.product.price.toString();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _savePrice() async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price'), backgroundColor: AppColors.rejected),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await widget.provider.changePrice(widget.product.id!, price);
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Price updated successfully'), backgroundColor: AppColors.completed),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.provider.errorMessage ?? 'Failed to update price'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = widget.product.isEnabled ? AppColors.primary : AppColors.textSecondary;
    final statusText = widget.product.isEnabled ? 'ON SALE' : 'UNAVAILABLE';

    return Card(
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.product.imageUrl != null
                  ? Image.network(
                      widget.product.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackImage(),
                    )
                  : _buildFallbackImage(),
            ),
            title: Text(
              widget.product.name,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _isEditing
                    ? Row(
                        children: [
                          SizedBox(
                            width: 90,
                            height: 38,
                            child: TextField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                prefixText: '₹',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('/ ${widget.product.unit}'),
                          const SizedBox(width: 8),
                          _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.check_circle, color: AppColors.completed, size: 28),
                                  onPressed: _savePrice,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: AppColors.rejected, size: 28),
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _priceController.text = widget.product.price.toString();
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${widget.product.price} / ${widget.product.unit}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Switch.adaptive(
              value: widget.product.isEnabled,
              activeColor: AppColors.primary,
              onChanged: (_) async {
                if (widget.product.id != null) {
                  final success = await widget.provider.toggleAvailability(widget.product.id!);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.provider.errorMessage ?? 'Failed to toggle availability'),
                        backgroundColor: AppColors.rejected,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size.zero,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: const Icon(Icons.edit_calendar_rounded, size: 20),
                    label: Text(_isEditing ? 'CANCEL EDIT' : 'CHANGE PRICE', style: const TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditProductScreen(product: widget.product),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                    label: const Text('EDIT DETAILS', style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}
