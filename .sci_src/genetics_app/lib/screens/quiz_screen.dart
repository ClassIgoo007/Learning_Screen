import 'package:flutter/material.dart';

import '../logic/controllers.dart';
import '../models/content.dart';
import '../widgets/common.dart';
import '../widgets/passage_card.dart';

/// Screen 1 — question and answer. One question per card, three options,
/// immediate feedback with a short explanation.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizController _controller = QuizController(kQuizQuestions);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
        title: const Text('Reading & Questions'),
        actions: [
          IconButton(
            tooltip: 'Start over',
            icon: const Icon(Icons.refresh),
            onPressed: _controller.reset,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const PassageCard(passage: kPassageOne),
              const SizedBox(height: 16),
              const Text(
                'Now answer the questions. Everything you need is in the '
                'passage above — tap "Hide" to collapse it, or "Read" to '
                'open it again while you work.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 14),
              ScoreCard(
                score: _controller.score,
                total: _controller.total,
                label:
                    'Answered ${_controller.answeredCount} of ${_controller.total}',
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < _controller.total; i++)
                _QuestionCard(
                  number: i + 1,
                  question: _controller.questions[i],
                  selected: _controller.selectionFor(i),
                  revealed: _controller.isRevealed(i),
                  onSelect: (option) => _controller.select(i, option),
                ),
              if (_controller.isFinished) ...[
                const SizedBox(height: 8),
                Card(
                  color: kTealLight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'All done — ${_controller.score} / ${_controller.total} correct!',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: kTeal),
                          onPressed: _controller.reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.revealed,
    required this.onSelect,
  });

  final int number;
  final QuizQuestion question;
  final int? selected;
  final bool revealed;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final correct = revealed && selected == question.answerIndex;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kTeal.withOpacity(0.25)),
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
                  backgroundColor: kTeal,
                  child: Text('$number',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(question.question,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < question.options.length; i++)
              _OptionTile(
                label: question.options[i],
                state: _stateFor(i),
                onTap: revealed ? null : () => onSelect(i),
              ),
            if (revealed) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: correct
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.lightbulb_rounded,
                      size: 18,
                      color: correct ? kTealDark : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        correct
                            ? 'Correct! ${question.explanation}'
                            : 'The answer is "${question.answer}". '
                                '${question.explanation}',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _OptionState _stateFor(int index) {
    if (!revealed) {
      return selected == index ? _OptionState.selected : _OptionState.idle;
    }
    if (index == question.answerIndex) return _OptionState.correct;
    if (index == selected) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    late final Color border;
    late final Color fill;
    IconData? icon;

    switch (state) {
      case _OptionState.correct:
        border = kTeal;
        fill = const Color(0xFFE8F5E9);
        icon = Icons.check_circle_rounded;
      case _OptionState.wrong:
        border = Colors.red.shade400;
        fill = const Color(0xFFFFEBEE);
        icon = Icons.cancel_rounded;
      case _OptionState.selected:
        border = kTeal;
        fill = kTealLight;
      case _OptionState.idle:
        border = Colors.black26;
        fill = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 15)),
                ),
                if (icon != null)
                  Icon(icon,
                      size: 20,
                      color: state == _OptionState.correct
                          ? kTealDark
                          : Colors.red.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
