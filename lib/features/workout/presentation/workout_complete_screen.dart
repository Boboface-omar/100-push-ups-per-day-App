import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_card.dart';
import 'controllers/workout_providers.dart';

class WorkoutCompleteScreen extends ConsumerStatefulWidget {
  final int reps;
  final int sets;
  final int duration;
  final bool completed;
  final String? reason;

  const WorkoutCompleteScreen({
    super.key,
    required this.reps,
    required this.sets,
    required this.duration,
    required this.completed,
    this.reason,
  });

  @override
  ConsumerState<WorkoutCompleteScreen> createState() =>
      _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends ConsumerState<WorkoutCompleteScreen> {
  String? _selectedFeedback;

  @override
  Widget build(BuildContext context) {
    final m = widget.duration ~/ 60;
    final s = widget.duration % 60;
    final durationFormatted = '${m}m ${s.toString().padLeft(2, '0')}s';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // Success / Completion Icon Badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: widget.completed
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.completed
                          ? AppColors.primary
                          : AppColors.warning,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.completed
                          ? Icons.check_circle_outline
                          : Icons.shield_outlined,
                      size: 40,
                      color: widget.completed
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  widget.completed
                      ? 'Bien joué !'
                      : 'Séance enregistrée',
                  style: AppTypography.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.completed
                      ? 'Chaque répétition compte pour ta force et ta régularité.'
                      : (widget.reason != null
                          ? '${widget.reason}. Bravo pour ton écoute corporelle.'
                          : 'Tu as écouté ton corps et préservé ta santé. C\'est l\'essentiel.'),
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Pompes',
                        value: '${widget.reps}',
                        subtitle: 'répétitions validées',
                        valueColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Séries',
                        value: '${widget.sets}',
                        subtitle: 'accomplies',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  label: 'Durée',
                  value: durationFormatted,
                  subtitle: 'temps d\'effort & de repos',
                ),

                const SizedBox(height: 28),

                // Feedback selector (Facile / Adapté / Difficile)
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment as-tu trouvé cette séance ?',
                        style: AppTypography.bodyBold,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cela permet d\'ajuster au mieux le rythme des prochaines séances.',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildFeedbackChip('Facile', 'easy'),
                          const SizedBox(width: 8),
                          _buildFeedbackChip('Adapté', 'just_right'),
                          const SizedBox(width: 8),
                          _buildFeedbackChip('Difficile', 'hard'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Return Home Button
                AppButton(
                  label: 'Retour à l\'accueil',
                  icon: Icons.home_rounded,
                  onPressed: () {
                    // Refresh history in state
                    ref.read(workoutHistoryProvider.notifier).reload();
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackChip(String label, String value) {
    final isSelected = _selectedFeedback == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFeedback = value;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
