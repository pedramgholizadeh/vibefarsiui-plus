import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// امتیاز ستاره‌ای — پورت `registry/ui/rating.tsx`.
///
/// ستاره‌ها از سمت راست پر می‌شوند و hover پیش‌نمایش می‌دهد.
///
/// ```dart
/// VibeRating(value: _rate, onChanged: (v) => setState(() => _rate = v), showValue: true)
/// ```
class VibeRating extends StatefulWidget {
  const VibeRating({
    super.key,
    this.value,
    this.defaultValue = 0,
    this.onChanged,
    this.max = 5,
    this.readOnly = false,
    this.showValue = false,
    this.small = false,
  });

  /// مقدار کنترل‌شده.
  final double? value;
  final double defaultValue;
  final ValueChanged<double>? onChanged;
  final int max;
  final bool readOnly;

  /// نمایش «۳ از ۵» کنار ستاره‌ها.
  final bool showValue;
  final bool small;

  @override
  State<VibeRating> createState() => _VibeRatingState();
}

class _VibeRatingState extends State<VibeRating> {
  late double _internal;
  int? _hover;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final v = widget.value ?? _internal;
    final shown = _hover?.toDouble() ?? v;
    final size = widget.small ? 16.0 : 20.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var n = 1; n <= widget.max; n++)
              MouseRegion(
                cursor: widget.readOnly ? MouseCursor.defer : SystemMouseCursors.click,
                onEnter: widget.readOnly ? null : (_) => setState(() => _hover = n),
                onExit: widget.readOnly ? null : (_) => setState(() => _hover = null),
                child: GestureDetector(
                  onTap: widget.readOnly ? null : () {
                    if (widget.value == null) setState(() => _internal = n.toDouble());
                    widget.onChanged?.call(n.toDouble());
                  },
                  child: AnimatedScale(
                    scale: !widget.readOnly && _hover != null && _hover! >= n ? 1.1 : 1.0,
                    duration: VibeMotion.duration,
                    curve: VibeMotion.ease,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        n <= shown ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: size,
                        color: n <= shown ? t.foreground : t.mutedForeground.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (widget.showValue) ...[
          const SizedBox(width: 8),
          Text(
            "${fa(v.round())} از ${fa(widget.max)}",
            style: TextStyle(fontSize: 12, color: t.mutedForeground),
          ),
        ],
      ],
    );
  }
}
