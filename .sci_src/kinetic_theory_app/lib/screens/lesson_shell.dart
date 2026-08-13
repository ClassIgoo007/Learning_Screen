import 'package:flutter/material.dart';

import '../animation/kinetic_timeline.dart';
import '../data/lesson_data.dart';
import '../theme/palette.dart';
import 'animation_screen.dart';
import 'blank_screen.dart';
import 'choice_screen.dart';

/// Lets any descendant send the animation to a particular beat and bring that
/// screen forward — the join between a question and the figure it tests.
class LessonNavigator extends InheritedWidget {
  const LessonNavigator({
    super.key,
    required this.showBeat,
    required super.child,
  });

  final void Function(int beat) showBeat;

  static LessonNavigator? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LessonNavigator>();

  @override
  bool updateShouldNotify(LessonNavigator oldWidget) => false;
}

/// Holds the three screens. Each keeps its own answers while the student moves
/// between them, and the two that are off screen have their tickers muted so
/// nothing animates unseen.
class LessonShell extends StatefulWidget {
  const LessonShell({super.key});

  @override
  State<LessonShell> createState() => _LessonShellState();
}

class _LessonShellState extends State<LessonShell> {
  final ValueNotifier<KineticStage> _stage =
      ValueNotifier<KineticStage>(KineticStage.bombardment);

  int _tab = 0;

  static const _subtitles = <String>[
    'Figs. 8-8 and 8-9 · The figures, animated',
    'Part 1 · Multiple choice',
    'Part 2 · Fill in',
  ];

  @override
  void dispose() {
    _stage.dispose();
    super.dispose();
  }

  void _showBeat(int beat) {
    _stage.value = KineticStage.fromBeat(beat);
    setState(() => _tab = 0);
  }

  Widget _page(Widget child, bool visible) =>
      TickerMode(enabled: visible, child: child);

  @override
  Widget build(BuildContext context) {
    return LessonNavigator(
      showBeat: _showBeat,
      child: Scaffold(
        backgroundColor: Palette.paper,
        appBar: AppBar(
          backgroundColor: Palette.paper,
          surfaceTintColor: Palette.paper,
          elevation: 0,
          titleSpacing: Sizes.gutter,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kinetic theory of gases',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Palette.ink,
                ),
              ),
              Text(
                _subtitles[_tab],
                style: const TextStyle(fontSize: 12.5, color: Palette.inkSoft),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Palette.hairline),
          ),
        ),
        body: IndexedStack(
          index: _tab,
          children: [
            _page(AnimationScreen(stage: _stage), _tab == 0),
            _page(const ChoiceScreen(lesson: kKineticLesson), _tab == 1),
            _page(const BlankScreen(lesson: kKineticLesson), _tab == 2),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          backgroundColor: Palette.surface,
          indicatorColor: Palette.slateTint,
          height: 64,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.scatter_plot_outlined),
              selectedIcon: Icon(Icons.scatter_plot, color: Palette.slate),
              label: 'Animation',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist, color: Palette.slate),
              label: 'Questions',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note, color: Palette.slate),
              label: 'Blanks',
            ),
          ],
        ),
      ),
    );
  }
}
