import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../workout/domain/workout_session.dart';
import '../../workout/presentation/controllers/workout_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutHistoryProvider);
    final repo = ref.watch(workoutRepositoryProvider);

    final totalReps = repo.getTotalRepsAllTime();
    final completedSessionsCount = repo.getCompletedSessionsCount();

    // Past 7 days calculation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final past7Days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return d;
    });

    final dailyReps = past7Days.map((date) {
      final daySessions = sessions.where((s) =>
          s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day &&
          s.completed);
      final reps = daySessions.fold(0, (sum, s) => sum + s.repsCompleted);
      return {'date': date, 'reps': reps};
    }).toList();

    final maxDailyReps = dailyReps.fold<int>(
      20,
      (max, item) {
        final r = item['reps'] as int;
        return r > max ? r : max;
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progression',
                style: AppTypography.h1,
              ),
              const SizedBox(height: 4),
              Text(
                'Mesure tes accomplissements et ta régularité dans le temps.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // KPI Summary
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total pompes',
                      value: '$totalReps',
                      subtitle: 'toutes séances confondues',
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Séances faites',
                      value: '$completedSessionsCount',
                      subtitle: 'entraînements réussis',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 7-Day Activity Chart Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activité sur 7 jours',
                          style: AppTypography.h3.copyWith(fontSize: 16),
                        ),
                        Text(
                          'Répétitions / jour',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Bars container
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: dailyReps.map((item) {
                          final date = item['date'] as DateTime;
                          final reps = item['reps'] as int;
                          final isToday = date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;
                          final heightFactor = (reps / maxDailyReps).clamp(0.05, 1.0);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (reps > 0)
                                    Text(
                                      '$reps',
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 11,
                                        color: isToday
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 15),
                                  const SizedBox(height: 6),
                                  // Bar
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 90 * heightFactor,
                                        decoration: BoxDecoration(
                                          color: reps > 0
                                              ? (isToday
                                                  ? AppColors.primary
                                                  : AppColors.primary.withValues(alpha: 0.6))
                                              : AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(6),
                                          border: isToday
                                              ? Border.all(
                                                  color: AppColors.primary,
                                                  width: 1.5,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDayLetter(date.weekday),
                                    style: AppTypography.caption.copyWith(
                                      color: isToday
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: isToday
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // History Section
              const SectionHeader(title: 'Historique des séances'),
              const SizedBox(height: 8),

              if (sessions.isEmpty)
                const EmptyState(
                  title: 'Aucune séance enregistrée',
                  description:
                      'Tes séances terminées et tes répétitions apparaîtront ici au fur et à mesure.',
                  icon: Icons.history_rounded,
                )
              else
                ...sessions.map((session) => _buildSessionItem(session)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(WorkoutSession session) {
    final dateStr =
        '${session.date.day.toString().padLeft(2, '0')}/${session.date.month.toString().padLeft(2, '0')}/${session.date.year}';
    final durationStr = session.durationSeconds > 0
        ? '${session.durationSeconds ~/ 60}m ${session.durationSeconds % 60}s'
        : '--';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: session.completed
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                session.completed ? Icons.check_circle_outline : Icons.pause_circle_outline,
                size: 20,
                color: session.completed ? AppColors.primary : AppColors.warning,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${session.repsCompleted} pompes',
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${session.setsCompleted}/${session.targetSets} séries terminées',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        durationStr,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDayLetter(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mer';
      case 4:
        return 'Jeu';
      case 5:
        return 'Ven';
      case 6:
        return 'Sam';
      case 7:
        return 'Dim';
      default:
        return '';
    }
  }
}
