import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// صفحه‌بندی — پورت `registry/ui/pagination.tsx`.
///
/// «قبلی» به راست و «بعدی» به چپ اشاره می‌کنند، مثل ترتیب خواندن فارسی؛
/// شماره‌ها با ارقام فارسی و «…» برای فاصله‌ها.
///
/// ```dart
/// VibePagination(page: _page, total: 12, onChange: (p) => setState(() => _page = p))
/// ```
class VibePagination extends StatelessWidget {
  final int page;
  final int total;
  final ValueChanged<int> onChange;

  /// تعداد صفحات اطراف صفحه‌ی جاری.
  final int siblings;
  final bool small;

  const VibePagination({
    super.key,
    required this.page,
    required this.total,
    required this.onChange,
    this.siblings = 1,
    this.small = false,
  });

  List<Object> _range() {
    final pages = <int>{1, total};
    for (var p = page - siblings; p <= page + siblings; p++) {
      if (p >= 1 && p <= total) pages.add(p);
    }
    final sorted = pages.toList()..sort();
    final out = <Object>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add("…");
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final size = small ? 32.0 : 36.0;

    Widget button({required Widget child, required VoidCallback? onTap, required String label, bool active = false}) {
      return Semantics(
        label: label,
        button: true,
        selected: active,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: active ? t.primary : t.border),
              color: active ? t.primary : Colors.transparent,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: small ? 12 : 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? t.primaryForeground : t.mutedForeground,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // «قبلی» به راست اشاره می‌کند (جهت خواندن).
        button(
          label: "صفحه‌ی قبل",
          onTap: page <= 1 ? null : () => onChange(page - 1),
          child: Icon(Icons.chevron_right, size: 16, color: page <= 1 ? t.mutedForeground.withValues(alpha: 0.4) : t.mutedForeground),
        ),
        for (final p in _range())
          if (p is String)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text("…", style: TextStyle(color: t.mutedForeground)),
            )
          else
            _pageButton(context, t, n: p as int),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: button(
            label: "صفحه‌ی بعد",
            onTap: page >= total ? null : () => onChange(page + 1),
            child: Icon(Icons.chevron_left, size: 16, color: page >= total ? t.mutedForeground.withValues(alpha: 0.4) : t.mutedForeground),
          ),
        ),
      ],
    );
  }

  Widget _pageButton(BuildContext context, VibeTokens t, {required int n}) {
    final size = small ? 32.0 : 36.0;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Semantics(
        label: "صفحه‌ی ${fa(n)}",
        button: true,
        selected: n == page,
        child: GestureDetector(
          onTap: () => onChange(n),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: n == page ? t.primary : t.border),
              color: n == page ? t.primary : Colors.transparent,
            ),
            child: Text(
              fa(n),
              style: TextStyle(
                fontSize: small ? 12 : 14,
                fontWeight: n == page ? FontWeight.w600 : FontWeight.w400,
                color: n == page ? t.primaryForeground : t.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
