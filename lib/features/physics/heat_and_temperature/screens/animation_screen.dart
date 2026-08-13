import 'package:flutter/material.dart';

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

  bool _running = true;

  CryoStage get _stage => widget.stage.value;

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
    widget.stage.addListener(_onStageRequested);
  }

  @override
  void dispose() {
    widget.stage.removeListener(_onStageRequested);
    _clock.dispose();
    _cycle.dispose();
    _intensity.dispose();
    super.dispose();
  }

  void _onStageRequested() {
    setState(() {});
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
              SegmentedPicker(
                left: 'Cryogenic cycle · 4-9',
                right: 'Plasma jet · 4-8',
                leftSelected: apparatus,
                onLeft: () => _select(CryoStage.compression),
                onRight: () => _select(CryoStage.plasmaJet),
              ),
              const SizedBox(height: 14),
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
                    Semantics(
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
                                animation: Listenable.merge([_clock, _cycle]),
                                painterBuilder: () => CryogenicPainter(
                                  CryoState(
                                      t: _clock.value, stage: _cycle.value),
                                  labelColor: Palette.inkSoft,
                                ),
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
                    const SizedBox(height: 4),
                    Text(
                      apparatus
                          ? 'Fig. 4-9 — the gas heated by compression in the '
                              'upper chamber loses heat to the surroundings, '
                              'while the gas cooled by expansion in the lower '
                              'chamber absorbs heat from them'
                          : 'Fig. 4-8 — a plasma jet produced by blowing a '
                              'stream of noble gas through a high-current '
                              'electric arc discharge',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: Palette.inkSoft,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!reduceMotion)
                    ControlPill(
                      icon: _running ? Icons.pause : Icons.play_arrow,
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
