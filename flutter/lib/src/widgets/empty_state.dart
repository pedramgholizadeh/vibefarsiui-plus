import 'package:flutter/material.dart';

import '../theme.dart';

/// حالت خالی — پورت `registry/ui/empty-state.tsx`.
///
/// می‌گوید چه چیزی نیست و همان یک عملی را که درستش می‌کند پیشنهاد می‌دهد:
/// آیکون در دایره‌ی ثانویه، عنوان، توضیح کوتاه و دکمه‌ی عمل — همه داخل
/// قاب خط‌چین.
///
/// ```dart
/// VibeEmptyState(
///   title: "سفارشی ثبت نشده",
///   description: "اولین سفارشت را ثبت کن تا اینجا نمایش داده شود.",
///   action: VibeButton(onPressed: newOrder, child: Text("سفارش جدید")),
/// )
/// ```
class VibeEmptyState extends StatelessWidget {
  const VibeEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
    this.dashedBorder = true,
  });

  /// آیکون حالت خالی؛ پیش‌فرض صندوق ورودی، معادل Inbox وب.
  final Widget? icon;

  final String title;

  final String? description;

  /// عمل پیشنهادی؛ معمولاً یک [VibeButton].
  final Widget? action;

  /// قاب خط‌چین دور حالت خالی؛ جدول داده آن را خاموش می‌کند (مثل وب).
  final bool dashedBorder;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32), // p-8
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: t.secondary, shape: BoxShape.circle),
            child: IconTheme.merge(
              data: IconThemeData(size: 20, color: t.mutedForeground),
              child: icon ?? const Icon(Icons.inbox_outlined),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: t.foreground,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320), // max-w-xs
              child: Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: t.mutedForeground,
                  height: 20 / 12, // leading-5
                ),
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 8),
            action!,
          ],
        ],
      ),
    );

    if (!dashedBorder) return content;
    return _DashedBorder(color: t.input, radius: 14, child: content); // rounded-xl
  }
}

/// خط‌چین گردشده — معادل `border border-dashed border-input` وب.
class _DashedBorder extends StatelessWidget {
  const _DashedBorder({required this.radius, required this.color, required this.child});

  final double radius;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(radius: radius, color: color),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rRect);
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
