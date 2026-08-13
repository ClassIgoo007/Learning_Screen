import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';
import 'lesson_shell.dart';

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
                    const SizedBox(height: 26),
                    SectionLabel(
                      text: 'Complete each sentence',
                      trailing: '${_items.length} blanks',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
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
                      _ClozeCard(
                        index: i,
                        item: _items[i],
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        checked: _checked,
                        onSubmitted: () => _advance(i),
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_checked) ...[
                      const SizedBox(height: 6),
                      ScoreBanner(score: _score, total: _items.length),
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
    final border = !checked
        ? Palette.hairline
        : correct
            ? Palette.correct.withOpacity(0.5)
            : Palette.wrong.withOpacity(0.5);

    final sentenceStyle = const TextStyle(
      fontSize: 15.5,
      height: 1.9,
      color: Palette.ink,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Palette.slateTint,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Palette.slate,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The sentence flows as one wrapping line of text with the
                // input embedded in it, so the blank sits where the word would.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${item.before} ', style: sentenceStyle),
                    _BlankField(
                      controller: controller,
                      focusNode: focusNode,
                      checked: checked,
                      correct: correct,
                      onSubmitted: onSubmitted,
                      onChanged: onChanged,
                    ),
                    Text(' ${item.after}', style: sentenceStyle),
                  ],
                ),
                if (item.hint != null && !checked) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 14, color: Palette.updraft),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.hint!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: Palette.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (checked) WatchBeatLink(beat: item.beat),
                if (checked && !correct) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right,
                          size: 15, color: Palette.wrong),
                      const SizedBox(width: 6),
                      Text(
                        'Answer: ${item.answer}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Palette.wrong,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (checked)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Icon(
                correct ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: correct ? Palette.correct : Palette.wrong,
              ),
            ),
        ],
      ),
    );
  }
}

/// The blank itself: an underlined field sized to sit inline with the sentence.
class _BlankField extends StatelessWidget {
  const _BlankField({
    required this.controller,
    required this.focusNode,
    required this.checked,
    required this.correct,
    required this.onSubmitted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool checked;
  final bool correct;
  final VoidCallback onSubmitted;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final color = !checked
        ? Palette.slate
        : correct
            ? Palette.correct
            : Palette.wrong;

    return SizedBox(
      width: 132,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: !checked,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => onSubmitted(),
        onChanged: (_) => onChanged(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: '. . . . . .',
          hintStyle: const TextStyle(
            color: Palette.inkSoft,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color.withOpacity(0.5), width: 1.4),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color, width: 1.4),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: color, width: 2),
          ),
        ),
      ),
    );
  }
}
