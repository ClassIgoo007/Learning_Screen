import 'package:flutter/material.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/controllers.dart';
import '../models/science_content.dart';
import '../widgets/science_widgets.dart';

/// Multiple-choice Q&A: select answers, then press Check to grade.
class ScienceQuizScreen extends StatefulWidget {
  const ScienceQuizScreen({
    super.key,
    required this.topic,
    required this.openAI,
  });

  final ScienceTopic topic;
  final OpenAIService openAI;

  @override
  State<ScienceQuizScreen> createState() => _ScienceQuizScreenState();
}

class _ScienceQuizScreenState extends State<ScienceQuizScreen> {
  late final QuizController _controller =
      QuizController(widget.topic.questions);
  bool _generating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    if (_controller.selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one answer, then press Check.')),
      );
      return;
    }
    _controller.check();
    final missing = _controller.total - _controller.selectedCount;
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
                '$missing question(s) still unanswered — the rest were checked.')),
      );
    }
  }

  Future<void> _generateNew() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      final questions =
          await widget.openAI.generateScienceQuiz(topic: widget.topic);
      if (!mounted) return;
      _controller.replaceQuestions(questions);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Loaded ${questions.length} new AI questions. Select answers, then Check.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate questions: $e')),
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
                        'Tap an answer for each question, then press Check. '
                        'If an answer is wrong, you will see a clear message.',
                        style: TextStyle(fontSize: 14.5, color: AppColors.ink),
                      ),
                      const SizedBox(height: 14),
                      if (_controller.checked)
                        ScoreCard(
                          score: _controller.score,
                          total: _controller.selectedCount,
                          label: _controller.wrongCount == 0 &&
                                  _controller.selectedCount ==
                                      _controller.total
                              ? 'Perfect! Every answer is right.'
                              : 'Checked ${_controller.selectedCount} of ${_controller.total}',
                          accent: topic.accent,
                        ),
                      if (_controller.checked) const SizedBox(height: 14),
                      for (var i = 0; i < _controller.total; i++)
                        _QuestionCard(
                          number: i + 1,
                          question: _controller.questions[i],
                          selected: _controller.selectionFor(i),
                          revealed: _controller.isRevealed(i),
                          accent: topic.accent,
                          onSelect: (option) => _controller.select(i, option),
                        ),
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
                    label: 'Check answers',
                    icon: Icons.check_rounded,
                    color: widget.topic.accent,
                    enabled: _controller.selectedCount > 0 && !_generating,
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
                    onTap: _controller.reset,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppButton(
              label: _generating ? 'Generating…' : 'New AI Questions',
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
              onTap: () => onSelect(i),
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
                        : Icons.cancel_rounded,
                    size: 18,
                    color: correct ? AppColors.greenDark : AppColors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correct
                          ? 'Correct! ${question.explanation}'
                          : 'That answer is wrong. The correct answer is '
                              '"${question.answer}". ${question.explanation}',
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
  final VoidCallback onTap;

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
