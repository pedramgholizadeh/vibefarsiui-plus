/// تعطیلات رسمی ایران و مناسبت‌ها — پورت `lib/iran-holidays.ts`.
///
/// قاعده‌محور: خورشیدی بر اساس تاریخ شمسی و مذهبی بر اساس تاریخ قمری از
/// `hijri.dart`. سال‌های [verifiedJalaliYears] با تقویم رسمی روزبه‌روز
/// چک‌شده‌اند؛ بیرون آن‌ها مناسبت‌های قمری `approximate: true` دارند.
library;

import 'hijri.dart';
import 'jalali.dart';

/// یک مناسبت.
class Occasion {
  /// کلید روز میلادی «YYYY-MM-DD».
  final String key;
  final DateTime date;
  final String title;

  /// تعطیل رسمی.
  final bool holiday;
  final bool solar;

  /// مناسبت قمری بیرون جدول رسمی؛ ممکن است یک روز خطا داشته باشد.
  final bool approximate;
  final HijriDate? hijri;

  const Occasion({
    required this.key,
    required this.date,
    required this.title,
    required this.holiday,
    required this.solar,
    required this.approximate,
    this.hijri,
  });
}

/// مناسبت‌های یک روز («YYYY-MM-DD» میلادی).
typedef OccasionProvider = List<Occasion> Function(String key);

/// سال‌های شمسی چک‌شده با تقویم رسمی.
const List<int> verifiedJalaliYears = [1404, 1405];

const List<(int, int, String, bool)> _solar = [
  (1, 1, "نوروز", true),
  (1, 2, "نوروز", true),
  (1, 3, "نوروز", true),
  (1, 4, "نوروز", true),
  (1, 12, "روز جمهوری اسلامی", true),
  (1, 13, "روز طبیعت", true),
  (2, 12, "روز معلم", false),
  (3, 14, "رحلت امام خمینی", true),
  (3, 15, "قیام ۱۵ خرداد", true),
  (9, 16, "روز دانشجو", false),
  (9, 30, "شب یلدا", false),
  (11, 22, "پیروزی انقلاب اسلامی", true),
  (12, 29, "روز ملی شدن صنعت نفت", true),
];

const List<(int, Object, String, bool)> _lunar = [
  (1, 9, "تاسوعای حسینی", true),
  (1, 10, "عاشورای حسینی", true),
  (2, 20, "اربعین حسینی", true),
  (2, 28, "رحلت پیامبر و شهادت امام حسن مجتبی", true),
  (2, "last", "شهادت امام رضا", true),
  (3, 8, "شهادت امام حسن عسکری", true),
  (3, 17, "میلاد پیامبر و امام جعفر صادق", true),
  (6, 3, "شهادت حضرت فاطمه", true),
  (6, 20, "روز زن و مادر", false),
  (7, 13, "ولادت امام علی و روز پدر", true),
  (7, 27, "مبعث", true),
  (8, 15, "نیمه‌ی شعبان", true),
  (9, 21, "شهادت امام علی", true),
  (10, 1, "عید فطر", true),
  (10, 2, "تعطیل به مناسبت عید فطر", true),
  (10, 25, "شهادت امام جعفر صادق", true),
  (12, 10, "عید قربان", true),
  (12, 18, "عید غدیر", true),
];

String _keyOf(DateTime d) {
  final m = d.month.toString().padLeft(2, "0");
  final day = d.day.toString().padLeft(2, "0");
  return "${d.year}-$m-$day";
}

DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

final Map<int, List<Occasion>> _cache = {};

/// همه‌ی مناسبت‌های یک سال شمسی، مرتب؛ در یک روز مشترک تعطیل اول است.
List<Occasion> occasionsOf(int jy) {
  final hit = _cache[jy];
  if (hit != null) return hit;
  final first = toGregorian(jy, 1, 1);
  final last = toGregorian(jy, 12, jalaliMonthLength(jy, 12));
  bool inYear(DateTime d) => !d.isBefore(first) && !d.isAfter(last);
  final out = <Occasion>[];

  void push(DateTime date, String title, bool holiday, bool solar, bool approximate, {HijriDate? hijri}) {
    out.add(Occasion(key: _keyOf(date), date: date, title: title, holiday: holiday, solar: solar, approximate: approximate, hijri: hijri));
  }

  for (final (jm, jd, title, holiday) in _solar) {
    push(toGregorian(jy, jm, jd), title, holiday, true, false);
  }

  // چهارشنبه‌سوری: شب پیش از آخرین چهارشنبه‌ی سال.
  var wed = last;
  while (jalaliWeekday(wed) != 4) {
    wed = _addDays(wed, -1);
  }
  push(_addDays(wed, -1), "چهارشنبه‌سوری", false, true, false);

  final hyFirst = toHijri(first).hy;
  final hyLast = toHijri(last).hy;
  for (var hy = hyFirst; hy <= hyLast; hy++) {
    for (final (hm, rule, title, holiday) in _lunar) {
      final hd = rule == "last" ? hijriMonthLength(hy, hm) : rule as int;
      final conv = fromHijri(hy, hm, hd);
      if (!inYear(conv.date)) continue;
      final exact = !conv.approximate && !toHijri(conv.date).approximate;
      push(conv.date, title, holiday, false, !exact, hijri: HijriDate(hy, hm, hd, approximate: !exact));
    }
  }

  out.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return (b.holiday ? 1 : 0) - (a.holiday ? 1 : 0);
  });
  _cache[jy] = out;
  return out;
}

final Map<int, Map<String, List<Occasion>>> _byKey = {};

Map<String, List<Occasion>> _index(int jy) {
  return _byKey.putIfAbsent(jy, () {
    final map = <String, List<Occasion>>{};
    for (final o in occasionsOf(jy)) {
      map.putIfAbsent(o.key, () => []).add(o);
    }
    return map;
  });
}

/// مناسبت‌های یک روز میلادی «YYYY-MM-DD»؛ خالی اگر مناسبتی نباشد.
List<Occasion> occasionsOfKey(String key) {
  final jy = toJalali(DateTime.parse(key)).jy;
  return _index(jy)[key] ?? const [];
}

/// Provider پیش‌فرض: مناسبت‌های رسمی ایران.
List<Occasion> iranOccasions(String key) => occasionsOfKey(key);
