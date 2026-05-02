import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/ui/features/dice/views/dice_roll_dialog.dart';
import 'package:ludocount/ui/features/dice/view_models/dice_view_model.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('DiceRollDialog builds and rolls dice', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DiceViewModel()),
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

    expect(find.text('Lancer de dés'), findsOneWidget);
    expect(find.byType(DiceRollDialog), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    final rollButton = find.byIcon(Icons.casino);
    expect(rollButton, findsOneWidget);

    await tester.tap(rollButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsWidgets);
    expect(find.textContaining('Total'), findsOneWidget);
  });
}
