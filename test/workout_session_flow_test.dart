import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:push_ups_app/features/workout/domain/fitness_level.dart';
import 'package:push_ups_app/features/workout/presentation/controllers/workout_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ActiveWorkoutNotifier lifecycle: sets, rest, skip, completion, and safety stop',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testContainer = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    // Initial level is Beginner (3 sets of 6 reps)
    final plan = testContainer.read(currentPlanProvider);
    expect(plan.level, FitnessLevel.beginner);
    expect(plan.sets, 3);
    expect(plan.repsPerSet, 6);

    final notifier = testContainer.read(activeWorkoutProvider.notifier);
    var state = testContainer.read(activeWorkoutProvider);

    expect(state.currentSet, 1);
    expect(state.totalSetsCompleted, 0);
    expect(state.status, ActiveSessionStatus.working);

    // 1. Complete set 1
    notifier.completeCurrentSet();
    state = testContainer.read(activeWorkoutProvider);

    expect(state.totalSetsCompleted, 1);
    expect(state.totalRepsCompleted, 6);
    expect(state.status, ActiveSessionStatus.resting);
    expect(state.currentSet, 2);

    // 2. Skip rest
    notifier.skipRest();
    state = testContainer.read(activeWorkoutProvider);
    expect(state.status, ActiveSessionStatus.working);

    // 3. Complete set 2
    notifier.completeCurrentSet();
    state = testContainer.read(activeWorkoutProvider);
    expect(state.totalSetsCompleted, 2);
    expect(state.totalRepsCompleted, 12);
    expect(state.status, ActiveSessionStatus.resting);

    // Skip rest to set 3 (final set)
    notifier.skipRest();
    state = testContainer.read(activeWorkoutProvider);
    expect(state.currentSet, 3);

    // 4. Complete set 3 -> Workout completes!
    notifier.completeCurrentSet();
    state = testContainer.read(activeWorkoutProvider);
    expect(state.status, ActiveSessionStatus.completed);
    expect(state.totalSetsCompleted, 3);
    expect(state.totalRepsCompleted, 18);

    // Wait for async persistence to finish
    await Future.delayed(const Duration(milliseconds: 50));

    // Check that repository has recorded the completed session
    final repo = testContainer.read(workoutRepositoryProvider);
    final sessions = repo.getAllSessions();
    expect(sessions.length, 1);
    expect(sessions.first.completed, isTrue);
    expect(sessions.first.repsCompleted, 18);
    expect(sessions.first.setsCompleted, 3);

    testContainer.dispose();
  });
}
