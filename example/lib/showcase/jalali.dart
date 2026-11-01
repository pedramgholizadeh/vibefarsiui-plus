import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// تقویم شمسی: تبدیل، قالب‌بندی و کبیسه.
class JalaliShowcase extends StatelessWidget {
  const JalaliShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final now = JalaliDate.now();
    final norooz = JalaliDate(now.jy + 1, 1, 1);
    final daysToNorooz = norooz.toDateTime().difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FactList(title: "امروز", facts: [
          ("formatJalali(now, weekday: true)", formatJalali(DateTime.now(), weekday: true)),
          ("formatJalaliNumeric(now)", formatJalaliNumeric(DateTime.now())),
          ("jalaliMonths[now.jm - 1]", now.monthName),
          ("jalaliWeekdays[now.weekday]", jalaliWeekdays[now.weekday]),
        ]),
        FactList(title: "تبدیل", facts: [
          ("toGregorian(1404, 1, 1)", _fmt(toGregorian(1404, 1, 1))),
          ("JalaliDate.fromDateTime(DateTime(2025, 3, 21))",
              JalaliDate.fromDateTime(DateTime(2025, 3, 21)).toString()),
        ]),
        FactList(title: "کبیسه و طول ماه", facts: [
          ("isLeapJalaliYear(1403)", isLeapJalaliYear(1403) ? "true" : "false"),
          ("isLeapJalaliYear(1404)", isLeapJalaliYear(1404) ? "true" : "false"),
          ("JalaliDate(1403, 12, 1).monthLength", fa(const JalaliDate(1403, 12, 1).monthLength)),
        ]),
        FactList(title: "نوروز", facts: [
          ("نوروز ${fa(norooz.jy)}", norooz.format(weekday: true)),
          ("تا نوروز", "${fa(daysToNorooz)} روز"),
        ]),
      ],
    );
  }

  static String _fmt(DateTime d) =>
      "${d.year}/${d.month.toString().padLeft(2, "0")}/${d.day.toString().padLeft(2, "0")}";
}
