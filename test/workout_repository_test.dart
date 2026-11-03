import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:push_ups_app/features/workout/data/workout_repository.dart';
import 'package:push_ups_app/features/workout/domain/fitness_level.dart';
import 'package:push_ups_app/features/workout/domain/user_profile.dart';
import 'package:push_ups_app/features/workout/domain/workout_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late WorkoutRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = WorkoutRepository(prefs);
  });

  group('WorkoutRepository tests', () {
    test('Default user profile returns beginner and onboarding not completed', () {
      final profile = repo.getUserProfile();
      expect(profile.level, FitnessLevel.beginner);
      expect(profile.onboardingCompleted, isFalse);
    });

    test('Saving and loading user profile works correctly', () async {
      final updated = UserProfile(
        level: FitnessLevel.intermediate,
        onboardingCompleted: true,
        reminderEnabled: true,
        reminderTime: '19:00',
        createdAt: DateTime(2026, 11, 1),
      );

      final success = await repo.saveUserProfile(updated);
      expect(success, isTrue);

      final loaded = repo.getUserProfile();
      expect(loaded.level, FitnessLevel.intermediate);
      expect(loaded.onboardingCompleted, isTrue);
      expect(loaded.reminderEnabled, isTrue);
      expect(loaded.reminderTime, '19:00');
    });

    test('Saving and querying sessions calculates total reps and counts', () async {
      final session1 = WorkoutSession(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        setsCompleted: 3,
        targetSets: 3,
        repsCompleted: 18,
        targetReps: 18,
        durationSeconds: 420,
        completed: true,
      );

      final session2 = WorkoutSession(
        id: '2',
        date: DateTime.now(),
        setsCompleted: 2,
        targetSets: 3,
        repsCompleted: 12,
        targetReps: 18,
        durationSeconds: 300,
        completed: false, // stopped early
        feedback: 'Arrêt préventif',
      );

      await repo.saveSession(session1);
      await repo.saveSession(session2);

      final all = repo.getAllSessions();
      expect(all.length, 2);
      expect(repo.getTotalRepsAllTime(), 30);
      expect(repo.getCompletedSessionsCount(), 1);

      // Check clearAll
      await repo.clearAll();
      expect(repo.getAllSessions(), isEmpty);
      expect(repo.getUserProfile().onboardingCompleted, isFalse);
    });
  });
}
