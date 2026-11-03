import 'package:flutter_test/flutter_test.dart';
import 'package:push_ups_app/features/workout/domain/fitness_level.dart';
import 'package:push_ups_app/features/workout/domain/workout_plan.dart';

void main() {
  group('WorkoutPlan domain logic', () {
    test('Beginner plan has modest volume and 3 scheduled days', () {
      final plan = WorkoutPlan.forLevel(FitnessLevel.beginner);

      expect(plan.sets, 3);
      expect(plan.repsPerSet, 6);
      expect(plan.totalTargetReps, 18);
      expect(plan.restSeconds, 60);
      expect(plan.scheduledDaysOfWeek, [1, 3, 5]); // Mon, Wed, Fri

      // Monday is scheduled
      final monday = DateTime(2026, 11, 2); // Monday
      expect(plan.isScheduledOn(monday), isTrue);

      // Tuesday is recovery day
      final tuesday = DateTime(2026, 11, 3); // Tuesday
      expect(plan.isScheduledOn(tuesday), isFalse);
    });

    test('Intermediate plan has 4 series and progressive volume', () {
      final plan = WorkoutPlan.forLevel(FitnessLevel.intermediate);

      expect(plan.sets, 4);
      expect(plan.repsPerSet, 12);
      expect(plan.totalTargetReps, 48);
      expect(plan.scheduledDaysOfWeek.length, 4);
    });

    test('Advanced plan caps safely without demanding 100 in one go', () {
      final plan = WorkoutPlan.forLevel(FitnessLevel.advanced);

      expect(plan.sets, 4);
      expect(plan.repsPerSet, 20);
      expect(plan.totalTargetReps, 80);
      expect(plan.restSeconds, 75);
    });
  });
}
