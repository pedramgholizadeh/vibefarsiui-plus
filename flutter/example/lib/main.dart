import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'showcase/animations_page.dart';
import 'showcase/backgrounds_page.dart';
import 'showcase/blocks.dart';
import 'showcase/calendar_page.dart';
import 'showcase/charts_page.dart';
import 'showcase/components.dart';
import 'showcase/iranian_fields.dart';
import 'showcase/themes_page.dart';

/// اپ نمایشی وایب‌فارسی — همه‌ی کامپوننت‌ها با دسته‌بندی سایت اصلی.
void main() {
  runApp(const VibeFarsiShowcaseApp());
}

class VibeFarsiShowcaseApp extends StatelessWidget {
  const VibeFarsiShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "وایب‌فارسی · فلاتر",
      debugShowCheckedModeBanner: false,
      theme: VibeTheme.dark(fontFamily: "IRANSans"),
      darkTheme: VibeTheme.dark(fontFamily: "IRANSans"),
      themeMode: ThemeMode.dark,
      locale: const Locale("fa", "IR"),
      supportedLocales: const [Locale("fa", "IR")],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const ShowcaseShell(),
    );
  }
}

/// دسته‌بندی‌ها مثل سایت vibefarsi.ir
class _Category {
  final String label;
  final IconData icon;
  final WidgetBuilder page;

  const _Category(this.label, this.icon, this.page);
}

final _categories = <_Category>[
  _Category("کامپوننت‌ها", Icons.widgets_outlined, (_) => const ComponentsShowcase()),
  _Category("فیلدهای ایرانی", Icons.credit_card_outlined, (_) => const IranianFieldsShowcase()),
  _Category("بلاک‌ها", Icons.dashboard_outlined, (_) => const BlocksShowcase()),
  _Category("نمودارها", Icons.bar_chart_outlined, (_) => const ChartsShowcase()),
  _Category("تقویم", Icons.calendar_month_outlined, (_) => const CalendarShowcase()),
  _Category("انیمیشن‌ها", Icons.animation_outlined, (_) => const AnimationsShowcase()),
  _Category("پس‌زمینه‌ها", Icons.texture_outlined, (_) => const BackgroundsShowcase()),
  _Category("سیستم‌های طراحی", Icons.palette_outlined, (_) => const ThemesShowcase()),
];

class ShowcaseShell extends StatefulWidget {
  const ShowcaseShell({super.key});

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  int _index = 0;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final category = _categories[_index];

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // سایدبار مثل سایت.
          Container(
            width: 230,
            color: t.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.brand,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("و", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.brandForeground)),
                      ),
                      const SizedBox(width: 10),
                      const Text("وایب‌فارسی", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: t.muted,
                        ),
                        child: Text("فلاتر", style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: VibeSidebar(sections: [
                    VibeSidebarSection(label: const Text("دسته‌بندی‌ها"), items: [
                      for (var i = 0; i < _categories.length; i++)
                        VibeSidebarItem(
                          icon: _categories[i].icon,
                          label: Text(_categories[i].label),
                          active: i == _index,
                          onTap: () {
                            setState(() {
                              _index = i;
                            });
                            _scroll.jumpTo(0);
                          },
                        ),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
          // محتوا.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // هدر صفحه.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: t.card,
                    border: Border(bottom: BorderSide(color: t.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(category.icon, size: 18, color: t.brand),
                      const SizedBox(width: 8),
                      Text(category.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.foreground)),
                      const Spacer(),
                      Text(
                        "پکیج vibefarsi برای فلاتر",
                        style: TextStyle(fontSize: 12, color: t.mutedForeground),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(24),
                    child: category.page(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
