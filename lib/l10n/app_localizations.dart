import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('es'),
    Locale('de'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'appTitle': 'LudoCount',
      'presets': 'Presets',
      'usePreset': 'Utiliser ce preset',
      'continue': 'CONTINUER',
      'newGame': 'NOUVELLE PARTIE',
      'history': 'HISTORIQUE',
      'players': 'JOUEURS',
      'noRecentGame': 'Aucune partie récente trouvée.',
      'newGameTitle': 'Nouvelle Partie',
      'gameTitleLabel': 'Titre de la partie (Optionnel)',
      'gameTitleHint': 'Soirée Jeux...',
      'defaultGameTitle': 'Partie du {date}',
      'selectPlayers': 'Sélectionnez les joueurs',
      'quickSelectDefaults': 'Sélectionner les joueurs par défaut ({count})',
      'noPlayers': 'Aucun joueur disponible.',
      'createPlayers': 'Créer des joueurs',
      'defaultPlayer': 'Sélection par défaut',
      'markAsDefault': 'Marquer comme joueur par défaut',
      'defaultBadge': 'Par défaut',
      'clearDefaults': 'Désélectionner tous les joueurs par défaut',
      'presetClassic': 'Classique 500 points',
      'presetClassicDesc': 'Mode standard, limite de score à 500.',
      'presetInverse': 'Inverse 100 points',
      'presetInverseDesc': 'Le plus bas gagne, partie jusqu’à 100.',
      'presetRounds': '10 tours',
      'presetRoundsDesc': 'Score standard, partie limitée à 10 tours.',
      'newPreset': 'Nouveau preset',
      'presetNameLabel': 'Nom du preset',
      'noPresets': 'Aucun preset enregistré.',
      'options': 'Options',
      'inverseScoring': 'Marquage inversé (le plus bas gagne)',
      'inverseScoringSubtitle': 'Ex: Golf, Skyjo...',
      'maxScoreLabel': 'Score Max',
      'maxScoreHint': 'Ex: 500',
      'maxRoundsLabel': 'Tours Max',
      'maxRoundsHint': 'Ex: 10',
      'startGame': 'LANCER LA PARTIE',
      'playerListTitle': 'Liste des Joueurs',
      'noSavedPlayers': 'Aucun joueur enregistré.',
      'newPlayer': 'Nouveau Joueur',
      'name': 'Nom',
      'cancel': 'Annuler',
      'add': 'Ajouter',
      'deletePlayerTitle': 'Supprimer le joueur ?',
      'deletePlayerMessage': 'Voulez-vous vraiment supprimer {name} ?',
      'delete': 'Supprimer',
      'gameNotFound': 'Partie introuvable',
      'noPlayersInGame': 'Aucun joueur dans cette partie.',
      'addRound': 'AJOUTER UN TOUR',
      'finishGame': 'TERMINER LA PARTIE',
      'gameFinished': 'PARTIE TERMINÉE',
      'newRound': 'Nouveau Tour',
      'editScore': 'Modifier le score',
      'validate': 'Valider',
      'finishGameTitle': 'Terminer la partie ?',
      'finishGameMessage':
          'Cela verrouillera les scores. Voulez-vous continuer ?',
      'finish': 'Terminer',
      'finalResults': 'Résultats Finaux',
      'ranking': 'Classement',
      'autoLimitReached': 'Une limite de la partie a été atteinte !',
      'leave': 'Quitter',
      'ok': 'OK',
      'viewGrid': 'Voir la grille',
      'modeStandard': 'Standard',
      'modeInverse': 'Score Inversé (Golf)',
      'dateLabel': 'Date:',
      'modeLabel': 'Mode:',
      'maxScoreLabelInfo': 'Score Max:',
      'maxRoundsLabelInfo': 'Tours Max:',
      'pointsSuffix': 'pts',
      'historyTitle': 'Historique des parties',
      'noGamesRecorded': 'Aucune partie enregistrée.',
      'playersCount': '{count} Joueurs',
      'deleteGameTitle': 'Supprimer la partie ?',
      'deleteGameContent': 'Cette action est irréversible.',
      'round': 'Tour',
      'save': 'Enregistrer',
      'diceRoller': 'Lancer de dés',
      'numberOfDice': 'Nombre de dés',
      'rollDice': 'Lancer',
      'total': 'Total',
      'statistics': 'Statistiques',
      'totalGames': 'Parties jouées',
      'totalPlayers': 'Joueurs uniques',
      'mostActivePlayer': 'Joueur le plus actif',
      'bestWinRate': 'Meilleur taux de victoire',
    },
    'en': {
      'appTitle': 'LudoCount',
      'presets': 'Presets',
      'usePreset': 'Use this preset',
      'continue': 'CONTINUE',
      'newGame': 'NEW GAME',
      'history': 'HISTORY',
      'players': 'PLAYERS',
      'noRecentGame': 'No recent game found.',
      'newGameTitle': 'New Game',
      'gameTitleLabel': 'Game title (Optional)',
      'gameTitleHint': 'Game night...',
      'defaultGameTitle': 'Game on {date}',
      'selectPlayers': 'Select players',
      'quickSelectDefaults': 'Select default players ({count})',
      'quickSelectLast': 'Preselect last game\'s {count} players',
      'noPlayers': 'No players available.',
      'createPlayers': 'Create players',
      'defaultPlayer': 'Default selection',
      'markAsDefault': 'Mark as default player',
      'defaultBadge': 'Default',
      'clearDefaults': 'Clear all default players',
      'presetClassic': 'Classic 500 points',
      'presetClassicDesc': 'Standard scoring with a 500-point cap.',
      'presetInverse': 'Inverse 100 points',
      'presetInverseDesc': 'Lowest score wins, up to 100.',
      'presetRounds': '10 rounds',
      'presetRoundsDesc': 'Standard scoring, limited to 10 rounds.',
      'newPreset': 'New preset',
      'presetNameLabel': 'Preset name',
      'noPresets': 'No presets saved.',
      'options': 'Options',
      'inverseScoring': 'Inverse scoring (lowest wins)',
      'inverseScoringSubtitle': 'Ex: Golf, Skyjo...',
      'maxScoreLabel': 'Max Score',
      'maxScoreHint': 'e.g. 500',
      'maxRoundsLabel': 'Max Rounds',
      'maxRoundsHint': 'e.g. 10',
      'startGame': 'START GAME',
      'playerListTitle': 'Players',
      'noSavedPlayers': 'No players saved.',
      'newPlayer': 'New Player',
      'name': 'Name',
      'cancel': 'Cancel',
      'add': 'Add',
      'deletePlayerTitle': 'Delete player?',
      'deletePlayerMessage': 'Do you really want to delete {name}?',
      'delete': 'Delete',
      'gameNotFound': 'Game not found',
      'noPlayersInGame': 'No players in this game.',
      'addRound': 'ADD ROUND',
      'finishGame': 'END GAME',
      'gameFinished': 'GAME FINISHED',
      'newRound': 'New Round',
      'editScore': 'Edit score',
      'validate': 'Save',
      'finishGameTitle': 'Finish the game?',
      'finishGameMessage': 'This will lock scores. Do you want to continue?',
      'finish': 'Finish',
      'finalResults': 'Final Results',
      'ranking': 'Ranking',
      'autoLimitReached': 'A game limit has been reached!',
      'leave': 'Leave',
      'ok': 'OK',
      'viewGrid': 'View grid',
      'modeStandard': 'Standard',
      'modeInverse': 'Inverse score (Golf)',
      'dateLabel': 'Date:',
      'modeLabel': 'Mode:',
      'maxScoreLabelInfo': 'Max score:',
      'maxRoundsLabelInfo': 'Max rounds:',
      'pointsSuffix': 'pts',
      'historyTitle': 'Game history',
      'noGamesRecorded': 'No games recorded.',
      'playersCount': '{count} Players',
      'deleteGameTitle': 'Delete game?',
      'deleteGameContent': 'This action cannot be undone.',
      'round': 'Round',
      'save': 'Save',
      'diceRoller': 'Dice Roller',
      'numberOfDice': 'Number of dice',
      'rollDice': 'Roll',
      'total': 'Total',
      'statistics': 'Statistics',
      'totalGames': 'Games Played',
      'totalPlayers': 'Total Players',
      'mostActivePlayer': 'Most Active Player',
      'bestWinRate': 'Best Win Rate',
    },
    'es': {
      'appTitle': 'LudoCount',
      'presets': 'Presets',
      'usePreset': 'Usar este preset',
      'continue': 'CONTINUAR',
      'newGame': 'NUEVA PARTIDA',
      'history': 'HISTORIAL',
      'players': 'JUGADORES',
      'noRecentGame': 'No se encontró partida reciente.',
      'newGameTitle': 'Nueva partida',
      'gameTitleLabel': 'Título de la partida (Opcional)',
      'gameTitleHint': 'Noche de juegos...',
      'defaultGameTitle': 'Partida del {date}',
      'selectPlayers': 'Seleccione los jugadores',
      'quickSelectDefaults': 'Seleccionar jugadores por defecto ({count})',
      'noPlayers': 'No hay jugadores disponibles.',
      'createPlayers': 'Crear jugadores',
      'defaultPlayer': 'Selección por defecto',
      'markAsDefault': 'Marcar como jugador por defecto',
      'defaultBadge': 'Por defecto',
      'clearDefaults': 'Quitar todos los jugadores por defecto',
      'presetClassic': 'Clásico 500 puntos',
      'presetClassicDesc': 'Puntuación estándar con límite de 500.',
      'presetInverse': 'Inverso 100 puntos',
      'presetInverseDesc': 'Gana el más bajo, hasta 100.',
      'presetRounds': '10 rondas',
      'presetRoundsDesc': 'Puntuación estándar, límite de 10 rondas.',
      'newPreset': 'Nuevo preset',
      'presetNameLabel': 'Nombre del preset',
      'noPresets': 'No hay presets guardados.',
      'options': 'Opciones',
      'inverseScoring': 'Puntuación inversa (gana el menor)',
      'inverseScoringSubtitle': 'Ej.: Golf, Skyjo...',
      'maxScoreLabel': 'Puntuación máx.',
      'maxScoreHint': 'Ej.: 500',
      'maxRoundsLabel': 'Rondas máx.',
      'maxRoundsHint': 'Ej.: 10',
      'startGame': 'INICIAR PARTIDA',
      'playerListTitle': 'Lista de jugadores',
      'noSavedPlayers': 'No hay jugadores guardados.',
      'newPlayer': 'Nuevo jugador',
      'name': 'Nombre',
      'cancel': 'Cancelar',
      'add': 'Añadir',
      'deletePlayerTitle': '¿Eliminar jugador?',
      'deletePlayerMessage': '¿Seguro que quieres eliminar a {name}?',
      'delete': 'Eliminar',
      'gameNotFound': 'Partida no encontrada',
      'noPlayersInGame': 'No hay jugadores en esta partida.',
      'addRound': 'AÑADIR RONDA',
      'finishGame': 'TERMINAR PARTIDA',
      'gameFinished': 'PARTIDA FINALIZADA',
      'newRound': 'Nueva ronda',
      'editScore': 'Editar puntuación',
      'validate': 'Guardar',
      'finishGameTitle': '¿Terminar la partida?',
      'finishGameMessage': 'Se bloquearán las puntuaciones. ¿Continuar?',
      'finish': 'Terminar',
      'finalResults': 'Resultados finales',
      'ranking': 'Clasificación',
      'autoLimitReached': '¡Se alcanzó un límite de la partida!',
      'leave': 'Salir',
      'ok': 'OK',
      'viewGrid': 'Ver tabla',
      'modeStandard': 'Estándar',
      'modeInverse': 'Puntuación inversa (Golf)',
      'dateLabel': 'Fecha:',
      'modeLabel': 'Modo:',
      'maxScoreLabelInfo': 'Puntuación máx.:',
      'maxRoundsLabelInfo': 'Rondas máx.:',
      'pointsSuffix': 'pts',
      'historyTitle': 'Historial de partidas',
      'noGamesRecorded': 'No hay partidas registradas.',
      'playersCount': '{count} Jugadores',
      'deleteGameTitle': '¿Eliminar partida?',
      'deleteGameContent': 'Esta acción no se puede deshacer.',
      'round': 'Ronda',
      'save': 'Guardar',
      'diceRoller': 'Lanzar dados',
      'numberOfDice': 'Número de dados',
      'rollDice': 'Lanzar',
      'total': 'Total',
      'statistics': 'Estadísticas',
      'totalGames': 'Partidas jugadas',
      'totalPlayers': 'Jugadores totales',
      'mostActivePlayer': 'Jugador más activo',
      'bestWinRate': 'Mejor tasa de victoria',
    },
    'de': {
      'appTitle': 'LudoCount',
      'presets': 'Presets',
      'usePreset': 'Diesen Preset nutzen',
      'continue': 'FORTSETZEN',
      'newGame': 'NEUES SPIEL',
      'history': 'VERLAUF',
      'players': 'SPIELER',
      'noRecentGame': 'Keine letzte Partie gefunden.',
      'newGameTitle': 'Neues Spiel',
      'gameTitleLabel': 'Spieltitel (optional)',
      'gameTitleHint': 'Spielabend...',
      'defaultGameTitle': 'Spiel vom {date}',
      'selectPlayers': 'Spieler auswählen',
      'quickSelectDefaults': 'Standardspieler auswählen ({count})',
      'noPlayers': 'Keine Spieler verfügbar.',
      'createPlayers': 'Spieler erstellen',
      'defaultPlayer': 'Standardauswahl',
      'markAsDefault': 'Als Standardspieler markieren',
      'defaultBadge': 'Standard',
      'clearDefaults': 'Alle Standardspieler entfernen',
      'presetClassic': 'Klassisch 500 Punkte',
      'presetClassicDesc': 'Standardwertung mit 500-Punkte-Limit.',
      'presetInverse': 'Inverse 100 Punkte',
      'presetInverseDesc': 'Niedrigster Punktestand gewinnt, bis 100.',
      'presetRounds': '10 Runden',
      'presetRoundsDesc': 'Standardwertung, auf 10 Runden begrenzt.',
      'newPreset': 'Neuer Preset',
      'presetNameLabel': 'Preset-Name',
      'noPresets': 'Keine Presets gespeichert.',
      'options': 'Optionen',
      'inverseScoring': 'Umgekehrte Wertung (niedrig gewinnt)',
      'inverseScoringSubtitle': 'z. B. Golf, Skyjo...',
      'maxScoreLabel': 'Max. Punkte',
      'maxScoreHint': 'z. B. 500',
      'maxRoundsLabel': 'Max. Runden',
      'maxRoundsHint': 'z. B. 10',
      'startGame': 'SPIEL STARTEN',
      'playerListTitle': 'Spielerliste',
      'noSavedPlayers': 'Keine Spieler gespeichert.',
      'newPlayer': 'Neuer Spieler',
      'name': 'Name',
      'cancel': 'Abbrechen',
      'add': 'Hinzufügen',
      'deletePlayerTitle': 'Spieler löschen?',
      'deletePlayerMessage': 'Möchtest du {name} wirklich löschen?',
      'delete': 'Löschen',
      'gameNotFound': 'Partie nicht gefunden',
      'noPlayersInGame': 'Keine Spieler in dieser Partie.',
      'addRound': 'RUNDE HINZUFÜGEN',
      'finishGame': 'SPIEL BEENDEN',
      'gameFinished': 'SPIEL BEENDET',
      'newRound': 'Neue Runde',
      'editScore': 'Punktzahl bearbeiten',
      'validate': 'Speichern',
      'finishGameTitle': 'Spiel beenden?',
      'finishGameMessage': 'Dadurch werden die Punkte gesperrt. Weiter?',
      'finish': 'Beenden',
      'finalResults': 'Endergebnisse',
      'ranking': 'Rangliste',
      'autoLimitReached': 'Ein Limit der Partie wurde erreicht!',
      'leave': 'Verlassen',
      'ok': 'OK',
      'viewGrid': 'Tabelle anzeigen',
      'modeStandard': 'Standard',
      'modeInverse': 'Umgekehrte Punktzahl (Golf)',
      'dateLabel': 'Datum:',
      'modeLabel': 'Modus:',
      'maxScoreLabelInfo': 'Max. Punkte:',
      'maxRoundsLabelInfo': 'Max. Runden:',
      'pointsSuffix': 'Pkt',
      'historyTitle': 'Partienverlauf',
      'noGamesRecorded': 'Keine Partien gespeichert.',
      'playersCount': '{count} Spieler',
      'deleteGameTitle': 'Spiel löschen?',
      'deleteGameContent': 'Diese Aktion kann nicht rückgängig gemacht werden.',
      'round': 'Runde',
      'save': 'Speichern',
      'diceRoller': 'Würfeln',
      'numberOfDice': 'Anzahl der Würfel',
      'rollDice': 'Würfeln',
      'total': 'Gesamt',
      'statistics': 'Statistiken',
      'totalGames': 'Gespielte Spiele',
      'totalPlayers': 'Gesamtspieler',
      'mostActivePlayer': 'Aktivster Spieler',
      'bestWinRate': 'Beste Gewinnrate',
    },
  };

  String _t(String key) {
    final languageCode = locale.languageCode;
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  String get appTitle => _t('appTitle');
  String get presets => _t('presets');
  String get usePreset => _t('usePreset');
  String get continueLabel => _t('continue');
  String get newGame => _t('newGame');
  String get history => _t('history');
  String get players => _t('players');
  String get noRecentGame => _t('noRecentGame');
  String get newGameTitle => _t('newGameTitle');
  String get gameTitleLabel => _t('gameTitleLabel');
  String get gameTitleHint => _t('gameTitleHint');
  String defaultGameTitle(String date) =>
      _t('defaultGameTitle').replaceFirst('{date}', date);
  String get selectPlayers => _t('selectPlayers');
  String quickSelectDefaults(int count) =>
      _t('quickSelectDefaults').replaceFirst('{count}', '$count');
  String get noPlayers => _t('noPlayers');
  String get createPlayers => _t('createPlayers');
  String get defaultPlayer => _t('defaultPlayer');
  String get markAsDefault => _t('markAsDefault');
  String get defaultBadge => _t('defaultBadge');
  String get clearDefaults => _t('clearDefaults');
  String get presetClassic => _t('presetClassic');
  String get presetClassicDesc => _t('presetClassicDesc');
  String get presetInverse => _t('presetInverse');
  String get presetInverseDesc => _t('presetInverseDesc');
  String get presetRounds => _t('presetRounds');
  String get presetRoundsDesc => _t('presetRoundsDesc');
  String get newPreset => _t('newPreset');
  String get presetNameLabel => _t('presetNameLabel');
  String get noPresets => _t('noPresets');
  String get options => _t('options');
  String get inverseScoring => _t('inverseScoring');
  String get inverseScoringSubtitle => _t('inverseScoringSubtitle');
  String get maxScoreLabel => _t('maxScoreLabel');
  String get maxScoreHint => _t('maxScoreHint');
  String get maxRoundsLabel => _t('maxRoundsLabel');
  String get maxRoundsHint => _t('maxRoundsHint');
  String get startGame => _t('startGame');
  String get playerListTitle => _t('playerListTitle');
  String get noSavedPlayers => _t('noSavedPlayers');
  String get newPlayer => _t('newPlayer');
  String get name => _t('name');
  String get cancel => _t('cancel');
  String get add => _t('add');
  String get deletePlayerTitle => _t('deletePlayerTitle');
  String deletePlayerMessage(String name) =>
      _t('deletePlayerMessage').replaceFirst('{name}', name);
  String get delete => _t('delete');
  String get gameNotFound => _t('gameNotFound');
  String get noPlayersInGame => _t('noPlayersInGame');
  String get addRound => _t('addRound');
  String get finishGame => _t('finishGame');
  String get gameFinished => _t('gameFinished');
  String get newRound => _t('newRound');
  String get editScore => _t('editScore');
  String get validate => _t('validate');
  String get finishGameTitle => _t('finishGameTitle');
  String get finishGameMessage => _t('finishGameMessage');
  String get finish => _t('finish');
  String get finalResults => _t('finalResults');
  String get ranking => _t('ranking');
  String get autoLimitReached => _t('autoLimitReached');
  String get leave => _t('leave');
  String get ok => _t('ok');
  String get viewGrid => _t('viewGrid');
  String get modeStandard => _t('modeStandard');
  String get modeInverse => _t('modeInverse');
  String get dateLabel => _t('dateLabel');
  String get modeLabel => _t('modeLabel');
  String get maxScoreLabelInfo => _t('maxScoreLabelInfo');
  String get maxRoundsLabelInfo => _t('maxRoundsLabelInfo');
  String get pointsSuffix => _t('pointsSuffix');
  String get historyTitle => _t('historyTitle');
  String get noGamesRecorded => _t('noGamesRecorded');
  String playersCount(int count) =>
      _t('playersCount').replaceFirst('{count}', '$count');
  String get deleteGameTitle => _t('deleteGameTitle');
  String get deleteGameContent => _t('deleteGameContent');
  String get round => _t('round');
  String get save => _t('save');
  String get diceRoller => _t('diceRoller');
  String get numberOfDice => _t('numberOfDice');
  String get rollDice => _t('rollDice');
  String get total => _t('total');
  String get statistics => _t('statistics');
  String get totalGames => _t('totalGames');
  String get totalPlayers => _t('totalPlayers');
  String get mostActivePlayer => _t('mostActivePlayer');
  String get bestWinRate => _t('bestWinRate');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
