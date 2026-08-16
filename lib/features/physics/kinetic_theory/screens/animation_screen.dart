import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
import '../animation/kinetic_timeline.dart';
import '../painting/kinetic_painters.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// The animation tab: the closed vessel of Fig. 8-8 and Brown's apparatus of
/// Fig. 8-9, behind a segmented control.
///
/// The molecules must keep travelling rather than loop, so the clock here is
/// an elapsed-seconds value taken from a controller that repeats over a long
/// period; positions come from `foldBetween`, which reflects a coordinate
/// between two walls without storing anything.
class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key, required this.stage});

  final ValueNotifier<KineticStage> stage;

  @override
  State<AnimationScreen> createState() =>
      _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  static const _cycle = Duration(seconds: 120);

  late final AnimationController _clock;
  late final AnimationController _compression;
  late final AnimationController _heat;
  late final AnimationController _agitation;

  bool _running = true;
  bool? _lastReduceMotion;

  KineticStage get _stage => widget.stage.value;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: _cycle)..repeat();
    _compression = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: _stage == KineticStage.reducedVolume ? 1 : 0,
    );
    _heat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: _stage == KineticStage.raisedTemperature ? 1 : 0,
    );
    _agitation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      value: _stage == KineticStage.fastWheel ? 1 : 0,
    );
    widget.stage.addListener(_onStageRequested);
  }

  @override
  void dispose() {
    widget.stage.removeListener(_onStageRequested);
    _clock.dispose();
    _compression.dispose();
    _heat.dispose();
    _agitation.dispose();
    super.dispose();
  }

  /// Beats 2 and 3 are deliberately exclusive: the text changes one thing at a
  /// time, and so does the animation.
  void _onStageRequested() {
    setState(() {});
    const curve = Curves.easeInOut;
    if (_stage.isVessel) {
      _compression.animateTo(
          _stage == KineticStage.reducedVolume ? 1 : 0, curve: curve);
      _heat.animateTo(
          _stage == KineticStage.raisedTemperature ? 1 : 0, curve: curve);
    } else {
      _agitation.animateTo(
          _stage == KineticStage.fastWheel ? 1 : 0, curve: curve);
    }
  }

  void _select(KineticStage stage) => widget.stage.value = stage;

  void _togglePlay() {
    setState(() => _running = !_running);
    _running ? _clock.repeat() : _clock.stop();
  }

  /// Elapsed seconds, which is what the molecule and ball positions fold.
  double get _seconds => _clock.value * _cycle.inSeconds;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _lastReduceMotion) {
      _lastReduceMotion = reduceMotion;
      // The clock must resume the moment reduced motion is no longer
      // requested — molecules keep travelling in every beat, always.
      if (reduceMotion) {
        _clock.stop();
      } else if (_running) {
        _clock.repeat();
      }
    }

    final vessel = _stage.isVessel;
    final beats =
        KineticStage.values.where((s) => s.isVessel == vessel).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(Sizes.gutter, 16, Sizes.gutter, 28),
      children: [
        ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Controls grouped above the canvas — Cloud Formation puts its
              // beat picker below the figure; Kinetic Theory leads with the
              // controls so the figure reads as the result of a choice
              // already made, not the first thing to look at.
              SegmentedPicker(
                left: 'Closed vessel · 8-8',
                right: 'Ping-pong model · 8-9',
                leftSelected: vessel,
                onLeft: () => _select(KineticStage.bombardment),
                onRight: () => _select(KineticStage.slowWheel),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!reduceMotion)
                    ControlPill(
                      icon: _running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: _running ? 'Pause' : 'Play',
                      onTap: _togglePlay,
                    ),
                  for (final s in beats)
                    ControlPill(
                      label: '${s.beat} · ${s.label}',
                      selected: s == _stage,
                      onTap: () => _select(s),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              FigureFrame(
                accent: Palette.slate,
                caption: vessel
                    ? '8-8 — the molecules of gas are reflected '
                        'from the wall and thereby exert a pressure'
                    : '8-9 — Brown\u2019s apparatus for '
                        'demonstrating the kinetic theory of gases',
                child: RepaintBoundary(
                  child: vessel
                      ? ScaledCanvas(
                          size: VesselMetrics.canvas,
                          animation: Listenable.merge(
                              [_clock, _compression, _heat]),
                          painterBuilder: () => VesselPainter(
                            VesselState(
                              t: _seconds,
                              compression: _compression.value,
                              heat: _heat.value,
                            ),
                            labelColor: Palette.inkSoft,
                          ),
                        )
                      : ScaledCanvas(
                          size: ApparatusMetrics.canvas,
                          animation:
                              Listenable.merge([_clock, _agitation]),
                          painterBuilder: () => ApparatusPainter(
                            ApparatusState(
                              t: _seconds,
                              agitation: _agitation.value,
                            ),
                            labelColor: Palette.inkSoft,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              CaptionPanel(
                title: 'Beat ${_stage.beat} · ${_stage.label}',
                body: _stage.caption,
              ),
              const SizedBox(height: 14),
              Text(
                vessel
                    ? 'The gauge on the right reads A × T / V. Squeezing the '
                        'vessel and warming it move it the same way, for two '
                        'quite different reasons.'
                    : 'Nothing about the balls changes except how hard they '
                        'are kicked — which is the whole claim the model is '
                        'making about temperature.',
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Palette.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
