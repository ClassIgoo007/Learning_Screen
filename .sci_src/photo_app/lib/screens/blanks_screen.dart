import 'package:flutter/material.dart';

import '../logic/controllers.dart';
import '../models/content.dart';
import '../widgets/common.dart';
import '../widgets/diagram_view.dart';

/// Screen 2 — sentences with blanks the learner types into.
class BlanksScreen extends StatefulWidget {
  const BlanksScreen({super.key});

  @override
  State<BlanksScreen> createState() => _BlanksScreenState();
}

class _BlanksScreenState extends State<BlanksScreen> {
  final BlanksController _controller = BlanksController(kBlankItems);
  late final List<TextEditingController> _fields = List.generate(
    kBlankItems.length,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _resetAll() {
    for (final f in _fields) {
      f.clear();
    }
    _controller.reset();
  }

  void _reveal(int index) {
    _controller.revealAnswer(index);
    _fields[index].text = _controller.answerFor(index);
  }

  void _check() {
    FocusScope.of(context).unfocus(); // hide the keyboard before scoring
    _controller.check();
    final missing = _controller.total - _controller.filledCount;
    if (missing > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$missing blank(s) still empty — that is fine, '
            'the filled ones were checked.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: const Text('Fill in the Blanks'),
        actions: [
          IconButton(
            tooltip: 'Start over',
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const EquationBanner(),
              const SizedBox(height: 12),
              const CollapsibleDiagram(),
              const SizedBox(height: 14),
              const Text(
                'Write the missing word in each sentence. Spelling counts, '
                'but capital letters do not — and CO₂ or "carbon dioxide" '
                'both work.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              const WordBankStrip(),
              const SizedBox(height: 14),
              for (var i = 0; i < _controller.total; i++)
                _BlankCard(
                  number: i + 1,
                  item: _controller.items[i],
                  field: _fields[i],
                  checked: _controller.checked,
                  correct: _controller.isCorrect(i),
                  filled: _controller.isFilled(i),
                  hintShown: _controller.isHintShown(i),
                  onChanged: (v) => _controller.setAnswer(i, v),
                  onHint: () => _controller.toggleHint(i),
                  onReveal: () => _reveal(i),
                ),
              if (_controller.checked) ...[
                const SizedBox(height: 6),
                ScoreCard(
                  score: _controller.score,
                  total: _controller.total,
                  label: _controller.allCorrect
                      ? 'Perfect! Every sentence is right.'
                      : 'Your score',
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kGreen),
                    onPressed:
                        _controller.filledCount == 0 ? null : _check,
                    icon: const Icon(Icons.check),
                    label: Text(
                        'Check (${_controller.filledCount}/${_controller.total})'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetAll,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlankCard extends StatelessWidget {
  const _BlankCard({
    required this.number,
    required this.item,
    required this.field,
    required this.checked,
    required this.correct,
    required this.filled,
    required this.hintShown,
    required this.onChanged,
    required this.onHint,
    required this.onReveal,
  });

  final int number;
  final BlankItem item;
  final TextEditingController field;
  final bool checked;
  final bool correct;
  final bool filled;
  final bool hintShown;
  final ValueChanged<String> onChanged;
  final VoidCallback onHint;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final showRight = checked && filled && correct;
    final showWrong = checked && filled && !correct;

    Color borderColor = Colors.black26;
    if (showRight) borderColor = kGreen;
    if (showWrong) borderColor = Colors.red.shade400;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kGreen.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: kGreen,
                  child: Text('$number',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: item.before),
                      const TextSpan(
                        text: '_______',
                        style: TextStyle(
                            color: kGreenDark, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: item.after),
                    ]),
                    style: const TextStyle(fontSize: 16, height: 1.35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: field,
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Type your answer',
                filled: true,
                fillColor: showRight
                    ? const Color(0xFFE8F5E9)
                    : showWrong
                        ? const Color(0xFFFFEBEE)
                        : Colors.white,
                suffixIcon: checked && filled
                    ? Icon(
                        correct
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: correct ? kGreenDark : Colors.red.shade600,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1.4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kGreen, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onHint,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: Text(hintShown ? 'Hide hint' : 'Hint'),
                ),
                const Spacer(),
                if (showWrong)
                  TextButton.icon(
                    onPressed: onReveal,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Show answer'),
                  ),
              ],
            ),
            if (hintShown)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(item.hint,
                    style: const TextStyle(fontSize: 13.5)),
              ),
          ],
        ),
      ),
    );
  }
}
