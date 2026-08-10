import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Transport controls: play/pause, replay, scrub, loop and playback speed.
class ControlBar extends StatelessWidget {
  const ControlBar({
    required this.isPlaying,
    required this.progress,
    required this.speed,
    required this.loop,
    required this.onPlayPause,
    required this.onReplay,
    required this.onSeek,
    required this.onSpeedChanged,
    required this.onLoopChanged,
    super.key,
  });

  final bool isPlaying;
  final double progress;
  final double speed;
  final bool loop;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<bool> onLoopChanged;

  static const List<double> _speeds = <double>[0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Palette.uiSurfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: Palette.uiAccent,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.14),
              thumbColor: Palette.uiOnSurface,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: onSeek,
              label: '${(progress * 100).round()}%',
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onReplay,
                tooltip: 'Replay from the start (R)',
                icon: const Icon(Icons.replay_rounded),
                color: Palette.uiOnSurface,
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: onPlayPause,
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.uiAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                label: Text(isPlaying ? 'Pause' : 'Play'),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => onLoopChanged(!loop),
                tooltip: loop ? 'Looping on' : 'Looping off',
                icon: Icon(loop ? Icons.repeat_on_rounded : Icons.repeat_rounded),
                color: loop ? Palette.uiAccent : Palette.uiMuted,
              ),
              const SizedBox(width: 4),
              _SpeedMenu(
                speed: speed,
                speeds: _speeds,
                onChanged: onSpeedChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedMenu extends StatelessWidget {
  const _SpeedMenu({
    required this.speed,
    required this.speeds,
    required this.onChanged,
  });

  final double speed;
  final List<double> speeds;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Playback speed',
      initialValue: speed,
      onSelected: onChanged,
      color: Palette.uiSurfaceHigh,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
        for (final double s in speeds)
          PopupMenuItem<double>(
            value: s,
            child: Text(
              '${s.toString().replaceFirst(RegExp(r'\.0$'), '')}×',
              style: const TextStyle(color: Palette.uiOnSurface),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Text(
          '${speed.toString().replaceFirst(RegExp(r'\.0$'), '')}×',
          style: const TextStyle(
            color: Palette.uiOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
