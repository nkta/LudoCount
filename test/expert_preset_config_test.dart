import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludocount/ui/features/expert_preset_config/views/expert_preset_config_view.dart';
import 'package:ludocount/ui/features/expert_preset_config/view_models/expert_preset_config_view_model.dart';
import 'package:ludocount/data/repositories/preset_repository.dart';
import 'package:ludocount/data/services/preset_service.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ludocount/data/models/game_preset.dart';
import 'package:ludocount/data/models/player.dart';
import 'package:ludocount/data/models/game.dart';
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
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PlayerAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GameAdapter());

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
    final presetRepository = PresetRepository(presetService: PresetService());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ExpertPresetConfigViewModel(presetRepository: presetRepository),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr')],
          home: const ExpertPresetConfigView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final buttonTextFinder = find.text('Ajouter variables par défaut (Pari/Plis)');
    expect(buttonTextFinder, findsOneWidget);

    await tester.ensureVisible(buttonTextFinder);
    await tester.pumpAndSettle();

    expect(find.text('Pari (bid)'), findsNothing);
    expect(find.text('Plis (tricks)'), findsNothing);

    await tester.tap(buttonTextFinder);
    await tester.pump();

    expect(find.text('Pari (bid)', skipOffstage: false), findsOneWidget);
    expect(find.text('Plis (tricks)', skipOffstage: false), findsOneWidget);

    await tester.tap(buttonTextFinder);
    await tester.pumpAndSettle();

    expect(find.text('Pari (bid)', skipOffstage: false), findsOneWidget);
    expect(find.text('Plis (tricks)', skipOffstage: false), findsOneWidget);
  });
}
