import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final int orderId;
  final String estimatedDelivery;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.estimatedDelivery,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Success Circle
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.xl),

              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.sm),
              Text(
                'Thank you for shopping with FreshMandi. Your order is pending vendor approval.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.xl),

              // Order Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.md),
                  child: Column(
                    children: [
                      _SummaryDetailRow(
                        label: 'Order ID',
                        value: '#${widget.orderId}',
                      ),
                      const SizedBox(height: Dimensions.sm),
                      _SummaryDetailRow(
                        label: 'Estimated Delivery',
                        value: widget.estimatedDelivery,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),

              // Navigation triggers
              CustomButton(
                text: 'View My Orders',
                icon: Icons.receipt_long_rounded,
                onPressed: () {
                  // Open HomeScreen with index 2 (Orders tab)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: Dimensions.sm),
              CustomButton(
                text: 'Continue Shopping',
                isOutlined: true,
                onPressed: () {
                  // Direct to main homepage stack (Index 0)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialIndex: 0),
                    ),
                    (route) => false,
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

class _SummaryDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
