import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/controllers.dart';
import '../models/science_content.dart';
import '../widgets/science_widgets.dart';

/// Multiple-choice Q&A activity for a science reading topic.
class ScienceQuizScreen extends StatefulWidget {
  const ScienceQuizScreen({super.key, required this.topic});

  final ScienceTopic topic;

  @override
  State<ScienceQuizScreen> createState() => _ScienceQuizScreenState();
}

class _ScienceQuizScreenState extends State<ScienceQuizScreen> {
  late final QuizController _controller =
      QuizController(widget.topic.questions);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      if (topic.quiz.hasPassage)
                        PassageCard(
                          activity: topic.quiz,
                          accent: topic.accent,
                        )
                      else ...[
                        DiagramCard(
                          asset: topic.quiz.diagram,
                          label: topic.quiz.diagramCaption,
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
                        'Read each question and tap the answer you think is right. '
                        'You will see straight away whether it was correct.',
                        style: TextStyle(fontSize: 14.5, color: AppColors.ink),
                      ),
                      const SizedBox(height: 14),
                      ScoreCard(
                        score: _controller.score,
                        total: _controller.total,
                        label:
                            'Answered ${_controller.answeredCount} of ${_controller.total}',
                        accent: topic.accent,
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < _controller.total; i++)
                        _QuestionCard(
                          number: i + 1,
                          question: _controller.questions[i],
                          selected: _controller.selectionFor(i),
                          revealed: _controller.isRevealed(i),
                          accent: topic.accent,
                          onSelect: (option) => _controller.select(i, option),
                        ),
                      if (_controller.isFinished) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: topic.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'All done — ${_controller.score} / '
                                '${_controller.total} correct!',
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 10),
                              AppButton(
                                label: 'Try again',
                                icon: Icons.refresh_rounded,
                                color: topic.accent,
                                onTap: _controller.reset,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
              'Question & Answer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _controller.reset,
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
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selected,
    required this.revealed,
    required this.accent,
    required this.onSelect,
  });

  final int number;
  final QuizQuestion question;
  final int? selected;
  final bool revealed;
  final Color accent;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final correct = revealed && selected == question.answerIndex;

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
                child: Text(question.question,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < question.options.length; i++)
            _OptionTile(
              label: question.options[i],
              state: _stateFor(i),
              accent: accent,
              onTap: revealed ? null : () => onSelect(i),
            ),
          if (revealed) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: correct ? AppColors.greenSoft : AppColors.redSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    correct
                        ? Icons.check_circle_rounded
                        : Icons.lightbulb_rounded,
                    size: 18,
                    color: correct ? AppColors.greenDark : AppColors.red,
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
    required this.accent,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    late final Color border;
    late final Color fill;
    IconData? icon;

    switch (state) {
      case _OptionState.correct:
        border = AppColors.green;
        fill = AppColors.greenSoft;
        icon = Icons.check_circle_rounded;
      case _OptionState.wrong:
        border = AppColors.red;
        fill = AppColors.redSoft;
        icon = Icons.cancel_rounded;
      case _OptionState.selected:
        border = accent;
        fill = accent.withValues(alpha: 0.12);
      case _OptionState.idle:
        border = AppColors.hairline;
        fill = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
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
                          ? AppColors.greenDark
                          : AppColors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
