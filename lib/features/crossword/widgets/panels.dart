import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../logic/crossword_controller.dart';
import '../models/crossword.dart';

/// Rounded word-bank card, matching the app's modern card style.
class WordBank extends StatelessWidget {
  const WordBank({super.key, required this.controller});

  final CrosswordController controller;

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
                for (final entry in controller.puzzle.entries)
                  _wordChip(entry),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordChip(CrosswordEntry entry) {
    final solved = controller.isEntrySolved(entry);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: solved ? AppColors.greenSoft : AppColors.blueSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        entry.answer.toLowerCase(),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          decoration: solved ? TextDecoration.lineThrough : null,
          color: solved ? AppColors.greenDark : AppColors.ink,
        ),
      ),
    );
  }
}

/// "Across" / "Down" clue lists; tapping a clue selects that word.
class CluesPanel extends StatelessWidget {
  const CluesPanel({super.key, required this.controller});

  final CrosswordController controller;

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
            _header('Across'),
            for (final e in controller.puzzle.across) _clue(e),
            const SizedBox(height: 14),
            _header('Down'),
            for (final e in controller.puzzle.down) _clue(e),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13.5)),
      );

  Widget _clue(CrosswordEntry e) {
    final selected = controller.selected == e;
    final solved = controller.isEntrySolved(e);
    return InkWell(
      onTap: () => controller.selectEntry(e),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueSoft : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: '${e.number}. ',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.blueDark)),
            TextSpan(
              text: e.clue,
              style: TextStyle(
                decoration: solved ? TextDecoration.lineThrough : null,
                color: solved ? AppColors.inkSoft : AppColors.ink,
              ),
            ),
            if (solved)
              const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.green),
                ),
              ),
          ]),
          style: const TextStyle(fontSize: 14.5, height: 1.3),
        ),
      ),
    );
  }
}

/// Compact on-screen A-Z keyboard — consistent input on every platform,
/// no soft-keyboard focus hacks.
class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({super.key, required this.controller});

  final CrosswordController controller;

  static const _rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final enabled = controller.selected != null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _rows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final letter in _rows[i].split(''))
                      _key(letter, enabled,
                          () => controller.typeLetter(letter)),
                    if (i == _rows.length - 1)
                      _key('⌫', enabled, controller.backspace, wide: true),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _key(String label, bool enabled, VoidCallback onTap,
      {bool wide = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Material(
        color: enabled ? Colors.white : const Color(0xFFEEF3F8),
        borderRadius: BorderRadius.circular(10),
        elevation: 0,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: wide ? 54 : 32,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: enabled ? kCardShadow : null,
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.ink : AppColors.inkSoft)),
          ),
        ),
      ),
    );
  }
}
