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

/// Kinetic theory worksheet with instrument-lab chrome: violet accent rail,
/// denser paper, and a bottom icon rail — not Cloud's top capsules or Heat's
/// thermal dual-tone bar.
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

  static const _tabs = <(IconData, IconData, String)>[
    (Icons.scatter_plot_outlined, Icons.scatter_plot, 'Model'),
    (Icons.fact_check_outlined, Icons.fact_check, 'Check'),
    (Icons.notes_outlined, Icons.notes, 'Notes'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Palette.slate,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LAB',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Palette.slate,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Fig. ${_index == 0 ? '8-8 / 8-9' : _index == 1 ? 'Q' : 'B'}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Palette.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _titles[_index],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              _subtitles[_index],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.paper,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Palette.hairline, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 5,
                            decoration: const BoxDecoration(
                              color: Palette.slate,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: IndexedStack(
                              index: _index,
                              children: [
                                _page(
                                  AnimationScreen(stage: _stage),
                                  _index == 0,
                                ),
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _LabTabRail(
                  index: _index,
                  tabs: _tabs,
                  onSelect: (i) => setState(() => _index = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Square-edged bottom rail — Kinetic's instrument-panel navigation.
class _LabTabRail extends StatelessWidget {
  const _LabTabRail({
    required this.index,
    required this.tabs,
    required this.onSelect,
  });

  final int index;
  final List<(IconData, IconData, String)> tabs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelect(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: index == i
                              ? Palette.slateTint
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: index == i
                                ? Palette.slate
                                : Palette.hairline,
                            width: index == i ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              index == i ? tabs[i].$2 : tabs[i].$1,
                              size: 22,
                              color: index == i
                                  ? Palette.slate
                                  : Palette.inkSoft,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tabs[i].$3,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: index == i
                                    ? Palette.slate
                                    : Palette.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
