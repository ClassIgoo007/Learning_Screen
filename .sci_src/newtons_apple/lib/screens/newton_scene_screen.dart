import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../animation/scene_timeline.dart';
import '../theme/palette.dart';
import '../widgets/control_bar.dart';
import '../widgets/narration_panel.dart';
import '../widgets/scene_stage_view.dart';

/// Hosts the single [AnimationController] that drives the entire scene.
class NewtonSceneScreen extends StatefulWidget {
  const NewtonSceneScreen({super.key});

  @override
  State<NewtonSceneScreen> createState() => _NewtonSceneScreenState();
}

class _NewtonSceneScreenState extends State<NewtonSceneScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SceneTiming.total,
  )..addStatusListener(_onStatusChanged);

  final FocusNode _focusNode = FocusNode(debugLabel: 'scene-shortcuts');

  double _speed = 1.0;
  bool _loop = true;
  bool _didAutoStart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAutoStart) {
      return;
    }
    _didAutoStart = true;

    // Respect the platform "reduce motion" setting: land on the final frame
    // (apple down, law revealed) instead of animating, and let the viewer
    // press play if they want the motion.
    final bool reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ??
        false;
    if (reduceMotion) {
      _controller.value = 1.0;
      _loop = false;
    } else {
      _controller.forward();
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _loop) {
      _controller.forward(from: 0.0);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlay() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else if (_controller.value >= 1.0) {
      _controller.forward(from: 0.0);
    } else {
      _controller.forward();
    }
    setState(() {});
  }

  void _replay() {
    _controller.forward(from: 0.0);
    setState(() {});
  }

  void _seek(double value) {
    _controller
      ..stop()
      ..value = value;
    setState(() {});
  }

  void _setSpeed(double speed) {
    final bool wasPlaying = _controller.isAnimating;
    _speed = speed;
    _controller.duration = SceneTiming.total * (1.0 / speed);
    if (wasPlaying) {
      _controller.forward(from: _controller.value);
    }
    setState(() {});
  }

  void _setLoop(bool value) {
    setState(() => _loop = value);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatusChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.uiSurface,
      body: SafeArea(
        child: CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.space): _togglePlay,
            const SingleActivator(LogicalKeyboardKey.keyR): _replay,
          },
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                final SceneState state =
                    SceneState.fromProgress(_controller.value);
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool wide = constraints.maxWidth >= 900;
                    final Widget stage = Padding(
                      padding: const EdgeInsets.all(12),
                      child: SceneStageView(state: state),
                    );
                    final Widget side = _SidePanel(
                      state: state,
                      isPlaying: _controller.isAnimating,
                      speed: _speed,
                      loop: _loop,
                      compact: !wide,
                      onPlayPause: _togglePlay,
                      onReplay: _replay,
                      onSeek: _seek,
                      onSpeedChanged: _setSpeed,
                      onLoopChanged: _setLoop,
                    );

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: stage),
                          SizedBox(
                            width: 380,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                              child: side,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: <Widget>[
                        Expanded(child: stage),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: side,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.state,
    required this.isPlaying,
    required this.speed,
    required this.loop,
    required this.compact,
    required this.onPlayPause,
    required this.onReplay,
    required this.onSeek,
    required this.onSpeedChanged,
    required this.onLoopChanged,
  });

  final SceneState state;
  final bool isPlaying;
  final double speed;
  final bool loop;
  final bool compact;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<bool> onLoopChanged;

  @override
  Widget build(BuildContext context) {
    final Widget narration = NarrationPanel(
      stage: state.stage,
      compact: compact,
    );
    final Widget controls = ControlBar(
      isPlaying: isPlaying,
      progress: state.progress,
      speed: speed,
      loop: loop,
      onPlayPause: onPlayPause,
      onReplay: onReplay,
      onSeek: onSeek,
      onSpeedChanged: onSpeedChanged,
      onLoopChanged: onLoopChanged,
    );

    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          narration,
          const SizedBox(height: 10),
          controls,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _Header(),
        const SizedBox(height: 16),
        narration,
        const Spacer(),
        controls,
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Newton’s Apple',
          style: TextStyle(
            color: Palette.uiOnSurface,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'From a falling apple to a universal law',
          style: TextStyle(color: Palette.uiMuted, fontSize: 14),
        ),
      ],
    );
  }
}
