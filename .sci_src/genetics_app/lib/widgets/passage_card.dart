import 'package:flutter/material.dart';

import '../models/content.dart';
import 'common.dart';
import 'diagram_view.dart';

/// A reading passage with its diagram. The passage is what the questions
/// on the screen are based on, so it can be collapsed once read but is
/// always one tap away while answering.
class PassageCard extends StatefulWidget {
  const PassageCard({
    super.key,
    required this.passage,
    this.initiallyOpen = true,
  });

  final Passage passage;
  final bool initiallyOpen;

  @override
  State<PassageCard> createState() => _PassageCardState();
}

class _PassageCardState extends State<PassageCard> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kTealLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kTeal.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                const Icon(Icons.article_rounded, size: 20, color: kTealDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.passage.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kTealDark),
                  ),
                ),
                Text(_open ? 'Hide' : 'Read',
                    style: const TextStyle(
                        color: kTealDark, fontWeight: FontWeight.w600)),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: kTealDark),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 10),
            DiagramCard(
              asset: widget.passage.asset,
              label: widget.passage.imageCaption,
            ),
            const SizedBox(height: 6),
            Text(
              widget.passage.imageCaption,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            // SelectableText so a learner can highlight a phrase while
            // hunting for an answer.
            SelectableText(
              widget.passage.text,
              style: const TextStyle(fontSize: 15.5, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
