import 'package:flutter/material.dart';

import '../models/worksheet.dart';

/// The pink "Pronunciation Key" panel at the top of the worksheet.
class PronunciationKeyCard extends StatelessWidget {
  const PronunciationKeyCard({super.key});

  static const _pink = Color(0xFFF9D5E0);
  static const _pinkBorder = Color(0xFFD6336C);

  @override
  Widget build(BuildContext context) {
    const symbolStyle = TextStyle(
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    const wordStyle = TextStyle(fontFamily: 'monospace', fontSize: 14);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _pink,
        border: Border.all(color: _pinkBorder, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pronunciation Key',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              for (final entry in kPronunciationKey)
                SizedBox(
                  width: 90,
                  child: Row(
                    children: [
                      SizedBox(
                          width: 36,
                          child: Text(entry[0], style: symbolStyle)),
                      Expanded(
                          child: Text(entry[1], style: wordStyle)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 24, color: _pinkBorder),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ə = ', style: symbolStyle),
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    for (final ex in kSchwaExamples)
                      Text('${ex[0]} in ${ex[1]}', style: wordStyle),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
