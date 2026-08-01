import 'package:flutter/material.dart';

import '../features/activity/models/activity.dart';
import '../features/activity/screens/activity_intro_screen.dart';
import '../features/crossword/models/crossword.dart';
import '../features/crossword/screens/crossword_intro_screen.dart';
import '../models/quiz_session.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/section_hub.dart';
import 'welcome_screen.dart';

/// Language Arts hub: phonics, crosswords, and sentence activities.
class LanguageArtsScreen extends StatelessWidget {
  const LanguageArtsScreen({
    super.key,
    required this.openAI,
    required this.tts,
    required this.store,
  });

  final OpenAIService openAI;
  final TtsService tts;
  final SessionStore store;

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Reading & Phonics',
      heading: 'Language',
      highlight: 'Arts',
      tagline: 'Build reading skills with phonics, crosswords, and word activities',
      heroImage: 'assets/sec_phonics.png',
      accent: AppColors.blue,
      cards: [
        HubCardItem(
          title: 'Phonics Practice',
          subtitle: 'Hear a word and pick the right spelling',
          icon: Icons.spellcheck_rounded,
          color: AppColors.blue,
          image: 'assets/mascot_welcome.png',
          builder: (_) =>
              WelcomeScreen(openAI: openAI, tts: tts, store: store),
        ),
        HubCardItem(
          title: 'Crosswords',
          subtitle: 'Long vowel and oi/oy word puzzles',
          icon: Icons.grid_on_rounded,
          color: AppColors.green,
          image: 'assets/sec_crosswords.png',
          builder: (_) => const CrosswordsHubScreen(),
        ),
        HubCardItem(
          title: 'Activities',
          subtitle: 'Sentences and word-search challenges',
          icon: Icons.search_rounded,
          color: AppColors.yellow,
          image: 'assets/sec_activities.png',
          builder: (_) => const ActivitiesHubScreen(),
        ),
      ],
    );
  }
}

/// All crossword games in one place.
class CrosswordsHubScreen extends StatelessWidget {
  const CrosswordsHubScreen({super.key});

  static const _puzzles = [
    (kLongAPuzzle, AppColors.green),
    (kLongIPuzzle, AppColors.blueDark),
    (kLongOPuzzle, AppColors.blue),
    (kOiOyPuzzle, AppColors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Word Puzzles',
      heading: 'Long Vowel',
      highlight: 'Crosswords',
      tagline: 'Read the clues and fill each grid with the right words',
      heroImage: 'assets/sec_crosswords.png',
      accent: AppColors.green,
      showHero: false,
      cards: [
        for (final (puzzle, color) in _puzzles)
          HubCardItem(
            title: puzzle.title,
            subtitle: puzzle.tagline,
            icon: Icons.grid_on_rounded,
            color: color,
            image: puzzle.image,
            builder: (_) => CrosswordIntroScreen(puzzle: puzzle),
          ),
      ],
    );
  }
}

/// All sentence + word-search activities in one place.
class ActivitiesHubScreen extends StatelessWidget {
  const ActivitiesHubScreen({super.key});

  static const _activities = [
    (kLongEActivity, AppColors.yellow),
    (kLongUActivity, AppColors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Word Search',
      heading: 'Sentence',
      highlight: 'Activities',
      tagline: 'Finish the sentences, then find every word in the puzzle',
      heroImage: 'assets/sec_activities.png',
      accent: AppColors.yellow,
      showHero: false,
      cards: [
        for (final (activity, color) in _activities)
          HubCardItem(
            title: activity.title,
            subtitle: activity.tagline,
            icon: Icons.search_rounded,
            color: color,
            image: activity.image,
            builder: (_) => ActivityIntroScreen(activity: activity),
          ),
      ],
    );
  }
}
