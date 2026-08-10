import 'package:flutter/material.dart';

import '../animation/scene_timeline.dart';
import '../theme/palette.dart';
import 'animation_screen.dart';
import 'blank_screen.dart';
import 'choice_screen.dart';

/// Lets any descendant send the animation to a particular beat and bring that
/// tab forward — the join between a question and the stage it tests.
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
/// between them, so switching tabs never wipes work.
class LessonShell extends StatefulWidget {
  const LessonShell({super.key});

  @override
  State<LessonShell> createState() => _LessonShellState();
}

class _LessonShellState extends State<LessonShell> {
  final ValueNotifier<SceneStage> _stage =
      ValueNotifier<SceneStage>(SceneStage.rain);

  int _index = 0;

  static const _titles = <String>[
    'Cloud formation',
    'Cloud formation',
    'Atmospheric circulation',
  ];

  static const _subtitles = <String>[
    'The sequence, animated',
    'Part 1 · Multiple choice',
    'Part 2 · Fill in',
  ];

  @override
  void dispose() {
    _stage.dispose();
    super.dispose();
  }

  void _showBeat(int beat) {
    _stage.value = SceneStage.fromBeat(beat);
    setState(() => _index = 0);
  }

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
              Text(
                _titles[_index],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Palette.ink,
                ),
              ),
              Text(
                _subtitles[_index],
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
          index: _index,
          children: [
            AnimationScreen(stage: _stage),
            const ChoiceScreen(),
            const BlankScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          backgroundColor: Palette.surface,
          indicatorColor: Palette.slateTint,
          height: 64,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.cloud_queue),
              selectedIcon: Icon(Icons.cloud, color: Palette.slate),
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
