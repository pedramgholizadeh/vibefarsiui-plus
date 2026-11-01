import 'package:flutter/material.dart';

import '../theme.dart';

/// جهت جداکننده.
enum VibeSeparatorOrientation { horizontal, vertical }

/// جداکننده — پورت `registry/ui/separator.tsx`.
///
/// خط مویی از رنگ `border`؛ افقی یا عمودی. با `label` متن در وسط خط
/// افقی می‌نشیند (مثل «یا»). به‌طور پیش‌فرض تزئینی است و از درخت
/// دسترس‌پذیری حذف می‌شود.
///
/// ```dart
/// VibeSeparator()
/// VibeSeparator(orientation: VibeSeparatorOrientation.vertical)
/// VibeSeparator(label: Text("یا"))
/// ```
class VibeSeparator extends StatelessWidget {
  const VibeSeparator({
    super.key,
    this.orientation = VibeSeparatorOrientation.horizontal,
    this.label,
    this.decorative = true,
  });

  final VibeSeparatorOrientation orientation;

  /// متن وسط خط افقی؛ برای خط عمودی بی‌اثر است.
  final Widget? label;

  /// اگر `false` باشد نقش جداکننده در دسترس‌پذیری حفظ می‌شود.
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final Widget content;

    if (orientation == VibeSeparatorOrientation.vertical) {
      // self-stretch وب: تا ارتفاع والدِ کشسان بالا کشیده می‌شود
      content = Container(width: 1, color: t.border);
    } else if (label == null) {
      content = Container(height: 1, color: t.border);
    } else {
      final hairline = Container(height: 1, color: t.border);
      content = Row(
        children: [
          Expanded(child: hairline),
          const SizedBox(width: 12),
          Flexible(
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: 12, color: t.mutedForeground),
              child: label!,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: hairline),
        ],
      );
    }

    if (decorative) return ExcludeSemantics(child: content);
    return Semantics(child: content);
  }
}
