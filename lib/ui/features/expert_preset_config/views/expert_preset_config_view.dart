import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ludocount/l10n/app_localizations.dart';
import 'package:ludocount/ui/core/widgets/formula_toolbar.dart';
import 'package:ludocount/ui/core/widgets/scoring_rule_editor.dart';
import 'package:ludocount/ui/features/expert_preset_config/view_models/expert_preset_config_view_model.dart';

class ExpertPresetConfigView extends StatefulWidget {
  const ExpertPresetConfigView({super.key});

  @override
  State<ExpertPresetConfigView> createState() =>
      _ExpertPresetConfigViewState();
}

class _ExpertPresetConfigViewState extends State<ExpertPresetConfigView> {
  final _titleController = TextEditingController();
  final _formulaController = TextEditingController();
  final _roundsController = TextEditingController();
  final _minPlayersController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _roundLabelsController = TextEditingController();
  final _fieldKeyController = TextEditingController();
  final _fieldLabelController = TextEditingController();

  final FocusNode _simpleFormulaFocus = FocusNode();
  TextEditingController? _activeController;
  bool _showToolbar = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _simpleFormulaFocus.addListener(() {
      if (_simpleFormulaFocus.hasFocus) {
        setState(() => _activeController = _formulaController);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final vm = context.read<ExpertPresetConfigViewModel>();
    if (vm.initialRoundLabels != null) {
      _roundLabelsController.text = vm.initialRoundLabels!.join('\n');
    }
    if (vm.targetRounds != null) {
      _roundsController.text = vm.targetRounds.toString();
    }
    if (vm.minPlayers != null) {
      _minPlayersController.text = vm.minPlayers.toString();
    }
    if (vm.maxPlayers != null) {
      _maxPlayersController.text = vm.maxPlayers.toString();
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
      setState(() => _activeController = controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<ExpertPresetConfigViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Expert'),
        actions: [
          IconButton(
            icon: Icon(
                _showToolbar ? Icons.keyboard_hide : Icons.keyboard),
            tooltip: _showToolbar
                ? 'Masquer les opérateurs'
                : 'Afficher les opérateurs',
            onPressed: () => setState(() => _showToolbar = !_showToolbar),
          ),
          IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialog),
        ],
      ),
      body: Column(
        children: [
          if (_showToolbar)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: FormulaToolbar(
                controller: _activeController ?? _formulaController,
                variables: [
                  'index',
                  'round',
                  'playerCount',
                  ...vm.fields.map((f) => f.key),
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
                    decoration:
                        InputDecoration(labelText: l10n.presetNameLabel),
                  ),
                  const SizedBox(height: 20),

                  const Text('Champs de saisie',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                            hintText: "Affiché à l'écran",
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          final key = _fieldKeyController.text.trim();
                          final label = _fieldLabelController.text.trim();
                          if (key.isEmpty || label.isEmpty) return;
                          if (vm.fields.any((f) => f.key == key)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Cette clé existe déjà')),
                            );
                            return;
                          }
                          vm.addField(key, label);
                          _fieldKeyController.clear();
                          _fieldLabelController.clear();
                        },
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: vm.addDefaultFields,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text(
                        'Ajouter variables par défaut (Pari/Plis)'),
                  ),
                  const SizedBox(height: 8),
                  if (vm.fields.isEmpty)
                    const Text('Aucun champ défini',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey))
                  else
                    ...vm.fields.asMap().entries.map((entry) => ListTile(
                          dense: true,
                          title: Text(
                              '${entry.value.label} (${entry.value.key})'),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => vm.removeField(entry.key),
                          ),
                        )),

                  const SizedBox(height: 20),
                  const Text('Calcul du Score',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Utiliser des règles conditionnelles'),
                    subtitle: const Text(
                        'Permet de définir plusieurs cas (Si... Alors...)'),
                    value: vm.useConditionalRules,
                    onChanged: vm.setUseConditionalRules,
                  ),

                  if (!vm.useConditionalRules) ...[
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
                        hintText:
                            'Ex: bid == tricks ? (bid == 0 ? 10 : bid * 20) : (bid == 0 ? -10 : abs(tricks - bid) * -10)',
                      ),
                      maxLines: 3,
                      onTap: () => _handleFocus(_formulaController),
                    ),
                  ] else ...[
                    const Text(
                      "Les règles sont évaluées dans l'ordre. La première condition vraie détermine le score.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ...vm.rules.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final rule = entry.value;
                      return ScoringRuleEditor(
                        key: ValueKey(rule.id),
                        rule: rule,
                        index: idx,
                        isRoot: true,
                        onFocus: _handleFocus,
                        onChanged: (newRule) => vm.updateRule(idx, newRule),
                        onDelete: () => vm.removeRule(idx),
                      );
                    }),
                    ElevatedButton.icon(
                      onPressed: vm.addRule,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une règle principale'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Astuce: Ajoutez une dernière règle avec condition "true" pour le cas par défaut.',
                      style: TextStyle(
                          fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],

                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: vm.isInverseScore,
                    onChanged: vm.setIsInverseScore,
                    title: Text(l10n.inverseScoring),
                  ),
                  TextField(
                    controller: _roundsController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        vm.targetRounds = int.tryParse(val),
                    decoration:
                        InputDecoration(labelText: l10n.maxRoundsLabel),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPlayersController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) =>
                              vm.minPlayers = int.tryParse(val),
                          decoration: const InputDecoration(
                              labelText: 'Joueurs Min'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPlayersController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) =>
                              vm.maxPlayers = int.tryParse(val),
                          decoration: const InputDecoration(
                              labelText: 'Joueurs Max'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: vm.useCustomRoundLabels,
                    onChanged: vm.setUseCustomRoundLabels,
                    title: const Text(
                        'Utiliser des noms de tours personnalisés'),
                    subtitle: const Text(
                        'Si désactivé, utilise "Tour 1", "Tour 2"...'),
                  ),
                  if (vm.useCustomRoundLabels) ...[
                    const SizedBox(height: 8),
                    const Text('Noms des lignes',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Un nom par ligne.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey)),
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
                    onPressed: () => _save(context, vm, l10n),
                    child: Text(vm.initialRoundLabels != null ||
                            vm.fields.isNotEmpty
                        ? l10n.save
                        : l10n.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    ExpertPresetConfigViewModel vm,
    AppLocalizations l10n,
  ) async {
    final title = _titleController.text.trim();
    final formula = _formulaController.text.trim();

    if (title.isEmpty || vm.fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez remplir le titre et les champs')));
      return;
    }
    if (!vm.useConditionalRules && formula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez saisir une formule')));
      return;
    }
    if (vm.useConditionalRules && vm.rules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez ajouter au moins une règle')));
      return;
    }

    List<String>? roundLabels;
    if (vm.useCustomRoundLabels) {
      final labelsText = _roundLabelsController.text.trim();
      if (labelsText.isNotEmpty) {
        roundLabels = labelsText
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    await vm.save(title: title, formula: formula, roundLabels: roundLabels);
    if (mounted) Navigator.pop(context);
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
              Text(
                  'Le mode expert vous permet de créer des jeux avec des règles de score personnalisées.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('1. Champs de saisie',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Définissez les variables que vous saisirez à chaque tour.'),
              SizedBox(height: 8),
              Text('Variables prédéfinies:',
                  style: TextStyle(fontStyle: FontStyle.italic)),
              Text(
                  '- round: Numéro du tour actuel (1, 2, 3...)\n- index: Index du tour actuel (0, 1, 2...)\n- playerCount: Nombre de joueurs dans la partie'),
              SizedBox(height: 8),
              Text('2. Formules',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'Utilisez ces variables pour calculer le score. Opérateurs (+, -, *, /) et fonctions mathématiques disponibles.'),
              SizedBox(height: 4),
              Text('Fonctions disponibles:',
                  style: TextStyle(fontStyle: FontStyle.italic)),
              Text(
                  '- abs(x): Valeur absolue\n- max(a,b), min(a,b)\n- pow(x,y): Puissance\n- sqrt(x): Racine carrée\n- rnd(x), ceil(x), floor(x)\n- if/else via ternaire: condition ? valeur_si_vrai : valeur_si_faux'),
              SizedBox(height: 8),
              Text('3. Règles conditionnelles',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  "Pour des cas complexes, définissez plusieurs règles. Le système évaluera les conditions dans l'ordre."),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer')),
        ],
      ),
    );
  }
}
