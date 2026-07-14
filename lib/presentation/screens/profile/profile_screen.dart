import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'saved_addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  void _editName(BuildContext context, AuthProvider auth) {
    final controller = TextEditingController(text: auth.currentUser?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(ctx);
                final address = auth.currentUser?.address ?? 
                    AddressModel(houseNumber: '', street: '', area: '', landmark: '', city: 'Rajkot', pincode: '');
                final success = await auth.updateProfile(newName, auth.currentUser!.mobile, address);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name updated successfully.')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context, AuthProvider auth) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading photo...'), duration: Duration(seconds: 2)),
      );

      final success = await auth.uploadProfilePhoto(pickedFile.path);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(auth.errorMessage ?? 'Failed to upload photo.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final name = user?.name.isNotEmpty == true ? user!.name : 'New Customer';
    final mobile = user?.mobile ?? '9876543210';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: !isTab,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          children: [
            // User Meta Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.lg),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickAndUploadPhoto(context, authProvider),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: user?.profilePhoto != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.network(
                                      user!.profilePhoto!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                                onPressed: () => _editName(context, authProvider),
                              )
                            ],
                          ),
                          Text(
                            '+91 $mobile',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.md),

            // Read Only Delivery Info Card
            if (user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Info (Read Only)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Account Status:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (user.status == 'approved' ? Colors.green : Colors.orange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: user.status == 'approved' ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Distance:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Text(
                            user.deliveryKm != null ? '${user.deliveryKm} KM' : 'Not assigned',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Assigned Delivery Charge:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Text(
                            user.deliveryCharge != null ? '₹${user.deliveryCharge!.toStringAsFixed(2)}' : 'Not assigned',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.md),
            ],

            // Profile Options Menu List
            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MenuTile(
                    icon: Icons.home_repair_service_rounded,
                    title: 'Saved Addresses',
                    subtitle: 'Manage house, street, and landmarks',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedAddressesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _MenuTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notification Settings',
                    subtitle: 'Toggle push alerts and delivery status updates',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications are managed dynamically via Firebase Messaging.'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _MenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Gundawadi Mart',
                    subtitle: 'Version 1.0.0 (Latest Stable)',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.xl),

            // Logout Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1),
                minimumSize: const Size.fromHeight(Dimensions.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
              ),
              onPressed: () {
                _showLogoutConfirmation(context, authProvider);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: Dimensions.sm),
                  Text(
                    'Logout Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout? Your active cart and orders session will be secured locally.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(Dimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }
}
