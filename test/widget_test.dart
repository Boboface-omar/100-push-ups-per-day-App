import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:push_ups_app/app/app.dart';
import 'package:push_ups_app/features/workout/presentation/controllers/workout_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders onboarding when user is new', (WidgetTester tester) async {
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

    // Verify Onboarding Screen is visible
    expect(find.text('100 PUSH UPS'), findsWidgets);
    expect(find.text('Choisis ton niveau de départ'), findsOneWidget);
    expect(find.text('Commencer mon programme'), findsOneWidget);
  });
}
