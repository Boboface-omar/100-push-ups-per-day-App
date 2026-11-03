import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: borderColor, width: 1);
    final radius = BorderRadius.circular(borderRadius);

    if (onTap != null) {
      return Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.surfaceElevated.withValues(alpha: 0.5),
          highlightColor: AppColors.surfaceElevated.withValues(alpha: 0.3),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}
