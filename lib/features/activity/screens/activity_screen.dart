import 'package:flutter/material.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/activity_controller.dart';
import '../models/activity.dart';
import '../widgets/panels.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({
    super.key,
    required this.activity,
    required this.openAI,
  });

  final VowelActivity activity;
  final OpenAIService openAI;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController _controller =
      ActivityController(widget.activity);
  bool _celebrated = false;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeCelebrate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeCelebrate() {
    if (_controller.isComplete && !_celebrated) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('You did it!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(_controller.activity.image, height: 170),
                ),
                const SizedBox(height: 12),
                const Text('Every sentence is right and every word '
                    'is found. Time to celebrate!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _celebrated = false;
                  _controller.reset();
                },
                child: const Text('Play again'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green),
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> _generateNewActivity() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      final next = await widget.openAI.generateVowelActivity(
        seed: _controller.activity,
      );
      if (!mounted) return;
      _celebrated = false;
      _controller.replaceActivity(next);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Loaded a new AI word bank, sentences, and word search!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is HttpException ? e.message : '$e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate a new activity: $message')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  void _checkSentences() {
    _controller.checkSentences();
    if (!mounted) return;

    if (_controller.isComplete) {
      // Celebration dialog is shown by the controller listener.
      return;
    }

    final empty = _controller.emptyBlankCount;
    final wrong = _controller.wrongBlankCount;
    final correct = _controller.correctBlankCount;
    final total = _controller.activity.sentences.length;
    final foundAll = _controller.allWordsFound;

    if (empty == total) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_rounded, color: AppColors.blue),
              SizedBox(width: 8),
              Expanded(child: Text('Fill the sentences')),
            ],
          ),
          content: Text(
            foundAll
                ? 'You found every word in the puzzle — nice!\n\n'
                    'Now finish the sentences: tap a blank, then either '
                    'tap the word in the Word Bank or drag across it again '
                    'in the puzzle.'
                : 'Tap a blank to select it, then drag across the matching '
                    'word in the puzzle (or tap it in the Word Bank).',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (wrong > 0) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel_rounded, color: AppColors.red),
              SizedBox(width: 8),
              Expanded(child: Text('Some answers are wrong')),
            ],
          ),
          content: Text(
            '${wrong == 1 ? '1 sentence is' : '$wrong sentences are'} marked '
            'wrong in red.'
            '${correct > 0 ? '\n$correct look correct so far.' : ''}'
            '${empty > 0 ? '\n$empty still empty.' : ''}'
            '\n\nTap a wrong blank to clear it, then choose a new word.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (empty > 0) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_rounded, color: AppColors.yellow),
              SizedBox(width: 8),
              Expanded(child: Text('Almost there')),
            ],
          ),
          content: Text(
            'Nice work — $correct of $total sentences look right.\n\n'
            'Fill the $empty empty blank${empty == 1 ? '' : 's'} next: '
            'tap a blank, then cross the word in the puzzle.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.green),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // All sentences correct, but puzzle words still missing.
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Sentences look great!')),
          ],
        ),
        content: Text(
          'Every sentence is correct. '
          'Now find the remaining words in the puzzle '
          '(${_controller.foundWords.length} / '
          '${_controller.activity.words.length} so far).',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;
                  return wide ? _wideLayout() : _narrowLayout();
                }),
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
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Text(
                _controller.activity.title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _generating ? null : _controller.reset,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: kCardShadow,
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: AppColors.blue, size: 20),
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
                    label: 'Check sentences',
                    icon: Icons.check_rounded,
                    color: AppColors.green,
                    enabled: !_generating,
                    onTap: _checkSentences,
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
              label: _generating ? 'Generating…' : 'New AI Activity',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.blue,
              enabled: !_generating,
              onTap: _generateNewActivity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Text(
            _controller.activity.subtitle,
            style: const TextStyle(
                fontSize: 14.5, height: 1.35, color: AppColors.inkSoft),
          ),
        ),
      );

  Widget _progress() => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.blueSoft,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Words found: ${_controller.foundWords.length} / '
            '${_controller.activity.words.length}',
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.blueDark),
          ),
        ),
      );

  Widget _illustration({double height = 150}) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(_controller.activity.image,
              height: height, fit: BoxFit.contain),
        ),
      );

  /// Phones: one scrollable column.
  Widget _narrowLayout() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            WordBank(controller: _controller),
            const SizedBox(height: 16),
            Center(child: WordSearchGrid(controller: _controller)),
            Center(child: _progress()),
            const SizedBox(height: 4),
            SentenceList(controller: _controller),
            const SizedBox(height: 12),
            Center(child: _illustration(height: 140)),
          ],
        ),
      );

  /// Tablets/desktop: sentences left, puzzle + illustration right.
  Widget _wideLayout() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    WordBank(controller: _controller),
                    const SizedBox(height: 16),
                    SentenceList(controller: _controller),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    WordSearchGrid(controller: _controller),
                    _progress(),
                    _illustration(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
