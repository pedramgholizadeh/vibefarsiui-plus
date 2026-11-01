import 'package:flutter/material.dart';

import '../theme.dart';

/// واریانت نشان — همان واریانت‌های `registry/ui/badge.tsx`.
enum VibeBadgeVariant { regular, secondary, outline, success, warning, brand, destructive }

/// نشان متنی — پورت `registry/ui/badge.tsx`.
///
/// نشانِ بدون قاب: فقط متن رنگی، `text-xs` (۱۲)، وزن medium و بدون شکست خط.
/// رنگ از واریانت می‌آید؛ هیچ پس‌زمینه‌ای ندارد مثل وب.
///
/// ```dart
/// VibeBadge(variant: VibeBadgeVariant.success, child: Text("پرداخت شد"))
/// VibeBadge(variant: VibeBadgeVariant.brand, child: Text("ویژه"))
/// ```
class VibeBadge extends StatelessWidget {
  const VibeBadge({super.key, required this.child, this.variant = VibeBadgeVariant.regular});

  final Widget child;
  final VibeBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final color = switch (variant) {
      VibeBadgeVariant.regular => t.foreground,
      VibeBadgeVariant.secondary => t.mutedForeground,
      VibeBadgeVariant.outline => t.foreground.withValues(alpha: 0.55),
      VibeBadgeVariant.success => t.success,
      VibeBadgeVariant.warning => t.warning,
      VibeBadgeVariant.brand => t.brand,
      VibeBadgeVariant.destructive => t.destructive,
    };

    return DefaultTextStyle.merge(
      // line-height وب: leading-6 = ۲۴px روی فونت ۱۲
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color, height: 2),
      maxLines: 1,
      overflow: TextOverflow.clip,
      child: child,
    );
  }
}
