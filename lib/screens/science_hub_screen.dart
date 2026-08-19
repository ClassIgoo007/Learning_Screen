import 'package:flutter/material.dart';

import '../features/physics/bernoulli/screens/bernoulli_home_screen.dart';
import '../features/physics/cloud_formation/screens/cloud_formation_shell.dart';
import '../features/physics/heat_and_temperature/screens/heat_and_temperature_shell.dart';
import '../features/physics/kinetic_theory/screens/kinetic_theory_shell.dart';
import '../features/physics/newtons_apple/screens/newton_scene_screen.dart';
import '../features/science/data/biology_topics.dart';
import '../features/science/screens/topic_home_screen.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
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
      tagline:
          'Explore biology, physics, and chemistry through reading and quizzes',
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
          subtitle: 'Bernoulli, Newton, cloud formation, and more',
          icon: Icons.bolt_rounded,
          color: const Color(0xFF5C6BC0),
          image: 'assets/sec_physics.png',
          builder: (_) => PhysicsHubScreen(openAI: openAI),
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

/// Physics catalog — interactive labs and quizzes.
class PhysicsHubScreen extends StatelessWidget {
  const PhysicsHubScreen({super.key, required this.openAI});

  final OpenAIService openAI;

  @override
  Widget build(BuildContext context) {
    return SectionHubScreen(
      badge: 'Forces & Motion',
      heading: 'Physics',
      highlight: 'Lab',
      tagline:
          'Explore motion, pressure, gravity, and weather with interactive labs',
      heroImage: 'assets/sec_physics.png',
      accent: const Color(0xFF5C6BC0),
      showHero: false,
      cards: [
        HubCardItem(
          title: "Bernoulli's Principle",
          subtitle: 'Watch pressure drop in a Venturi tube, then quiz yourself',
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF5C6BC0),
          image: 'assets/sec_physics.png',
          builder: (_) => BernoulliHomeScreen(openAI: openAI),
        ),
        HubCardItem(
          title: "Newton's Apple",
          subtitle:
              'Watch gravity pull an apple down and reveal F = G m₁m₂ / r²',
          icon: Icons.park_rounded,
          color: const Color(0xFF43A047),
          image: 'assets/newtons_apple_preview.png',
          builder: (_) => const NewtonSceneScreen(),
        ),
        HubCardItem(
          title: 'Cloud Formation',
          subtitle:
              'Animate rain in a cumulonimbus cloud, then answer questions',
          icon: Icons.cloud_rounded,
          color: const Color(0xFF0288D1),
          image: 'assets/cloud_formation_preview.png',
          builder: (_) => CloudFormationShell(openAI: openAI),
        ),
        HubCardItem(
          title: 'Kinetic Theory of Gases',
          subtitle:
              'Watch molecules bombard the walls of a vessel, then answer questions',
          icon: Icons.scatter_plot_rounded,
          color: AppColors.violet,
          image: 'assets/kinetic_theory_thumbnail.png',
          builder: (_) => KineticTheoryShell(openAI: openAI),
        ),
        HubCardItem(
          title: 'Heat and Temperature',
          subtitle:
              'Watch a plasma jet and a cryogenic cycle, then answer questions',
          icon: Icons.thermostat_rounded,
          color: AppColors.yellow,
          image: 'assets/heat_temperature_preview.png',
          builder: (_) => HeatAndTemperatureShell(openAI: openAI),
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
