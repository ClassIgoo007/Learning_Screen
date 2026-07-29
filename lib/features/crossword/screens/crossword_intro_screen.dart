import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../models/crossword.dart';
import 'crossword_screen.dart';

/// Intro/welcome screen for the crossword game, mirroring the phonics
/// welcome page: a hero illustration, heading, and a play button.
class CrosswordIntroScreen extends StatelessWidget {
  const CrosswordIntroScreen({super.key, this.puzzle = kLongAPuzzle});

  final CrosswordPuzzle puzzle;

  void _play(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrosswordScreen(puzzle: puzzle),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 14),
                    _Badge(count: puzzle.wordCount),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: AppColors.ink,
                      ),
                      children: [
                        const TextSpan(text: 'Words with\n'),
                        TextSpan(
                            text: puzzle.name,
                            style: const TextStyle(color: AppColors.blue)),
                        const TextSpan(text: ' Crossword'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    puzzle.tagline,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.inkSoft),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      puzzle.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                AppButton(
                  label: 'Play Crossword',
                  icon: Icons.grid_on_rounded,
                  color: AppColors.blue,
                  onTap: () => _play(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: kCardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.extension_rounded,
              color: AppColors.green, size: 16),
          const SizedBox(width: 6),
          Text('$count Words to Solve',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
