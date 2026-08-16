import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
import '../data/lesson_data.dart';
import '../models/lesson.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// Screen 1 — read the passage, then answer four multiple-choice questions.
class ChoiceScreen extends StatefulWidget {
  const ChoiceScreen({super.key});

  @override
  State<ChoiceScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  final Map<int, String> _selected = <int, String>{};
  bool _checked = false;

  List<ChoiceQuestion> get _questions => kCloudLesson.choiceQuestions;

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
                    PassageCard(passage: kCloudLesson.passageOne),
                    const SizedBox(height: 16),
                    ProgressHeader(
                      label: 'Choose the best answer',
                      answered: _selected.length,
                      total: _questions.length,
                    ),
                    if (_checked) ...[
                      const SizedBox(height: 12),
                      ScoreBanner(score: _score, total: _questions.length),
                    ],
                    const SizedBox(height: 16),
                    for (var i = 0; i < _questions.length; i++) ...[
                      EntranceFade(
                        delay: Duration(milliseconds: 40 * i),
                        child: _QuestionCard(
                          index: i,
                          question: _questions[i],
                          selected: _selected[i],
                          checked: _checked,
                          onSelect: _checked
                              ? null
                              : (value) =>
                                  setState(() => _selected[i] = value),
                        ),
                      ),
                      const SizedBox(height: 14),
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

    return ElevatedCard(
      color: Palette.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      borderColor: !checked
          ? null
          : correct
              ? Palette.correct.withValues(alpha: 0.45)
              : Palette.wrong.withValues(alpha: 0.45),
      glow: checked ? (correct ? Palette.correct : Palette.wrong) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumberBadge(
                number: index + 1,
                accent: Palette.slate,
                filled: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopicChip(
                      label: question.topic,
                      accent: Palette.updraft,
                      tint: Palette.updraftTint,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.prompt,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Palette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: AnimatedFeedbackIcon(correct: correct, visible: checked),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var c = 0; c < question.choices.length; c++)
            _ChoiceTile(
              index: c,
              label: question.choices[c],
              isSelected: selected == question.choices[c],
              isAnswer: question.answer == question.choices[c],
              checked: checked,
              onTap: onSelect == null
                  ? null
                  : () => onSelect!(question.choices[c]),
            ),
          if (checked) WatchBeatLink(beat: question.beat),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.isAnswer,
    required this.checked,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isSelected;
  final bool isAnswer;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TileFeedback feedback;
    final Color text;
    if (!checked && isSelected) {
      feedback = TileFeedback.selected;
      text = Palette.slate;
    } else if (checked && isAnswer) {
      feedback = TileFeedback.correct;
      text = Palette.correct;
    } else if (checked && isSelected) {
      feedback = TileFeedback.incorrect;
      text = Palette.wrong;
    } else {
      feedback = TileFeedback.neutral;
      text = Palette.ink;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SelectableTile(
        feedback: feedback,
        accent: Palette.slate,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LetterBadge(
              index: index,
              feedback: feedback,
              accent: Palette.slate,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: text,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
