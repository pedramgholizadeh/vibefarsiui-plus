import 'package:flutter/material.dart';

import '../theme.dart';

/// کلید میانبر — پورت `registry/ui/kbd.tsx`.
///
/// همیشه چپ‌چین تا «⌘ K» همان‌طور که تایپ شده خوانده شود.
///
/// ```dart
/// VibeKbd(keys: const ["⌘", "K"])
/// ```
class VibeKbd extends StatelessWidget {
  final List<String> keys;

  const VibeKbd({super.key, required this.keys});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: t.border),
                color: t.card,
                boxShadow: [
                  BoxShadow(color: t.border, offset: const Offset(0, 1), spreadRadius: -1),
                ],
              ),
              child: Text(
                keys[i],
                style: TextStyle(fontSize: 11, height: 1.6, color: t.foreground.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
