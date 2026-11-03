import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/safety_notice.dart';
import '../../workout/domain/workout_plan.dart';
import '../../workout/domain/workout_session.dart';
import '../../workout/presentation/controllers/workout_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final plan = ref.watch(currentPlanProvider);
    final sessions = ref.watch(workoutHistoryProvider);

    final now = DateTime.now();
    final isWorkoutDay = plan.isScheduledOn(now);

    // Check if session for today is already completed
    final todaySession = sessions.firstWhere(
      (s) =>
          s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day &&
          s.completed,
      orElse: () => WorkoutSession(
        id: '',
        date: DateTime(1970),
        setsCompleted: 0,
        targetSets: 0,
        repsCompleted: 0,
        targetReps: 0,
        durationSeconds: 0,
        completed: false,
      ),
    );
    final isTodayCompleted = todaySession.completed;

    // Check if session for today is already completed
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Level badge and greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100 PUSH UPS',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getGreeting(),
                        style: AppTypography.h2.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Text(
                      profile.level.displayName,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Action Card: Today's Session OR Rest Day OR Completed
              if (isTodayCompleted)
                _buildCompletedTodayCard(context, todaySession)
              else if (isWorkoutDay)
                _buildWorkoutScheduledCard(context, plan)
              else
                _buildRestDayCard(context, plan),

              const SizedBox(height: 24),

              // Weekly Tracker Strip
              _buildWeeklyTracker(context, plan, sessions),

              const SizedBox(height: 24),

              // Daily Technique Tip
              _buildTechniqueTipCard(plan),

              const SizedBox(height: 20),

              // Safety reminder
              const SafetyNotice(compact: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Widget _buildWorkoutScheduledCard(BuildContext context, WorkoutPlan plan) {
    return AppCard(
      backgroundColor: AppColors.surface,
      borderColor: AppColors.primary.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SÉANCE DU JOUR',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                '~ 8 - 10 min',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            plan.exerciseName,
            style: AppTypography.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '${plan.sets} séries de ${plan.repsPerSet} répétitions (${plan.totalTargetReps} au total)',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricChip(
                Icons.repeat,
                '${plan.sets} séries',
              ),
              const SizedBox(width: 10),
              _buildMetricChip(
                Icons.timer_outlined,
                '${plan.restSeconds}s repos',
              ),
            ],
          ),
          const SizedBox(height: 22),
          AppButton(
            label: 'Commencer la séance',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              context.push('/workout');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTodayCard(BuildContext context, WorkoutSession session) {
    return AppCard(
      backgroundColor: AppColors.surface,
      borderColor: AppColors.success.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Séance terminée aujourd\'hui !',
                style: AppTypography.bodyBold.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${session.repsCompleted} pompes validées',
            style: AppTypography.h1.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            'Excellent travail pour ta régularité. Maintenant, laisse ton corps récupérer pour la prochaine session.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Voir mes progrès',
            variant: AppButtonVariant.secondary,
            icon: Icons.insights_rounded,
            height: 46,
            onPressed: () {
              context.go('/progress');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRestDayCard(BuildContext context, WorkoutPlan plan) {
    return AppCard(
      backgroundColor: AppColors.surface,
      borderColor: AppColors.warning.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'JOUR DE RÉCUPÉRATION',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Le repos fait grandir ta force',
            style: AppTypography.h2.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Les fibres musculaires se réparent et se renforcent pendant les jours de repos. Profite de cette journée sans culpabilité.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.spa_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Conseil : bois suffisamment d\'eau et marche un peu pour favoriser la circulation.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTracker(
    BuildContext context,
    WorkoutPlan plan,
    List<WorkoutSession> sessions,
  ) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cette semaine',
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              InkWell(
                onTap: () => context.go('/progress'),
                child: Text(
                  'Historique >',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayDate = DateTime(
                startOfWeek.year,
                startOfWeek.month,
                startOfWeek.day + index,
              );
              final isToday = dayDate.year == now.year &&
                  dayDate.month == now.month &&
                  dayDate.day == now.day;
              final isScheduled = plan.isScheduledOn(dayDate);
              final isCompleted = sessions.any((s) =>
                  s.date.year == dayDate.year &&
                  s.date.month == dayDate.month &&
                  s.date.day == dayDate.day &&
                  s.completed);

              Color dotColor;
              IconData? dotIcon;

              if (isCompleted) {
                dotColor = AppColors.success;
                dotIcon = Icons.check;
              } else if (isScheduled) {
                dotColor = isToday ? AppColors.primary : AppColors.surfaceElevated;
              } else {
                dotColor = AppColors.surfaceElevated; // Rest day
              }

              return Column(
                children: [
                  Text(
                    days[index],
                    style: AppTypography.caption.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday ? AppColors.primary : AppColors.border,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: dotIcon != null
                          ? Icon(dotIcon, size: 16, color: AppColors.background)
                          : (!isScheduled
                              ? const Icon(
                                  Icons.bedtime_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                )
                              : null),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueTipCard(WorkoutPlan plan) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseil technique',
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.techniqueNote,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Variante adaptée : ${plan.safeAlternative}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
