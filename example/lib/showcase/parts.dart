import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

/// کارت بخش نمایشی با عنوان و محتوا.
class ShowSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ShowSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.surface),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// فهرست «کد → نتیجه» برای نمایش رفتار توابع؛ عنوان اختیاری بالای فهرست.
class FactList extends StatelessWidget {
  final String? title;
  final List<(String, String)> facts;

  const FactList({super.key, this.title, required this.facts});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
        ],
        for (final (code, result) in facts)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$code → ",
                    style: TextStyle(color: t.mutedForeground, fontSize: 13),
                  ),
                  TextSpan(text: result, style: const TextStyle(fontSize: 13)),
                ],
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
      ],
    );
  }
}
