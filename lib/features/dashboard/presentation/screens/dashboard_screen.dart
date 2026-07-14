import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import 'package:mart/features/auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../../orders/presentation/screens/order_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../notifications/presentation/screens/notification_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final shopName = auth.user?.shopName ?? 'Gundawadi Mart Vendor';
    final ownerName = auth.user?.ownerName ?? 'Vendor';
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, size: 28),
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: () {
              Provider.of<DashboardProvider>(context, listen: false).fetchStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 26),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<DashboardProvider>(context, listen: false).fetchStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Greeting Card
                  Card(
                    color: AppColors.primary.withOpacity(0.08),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary,
                            backgroundImage: auth.user?.shopPhoto != null 
                                ? NetworkImage(auth.user!.shopPhoto!) 
                                : null,
                            child: auth.user?.shopPhoto == null 
                                ? const Icon(Icons.storefront, size: 32, color: Colors.white) 
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shopName,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 22,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Namaste, $ownerName',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sales Summary Card
                  Consumer<DashboardProvider>(
                    builder: (context, provider, _) {
                      final salesVal = provider.stats?.todaySales ?? 0.0;
                      return Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.currency_rupee, color: AppColors.primary, size: 28),
                                  SizedBox(width: 6),
                                  Text(
                                    "TODAY'S TOTAL SALES",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (provider.isLoading)
                                const SizedBox(
                                  height: 38,
                                  width: 38,
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                )
                              else
                                Text(
                                  currencyFormatter.format(salesVal),
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    fontSize: 36,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "TODAY'S ORDER SUMMARY",
                    style: theme.textTheme.titleMedium?.copyWith(
                      letterSpacing: 0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Orders Grid summary
                  Consumer<DashboardProvider>(
                    builder: (context, provider, _) {
                      final todayCount = provider.stats?.todayOrders ?? 0;
                      final pendingCount = provider.stats?.pendingOrders ?? 0;
                      final completedCount = provider.stats?.completedOrders ?? 0;

                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          _buildSummaryCard(
                            context: context,
                            title: "Pending Orders",
                            count: pendingCount,
                            color: AppColors.pending,
                            icon: Icons.hourglass_empty_rounded,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderListScreen(
                                  initialStatusFilter: 'Pending',
                                  initialDateFilter: 'Today',
                                ),
                              ),
                            ),
                          ),
                          _buildSummaryCard(
                            context: context,
                            title: "Completed Orders",
                            count: completedCount,
                            color: AppColors.completed,
                            icon: Icons.check_circle_outline_rounded,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderListScreen(
                                  initialStatusFilter: 'Completed',
                                  initialDateFilter: 'Today',
                                ),
                              ),
                            ),
                          ),
                          _buildSummaryCard(
                            context: context,
                            title: "All Today's Orders",
                            count: todayCount,
                            color: AppColors.accepted,
                            icon: Icons.shopping_basket_outlined,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderListScreen(
                                  initialStatusFilter: 'All',
                                  initialDateFilter: 'Today',
                                ),
                              ),
                            ),
                          ),
                          _buildSummaryCard(
                            context: context,
                            title: "Live Shop Profile",
                            countText: "Edit",
                            color: AppColors.secondary,
                            icon: Icons.settings_outlined,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Large Quick Access Shortcut for Products Management
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 70), // extra large for touch target
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      );
                    },
                    icon: const Icon(Icons.inventory_2_outlined, size: 30, color: Colors.white),
                    label: const Text(
                      'MANAGE MY VEGETABLES',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Large Quick Access Shortcut for Orders list
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 70),
                      side: const BorderSide(color: AppColors.primary, width: 2.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderListScreen(initialStatusFilter: 'All')),
                      );
                    },
                    icon: const Icon(Icons.assignment_outlined, size: 30, color: AppColors.primary),
                    label: const Text(
                      'VIEW ALL ORDERS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    int? count,
    String? countText,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  count != null ? count.toString() : countText ?? '',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Log Out?'),
          content: const Text('Are you sure you want to log out of Gundawadi Mart? You will not receive push notifications until you log in again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('NO', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected,
                minimumSize: const Size(100, 48),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await Provider.of<AuthProvider>(context, listen: false).logout();
              },
              child: const Text('YES, LOGOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
