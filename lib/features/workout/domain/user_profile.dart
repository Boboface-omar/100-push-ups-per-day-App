import 'fitness_level.dart';

class UserProfile {
  final FitnessLevel level;
  final bool onboardingCompleted;
  final bool reminderEnabled;
  final String reminderTime; // "18:30"
  final DateTime createdAt;

  const UserProfile({
    required this.level,
    required this.onboardingCompleted,
    this.reminderEnabled = false,
    this.reminderTime = '18:30',
    required this.createdAt,
  });

  factory UserProfile.initial() {
    return UserProfile(
      level: FitnessLevel.beginner,
      onboardingCompleted: false,
      reminderEnabled: false,
      reminderTime: '18:30',
      createdAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    FitnessLevel? level,
    bool? onboardingCompleted,
    bool? reminderEnabled,
    String? reminderTime,
    DateTime? createdAt,
  }) {
    return UserProfile(
      level: level ?? this.level,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'onboardingCompleted': onboardingCompleted,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      level: FitnessLevel.fromString(json['level'] as String?),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String? ?? '18:30',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
