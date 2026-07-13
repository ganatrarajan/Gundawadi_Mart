import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final profile = provider.profile;

          if (provider.isLoading && profile == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (profile == null) {
            return const Center(child: Text('Profile information not loaded.'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ResponsiveLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop Photo Banner
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: profile.shopPhoto != null
                                  ? Image.network(
                                      profile.shopPhoto!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.storefront, size: 80, color: Colors.grey),
                                    )
                                  : const Icon(Icons.storefront, size: 80, color: Colors.grey),
                            ),
                            Container(
                              height: 80,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      profile.shopName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Profile details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              _buildDetailTile(
                                icon: Icons.person_outline,
                                label: 'OWNER NAME',
                                value: profile.ownerName,
                              ),
                              const Divider(height: 20),
                              _buildDetailTile(
                                icon: Icons.phone_android,
                                label: 'MOBILE NUMBER',
                                value: '+91 ${profile.mobile}',
                              ),
                              const Divider(height: 20),
                              _buildDetailTile(
                                icon: Icons.location_on_outlined,
                                label: 'SHOP ADDRESS',
                                value: profile.address,
                              ),
                              const Divider(height: 20),
                              _buildDetailTile(
                                icon: Icons.access_time_filled,
                                label: 'SHOP OPERATING HOURS',
                                value: '${profile.openingTime} to ${profile.closingTime}',
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ResponsiveLayout(
                    child: CustomButton(
                      text: 'EDIT PROFILE DETAILS',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      icon: Icons.edit_note_rounded,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
