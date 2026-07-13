import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'products_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  
  int _selectedCategoryId = 1; // 1 for Vegetables, 2 for Fruits
  String _selectedUnit = '1kg'; // default unit choice

  final List<String> _units = ['1kg', '500g', '250g', '1 Bunch', '1 Piece', '1 Dozen'];

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text.trim();
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;

      final success = await Provider.of<ProductsProvider>(context, listen: false).saveProduct(
        categoryId: _selectedCategoryId,
        name: name,
        price: price,
        unit: _selectedUnit,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('શાકભાજી ઉમેરાઈ ગઈ છે (Product added successfully).'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ઉમેરવામાં ભૂલ આવી છે (Error adding product).'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('નવી શાકભાજી ઉમેરો'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'નવું ઉત્પાદન ઉમેરો (Add New Item)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 24),
              // Category choice
              const Text('કેટેગરી પસંદ કરો (Select Category)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('શાકભાજી (Vegetables)', style: TextStyle(fontSize: 16)),
                      ),
                      selected: _selectedCategoryId == 1,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategoryId = 1);
                      },
                      selectedColor: const Color(0xFF1B5E20),
                      textColor: _selectedCategoryId == 1 ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('ફળો (Fruits)', style: TextStyle(fontSize: 16)),
                      ),
                      selected: _selectedCategoryId == 2,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategoryId = 2);
                      },
                      selectedColor: const Color(0xFF1B5E20),
                      textColor: _selectedCategoryId == 2 ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Product Name input
              const Text('નામ લખો (Vegetable Name)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'દા.ત. ટામેટા (e.g. Tomatoes)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 24),
              // Product Price and Unit choice
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ભાવ (Price in ₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            hintText: '40',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v!.isEmpty ? 'Enter price' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('વજન / માપ (Unit)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          style: const TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _units
                              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedUnit = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: productsProvider.isLoading ? null : _save,
                child: productsProvider.isLoading
                    ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('શાકભાજી ઉમેરો (Save Product)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
