import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/screens/expert_preset_config_screen.dart';
import 'package:ludocount/providers/game_provider.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ludocount/models/game_preset.dart';
import 'package:ludocount/models/player.dart';
import 'package:ludocount/models/game.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GamePresetAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ScoringRuleAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(GameTypeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ScoreFieldDefinitionAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GameAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PlayerAdapter());
    
    await Hive.openBox<GamePreset>('presets');
    await Hive.openBox<Player>('players');
    await Hive.openBox<Game>('games');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('Clicking "Ajouter variables par défaut" adds bid and tricks fields', (WidgetTester tester) async {
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
          supportedLocales: const [Locale('fr')],
          home: const ExpertPresetConfigScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify button exists
    final buttonTextFinder = find.text('Ajouter variables par défaut (Pari/Plis)');
    expect(buttonTextFinder, findsOneWidget);

    // Scroll to button to ensure it's visible/tappable
    await tester.ensureVisible(buttonTextFinder);
    await tester.pumpAndSettle();

    // Verify fields are initially empty
    expect(find.text('Pari (bid)'), findsNothing);
    expect(find.text('Plis (tricks)'), findsNothing);

    // Tap the button
    await tester.tap(buttonTextFinder);
    await tester.pump();

    // Verify fields are added
    expect(find.text('Pari (bid)', skipOffstage: false), findsOneWidget);
    expect(find.text('Plis (tricks)', skipOffstage: false), findsOneWidget);

    // Tap again to ensure no duplicates
    await tester.tap(buttonTextFinder);
    await tester.pumpAndSettle();

    expect(find.text('Pari (bid)', skipOffstage: false), findsOneWidget);
    expect(find.text('Plis (tricks)', skipOffstage: false), findsOneWidget);
  });
}
