import 'package:flutter/material.dart';

import '../models/content.dart';
import '../widgets/common.dart';
import 'blanks_screen.dart';
import 'quiz_screen.dart';

/// Entry screen: introduces both passages and launches either activity.
/// Cards stack on phones and sit side by side on tablets and desktop.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaper,
      appBar: AppBar(
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('DNA & Chromosomes',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6)),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Reading comprehension in biology',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTealDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Each activity begins with a short passage and its diagram. '
                'Read the passage, then answer the questions that follow — '
                'every answer can be found in what you have just read.',
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, constraints) {
                final cards = [
                  _ActivityCard(
                    passage: kPassageOne,
                    icon: Icons.quiz_rounded,
                    title: 'Passage 1 + Questions',
                    subtitle:
                        'The structure of DNA, then '
                        '${kQuizQuestions.length} multiple-choice questions.',
                    color: kTeal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                    ),
                  ),
                  _ActivityCard(
                    passage: kPassageTwo,
                    icon: Icons.edit_note_rounded,
                    title: 'Passage 2 + Fill in the Blanks',
                    subtitle:
                        'Chromosomes and the genome, then '
                        '${kBlankItems.length} sentences to complete.',
                    color: kAccent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BlanksScreen()),
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
              const SizedBox(height: 18),
              const WordBankStrip(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.passage,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final Passage passage;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A preview of the passage's diagram, so the two activities
              // are easy to tell apart at a glance.
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  height: 130,
                  width: double.infinity,
                  child: Image.asset(
                    passage.asset,
                    fit: BoxFit.contain,
                    cacheWidth: 600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(fontSize: 14, height: 1.35)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Start',
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
