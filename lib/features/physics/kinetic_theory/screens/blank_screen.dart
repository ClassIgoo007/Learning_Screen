import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
import '../models/lesson.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// Screen 2 — read the second passage, then complete each sentence by typing
/// the missing word into the blank.
class BlankScreen extends StatefulWidget {
  const BlankScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<BlankScreen> createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _checked = false;

  List<ClozeSentence> get _items => widget.lesson.clozeSentences;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(_items.length, (_) => TextEditingController());
    _focusNodes = List.generate(_items.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  int get _score {
    var total = 0;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isCorrect(_controllers[i].text)) total++;
    }
    return total;
  }

  bool get _complete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  void _check() {
    FocusScope.of(context).unfocus();
    if (!_complete) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Fill in every blank first.')),
        );
      return;
    }
    setState(() => _checked = true);
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (final c in _controllers) {
        c.clear();
      }
      _checked = false;
    });
  }

  /// Enter on the keyboard moves to the next blank, and marks on the last one.
  void _advance(int index) {
    if (index + 1 < _focusNodes.length) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _check();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                Sizes.gutter, 16, Sizes.gutter, 28),
            children: [
              ContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PassageCard(passage: widget.lesson.passageTwo),
                    const SizedBox(height: 16),
                    ProgressHeader(
                      label: 'Complete each sentence',
                      answered: _controllers
                          .where((c) => c.text.trim().isNotEmpty)
                          .length,
                      total: _items.length,
                    ),
                    if (_checked) ...[
                      const SizedBox(height: 12),
                      ScoreBanner(score: _score, total: _items.length),
                    ],
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Type the missing word from the passage into each '
                        'blank. Spelling is marked, capitals are not.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: Palette.inkSoft,
                        ),
                      ),
                    ),
                    for (var i = 0; i < _items.length; i++) ...[
                      EntranceFade(
                        delay: Duration(milliseconds: 40 * i),
                        child: _ClozeCard(
                          index: i,
                          item: _items[i],
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          checked: _checked,
                          onSubmitted: () => _advance(i),
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        ActionBar(
          primaryLabel: _checked ? 'Answers marked' : 'Check answers',
          onPrimary: _checked ? null : _check,
          secondaryLabel: _checked ? 'Try again' : 'Clear',
          onSecondary: _reset,
        ),
      ],
    );
  }
}

class _ClozeCard extends StatelessWidget {
  const _ClozeCard({
    required this.index,
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.checked,
    required this.onSubmitted,
    required this.onChanged,
  });

  final int index;
  final ClozeSentence item;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool checked;
  final VoidCallback onSubmitted;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final correct = item.isCorrect(controller.text);

    const sentenceStyle = TextStyle(
      fontSize: 15.5,
      height: 1.9,
      color: Palette.ink,
    );

    return ElevatedCard(
      color: Palette.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderColor: !checked
          ? null
          : correct
              ? Palette.correct.withValues(alpha: 0.45)
              : Palette.wrong.withValues(alpha: 0.45),
      glow: checked ? (correct ? Palette.correct : Palette.wrong) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumberBadge(
            number: index + 1,
            accent: Palette.slate,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${item.before} ', style: sentenceStyle),
                    BlankChip(
                      controller: controller,
                      focusNode: focusNode,
                      accent: Palette.slate,
                      checked: checked,
                      correct: correct,
                      onSubmitted: onSubmitted,
                      onChanged: onChanged,
                    ),
                    Text(' ${item.after}', style: sentenceStyle),
                  ],
                ),
                if (item.hint != null && !checked) ...[
                  const SizedBox(height: 10),
                  HintCallout(text: item.hint!, accent: Palette.updraft),
                ],
                if (checked) WatchBeatLink(beat: item.beat),
                if (checked && !correct) ...[
                  const SizedBox(height: 10),
                  RevealRow(answer: item.answer),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: AnimatedFeedbackIcon(correct: correct, visible: checked),
          ),
        ],
      ),
    );
  }
}
