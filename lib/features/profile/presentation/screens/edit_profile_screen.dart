import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import 'package:mart/features/auth/domain/entities/user.dart';
import 'package:mart/features/auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();

  String _openingTime = '06:00 AM';
  String _closingTime = '08:00 PM';
  String? _shopPhotoUrl;
  File? _localImageFile;
  bool _isUploadingPhoto = false;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      _shopNameController.text = profile.shopName;
      _ownerNameController.text = profile.ownerName;
      _addressController.text = profile.address;
      _openingTime = profile.openingTime;
      _closingTime = profile.closingTime;
      _shopPhotoUrl = profile.shopPhoto;
      _isClosed = profile.isClosed;
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _localImageFile = File(pickedFile.path);
          _isUploadingPhoto = true;
        });

        final provider = Provider.of<ProfileProvider>(context, listen: false);
        final uploadedUrl = await provider.uploadPhoto(pickedFile.path);

        setState(() {
          _isUploadingPhoto = false;
          if (uploadedUrl != null) {
            _shopPhotoUrl = uploadedUrl;
          }
        });
      }
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
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
                title: const Text('Capture from Camera', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary, size: 28),
                title: const Text('Select from Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  TimeOfDay _parseTimeString(String timeStr, TimeOfDay defaultTime) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.length != 2) return defaultTime;
      
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return defaultTime;
      
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';
      
      if (isPm && hour != 12) {
        hour += 12;
      } else if (!isPm && hour == 12) {
        hour = 0;
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return defaultTime;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final doubleHour = hour == 0 ? 12 : hour;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final hourStr = doubleHour.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  Future<void> _selectTime(bool isOpening) async {
    final initial = isOpening
        ? _parseTimeString(_openingTime, const TimeOfDay(hour: 6, minute: 0))
        : _parseTimeString(_closingTime, const TimeOfDay(hour: 20, minute: 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        final formattedTime = _formatTimeOfDay(picked);
        if (isOpening) {
          _openingTime = formattedTime;
        } else {
          _closingTime = formattedTime;
        }
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final updatedUser = User(
      shopName: _shopNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      mobile: authProvider.user?.mobile ?? '',
      address: _addressController.text.trim(),
      openingTime: _openingTime,
      closingTime: _closingTime,
      shopPhoto: _shopPhotoUrl,
      supportName: authProvider.user?.supportName ?? 'Gmart Partner Support',
      supportMobile: authProvider.user?.supportMobile ?? '9876543210',
      isClosed: _isClosed,
    );

    final success = await provider.saveProfile(updatedUser);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop Profile updated successfully!'),
            backgroundColor: AppColors.completed,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Update failed.'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Shop Profile'),
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
                      // Image upload card
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border, width: 2),
                                image: _localImageFile != null
                                    ? DecorationImage(
                                        image: FileImage(_localImageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : _shopPhotoUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(_shopPhotoUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (_localImageFile == null && _shopPhotoUrl == null)
                                  ? const Icon(Icons.storefront, size: 60, color: Colors.grey)
                                  : null,
                            ),
                            if (_isUploadingPhoto)
                              Container(
                                width: 150,
                                height: 150,
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
                          'Upload Shop Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      CustomTextField(
                        controller: _shopNameController,
                        labelText: 'Shop Name',
                        hintText: 'e.g. Gundawadi Veg Stall',
                        prefixIcon: const Icon(Icons.storefront, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter shop name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      CustomTextField(
                        controller: _ownerNameController,
                        labelText: 'Owner Full Name',
                        hintText: 'e.g. Ramesh Patel',
                        prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter owner name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      CustomTextField(
                        controller: _addressController,
                        labelText: 'Shop Address',
                        hintText: 'e.g. Shop No. 12, Gundawadi, Rajkot',
                        prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                        maxLines: 2,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter shop address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Opening / Closing Timings Form
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Opening Time',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: AppColors.border, width: 1.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _openingTime,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(Icons.access_time, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Closing Time',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: AppColors.border, width: 1.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _closingTime,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(Icons.access_time, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Today Shop Closed Option Switch
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            'Today Shop Closed',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'If enabled, the shop will show as closed in the customer app, ignoring operating hours.',
                          ),
                          activeColor: AppColors.primary,
                          value: _isClosed,
                          onChanged: (bool value) {
                            setState(() {
                              _isClosed = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Consumer<ProfileProvider>(
                builder: (context, provider, _) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: isKeyboardOpen ? 8 : 24),
                    child: CustomButton(
                      text: 'SAVE PROFILE SETTINGS',
                      onPressed: _isUploadingPhoto ? null : _save,
                      isLoading: provider.isLoading,
                      icon: Icons.save_rounded,
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
