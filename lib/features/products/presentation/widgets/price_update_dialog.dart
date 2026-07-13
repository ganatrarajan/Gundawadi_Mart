import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class PriceUpdateDialog extends StatefulWidget {
  final int productId;
  final String productName;
  final double currentPrice;
  final String unit;
  final Function(double) onUpdated;

  const PriceUpdateDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.currentPrice,
    required this.unit,
    required this.onUpdated,
  });

  @override
  State<PriceUpdateDialog> createState() => _PriceUpdateDialogState();
}

class _PriceUpdateDialogState extends State<PriceUpdateDialog> {
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.currentPrice.toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Today\'s Price'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current rate: ₹${widget.currentPrice} per ${widget.unit}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _priceController,
              labelText: 'Today\'s Price (₹)',
              hintText: 'Enter new rate',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter a price';
                }
                final price = double.tryParse(val);
                if (price == null || price <= 0) {
                  return 'Enter a valid price greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(120, 48),
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final newPrice = double.parse(_priceController.text.trim());
            widget.onUpdated(newPrice);
            Navigator.pop(context);
          },
          child: const Text(
            'UPDATE',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
