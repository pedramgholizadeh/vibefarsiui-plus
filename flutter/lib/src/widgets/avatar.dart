import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// اندازه‌ی آواتار.
enum VibeAvatarSize { sm, md, lg }

(double, double, double) _sizeOf(VibeAvatarSize size) => switch (size) {
      // (قطر، اندازه‌ی فونت، ضخامت حلقه) — مطابق sizes وب
      VibeAvatarSize.sm => (28, 11, 2),
      VibeAvatarSize.md => (36, 13, 2),
      VibeAvatarSize.lg => (48, 14, 2),
    };

/// آواتار — پورت `registry/ui/avatar.tsx`.
///
/// با `src` عکس (شبکه) نشان می‌دهد؛ بدون عکس، حرف اول نام روی حلقه‌ی رنگ
/// متن می‌نشیند. اگر عکس لود نشود به حرف اول برمی‌گردد.
///
/// ```dart
/// VibeAvatar(name: "پدرام")
/// VibeAvatar(name: "سارا", src: "https://…/sara.jpg", size: VibeAvatarSize.lg)
/// ```
class VibeAvatar extends StatelessWidget {
  const VibeAvatar({
    super.key,
    required this.name,
    this.src,
    this.size = VibeAvatarSize.md,
    this.ringColor,
  });

  /// نام کامل؛ برای حرف اول و برچسب دسترس‌پذیری استفاده می‌شود.
  final String name;

  /// نشانی عکس (شبکه). null یعنی آواتار حرفی.
  final String? src;

  final VibeAvatarSize size;

  /// رنگ حلقه‌ی دور آواتار حرفی؛ پیش‌فرض `foreground`.
  /// [VibeAvatarGroup] آن را به رنگ پس‌زمینه تغییر می‌دهد تا هم‌پوشانی تمیز بماند.
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final (diameter, fontSize, ring) = _sizeOf(size);
    final initial = name.trim().isEmpty ? "" : name.trim().characters.first;

    Widget content;
    if (src != null) {
      content = Image.network(
        src!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialText(t, fontSize, initial),
      );
    } else {
      content = _initialText(t, fontSize, initial);
    }

    return Semantics(
      label: name,
      button: false,
      child: ExcludeSemantics(
        child: Container(
          width: diameter,
          height: diameter,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // بدون عکس: حلقه‌ی پیش‌فرض foreground؛ در گروه، حلقه‌ی background
            border: src == null || ringColor != null
                ? Border.all(
                    color: src == null ? (ringColor ?? t.foreground) : ringColor!,
                    width: ring,
                  )
                : null,
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _initialText(VibeTokens t, double fontSize, String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: t.foreground,
          height: 1,
        ),
      ),
    );
  }
}

/// یک عضو گروه آواتار: نام + عکس اختیاری.
class VibePerson {
  const VibePerson({required this.name, this.src});

  final String name;
  final String? src;
}

/// گروه آواتار — پورت `AvatarGroup` از `registry/ui/avatar.tsx`.
///
/// آواتارها روی هم می‌افتند (۸ پیکسل هم‌پوشانی) و اضافه‌ها «+n نفر دیگر» می‌شوند.
///
/// ```dart
/// VibeAvatarGroup(people: [VibePerson(name: "پدرام"), VibePerson(name: "سارا")], max: 4)
/// ```
class VibeAvatarGroup extends StatelessWidget {
  const VibeAvatarGroup({super.key, required this.people, this.max = 4, this.size = VibeAvatarSize.md});

  final List<VibePerson> people;

  /// حداکثر آواتار نمایش‌داده‌شده.
  final int max;

  final VibeAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final shown = people.take(max).toList(growable: false);
    final rest = people.length - shown.length;
    final (diameter, _, _) = _sizeOf(size);
    // فاصله‌ی شروع هر آواتار بعدی: ۸ پیکسل هم‌پوشانی مثل -ms-2 وب
    final step = diameter - 8.0;
    final stackWidth = shown.isEmpty ? 0.0 : shown.length * step + 8.0;

    final stack = SizedBox(
      width: stackWidth,
      height: shown.isEmpty ? 0.0 : diameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < shown.length; i++)
            PositionedDirectional(
              start: i * step,
              top: 0,
              child: VibeAvatar(
                name: shown[i].name,
                src: shown[i].src,
                size: size,
                ringColor: t.background,
              ),
            ),
        ],
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        stack,
        if (rest > 0) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "+${fa(rest)} نفر دیگر",
              style: TextStyle(fontSize: 12, color: t.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
