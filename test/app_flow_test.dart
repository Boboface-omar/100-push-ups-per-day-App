import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:push_ups_app/app/app.dart';
import 'package:push_ups_app/features/workout/presentation/controllers/workout_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full flow: Onboarding selection, reaching Home and seeing Workout card',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const PushUpsApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Onboarding
    expect(find.text('Choisis ton niveau de départ'), findsOneWidget);
    expect(find.text('Intermédiaire'), findsOneWidget);

    // Tap on 'Intermédiaire' level
    await tester.ensureVisible(find.text('Intermédiaire'));
    await tester.tap(find.text('Intermédiaire'));
    await tester.pumpAndSettle();

    // Tap 'Commencer mon programme'
    await tester.ensureVisible(find.text('Commencer mon programme'));
    await tester.tap(find.text('Commencer mon programme'));
    await tester.pumpAndSettle();

    // 2. We should now be on HomeScreen
    expect(find.text('100 PUSH UPS'), findsWidgets);
    expect(find.text('Intermédiaire'), findsOneWidget);

    await tester.ensureVisible(find.text('Cette semaine'));
    expect(find.text('Cette semaine'), findsOneWidget);
    expect(find.text('Conseil technique'), findsOneWidget);

    // 3. Navigation Bar check: Accueil, Progression, Profil
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Progression'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // 4. Tap on 'Progression' tab
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();

    expect(find.text('TOTAL POMPES'), findsOneWidget);
    expect(find.text('Activité sur 7 jours'), findsOneWidget);
    expect(find.text('Historique des séances'), findsOneWidget);

    // 5. Tap on 'Profil' tab
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();

    expect(find.text('Paramètres & Profil'), findsOneWidget);
    expect(find.text('Niveau d\'entraînement'), findsOneWidget);
    expect(find.text('Rappels bienveillants'), findsOneWidget);
    expect(find.text('Réinitialiser toutes les données'), findsOneWidget);
  });
}
