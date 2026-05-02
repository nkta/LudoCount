import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/models/game.dart';
import 'data/models/game_preset.dart';
import 'data/models/player.dart';
import 'data/repositories/game_repository.dart';
import 'data/repositories/player_repository.dart';
import 'data/repositories/preset_repository.dart';
import 'data/services/game_service.dart';
import 'data/services/player_service.dart';
import 'data/services/preset_service.dart';
import 'domain/use_cases/calculate_score_use_case.dart';
import 'domain/use_cases/seed_presets_use_case.dart';
import 'l10n/app_localizations.dart';
import 'ui/features/dice/view_models/dice_view_model.dart';
import 'ui/features/game_config/view_models/game_config_view_model.dart';
import 'ui/features/game_config/views/game_config_view.dart';
import 'ui/features/history/view_models/history_view_model.dart';
import 'ui/features/history/views/history_view.dart';
import 'ui/features/home/view_models/home_view_model.dart';
import 'ui/features/home/views/home_view.dart';
import 'ui/features/players/view_models/players_view_model.dart';
import 'ui/features/players/views/players_view.dart';
import 'ui/features/presets/view_models/presets_view_model.dart';
import 'ui/features/presets/views/presets_view.dart';
import 'ui/features/score/view_models/score_view_model.dart';
import 'ui/features/score/views/score_view.dart';

void main() async {
  await Hive.initFlutter();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  Hive.registerAdapter(GamePresetAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(GameTypeAdapter());
  Hive.registerAdapter(ScoreFieldDefinitionAdapter());
  Hive.registerAdapter(ScoringRuleAdapter());

  await Hive.openBox<GamePreset>('presets');
  await Hive.openBox<Player>('players');
  await Hive.openBox<Game>('games');

  final playerService = PlayerService();
  final gameService = GameService();
  final presetService = PresetService();

  final playerRepository = PlayerRepository(playerService: playerService);
  final gameRepository = GameRepository(gameService: gameService);
  final presetRepository = PresetRepository(presetService: presetService);
  final calculateScoreUseCase = CalculateScoreUseCase();

  await SeedPresetsUseCase(presetRepository: presetRepository).call();

  runApp(LudoCountApp(
    playerRepository: playerRepository,
    gameRepository: gameRepository,
    presetRepository: presetRepository,
    calculateScoreUseCase: calculateScoreUseCase,
  ));
}

class LudoCountApp extends StatelessWidget {
  const LudoCountApp({
    super.key,
    required this.playerRepository,
    required this.gameRepository,
    required this.presetRepository,
    required this.calculateScoreUseCase,
  });

  final PlayerRepository playerRepository;
  final GameRepository gameRepository;
  final PresetRepository presetRepository;
  final CalculateScoreUseCase calculateScoreUseCase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: playerRepository),
        ChangeNotifierProvider.value(value: gameRepository),
        ChangeNotifierProvider.value(value: presetRepository),
        Provider.value(value: calculateScoreUseCase),
        ChangeNotifierProvider(create: (_) => DiceViewModel()),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/',
        routes: {
          '/': (context) => ChangeNotifierProvider(
                create: (ctx) =>
                    HomeViewModel(gameRepository: ctx.read()),
                child: const HomeView(),
              ),
          '/config': (context) => ChangeNotifierProvider(
                create: (ctx) => GameConfigViewModel(
                  playerRepository: ctx.read(),
                  gameRepository: ctx.read(),
                  presetRepository: ctx.read(),
                ),
                child: const GameConfigView(),
              ),
          '/presets': (context) => ChangeNotifierProvider(
                create: (ctx) =>
                    PresetsViewModel(presetRepository: ctx.read()),
                child: const PresetsView(),
              ),
          '/history': (context) => ChangeNotifierProvider(
                create: (ctx) =>
                    HistoryViewModel(gameRepository: ctx.read()),
                child: const HistoryView(),
              ),
          '/players': (context) => ChangeNotifierProvider(
                create: (ctx) =>
                    PlayersViewModel(playerRepository: ctx.read()),
                child: const PlayersView(),
              ),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/score') {
            final gameId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (ctx) => ScoreViewModel(
                  gameId: gameId,
                  gameRepository: ctx.read(),
                  playerRepository: ctx.read(),
                  calculateScoreUseCase: ctx.read(),
                ),
                child: const ScoreView(),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    const bgColor = Color(0xFF2C343C);
    const surfaceColor = Color(0xFF37414A);
    const primaryColor = Color(0xFF66BB6A);

    return base.copyWith(
      scaffoldBackgroundColor: bgColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F262D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      colorScheme: base.colorScheme.copyWith(
        surface: surfaceColor,
        primary: primaryColor,
        onSurface: Colors.white,
        background: bgColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
