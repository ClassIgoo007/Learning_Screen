import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/crossword_controller.dart';
import '../models/crossword.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/panels.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({
    super.key,
    required this.puzzle,
    required this.openAI,
  });

  final CrosswordPuzzle puzzle;
  final OpenAIService openAI;

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late final CrosswordController _controller =
      CrosswordController(widget.puzzle);
  final FocusNode _focusNode = FocusNode(debugLabel: 'crosswordKeys');
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // Keep hardware-keyboard focus after taps / on-screen keys.
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    _maybeCelebrate();
  }

  /// Accept physical / laptop / Bluetooth keyboard input in addition to
  /// the on-screen letter pad.
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _controller.backspace();
      return KeyEventResult.handled;
    }

    // Prefer the typed character (handles shift / locale); fall back to
    // the key label for platforms that leave character null.
    final raw = (event.character ?? key.keyLabel).trim();
    if (raw.length == 1) {
      final upper = raw.toUpperCase();
      final code = upper.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        _controller.typeLetter(upper);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  bool _celebrated = false;
  void _maybeCelebrate() {
    if (_controller.isPuzzleSolved && !_celebrated) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Great job!'),
            content: Text(
                'You solved every word in the ${_controller.puzzle.name} puzzle!'),
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

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.skyGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    return wide ? _wideLayout() : _narrowLayout();
                  }),
                ),
                _actionBar(),
              ],
            ),
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
                _controller.puzzle.title,
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
                  child: AppButton(
                    label: 'Reveal',
                    icon: Icons.lightbulb_rounded,
                    color: AppColors.yellow,
                    textColor: AppColors.ink,
                    enabled: _controller.selected != null && !_generating,
                    onTap: _controller.revealSelectedWord,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Check',
                    icon: Icons.check_rounded,
                    color: AppColors.green,
                    enabled: _controller.filledCells != 0 && !_generating,
                    onTap: _checkAnswers,
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
              onTap: _generateNewClues,
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswers() {
    _controller.checkAnswers();
    if (!mounted) return;

    if (_controller.isPuzzleSolved) {
      // Celebration dialog is shown by the controller listener.
      return;
    }

    final wrongLetters = _controller.wrongFilledCells;
    final wrongWords = _controller.wrongEntryCount;
    final correct = _controller.correctFilledCells;

    if (wrongLetters > 0) {
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
            'Wrong answers stay marked in red on the grid and on the clue '
            'list until you change those letters.\n\n'
            '${wrongWords == 1 ? '1 clue' : '$wrongWords clues'} marked wrong'
            ' ($wrongLetters letter${wrongLetters == 1 ? '' : 's'}).'
            '${correct > 0 ? '\n$correct letter(s) look correct so far.' : ''}'
            '\n\nYou can fix them, or tap New AI Questions for fresh clues.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _generateNewClues();
              },
              child: const Text('New AI Questions'),
            ),
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

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Looking good!')),
          ],
        ),
        content: Text(
          'The $correct letter(s) you filled in are correct. '
          'Keep going to finish the puzzle.',
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

  Future<void> _generateNewClues() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      final next = await widget.openAI
          .generateCrosswordClues(puzzle: _controller.puzzle);
      if (!mounted) return;
      _celebrated = false;
      _controller.replacePuzzle(next); // fresh clues + clear progress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Loaded new AI clues for the same words. Fill the grid again!')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is HttpException ? e.message : '$e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate new clues: $message')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Text(
            _controller.puzzle.subtitle,
            style: const TextStyle(
                fontSize: 14.5, height: 1.35, color: AppColors.inkSoft),
          ),
        ),
      );

  Widget _illustration({double height = 160}) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          _controller.puzzle.image,
          height: height,
          fit: BoxFit.contain,
        ),
      );

  /// Phones: single scrollable column, keyboard pinned near the bottom.
  Widget _narrowLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                WordBank(controller: _controller),
                const SizedBox(height: 16),
                Center(child: CrosswordGrid(controller: _controller)),
                const SizedBox(height: 16),
                CluesPanel(controller: _controller),
                const SizedBox(height: 12),
                Center(child: _illustration(height: 150)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LetterKeyboard(controller: _controller),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Tablets/desktop: word bank + clues + illustration on the left,
  /// grid and keyboard on the right.
  Widget _wideLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  WordBank(controller: _controller),
                  const SizedBox(height: 16),
                  CluesPanel(controller: _controller),
                  const SizedBox(height: 12),
                  Center(child: _illustration()),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CrosswordGrid(controller: _controller),
                  const SizedBox(height: 20),
                  LetterKeyboard(controller: _controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
