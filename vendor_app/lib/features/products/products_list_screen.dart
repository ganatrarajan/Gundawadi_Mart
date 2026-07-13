import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'products_provider.dart';
import 'add_edit_product_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
    });
  }

  void _showPriceUpdateDialog(BuildContext context, int productId, String currentName, double currentPrice) {
    final priceCtrl = TextEditingController(text: currentPrice.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '$currentName નો ભાવ બદલો\n(Change Price for $currentName)',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 48, color: Colors.red),
                  onPressed: () {
                    final p = double.tryParse(priceCtrl.text) ?? 0.0;
                    if (p > 5) {
                      priceCtrl.text = (p - 5).toStringAsFixed(0);
                    }
                  },
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: '₹',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 48, color: Colors.green),
                  onPressed: () {
                    final p = double.tryParse(priceCtrl.text) ?? 0.0;
                    priceCtrl.text = (p + 5).toStringAsFixed(0);
                  },
                ),
              ],
            ),
            const Text('₹૫ (+/- 5) વધારવા કે ઘટાડવા માટે બટન દબાવો.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceCtrl.text);
              if (newPrice != null) {
                final ok = await Provider.of<ProductsProvider>(context, listen: false)
                    .quickUpdatePrice(productId, newPrice);
                if (ctx.mounted) {
                  if (ok) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ભાવ સફળતાપૂર્વક બદલાઈ ગયો છે (Price updated successfully).'), backgroundColor: Colors.green),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('શાકભાજી ના ભાવ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
              );
            },
          )
        ],
      ),
      body: productsProvider.isLoading && productsProvider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: productsProvider.fetchProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: productsProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productsProvider.products[index];
                  final int productId = product['id'];
                  final String name = product['name'];
                  final double price = double.parse(product['today_price'].toString());
                  final String unit = product['unit'];
                  final String status = product['status'];

                  final isAvailable = status == 'active';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Availability Toggle
                              ElevatedButton(
                                onPressed: () {
                                  productsProvider.toggleAvailability(productId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                                  minimumSize: const Size(120, 44),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  isAvailable ? 'ચાલુ (Active)' : 'બંધ (Inactive)',
                                  style: const TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Text(
                                'આજનો ભાવ: ₹${price.toStringAsFixed(0)} / $unit',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showPriceUpdateDialog(context, productId, name, price),
                                icon: const Icon(Icons.edit_note, size: 20),
                                label: const Text('ભાવ બદલો (Edit)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                  minimumSize: const Size(140, 44),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
