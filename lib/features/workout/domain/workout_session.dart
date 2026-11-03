class WorkoutSession {
  final String id;
  final DateTime date;
  final int setsCompleted;
  final int targetSets;
  final int repsCompleted;
  final int targetReps;
  final int durationSeconds;
  final bool completed;
  final String? feedback; // 'easy', 'just_right', 'hard', 'stopped_pain'

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.setsCompleted,
    required this.targetSets,
    required this.repsCompleted,
    required this.targetReps,
    required this.durationSeconds,
    required this.completed,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'setsCompleted': setsCompleted,
      'targetSets': targetSets,
      'repsCompleted': repsCompleted,
      'targetReps': targetReps,
      'durationSeconds': durationSeconds,
      'completed': completed,
      'feedback': feedback,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      setsCompleted: json['setsCompleted'] as int? ?? 0,
      targetSets: json['targetSets'] as int? ?? 0,
      repsCompleted: json['repsCompleted'] as int? ?? 0,
      targetReps: json['targetReps'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      feedback: json['feedback'] as String?,
    );
  }

  WorkoutSession copyWith({
    String? id,
    DateTime? date,
    int? setsCompleted,
    int? targetSets,
    int? repsCompleted,
    int? targetReps,
    int? durationSeconds,
    bool? completed,
    String? feedback,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      setsCompleted: setsCompleted ?? this.setsCompleted,
      targetSets: targetSets ?? this.targetSets,
      repsCompleted: repsCompleted ?? this.repsCompleted,
      targetReps: targetReps ?? this.targetReps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      feedback: feedback ?? this.feedback,
    );
  }
}
