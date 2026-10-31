/// ابزارهای فارسی — پورت دقیق `lib/utils.ts` رجیستری وایب‌فارسی.
///
/// اعداد فارسی، جداکننده‌ی هزارگان، تومان، درصد و حجم فایل؛ بدون هیچ وابستگی.
library;

const List<String> _faDigits = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"];

/// ارقام لاتینِ یک رشته یا عدد را به فارسی تبدیل می‌کند: `1405 -> ۱۴۰۵`.
String fa(Object value) {
  var out = value.toString();
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(i.toString(), _faDigits[i]);
  }
  return out;
}

/// ارقام فارسی و عربی را به لاتین برمی‌گرداند (برای پارس ورودی کاربر).
String en(Object value) {
  var out = value.toString();
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(_faDigits[i], i.toString());
    // ارقام عربی ٠ (U+0660) تا ٩ (U+0669)
    out = out.replaceAll(String.fromCharCode(0x0660 + i), i.toString());
  }
  return out;
}

/// عدد با جداکننده‌ی هزارگان فارسی: `12450000 -> ۱۲٬۴۵۰٬۰۰۰`.
String faNumber(num value) {
  final rounded = value.round();
  final grouped = rounded.toString().replaceAllMapped(
        RegExp(r"\B(?=(\d{3})+(?!\d))"),
        (m) => ",",
      );
  return fa(grouped).replaceAll(",", "٬");
}

/// مبلغ به تومان با واحد: `12450000 -> ۱۲٬۴۵۰٬۰۰۰ تومان`.
String formatToman(num value) => "${faNumber(value)} تومان";

/// درصد با رقم فارسی و علامت درصد فارسی: `18 -> ۱۸٪`.
String faPercent(num value, {int digits = 0}) =>
    "${fa(value.toStringAsFixed(digits)).replaceAll(".", "٫")}٪";

/// حجم فایل به فارسی: `1258291 -> ۱٫۲ مگابایت`.
String faFileSize(num bytes) {
  if (bytes < 1024) return "${fa(bytes)} بایت";
  if (bytes < 1024 * 1024) return "${fa((bytes / 1024).round())} کیلوبایت";
  return "${fa((bytes / (1024 * 1024)).toStringAsFixed(1)).replaceAll(".", "٫")} مگابایت";
}

/// PRNG قطعی؛ seed یکسان → دنباله‌ی یکسان. خروجی تابعی است که عددی در [0, 1) می‌دهد.
/// برای شاتر تصادفی اما پایدار در نمودارها و دموها. پورت mulberry32 — دقیقاً
/// هم‌ارزش پیاده‌سازی جاوااسکریپت (عملگرهای بیتی در جاوااسکریپت ۳۲بیتی‌اند).
double Function() mulberry32(int seed) {
  var a = seed;
  return () {
    a = _i32(a + 0x6D2B79F5);
    var t = _imul32(a ^ (_u32(a) >> 15), 1 | a);
    t = _i32(t + _imul32(t ^ (_u32(t) >> 7), 61 | t)) ^ t;
    return _u32(t ^ (_u32(t) >> 14)) / 4294967296;
  };
}

int _u32(int x) => x & 0xFFFFFFFF;

int _i32(int x) {
  final u = _u32(x);
  return u >= 0x80000000 ? u - 0x100000000 : u;
}

/// ضرب ماژولار ۳۲بیتی، هم‌ارزد Math.imul جاوااسکریپت.
int _imul32(int a, int b) {
  final ah = _u32(a) >> 16;
  final al = _u32(a) & 0xFFFF;
  final bh = _u32(b) >> 16;
  final bl = _u32(b) & 0xFFFF;
  final high = ah * bl + al * bh;
  final low = al * bl;
  return _i32((high << 16) + low);
}
