import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonType { primary, outline, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.height = 58, // Prominent height for large touch target
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Choose colors based on button type
    Color getBgColor() {
      if (onPressed == null) return Colors.grey.shade300;
      switch (type) {
        case ButtonType.primary:
          return AppColors.primary;
        case ButtonType.outline:
          return Colors.white;
        case ButtonType.danger:
          return AppColors.rejected;
        case ButtonType.success:
          return AppColors.completed;
      }
    }

    Color getFgColor() {
      if (onPressed == null) return Colors.grey.shade600;
      switch (type) {
        case ButtonType.primary:
        case ButtonType.danger:
        case ButtonType.success:
          return Colors.white;
        case ButtonType.outline:
          return AppColors.primary;
      }
    }

    final BorderSide borderSide = type == ButtonType.outline && onPressed != null
        ? const BorderSide(color: AppColors.primary, width: 2)
        : BorderSide.none;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getFgColor(),
          elevation: onPressed == null ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 24),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: getFgColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
