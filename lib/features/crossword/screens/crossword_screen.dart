import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/crossword_controller.dart';
import '../models/crossword.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/panels.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({super.key, required this.puzzle});

  final CrosswordPuzzle puzzle;

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late final CrosswordController _controller =
      CrosswordController(widget.puzzle);

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
                'You solved every word in the ${widget.puzzle.name} puzzle!'),
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
                  final wide = constraints.maxWidth >= 760;
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
            child: Text(
              widget.puzzle.title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800),
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
        builder: (context, _) => Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Reveal',
                icon: Icons.lightbulb_rounded,
                color: AppColors.yellow,
                textColor: AppColors.ink,
                enabled: _controller.selected != null,
                onTap: _controller.revealSelectedWord,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Check',
                icon: Icons.check_rounded,
                color: AppColors.green,
                enabled: _controller.filledCells != 0,
                onTap: _controller.checkAnswers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          widget.puzzle.subtitle,
          style: const TextStyle(
              fontSize: 14.5, height: 1.35, color: AppColors.inkSoft),
        ),
      );

  Widget _illustration({double height = 160}) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          widget.puzzle.image,
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
