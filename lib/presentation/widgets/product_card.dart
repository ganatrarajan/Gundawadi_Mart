import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import 'custom_button.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final int vendorId;
  final String vendorName;

  const ProductCard({
    super.key,
    required this.product,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late String _selectedOption;
  late double _priceForOption;

  double _getBaseWeightInKg(String unit) {
    final unitLower = unit.toLowerCase();
    final numericPart = RegExp(r'([0-9]*\.[0-9]+|[0-9]+)').stringMatch(unitLower);
    final value = double.tryParse(numericPart ?? '') ?? 1.0;
    
    if (unitLower.contains('kg')) {
      return value;
    } else if (unitLower.contains('gm') || unitLower.contains('g') || unitLower.contains('gram') || unitLower.contains('gra')) {
      return value / 1000.0;
    }
    return 1.0;
  }

  double _getBaseCount(String unit) {
    final unitLower = unit.toLowerCase();
    final numericPart = RegExp(r'([0-9]*\.[0-9]+|[0-9]+)').stringMatch(unitLower);
    return double.tryParse(numericPart ?? '') ?? 1.0;
  }

  String _getCleanUnitName(String unit) {
    return unit.replaceFirst(RegExp(r'^[0-9\.\s]+'), '').trim();
  }

  @override
  void initState() {
    super.initState();
    final unitLower = widget.product.unit.toLowerCase();
    final isWeightBased = unitLower.contains('kg') ||
        unitLower.contains('gm') ||
        unitLower.contains('g') ||
        unitLower.contains('gram') ||
        unitLower.contains('gra');
        
    if (isWeightBased) {
      if (unitLower.contains('kg')) {
        _selectedOption = '1kg';
        final baseWeight = _getBaseWeightInKg(widget.product.unit);
        _priceForOption = (widget.product.todayPrice / baseWeight) * 1.0;
      } else {
        if (unitLower.contains('500')) {
          _selectedOption = '500g';
          _priceForOption = widget.product.todayPrice;
        } else if (unitLower.contains('250')) {
          _selectedOption = '250g';
          _priceForOption = widget.product.todayPrice;
        } else {
          _selectedOption = widget.product.unit;
          _priceForOption = widget.product.todayPrice;
        }
      }
    } else {
      final cleanUnit = _getCleanUnitName(widget.product.unit);
      _selectedOption = '1 $cleanUnit';
      final baseCount = _getBaseCount(widget.product.unit);
      _priceForOption = (widget.product.todayPrice / baseCount) * 1.0;
    }
  }

  void _selectOption(String option, double price) {
    setState(() {
      _selectedOption = option;
      _priceForOption = price;
    });
  }

  // Open Dialog for Custom Quantity Input
  void _openCustomQuantityDialog(BuildContext context) {
    final controller = TextEditingController();
    final unitLower = widget.product.unit.toLowerCase();
    final isWeightBased = unitLower.contains('kg') ||
        unitLower.contains('gm') ||
        unitLower.contains('g') ||
        unitLower.contains('gram') ||
        unitLower.contains('gra');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isWeightBased ? 'Enter Custom Weight (in kg)' : 'Enter Custom Quantity'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: isWeightBased),
            decoration: InputDecoration(
              hintText: isWeightBased ? 'e.g. 1.5 or 0.5' : 'e.g. 3 or 10',
              suffixText: isWeightBased ? 'kg' : _getCleanUnitName(widget.product.unit),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final input = double.tryParse(controller.text);
                if (input != null && input > 0) {
                  double calculatedPrice;
                  String label;
                  
                  if (isWeightBased) {
                    final baseWeight = _getBaseWeightInKg(widget.product.unit);
                    calculatedPrice = (widget.product.todayPrice / baseWeight) * input;
                    label = input == input.toInt() ? '${input.toInt()}kg' : '${input.toStringAsFixed(1)}kg';
                  } else {
                    final intQty = input.round();
                    final baseCount = _getBaseCount(widget.product.unit);
                    calculatedPrice = (widget.product.todayPrice / baseCount) * intQty;
                    final cleanUnit = _getCleanUnitName(widget.product.unit);
                    final pluralUnit = cleanUnit.endsWith('ch') 
                        ? '${cleanUnit}es' 
                        : (cleanUnit.endsWith('s') ? cleanUnit : '${cleanUnit}s');
                    label = '$intQty ${intQty == 1 ? cleanUnit : pluralUnit}';
                  }
                  
                  _selectOption(label, calculatedPrice);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inCartQty = cart.getItemQuantity(widget.product.id, _selectedOption);
    final unitLower = widget.product.unit.toLowerCase();
    final isWeightBased = unitLower.contains('kg') ||
        unitLower.contains('gm') ||
        unitLower.contains('g') ||
        unitLower.contains('gram') ||
        unitLower.contains('gra');

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.md),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row containing image, name, price
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                  child: widget.product.imageUrl.isNotEmpty && widget.product.imageUrl.startsWith('http')
                      ? Image.network(
                          widget.product.imageUrl,
                          height: Dimensions.productImageSize,
                          width: Dimensions.productImageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildProductFallback();
                          },
                        )
                      : _buildProductFallback(),
                ),
                const SizedBox(width: Dimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: Dimensions.xs),
                      Text(
                        '₹${widget.product.todayPrice.toStringAsFixed(0)} / ${widget.product.unit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: Dimensions.xs),
                      Text(
                        'Selected Option: $_selectedOption (₹${_priceForOption.toStringAsFixed(0)})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.md),

            // Presets row
            if (isWeightBased) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _PresetButton(
                      label: '500g',
                      isSelected: _selectedOption == '500g',
                      onTap: () {
                        final baseWeight = _getBaseWeightInKg(widget.product.unit);
                        final price = (widget.product.todayPrice / baseWeight) * 0.5;
                        _selectOption('500g', price);
                      },
                    ),
                    const SizedBox(width: Dimensions.sm),
                    _PresetButton(
                      label: '1kg',
                      isSelected: _selectedOption == '1kg',
                      onTap: () {
                        final baseWeight = _getBaseWeightInKg(widget.product.unit);
                        final price = (widget.product.todayPrice / baseWeight) * 1.0;
                        _selectOption('1kg', price);
                      },
                    ),
                    const SizedBox(width: Dimensions.sm),
                    _PresetButton(
                      label: '2kg',
                      isSelected: _selectedOption == '2kg',
                      onTap: () {
                        final baseWeight = _getBaseWeightInKg(widget.product.unit);
                        final price = (widget.product.todayPrice / baseWeight) * 2.0;
                        _selectOption('2kg', price);
                      },
                    ),
                    const SizedBox(width: Dimensions.sm),
                    _PresetButton(
                      label: 'Custom',
                      isSelected: _selectedOption.contains('kg') && _selectedOption != '1kg' && _selectedOption != '2kg',
                      onTap: () => _openCustomQuantityDialog(context),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Count-based items (piece, bunch, packet, bundle, box, etc.)
              Builder(
                builder: (context) {
                  final String cleanUnit = _getCleanUnitName(widget.product.unit);
                  final String pluralUnit = cleanUnit.endsWith('ch') 
                      ? '${cleanUnit}es' 
                      : (cleanUnit.endsWith('s') ? cleanUnit : '${cleanUnit}s');
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PresetButton(
                          label: '1 $cleanUnit',
                          isSelected: _selectedOption == '1 $cleanUnit',
                          onTap: () {
                            final baseCount = _getBaseCount(widget.product.unit);
                            final price = (widget.product.todayPrice / baseCount) * 1.0;
                            _selectOption('1 $cleanUnit', price);
                          },
                        ),
                        const SizedBox(width: Dimensions.sm),
                        _PresetButton(
                          label: '2 $pluralUnit',
                          isSelected: _selectedOption == '2 $pluralUnit',
                          onTap: () {
                            final baseCount = _getBaseCount(widget.product.unit);
                            final price = (widget.product.todayPrice / baseCount) * 2.0;
                            _selectOption('2 $pluralUnit', price);
                          },
                        ),
                        const SizedBox(width: Dimensions.sm),
                        _PresetButton(
                          label: '5 $pluralUnit',
                          isSelected: _selectedOption == '5 $pluralUnit',
                          onTap: () {
                            final baseCount = _getBaseCount(widget.product.unit);
                            final price = (widget.product.todayPrice / baseCount) * 5.0;
                            _selectOption('5 $pluralUnit', price);
                          },
                        ),
                        const SizedBox(width: Dimensions.sm),
                        _PresetButton(
                          label: 'Custom',
                          isSelected: !_selectedOption.startsWith('1 ') && 
                                      !_selectedOption.startsWith('2 ') && 
                                      !_selectedOption.startsWith('5 '),
                          onTap: () => _openCustomQuantityDialog(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: Dimensions.md),

            // Action button
            if (inCartQty > 0)
              Container(
                height: Dimensions.buttonHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, color: Colors.white),
                      onPressed: () => cart.updateQuantity(widget.product.id, _selectedOption, -1),
                    ),
                    Text(
                      '$inCartQty in Cart',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      onPressed: () => cart.updateQuantity(widget.product.id, _selectedOption, 1),
                    ),
                  ],
                ),
              )
            else
              CustomButton(
                text: 'Add to Cart',
                icon: Icons.shopping_bag_outlined,
                onPressed: () {
                  cart.addToCart(
                    product: widget.product,
                    optionLabel: _selectedOption,
                    pricePerUnit: _priceForOption,
                    vendorId: widget.vendorId,
                    vendorName: widget.vendorName,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} Added!'),
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () {
                          // Can pop to home or push cart screen
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductFallback() {
    final firstLetter = widget.product.name.isNotEmpty 
        ? widget.product.name[0].toUpperCase() 
        : 'V';
    return Container(
      height: Dimensions.productImageSize,
      width: Dimensions.productImageSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: Text(
          firstLetter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.md,
          vertical: Dimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

