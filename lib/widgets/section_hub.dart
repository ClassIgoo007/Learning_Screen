import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';

/// One tappable card on a section hub screen.
class HubCardItem {
  const HubCardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.image,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String image;
  final WidgetBuilder builder;
}

/// Reusable intro + card list layout used for Language Arts, Science,
/// Biology, Crosswords, Activities, and similar hubs.
class SectionHubScreen extends StatelessWidget {
  const SectionHubScreen({
    super.key,
    required this.badge,
    required this.heading,
    required this.highlight,
    required this.tagline,
    required this.heroImage,
    required this.cards,
    this.accent = AppColors.blue,
    this.showHero = true,
  });

  final String badge;
  final String heading;
  final String highlight;
  final String tagline;
  final String heroImage;
  final List<HubCardItem> cards;
  final Color accent;
  final bool showHero;

  void _open(BuildContext context, HubCardItem card) {
    Navigator.of(context).push(MaterialPageRoute(builder: card.builder));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 4),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 14),
                    _Badge(label: badge, accent: accent),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                          color: AppColors.ink,
                        ),
                        children: [
                          TextSpan(text: '$heading\n'),
                          TextSpan(
                              text: highlight,
                              style: TextStyle(color: accent)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tagline,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.inkSoft),
                    ),
                    if (showHero) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          heroImage,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    for (final card in cards) ...[
                      _HubCard(
                        item: card,
                        onTap: () => _open(context, card),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.accent});

  final String label;
  final Color accent;

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
          Icon(Icons.auto_stories_rounded, color: accent, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.item, required this.onTap});

  final HubCardItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: kCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    item.image,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(item.icon, color: item.color, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.3,
                            color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: item.color, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
