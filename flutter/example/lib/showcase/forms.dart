import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// ویجت‌های فرم — با تکمیل دسته‌های پورت، این صفحه پر می‌شود.
class FormsShowcase extends StatelessWidget {
  const FormsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShowSection(
      title: "دکمه‌ها",
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          VibeButton(onPressed: null, child: Text("ثبت سفارش")),
        ],
      ),
    );
  }
}
