/// تاریخ هجری قمری به‌روایت ایران — پورت `lib/hijri.ts`.
///
/// ایران هر ماه قمری را با رؤیت هلال شروع می‌کند؛ شروع ماه‌های جدول
/// [iranHijriMonthStarts] از تقویم رسمی است و بیرون جدول الگوریتم tabular
/// با `approximate: true` استفاده می‌شود (ممکن است یک روز خطا داشته باشد).
library;

import 'jalali.dart';
import 'persian.dart';

/// یک تاریخ هجری قمری.
class HijriDate {
  final int hy;
  final int hm;
  final int hd;

  /// بیرون از جدول رسمی؛ ممکن است یک روز خطا داشته باشد.
  final bool approximate;

  const HijriDate(this.hy, this.hm, this.hd, {this.approximate = false});

  @override
  String toString() => "$hd/$hm/$hy";
}

/// نام ماه‌های قمری، محرم تا ذی‌الحجه.
const List<String> hijriMonths = [
  "محرم", "صفر", "ربیع‌الاول", "ربیع‌الثانی", "جمادی‌الاول", "جمادی‌الثانی",
  "رجب", "شعبان", "رمضان", "شوال", "ذی‌القعده", "ذی‌الحجه",
];

/// شروع هر ماه قمری به‌عنوان تاریخ شمسی [jy, jm, jd] طبق تقویم رسمی ایران.
/// با آمدن تقویم رسمی سال جدید، این جدول را گسترش دهید.
const Map<String, List<int>> iranHijriMonthStarts = {
  "1446-09": [1403, 12, 12],
  "1446-10": [1404, 1, 11],
  "1446-11": [1404, 2, 9],
  "1446-12": [1404, 3, 7],
  "1447-01": [1404, 4, 6],
  "1447-02": [1404, 5, 4],
  "1447-03": [1404, 6, 3],
  "1447-04": [1404, 7, 2],
  "1447-05": [1404, 8, 1],
  "1447-06": [1404, 9, 1],
  "1447-07": [1404, 10, 1],
  "1447-08": [1404, 11, 1],
  "1447-09": [1404, 11, 30],
  "1447-10": [1405, 1, 1],
  "1447-11": [1405, 1, 30],
  "1447-12": [1405, 2, 28],
  "1448-01": [1405, 3, 26],
  "1448-02": [1405, 4, 25],
  "1448-03": [1405, 5, 23],
  "1448-04": [1405, 6, 22],
  "1448-05": [1405, 7, 20],
  "1448-06": [1405, 8, 20],
  "1448-07": [1405, 9, 20],
  "1448-08": [1405, 10, 20],
  "1448-09": [1405, 11, 19],
  "1448-10": [1405, 12, 19],
};

const int _dayMs = 86400000;

/// تعداد روز کامل از 1970-01-01 برای روز تقویمی محلی [date].
int _dayNumber(DateTime date) =>
    (DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/ _dayMs);

DateTime _fromDayNumber(int n) {
  final u = DateTime.fromMillisecondsSinceEpoch(n * _dayMs, isUtc: true);
  return DateTime(u.year, u.month, u.day);
}

/* ---------- قمری tabular (راهنما) ---------- */

/// روز شماره‌ی ۱ محرم سال ۱ قمری در شمارش tabular.
const int _epoch = 1948440 - 2440588;

int _tabularToDay(int hy, int hm, int hd) =>
    _epoch + hd - 1 + (29.5 * (hm - 1)).ceil() + (hy - 1) * 354 + (3 + 11 * hy) ~/ 30;

({int hy, int hm, int hd}) _tabularFromDay(int n) {
  final hy = (30 * (n - _epoch) + 10646) ~/ 10631;
  final hm = ((n - 29 - _tabularToDay(hy, 1, 1)) / 29.5).ceil() + 1;
  final hmCapped = hm > 12 ? 12 : hm;
  final hd = n - _tabularToDay(hy, hmCapped, 1) + 1;
  return (hy: hy, hm: hmCapped, hd: hd);
}

/* ---------- جدول رسمی ---------- */

class _Start {
  final int hy;
  final int hm;
  final int day;
  const _Start(this.hy, this.hm, this.day);
}

final List<_Start> _starts = iranHijriMonthStarts.entries.map((e) {
  final parts = e.key.split("-");
  return _Start(int.parse(parts[0]), int.parse(parts[1]), _dayNumber(toGregorian(e.value[0], e.value[1], e.value[2])));
}).toList()
  ..sort((a, b) => a.day.compareTo(b.day));

int _startIndex(int hy, int hm) {
  for (var i = 0; i < _starts.length; i++) {
    if (_starts[i].hy == hy && _starts[i].hm == hm) return i;
  }
  return -1;
}

/// تاریخ قمری یک روز تقویمی؛ بیرون جدول رسمی approximate است.
HijriDate toHijri(DateTime date) {
  final n = _dayNumber(date);
  for (var i = _starts.length - 1; i >= 0; i--) {
    final s = _starts[i];
    if (n < s.day) continue;
    final hd = n - s.day + 1;
    final end = i + 1 < _starts.length ? _starts[i + 1].day : null;
    if ((end != null && n < end) || (end == null && hd <= 29)) {
      return HijriDate(s.hy, s.hm, hd);
    }
    break;
  }
  final t = _tabularFromDay(n);
  return HijriDate(t.hy, t.hm, t.hd, approximate: true);
}

/// روز تقویمی یک تاریخ قمری.
({DateTime date, bool approximate}) fromHijri(int hy, int hm, int hd) {
  final i = _startIndex(hy, hm);
  if (i >= 0) {
    final known = i + 1 < _starts.length ? _starts[i + 1].day - _starts[i].day : 29;
    return (date: _fromDayNumber(_starts[i].day + hd - 1), approximate: hd > known);
  }
  return (date: _fromDayNumber(_tabularToDay(hy, hm, hd)), approximate: true);
}

/// ۲۹ یا ۳۰؛ وقتی ماه و بعدی هر دو در جدول رسمی‌اند دقیق است.
int hijriMonthLength(int hy, int hm) {
  final i = _startIndex(hy, hm);
  if (i >= 0 && i + 1 < _starts.length) return _starts[i + 1].day - _starts[i].day;
  final ny = hm == 12 ? hy + 1 : hy;
  final nm = hm == 12 ? 1 : hm + 1;
  return _tabularToDay(ny, nm, 1) - _tabularToDay(hy, hm, 1);
}

/// آیا جدول رسمی این روز تقویمی را پوشش می‌دهد؟
bool isHijriVerified(DateTime date) => !toHijri(date).approximate;

/// «۱۸ ربیع‌الثانی ۱۴۴۸»، یا بدون سال.
String formatHijri(DateTime date, {bool year = true}) {
  final h = toHijri(date);
  return "${fa(h.hd)} ${hijriMonths[h.hm - 1]}${year ? " ${fa(h.hy)}" : ""}";
}
