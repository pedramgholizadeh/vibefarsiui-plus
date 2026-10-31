/// ابزارهای مشترک تقویم — پورت `lib/calendar-utils.ts` (بخش‌های استفاده‌شده).
library;

import 'jalali.dart';
import 'persian.dart';

/// شروع هفته‌ی شمسی (شنبه) برای [date].
DateTime startOfJalaliWeek(DateTime date) => DateTime(date.year, date.month, date.day - jalaliWeekday(date));

DateTime addDaysUtil(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// یک ماه شمسی جلو/عقب با حفظ روز (کوتاه‌شدن به آخر ماه).
DateTime addJalaliMonths(DateTime date, int n) {
  final j = toJalali(date);
  final total = j.jy * 12 + (j.jm - 1) + n;
  final y = total ~/ 12;
  final m = total % 12 + 1;
  final day = j.jd < jalaliMonthLength(y, m) ? j.jd : jalaliMonthLength(y, m);
  return toGregorian(y, m, day);
}

/// شبکه‌ی ماه: هفته‌ها × ۷ روز، شروع از شنبه؛ [fixedWeeks] همیشه ۶ هفته.
List<List<DateTime>> monthGrid(int jy, int jm, {bool fixedWeeks = false}) {
  final first = toGregorian(jy, jm, 1);
  final start = startOfJalaliWeek(first);
  final used = jalaliWeekday(first) + jalaliMonthLength(jy, jm);
  final rows = fixedWeeks ? 6 : (used / 7).ceil();
  return List.generate(rows, (r) => List.generate(7, (c) => addDaysUtil(start, r * 7 + c)));
}

/// «مهر ۱۴۰۵».
String monthTitle(int jy, int jm) => "${jalaliMonths[jm - 1]} ${jalaliMonthTitleYear(jy)}";

String jalaliMonthTitleYear(int jy) {
  return fa(jy);
}
