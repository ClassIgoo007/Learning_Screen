import 'package:flutter/material.dart';

import '../features/science/data/biology_topics.dart';
import '../features/science/screens/topic_home_screen.dart';
import '../services/openai_service.dart';
import '../widgets/section_hub.dart';

/// Top-level Science hub with Biology, Physics, and Chemistry branches.
class ScienceHubScreen extends StatelessWidget {
  const ScienceHubScreen({super.key, required this.openAI});

  final OpenAIService openAI;

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Explore & Discover',
      heading: 'Science',
      highlight: 'Lab',
      tagline: 'Explore biology, physics, and chemistry through reading and quizzes',
      heroImage: 'assets/sec_science.png',
      accent: const Color(0xFF00897B),
      cards: [
        HubCardItem(
          title: 'Biology',
          subtitle: 'DNA, photosynthesis, and how cells work',
          icon: Icons.biotech_rounded,
          color: const Color(0xFF00897B),
          image: 'assets/sec_biology.png',
          builder: (_) => BiologyHubScreen(openAI: openAI),
        ),
        HubCardItem(
          title: 'Physics',
          subtitle: 'Forces, energy, and motion — coming soon',
          icon: Icons.bolt_rounded,
          color: const Color(0xFF5C6BC0),
          image: 'assets/sec_physics.png',
          builder: (_) => const SubjectComingSoonScreen(
            subject: 'Physics',
            tagline: 'Explore forces, energy, and motion',
            heroImage: 'assets/sec_physics.png',
            accent: Color(0xFF5C6BC0),
          ),
        ),
        HubCardItem(
          title: 'Chemistry',
          subtitle: 'Elements, reactions, and matter — coming soon',
          icon: Icons.science_rounded,
          color: const Color(0xFFE65100),
          image: 'assets/sec_chemistry.png',
          builder: (_) => const SubjectComingSoonScreen(
            subject: 'Chemistry',
            tagline: 'Discover elements, reactions, and matter',
            heroImage: 'assets/sec_chemistry.png',
            accent: Color(0xFFE65100),
          ),
        ),
      ],
    );
  }
}

/// Biology catalog of reading topics.
class BiologyHubScreen extends StatelessWidget {
  const BiologyHubScreen({super.key, required this.openAI});

  final OpenAIService openAI;

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Living Things',
      heading: 'Biology',
      highlight: 'Reading',
      tagline: 'Read a passage, study the diagram, then test what you learned',
      heroImage: 'assets/sec_biology.png',
      accent: const Color(0xFF00897B),
      showHero: false,
      cards: [
        for (final topic in kBiologyTopics)
          HubCardItem(
            title: topic.title,
            subtitle: topic.tagline,
            icon: Icons.menu_book_rounded,
            color: topic.accent,
            image: topic.heroImage,
            builder: (_) => TopicHomeScreen(topic: topic, openAI: openAI),
          ),
      ],
    );
  }
}

/// Placeholder intro for science subjects not yet built.
class SubjectComingSoonScreen extends StatelessWidget {
  const SubjectComingSoonScreen({
    super.key,
    required this.subject,
    required this.tagline,
    required this.heroImage,
    required this.accent,
  });

  final String subject;
  final String tagline;
  final String heroImage;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Coming Soon',
      heading: subject,
      highlight: 'Lab',
      tagline: tagline,
      heroImage: heroImage,
      accent: accent,
      cards: const [],
    );
  }
}
