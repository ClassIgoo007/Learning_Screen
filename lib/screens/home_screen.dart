import 'package:flutter/material.dart';

import '../models/quiz_session.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'language_arts_screen.dart';
import 'science_hub_screen.dart';

/// Main landing page: choose Language Arts or Science.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.openAI,
    required this.tts,
    required this.store,
  });

  final OpenAIService openAI;
  final TtsService tts;
  final SessionStore store;

  void _openLanguageArts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LanguageArtsScreen(
          openAI: openAI,
          tts: tts,
          store: store,
        ),
      ),
    );
  }

  void _openScience(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScienceHubScreen()),
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
                const _SafeBadge(),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        color: AppColors.ink,
                      ),
                      children: [
                        TextSpan(text: 'Fun Ways to\n'),
                        TextSpan(
                            text: 'Learn',
                            style: TextStyle(color: AppColors.blue)),
                        TextSpan(text: ' & '),
                        TextSpan(
                            text: 'Play',
                            style: TextStyle(color: AppColors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pick a subject and start exploring',
                    style: TextStyle(fontSize: 15, color: AppColors.inkSoft),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 20),
                    children: [
                      _MainSectionCard(
                        title: 'Language Arts',
                        subtitle: 'Phonics, crosswords, and word activities',
                        image: 'assets/sec_phonics.png',
                        color: AppColors.blue,
                        icon: Icons.menu_book_rounded,
                        onTap: () => _openLanguageArts(context),
                      ),
                      const SizedBox(height: 16),
                      _MainSectionCard(
                        title: 'Science',
                        subtitle: 'Biology, physics, and chemistry reading labs',
                        image: 'assets/sec_science.png',
                        color: const Color(0xFF00897B),
                        icon: Icons.biotech_rounded,
                        onTap: () => _openScience(context),
                      ),
                    ],
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

class _MainSectionCard extends StatelessWidget {
  const _MainSectionCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String image;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: kCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26)),
                child: Image.asset(
                  image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: color),
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

class _SafeBadge extends StatelessWidget {
  const _SafeBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: kCardShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_rounded,
                color: AppColors.green, size: 16),
            SizedBox(width: 6),
            Text('100% Kids Safe',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
