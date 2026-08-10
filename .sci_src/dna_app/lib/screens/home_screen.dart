import 'package:flutter/material.dart';

import '../models/content.dart';
import '../widgets/common.dart';
import '../widgets/diagram_view.dart';
import 'blanks_screen.dart';
import 'quiz_screen.dart';

/// Entry screen: explains the topic and launches either activity.
/// Two stacked cards on phones, side by side on tablets and desktop.
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
        title: const Text('Transcription & Translation',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6)),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const DiagramCard(),
              const SizedBox(height: 16),
              const FlowBanner(),
              const SizedBox(height: 16),
              const Text(
                'How a cell turns a gene into a protein',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTealDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'A gene in DNA is transcribed into RNA, and that RNA is then '
                'translated into a protein. DNA is also replicated to make '
                'more DNA, and some viruses run the middle step backwards by '
                'reverse transcription. Choose an activity to practise what '
                'you know.',
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, constraints) {
                final cards = [
                  _ActivityCard(
                    icon: Icons.quiz_rounded,
                    title: 'Question & Answer',
                    subtitle:
                        '${kQuizQuestions.length} multiple-choice questions '
                        'with instant feedback.',
                    color: kTeal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const QuizScreen()),
                    ),
                  ),
                  _ActivityCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Fill in the Blanks',
                    subtitle:
                        '${kBlankItems.length} sentences to complete by '
                        'typing the missing word.',
                    color: kAccent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const BlanksScreen()),
                    ),
                  ),
                ];

                if (constraints.maxWidth >= 620) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
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
