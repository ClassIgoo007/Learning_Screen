import 'package:flutter/material.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/controllers.dart';
import '../models/science_content.dart';
import '../widgets/chemical_text.dart';
import '../widgets/science_widgets.dart';

/// Fill-in-the-blank: type answers, then press Check to grade.
class ScienceBlanksScreen extends StatefulWidget {
  const ScienceBlanksScreen({
    super.key,
    required this.topic,
    required this.openAI,
  });

  final ScienceTopic topic;
  final OpenAIService openAI;

  @override
  State<ScienceBlanksScreen> createState() => _ScienceBlanksScreenState();
}

class _ScienceBlanksScreenState extends State<ScienceBlanksScreen> {
  late final BlanksController _controller =
      BlanksController(widget.topic.blankItems);
  late List<TextEditingController> _fields = List.generate(
    widget.topic.blankItems.length,
    (_) => TextEditingController(),
  );
  bool _generating = false;

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _rebuildFields(int count) {
    for (final f in _fields) {
      f.dispose();
    }
    _fields = List.generate(count, (_) => TextEditingController());
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
    FocusScope.of(context).unfocus();
    if (_controller.filledCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Type at least one answer, then press Check.')),
      );
      return;
    }
    _controller.check();
    final missing = _controller.total - _controller.filledCount;
    final wrong = _controller.wrongCount;
    if (!mounted) return;
    if (wrong > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.red,
          content: Text(
            wrong == 1
                ? '1 answer is wrong. Look for the red messages below.'
                : '$wrong answers are wrong. Look for the red messages below.',
          ),
        ),
      );
    } else if (missing == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.green,
          content: Text('Nice work — every answer is correct!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '$missing blank(s) still empty — the filled ones were checked.')),
      );
    }
  }

  Future<void> _generateNew() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      final items =
          await widget.openAI.generateScienceBlanks(topic: widget.topic);
      if (!mounted) return;
      _controller.replaceItems(items);
      _rebuildFields(items.length);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Loaded ${items.length} new AI sentences. Type answers, then Check.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate sentences: $e')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    children: [
                      if (topic.blanks.hasPassage)
                        PassageCard(
                          activity: topic.blanks,
                          accent: topic.accent,
                        )
                      else ...[
                        DiagramCard(
                          asset: topic.blanks.diagram,
                          label: topic.blanks.diagramCaption,
                          accent: topic.accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          topic.intro,
                          style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: AppColors.inkSoft),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Text(
                        'Type a word into each blank, then press Check. '
                        'If an answer is wrong, you will see a clear message.',
                        style: TextStyle(fontSize: 14.5, color: AppColors.ink),
                      ),
                      const SizedBox(height: 12),
                      WordBankStrip(
                          words: topic.wordBank, accent: topic.accent),
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
                          accent: topic.accent,
                          onChanged: (v) => _controller.setAnswer(i, v),
                          onHint: () => _controller.toggleHint(i),
                          onReveal: () => _reveal(i),
                        ),
                      if (_controller.checked) ...[
                        const SizedBox(height: 6),
                        ScoreCard(
                          score: _controller.score,
                          total: _controller.filledCount,
                          label: _controller.allCorrect
                              ? 'Perfect! Every sentence is right.'
                              : 'Your score',
                          accent: topic.accent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _actionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          const CircleBackButton(),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Fill in the Blanks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _resetAll,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: kCardShadow,
                ),
                child: Icon(Icons.refresh_rounded,
                    color: widget.topic.accent, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
              color: Color(0x12203A5C),
              blurRadius: 20,
              offset: Offset(0, -6)),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppButton(
                    label:
                        'Check (${_controller.filledCount}/${_controller.total})',
                    icon: Icons.check_rounded,
                    color: widget.topic.accent,
                    enabled: _controller.filledCount > 0 && !_generating,
                    onTap: _check,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Reset',
                    icon: Icons.refresh_rounded,
                    outlined: true,
                    enabled: !_generating,
                    onTap: _resetAll,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppButton(
              label: _generating ? 'Generating…' : 'New AI Sentences',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.blue,
              enabled: !_generating,
              onTap: _generateNew,
            ),
          ],
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
    required this.accent,
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
  final Color accent;
  final ValueChanged<String> onChanged;
  final VoidCallback onHint;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final showRight = checked && filled && correct;
    final showWrong = checked && filled && !correct;

    Color borderColor = AppColors.hairline;
    if (showRight) borderColor = AppColors.green;
    if (showWrong) borderColor = AppColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: accent,
                child: Text('$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 16, height: 1.35),
                    children: [
                      ...chemicalSpans(
                          item.before, const TextStyle(fontSize: 16, height: 1.35)),
                      TextSpan(
                        text: '_______',
                        style: TextStyle(
                            color: accent, fontWeight: FontWeight.bold),
                      ),
                      ...chemicalSpans(
                          item.after, const TextStyle(fontSize: 16, height: 1.35)),
                    ],
                  ),
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
                  ? AppColors.greenSoft
                  : showWrong
                      ? AppColors.redSoft
                      : Colors.white,
              suffixIcon: checked && filled
                  ? Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: correct ? AppColors.greenDark : AppColors.red,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor, width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accent, width: 1.8),
              ),
            ),
          ),
          if (showWrong) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.redSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cancel_rounded, size: 18, color: AppColors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'That answer is wrong. Try again, use a hint, or tap '
                      'Show answer.',
                      style: TextStyle(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showRight) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.greenDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Correct!',
                        style: TextStyle(fontSize: 13.5)),
                  ),
                ],
              ),
            ),
          ],
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
                color: AppColors.yellow.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ChemicalText(item.hint,
                  style: const TextStyle(fontSize: 13.5)),
            ),
        ],
      ),
    );
  }
}
