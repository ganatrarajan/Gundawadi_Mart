import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _customUnitController = TextEditingController();
  
  String _selectedUnit = '1kg';
  bool _isCustomUnit = false;
  String? _imageUrl;
  File? _localImageFile;
  bool _isUploadingImage = false;

  final List<String> _units = ['1kg', '500g', '250g', '1 piece', '1 bunch', '1 packet', 'Custom...'];

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      
      final unit = widget.product!.unit;
      if (_units.contains(unit)) {
        _selectedUnit = unit;
        _isCustomUnit = false;
      } else {
        _selectedUnit = 'Custom...';
        _isCustomUnit = true;
        _customUnitController.text = unit;
      }
      _imageUrl = widget.product!.imageUrl;
    } else {
      _selectedUnit = '1kg';
      _isCustomUnit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // compress to keep payloads lightweight
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _localImageFile = File(pickedFile.path);
          _isUploadingImage = true;
        });

        // Upload to server instantly and get remote URL
        final provider = Provider.of<ProductProvider>(context, listen: false);
        final uploadedUrl = await provider.uploadProductImage(pickedFile.path);
        
        setState(() {
          _isUploadingImage = false;
          if (uploadedUrl != null) {
            _imageUrl = uploadedUrl;
          }
        });
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary, size: 28),
                title: const Text('Take Photo from Camera', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary, size: 28),
                title: const Text('Choose from Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());

    final unit = _isCustomUnit ? _customUnitController.text.trim() : _selectedUnit;
    if (unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify a unit.'),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    bool success;
    if (isEdit) {
      final updatedProduct = widget.product!.copyWith(
        name: name,
        price: price,
        unit: unit,
        imageUrl: _imageUrl,
      );
      success = await provider.updateProduct(updatedProduct);
    } else {
      final newProduct = Product(
        name: name,
        price: price,
        unit: unit,
        imageUrl: _imageUrl,
      );
      success = await provider.createProduct(newProduct);
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Vegetable updated successfully!' : 'Vegetable added successfully!'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    }
  }

  void _delete() async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text('Are you sure you want to delete ${_nameController.text}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected,
                minimumSize: const Size(100, 48),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final provider = Provider.of<ProductProvider>(context, listen: false);
                final success = await provider.removeProduct(widget.product!.id!);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully.'),
                      backgroundColor: AppColors.completed,
                    ),
                  );
                  Navigator.pop(context); // Pop main screen
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Delete failed'),
                      backgroundColor: AppColors.rejected,
                    ),
                  );
                }
              },
              child: const Text('DELETE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Details' : 'Add New Vegetable'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_forever, size: 28, color: Colors.white),
              onPressed: _delete,
            ),
        ],
      ),
      body: ResponsiveLayout(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Area
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border, width: 2),
                                image: _localImageFile != null
                                    ? DecorationImage(
                                        image: FileImage(_localImageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : _imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(_imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (_localImageFile == null && _imageUrl == null)
                                  ? const Icon(
                                      Icons.image_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            if (_isUploadingImage)
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: FloatingActionButton.small(
                                backgroundColor: AppColors.primary,
                                onPressed: _showImageSourceSheet,
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Upload Vegetable Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Vegetable Name',
                        hintText: 'e.g. Fresh Cabbage (पत्ता गोभी)',
                        prefixIcon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: CustomTextField(
                              controller: _priceController,
                              labelText: 'Price (₹)',
                              hintText: 'e.g. 30',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Enter price';
                                }
                                final p = double.tryParse(val);
                                if (p == null || p <= 0) {
                                  return 'Invalid rate';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Per Unit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedUnit,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                                    items: _units.map((unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(unit),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedUnit = val;
                                          _isCustomUnit = val == 'Custom...';
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_isCustomUnit) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _customUnitController,
                          labelText: 'Custom Unit',
                          hintText: 'e.g. 1.5 kg, 3 kg',
                          prefixIcon: const Icon(Icons.scale_outlined, color: AppColors.primary),
                          validator: (val) {
                            if (_isCustomUnit && (val == null || val.trim().isEmpty)) {
                              return 'Enter custom unit';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: isKeyboardOpen ? 8 : 24),
                    child: CustomButton(
                      text: isEdit ? 'SAVE CHANGES' : 'ADD VEGETABLE',
                      onPressed: _isUploadingImage ? null : _save,
                      isLoading: provider.isLoading,
                      icon: Icons.check_rounded,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
