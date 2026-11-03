import 'fitness_level.dart';

class WorkoutPlan {
  final FitnessLevel level;
  final int sets;
  final int repsPerSet;
  final int restSeconds;
  final List<int> scheduledDaysOfWeek; // 1 = Monday ... 7 = Sunday
  final String exerciseName;
  final String techniqueNote;
  final String safeAlternative;

  const WorkoutPlan({
    required this.level,
    required this.sets,
    required this.repsPerSet,
    required this.restSeconds,
    required this.scheduledDaysOfWeek,
    required this.exerciseName,
    required this.techniqueNote,
    required this.safeAlternative,
  });

  int get totalTargetReps => sets * repsPerSet;

  bool isScheduledOn(DateTime date) {
    return scheduledDaysOfWeek.contains(date.weekday);
  }

  factory WorkoutPlan.forLevel(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return const WorkoutPlan(
          level: FitnessLevel.beginner,
          sets: 3,
          repsPerSet: 6,
          restSeconds: 60,
          scheduledDaysOfWeek: [1, 3, 5], // Lundi, Mercredi, Vendredi
          exerciseName: 'Pompes inclinées ou sur genoux',
          techniqueNote:
              'Mains sous les épaules, corps bien aligné de la tête aux genoux. Descends en 2 secondes, remonte avec contrôle sans à-coup.',
          safeAlternative:
              'Si les poignets ou les épaules fatiguent, utilise une table solide ou le mur pour réduire la charge.',
        );
      case FitnessLevel.intermediate:
        return const WorkoutPlan(
          level: FitnessLevel.intermediate,
          sets: 4,
          repsPerSet: 12,
          restSeconds: 60,
          scheduledDaysOfWeek: [1, 2, 4, 6], // Lundi, Mardi, Jeudi, Samedi
          exerciseName: 'Pompes classiques au sol',
          techniqueNote:
              'Gainage actif, fessiers serrés. Coudes à environ 45° du buste (forme de flèche, pas en T). Respire régulièrement.',
          safeAlternative:
              'Si la dernière série devient difficile, termine les dernières répétitions sur les genoux plutôt que de casser la posture.',
        );
      case FitnessLevel.advanced:
        return const WorkoutPlan(
          level: FitnessLevel.advanced,
          sets: 4,
          repsPerSet: 20,
          restSeconds: 75,
          scheduledDaysOfWeek: [1, 2, 4, 5], // Lundi, Mardi, Jeudi, Vendredi
          exerciseName: 'Pompes classiques tempo contrôlé',
          techniqueNote:
              'Amplitude complète : poitrine à quelques centimètres du sol, extension propre sans verrouillage brutal des coudes.',
          safeAlternative:
              'Privilégie toujours la propreté du mouvement au volume. Arrête-toi dès que le bassin s\'affaisse.',
        );
    }
  }
}
