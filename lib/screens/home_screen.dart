import 'package:flutter/material.dart';

import '../models/quiz_session.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'games_screen.dart';

/// The main landing page for the whole app. Leads into the games page
/// where the different mini-apps can be chosen.
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

  void _openGames(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamesScreen(openAI: openAI, tts: tts, store: store),
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
                    'A hub of playful reading and word games',
                    style: TextStyle(fontSize: 15, color: AppColors.inkSoft),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/home_hero.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                AppButton(
                  label: 'Explore Games',
                  icon: Icons.sports_esports_rounded,
                  color: AppColors.blue,
                  onTap: () => _openGames(context),
                ),
              ],
            ),
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
