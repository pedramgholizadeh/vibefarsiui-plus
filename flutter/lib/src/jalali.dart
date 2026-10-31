/// تقویم شمسی (جلالی) — پورت دقیق `lib/jalali.ts` رجیستری وایب‌فارسی.
///
/// الگوریتم Borkowski (همان jalaali-js). معتبر برای سال‌های ۱ تا ۳۱۷۷ شمسی؛ بدون وابستگی.
library;

import 'persian.dart';

/// یک تاریخ شمسی: سال، ماه (۱–۱۲) و روز (۱–۳۱). ترتیب مقایسه، ترتیب زمانی است.
class JalaliDate implements Comparable<JalaliDate> {
  final int jy;
  final int jm;
  final int jd;

  const JalaliDate(this.jy, this.jm, this.jd);

  /// تاریخ شمسی همین لحظه.
  factory JalaliDate.now() => toJalali(DateTime.now());

  /// تبدیل از DateTime میلادی.
  factory JalaliDate.fromDateTime(DateTime date) => toJalali(date);

  /// تبدیل به DateTime میلادی (نیمه‌شب روز مربوطه).
  DateTime toDateTime() => toGregorian(jy, jm, jd);

  /// روز هفته: ۰ = شنبه … ۶ = جمعه.
  int get weekday => jalaliWeekday(toDateTime());

  /// تعداد روزهای این ماه (۲۹ تا ۳۱).
  int get monthLength => jalaliMonthLength(jy, jm);

  /// نام این ماه: «فروردین» … «اسفند».
  String get monthName => jalaliMonths[jm - 1];

  /// «چهارشنبه، ۲۵ شهریور ۱۴۰۵».
  String format({bool weekday = false, bool year = true}) =>
      formatJalali(toDateTime(), weekday: weekday, year: year);

  /// «۱۴۰۵/۰۶/۲۵».
  String get formatNumeric => formatJalaliNumeric(toDateTime());

  /// تاریخ `days` روز بعد (یا قبل، با عدد منفی).
  JalaliDate addDays(int days) => toJalali(toDateTime().add(Duration(days: days)));

  /// تاریخ اولین روز (شنبه) هفته‌ی این تاریخ.
  JalaliDate startOfWeek() => addDays(-weekday);

  @override
  String toString() => "$jy/$jm/$jd";

  @override
  bool operator ==(Object other) => other is JalaliDate && other.jy == jy && other.jm == jm && other.jd == jd;

  @override
  int get hashCode => Object.hash(jy, jm, jd);

  @override
  int compareTo(JalaliDate other) {
    if (jy != other.jy) return jy.compareTo(other.jy);
    if (jm != other.jm) return jm.compareTo(other.jm);
    return jd.compareTo(other.jd);
  }
}

int _div(int a, int b) => a ~/ b;
int _mod(int a, int b) => a - (a ~/ b) * b;

const List<int> _breaks = [
  -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
];

class _JalCal {
  final int leap;
  final int gy;
  final int march;
  const _JalCal(this.leap, this.gy, this.march);
}

_JalCal _jalCal(int jy) {
  final bl = _breaks.length;
  final gy = jy + 621;
  var leapJ = -14;
  var jp = _breaks[0];
  if (jy < jp || jy >= _breaks[bl - 1]) {
    throw RangeError("سال شمسی نامعتبر: $jy");
  }
  var jump = 0;
  for (var i = 1; i < bl; i += 1) {
    final jm = _breaks[i];
    jump = jm - jp;
    if (jy < jm) break;
    leapJ = leapJ + _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
    jp = jm;
  }
  var n = jy - jp;
  leapJ = leapJ + _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
  if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
  final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
  final march = 20 + leapJ - leapG;
  if (jump - n < 6) n = n - jump + _div(jump + 4, 33) * 33;
  var leap = _mod(_mod(n + 1, 33) - 1, 4);
  if (leap == -1) leap = 4;
  return _JalCal(leap, gy, march);
}

int _g2d(int gy, int gm, int gd) {
  var d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
      _div(153 * _mod(gm + 9, 12) + 2, 5) +
      gd -
      34840408;
  d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
  return d;
}

class _Greg {
  final int gy;
  final int gm;
  final int gd;
  const _Greg(this.gy, this.gm, this.gd);
}

_Greg _d2g(int jdn) {
  var j = 4 * jdn + 139361631;
  j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
  final i = _div(_mod(j, 1461), 4) * 5 + 308;
  final gd = _div(_mod(i, 153), 5) + 1;
  final gm = _mod(_div(i, 153), 12) + 1;
  final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
  return _Greg(gy, gm, gd);
}

int _j2d(int jy, int jm, int jd) {
  final r = _jalCal(jy);
  return _g2d(r.gy, 3, r.march) + (jm - 1) * 31 - _div(jm, 7) * (jm - 7) + jd - 1;
}

JalaliDate _d2j(int jdn) {
  final gy = _d2g(jdn).gy;
  var jy = gy - 621;
  final r = _jalCal(jy);
  final jdn1f = _g2d(gy, 3, r.march);
  var k = jdn - jdn1f;
  if (k >= 0) {
    if (k <= 185) return JalaliDate(jy, 1 + _div(k, 31), _mod(k, 31) + 1);
    k -= 186;
  } else {
    jy -= 1;
    k += 179;
    if (r.leap == 1) k += 1;
  }
  return JalaliDate(jy, 7 + _div(k, 30), _mod(k, 30) + 1);
}

/// تبدیل DateTime میلادی به تاریخ شمسی.
JalaliDate toJalali(DateTime date) => _d2j(_g2d(date.year, date.month, date.day));

/// تبدیل تاریخ شمسی به DateTime میلادی (نیمه‌شب).
DateTime toGregorian(int jy, int jm, int jd) {
  final g = _d2g(_j2d(jy, jm, jd));
  return DateTime(g.gy, g.gm, g.gd);
}

/// سال کبیسه شمسی؟
bool isLeapJalaliYear(int jy) => _jalCal(jy).leap == 0;

/// تعداد روزهای ماه شمسی.
int jalaliMonthLength(int jy, int jm) {
  if (jm <= 6) return 31;
  if (jm <= 11) return 30;
  return isLeapJalaliYear(jy) ? 30 : 29;
}

/// نام ماه‌های شمسی، از فروردین تا اسفند.
const List<String> jalaliMonths = [
  "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
  "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند",
];

/// نام روزهای هفته از شنبه: شنبه، یکشنبه، …، جمعه.
const List<String> jalaliWeekdays = ["شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه"];

/// حرف اول روزهای هفته از شنبه.
const List<String> jalaliWeekdaysShort = ["ش", "ی", "د", "س", "چ", "پ", "ج"];

/// روز هفته از دید تقویم شمسی: ۰ = شنبه … ۶ = جمعه.
int jalaliWeekday(DateTime date) => (date.weekday % 7 + 1) % 7;

/// «چهارشنبه، ۲۵ شهریور ۱۴۰۵».
String formatJalali(DateTime date, {bool weekday = false, bool year = true}) {
  final j = toJalali(date);
  var first = "${fa(j.jd)} ${jalaliMonths[j.jm - 1]}";
  if (year) first += " ${fa(j.jy)}";
  return (weekday ? "${jalaliWeekdays[jalaliWeekday(date)]}، " : "") + first;
}

/// شکل عددی «۱۴۰۵/۰۶/۲۵».
String formatJalaliNumeric(DateTime date) {
  final j = toJalali(date);
  return fa("${j.jy}/${j.jm.toString().padLeft(2, "0")}/${j.jd.toString().padLeft(2, "0")}");
}
