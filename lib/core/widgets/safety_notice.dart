import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import 'app_card.dart';

class SafetyNotice extends StatelessWidget {
  final bool compact;
  final String? customText;

  const SafetyNotice({
    super.key,
    this.compact = false,
    this.customText,
  });

  static const defaultText =
      'Écoute ton corps. Arrête si tu ressens une douleur ou un malaise. La qualité du mouvement et la récupération comptent davantage que le nombre de répétitions.';

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 16,
              color: AppColors.warning,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                customText ?? 'Rappel sécurité : arrête dès le moindre signal de douleur inhabituelle.',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      backgroundColor: AppColors.surface,
      borderColor: AppColors.border,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priorité sécurité & bienveillance',
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customText ?? defaultText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
