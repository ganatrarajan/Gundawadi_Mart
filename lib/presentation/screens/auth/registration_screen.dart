import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController(text: 'Rajkot');
  final _pincodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await auth.register(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        houseNumber: _houseController.text.trim(),
        street: _streetController.text.trim(),
        area: _areaController.text.trim(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Registration failed. Mobile might already be registered.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Submitted!'),
          ],
        ),
        content: const Text(
          'Your registration has been submitted successfully. Please wait for admin approval before logging in.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to login screen
            },
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: Dimensions.xs),
                const Text(
                  'Submit your details for verification by Gundawadi Mart admin.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: Dimensions.lg),

                // Name
                CustomTextField(
                  labelText: 'Full Name *',
                  hintText: 'Enter your first and last name',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  validator: (val) => val == null || val.isEmpty ? 'Enter your full name' : null,
                ),
                const SizedBox(height: Dimensions.md),

                // Mobile
                CustomTextField(
                  labelText: 'Mobile Number *',
                  hintText: 'Enter 10 digit contact number',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter mobile number';
                    if (val.length != 10) return 'Must be 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: Dimensions.md),

                // Password
                CustomTextField(
                  labelText: 'Password *',
                  hintText: 'Minimum 6 characters',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: Dimensions.md),

                // Confirm Password
                CustomTextField(
                  labelText: 'Confirm Password *',
                  hintText: 'Repeat your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Confirm password';
                    if (val != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: Dimensions.md),

                const Divider(height: Dimensions.xl, color: AppColors.border),
                const Text(
                  'Address Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: Dimensions.md),

                // House flat
                CustomTextField(
                  labelText: 'House / Shop / Flat Number *',
                  hintText: 'e.g. Flat 304, Green Villa',
                  controller: _houseController,
                  validator: (val) => val == null || val.isEmpty ? 'Enter house number' : null,
                ),
                const SizedBox(height: Dimensions.md),

                // Street
                CustomTextField(
                  labelText: 'Street / Road *',
                  hintText: 'e.g. Lane 4, Gundawadi Market',
                  controller: _streetController,
                  validator: (val) => val == null || val.isEmpty ? 'Enter street name' : null,
                ),
                const SizedBox(height: Dimensions.md),

                // Area
                CustomTextField(
                  labelText: 'Area / Colony *',
                  hintText: 'e.g. Gundawadi, Rajkot',
                  controller: _areaController,
                  validator: (val) => val == null || val.isEmpty ? 'Enter area' : null,
                ),
                const SizedBox(height: Dimensions.md),

                // Landmark
                CustomTextField(
                  labelText: 'Landmark (Optional)',
                  hintText: 'e.g. Near Ram Temple',
                  controller: _landmarkController,
                ),
                const SizedBox(height: Dimensions.md),

                // City / Pincode
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'City *',
                        hintText: 'Rajkot',
                        controller: _cityController,
                        validator: (val) => val == null || val.isEmpty ? 'City is required' : null,
                      ),
                    ),
                    const SizedBox(width: Dimensions.md),
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Pincode *',
                        hintText: '360001',
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (val) => val == null || val.isEmpty ? 'Enter pincode' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.xl),

                // Submit Button
                CustomButton(
                  text: 'Submit Registration',
                  isLoading: authProvider.state == AuthState.authenticating,
                  onPressed: _submitRegistration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
