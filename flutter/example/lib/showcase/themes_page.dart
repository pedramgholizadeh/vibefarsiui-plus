import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «سیستم‌های طراحی»: هر ۶ تم رسمی با نمونه‌ی زنده.
class ThemesShowcase extends StatelessWidget {
  const ThemesShowcase({super.key});

  static const _themes = [
    ("گرافیت تیره", VibeTokens.dark),
    ("گرافیت روشن", VibeTokens.light),
    ("لاجورد", VibeTokens.lapis),
    ("کاغذ", VibeTokens.paper),
    ("انار", VibeTokens.pomegranate),
    ("زعفران", VibeTokens.saffron),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "توکن‌های هر تم",
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final (name, tokens) in _themes) _themeCard(context, name, tokens),
            ],
          ),
        ),
      ],
    );
  }

  Widget _themeCard(BuildContext context, String name, VibeTokens tokens) {
    final t = context.vibe;
    return Container(
      width: 300,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.field),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // پیش‌نمایش زنده: پس‌زمینه + دکمه‌ها + نشان روی توکن‌های همان تم.
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (final color in [tokens.brand, tokens.primary, tokens.success, tokens.warning, tokens.destructive])
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: tokens.border),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _button(tokens, "تأیید", fill: tokens.primary, textColor: tokens.primaryForeground),
                    const SizedBox(width: 6),
                    _button(tokens, "انصراف", fill: Colors.transparent, textColor: tokens.foreground, outline: tokens.input),
                    const SizedBox(width: 6),
                    _button(tokens, "برند", fill: tokens.brand, textColor: tokens.brandForeground),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "متن اصلی روی پس‌زمینه — ۱۲٬۴۵۰٬۰۰۰ تومان",
                  style: TextStyle(fontSize: 12, color: tokens.foreground),
                ),
                Text(
                  "متن کم‌رنگ راهنما",
                  style: TextStyle(fontSize: 11, color: tokens.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(VibeTokens tokens, String label, {required Color fill, required Color textColor, Color? outline}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: outline ?? Colors.transparent),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
