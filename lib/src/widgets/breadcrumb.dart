import 'package:flutter/material.dart';

import '../theme.dart';

/// یک قدم از مسیر: برچسب و عملیات اختیاری. آخرین قدم، صفحه‌ی جاری است.
class VibeCrumb {
  final Widget label;
  final VoidCallback? onTap;

  const VibeCrumb({required this.label, this.onTap});
}

/// مسیر — پورت `registry/ui/breadcrumb.tsx`.
///
/// جداکننده‌ها به سمت چپ اشاره می‌کنند (جهت حرکت در RTL) و آخرین قدم با رنگ
/// متن اصلی و وزن بیشتر، صفحه‌ی جاری است.
///
/// ```dart
/// VibeBreadcrumb(items: [
///   VibeCrumb(label: Text("فروشگاه"), onTap: () => …),
///   VibeCrumb(label: Text("لپ‌تاپ")),
/// ])
/// ```
class VibeBreadcrumb extends StatelessWidget {
  final List<VibeCrumb> items;

  const VibeBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Semantics(
      label: "مسیر",
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _crumb(context, items[i], last: i == items.length - 1),
            if (i != items.length - 1)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 6),
                child: Icon(
                  Icons.chevron_left,
                  size: 14,
                  color: t.mutedForeground.withValues(alpha: 0.6),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _crumb(BuildContext context, VibeCrumb crumb, {required bool last}) {
    final t = context.vibe;
    final style = last
        ? TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.foreground)
        : TextStyle(fontSize: 14, color: t.mutedForeground);
    final content = DefaultTextStyle.merge(style: style, child: crumb.label);
    if (crumb.onTap != null && !last) {
      return Semantics(
        link: true,
        child: InkWell(
          onTap: crumb.onTap,
          borderRadius: BorderRadius.circular(4),
          hoverColor: Colors.transparent,
          child: content,
        ),
      );
    }
    return content;
  }
}
