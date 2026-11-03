import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_profile.dart';
import '../domain/workout_session.dart';

class WorkoutRepository {
  static const String _profileKey = 'user_profile';
  static const String _sessionsKey = 'workout_sessions';

  final SharedPreferences _prefs;

  WorkoutRepository(this._prefs);

  static Future<WorkoutRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutRepository(prefs);
  }

  // --- Profile Methods ---

  UserProfile getUserProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) {
      return UserProfile.initial();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return UserProfile.initial();
    }
  }

  Future<bool> saveUserProfile(UserProfile profile) async {
    final raw = jsonEncode(profile.toJson());
    return _prefs.setString(_profileKey, raw);
  }

  // --- Session Methods ---

  List<WorkoutSession> getAllSessions() {
    final rawList = _prefs.getStringList(_sessionsKey) ?? [];
    final sessions = <WorkoutSession>[];
    for (final raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        sessions.add(WorkoutSession.fromJson(map));
      } catch (_) {
        // Skip corrupted entry
      }
    }
    // Sort descending by date (most recent first)
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  Future<bool> saveSession(WorkoutSession session) async {
    final sessions = getAllSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.insert(0, session);
    }
    final rawList = sessions.map((s) => jsonEncode(s.toJson())).toList();
    return _prefs.setStringList(_sessionsKey, rawList);
  }

  WorkoutSession? getTodaySession() {
    final sessions = getAllSessions();
    final now = DateTime.now();
    for (final s in sessions) {
      if (s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day) {
        return s;
      }
    }
    return null;
  }

  List<WorkoutSession> getSessionsForPast7Days() {
    final sessions = getAllSessions();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return sessions.where((s) => s.date.isAfter(cutoff)).toList();
  }

  int getTotalRepsAllTime() {
    final sessions = getAllSessions();
    return sessions.fold(0, (sum, s) => sum + s.repsCompleted);
  }

  int getCompletedSessionsCount() {
    final sessions = getAllSessions();
    return sessions.where((s) => s.completed).length;
  }

  Future<void> clearAll() async {
    await _prefs.remove(_profileKey);
    await _prefs.remove(_sessionsKey);
  }
}
