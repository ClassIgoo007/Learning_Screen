import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
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

/// Cloud formation worksheet: animation + multiple choice + fill-in-the-blank.
/// Outer chrome matches the Learning Hub; inner worksheet keeps its paper UI.
class CloudFormationShell extends StatefulWidget {
  const CloudFormationShell({super.key});

  @override
  State<CloudFormationShell> createState() => _CloudFormationShellState();
}

class _CloudFormationShellState extends State<CloudFormationShell> {
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
                        AnimationScreen(stage: _stage),
                        const ChoiceScreen(),
                        const BlankScreen(),
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
                        icon: Icon(Icons.cloud_queue),
                        selectedIcon:
                            Icon(Icons.cloud, color: Palette.slate),
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
