import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/common.dart';
import '../physics/venturi.dart';
import '../state/simulation_controller.dart';
import '../theme/bernoulli_colors.dart';
import '../widgets/bernoulli_widgets.dart';
import '../widgets/venturi_figure.dart';

/// Animated Venturi tube experiment with Learning Hub chrome.
class BernoulliSimulationScreen extends StatefulWidget {
  const BernoulliSimulationScreen({super.key});

  @override
  State<BernoulliSimulationScreen> createState() =>
      _BernoulliSimulationScreenState();
}

class _BernoulliSimulationScreenState extends State<BernoulliSimulationScreen>
    with WidgetsBindingObserver {
  final SimulationController _sim = SimulationController();
  bool _wantsMotion = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sim.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    _sim.setRunning(foreground && _wantsMotion);
  }

  void _toggleMotion() {
    _wantsMotion = !_wantsMotion;
    _sim.setRunning(_wantsMotion);
  }

  void _reset() {
    _wantsMotion = true;
    _sim.reset();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Figure 1-10 — Venturi tube',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _sim,
                      builder: (context, _) => _roundIcon(
                        tooltip:
                            _sim.running ? 'Pause the flow' : 'Start the flow',
                        icon: _sim.running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onTap: reduceMotion ? null : _toggleMotion,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _roundIcon(
                      tooltip: 'Reset',
                      icon: Icons.refresh_rounded,
                      onTap: _reset,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _sim,
                  builder: (context, _) {
                    final m = _sim.model;
                    return ContentWidth(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        children: [
                          FigureCard(
                            child: VenturiFigure(
                              model: m,
                              running: _sim.running && !reduceMotion,
                              showStreamlines: _sim.showStreamlines,
                              semanticsLabel: _sim.describe(),
                            ),
                          ),
                          if (reduceMotion)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Motion is paused because your device has '
                                '"reduce motion" turned on. The columns and '
                                'numbers still update as you move the sliders.',
                                style: TextStyle(
                                    fontSize: 12.5, color: AppColors.inkSoft),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (m.cavitates) _cavitationWarning(m),
                          _readouts(m),
                          const SizedBox(height: 18),
                          _controls(m),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: BernoulliColors.motion
                                      .withValues(alpha: 0.35)),
                              boxShadow: kCardShadow,
                            ),
                            child: PressureSplitBars(model: m),
                          ),
                          const SizedBox(height: 18),
                          _explainer(m),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundIcon({
    required String tooltip,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: kCardShadow,
            ),
            child: Icon(icon, color: BernoulliColors.accent, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _cavitationWarning(VenturiModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BernoulliColors.badSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BernoulliColors.bad.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: BernoulliColors.bad),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The throat pressure has fallen below zero '
              '(${(m.throatPressure / 1000).toStringAsFixed(1)} kPa). A real '
              'pipe would cavitate here: the water boils into bubbles and the '
              'standpipe empties.',
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readouts(VenturiModel m) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Readout(
            label: 'Speed, wide',
            value: '${m.wideSpeed.toStringAsFixed(2)} m/s',
            color: BernoulliColors.ok),
        Readout(
            label: 'Speed, throat',
            value: '${m.throatSpeed.toStringAsFixed(2)} m/s',
            color: BernoulliColors.bad),
        Readout(
            label: 'Throat is',
            value: '${m.speedRatio.toStringAsFixed(1)}× faster',
            color: BernoulliColors.motion),
        Readout(
            label: 'Pressure, wide',
            value: '${(m.widePressure / 1000).toStringAsFixed(1)} kPa',
            color: BernoulliColors.ok),
        Readout(
            label: 'Pressure, throat',
            value: '${(m.throatPressure / 1000).toStringAsFixed(1)} kPa',
            color: BernoulliColors.bad),
        Readout(
            label: 'Column drop',
            value: '${m.columnDrop.toStringAsFixed(2)} m'),
      ],
    );
  }

  Widget _controls(VenturiModel m) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairline),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _slider(
            label: 'Flow rate',
            value: m.flow,
            min: VenturiModel.minFlow,
            max: VenturiModel.maxFlow,
            display: '${(m.flow * 1000).toStringAsFixed(1)} litres/s',
            semantic: '${(m.flow * 1000).toStringAsFixed(1)} litres per second',
            onChanged: (v) => _sim.flow = v,
          ),
          _slider(
            label: 'Throat diameter',
            value: m.throatDiameter,
            min: VenturiModel.minThroat,
            max: VenturiModel.maxThroat,
            display: '${(m.throatDiameter * 1000).toStringAsFixed(0)} mm '
                '(pipe is ${(m.wideDiameter * 1000).toStringAsFixed(0)} mm)',
            semantic:
                '${(m.throatDiameter * 1000).toStringAsFixed(0)} millimetres',
            onChanged: (v) => _sim.throatDiameter = v,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: BernoulliColors.accent,
            title: const Text('Show the water moving',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text(
                'Streaks are longer and further apart where the water is '
                'faster',
                style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
            value: _sim.showStreamlines,
            onChanged: _sim.setShowStreamlines,
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String display,
    required String semantic,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Flexible(
              child: Text(display,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: BernoulliColors.accent, fontSize: 13)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: BernoulliColors.accent,
            thumbColor: BernoulliColors.accent,
            inactiveTrackColor: BernoulliColors.accent.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            label: display,
            semanticFormatterCallback: (_) => '$label: $semantic',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _explainer(VenturiModel m) {
    final levelled = _sim.isStraightPipe;
    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What you are looking at',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: BernoulliColors.accent)),
          const SizedBox(height: 8),
          Text(
            levelled
                ? 'The throat is now as wide as the pipe, so the water never '
                    'speeds up and never has to trade pressure for speed. '
                    'All three columns stand level — no constriction, no '
                    'pressure drop.'
                : 'The same water must pass every point each second, so where '
                    'the pipe narrows to '
                    '${(m.throatDiameter * 1000).toStringAsFixed(0)} mm the '
                    'water is forced to run '
                    '${m.speedRatio.toStringAsFixed(1)} times faster '
                    '(${m.wideSpeed.toStringAsFixed(2)} → '
                    '${m.throatSpeed.toStringAsFixed(2)} m/s). That speed has '
                    'to be paid for out of pressure, so the static pressure '
                    'falls from ${(m.widePressure / 1000).toStringAsFixed(1)} '
                    'to ${(m.throatPressure / 1000).toStringAsFixed(1)} kPa '
                    'and the middle standpipe sits '
                    '${m.columnDrop.toStringAsFixed(2)} m lower than its '
                    'neighbours.',
            style: const TextStyle(fontSize: 14.5, height: 1.45),
          ),
          const SizedBox(height: 10),
          const Text(
            'Try it: widen the throat until it matches the pipe and the three '
            'columns level out. Then open the flow wide with a narrow throat '
            'and watch the middle column collapse.',
            style: TextStyle(
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                color: AppColors.inkSoft),
          ),
          const SizedBox(height: 10),
          const Text(
            'Note: this is the ideal, frictionless case, so both wide sections '
            'read the same. A real pipe loses a little pressure to friction, '
            'making the downstream column slightly lower.',
            style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
