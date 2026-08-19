import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
import '../../../../services/openai_service.dart';
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

/// Cloud formation worksheet with atmospheric chrome: mist paper, sky header
/// strip, and top capsule tabs (not a bottom NavigationBar like the lab or
/// thermal lessons).
class CloudFormationShell extends StatefulWidget {
  const CloudFormationShell({super.key, required this.openAI});

  final OpenAIService openAI;

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

  static const _tabs = <(IconData, IconData, String)>[
    (Icons.cloud_outlined, Icons.cloud_rounded, 'Sky'),
    (Icons.quiz_outlined, Icons.quiz_rounded, 'Quiz'),
    (Icons.edit_outlined, Icons.edit_rounded, 'Fill'),
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Palette.slate.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Atmosphere',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.slate,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SkyTabStrip(
                    index: _index,
                    tabs: _tabs,
                    onSelect: (i) => setState(() => _index = i),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Palette.paper,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IndexedStack(
                      index: _index,
                      children: [
                        AnimationScreen(stage: _stage),
                        ChoiceScreen(openAI: widget.openAI),
                        BlankScreen(openAI: widget.openAI),
                      ],
                    ),
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

/// Soft capsule tabs along the top — Cloud's signature chrome.
class _SkyTabStrip extends StatelessWidget {
  const _SkyTabStrip({
    required this.index,
    required this.tabs,
    required this.onSelect,
  });

  final int index;
  final List<(IconData, IconData, String)> tabs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Palette.hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: index == i ? Palette.slate : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: index == i
                          ? [
                              BoxShadow(
                                color: Palette.slate.withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index == i ? tabs[i].$2 : tabs[i].$1,
                          size: 18,
                          color: index == i ? Colors.white : Palette.inkSoft,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tabs[i].$3,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: index == i ? Colors.white : Palette.inkSoft,
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
    );
  }
}
