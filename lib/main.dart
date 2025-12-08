import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'models/game_preset.dart';

import 'models/game.dart';
import 'models/player.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'screens/game_config_screen.dart';
import 'screens/score_screen.dart';
import 'screens/history_screen.dart';
import 'screens/player_list_screen.dart';
import 'screens/preset_screen.dart';
import 'utils/preset_seeder.dart';

void main() async {
  // Initialisation de Hive
  await Hive.initFlutter();
  
  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  // Enregistrement des Adapters (Générés par build_runner)
  Hive.registerAdapter(GamePresetAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(GameTypeAdapter());
  Hive.registerAdapter(ScoreFieldDefinitionAdapter());
  Hive.registerAdapter(ScoringRuleAdapter());

  // Ouverture des boîtes
  await Hive.openBox<GamePreset>('presets');
  await Hive.openBox<Player>('players');
  await Hive.openBox<Game>('games');

  // Seeding
  final gameProvider = GameProvider();
  await PresetSeeder.seedAkropolis(gameProvider);
  await PresetSeeder.seedLuz(gameProvider);


  runApp(const LudoCountApp());
}

class LudoCountApp extends StatelessWidget {
  const LudoCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
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
          '/': (context) => const HomeScreen(),
          '/config': (context) => const GameConfigScreen(),
          '/presets': (context) => const PresetScreen(),
          '/history': (context) => const HistoryScreen(),
          '/players': (context) => const PlayerListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/score') {
            final args = settings.arguments as String; // gameId
            return MaterialPageRoute(
              builder: (context) => ScoreScreen(gameId: args),
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
    const primaryColor =
        Color(0xFF66BB6A); // Utiliser le vert comme primaire par défaut

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
