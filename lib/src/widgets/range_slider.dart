import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// اسلایدر بازه — پورت `registry/ui/range-slider.tsx`.
///
/// دو نشانگر روی یک ریل؛ بازه‌ی فعال از سمت شروع (راست در RTL) پر می‌شود.
/// برچسب‌های سر و ته با ارقام فارسی و با [fullRangeLabel] حالت «همه».
///
/// ```dart
/// VibeRangeSlider(
///   value: _range, min: 0, max: 5000000, step: 100000,
///   onChanged: (r) => setState(() => _range = r),
///   format: formatToman,
///   fullRangeLabel: const Text("همه قیمت‌ها"),
/// )
/// ```
class VibeRangeSlider extends StatelessWidget {
  /// بازه‌ی کنترل‌شده.
  final RangeValues? value;
  final RangeValues defaultValue;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final double step;

  /// قالب برچسب‌ها؛ پیش‌فرض ارقام فارسی.
  final String Function(double value)? format;
  final Widget? label;
  final bool showValue;

  /// جای دو مقدار وقتی بازه کل [min, max] را می‌پوشاند.
  final Widget? fullRangeLabel;
  final bool disabled;
  final bool small;

  const VibeRangeSlider({
    super.key,
    this.value,
    this.defaultValue = const RangeValues(0, 100),
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.format,
    this.label,
    this.showValue = true,
    this.fullRangeLabel,
    this.disabled = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final effective = value ?? defaultValue;
    final fmt = format ?? (v) => fa(v.round());
    final isFull = effective.start <= min && effective.end >= max;

    final slider = SliderTheme(
      data: SliderThemeData(
        thumbColor: t.background,
        activeTrackColor: t.primary,
        inactiveTrackColor: t.input,
        trackHeight: 6,
        overlayColor: t.ring.withValues(alpha: 0.1),
        rangeThumbShape: _BorderedRangeThumbShape(borderColor: t.primary),
        rangeTrackShape: const _StartFillRangeTrackShape(),
        disabledActiveTrackColor: t.primary,
        disabledInactiveTrackColor: t.input,
      ),
      child: RangeSlider(
        values: RangeValues(effective.start.clamp(min, max), effective.end.clamp(min, max)),
        min: min,
        max: max,
        divisions: step <= 0 ? null : ((max - min) / step).round(),
        onChanged: disabled || onChanged == null ? null : (r) => onChanged!(r),
      ),
    );

    return Column(
      children: [
        if (label != null || showValue)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  DefaultTextStyle.merge(style: TextStyle(fontSize: 12, color: t.mutedForeground), child: label!),
                if (showValue)
                  if (isFull && fullRangeLabel != null)
                    DefaultTextStyle.merge(style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), child: fullRangeLabel!)
                  else
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        "${fmt(effective.start)} — ${fmt(effective.end)}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
              ],
            ),
          ),
        Opacity(opacity: disabled ? 0.5 : 1, child: slider),
      ],
    );
  }
}

/// نشانگر بازه با حاشیه — همان thumb وب.
class _BorderedRangeThumbShape extends RangeSliderThumbShape {
  final Color borderColor;

  const _BorderedRangeThumbShape({required this.borderColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(16, 16);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 8, Paint()..color = sliderTheme.thumbColor ?? const Color(0xFFFFFFFF));
    canvas.drawCircle(center, 8, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 2);
  }
}

/// ریل بازه که از سمت شروع (راست در RTL) پر می‌شود.
class _StartFillRangeTrackShape extends RoundedRectRangeSliderTrackShape {
  const _StartFillRangeTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset endThumbCenter,
    required Offset startThumbCenter,
    required TextDirection textDirection,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      // معکوس‌کردن جهت، پرشدن از سمت شروع (راست در RTL).
      textDirection: textDirection == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr,
      startThumbCenter: startThumbCenter,
      endThumbCenter: endThumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
  }
}
