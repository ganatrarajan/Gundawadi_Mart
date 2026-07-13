import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../providers/notification_provider.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Log'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final notifications = provider.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No Notifications Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alerts about new or cancelled orders will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ResponsiveLayout(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = notifications[index];
                
                final isCancel = item.type == 'cancelled';
                final alertColor = isCancel ? AppColors.rejected : AppColors.primary;
                final alertIcon = isCancel ? Icons.cancel_outlined : Icons.shopping_basket_rounded;

                return Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: alertColor.withOpacity(0.1),
                      child: Icon(alertIcon, color: alertColor),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          item.body,
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.time,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Extract order number from body if possible
                      final regExp = RegExp(r'ORD-\d+');
                      final match = regExp.firstMatch(item.body);
                      if (match != null) {
                        final orderId = match.group(0);
                        if (orderId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(orderId: orderId),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
