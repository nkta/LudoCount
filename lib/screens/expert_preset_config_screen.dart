import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_preset.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../widgets/scoring_rule_editor.dart';
import '../widgets/formula_toolbar.dart';
class ExpertPresetConfigScreen extends StatefulWidget {
  final GamePreset? preset;
  const ExpertPresetConfigScreen({super.key, this.preset});

  @override
  State<ExpertPresetConfigScreen> createState() => _ExpertPresetConfigScreenState();
}

class _ExpertPresetConfigScreenState extends State<ExpertPresetConfigScreen> {
  final _titleController = TextEditingController();
  final _formulaController = TextEditingController();
  final List<ScoringRule> _rules = [];
  bool _useConditionalRules = false;
  
  final List<ScoreFieldDefinition> _fields = [];
  final _roundsController = TextEditingController();
  final _minPlayersController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _roundLabelsController = TextEditingController();
  bool _isInverseScore = false;
  bool _useCustomRoundLabels = false;

  final _fieldKeyController = TextEditingController();
  final _fieldLabelController = TextEditingController();


  TextEditingController? _activeController;
  final FocusNode _simpleFormulaFocus = FocusNode();
  bool _showToolbar = true;
  @override
  void initState() {
    super.initState();
    _simpleFormulaFocus.addListener(() {
      if (_simpleFormulaFocus.hasFocus) {
        setState(() => _activeController = _formulaController);
      }
    });
    if (widget.preset != null) {
      final p = widget.preset!;
      _titleController.text = p.title;
      _isInverseScore = p.isInverseScore;
      if (p.targetRounds != null) {
        _roundsController.text = p.targetRounds.toString();
      }
      if (p.minPlayers != null) {
        _minPlayersController.text = p.minPlayers.toString();
      }
      if (p.maxPlayers != null) {
        _maxPlayersController.text = p.maxPlayers.toString();
      }
      if (p.fields != null) {
        _fields.addAll(p.fields!);
      }
      if (p.scoreFormula != null) {
        _formulaController.text = p.scoreFormula!;
      }
      if (p.scoringRules != null && p.scoringRules!.isNotEmpty) {
        _rules.addAll(p.scoringRules!);
        _useConditionalRules = true;
      }
      if (p.roundLabels != null && p.roundLabels!.isNotEmpty) {
        _roundLabelsController.text = p.roundLabels!.join('\n');
        _useCustomRoundLabels = true;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _formulaController.dispose();
    _roundsController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    _roundLabelsController.dispose();
    _fieldKeyController.dispose();
    _fieldLabelController.dispose();
    _simpleFormulaFocus.dispose();
    super.dispose();
  }
  
  void _handleFocus(TextEditingController controller) {
    if (_activeController != controller) {
      setState(() {
        _activeController = controller;
      });
    }
  }

  void _addField() {
    final key = _fieldKeyController.text.trim();
    final label = _fieldLabelController.text.trim();
    if (key.isNotEmpty && label.isNotEmpty) {
      if (_fields.any((f) => f.key == key)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cette clé existe déjà')),
        );
        return;
      }
      setState(() {
        _fields.add(ScoreFieldDefinition(key: key, label: label));
        _fieldKeyController.clear();
        _fieldLabelController.clear();
      });
    }
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _addRule() {
    setState(() {
      _rules.add(ScoringRule(condition: '', formula: ''));
    });
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  void _addDefaultFields() {
    setState(() {
      if (!_fields.any((f) => f.key == 'bid')) {
        _fields.add(ScoreFieldDefinition(key: 'bid', label: 'Pari'));
      }
      if (!_fields.any((f) => f.key == 'tricks')) {
        _fields.add(ScoreFieldDefinition(key: 'tricks', label: 'Plis'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Expert'),
        actions: [
          IconButton(
            icon: Icon(_showToolbar ? Icons.keyboard_hide : Icons.keyboard),
            tooltip: _showToolbar ? 'Masquer les opérateurs' : 'Afficher les opérateurs',
            onPressed: () => setState(() => _showToolbar = !_showToolbar),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showToolbar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FormulaToolbar(
                controller: _activeController ?? _formulaController,
                variables: [
                  'index', 
                  'round', 
                  'playerCount',
                  ..._fields.map((f) => f.key),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.presetNameLabel),
                  ),
            const SizedBox(height: 20),
            
            const Text('Champs de saisie', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fieldKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Clé (ex: bid)',
                      hintText: 'Variable pour la formule',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fieldLabelController,
                    decoration: const InputDecoration(
                      labelText: 'Label (ex: Pari)',
                      hintText: 'Affiché à l\'écran',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addField,
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _addDefaultFields,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Ajouter variables par défaut (Pari/Plis)'),
            ),
            const SizedBox(height: 8),
            if (_fields.isEmpty)
              const Text('Aucun champ défini', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            ..._fields.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return ListTile(
                dense: true,
                title: Text('${field.label} (${field.key})'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeField(index),
                ),
              );
            }),

            const SizedBox(height: 20),
            const Text('Calcul du Score', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Utiliser des règles conditionnelles'),
              subtitle: const Text('Permet de définir plusieurs cas (Si... Alors...)'),
              value: _useConditionalRules,
              onChanged: (val) => setState(() => _useConditionalRules = val),
            ),
            
            if (!_useConditionalRules) ...[
              const Text(
                'Formule unique. Var: round, index. Fonctions: abs, min, max, pow, sqrt, ceil, floor, rnd, sign, clamp.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _formulaController,
                focusNode: _simpleFormulaFocus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ex: bid == tricks ? (bid == 0 ? 10 : bid * 20) : (bid == 0 ? -10 : abs(tricks - bid) * -10)',
                ),
                maxLines: 3,
                onTap: () => _handleFocus(_formulaController),
              ),
            ] else ...[
              const Text(
                'Les règles sont évaluées dans l\'ordre. La première condition vraie détermine le score.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ..._rules.asMap().entries.map((entry) {
                final index = entry.key;
                final rule = entry.value;
                return ScoringRuleEditor(
                  key: ValueKey(rule.id),
                  rule: rule,
                  index: index,
                  isRoot: true,
                  onFocus: _handleFocus,
                  onChanged: (newRule) {
                    setState(() {
                      _rules[index] = newRule;
                    });
                  },
                  onDelete: () => _removeRule(index),
                );
              }),
              ElevatedButton.icon(
                onPressed: _addRule,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une règle principale'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Astuce: Ajoutez une dernière règle avec condition "true" pour le cas par défaut (Sinon...).',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],

            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isInverseScore,
              onChanged: (val) => setState(() => _isInverseScore = val),
              title: Text(l10n.inverseScoring),
            ),
            TextField(
              controller: _roundsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.maxRoundsLabel,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPlayersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Joueurs Min',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPlayersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Joueurs Max',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _useCustomRoundLabels,
              onChanged: (val) => setState(() => _useCustomRoundLabels = val),
              title: const Text('Utiliser des noms de tours personnalisés'),
              subtitle: const Text('Si désactivé, utilise "Tour 1", "Tour 2"...'),
            ),
            if (_useCustomRoundLabels) ...[
              const SizedBox(height: 8),
              const Text('Noms des lignes', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text(
                'Un nom par ligne.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _roundLabelsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Bleu\nJaune\nRouge...',
                ),
                maxLines: 5,
              ),
            ],

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final formula = _formulaController.text.trim();
                
                if (title.isEmpty || _fields.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir le titre et les champs')),
                  );
                  return;
                }

                if (!_useConditionalRules && formula.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez saisir une formule')),
                  );
                  return;
                }

                if (_useConditionalRules && _rules.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez ajouter au moins une règle')),
                  );
                  return;
                }

                List<String>? roundLabels;
                if (_useCustomRoundLabels) {
                  final labelsText = _roundLabelsController.text.trim();
                  if (labelsText.isNotEmpty) {
                    roundLabels = labelsText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  }
                }

                final newPreset = GamePreset(
                  id: widget.preset?.id ?? const Uuid().v4(),
                  title: title,
                  isInverseScore: _isInverseScore,
                  targetRounds: int.tryParse(_roundsController.text),
                  fields: _fields,
                  scoreFormula: _useConditionalRules ? null : formula,
                  scoringRules: _useConditionalRules ? _rules : null,
                  roundLabels: roundLabels,
                  isCustom: true,
                  type: widget.preset?.type ?? GameType.standard,
                  minPlayers: int.tryParse(_minPlayersController.text),
                  maxPlayers: int.tryParse(_maxPlayersController.text),
                );

                Provider.of<GameProvider>(context, listen: false).savePreset(newPreset);
                Navigator.pop(context);
              },
              child: Text(widget.preset != null ? l10n.save : l10n.add),
            ),
          ],
        ),
      ),
            ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aide Mode Expert'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Le mode expert vous permet de créer des jeux avec des règles de score personnalisées.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('1. Champs de saisie', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Définissez les variables que vous saisirez à chaque tour (ex: "bid" pour pari, "tricks" pour plis).'),
              SizedBox(height: 8),
              Text('Variables prédéfinies:', style: TextStyle(fontStyle: FontStyle.italic)),
              Text('- round: Numéro du tour actuel (1, 2, 3...)\n- index: Index du tour actuel (0, 1, 2...)\n- playerCount: Nombre de joueurs dans la partie'),
              SizedBox(height: 8),
              Text('2. Formules', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Utilisez ces variables pour calculer le score. Vous pouvez utiliser des opérateurs (+, -, *, /) et des fonctions mathématiques.'),
              SizedBox(height: 4),
              Text('Fonctions disponibles:', style: TextStyle(fontStyle: FontStyle.italic)),
              Text('- abs(x): Valeur absolue\n- max(a,b), min(a,b)\n- pow(x,y): Puissance\n- sqrt(x): Racine carrée\n- rnd(x), ceil(x), floor(x)\n- if/else via condition ternaire: condition ? valeur_si_vrai : valeur_si_faux'),
              SizedBox(height: 8),
              Text('3. Règles conditionnelles', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Pour des cas complexes, définissez plusieurs règles. Le système évaluera les conditions dans l\'ordre et appliquera la formule de la première condition vraie.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
