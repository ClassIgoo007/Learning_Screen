import 'package:flutter/material.dart';

import '../../../services/openai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../models/science_content.dart';
import '../widgets/science_widgets.dart';
import 'science_blanks_screen.dart';
import 'science_quiz_screen.dart';

/// Topic home: introduces the science reading topic and launches either
/// the Q&A or fill-in-the-blanks activity.
class TopicHomeScreen extends StatelessWidget {
  const TopicHomeScreen({
    super.key,
    required this.topic,
    required this.openAI,
  });

  final ScienceTopic topic;
  final OpenAIService openAI;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        topic.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  children: [
                    Text(
                      topic.tagline,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic.intro,
                      style: const TextStyle(
                          fontSize: 15, height: 1.4, color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DiagramCard(
                        asset: topic.heroImage,
                        label: topic.title,
                        accent: topic.accent,
                        maxHeight: 220,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(builder: (context, constraints) {
                      final cards = [
                        _ActivityCard(
                          topic: topic,
                          icon: Icons.quiz_rounded,
                          title: topic.quiz.hasPassage
                              ? 'Passage 1 + Questions'
                              : 'Question & Answer',
                          subtitle:
                              '${topic.questions.length} multiple-choice questions',
                          preview: topic.quiz.diagram,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ScienceQuizScreen(
                                  topic: topic, openAI: openAI),
                            ),
                          ),
                        ),
                        _ActivityCard(
                          topic: topic,
                          icon: Icons.edit_note_rounded,
                          title: topic.blanks.hasPassage
                              ? 'Passage 2 + Fill in the Blanks'
                              : 'Fill in the Blanks',
                          subtitle:
                              '${topic.blankItems.length} sentences to complete',
                          preview: topic.blanks.diagram,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ScienceBlanksScreen(
                                  topic: topic, openAI: openAI),
                            ),
                          ),
                        ),
                      ];
                      if (constraints.maxWidth >= 620) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 14),
                            Expanded(child: cards[1]),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          cards[0],
                          const SizedBox(height: 14),
                          cards[1],
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    WordBankStrip(words: topic.wordBank, accent: topic.accent),
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
  const _ActivityCard({
    required this.topic,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.onTap,
  });

  final ScienceTopic topic;
  final IconData icon;
  final String title;
  final String subtitle;
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: kCardShadow,
        border: Border.all(color: topic.accent.withValues(alpha: 0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: AppColors.blueSoft,
                    height: 120,
                    width: double.infinity,
                    child: Image.asset(preview, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(icon, color: topic.accent, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.inkSoft)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Start',
                        style: TextStyle(
                            color: topic.accent, fontWeight: FontWeight.w800)),
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: topic.accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
