import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/workout_repository.dart';
import '../../domain/fitness_level.dart';
import '../../domain/user_profile.dart';
import '../../domain/workout_plan.dart';
import '../../domain/workout_session.dart';

// Repository provider initialized at bootstrap
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main');
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WorkoutRepository(prefs);
});

// Profile Notifier
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final repo = ref.watch(workoutRepositoryProvider);
    return repo.getUserProfile();
  }

  Future<void> updateLevel(FitnessLevel level) async {
    final repo = ref.read(workoutRepositoryProvider);
    final updated = state.copyWith(level: level);
    await repo.saveUserProfile(updated);
    state = updated;
  }

  Future<void> completeOnboarding(FitnessLevel level) async {
    final repo = ref.read(workoutRepositoryProvider);
    final updated = state.copyWith(
      level: level,
      onboardingCompleted: true,
    );
    await repo.saveUserProfile(updated);
    state = updated;
  }

  Future<void> toggleReminder(bool enabled) async {
    final repo = ref.read(workoutRepositoryProvider);
    final updated = state.copyWith(reminderEnabled: enabled);
    await repo.saveUserProfile(updated);
    state = updated;
  }

  Future<void> updateReminderTime(String time) async {
    final repo = ref.read(workoutRepositoryProvider);
    final updated = state.copyWith(reminderTime: time);
    await repo.saveUserProfile(updated);
    state = updated;
  }

  Future<void> resetProfile() async {
    final repo = ref.read(workoutRepositoryProvider);
    await repo.clearAll();
    state = UserProfile.initial();
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

// Current active plan based on profile level
final currentPlanProvider = Provider<WorkoutPlan>((ref) {
  final profile = ref.watch(userProfileProvider);
  return WorkoutPlan.forLevel(profile.level);
});

// Session history notifier
class WorkoutHistoryNotifier extends Notifier<List<WorkoutSession>> {
  @override
  List<WorkoutSession> build() {
    final repo = ref.watch(workoutRepositoryProvider);
    return repo.getAllSessions();
  }

  void reload() {
    final repo = ref.read(workoutRepositoryProvider);
    state = repo.getAllSessions();
  }

  Future<void> recordSession(WorkoutSession session) async {
    final repo = ref.read(workoutRepositoryProvider);
    await repo.saveSession(session);
    if (ref.mounted) {
      state = repo.getAllSessions();
    }
  }

  Future<void> clearHistory() async {
    final repo = ref.read(workoutRepositoryProvider);
    await repo.clearAll();
    state = [];
  }
}

final workoutHistoryProvider =
    NotifierProvider<WorkoutHistoryNotifier, List<WorkoutSession>>(
  WorkoutHistoryNotifier.new,
);

// Active Workout Session State
enum ActiveSessionStatus { ready, working, resting, paused, completed, stoppedEarly }

class ActiveWorkoutState {
  final WorkoutPlan plan;
  final int currentSet; // 1-indexed (1..plan.sets)
  final int totalSetsCompleted;
  final int totalRepsCompleted;
  final int currentRepsInSet;
  final ActiveSessionStatus status;
  final int restRemainingSeconds;
  final int totalElapsedSeconds;
  final DateTime startTime;
  final String? stopReason;

  const ActiveWorkoutState({
    required this.plan,
    required this.currentSet,
    required this.totalSetsCompleted,
    required this.totalRepsCompleted,
    required this.currentRepsInSet,
    required this.status,
    required this.restRemainingSeconds,
    required this.totalElapsedSeconds,
    required this.startTime,
    this.stopReason,
  });

  factory ActiveWorkoutState.initial(WorkoutPlan plan) {
    return ActiveWorkoutState(
      plan: plan,
      currentSet: 1,
      totalSetsCompleted: 0,
      totalRepsCompleted: 0,
      currentRepsInSet: plan.repsPerSet,
      status: ActiveSessionStatus.working,
      restRemainingSeconds: plan.restSeconds,
      totalElapsedSeconds: 0,
      startTime: DateTime.now(),
    );
  }

  ActiveWorkoutState copyWith({
    WorkoutPlan? plan,
    int? currentSet,
    int? totalSetsCompleted,
    int? totalRepsCompleted,
    int? currentRepsInSet,
    ActiveSessionStatus? status,
    int? restRemainingSeconds,
    int? totalElapsedSeconds,
    DateTime? startTime,
    String? stopReason,
  }) {
    return ActiveWorkoutState(
      plan: plan ?? this.plan,
      currentSet: currentSet ?? this.currentSet,
      totalSetsCompleted: totalSetsCompleted ?? this.totalSetsCompleted,
      totalRepsCompleted: totalRepsCompleted ?? this.totalRepsCompleted,
      currentRepsInSet: currentRepsInSet ?? this.currentRepsInSet,
      status: status ?? this.status,
      restRemainingSeconds: restRemainingSeconds ?? this.restRemainingSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      startTime: startTime ?? this.startTime,
      stopReason: stopReason ?? this.stopReason,
    );
  }

  double get overallProgress {
    if (plan.sets == 0) return 0.0;
    return (totalSetsCompleted / plan.sets).clamp(0.0, 1.0);
  }
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkoutState> {
  Timer? _timer;

  @override
  ActiveWorkoutState build() {
    final plan = ref.watch(currentPlanProvider);
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startTicker();
    return ActiveWorkoutState.initial(plan);
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == ActiveSessionStatus.paused ||
          state.status == ActiveSessionStatus.completed ||
          state.status == ActiveSessionStatus.stoppedEarly) {
        return;
      }

      final nextElapsed = state.totalElapsedSeconds + 1;

      if (state.status == ActiveSessionStatus.resting) {
        final nextRest = state.restRemainingSeconds - 1;
        if (nextRest <= 0) {
          // Rest finished! Move to next set working state
          state = state.copyWith(
            status: ActiveSessionStatus.working,
            restRemainingSeconds: state.plan.restSeconds,
            totalElapsedSeconds: nextElapsed,
          );
        } else {
          state = state.copyWith(
            restRemainingSeconds: nextRest,
            totalElapsedSeconds: nextElapsed,
          );
        }
      } else {
        state = state.copyWith(totalElapsedSeconds: nextElapsed);
      }
    });
  }

  void adjustRepsInCurrentSet(int reps) {
    if (reps < 0) return;
    state = state.copyWith(currentRepsInSet: reps);
  }

  void completeCurrentSet() {
    final updatedCompletedSets = state.totalSetsCompleted + 1;
    final updatedCompletedReps = state.totalRepsCompleted + state.currentRepsInSet;

    if (updatedCompletedSets >= state.plan.sets) {
      // Workout is complete!
      _timer?.cancel();
      state = state.copyWith(
        totalSetsCompleted: updatedCompletedSets,
        totalRepsCompleted: updatedCompletedReps,
        status: ActiveSessionStatus.completed,
      );
      _persistSession(completed: true);
    } else {
      // Start rest period
      state = state.copyWith(
        currentSet: state.currentSet + 1,
        totalSetsCompleted: updatedCompletedSets,
        totalRepsCompleted: updatedCompletedReps,
        status: ActiveSessionStatus.resting,
        restRemainingSeconds: state.plan.restSeconds,
        currentRepsInSet: state.plan.repsPerSet, // Reset reps for next set
      );
    }
  }

  void skipRest() {
    if (state.status == ActiveSessionStatus.resting) {
      state = state.copyWith(
        status: ActiveSessionStatus.working,
        restRemainingSeconds: state.plan.restSeconds,
      );
    }
  }

  void extendRest(int additionalSeconds) {
    if (state.status == ActiveSessionStatus.resting) {
      state = state.copyWith(
        restRemainingSeconds: state.restRemainingSeconds + additionalSeconds,
      );
    }
  }

  void togglePause() {
    if (state.status == ActiveSessionStatus.paused) {
      state = state.copyWith(status: ActiveSessionStatus.working);
    } else if (state.status == ActiveSessionStatus.working ||
        state.status == ActiveSessionStatus.resting) {
      state = state.copyWith(status: ActiveSessionStatus.paused);
    }
  }

  void stopEarly({required String reason}) {
    _timer?.cancel();
    state = state.copyWith(
      status: ActiveSessionStatus.stoppedEarly,
      stopReason: reason,
    );
    _persistSession(completed: false, feedback: reason);
  }

  Future<void> _persistSession({required bool completed, String? feedback}) async {
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: state.startTime,
      setsCompleted: state.totalSetsCompleted,
      targetSets: state.plan.sets,
      repsCompleted: state.totalRepsCompleted,
      targetReps: state.plan.totalTargetReps,
      durationSeconds: state.totalElapsedSeconds,
      completed: completed,
      feedback: feedback,
    );
    await ref.read(workoutHistoryProvider.notifier).recordSession(session);
  }
}

final activeWorkoutProvider =
    NotifierProvider.autoDispose<ActiveWorkoutNotifier, ActiveWorkoutState>(
  ActiveWorkoutNotifier.new,
);
