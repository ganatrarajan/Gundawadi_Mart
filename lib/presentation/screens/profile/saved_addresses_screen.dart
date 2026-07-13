import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadAddressDetails();
  }

  void _loadAddressDetails() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Prefer approved address as baseline, fallback to pending if empty
    final address = auth.currentUser?.address ?? auth.currentUser?.pendingAddress;
    if (address != null) {
      _houseController.text = address.houseNumber;
      _streetController.text = address.street;
      _areaController.text = address.area;
      _landmarkController.text = address.landmark;
      _cityController.text = address.city.isNotEmpty ? address.city : 'Rajkot';
      _pincodeController.text = address.pincode;
    } else {
      _cityController.text = 'Rajkot';
    }
  }

  @override
  void dispose() {
    _houseController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      if (user == null) return;

      final updatedAddress = AddressModel(
        houseNumber: _houseController.text.trim(),
        street: _streetController.text.trim(),
        area: _areaController.text.trim(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      final success = await auth.submitAddressChangeRequest(updatedAddress);
      if (success && mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address change request submitted. Pending admin review.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Update request failed.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final address = auth.currentUser?.address;
    final pendingAddress = auth.currentUser?.pendingAddress;
    
    // An active address exists if there is an approved address with text
    final hasAddress = address != null && address.fullAddress.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.md),
        child: _isEditing || !hasAddress
            ? Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Address Change',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Dimensions.xs),
                    const Text(
                      'Address changes require admin verification and approval.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: Dimensions.md),
                    CustomTextField(
                      labelText: 'House / Flat Number *',
                      hintText: 'e.g. Flat 304, Green Meadows',
                      controller: _houseController,
                      validator: (val) => val == null || val.isEmpty ? 'House number is required' : null,
                    ),
                    const SizedBox(height: Dimensions.md),
                    CustomTextField(
                      labelText: 'Street / Building *',
                      hintText: 'e.g. Lane 4, Phase 2',
                      controller: _streetController,
                      validator: (val) => val == null || val.isEmpty ? 'Street detail is required' : null,
                    ),
                    const SizedBox(height: Dimensions.md),
                    CustomTextField(
                      labelText: 'Area / Sector *',
                      hintText: 'e.g. Sector 12, Gundawadi',
                      controller: _areaController,
                      validator: (val) => val == null || val.isEmpty ? 'Area detail is required' : null,
                    ),
                    const SizedBox(height: Dimensions.md),
                    CustomTextField(
                      labelText: 'Landmark (Optional)',
                      hintText: 'e.g. Near Central Park',
                      controller: _landmarkController,
                    ),
                    const SizedBox(height: Dimensions.md),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            labelText: 'City *',
                            hintText: 'e.g. Rajkot',
                            controller: _cityController,
                            validator: (val) => val == null || val.isEmpty ? 'City is required' : null,
                          ),
                        ),
                        const SizedBox(width: Dimensions.md),
                        Expanded(
                          child: CustomTextField(
                            labelText: 'Pincode *',
                            hintText: 'e.g. 360001',
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Pincode is required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.xl),
                    Row(
                      children: [
                        if (hasAddress)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(Dimensions.buttonHeight),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.xs)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _loadAddressDetails();
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                        if (hasAddress) const SizedBox(width: Dimensions.md),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: 'Submit Request',
                            onPressed: _saveAddress,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Dimensions.sm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.primary),
                              const SizedBox(width: Dimensions.sm),
                              const Text(
                                'Verified Delivery Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                              )
                            ],
                          ),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: Dimensions.xs),
                          Text(
                            'House No: ${address.houseNumber}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          Text(
                            'Street: ${address.street}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          Text(
                            'Area: ${address.area}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          Text(
                            'City: ${address.city} - ${address.pincode}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          if (address.landmark.isNotEmpty)
                            Text(
                              'Landmark: ${address.landmark}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          const SizedBox(height: Dimensions.sm),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: Dimensions.xs),
                          Text(
                            address.fullAddress,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Pending Address Banner
                  if (pendingAddress != null) ...[
                    const SizedBox(height: Dimensions.lg),
                    const Text(
                      'Pending Address Change',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Dimensions.sm),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.md),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade300),
                        borderRadius: BorderRadius.circular(Dimensions.xs),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.hourglass_empty_rounded, color: Colors.amber.shade800),
                              const SizedBox(width: Dimensions.sm),
                              const Text(
                                'Awaiting Admin Approval',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            pendingAddress.fullAddress,
                            style: const TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                          const SizedBox(height: Dimensions.xs),
                          const Text(
                            'Your orders will continue to ship to the active address above until this is verified.',
                            style: TextStyle(color: Colors.black54, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
