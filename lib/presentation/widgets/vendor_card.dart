import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/vendor_model.dart';
import '../screens/vendor/vendor_details_screen.dart';

class VendorCard extends StatelessWidget {
  final VendorModel vendor;

  const VendorCard({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (!vendor.isOpen) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Shop is currently closed'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorDetailsScreen(vendorId: vendor.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Photo with Status Badge
            Stack(
              children: [
                vendor.shopPhoto.isNotEmpty && vendor.shopPhoto.startsWith('http')
                    ? Image.network(
                        vendor.shopPhoto,
                        height: Dimensions.vendorImageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: Dimensions.vendorImageHeight,
                            width: double.infinity,
                            color: AppColors.primaryLight,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.store_rounded,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: Dimensions.vendorImageHeight,
                        width: double.infinity,
                        color: AppColors.primaryLight,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.store_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                Positioned(
                  top: Dimensions.md,
                  right: Dimensions.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.md,
                      vertical: Dimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: vendor.isOpen ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMax),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      vendor.isOpen ? 'OPEN' : 'CLOSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Vendor Info
            Padding(
              padding: const EdgeInsets.all(Dimensions.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.shopName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: Dimensions.xs),
                            Expanded(
                              child: Text(
                                vendor.ownerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.sm),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.primary,
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
}
