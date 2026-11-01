import 'package:flutter/material.dart';

import '../theme.dart';

/// ناحیه‌ی اسکرول — پورت `registry/ui/scroll-area.tsx`.
///
/// اسکرول‌بار نازک هم‌رنگ تم تا UI تیره به اسکرول‌بار سیستمی (ویندوز)
/// نیفتد.
///
/// ```dart
/// VibeScrollArea(height: 300, child: LongList())
/// ```
class VibeScrollArea extends StatelessWidget {
  final Widget child;

  /// ارتفاع ثابت؛ خالی یعنی پرکردن والد.
  final double? height;

  /// اسکرول افقی هم داشته باشد.
  final bool horizontal;
  final bool thick;

  const VibeScrollArea({super.key, required this.child, this.height, this.horizontal = false, this.thick = false});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final scrollController = ScrollController();
    final thickness = thick ? 8.0 : 6.0;

    final content = SingleChildScrollView(
      controller: scrollController,
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      child: child,
    );

    final wrapped = RawScrollbar(
      controller: scrollController,
      thumbColor: t.mutedForeground.withValues(alpha: 0.4),
      radius: const Radius.circular(999),
      thickness: thickness,
      crossAxisMargin: 1,
      mainAxisMargin: 2,
      child: content,
    );

    if (height != null) {
      return SizedBox(height: height, child: wrapped);
    }
    return wrapped;
  }
}
