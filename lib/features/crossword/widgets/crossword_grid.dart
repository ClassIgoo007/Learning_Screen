import 'dart:math' show Point, min;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../logic/crossword_controller.dart';

/// Renders the crossword grid inside a rounded white card. Cells size
/// themselves to the available width (capped so they never get too large).
class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({super.key, required this.controller});

  final CrosswordController controller;

  @override
  Widget build(BuildContext context) {
    final puzzle = controller.puzzle;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: kCardShadow,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final available =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
          final cell = min(available / puzzle.cols, 38.0);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < puzzle.rows; r++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var c = 0; c < puzzle.cols; c++)
                      _buildCell(Point(r, c), cell),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCell(Point<int> pos, double size) {
    final puzzle = controller.puzzle;
    if (puzzle.solutionAt(pos) == null) {
      return SizedBox(width: size, height: size); // not part of any word
    }

    final status = controller.statusAt(pos);
    final inWord = controller.isInSelectedWord(pos);
    final isCursor = controller.cursorCell == pos;
    final number = puzzle.numberAt(pos);

    Color fill = Colors.white;
    if (status == CellStatus.correct) fill = AppColors.greenSoft;
    if (status == CellStatus.wrong) fill = AppColors.redSoft;
    if (isCursor) {
      fill = AppColors.blue.withValues(alpha: 0.35);
    } else if (inWord &&
        (status == CellStatus.empty || status == CellStatus.filled)) {
      fill = AppColors.blueSoft;
    }

    return GestureDetector(
      onTap: () => controller.tapCell(pos),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(
            color: inWord ? AppColors.blue : const Color(0xFFC3D2E0),
            width: inWord ? 1.6 : 0.8,
          ),
        ),
        child: Stack(
          children: [
            if (number != null)
              Positioned(
                top: 1,
                left: 2,
                child: Text('$number',
                    style: TextStyle(
                        fontSize: size * 0.26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkSoft)),
              ),
            Center(
              child: Text(
                controller.letterAt(pos),
                style: TextStyle(
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.w700,
                  color: status == CellStatus.wrong
                      ? AppColors.red
                      : status == CellStatus.correct
                          ? AppColors.greenDark
                          : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
