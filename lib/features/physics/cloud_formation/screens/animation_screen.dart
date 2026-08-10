import 'package:flutter/material.dart';

import '../animation/scene_metrics.dart';
import '../animation/scene_timeline.dart';
import '../painting/scene_painters.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// Screen 0 — the cloud-formation animation. One clock drives the currents,
/// the breathing cloud and the rain; a second, shorter clock cross-fades
/// between the four beats when the student picks one.
class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key, required this.stage});

  /// Owned by the shell, so a question on another tab can drive the scene to
  /// the beat it tests.
  final ValueNotifier<SceneStage> stage;

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _clock;
  late final AnimationController _stageClock;

  SceneStage get _stage => widget.stage.value;
  late double _stageFrom = _stage.beat.toDouble();
  late double _stageTo = _stage.beat.toDouble();

  bool _running = true;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _stageClock = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: 1,
    );
    widget.stage.addListener(_onStageRequested);
  }

  @override
  void dispose() {
    widget.stage.removeListener(_onStageRequested);
    _clock.dispose();
    _stageClock.dispose();
    super.dispose();
  }

  double get _stageValue {
    final eased = Curves.easeInOut.transform(_stageClock.value);
    return _stageFrom + (_stageTo - _stageFrom) * eased;
  }

  void _select(SceneStage stage) => widget.stage.value = stage;

  /// Cross-fades from wherever the scene currently is to the requested beat.
  void _onStageRequested() {
    final target = _stage.beat.toDouble();
    if (target == _stageTo) return;
    setState(() {
      _stageFrom = _stageValue;
      _stageTo = target;
    });
    _stageClock.forward(from: 0);
  }

  void _togglePlay() {
    setState(() => _running = !_running);
    _running ? _clock.repeat() : _clock.stop();
  }

  @override
  Widget build(BuildContext context) {
    // Honour the platform's reduced-motion setting: hold a single frame.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _clock.isAnimating) _clock.stop();

    return ListView(
      padding: const EdgeInsets.fromLTRB(Sizes.gutter, 16, Sizes.gutter, 28),
      children: [
        ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                decoration: BoxDecoration(
                  color: Palette.surface,
                  borderRadius: BorderRadius.circular(Sizes.cardRadius),
                  border: Border.all(color: Palette.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RepaintBoundary(
                      child: AspectRatio(
                        aspectRatio: SceneMetrics.canvas.width /
                            SceneMetrics.canvas.height,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: SceneMetrics.canvas.width,
                            height: SceneMetrics.canvas.height,
                            child: _SceneStageView(
                              clock: _clock,
                              stageClock: _stageClock,
                              stageValue: () => _stageValue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fig. 17-11 — the formation of rain in a cumulonimbus '
                      'cloud',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: Palette.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!reduceMotion)
                    _ControlPill(
                      icon: _running ? Icons.pause : Icons.play_arrow,
                      label: _running ? 'Pause' : 'Play',
                      onTap: _togglePlay,
                    ),
                  for (final s in SceneStage.values)
                    _ControlPill(
                      label: '${s.beat} · ${s.label}',
                      selected: s == _stage,
                      onTap: () => _select(s),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: Palette.slateTint,
                  borderRadius: BorderRadius.circular(Sizes.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beat ${_stage.beat} · ${_stage.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Palette.slate,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _stage.caption,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: Palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'The amber currents keep running in every beat — the updraft '
                'does not stop while the storm lives.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Palette.inkSoft,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'BEAT CAPTIONS',
                style: TextStyle(
                  fontSize: 11.5,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                  color: Palette.inkSoft,
                ),
              ),
              const SizedBox(height: 10),
              for (final s in SceneStage.values) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Palette.ink,
                      ),
                      children: [
                        TextSpan(
                          text: '${s.beat} · ${s.label} — ',
                          style: TextStyle(
                            fontWeight: s == _stage
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: s == _stage ? Palette.slate : Palette.ink,
                          ),
                        ),
                        TextSpan(text: s.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Stacks the painted layers on the fixed design canvas.
class _SceneStageView extends StatelessWidget {
  const _SceneStageView({
    required this.clock,
    required this.stageClock,
    required this.stageValue,
  });

  final Animation<double> clock;
  final Animation<double> stageClock;
  final double Function() stageValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Static layer — behind its own boundary, never repaints.
        const RepaintBoundary(
          child: CustomPaint(painter: GroundPainter()),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([clock, stageClock]),
          builder: (context, _) {
            final state = SceneState.fromProgress(clock.value, stageValue());
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: CloudPainter(state)),
                CustomPaint(
                  painter: RainPainter(state, labelColor: Palette.inkSoft),
                ),
                CustomPaint(
                  painter: CurrentsPainter(state, labelColor: Palette.inkSoft),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ControlPill extends StatelessWidget {
  const _ControlPill({
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Palette.slate : Palette.inkSoft;
    return Material(
      color: selected ? Palette.slateTint : Palette.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Palette.slate : Palette.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: fg,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
