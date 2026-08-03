import 'package:flutter/material.dart';

import '../models/content.dart';
import '../physics/venturi.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/venturi_figure.dart';
import 'quiz_screen.dart';
import 'simulation_screen.dart';

/// Entry screen: a still of the figure, then the two activities.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    // The preview does not animate: it is a poster, not the experiment, and
    // an idle ticker on the home screen is wasted battery.
    const model = VenturiModel();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Bernoulli's Principle",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FigureCard(
                padding: 10,
                child: VenturiFigure(
                  model: model,
                  running: false,
                  semanticsLabel: model.describe(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The pressure is lower in the narrow part of the tube, where '
                'the water moves faster.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: context.scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Text(
                'Why does squeezing a pipe lower the pressure?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.scheme.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'The same water has to get through every second, so it speeds '
                'up in the throat — and it can only buy that speed with '
                'pressure. Open the simulation to pump the flow and pinch the '
                'pipe yourself, then test what you have worked out.',
                style: TextStyle(fontSize: 15, height: 1.45),
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
                      colour: context.scheme.primary,
                      onTap: () => Navigator.of(context)
                          .pushNamed(SimulationScreen.routeName),
                    ),
                    _ActivityCard(
                      icon: Icons.quiz_rounded,
                      title: 'Questions & answers',
                      subtitle:
                          '${kQuizQuestions.length} questions on Bernoulli, '
                          'with an explanation for every answer.',
                      colour: context.colours.motion,
                      onTap: () => Navigator.of(context)
                          .pushNamed(QuizScreen.routeName),
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
                    children: [cards[0], const SizedBox(height: 14), cards[1]],
                  );
                },
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colour.withOpacity(0.5)),
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
                  backgroundColor: colour.withOpacity(0.15),
                  child: Icon(icon, color: colour, size: 26),
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
                    Text('Open',
                        style: TextStyle(
                            color: colour, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: colour),
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
