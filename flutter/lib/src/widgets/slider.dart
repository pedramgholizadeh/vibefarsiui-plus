import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// اسلایدر — پورت `registry/ui/slider.tsx`.
///
/// ریل از ابتدای سطر (در RTL سمت راست) پر می‌شود؛ نشانگر با حاشیه‌ی primary
/// مثل وب. برچسب مقدار پیش‌فرض ارقام فارسی دارد.
///
/// ```dart
/// VibeSlider(
///   value: _qty, min: 1, max: 10,
///   onChanged: (v) => setState(() => _qty = v),
///   label: Text("تعداد"),
/// )
/// ```
class VibeSlider extends StatelessWidget {
  /// مقدار کنترل‌شده.
  final double? value;
  final double defaultValue;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final double step;

  /// قالب مقدار؛ پیش‌فرض ارقام فارسی.
  final String Function(double value)? format;
  final Widget? label;
  final bool showValue;
  final bool disabled;

  const VibeSlider({
    super.key,
    this.value,
    this.defaultValue = 0,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.format,
    this.label,
    this.showValue = true,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final effective = value ?? defaultValue;
    final fmt = format ?? (v) => fa(v.round());

    return Column(
      children: [
        if (label != null || showValue)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                    child: label!,
                  ),
                if (showValue)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(fmt(effective), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
        Opacity(
          opacity: disabled ? 0.5 : 1,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: t.primary,
              inactiveTrackColor: t.input,
              thumbColor: t.background,
              // نشانگر با حاشیه‌ی primary، مثل وب.
              thumbShape: _BorderedThumbShape(borderColor: t.primary),
              overlayColor: t.ring.withValues(alpha: 0.1),
              trackShape: const _StartFillTrackShape(),
              disabledActiveTrackColor: t.primary,
              disabledInactiveTrackColor: t.input,
            ),
            child: Slider(
              value: effective.clamp(min, max),
              min: min,
              max: max,
              divisions: step <= 0 ? null : ((max - min) / step).round(),
              onChanged: disabled || onChanged == null ? null : (v) => onChanged!(v),
            ),
          ),
        ),
      ],
    );
  }
}

/// نشانگر دایره‌ای با حاشیه‌ی دوبیتی — همان thumb وب.
class _BorderedThumbShape extends SliderComponentShape {
  final Color borderColor;

  const _BorderedThumbShape({required this.borderColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(16, 16);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 8, Paint()..color = sliderTheme.thumbColor ?? const Color(0xFFFFFFFF));
    canvas.drawCircle(center, 8, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 2);
  }
}

/// ریل که از سمت شروع (راست در RTL) پر می‌شود — پیش‌فرض فلاتر برعکس است.
class _StartFillTrackShape extends RoundedRectSliderTrackShape {
  const _StartFillTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      // معکوس‌کردن جهت، پرشدن از سمت شروع (راست در RTL).
      textDirection: textDirection == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );
  }
}
