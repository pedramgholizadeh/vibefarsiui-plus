import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'showcase/foundation.dart';
import 'showcase/forms.dart';
import 'showcase/iranian.dart';
import 'showcase/jalali.dart';

/// اپ نمایشی وایب‌فارسی — تمام ویجت‌های پکیج با داده‌ی واقعی فارسی.
void main() {
  runApp(const VibeFarsiShowcaseApp());
}

class VibeFarsiShowcaseApp extends StatelessWidget {
  const VibeFarsiShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "وایب‌فارسی",
      debugShowCheckedModeBanner: false,
      theme: VibeTheme.dark(),
      darkTheme: VibeTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: const Locale("fa", "IR"),
      supportedLocales: const [Locale("fa", "IR")],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _index = 0;

  static const _pages = [
    (FoundationShowcase(), "پایه", Icons.palette_outlined),
    (FormsShowcase(), "فرم", Icons.edit_note_outlined),
    (IranianShowcase(), "ایرانی", Icons.badge_outlined),
    (JalaliShowcase(), "شمسی", Icons.calendar_month_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("وایب‌فارسی · فلاتر"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _pageCard(_index),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final (_, label, icon) in _pages)
            NavigationDestination(icon: Icon(icon), label: label),
        ],
      ),
    );
  }

  Widget _pageCard(int i) => _pages[i].$1;
}
