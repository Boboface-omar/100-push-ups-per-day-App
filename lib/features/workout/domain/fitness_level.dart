enum FitnessLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Débutant';
      case FitnessLevel.intermediate:
        return 'Intermédiaire';
      case FitnessLevel.advanced:
        return 'Avancé';
    }
  }

  String get description {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Je découvre les pompes ou j\'en fais très peu. Je privilégie les variantes douces (inclinées ou sur genoux).';
      case FitnessLevel.intermediate:
        return 'Je pratique déjà régulièrement des pompes avec une bonne exécution de base.';
      case FitnessLevel.advanced:
        return 'Je maîtrise les pompes classiques et cherche à consolider mon volume et ma régularité.';
    }
  }

  String get targetPace {
    switch (this) {
      case FitnessLevel.beginner:
        return '3 séries de 5 à 8 répétitions • 3 séances / sem';
      case FitnessLevel.intermediate:
        return '4 séries de 10 à 15 répétitions • 3-4 séances / sem';
      case FitnessLevel.advanced:
        return '4 à 5 séries de 15 à 25 répétitions • 4 séances / sem';
    }
  }

  static FitnessLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'intermediate':
        return FitnessLevel.intermediate;
      case 'advanced':
        return FitnessLevel.advanced;
      case 'beginner':
      default:
        return FitnessLevel.beginner;
    }
  }
}
