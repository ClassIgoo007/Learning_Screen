import 'package:flutter/material.dart';

import '../models/quiz_session.dart';
import '../models/worksheet.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.elapsed,
    required this.worksheet,
    required this.openAI,
    required this.tts,
    required this.store,
  });

  final int correct;
  final int total;
  final Duration elapsed;
  final Worksheet worksheet;
  final OpenAIService openAI;
  final TtsService tts;
  final SessionStore store;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _generating = false;

  int get _percent =>
      widget.total == 0 ? 0 : (widget.correct / widget.total * 100).round();
  int get _xp => widget.correct * 25;

  String get _timeLabel {
    final m = widget.elapsed.inMinutes;
    final s = widget.elapsed.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _headline {
    if (_percent == 100) return 'You Just did it!';
    if (_percent >= 60) return 'Great job!';
    return 'Good effort!';
  }

  void _startQuiz(Worksheet ws) {
    final session = widget.store.startNew(ws);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          openAI: widget.openAI,
          tts: widget.tts,
          store: widget.store,
        ),
      ),
    );
  }

  Future<void> _playAgain() async => _startQuiz(widget.worksheet);

  Future<void> _generateNew() async {
    final theme = await _askForTheme();
    if (theme == null) return;
    setState(() => _generating = true);
    try {
      final ws = await widget.openAI
          .generateWorksheet(theme: theme.isEmpty ? null : theme);
      if (!mounted) return;
      _startQuiz(ws);
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate a new worksheet: $e')),
      );
    }
  }

  Future<String?> _askForTheme() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New AI worksheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pick a theme and the AI builds 8 fresh questions.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Theme (optional)',
                hintText: 'e.g. animals, space, ocean',
                filled: true,
                fillColor: AppColors.blueSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _generating ? _buildGenerating() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.blue),
          SizedBox(height: 18),
          Text('Building a new worksheet…',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset('assets/hero_results.png',
                  fit: BoxFit.contain),
            ),
          ),
          Text(
            _headline,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'You scored ${widget.correct} of ${widget.total}',
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 15),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  color: AppColors.yellow,
                  value: '$_xp',
                  label: 'Total XP',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.track_changes_rounded,
                  color: AppColors.blue,
                  value: '$_percent%',
                  label: _percent >= 60 ? 'Great' : 'Keep going',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_rounded,
                  color: AppColors.green,
                  value: _timeLabel,
                  label: 'Time',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Try Fresh Words',
            icon: Icons.auto_awesome_rounded,
            color: AppColors.green,
            onTap: _generateNew,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Play Again',
            outlined: true,
            onTap: _playAgain,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.inkSoft, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
