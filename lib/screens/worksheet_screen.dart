import 'package:flutter/material.dart';

import '../models/worksheet.dart';
import '../services/openai_service.dart';
import '../widgets/pronunciation_key_card.dart';

class WorksheetScreen extends StatefulWidget {
  const WorksheetScreen({super.key, required this.openAI});

  final OpenAIService openAI;

  @override
  State<WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends State<WorksheetScreen> {
  Worksheet _worksheet = kDefaultWorksheet;

  /// index -> word the student picked
  final Map<int, String> _selections = {};
  bool _checked = false;
  bool _generating = false;

  int get _score => _worksheet.questions.indexed
      .where((e) => _selections[e.$1] == e.$2.answer)
      .length;

  // ---------- actions ----------

  void _select(int index, String word) {
    if (_checked) return;
    setState(() => _selections[index] = word);
  }

  void _checkAnswers() {
    if (_selections.length < _worksheet.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fill in every blank before checking!')));
      return;
    }
    setState(() => _checked = true);
  }

  void _reset() => setState(() {
        _selections.clear();
        _checked = false;
      });

  Future<void> _generateNewWorksheet() async {
    final theme = await _askForTheme();
    if (theme == null) return; // dialog dismissed

    setState(() => _generating = true);
    try {
      final ws = await widget.openAI
          .generateWorksheet(theme: theme.isEmpty ? null : theme);
      setState(() {
        _worksheet = ws;
        _selections.clear();
        _checked = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate a new worksheet: $e')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<String?> _askForTheme() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New AI worksheet'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Optional theme (e.g. animals, space)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3), // workbook-paper tone
      appBar: AppBar(
        title: Text(_worksheet.title),
        backgroundColor: const Color(0xFFD6336C),
        foregroundColor: Colors.white,
      ),
      body: _generating
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Asking AI for a new worksheet…'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const PronunciationKeyCard(),
                const SizedBox(height: 16),
                const Text(
                  'Look at each phonetic spelling. Use the pronunciation '
                  'key to decide which of the three words it spells. '
                  'Tap the word to fill in the blank.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                for (final (i, q) in _worksheet.questions.indexed)
                  _QuestionTile(
                    number: i + 1,
                    question: q,
                    selected: _selections[i],
                    checked: _checked,
                    onSelect: (w) => _select(i, w),
                  ),
                const SizedBox(height: 8),
                if (_checked)
                  Card(
                    color: const Color(0xFFF9D5E0),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Score: $_score / ${_worksheet.questions.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: _generating
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _checked ? _reset : _checkAnswers,
                        icon: Icon(_checked ? Icons.refresh : Icons.check),
                        label: Text(_checked ? 'Try again' : 'Check answers'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD6336C)),
                        onPressed: _generateNewWorksheet,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('New AI worksheet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.number,
    required this.question,
    required this.selected,
    required this.checked,
    required this.onSelect,
  });

  final int number;
  final PhoneticQuestion question;
  final String? selected;
  final bool checked;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isCorrect = checked && selected == question.answer;
    final isWrong = checked && selected != null && !isCorrect;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$number. ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(question.phonetic,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 16)),
                const SizedBox(width: 12),
                // The "blank" being filled in
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 2),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: Colors.black87, width: 1.5)),
                    ),
                    child: Text(
                      selected ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: isCorrect
                            ? Colors.green.shade700
                            : isWrong
                                ? Colors.red.shade700
                                : Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (checked)
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final word in question.choices)
                  ChoiceChip(
                    label: Text(word),
                    selected: selected == word,
                    selectedColor: const Color(0xFFF9D5E0),
                    onSelected: (_) => onSelect(word),
                  ),
              ],
            ),
            if (checked && isWrong)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Answer: ${question.answer}',
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
