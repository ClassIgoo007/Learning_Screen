import 'package:flutter/material.dart';

import '../../shared/modern_kit.dart';
import '../animation/cryo_timeline.dart';
import '../painting/cryo_painters.dart';
import '../painting/plasma_painters.dart';
import '../theme/palette.dart';
import '../widgets/common.dart';

/// The animation tab: the cryogenic apparatus of Fig. 4-9 and the plasma jet
/// of Fig. 4-8, behind a segmented control — the cold end of the temperature
/// scale and the hot end of it.
class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key, required this.stage});

  final ValueNotifier<CryoStage> stage;

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _clock;

  /// Where the apparatus sits between its three beats, 1.0 .. 3.0.
  late final AnimationController _cycle;

  /// 0 = the arc just struck, 1 = the jet at full temperature.
  late final AnimationController _intensity;

  /// The valve's manual override, 0 = closed .. 1 = open. Only read while
  /// [_manualValveOverride] is set; otherwise the beat drives the valve.
  late final AnimationController _manualValve;

  /// True once the student has tapped the valve directly. Cleared whenever a
  /// beat is requested (pill, segmented control or a "Watch beat" link), so
  /// beat navigation always wins and shows its own canonical valve state —
  /// the student can then resume tapping from there.
  bool _manualValveOverride = false;
  bool _manualValveOpen = false;

  bool _running = true;

  CryoStage get _stage => widget.stage.value;

  /// The stage fed to [CryoState]: the beat's own position, unless the
  /// student is manually driving the valve, in which case 1..2 (closed..open)
  /// reuses the exact compression/expansion visuals Beats 1 and 2 already
  /// define, so nothing about the physics needs to be duplicated.
  double get _effectiveStage =>
      _manualValveOverride ? 1 + _manualValve.value : _cycle.value;

  void _toggleValve() {
    final currentlyOpen = _manualValveOverride
        ? _manualValveOpen
        : CryoState(t: 0, stage: _cycle.value).valveOpen > 0.5;
    if (!_manualValveOverride) {
      // Seed the manual controller from wherever the beat currently has the
      // valve, so taking over control is seamless rather than a jump.
      _manualValve.value = CryoState(t: 0, stage: _cycle.value).valveOpen;
    }
    setState(() {
      _manualValveOverride = true;
      _manualValveOpen = !currentlyOpen;
    });
    _manualValve.animateTo(_manualValveOpen ? 1 : 0, curve: Curves.easeInOut);
  }

  void _handleApparatusTap(Offset canvasPosition) {
    // Generous relative to the drawn valve (radius 30): on the narrowest
    // phone widths the figure scales down to roughly a third size, so this
    // still clears the ~44pt minimum touch target on screen.
    const hitRadius = 85.0;
    final delta = canvasPosition - CryoMetrics.valveCentre;
    if (delta.distanceSquared <= hitRadius * hitRadius) {
      _toggleValve();
    }
  }

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _cycle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 1,
      upperBound: 3,
      value: _stage.isApparatus ? _stage.beat.toDouble() : 1,
    );
    _intensity = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      value: _stage == CryoStage.plasmaJet ? 1 : 0,
    );
    _manualValve = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    widget.stage.addListener(_onStageRequested);
  }

  @override
  void dispose() {
    widget.stage.removeListener(_onStageRequested);
    _clock.dispose();
    _cycle.dispose();
    _intensity.dispose();
    _manualValve.dispose();
    super.dispose();
  }

  void _onStageRequested() {
    setState(() => _manualValveOverride = false);
    const curve = Curves.easeInOut;
    if (_stage.isApparatus) {
      _cycle.animateTo(_stage.beat.toDouble(), curve: curve);
    } else {
      _intensity.animateTo(
          _stage == CryoStage.plasmaJet ? 1 : 0, curve: curve);
    }
  }

  void _select(CryoStage stage) => widget.stage.value = stage;

  void _togglePlay() {
    setState(() => _running = !_running);
    _running ? _clock.repeat() : _clock.stop();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _clock.isAnimating) _clock.stop();

    final apparatus = _stage.isApparatus;
    final beats =
        CryoStage.values.where((s) => s.isApparatus == apparatus).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(Sizes.gutter, 16, Sizes.gutter, 28),
      children: [
        ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Figure leads — Kinetic puts controls first; Cloud leads with
              // sky + timeline. Heat opens on the apparatus itself.
              FigureFrame(
                accent: apparatus ? Palette.cold : Palette.hot,
                caption: apparatus
                    ? '4-9 — the gas heated by compression in the '
                        'upper chamber loses heat to the surroundings, '
                        'while the gas cooled by expansion in the lower '
                        'chamber absorbs heat from them'
                    : '4-8 — a plasma jet produced by blowing a '
                        'stream of noble gas through a high-current '
                        'electric arc discharge',
                child: Semantics(
                  label: apparatus
                      ? 'Diagram of a cryogenic apparatus. A compressor '
                          'driven by an electric motor pumps gas into an '
                          'upper compression chamber, which loses heat to '
                          'the surroundings, and a valve releases it into '
                          'a lower expansion chamber, which absorbs heat.'
                      : 'Diagram of a plasma torch. Noble gas is blown '
                          'through a high-current arc and leaves the '
                          'nozzle as a jet, with a temperature scale '
                          'alongside.',
                  child: RepaintBoundary(
                    child: apparatus
                        ? ScaledCanvas(
                            size: CryoMetrics.canvas,
                            animation: Listenable.merge(
                                [_clock, _cycle, _manualValve]),
                            painterBuilder: () => CryogenicPainter(
                              CryoState(
                                  t: _clock.value, stage: _effectiveStage),
                              labelColor: Palette.inkSoft,
                            ),
                            onTap: _handleApparatusTap,
                          )
                        : ScaledCanvas(
                            size: PlasmaMetrics.canvas,
                            animation:
                                Listenable.merge([_clock, _intensity]),
                            painterBuilder: () => PlasmaPainter(
                              PlasmaState(
                                t: _clock.value,
                                intensity: _intensity.value,
                              ),
                              labelColor: Palette.inkSoft,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SegmentedPicker(
                left: 'Cryogenic cycle · 4-9',
                right: 'Plasma jet · 4-8',
                leftSelected: apparatus,
                onLeft: () => _select(CryoStage.compression),
                onRight: () => _select(CryoStage.plasmaJet),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!reduceMotion)
                    ControlPill(
                      icon: _running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: _running ? 'Pause' : 'Play',
                      onTap: _togglePlay,
                    ),
                  if (!reduceMotion) const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < beats.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            ControlPill(
                              label: '${beats[i].beat} · ${beats[i].label}',
                              selected: beats[i] == _stage,
                              onTap: () => _select(beats[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CaptionPanel(
                title: 'Beat ${_stage.beat} · ${_stage.label}',
                body: _stage.caption,
              ),
              const SizedBox(height: 14),
              Text(
                apparatus
                    ? 'Direction of heat flow is shown by wavy-tailed arrows, '
                        'as in the figure. Nothing is destroyed or created — '
                        'the heat is only moved, which is why the refrigerator '
                        'warms the kitchen while it cools the food.'
                    : 'The scale on the left places the jet against two '
                        'familiar temperatures: a kitchen flame and the '
                        'surface of the sun.',
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
