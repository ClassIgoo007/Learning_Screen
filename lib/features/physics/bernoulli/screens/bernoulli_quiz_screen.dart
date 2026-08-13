import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
import '../logic/quiz_controller.dart';
import '../models/content.dart';
import '../theme/bernoulli_colors.dart';
import '../widgets/bernoulli_widgets.dart';

/// Questions on Bernoulli's principle with Learning Hub chrome.
class BernoulliQuizScreen extends StatefulWidget {
  const BernoulliQuizScreen({super.key});

  @override
  State<BernoulliQuizScreen> createState() => _BernoulliQuizScreenState();
}

class _BernoulliQuizScreenState extends State<BernoulliQuizScreen> {
  final QuizController _controller = QuizController(kQuizQuestions);
  bool _passageOpen = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int question, int option) {
    _controller.select(question, option);
    final correct = _controller.isCorrect(question);
    final q = _controller.questions[question];
    unawaited(SemanticsService.sendAnnouncement(
      View.of(context),
      correct
          ? 'Correct. ${q.explanation}'
          : 'Not quite. The answer is ${q.answer}. ${q.explanation}',
      Directionality.of(context),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Questions on Bernoulli',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
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
                          child: const Icon(Icons.refresh_rounded,
                              color: BernoulliColors.accent, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => ContentWidth(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        _passage(),
                        const SizedBox(height: 14),
                        _score(),
                        const SizedBox(height: 14),
                        for (var i = 0; i < _controller.total; i++)
                          _card(i),
                        if (_controller.isFinished) _finished(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passage() {
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: _passageOpen ? 'Hide the explainer' : 'Read the explainer',
            child: InkWell(
              onTap: () => setState(() => _passageOpen = !_passageOpen),
              child: Row(
                children: [
                  const Icon(Icons.article_rounded,
                      size: 20, color: BernoulliColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(kBernoulliPassage.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: BernoulliColors.accent)),
                  ),
                  Text(_passageOpen ? 'Hide' : 'Read',
                      style: const TextStyle(
                          color: BernoulliColors.accent,
                          fontWeight: FontWeight.w700)),
                  Icon(_passageOpen ? Icons.expand_less : Icons.expand_more,
                      color: BernoulliColors.accent),
                ],
              ),
            ),
          ),
          if (_passageOpen) ...[
            const SizedBox(height: 10),
            SelectableText(kBernoulliPassage.text,
                style: const TextStyle(fontSize: 15.5, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _score() {
    final ratio =
        _controller.total == 0 ? 0.0 : _controller.score / _controller.total;
    return Semantics(
      label: 'Progress: answered ${_controller.answeredCount} of '
          '${_controller.total}, ${_controller.score} correct.',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hairline),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Answered ${_controller.answeredCount} of ${_controller.total}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: BernoulliColors.accent)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor:
                    BernoulliColors.accent.withValues(alpha: 0.15),
                color: BernoulliColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text('${_controller.score} of ${_controller.total} correct',
                style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _finished() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BernoulliColors.okSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BernoulliColors.ok.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            'All done — ${_controller.score} / ${_controller.total} correct!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Try again',
            icon: Icons.refresh_rounded,
            color: BernoulliColors.accent,
            onTap: _controller.reset,
          ),
        ],
      ),
    );
  }

  Widget _card(int i) {
    final q = _controller.questions[i];
    final revealed = _controller.isRevealed(i);
    final selected = _controller.selectionFor(i);
    final correct = revealed && _controller.isCorrect(i);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: BernoulliColors.accent,
                child: Text('${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(q.question,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var o = 0; o < q.options.length; o++)
            _option(
              label: q.options[o],
              index: o,
              total: q.options.length,
              state: !revealed
                  ? (selected == o ? _OptState.selected : _OptState.idle)
                  : o == q.answerIndex
                      ? _OptState.correct
                      : (o == selected ? _OptState.wrong : _OptState.idle),
              onTap: revealed ? null : () => _select(i, o),
            ),
          if (revealed) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: correct
                    ? BernoulliColors.okSoft
                    : BernoulliColors.warnSoft,
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
                    color: correct ? BernoulliColors.ok : BernoulliColors.warn,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correct
                          ? 'Correct! ${q.explanation}'
                          : 'The answer is "${q.answer}". ${q.explanation}',
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

  Widget _option({
    required String label,
    required int index,
    required int total,
    required _OptState state,
    required VoidCallback? onTap,
  }) {
    late final Color border;
    late final Color fill;
    IconData? icon;

    switch (state) {
      case _OptState.correct:
        border = BernoulliColors.ok;
        fill = BernoulliColors.okSoft;
        icon = Icons.check_circle_rounded;
      case _OptState.wrong:
        border = BernoulliColors.bad;
        fill = BernoulliColors.badSoft;
        icon = Icons.cancel_rounded;
      case _OptState.selected:
        border = BernoulliColors.accent;
        fill = BernoulliColors.blueSoft;
      case _OptState.idle:
        border = AppColors.hairline;
        fill = Colors.white;
    }

    final status = switch (state) {
      _OptState.correct => ', correct answer',
      _OptState.wrong => ', your answer, incorrect',
      _ => '',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: onTap != null,
        enabled: onTap != null,
        label: 'Option ${index + 1} of $total: $label$status',
        excludeSemantics: true,
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
                      child:
                          Text(label, style: const TextStyle(fontSize: 15))),
                  if (icon != null)
                    Icon(icon,
                        size: 20,
                        color: state == _OptState.correct
                            ? BernoulliColors.ok
                            : BernoulliColors.bad),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _OptState { idle, selected, correct, wrong }
