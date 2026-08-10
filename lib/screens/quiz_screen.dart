import 'package:flutter/material.dart';

import '../models/quiz_session.dart';
import '../models/worksheet.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.session,
    required this.openAI,
    required this.tts,
    required this.store,
  });

  final QuizSession session;
  final OpenAIService openAI;
  final TtsService tts;
  final SessionStore store;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _selected;
  bool _submitted = false;
  final Set<String> _eliminated = {};
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  QuizSession get _session => widget.session;
  PhoneticQuestion get _question =>
      _session.worksheet.questions[_session.index];
  int get _total => _session.total;

  void _submit(String word) {
    if (_submitted) return;
    final correct = word == _question.answer;
    setState(() {
      _selected = word;
      _submitted = true;
      if (correct) {
        _session.correct++;
      } else {
        _session.lives =
            (_session.lives - 1).clamp(0, QuizSession.maxLives);
      }
    });
  }

  void _useHint() {
    if (_submitted) return;
    final wrong = _question.choices
        .where((c) => c != _question.answer && !_eliminated.contains(c))
        .toList();
    if (wrong.isEmpty) return;
    setState(() => _eliminated.add(wrong.first));
  }

  Future<void> _speak() async {
    try {
      await widget.tts.speak(_question.answer);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio is not available here.')),
      );
    }
  }

  void _next() {
    final outOfLives = _session.lives <= 0;
    final lastQuestion = _session.index >= _total - 1;
    if (lastQuestion || outOfLives) {
      _finish();
      return;
    }
    setState(() {
      _session.index++;
      _selected = null;
      _submitted = false;
      _eliminated.clear();
    });
  }

  void _finish() {
    final elapsed = DateTime.now().difference(_startedAt);
    final worksheet = _session.worksheet;
    final correct = _session.correct;
    final total = _total;
    // Session is done — clear it so "Resume" starts fresh next time.
    widget.store.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          correct: correct,
          total: total,
          elapsed: elapsed,
          worksheet: worksheet,
          openAI: widget.openAI,
          tts: widget.tts,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = _submitted && _selected == _question.answer;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                progress: (_session.index + (_submitted ? 1 : 0)) / _total,
                lives: _session.lives,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Choose the Right Word',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      _PromptCard(
                        phonetic: _question.phonetic,
                        onSpeak: _speak,
                        onHint: _useHint,
                        hintAvailable: !_submitted,
                      ),
                      const SizedBox(height: 20),
                      ..._buildChoices(),
                    ],
                  ),
                ),
              ),
              _buildBottom(isCorrect),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChoices() {
    return [
      for (final word in _question.choices)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ChoiceTile(
            word: word,
            state: _stateFor(word),
            dimmed: _eliminated.contains(word) && !_submitted,
            onTap: () {
              if (_eliminated.contains(word)) return;
              _submit(word);
            },
          ),
        ),
    ];
  }

  _ChoiceState _stateFor(String word) {
    if (!_submitted) {
      return _selected == word ? _ChoiceState.selected : _ChoiceState.idle;
    }
    if (word == _question.answer) return _ChoiceState.correct;
    if (word == _selected) return _ChoiceState.wrong;
    return _ChoiceState.idle;
  }

  Widget _buildBottom(bool isCorrect) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: _submitted
            ? (isCorrect ? AppColors.greenSoft : AppColors.redSoft)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12203A5C),
              blurRadius: 20,
              offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_submitted) ...[
            Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_rounded,
                  size: 26,
                  color: isCorrect ? AppColors.greenDark : AppColors.red,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isCorrect
                        ? 'Nice — that\'s it!'
                        : 'Answer: ${_question.answer}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color:
                          isCorrect ? AppColors.greenDark : AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: _submitted
                ? (_session.index >= _total - 1 || _session.lives <= 0
                    ? 'See Results'
                    : 'Continue Next')
                : 'Pick an answer',
            icon: _submitted ? Icons.arrow_forward_rounded : null,
            color: AppColors.green,
            enabled: _submitted,
            onTap: _next,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Top bar
// ============================================================

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.progress,
    required this.lives,
    required this.onBack,
  });

  final double progress;
  final int lives;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(Icons.arrow_back_rounded,
                    color: AppColors.ink, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 12,
                  backgroundColor: Colors.white,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.blue),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          HeartsBar(lives: lives),
        ],
      ),
    );
  }
}

// ============================================================
// Prompt card
// ============================================================

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.phonetic,
    required this.onSpeak,
    required this.onHint,
    required this.hintAvailable,
  });

  final String phonetic;
  final VoidCallback onSpeak;
  final VoidCallback onHint;
  final bool hintAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'What word is this?',
              style: TextStyle(
                color: AppColors.blueDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            phonetic,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleIconButton(
                icon: Icons.volume_up_rounded,
                color: AppColors.blue,
                onTap: onSpeak,
              ),
              const SizedBox(width: 18),
              CircleIconButton(
                icon: Icons.lightbulb_rounded,
                color: hintAvailable
                    ? AppColors.yellow
                    : AppColors.inkSoft,
                onTap: onHint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Choice tile
// ============================================================

enum _ChoiceState { idle, selected, correct, wrong }

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.word,
    required this.state,
    required this.dimmed,
    required this.onTap,
  });

  final String word;
  final _ChoiceState state;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late Color border;
    IconData? trailing;
    switch (state) {
      case _ChoiceState.selected:
        bg = AppColors.blueSoft;
        fg = AppColors.blueDark;
        border = AppColors.blue;
      case _ChoiceState.correct:
        bg = AppColors.greenSoft;
        fg = AppColors.greenDark;
        border = AppColors.green;
        trailing = Icons.check_circle_rounded;
      case _ChoiceState.wrong:
        bg = AppColors.redSoft;
        fg = AppColors.red;
        border = AppColors.red;
        trailing = Icons.cancel_rounded;
      case _ChoiceState.idle:
        bg = Colors.white;
        fg = AppColors.ink;
        border = AppColors.hairline;
    }

    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.8),
          boxShadow: state == _ChoiceState.idle ? kCardShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      word,
                      style: TextStyle(
                        color: fg,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Icon(trailing, color: fg, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
