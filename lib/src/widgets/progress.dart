import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// اندازه‌ی نوار.
enum VibeProgressSize { sm, md }

/// نوار پیشرفت — پورت `registry/ui/progress.tsx`.
///
/// از سمت شروع (راست در RTL) پر می‌شود؛ درصد با ارقام فارسی و علامت ٪
/// نمایش داده می‌شود. مقدار خارج از بازه به ۰ تا ۱۰۰ محدود می‌شود.
///
/// ```dart
/// VibeProgress(value: 64, label: Text("آپلود"), showValue: true)
/// VibeProgress(value: 3, max: 12, size: VibeProgressSize.sm)
/// ```
class VibeProgress extends StatelessWidget {
  const VibeProgress({
    super.key,
    required this.value,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.size = VibeProgressSize.md,
  });

  /// مقدار فعلی؛ نسبت به [max] سهم درصد را می‌سازد.
  final num value;

  final num max;

  /// برچسب کنار درصد؛ اختیاری.
  final Widget? label;

  /// نمایش درصد فارسی سمت مقابل برچسب.
  final bool showValue;

  final VibeProgressSize size;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final pct = ((value / max) * 100).clamp(0, 100).toDouble();
    final height = size == VibeProgressSize.sm ? 6.0 : 8.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 12, color: t.foreground),
                  child: label!,
                ),
              if (showValue)
                Text(
                  faPercent(pct),
                  style: TextStyle(
                    fontSize: 12,
                    color: t.mutedForeground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Semantics(
          value: faPercent(100 * value / max),
          label: "پیشرفت",
          child: ExcludeSemantics(
            child: Container(
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: t.input,
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedFractionallySizedBox(
                // پرشدن با همان duration-500 وب
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                widthFactor: pct / 100,
                alignment: AlignmentDirectional.centerStart,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
