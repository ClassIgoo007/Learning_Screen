import 'dart:math' show Point, min;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../logic/activity_controller.dart';
import '../models/activity.dart';

/// Word-bank card. Words are struck through once used in a sentence;
/// a magnifier check appears when also found in the puzzle.
class WordBank extends StatelessWidget {
  const WordBank({super.key, required this.controller});

  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book_rounded,
                    color: AppColors.blue, size: 18),
                SizedBox(width: 8),
                Text('Word Bank',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final word in controller.activity.words) _chip(word),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String word) {
    final used = controller.isWordUsedInSentence(word);
    final found = controller.isWordFound(word);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => controller.tapBankWord(word),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: used ? AppColors.greenSoft : AppColors.blueSoft,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: used ? AppColors.green : AppColors.blue,
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.toLowerCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  decoration:
                      used ? TextDecoration.lineThrough : null,
                  color: used ? AppColors.greenDark : AppColors.ink,
                ),
              ),
              if (found)
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(Icons.search_rounded,
                      size: 15, color: AppColors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Numbered fill-in-the-blank sentences in a card. Tapping a blank makes it
/// active; tapping a filled blank clears it for correction.
class SentenceList extends StatelessWidget {
  const SentenceList({super.key, required this.controller});

  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: kCardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note_rounded,
                    color: AppColors.blue, size: 20),
                SizedBox(width: 8),
                Text('Finish the Sentences',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            for (final (i, s) in controller.activity.sentences.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: '${i + 1}. ',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.blueDark)),
                    TextSpan(text: s.before),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: _Blank(controller: controller, index: i),
                    ),
                    TextSpan(text: s.after),
                  ]),
                  style: const TextStyle(
                      fontSize: 15.5, height: 1.5, color: AppColors.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Blank extends StatelessWidget {
  const _Blank({required this.controller, required this.index});

  final ActivityController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final status = controller.blankStatus(index);
    final active = controller.activeSentence == index;
    final word = controller.answerFor(index);

    Color textColor = AppColors.ink;
    if (status == BlankStatus.correct) textColor = AppColors.greenDark;
    if (status == BlankStatus.wrong) textColor = AppColors.red;

    Color underline = AppColors.inkSoft;
    if (active) underline = AppColors.blue;
    if (status == BlankStatus.correct) underline = AppColors.green;
    if (status == BlankStatus.wrong) underline = AppColors.red;

    return GestureDetector(
      onTap: () => word == null
          ? controller.tapBlank(index)
          : controller.clearBlank(index),
      child: Container(
        constraints: const BoxConstraints(minWidth: 92),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.blueSoft : null,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            bottom: BorderSide(
                color: underline, width: active ? 2.4 : 1.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word?.toLowerCase() ?? '     ',
              style: TextStyle(
                fontSize: 15.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            if (status == BlankStatus.correct)
              const Icon(Icons.check_rounded,
                  size: 15, color: AppColors.green),
            if (status == BlankStatus.wrong)
              const Icon(Icons.close_rounded, size: 15, color: AppColors.red),
          ],
        ),
      ),
    );
  }
}

/// The letter grid inside a rounded white card.
/// Drag across letters in a straight line to cross out a word.
class WordSearchGrid extends StatelessWidget {
  const WordSearchGrid({super.key, required this.controller});

  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    final activity = controller.activity;
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
          final cell = min(available / activity.cols, 36.0);
          final gridW = cell * activity.cols;
          final gridH = cell * activity.rows;
          final selecting = controller.selectionCells.toSet();
          final found = controller.foundCells;

          Point<int>? cellAt(Offset local) {
            final c = (local.dx / cell).floor();
            final r = (local.dy / cell).floor();
            if (r < 0 || c < 0 || r >= activity.rows || c >= activity.cols) {
              return null;
            }
            return Point(r, c);
          }

          return SizedBox(
            width: gridW,
            height: gridH,
            // Eager pan wins over the parent scroll view so kids can drag
            // across vertical words without the page stealing the gesture.
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _EagerPanGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        _EagerPanGestureRecognizer>(
                  _EagerPanGestureRecognizer.new,
                  (instance) {
                    instance
                      ..onStart = (d) {
                        final p = cellAt(d.localPosition);
                        if (p != null) controller.beginGridSelect(p);
                      }
                      ..onUpdate = (d) {
                        final p = cellAt(d.localPosition);
                        if (p != null) controller.updateGridSelect(p);
                      }
                      ..onEnd = (_) {
                        controller.endGridSelect();
                      }
                      ..onCancel = controller.cancelGridSelect;
                  },
                ),
              },
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(gridW, gridH),
                    painter: _WordHighlightPainter(
                      cellSize: cell,
                      found: controller.foundPlacements,
                      selecting: controller.selectionCells,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var r = 0; r < activity.rows; r++)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var c = 0; c < activity.cols; c++)
                              _letter(
                                Point(r, c),
                                cell,
                                found.contains(Point(r, c)),
                                selecting.contains(Point(r, c)),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _letter(
    Point<int> pos,
    double size,
    bool isFound,
    bool isSelecting,
  ) {
    Color color = AppColors.ink;
    if (isFound) color = AppColors.greenDark;
    if (isSelecting) color = AppColors.blueDark;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          controller.activity.letterAt(pos),
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Draws continuous rounded “highlighter” strokes for found / selecting words.
class _WordHighlightPainter extends CustomPainter {
  _WordHighlightPainter({
    required this.cellSize,
    required this.found,
    required this.selecting,
  });

  final double cellSize;
  final List<WordPlacement> found;
  final List<Point<int>> selecting;

  @override
  void paint(Canvas canvas, Size size) {
    for (final placement in found) {
      _stroke(canvas, placement.cells, AppColors.greenSoft);
    }
    if (selecting.isNotEmpty) {
      _stroke(canvas, selecting, AppColors.blueSoft);
    }
  }

  void _stroke(Canvas canvas, List<Point<int>> cells, Color color) {
    if (cells.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thickness = cellSize * 0.78;
    if (cells.length == 1) {
      final c = cells.first;
      final center = Offset((c.y + 0.5) * cellSize, (c.x + 0.5) * cellSize);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: thickness, height: thickness),
          Radius.circular(thickness / 2),
        ),
        paint,
      );
      return;
    }

    final first = cells.first;
    final last = cells.last;
    final start = Offset(
        (first.y + 0.5) * cellSize, (first.x + 0.5) * cellSize);
    final end =
        Offset((last.y + 0.5) * cellSize, (last.x + 0.5) * cellSize);

    paint.strokeWidth = thickness;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _WordHighlightPainter old) =>
      old.cellSize != cellSize ||
      old.found != found ||
      old.selecting != selecting;
}

/// Accepts the pan immediately so the surrounding scroll view cannot steal
/// vertical word-search drags.
class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
