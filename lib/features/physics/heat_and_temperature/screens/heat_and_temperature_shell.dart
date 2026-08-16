import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
import '../animation/cryo_timeline.dart';
import '../data/lesson_data.dart';
import '../theme/palette.dart';
import 'animation_screen.dart';
import 'blank_screen.dart';
import 'choice_screen.dart';
import 'table_screen.dart';

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

/// Heat and temperature worksheet with thermal dual-tone chrome: warm peach
/// paper, hot↔cold header ribbon, and a bottom thermal tab bar — distinct
/// from Cloud's top sky capsules and Kinetic's lab rail.
class HeatAndTemperatureShell extends StatefulWidget {
  const HeatAndTemperatureShell({super.key});

  @override
  State<HeatAndTemperatureShell> createState() =>
      _HeatAndTemperatureShellState();
}

class _HeatAndTemperatureShellState extends State<HeatAndTemperatureShell> {
  final ValueNotifier<CryoStage> _stage =
      ValueNotifier<CryoStage>(CryoStage.compression);

  int _index = 0;

  static const _titles = <String>[
    'Heat and temperature',
    'The principle of cryogenics',
    'Very hot and very cold',
    'Tables 4-2 and 4-3',
  ];

  static const _subtitles = <String>[
    'Figs. 4-8 and 4-9 · animated',
    'Part 1 · Multiple choice',
    'Part 2 · Fill in',
    'Reference tables',
  ];

  static const _tabs = <(IconData, IconData, String)>[
    (Icons.thermostat_outlined, Icons.thermostat, 'Heat'),
    (Icons.checklist_outlined, Icons.checklist, 'Quiz'),
    (Icons.edit_note_outlined, Icons.edit_note, 'Blanks'),
    (Icons.table_chart_outlined, Icons.table_chart, 'Tables'),
  ];

  @override
  void dispose() {
    _stage.dispose();
    super.dispose();
  }

  void _showBeat(int beat) {
    _stage.value = CryoStage.fromBeat(beat);
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 12),
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
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _ThermalRibbon(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Palette.paper,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IndexedStack(
                      index: _index,
                      children: [
                        _page(AnimationScreen(stage: _stage), _index == 0),
                        _page(
                          const ChoiceScreen(lesson: kCryogenicsLesson),
                          _index == 1,
                        ),
                        _page(
                          const BlankScreen(lesson: kCryogenicsLesson),
                          _index == 2,
                        ),
                        _page(const TableScreen(), _index == 3),
                      ],
                    ),
                  ),
                ),
                _ThermalTabBar(
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

/// Hot → cold spectrum ribbon under the title.
class _ThermalRibbon extends StatelessWidget {
  const _ThermalRibbon();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Palette.hot,
            Palette.slate,
            Palette.cold,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.hot.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(-2, 3),
          ),
          BoxShadow(
            color: Palette.cold.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 16, color: Colors.white.withValues(alpha: 0.95)),
                const SizedBox(width: 4),
                Text(
                  'Hot',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 18,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ac_unit_rounded,
                    size: 16, color: Colors.white.withValues(alpha: 0.95)),
                const SizedBox(width: 4),
                Text(
                  'Cold',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom thermal tabs with a hot↔cold underline indicator.
class _ThermalTabBar extends StatelessWidget {
  const _ThermalTabBar({
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.hot, Palette.slate, Palette.cold],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onSelect(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: index == i
                                      ? Palette.slateTint
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  index == i ? tabs[i].$2 : tabs[i].$1,
                                  size: 22,
                                  color: index == i
                                      ? Palette.ink
                                      : Palette.inkSoft,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tabs[i].$3,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: index == i
                                      ? Palette.ink
                                      : Palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
