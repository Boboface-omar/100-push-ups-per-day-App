import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = isEnabled ? AppColors.primary : AppColors.surfaceElevated;
        fg = isEnabled ? AppColors.background : AppColors.textSecondary;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.surfaceElevated;
        fg = isEnabled ? AppColors.textPrimary : AppColors.textSecondary;
        borderSide = const BorderSide(color: AppColors.border, width: 1);
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = isEnabled ? AppColors.textPrimary : AppColors.textSecondary;
        borderSide = const BorderSide(color: AppColors.border, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bg = isEnabled ? AppColors.error.withValues(alpha: 0.15) : AppColors.surfaceElevated;
        fg = isEnabled ? AppColors.error : AppColors.textSecondary;
        borderSide = BorderSide(
          color: isEnabled ? AppColors.error.withValues(alpha: 0.4) : AppColors.border,
          width: 1,
        );
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: AppTypography.button.copyWith(color: fg),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          splashColor: variant == AppButtonVariant.primary
              ? AppColors.primaryPressed.withValues(alpha: 0.3)
              : AppColors.surface.withValues(alpha: 0.2),
          highlightColor: variant == AppButtonVariant.primary
              ? AppColors.primaryPressed
              : AppColors.surfaceElevated,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
