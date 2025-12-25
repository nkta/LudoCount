import 'package:flutter/material.dart';

class FormulaToolbar extends StatefulWidget {
  final TextEditingController? controller;
  final List<String> variables;

  const FormulaToolbar({
    super.key,
    this.controller,
    this.variables = const [],
  });

  @override
  State<FormulaToolbar> createState() => _FormulaToolbarState();
}

class _FormulaToolbarState extends State<FormulaToolbar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final logicSymbols = [
    '==', '!=', '>', '<', '>=', '<=',
    '&&', '||', '!',
    '?', ':',
    '(', ')',
  ];

  final mathSymbols = [
    '+', '-', '*', '/', '%',
    'abs()', 'max()', 'min()', 'pow()', 'sqrt()',
    'floor()', 'ceil()', 'rnd()', 'sign()', 'clamp()'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    if (widget.controller == null) return;

    final currentText = widget.controller!.text;
    final selection = widget.controller!.selection;

    if (selection.start < 0) {
      widget.controller!.text = currentText + text;
      widget.controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller!.text.length),
      );
    } else {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      widget.controller!.text = newText;
      widget.controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: selection.start + text.length),
      );
    }
  }

  Widget _buildButton(String label, {bool isFunction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: widget.controller == null
            ? null
            : () {
                if (isFunction && label.endsWith('()')) {
                  _insertText(label);
                   if (widget.controller != null) {
                      final pos = widget.controller!.selection.baseOffset;
                      widget.controller!.selection = TextSelection.fromPosition(TextPosition(offset: pos - 1));
                   }
                } else {
                  _insertText(' $label ');
                }
              },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(40, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          visualDensity: VisualDensity.compact,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildList(List<String> items) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return _buildButton(items[index], isFunction: items[index].endsWith('()'));
        },
      );
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // Increased height to accommodate tabs + buttons
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: const [
                Tab(text: 'Variables'),
                Tab(text: 'Logique'),
                Tab(text: 'Maths'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swipe to avoid conflict with horizontal list
                children: [
                   // Variables Tab
                   widget.variables.isEmpty 
                    ? const Center(child: Text('Aucune variable', style: TextStyle(color: Colors.grey, fontSize: 12)))
                    : _buildList(widget.variables),
                   // Logic Tab
                   _buildList(logicSymbols),
                   // Math Tab
                   _buildList(mathSymbols),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
