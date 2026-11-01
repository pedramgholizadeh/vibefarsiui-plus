import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// ویجت‌های فرم: ورودی، سلکت، سوییچ، اسلایدر و…
class FormsShowcase extends StatefulWidget {
  const FormsShowcase({super.key});

  @override
  State<FormsShowcase> createState() => _FormsShowcaseState();
}

class _FormsShowcaseState extends State<FormsShowcase> {
  bool _notifications = true;
  double _quantity = 3;
  String? _city;
  String _search = "";
  List<String> _tags = const ["فروشگاه", "تخفیف"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "ورودی متن",
          child: Column(
            children: [
              const VibeInput(hintText: "مثلاً: سارا محمدی"),
              const SizedBox(height: 12),
              VibeSearchInput(onChanged: (v) => setState(() => _search = v)),
              if (_search.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text("جست‌وجو: $_search", style: TextStyle(fontSize: 12, color: context.vibe.mutedForeground)),
              ],
            ],
          ),
        ),
        ShowSection(
          title: "انتخاب‌ها",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeSelect(
                options: const [
                  VibeSelectOption(value: "teh", label: "تهران"),
                  VibeSelectOption(value: "esf", label: "اصفهان"),
                  VibeSelectOption(value: "shz", label: "شیراز"),
                ],
                value: _city,
                onChanged: (v) => setState(() => _city = v),
                hint: "شهر را انتخاب کنید",
              ),
              const SizedBox(height: 12),
              VibeTagsInput(
                value: _tags,
                onChanged: (t) => setState(() => _tags = t),
                max: 5,
              ),
            ],
          ),
        ),
        ShowSection(
          title: "سوییچ و اسلایدر",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  VibeSwitch(value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
                  const SizedBox(width: 8),
                  Text("اعلان‌ها ${_notifications ? "روشن" : "خاموش"} است", style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              VibeSlider(
                value: _quantity,
                min: 1,
                max: 10,
                onChanged: (v) => setState(() => _quantity = v),
                label: const Text("تعداد"),
                showValue: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
