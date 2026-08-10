import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
import '../animation/kinetic_timeline.dart';
import '../data/lesson_data.dart';
import '../theme/palette.dart';
import 'animation_screen.dart';
import 'blank_screen.dart';
import 'choice_screen.dart';

/// Lets any descendant send the animation to a particular beat and bring that
/// tab forward — the join between a question and the figure it tests.
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

/// Kinetic theory of gases worksheet: animation + multiple choice + fill in.
/// Outer chrome matches the Learning Hub; inner worksheet keeps its own paper
/// UI, same split as the other physics lessons (see `cloud_formation_shell`).
class KineticTheoryShell extends StatefulWidget {
  const KineticTheoryShell({super.key});

  @override
  State<KineticTheoryShell> createState() => _KineticTheoryShellState();
}

class _KineticTheoryShellState extends State<KineticTheoryShell> {
  final ValueNotifier<KineticStage> _stage =
      ValueNotifier<KineticStage>(KineticStage.bombardment);

  int _index = 0;

  static const _titles = <String>[
    'Kinetic theory of gases',
    'Kinetic theory of gases',
    'A mechanical model of a gas',
  ];

  static const _subtitles = <String>[
    'Figs. 8-8 and 8-9 · animated',
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
    setState(() => _index = 0);
  }

  /// Off-screen tabs sit inside a muted ticker, so nothing animates unseen.
  Widget _page(Widget child, bool visible) =>
      TickerMode(enabled: visible, child: child);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LessonNavigator(
            showBeat: _showBeat,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titles[_index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              _subtitles[_index],
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ColoredBox(
                    color: Palette.paper,
                    child: IndexedStack(
                      index: _index,
                      children: [
                        _page(AnimationScreen(stage: _stage), _index == 0),
                        _page(
                          const ChoiceScreen(lesson: kKineticLesson),
                          _index == 1,
                        ),
                        _page(
                          const BlankScreen(lesson: kKineticLesson),
                          _index == 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: Palette.surface,
                  elevation: 0,
                  child: NavigationBar(
                    selectedIndex: _index,
                    backgroundColor: Palette.surface,
                    indicatorColor: Palette.slateTint,
                    height: 64,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.scatter_plot_outlined),
                        selectedIcon:
                            Icon(Icons.scatter_plot, color: Palette.slate),
                        label: 'Animation',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.checklist_outlined),
                        selectedIcon:
                            Icon(Icons.checklist, color: Palette.slate),
                        label: 'Questions',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.edit_note_outlined),
                        selectedIcon:
                            Icon(Icons.edit_note, color: Palette.slate),
                        label: 'Blanks',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
