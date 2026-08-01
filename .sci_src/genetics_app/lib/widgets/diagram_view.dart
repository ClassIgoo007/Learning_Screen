import 'package:flutter/material.dart';

import 'common.dart';

/// A diagram from a passage, shown as a tappable card.
/// Tapping opens a full-screen viewer with pinch-to-zoom, because the
/// labels in these figures are small on a phone.
class DiagramCard extends StatelessWidget {
  const DiagramCard({
    super.key,
    required this.asset,
    required this.label,
    this.maxHeight = 420,
  });

  final String asset;
  final String label;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label. Double tap to open and zoom.',
      image: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openDiagram(context, asset, label),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kTeal.withOpacity(0.35)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // cacheWidth keeps decoded memory small on phones while the
                // full-resolution file stays available for zooming.
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Image.asset(
                    asset,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    cacheWidth: 1200,
                  ),
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen, pinch-zoomable view of a diagram.
Future<void> openDiagram(BuildContext context, String asset, String label) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _DiagramViewer(asset: asset, label: label),
    ),
  );
}

class _DiagramViewer extends StatelessWidget {
  const _DiagramViewer({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(label),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
