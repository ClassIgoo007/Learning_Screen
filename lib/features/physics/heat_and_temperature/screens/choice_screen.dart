import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// Screen 1 — read the passage, then answer four multiple-choice questions.
class ChoiceScreen extends StatefulWidget {
  const ChoiceScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<ChoiceScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  final Map<int, String> _selected = <int, String>{};
  bool _checked = false;

  List<ChoiceQuestion> get _questions => widget.lesson.choiceQuestions;

  int get _score => _questions
      .asMap()
      .entries
      .where((e) => e.value.isCorrect(_selected[e.key]))
      .length;

  bool get _complete => _selected.length == _questions.length;

  void _check() {
    if (!_complete) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Answer every question first.')),
        );
      return;
    }
    setState(() => _checked = true);
  }

  void _reset() => setState(() {
        _selected.clear();
        _checked = false;
      });

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
                    PassageCard(passage: widget.lesson.passageOne),
                    const SizedBox(height: 20),
                    ProgressHeader(
                      label: 'Choose the best answer',
                      answered: _selected.length,
                      total: _questions.length,
                    ),
                    if (_checked) ...[
                      const SizedBox(height: 12),
                      ScoreBanner(score: _score, total: _questions.length),
                    ],
                    const SizedBox(height: 14),
                    for (var i = 0; i < _questions.length; i++) ...[
                      _QuestionCard(
                        index: i,
                        question: _questions[i],
                        selected: _selected[i],
                        checked: _checked,
                        onSelect: _checked
                            ? null
                            : (value) =>
                                setState(() => _selected[i] = value),
                      ),
                      const SizedBox(height: 10),
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
          onSecondary: _selected.isEmpty ? null : _reset,
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.checked,
    required this.onSelect,
  });

  final int index;
  final ChoiceQuestion question;
  final String? selected;
  final bool checked;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final correct = question.isCorrect(selected);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(Sizes.cardRadius),
        border: Border.all(
          color: !checked
              ? Palette.hairline
              : correct
                  ? Palette.correct.withValues(alpha: 0.5)
                  : Palette.wrong.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberChip(index + 1),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopicPill(question.topic),
                    const SizedBox(height: 6),
                    Text(
                      question.prompt,
                      style: const TextStyle(
                        fontSize: 15.5,
                        height: 1.45,
                        color: Palette.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (checked)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    size: 20,
                    color: correct ? Palette.correct : Palette.wrong,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final choice in question.choices)
            _ChoiceTile(
              label: choice,
              isSelected: selected == choice,
              isAnswer: question.answer == choice,
              checked: checked,
              onTap: onSelect == null ? null : () => onSelect!(choice),
            ),
          if (checked) WatchBeatLink(beat: question.beat),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.isAnswer,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isAnswer;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = Palette.hairline;
    Color fill = Palette.surface;
    Color text = Palette.ink;

    if (!checked && isSelected) {
      border = Palette.slate;
      fill = Palette.slateTint;
      text = Palette.slate;
    } else if (checked && isAnswer) {
      border = Palette.correct;
      fill = Palette.correctTint;
      text = Palette.correct;
    } else if (checked && isSelected) {
      border = Palette.wrong;
      fill = Palette.wrongTint;
      text = Palette.wrong;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: isSelected ? text : Palette.inkSoft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: text,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
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

/// An outlined ring, matching Kinetic Theory's numbering treatment — same
/// primitive, different fill, so the app's two data-driven worksheets read as
/// siblings even though their accent colours differ.
class _NumberChip extends StatelessWidget {
  const _NumberChip(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Palette.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Palette.slate, width: 1.6),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Palette.slate,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Palette.accentTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          letterSpacing: 0.9,
          fontWeight: FontWeight.w600,
          color: Palette.accent,
        ),
      ),
    );
  }
}
