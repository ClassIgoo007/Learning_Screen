import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
import '../models/content.dart';
import '../physics/venturi.dart';
import '../theme/bernoulli_colors.dart';
import '../widgets/bernoulli_widgets.dart';
import '../widgets/venturi_figure.dart';
import 'bernoulli_quiz_screen.dart';
import 'bernoulli_simulation_screen.dart';

/// Physics topic home for Bernoulli / Venturi, matching Learning Hub chrome.
class BernoulliHomeScreen extends StatelessWidget {
  const BernoulliHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const model = VenturiModel();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    CircleBackButton(),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Bernoulli's Principle",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ContentWidth(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      FigureCard(
                        padding: 10,
                        child: VenturiFigure(
                          model: model,
                          running: false,
                          semanticsLabel: model.describe(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The pressure is lower in the narrow part of the tube, '
                        'where the water moves faster.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Why does squeezing a pipe lower the pressure?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: BernoulliColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The same water has to get through every second, so it '
                        'speeds up in the throat — and it can only buy that '
                        'speed with pressure. Open the simulation to pump the '
                        'flow and pinch the pipe yourself, then test what you '
                        'have worked out.',
                        style: TextStyle(
                            fontSize: 15, height: 1.45, color: AppColors.ink),
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cards = <Widget>[
                            _ActivityCard(
                              icon: Icons.science_rounded,
                              title: 'Run the experiment',
                              subtitle:
                                  'Animate Figure 1-10: change the flow and the '
                                  'throat and watch the columns respond.',
                              colour: BernoulliColors.accent,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const BernoulliSimulationScreen(),
                                ),
                              ),
                            ),
                            _ActivityCard(
                              icon: Icons.quiz_rounded,
                              title: 'Questions & answers',
                              subtitle:
                                  '${kQuizQuestions.length} questions on '
                                  'Bernoulli, with an explanation for every '
                                  'answer.',
                              colour: BernoulliColors.motion,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BernoulliQuizScreen(),
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
                        },
                      ),
                    ],
                  ),
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
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colour,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color colour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colour.withValues(alpha: 0.45)),
              boxShadow: kCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colour.withValues(alpha: 0.15),
                  child: Icon(icon, color: colour, size: 26),
                ),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 14, height: 1.35, color: AppColors.inkSoft)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Open',
                        style: TextStyle(
                            color: colour, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: colour),
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
