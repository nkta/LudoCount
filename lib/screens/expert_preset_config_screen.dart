import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_preset.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';

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
  final _roundLabelsController = TextEditingController();
  bool _isInverseScore = false;
  bool _useCustomRoundLabels = false;

  final _fieldKeyController = TextEditingController();
  final _fieldLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.preset != null) {
      final p = widget.preset!;
      _titleController.text = p.title;
      _isInverseScore = p.isInverseScore;
      if (p.targetRounds != null) {
        _roundsController.text = p.targetRounds.toString();
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
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ex: bid == tricks ? (bid == 0 ? 10 : bid * 20) : (bid == 0 ? -10 : abs(tricks - bid) * -10)',
                ),
                maxLines: 3,
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Règle ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _removeRule(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Condition (Si...)',
                            hintText: 'ex: bid == tricks && round > 1',
                            helperText: 'Opérateurs: ==, !=, >, <, &&, ||. Maths: abs, max...',
                            isDense: true,
                          ),
                          controller: TextEditingController(text: rule.condition)
                            ..selection = TextSelection.fromPosition(TextPosition(offset: rule.condition.length)),
                          onChanged: (val) {
                            // Hack pour mettre à jour l'objet sans redessiner tout le widget tree à chaque caractère
                            // Idéalement on utiliserait des controllers dédiés pour chaque règle
                            _rules[index] = ScoringRule(condition: val, formula: rule.formula);
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Score (Alors...)',
                            hintText: 'ex: bid * 20',
                            helperText: 'Maths: abs, min, max, pow, sqrt, ceil, floor, rnd...',
                            isDense: true,
                          ),
                          controller: TextEditingController(text: rule.formula)
                            ..selection = TextSelection.fromPosition(TextPosition(offset: rule.formula.length)),
                          onChanged: (val) {
                            _rules[index] = ScoringRule(condition: rule.condition, formula: val);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: _addRule,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une règle'),
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
                );

                Provider.of<GameProvider>(context, listen: false).savePreset(newPreset);
                Navigator.pop(context);
              },
              child: Text(widget.preset != null ? l10n.save : l10n.add),
            ),
          ],
        ),
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
              Text('- round: Numéro du tour actuel (1, 2, 3...)\n- index: Index du tour actuel (0, 1, 2...)'),
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
