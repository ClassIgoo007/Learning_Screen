import 'package:flutter/material.dart';

import '../features/activity/models/activity.dart';
import '../features/activity/screens/activity_intro_screen.dart';
import '../features/crossword/models/crossword.dart';
import '../features/crossword/screens/crossword_intro_screen.dart';
import '../models/quiz_session.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'welcome_screen.dart';

/// One learning game shown on the games page. Add a new [GameActivity] to the
/// list in [GamesScreen] to surface another mini-app — no other wiring needed.
class GameActivity {
  const GameActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({
    super.key,
    required this.openAI,
    required this.tts,
    required this.store,
  });

  final OpenAIService openAI;
  final TtsService tts;
  final SessionStore store;

  List<GameActivity> _activities() => [
        GameActivity(
          title: 'Phonics Practice',
          subtitle: 'Hear a word and pick the right spelling',
          icon: Icons.spellcheck_rounded,
          color: AppColors.blue,
          builder: (_) =>
              WelcomeScreen(openAI: openAI, tts: tts, store: store),
        ),
        GameActivity(
          title: 'Long-a Crossword',
          subtitle: 'Solve clues for words with the long-a sound',
          icon: Icons.grid_on_rounded,
          color: AppColors.green,
          builder: (_) => CrosswordIntroScreen(
              puzzle: kLongAPuzzle, openAI: openAI),
        ),
        GameActivity(
          title: 'Long-e Activity',
          subtitle: 'Finish sentences and hunt words in a puzzle',
          icon: Icons.search_rounded,
          color: AppColors.yellow,
          builder: (_) =>
              ActivityIntroScreen(activity: kLongEActivity, openAI: openAI),
        ),
        GameActivity(
          title: 'Long-i Crossword',
          subtitle: 'Fill-in-the-blank clues for long-i words',
          icon: Icons.grid_on_rounded,
          color: AppColors.blueDark,
          builder: (_) => CrosswordIntroScreen(
              puzzle: kLongIPuzzle, openAI: openAI),
        ),
        GameActivity(
          title: 'Long-o Crossword',
          subtitle: 'Float through clues for words with the long-o sound',
          icon: Icons.grid_on_rounded,
          color: AppColors.blue,
          builder: (_) => CrosswordIntroScreen(
              puzzle: kLongOPuzzle, openAI: openAI),
        ),
        GameActivity(
          title: 'Long-u Activity',
          subtitle: 'Finish sentences and hunt words in a puzzle',
          icon: Icons.search_rounded,
          color: AppColors.green,
          builder: (_) =>
              ActivityIntroScreen(activity: kLongUActivity, openAI: openAI),
        ),
        GameActivity(
          title: 'oi & oy Crossword',
          subtitle: "Solve clues for words with the sound in 'boy'",
          icon: Icons.grid_on_rounded,
          color: AppColors.red,
          builder: (_) => CrosswordIntroScreen(
              puzzle: kOiOyPuzzle, openAI: openAI),
        ),
      ];

  void _open(BuildContext context, GameActivity activity) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: activity.builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = _activities();
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 20, 4),
                child: Row(
                  children: [
                    CircleBackButton(),
                    SizedBox(width: 14),
                    Text(
                      'Choose a Game',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    for (final activity in activities) ...[
                      _ActivityCard(
                        activity: activity,
                        onTap: () => _open(context, activity),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 8),
                    const _ComingSoon(),
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onTap});

  final GameActivity activity;
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: activity.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(activity.icon,
                      color: activity.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        activity.subtitle,
                        style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.3,
                            color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: activity.color, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline, width: 1.6),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: AppColors.inkSoft, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'More games coming soon',
              style: TextStyle(
                  color: AppColors.inkSoft, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
