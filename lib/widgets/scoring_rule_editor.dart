import 'package:flutter/material.dart';
import '../models/game_preset.dart';

class ScoringRuleEditor extends StatefulWidget {
  final ScoringRule rule;
  final ValueChanged<ScoringRule> onChanged;
  final VoidCallback onDelete;
  final int index;
  final bool isRoot;

  final ValueChanged<TextEditingController>? onFocus;

  const ScoringRuleEditor({
    super.key,
    required this.rule,
    required this.onChanged,
    required this.onDelete,
    required this.index,
    this.isRoot = false,
    this.onFocus,
  });

  @override
  State<ScoringRuleEditor> createState() => _ScoringRuleEditorState();
}

class _ScoringRuleEditorState extends State<ScoringRuleEditor> {
  late TextEditingController _conditionController;
  late TextEditingController _formulaController;
  final FocusNode _conditionFocus = FocusNode();
  final FocusNode _formulaFocus = FocusNode();
  bool _hasSubRules = false;

  @override
  void initState() {
    super.initState();
    _conditionController = TextEditingController(text: widget.rule.condition);
    _formulaController = TextEditingController(text: widget.rule.formula ?? '');
    _hasSubRules = widget.rule.rules != null;
    
    _conditionFocus.addListener(() {
      if (_conditionFocus.hasFocus) {
        widget.onFocus?.call(_conditionController);
      }
    });
    
    _formulaFocus.addListener(() {
      if (_formulaFocus.hasFocus) {
        widget.onFocus?.call(_formulaController);
      }
    });
  }

  @override
  void didUpdateWidget(ScoringRuleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if field doesn't have focus (user is not typing)
    if (!_conditionFocus.hasFocus && widget.rule.condition != _conditionController.text) {
      _conditionController.value = _conditionController.value.copyWith(
        text: widget.rule.condition,
        selection: TextSelection.collapsed(offset: widget.rule.condition.length),
      );
    }
    if (!_formulaFocus.hasFocus && widget.rule.formula != _formulaController.text && widget.rule.formula != null) {
       _formulaController.value = _formulaController.value.copyWith(
        text: widget.rule.formula!,
        selection: TextSelection.collapsed(offset: widget.rule.formula!.length),
      );
    }
    if ((widget.rule.rules != null) != _hasSubRules) {
        _hasSubRules = widget.rule.rules != null;
    }
  }
  
  @override
  void dispose() {
    _conditionController.dispose();
    _formulaController.dispose();
    _conditionFocus.dispose();
    _formulaFocus.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(ScoringRule(
      id: widget.rule.id,
      condition: _conditionController.text,
      formula: _hasSubRules ? null : _formulaController.text,
      rules: _hasSubRules ? (widget.rule.rules ?? []) : null,
    ));
  }
  
  void _onSubRulesChanged(List<ScoringRule> newRules) {
     widget.onChanged(ScoringRule(
      id: widget.rule.id,
      condition: _conditionController.text,
      formula: null,
      rules: newRules,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: widget.isRoot ? null : Theme.of(context).cardColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: widget.isRoot 
          ? BorderSide.none 
          : BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Si...', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _conditionController,
                    focusNode: _conditionFocus,
                    decoration: const InputDecoration(
                      hintText: 'ex: bid == tricks',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (_) => _notifyChange(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text('Action: '),
                DropdownButton<bool>(
                  value: _hasSubRules,
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Formule')),
                    DropdownMenuItem(value: true, child: Text('Sous-conditions')),
                  ],
                  onChanged: (val) {
                    if (val != null && val != _hasSubRules) {
                      setState(() {
                         _hasSubRules = val;
                      });
                      // If switching to subrules, init with empty list if null
                      if (_hasSubRules && widget.rule.rules == null) {
                          widget.onChanged(ScoringRule(
                            id: widget.rule.id,
                            condition: _conditionController.text,
                            formula: null,
                            rules: [],
                          ));
                      } else if (!_hasSubRules) {
                           widget.onChanged(ScoringRule(
                            id: widget.rule.id,
                            condition: _conditionController.text,
                            formula: _formulaController.text,
                            rules: null,
                          ));
                      }
                    }
                  },
                  isDense: true,
                  underline: Container(),
                ),
              ],
            ),
            if (!_hasSubRules)
              TextField(
                controller: _formulaController,
                focusNode: _formulaFocus,
                decoration: const InputDecoration(
                  labelText: 'Alors Score = ',
                  hintText: 'ex: bid * 20',
                  isDense: true,
                ),
                onChanged: (_) => _notifyChange(),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Column(
                  children: [
                    if (widget.rule.rules != null)
                      ...widget.rule.rules!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subRule = entry.value;
                        return ScoringRuleEditor(
                          key: ValueKey(subRule.id), 
                          index: index,
                          rule: subRule,
                          onFocus: widget.onFocus,
                          onChanged: (updatedRule) {
                            final newRules = List<ScoringRule>.from(widget.rule.rules!);
                            newRules[index] = updatedRule;
                            _onSubRulesChanged(newRules);
                          },
                          onDelete: () {
                             final newRules = List<ScoringRule>.from(widget.rule.rules!);
                            newRules.removeAt(index);
                            _onSubRulesChanged(newRules);
                          },
                        );
                      }).toList(),
                    OutlinedButton.icon(
                      onPressed: () {
                         final newRules = List<ScoringRule>.from(widget.rule.rules ?? []);
                         newRules.add(ScoringRule(condition: '', formula: ''));
                         _onSubRulesChanged(newRules);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter Sous-Condition'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
