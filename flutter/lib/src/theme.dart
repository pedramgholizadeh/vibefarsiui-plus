/// تم وایب‌فارسی برای فلاتر — پورت توکن‌های تم گرافیت (پیش‌فرض تیره).
///
/// رنگ‌ها از `registry/themes/graphite.css` با تبدیل دقیق oklch → sRGB آمده‌اند.
library;

import 'package:flutter/material.dart';

/// توکن‌هایی که در [ColorScheme] جا نمی‌شوند: موفقیت، هشدار، برند، کارت، حاشیه و…
@immutable
class VibeTokens extends ThemeExtension<VibeTokens> {
  const VibeTokens({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.success,
    required this.warning,
    required this.brand,
    required this.brandForeground,
    required this.ring,
    required this.border,
    required this.input,
  });

  /// پس‌زمینه‌ی صفحه — oklch(0.115 0.002 285).
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color success;
  final Color warning;
  final Color brand;
  final Color brandForeground;
  final Color ring;
  final Color border;
  final Color input;

  /// توکن‌های تم پیش‌فرض (گرافیت تیره).
  static const VibeTokens dark = VibeTokens(
    background: Color(0xFF050506), // oklch(0.115 0.002 285)
    foreground: Color(0xFFF7F7F7), // oklch(0.975 0 0)
    card: Color(0xFF09090A), // oklch(0.14 0.002 285)
    cardForeground: Color(0xFFF7F7F7),
    popover: Color(0xFF0D0D0E), // oklch(0.16 0.002 285)
    popoverForeground: Color(0xFFF7F7F7),
    primary: Color(0xFFF7F7F7), // oklch(0.975 0 0)
    primaryForeground: Color(0xFF070707), // oklch(0.13 0 0)
    secondary: Color(0xFF161617), // oklch(0.2 0.002 285)
    secondaryForeground: Color(0xFFF7F7F7),
    muted: Color(0xFF101011), // oklch(0.175 0.002 285)
    mutedForeground: Color(0xFF89898B), // oklch(0.63 0.004 285)
    accent: Color(0xFF161617),
    accentForeground: Color(0xFFF7F7F7),
    destructive: Color(0xFFF14D4C), // oklch(0.65 0.2 25)
    success: Color(0xFF2ACC8A), // oklch(0.75 0.16 160)
    warning: Color(0xFFFAB72A), // oklch(0.82 0.16 80)
    brand: Color(0xFFFFA430), // oklch(0.8 0.165 65)
    brandForeground: Color(0xFF2E1200), // oklch(0.22 0.06 60)
    ring: Color(0xFF9E9E9E), // oklch(0.7 0 0)
    border: Color(0x14FFFFFF), // سفید با شفافیت ۸٪
    input: Color(0x1CFFFFFF), // سفید با شفافیت ۱۱٪
  );

  /// گرافیت روشن: همان زبان طراحی با نوت‌های معکوس برای حالت روشن.
  static const VibeTokens light = VibeTokens(
    background: Color(0xFFFCFCFC),
    foreground: Color(0xFF0A0A0B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF0A0A0B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF0A0A0B),
    primary: Color(0xFF101011),
    primaryForeground: Color(0xFFF7F7F7),
    secondary: Color(0xFFEDEDEF),
    secondaryForeground: Color(0xFF0A0A0B),
    muted: Color(0xFFF2F2F3),
    mutedForeground: Color(0xFF6B6B6E),
    accent: Color(0xFFEDEDEF),
    accentForeground: Color(0xFF0A0A0B),
    destructive: Color(0xFFD93A39),
    success: Color(0xFF12855B),
    warning: Color(0xFFB37400),
    brand: Color(0xFFD97E06),
    brandForeground: Color(0xFFFFF6E8),
    ring: Color(0xFF6E6E70),
    border: Color(0x14000000),
    input: Color(0x1C000000),
  );

  /// تم lapis — پورت registry/themes/lapis.css
  static const VibeTokens lapis = VibeTokens(
    background: Color(0xFF050815),
    foreground: Color(0xFFD6E7F8),
    card: Color(0xFF080D1D),
    cardForeground: Color(0xFFD6E7F8),
    popover: Color(0xFF0B1121),
    popoverForeground: Color(0xFFD6E7F8),
    primary: Color(0xFF61A4FF),
    primaryForeground: Color(0xFF050815),
    secondary: Color(0xFF131A2D),
    secondaryForeground: Color(0xFFD6E7F8),
    muted: Color(0xFF0D1323),
    mutedForeground: Color(0xFF8799B8),
    accent: Color(0xFF111C34),
    accentForeground: Color(0xFFD6E7F8),
    destructive: Color(0xFFF75D59),
    success: Color(0xFF6FEA77),
    warning: Color(0xFFF4C947),
    brand: Color(0xFF6FEA77),
    brandForeground: Color(0xFF011205),
    ring: Color(0xFF6FEA77),
    border: Color(0x4280A5E3),
    input: Color(0x5780A5E3),
  );

  /// تم paper — پورت registry/themes/paper.css
  static const VibeTokens paper = VibeTokens(
    background: Color(0xFFFBFAF7),
    foreground: Color(0xFF1A1512),
    card: Color(0xFFFBFAF7),
    cardForeground: Color(0xFF1A1512),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF1A1512),
    primary: Color(0xFF1A1512),
    primaryForeground: Color(0xFFFBFAF7),
    secondary: Color(0xFFEEEBE5),
    secondaryForeground: Color(0xFF1A1512),
    muted: Color(0xFFF2F0EC),
    mutedForeground: Color(0xFF615953),
    accent: Color(0xFFEEEBE5),
    accentForeground: Color(0xFF1A1512),
    destructive: Color(0xFFCC272E),
    success: Color(0xFF007F4E),
    warning: Color(0xFFBB7400),
    brand: Color(0xFFC83122),
    brandForeground: Color(0xFFFAFAFA),
    ring: Color(0xFF6C6158),
    border: Color(0x241A1512),
    input: Color(0x4D1A1512),
  );

  /// تم pomegranate — پورت registry/themes/pomegranate.css
  static const VibeTokens pomegranate = VibeTokens(
    background: Color(0xFFFCE5E6),
    foreground: Color(0xFF3B1B1E),
    card: Color(0xFFFFF4F4),
    cardForeground: Color(0xFF3B1B1E),
    popover: Color(0xFFFFF8F8),
    popoverForeground: Color(0xFF3B1B1E),
    primary: Color(0xFFDE3951),
    primaryForeground: Color(0xFFFFFAFB),
    secondary: Color(0xFFF4D5D6),
    secondaryForeground: Color(0xFF3B1B1E),
    muted: Color(0xFFF8DDDE),
    mutedForeground: Color(0xFF7D585A),
    accent: Color(0xFFF8D4D5),
    accentForeground: Color(0xFF3B1B1E),
    destructive: Color(0xFFCC2823),
    success: Color(0xFF00935D),
    warning: Color(0xFFD6810C),
    brand: Color(0xFFBF50A0),
    brandForeground: Color(0xFFFCFCFC),
    ring: Color(0xFFDE3951),
    border: Color(0x173B1B1E),
    input: Color(0x1F3B1B1E),
  );

  /// تم saffron — پورت registry/themes/saffron.css
  static const VibeTokens saffron = VibeTokens(
    background: Color(0xFFFAEEC9),
    foreground: Color(0xFF130E0B),
    card: Color(0xFFFFFEF6),
    cardForeground: Color(0xFF130E0B),
    popover: Color(0xFFFFFEF6),
    popoverForeground: Color(0xFF130E0B),
    primary: Color(0xFFFFB407),
    primaryForeground: Color(0xFF130E0B),
    secondary: Color(0xFFFFFEF6),
    secondaryForeground: Color(0xFF130E0B),
    muted: Color(0xFFEEE1BC),
    mutedForeground: Color(0xFF524536),
    accent: Color(0xFFFCD176),
    accentForeground: Color(0xFF130E0B),
    destructive: Color(0xFFDF2321),
    success: Color(0xFF05893E),
    warning: Color(0xFFCC6600),
    brand: Color(0xFFED4042),
    brandForeground: Color(0xFFFCFCFC),
    ring: Color(0xFF130E0B),
    border: Color(0xFF130E0B),
    input: Color(0xFF130E0B),
  );

  /// تم turquoise — پورت registry/themes/turquoise.css
  static const VibeTokens turquoise = VibeTokens(
    background: Color(0xFF001A25),
    foreground: Color(0xFFEEF7F8),
    card: Color(0x12E6FAFA),
    cardForeground: Color(0xFFEEF7F8),
    popover: Color(0xE0022632),
    popoverForeground: Color(0xFFEEF7F8),
    primary: Color(0xFF60EAE2),
    primaryForeground: Color(0xFF001C22),
    secondary: Color(0x1CE6FAFA),
    secondaryForeground: Color(0xFFEEF7F8),
    muted: Color(0x0FE6FAFA),
    mutedForeground: Color(0xFFA1C6CA),
    accent: Color(0x1FE6FAFA),
    accentForeground: Color(0xFFEEF7F8),
    destructive: Color(0xFFFA686A),
    success: Color(0xFF41DCA5),
    warning: Color(0xFFF8C655),
    brand: Color(0xFF81EDC1),
    brandForeground: Color(0xFF001D17),
    ring: Color(0xFF60EAE2),
    border: Color(0x29DFFCFD),
    input: Color(0x38DFFCFD),
  );

  /// توکن‌های تم جاری؛ اگر تم وایب‌فارسی ست نشده باشد به گرافیت تیره برمی‌گردد.
  static VibeTokens of(BuildContext context) =>
      Theme.of(context).extension<VibeTokens>() ?? dark;

  @override
  VibeTokens copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? success,
    Color? warning,
    Color? brand,
    Color? brandForeground,
    Color? ring,
    Color? border,
    Color? input,
  }) {
    return VibeTokens(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      brand: brand ?? this.brand,
      brandForeground: brandForeground ?? this.brandForeground,
      ring: ring ?? this.ring,
      border: border ?? this.border,
      input: input ?? this.input,
    );
  }

  @override
  VibeTokens lerp(VibeTokens? other, double t) {
    if (other == null) return this;
    return VibeTokens(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      popover: Color.lerp(popover, other.popover, t)!,
      popoverForeground: Color.lerp(popoverForeground, other.popoverForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(primaryForeground, other.primaryForeground, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground: Color.lerp(secondaryForeground, other.secondaryForeground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandForeground: Color.lerp(brandForeground, other.brandForeground, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
    );
  }
}

/// دسترسی سریع به توکن‌ها: `context.vibe.brand`.
extension VibeTokensContext on BuildContext {
  VibeTokens get vibe => VibeTokens.of(this);
}

/// زبان طراحی: شعاع‌ها، حرکت و فشردگی — پورت متغیرهای شکل و حرکت گرافیت.
abstract final class VibeRadius {
  /// `--radius: 0.625rem`
  static const double base = 10;

  /// `--shape-control` = base − 2
  static const double control = 8;

  /// `--shape-field` = base − 2
  static const double field = 8;

  /// `--shape-surface` = base + 12
  static const double surface = 22;

  /// `--shape-overlay` = base + 4
  static const double overlay = 14;
}

/// `--motion: 200ms` با `cubic-bezier(0.2, 0, 0, 1)`.
abstract final class VibeMotion {
  static const Duration duration = Duration(milliseconds: 200);
  static const Cubic ease = Cubic(0.2, 0, 0, 1);
  static const Duration slow = Duration(milliseconds: 350);
}

/// `--press: scale(0.98)` برای حالت فشرده‌ی دکمه‌ها.
abstract final class VibePress {
  static const double scale = 0.98;
}

/// سازنده‌ی [ThemeData] وایب‌فارسی: گرافیت تیره (پیش‌فرض) یا روشن.
///
/// ```dart
/// MaterialApp(
///   theme: VibeTheme.light(),
///   darkTheme: VibeTheme.dark(),
///   themeMode: ThemeMode.dark,
/// )
/// ```
abstract final class VibeTheme {
  /// تم گرافیت تیره — پیش‌فرض وایب‌فارسی.
  ///
  /// [fontFamily] به‌صورت پیش‌فرض «Vazirmatn» است؛ فونت را در پروژه‌ی خودتان
  /// باندل کنید (فایل ttf یا پکیج google_fonts) یا نام فونت دیگری بدهید.
  static ThemeData dark({String fontFamily = "Vazirmatn"}) =>
      _build(VibeTokens.dark, Brightness.dark, fontFamily);

  /// تم گرافیت روشن.
  static ThemeData light({String fontFamily = "Vazirmatn"}) =>
      _build(VibeTokens.light, Brightness.light, fontFamily);

  /// تم با توکن‌های دلخواه — مثلاً تم‌های رسمی رجیستری:
  ///
  /// ```dart
  /// VibeTheme.withTokens(VibeTokens.saffron, Brightness.light)
  /// VibeTheme.withTokens(VibeTokens.lapis, Brightness.dark)
  /// ```
  static ThemeData withTokens(VibeTokens tokens, Brightness brightness, {String fontFamily = "Vazirmatn"}) =>
      _build(tokens, brightness, fontFamily);

  static ThemeData _build(VibeTokens t, Brightness brightness, String fontFamily) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: t.primary,
      onPrimary: t.primaryForeground,
      secondary: t.secondary,
      onSecondary: t.secondaryForeground,
      surface: t.card,
      onSurface: t.cardForeground,
      error: t.destructive,
      onError: Colors.white,
      tertiary: t.brand,
      onTertiary: t.brandForeground,
      surfaceContainerHighest: t.muted,
      onSurfaceVariant: t.mutedForeground,
      outline: t.border,
      outlineVariant: t.border,
    );

    final baseText = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      splashFactory: NoSplash.splashFactory,
    );

    return baseText.copyWith(
      extensions: [t],
      scaffoldBackgroundColor: t.background,
      canvasColor: t.background,
      dividerColor: t.border,
      textTheme: _persianTextTheme(baseText.textTheme, t),
      dialogTheme: DialogThemeData(
        backgroundColor: t.popover,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeRadius.overlay),
          side: BorderSide(color: t.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.popover,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          side: BorderSide(color: t.border),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.popover,
          borderRadius: BorderRadius.circular(VibeRadius.field),
          border: Border.all(color: t.border),
        ),
        textStyle: TextStyle(fontSize: 13, color: t.popoverForeground, fontFamily: fontFamily),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.popover,
        contentTextStyle: TextStyle(fontSize: 14, color: t.popoverForeground, fontFamily: fontFamily),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeRadius.field),
          side: BorderSide(color: t.border),
        ),
      ),
    );
  }

  /// تایپوگرافی فارسی: ارتفاع خط بیشتر، بدون letter-spacing (حروف فارسی چسبیده می‌مانند).
  static TextTheme _persianTextTheme(TextTheme base, VibeTokens t) {
    // وزن و ارتفاع نمایش/عنوان‌ها برای فارسی تنظیم می‌شود؛ بقیه از تم پایه.
    return base
        .apply(bodyColor: t.foreground, displayColor: t.foreground)
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
          headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.4),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.45),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.45),
          bodyLarge: base.bodyLarge?.copyWith(height: 1.7),
          bodyMedium: base.bodyMedium?.copyWith(height: 1.7),
          bodySmall: base.bodySmall?.copyWith(height: 1.6),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.45),
          labelMedium: base.labelMedium?.copyWith(height: 1.5),
          labelSmall: base.labelSmall?.copyWith(height: 1.5),
        );
  }
}
