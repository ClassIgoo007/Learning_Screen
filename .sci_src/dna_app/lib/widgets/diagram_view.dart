import 'package:flutter/material.dart';

import 'common.dart';

const String kDiagramAsset = 'assets/dna_diagram.jpg';

/// The transcription and translation diagram, shown as a tappable card.
/// Tapping opens a full-screen viewer with pinch-to-zoom, because the
/// labels (thylakoid, stroma, grana...) are small on a phone.
class DiagramCard extends StatelessWidget {
  const DiagramCard({super.key, this.caption = true});

  final bool caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Transcription and translation diagram. Double tap to open and zoom.',
          image: true,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => openDiagram(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kTeal.withOpacity(0.35)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // cacheWidth keeps decoded memory small on phones while
                    // the full-resolution file stays available for zooming.
                    Image.asset(
                      kDiagramAsset,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      cacheWidth: 1400,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded,
                                size: 16, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Tap to zoom',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (caption) ...[
          const SizedBox(height: 6),
          const Text(
            'Study the diagram, then answer the questions.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ],
    );
  }
}

/// Full-screen, pinch-zoomable view of the diagram.
Future<void> openDiagram(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const _DiagramViewer(),
    ),
  );
}

class _DiagramViewer extends StatelessWidget {
  const _DiagramViewer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Transcription and translation diagram'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Image.asset(kDiagramAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Collapsible version used on the activity screens, so the diagram is
/// available for reference without pushing the questions off-screen.
class CollapsibleDiagram extends StatefulWidget {
  const CollapsibleDiagram({super.key, this.initiallyOpen = false});

  final bool initiallyOpen;

  @override
  State<CollapsibleDiagram> createState() => _CollapsibleDiagramState();
}

class _CollapsibleDiagramState extends State<CollapsibleDiagram> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kTealLight,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, size: 18, color: kTealDark),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Transcription and translation diagram',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: kTealDark)),
                ),
                Text(_open ? 'Hide' : 'Show',
                    style: const TextStyle(
                        color: kTealDark, fontWeight: FontWeight.w600)),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: kTealDark),
              ],
            ),
          ),
          if (_open) ...[
            const SizedBox(height: 8),
            const DiagramCard(caption: false),
          ],
        ],
      ),
    );
  }
}
