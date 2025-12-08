import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/screens/dice_roll_screen.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/providers/game_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('DiceRollDialog builds and rolls dice', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: const Scaffold(
            body: DiceRollDialog(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Lancer de dés'), findsOneWidget);
    expect(find.byType(DiceRollDialog), findsOneWidget);
    
    // Check for "1" (default number of dice)
    expect(find.text('1'), findsOneWidget);

    // Find Roll button
    final rollButton = find.byIcon(Icons.casino);
    expect(rollButton, findsOneWidget);

    // Tap Roll
    await tester.tap(rollButton);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 1)); // End animation
    await tester.pumpAndSettle(); // Ensure UI updates

    // Verify results are shown
    expect(find.byType(Container), findsWidgets);
    
    // Check for "Total" text
    expect(find.textContaining('Total'), findsOneWidget);
  });
}
