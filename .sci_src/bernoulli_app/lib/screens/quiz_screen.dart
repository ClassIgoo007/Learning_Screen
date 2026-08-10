import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../logic/quiz_controller.dart';
import '../models/content.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Question and answer screen on Bernoulli's principle.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  static const String routeName = '/questions';

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizController _controller = QuizController(kQuizQuestions);
  bool _passageOpen = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int question, int option) {
    _controller.select(question, option);
    // Announce the outcome so a screen-reader user learns the result without
    // having to hunt for the explanation panel that just appeared.
    final correct = _controller.isCorrect(question);
    final q = _controller.questions[question];
    unawaited(SemanticsService.announce(
      correct
          ? 'Correct. ${q.explanation}'
          : 'Not quite. The answer is ${q.answer}. ${q.explanation}',
      Directionality.of(context),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions on Bernoulli'),
        actions: [
          IconButton(
            tooltip: 'Start over',
            icon: const Icon(Icons.refresh),
            onPressed: _controller.reset,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _passage(context),
                const SizedBox(height: 14),
                _score(context),
                const SizedBox(height: 14),
                for (var i = 0; i < _controller.total; i++) _card(context, i),
                if (_controller.isFinished) _finished(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passage(BuildContext context) {
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: _passageOpen
                ? 'Hide the explainer'
                : 'Read the explainer',
            child: InkWell(
              onTap: () => setState(() => _passageOpen = !_passageOpen),
              child: Row(
                children: [
                  Icon(Icons.article_rounded,
                      size: 20, color: context.scheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(kBernoulliPassage.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: context.scheme.onPrimaryContainer)),
                  ),
                  Text(_passageOpen ? 'Hide' : 'Read',
                      style: TextStyle(
                          color: context.scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600)),
                  Icon(_passageOpen ? Icons.expand_less : Icons.expand_more,
                      color: context.scheme.onPrimaryContainer),
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

  Widget _score(BuildContext context) {
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
          color: context.scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered ${_controller.answeredCount} of '
                '${_controller.total}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.scheme.primary)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: context.scheme.primary.withOpacity(0.15),
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

  Widget _finished(BuildContext context) {
    return Card(
      color: context.scheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.scheme.outlineVariant),
      ),
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
              onPressed: _controller.reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, int i) {
    final q = _controller.questions[i];
    final revealed = _controller.isRevealed(i);
    final selected = _controller.selectionFor(i);
    final correct = revealed && _controller.isCorrect(i);
    final c = context.colours;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.scheme.outlineVariant),
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
                  backgroundColor: context.scheme.primary,
                  child: Text('${i + 1}',
                      style: TextStyle(
                          color: context.scheme.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(q.question,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var o = 0; o < q.options.length; o++)
              _option(
                context: context,
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
                  color: correct ? c.okContainer : c.warnContainer,
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
                      color: correct ? c.ok : c.warn,
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
      ),
    );
  }

  Widget _option({
    required BuildContext context,
    required String label,
    required int index,
    required int total,
    required _OptState state,
    required VoidCallback? onTap,
  }) {
    final c = context.colours;
    late final Color border;
    late final Color fill;
    IconData? icon;

    switch (state) {
      case _OptState.correct:
        border = c.ok;
        fill = c.okContainer;
        icon = Icons.check_circle_rounded;
      case _OptState.wrong:
        border = c.bad;
        fill = c.badContainer;
        icon = Icons.cancel_rounded;
      case _OptState.selected:
        border = context.scheme.primary;
        fill = context.scheme.primaryContainer;
      case _OptState.idle:
        border = context.scheme.outline;
        fill = context.scheme.surface;
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
              // 48dp is the minimum comfortable touch target.
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
                        color: state == _OptState.correct ? c.ok : c.bad),
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
