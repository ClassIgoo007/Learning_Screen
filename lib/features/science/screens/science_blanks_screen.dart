import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/controllers.dart';
import '../models/science_content.dart';
import '../widgets/science_widgets.dart';

/// Fill-in-the-blank activity for a science reading topic.
class ScienceBlanksScreen extends StatefulWidget {
  const ScienceBlanksScreen({super.key, required this.topic});

  final ScienceTopic topic;

  @override
  State<ScienceBlanksScreen> createState() => _ScienceBlanksScreenState();
}

class _ScienceBlanksScreenState extends State<ScienceBlanksScreen> {
  late final BlanksController _controller =
      BlanksController(widget.topic.blankItems);
  late final List<TextEditingController> _fields = List.generate(
    widget.topic.blankItems.length,
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
    FocusScope.of(context).unfocus();
    _controller.check();
    final missing = _controller.total - _controller.filledCount;
    if (missing > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$missing blank(s) still empty — the filled ones '
                'were checked.')),
      );
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
                        'Complete each sentence with a word from the reading. '
                        'Spelling counts, but capital letters do not.',
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
                          total: _controller.total,
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
        builder: (context, _) => Row(
          children: [
            Expanded(
              flex: 3,
              child: AppButton(
                label:
                    'Check (${_controller.filledCount}/${_controller.total})',
                icon: Icons.check_rounded,
                color: widget.topic.accent,
                enabled: _controller.filledCount > 0,
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
                onTap: _resetAll,
              ),
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
                  TextSpan(children: [
                    TextSpan(text: item.before),
                    TextSpan(
                      text: '_______',
                      style: TextStyle(
                          color: accent, fontWeight: FontWeight.bold),
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
              child: Text(item.hint,
                  style: const TextStyle(fontSize: 13.5)),
            ),
        ],
      ),
    );
  }
}
