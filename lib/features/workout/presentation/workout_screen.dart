import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/progress_ring.dart';
import 'controllers/workout_providers.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);

    // If workout just completed, push completion screen
    ref.listen<ActiveWorkoutState>(activeWorkoutProvider, (previous, next) {
      if (next.status == ActiveSessionStatus.completed) {
        context.pushReplacement(
          '/workout-complete',
          extra: {
            'reps': next.totalRepsCompleted,
            'sets': next.totalSetsCompleted,
            'duration': next.totalElapsedSeconds,
            'completed': true,
          },
        );
      } else if (next.status == ActiveSessionStatus.stoppedEarly) {
        context.pushReplacement(
          '/workout-complete',
          extra: {
            'reps': next.totalRepsCompleted,
            'sets': next.totalSetsCompleted,
            'duration': next.totalElapsedSeconds,
            'completed': false,
            'reason': next.stopReason,
          },
        );
      }
    });

    final isResting = state.status == ActiveSessionStatus.resting;
    final isPaused = state.status == ActiveSessionStatus.paused;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitConfirmation(context, notifier);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
            onPressed: () => _showExitConfirmation(context, notifier),
          ),
          title: Text(
            state.plan.exerciseName,
            style: AppTypography.h3.copyWith(fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: isPaused ? AppColors.primary : AppColors.textSecondary,
              ),
              onPressed: () => notifier.togglePause(),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: isResting
                ? _buildRestView(context, state, notifier)
                : _buildWorkingView(context, state, notifier, isPaused),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingView(
    BuildContext context,
    ActiveWorkoutState state,
    ActiveWorkoutNotifier notifier,
    bool isPaused,
  ) {
    return Column(
      children: [
        // Overall Series Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SÉRIE ${state.currentSet} SUR ${state.plan.sets}',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              _formatDuration(state.totalElapsedSeconds),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (state.currentSet - 1) / state.plan.sets,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const Spacer(),

        // Target Repetitions Focus
        Text(
          'Répétitions visées',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),

        // Interactive rep adjuster
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 36),
              color: state.currentRepsInSet > 1
                  ? AppColors.textSecondary
                  : AppColors.surfaceElevated,
              onPressed: state.currentRepsInSet > 1
                  ? () => notifier.adjustRepsInCurrentSet(state.currentRepsInSet - 1)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              '${state.currentRepsInSet}',
              style: AppTypography.counterBig.copyWith(
                color: isPaused ? AppColors.textSecondary : AppColors.primary,
                fontSize: 72,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 36),
              color: AppColors.textSecondary,
              onPressed: () =>
                  notifier.adjustRepsInCurrentSet(state.currentRepsInSet + 1),
            ),
          ],
        ),
        Text(
          'pompes pour cette série',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),

        const Spacer(),

        // Technique reminder snippet
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Garde le corps aligné, inspire en descendant, expire en remontant.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (isPaused)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pause, size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Séance en pause',
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.warning,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Primary Action: Complete Set
        AppButton(
          label: state.currentSet == state.plan.sets
              ? 'Terminer la séance'
              : 'Valider la série',
          icon: Icons.check,
          onPressed: isPaused ? () => notifier.togglePause() : () => notifier.completeCurrentSet(),
        ),

        const SizedBox(height: 12),

        // Safety Stop Button
        AppButton(
          label: 'J\'ai une douleur ou fatigue / Arrêter',
          variant: AppButtonVariant.danger,
          height: 46,
          onPressed: () => _showSafetyStopDialog(context, notifier),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRestView(
    BuildContext context,
    ActiveWorkoutState state,
    ActiveWorkoutNotifier notifier,
  ) {
    final progress = 1.0 -
        (state.restRemainingSeconds / state.plan.restSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          'TEMPS DE RÉCUPÉRATION',
          style: AppTypography.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Prochaine série : Série ${state.currentSet} (${state.plan.repsPerSet} pompes)',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),

        // Animated Countdown Progress Ring
        ProgressRing(
          progress: progress,
          size: 200,
          strokeWidth: 12,
          activeColor: AppColors.warning,
          backgroundColor: AppColors.surfaceElevated,
          centerChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${state.restRemainingSeconds}',
                style: AppTypography.counterBig.copyWith(
                  color: AppColors.warning,
                  fontSize: 64,
                ),
              ),
              Text(
                'secondes',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Rest Controls: Extend or Skip
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: '+20 sec',
                variant: AppButtonVariant.secondary,
                height: 48,
                onPressed: () => notifier.extendRest(20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AppButton(
                label: 'Passer le repos',
                variant: AppButtonVariant.primary,
                height: 48,
                onPressed: () => notifier.skipRest(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Le repos entre les séries est crucial pour reconstituer l\'ATP musculaire.',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSafetyStopDialog(BuildContext context, ActiveWorkoutNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Priorité à ta santé',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Arrêter quand le corps le demande n\'est pas un échec, c\'est un entraînement intelligent.\n\nTes séries déjà effectuées seront enregistrées.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: Text(
              'Continuer la séance',
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
            child: Text('Arrêter la séance', style: AppTypography.button),
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.stopEarly(reason: 'Arrêt préventif / écoute du corps');
            },
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, ActiveWorkoutNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Quitter la séance ?',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Souhaites-tu interrompre la séance en cours ? Les séries complétées seront conservées.',
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
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Quitter', style: AppTypography.button),
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.stopEarly(reason: 'Interruption manuelle');
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
