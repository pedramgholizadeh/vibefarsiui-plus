import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme.dart';

/// اندازه‌ی چرخنده.
enum VibeSpinnerSize { xs, sm, md, lg }

/// چرخنده‌ی بارگذاری — پورت `registry/ui/spinner.tsx`.
///
/// حلقه‌ای که رنگش را از `color` می‌گیرد (پیش‌فرض کم‌رنگ تم) و می‌چرخد؛
/// بدون برچسب هم نقش «در حال بارگذاری» را اعلام می‌کند. داخل دکمه‌ها
/// یا وسط کارت‌ها می‌نشیند.
///
/// ```dart
/// VibeSpinner(label: Text("در حال بارگذاری"))
/// VibeSpinner(size: VibeSpinnerSize.xs, color: VibeTokens.dark.brand)
/// ```
class VibeSpinner extends StatefulWidget {
  const VibeSpinner({super.key, this.size = VibeSpinnerSize.md, this.label, this.color});

  final VibeSpinnerSize size;

  /// متن کنار حلقه؛ بدون آن فقط برچسب دسترس‌پذیری خوانده می‌شود.
  final Widget? label;

  /// رنگ حلقه و متن؛ پیش‌فرض `mutedForeground` مثل `text-muted-foreground` وب.
  final Color? color;

  @override
  State<VibeSpinner> createState() => _VibeSpinnerState();
}

class _VibeSpinnerState extends State<VibeSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final color = widget.color ?? t.mutedForeground;
    // sizes وب: xs=12/1.5، sm=16/2، md=24/2، lg=36/3 (قطر/ضخامت خط)
    final (diameter, stroke) = switch (widget.size) {
      VibeSpinnerSize.xs => (12.0, 1.5),
      VibeSpinnerSize.sm => (16.0, 2.0),
      VibeSpinnerSize.md => (24.0, 2.0),
      VibeSpinnerSize.lg => (36.0, 3.0),
    };
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      label: "در حال بارگذاری",
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 13, color: color),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Transform.rotate(
                  angle: _controller.value * 2 * 3.141592653589793,
                  child: CustomPaint(
                    size: Size(diameter, diameter),
                    painter: _RingPainter(color: color, stroke: stroke, gapAtStart: rtl),
                  ),
                ),
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(width: 8),
              widget.label!,
            ],
          ],
        ),
      ),
    );
  }
}

/// حلقه با یک شکاف ۹۰ درجه؛ `gapAtStart` سمتِ شفاف را برمی‌گزیند
/// (معادل border-e-transparent وب در دو جهت).
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.stroke, required this.gapAtStart});

  final Color color;
  final double stroke;
  final bool gapAtStart;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(stroke / 2);
    // شکاف روی سمت inline-end (چپ در RTL، راست در LTR) وسط آن لبه.
    final gapCenter = gapAtStart ? 180.0 : 0.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color;
    canvas.drawArc(ring, _radians(gapCenter + 45), _radians(360 - 90), false, paint);
  }

  double _radians(double degrees) => degrees * 3.141592653589793 / 180;

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color || old.stroke != stroke || old.gapAtStart != gapAtStart;
}

/// پوشش بارگذاری — پورت `LoadingOverlay` از `registry/ui/spinner.tsx`.
///
/// روی کل والد (که باید داخل `Stack` باشد) می‌نشیند: پس‌زمینه‌ی نیمه‌شفاف
/// با کمی مات، چرخنده‌ی وسط و مسدودکردن لمس. وقتی `loading` خاموش است هیچ
/// چیزی رندر نمی‌شود.
///
/// ```dart
/// Stack(children: [content, VibeLoadingOverlay(loading: busy)])
/// ```
class VibeLoadingOverlay extends StatelessWidget {
  const VibeLoadingOverlay({
    super.key,
    required this.loading,
    this.label,
    this.borderRadius,
  });

  final bool loading;

  final Widget? label;

  /// شعاع گوشه‌ی پوشش؛ مثل `rounded-[inherit]` وب به شعاع والد بدهید.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (!loading) return const SizedBox.shrink();
    final t = context.vibe;
    return Positioned.fill(
      child: AbsorbPointer(
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: ColoredBox(
              color: t.background.withValues(alpha: 0.60),
              child: Center(child: VibeSpinner(label: label)),
            ),
          ),
        ),
      ),
    );
  }
}
