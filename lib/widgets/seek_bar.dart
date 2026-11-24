import 'package:flutter/material.dart';
import 'package:flutter_application_4_player/features/player/player.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({super.key});

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _drag;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = PlayerController.instance;
    return ValueListenableBuilder<Duration>(
      valueListenable: c.duration,
      builder: (_, total, _) => ValueListenableBuilder<Duration>(
        valueListenable: c.position,
        builder: (_, pos, _) {
          final max = total.inMilliseconds.toDouble();
          final value = (_drag ?? pos.inMilliseconds.toDouble()).clamp(
            0.0,
            max > 0 ? max : 1.0,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(_fmt(Duration(milliseconds: value.toInt()))),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: max > 0 ? max : 1.0,
                    value: value,
                    onChanged: max > 0
                        ? (v) => setState(() => _drag = v)
                        : null,
                    onChangeEnd: (v) async {
                      await c.seek(Duration(milliseconds: v.toInt()));
                      if (mounted) setState(() => _drag = null);
                    },
                  ),
                ),
                Text(_fmt(total)),
              ],
            ),
          );
        },
      ),
    );
  }
}
