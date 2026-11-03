import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/safety_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../workout/domain/fitness_level.dart';
import '../../workout/presentation/controllers/workout_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final profileNotifier = ref.read(userProfileProvider.notifier);
    final historyNotifier = ref.read(workoutHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paramètres & Profil',
                style: AppTypography.h1,
              ),
              const SizedBox(height: 4),
              Text(
                'Adapte ton entraînement et gère tes préférences.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Level Selection Section
              const SectionHeader(title: 'Niveau d\'entraînement'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: FitnessLevel.values.map((level) {
                    final isSelected = profile.level == level;
                    return InkWell(
                      onTap: () => profileNotifier.updateLevel(level),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  width: 2,
                                ),
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.background,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level.displayName,
                                    style: AppTypography.bodyBold.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    level.targetPace,
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Reminders
              const SectionHeader(title: 'Rappels bienveillants'),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rappel d\'entraînement',
                            style: AppTypography.bodyBold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.reminderEnabled
                                ? 'Activé (chaque jour d\'entraînement à ${profile.reminderTime})'
                                : 'Désactivé',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: profile.reminderEnabled,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                      inactiveTrackColor: AppColors.surfaceElevated,
                      onChanged: (value) => profileNotifier.toggleReminder(value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Safety & Health Disclaimers
              const SectionHeader(title: 'Sécurité & Décharge'),
              const SizedBox(height: 8),
              const SafetyNotice(
                customText:
                    'Cette application est un guide de motivation personnel et non un dispositif médical. '
                    'Ne t\'entraîne jamais sur une blessure ou en cas de douleur anormale. '
                    'Pour tout doute sur ta condition physique, consulte un professionnel de santé.',
              ),

              const SizedBox(height: 28),

              // Reset Application Data
              const SectionHeader(title: 'Données locales'),
              const SizedBox(height: 8),
              AppButton(
                label: 'Réinitialiser toutes les données',
                variant: AppButtonVariant.danger,
                icon: Icons.delete_outline_rounded,
                onPressed: () => _showResetDialog(context, profileNotifier, historyNotifier),
              ),

              const SizedBox(height: 32),

              // About and Version
              Center(
                child: Column(
                  children: [
                    Text(
                      '100 PUSH UPS PER DAY • v1.0.0',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '« Une pompe après l\'autre. »',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(
    BuildContext context,
    UserProfileNotifier profileNotifier,
    WorkoutHistoryNotifier historyNotifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Réinitialiser l\'application ?',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Toutes tes séances enregistrées et tes préférences seront définitivement effacées.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: Text(
              'Annuler',
              style: AppTypography.button.copyWith(color: AppColors.textSecondary),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Confirmer la réinitialisation', style: AppTypography.button),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await profileNotifier.resetProfile();
              await historyNotifier.clearHistory();
              if (context.mounted) {
                context.go('/onboarding');
              }
            },
          ),
        ],
      ),
    );
  }
}
