import 'package:flutter/material.dart';

import '../theme.dart';

/// اسکلت — پورت `registry/ui/skeleton.tsx`.
///
/// به‌طور پیش‌فرض با ضربان نرم (شفافیت ۰٫۵۵ ↔ ۱ در ۳ ثانیه) می‌تپد؛
/// با `shimmer` به‌جای ضربان، یک نور مورب از ابتدای بلوک تا انتهای آن می‌گذرد.
///
/// ```dart
/// VibeSkeleton(width: 200, height: 12)
/// VibeSkeleton(width: 120, height: 12, shimmer: true)
/// ```
class VibeSkeleton extends StatefulWidget {
  const VibeSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 12,
    this.borderRadius,
    this.shimmer = false,
  });

  /// پهوی بلوک؛ پیش‌فرض هر جا که هست پر می‌کند.
  final double? width;

  final double? height;

  /// شعاع گوشه؛ پیش‌فرض `rounded-md` (۸) مثل وب. برای دایره ۹۹۹ بدهید.
  final double? borderRadius;

  final bool shimmer;

  @override
  State<VibeSkeleton> createState() => _VibeSkeletonState();
}

class _VibeSkeletonState extends State<VibeSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // pulse-soft: ۳s؛ shine: ۲.۲s — مثل globals.css
    duration: widget.shimmer ? const Duration(milliseconds: 2200) : const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: !widget.shimmer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final radius = BorderRadius.circular(widget.borderRadius ?? 8);

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.shimmer
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // کی‌فریم وب: ۰٪ → ۱۲۰٪- و ۶۰٪ تا ۱۰۰٪ → ۲۲۰٪
                    final v = _controller.value;
                    final p = v < 0.6 ? Curves.easeInOut.transform(v / 0.6) : 1.0;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        return Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: t.secondary),
                            PositionedDirectional(
                              start: -1.2 * w + p * 3.4 * w,
                              top: 0,
                              bottom: 0,
                              width: w * 0.6,
                              child: const _ShineBand(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : FadeTransition(
                  opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                  child: ColoredBox(color: t.secondary),
                ),
        ),
      ),
    );
  }
}

/// نوار نور شیمر: گرادیان شفاف ← رنگ متن ۱۰٪ ← شفاف با کجی ۱۵ درجه.
class _ShineBand extends StatelessWidget {
  const _ShineBand();

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Transform(
      transform: Matrix4.skewX(-0.26), // skewX(-15deg)
      child: DecoratedBox(
        decoration: BoxDecoration(
          // bg-gradient-to-l وب: «از» در سمت راست شروع می‌شود
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Colors.transparent,
              t.foreground.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// ردیف آماده‌ی اسکلت — پورت `SkeletonRow` از `registry/ui/skeleton.tsx`.
///
/// آواتار دایره‌ای + دو خط متن؛ برای حالت بارگذاری فهرست‌ها.
///
/// ```dart
/// VibeSkeletonRow()
/// ```
class VibeSkeletonRow extends StatelessWidget {
  const VibeSkeletonRow({super.key, this.shimmer = false});

  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VibeSkeleton(width: 40, height: 40, borderRadius: 999, shimmer: shimmer),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: 0.75,
                alignment: AlignmentDirectional.centerStart,
                child: VibeSkeleton(height: 10, shimmer: shimmer),
              ),
              const SizedBox(height: 8),
              FractionallySizedBox(
                widthFactor: 0.5,
                alignment: AlignmentDirectional.centerStart,
                child: VibeSkeleton(height: 8, shimmer: shimmer),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
