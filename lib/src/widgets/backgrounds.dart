/// کتابخانه‌ی پس‌زمینه‌های تزئینی وایب‌فارسی — پورت `registry/backgrounds/*`.
///
/// نسخه‌های وب canvas/shader دارند؛ پورت فلاتر با CustomPaint سبک همان حس
/// را می‌دهد: گرید، نقطه، موج، ستاره، شعاع نور و گرادیان حرکتی. همه
/// `IgnorePointer` و `RepaintBoundary` هستند.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// پس‌زمینه‌ی پایه: پرکردن کل باکس با پینتر.
abstract class VibeBackground extends StatelessWidget {
  const VibeBackground({super.key});

  CustomPainter painter(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: painter(context), size: Size.infinite),
      ),
    );
  }
}

/// گرید خطی — پورت `grid.tsx`.
class VibeGridBackground extends VibeBackground {
  final double cell;
  final double strokeWidth;

  const VibeGridBackground({super.key, this.cell = 40, this.strokeWidth = 1});

  @override
  CustomPainter painter(BuildContext context) => _GridPainter(this, context.vibe);
}

class _GridPainter extends CustomPainter {
  final VibeGridBackground config;
  final VibeTokens t;
  _GridPainter(this.config, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = t.border
      ..strokeWidth = config.strokeWidth;
    for (double x = 0; x <= size.width; x += config.cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += config.cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

/// نقطه‌چین — پورت `dots.tsx`.
class VibeDotsBackground extends VibeBackground {
  final double spacing;
  final double dotRadius;

  const VibeDotsBackground({super.key, this.spacing = 24, this.dotRadius = 1.2});

  @override
  CustomPainter painter(BuildContext context) => _DotsPainter(this, context.vibe);
}

class _DotsPainter extends CustomPainter {
  final VibeDotsBackground config;
  final VibeTokens t;
  _DotsPainter(this.config, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = t.mutedForeground.withValues(alpha: 0.3);
    for (double x = config.spacing / 2; x < size.width; x += config.spacing) {
      for (double y = config.spacing / 2; y < size.height; y += config.spacing) {
        canvas.drawCircle(Offset(x, y), config.dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => false;
}

/// موج‌های افقی — پورت `waves.tsx`.
class VibeWavesBackground extends VibeBackground {
  final double amplitude;
  final double wavelength;
  final int count;

  const VibeWavesBackground({super.key, this.amplitude = 10, this.wavelength = 160, this.count = 5});

  @override
  CustomPainter painter(BuildContext context) => _WavesPainter(this, context.vibe);
}

class _WavesPainter extends CustomPainter {
  final VibeWavesBackground config;
  final VibeTokens t;
  _WavesPainter(this.config, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    for (var i = 0; i < config.count; i++) {
      final yBase = size.height * (0.25 + 0.15 * i);
      final amp = config.amplitude * (1 + i * 0.3);
      final path = Path();
      for (double x = 0; x <= size.width; x += 8) {
        final y = yBase + math.sin(x / config.wavelength * 2 * math.pi + rng.nextDouble()) * amp;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = (i.isEven ? t.brand : t.primary).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_WavesPainter old) => false;
}

/// ستاره‌ها — پورت `stars.tsx`.
class VibeStarsBackground extends VibeBackground {
  final int count;
  final int seed;

  const VibeStarsBackground({super.key, this.count = 80, this.seed = 42});

  @override
  CustomPainter painter(BuildContext context) => _StarsPainter(this, context.vibe);
}

class _StarsPainter extends CustomPainter {
  final VibeStarsBackground config;
  final VibeTokens t;
  _StarsPainter(this.config, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(config.seed);
    for (var i = 0; i < config.count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.3;
      canvas.drawCircle(Offset(x, y), r, Paint()..color = t.foreground.withValues(alpha: 0.2 + rng.nextDouble() * 0.5));
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => false;
}

/// شعاع نور گوشه‌ای — پورت `godrays.tsx` / `light-leak.tsx`.
class VibeLightLeakBackground extends VibeBackground {
  final Alignment origin;

  const VibeLightLeakBackground({super.key, this.origin = Alignment.topLeft});

  @override
  CustomPainter painter(BuildContext context) => _LightLeakPainter(this, context.vibe);
}

class _LightLeakPainter extends CustomPainter {
  final VibeLightLeakBackground config;
  final VibeTokens t;
  _LightLeakPainter(this.config, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = alignmentOrigin(config.origin, size);
    final radius = size.longestSide * 0.9;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [t.brand.withValues(alpha: 0.28), t.brand.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_LightLeakPainter old) => false;
}

Offset alignmentOrigin(Alignment alignment, Size size) =>
      Offset((alignment.x + 1) / 2 * size.width, (alignment.y + 1) / 2 * size.height);

/// گرادیان مش — پورت `gradient-mesh.tsx` / `mesh.tsx`.
class VibeMeshBackground extends VibeBackground {
  final List<(Alignment, Color)> stops;

  const VibeMeshBackground({super.key, this.stops = const []});

  @override
  CustomPainter painter(BuildContext context) {
    final t = context.vibe;
    final effective = stops.isEmpty
        ? [
            (Alignment.topLeft, t.brand.withValues(alpha: 0.20)),
            (Alignment.bottomRight, t.primary.withValues(alpha: 0.14)),
            (Alignment.bottomLeft, t.success.withValues(alpha: 0.10)),
          ]
        : stops;
    return _MeshPainter(effective, context.vibe.background);
  }
}

class _MeshPainter extends CustomPainter {
  final List<(Alignment, Color)> stops;
  final Color background;
  _MeshPainter(this.stops, this.background);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    for (final (alignment, color) in stops) {
      final center = alignmentOrigin(alignment, size);
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: size.longestSide * 0.7)),
      );
    }
  }

  @override
  bool shouldRepaint(_MeshPainter old) => false;
}

/// حرکت نرم گرادیان — پورت `aurora.tsx` / `liquid-gradient.tsx`.
///
/// سه لکه‌ی رنگی با انیمیشن آهسته.
class VibeAuroraBackground extends StatefulWidget {
  const VibeAuroraBackground({super.key, this.colors, this.period = const Duration(seconds: 14)});

  final List<Color>? colors;
  final Duration period;

  @override
  State<VibeAuroraBackground> createState() => _VibeAuroraBackgroundState();
}

class _VibeAuroraBackgroundState extends State<VibeAuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final colors = widget.colors ?? [t.brand.withValues(alpha: 0.18), t.primary.withValues(alpha: 0.12), t.success.withValues(alpha: 0.10)];
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _AuroraPainter(
              phase: _controller.value,
              colors: colors,
              background: t.background,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double phase;
  final List<Color> colors;
  final Color background;

  _AuroraPainter({required this.phase, required this.colors, required this.background});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    for (var i = 0; i < colors.length; i++) {
      final angle = phase * 2 * math.pi + i * 2.1;
      final center = Offset(
        size.width * (0.5 + 0.35 * math.cos(angle)),
        size.height * (0.5 + 0.35 * math.sin(angle * 1.3)),
      );
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            colors: [colors[i], colors[i].withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: size.longestSide * 0.6)),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.phase != phase;
}
