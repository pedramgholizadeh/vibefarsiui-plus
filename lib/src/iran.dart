/// اعتبارسنجی و قالب‌بندی ایرانی — پورت دقیق `lib/persian.ts` رجیستری وایب‌فارسی.
///
/// موبایل، شبا (IBAN)، کد ملی، شماره کارت (با BIN → بانک)، پلاک خودرو و کد پستی.
/// بدون وابستگی؛ ورودی با رقم فارسی یا لاتین پذیرفته می‌شود.
library;

import 'persian.dart';

/* ---------- موبایل ---------- */

/// «۰۹۱۲…»، «+98912…» و «0098912…» را به شکل ۱۰ رقمی «912…» نرمال می‌کند.
String normalizeIranMobile(String input) {
  var d = en(input).replaceAll(RegExp(r"\D"), "");
  if (d.startsWith("0098")) {
    d = d.substring(4);
  } else if (d.startsWith("98") && d.length > 10) {
    d = d.substring(2);
  }
  if (d.startsWith("0")) d = d.substring(1);
  return d.length > 10 ? d.substring(0, 10) : d;
}

bool isIranMobile(String input) => RegExp(r"^9\d{9}$").hasMatch(normalizeIranMobile(input));

/// «912 345 6789» — سه گروه، همیشه چپ‌چین.
String formatIranMobile(String input) {
  final d = normalizeIranMobile(input);
  return [d.substring(0, d.length > 3 ? 3 : d.length), ..._groups3(d)]
      .where((g) => g.isNotEmpty)
      .join(" ");
}

List<String> _groups3(String d) {
  if (d.length <= 3) return const [];
  final second = d.length > 6 ? d.substring(3, 6) : d.substring(3);
  final third = d.length > 6 ? d.substring(6) : "";
  return [second, third];
}

final List<(RegExp, String)> _operators = [
  (RegExp(r"^(91\d|99[0-6])"), "همراه اول"),
  (RegExp(r"^(93[0-9]|90[1-5])"), "ایرانسل"),
  (RegExp(r"^92[0-2]"), "رایتل"),
  (RegExp(r"^998"), "شاتل موبایل"),
  (RegExp(r"^999"), "سامانتل"),
];

/// اپراتور شماره موبایل، یا null.
String? mobileOperator(String input) {
  final d = normalizeIranMobile(input);
  if (d.length < 3) return null;
  for (final (RegExp pattern, String name) in _operators) {
    if (pattern.hasMatch(d)) return name;
  }
  return null;
}

/* ---------- شبا / IBAN ---------- */

/// «IR» + حداکثر ۲۴ رقم، با رقم‌های نرمال‌شده.
String normalizeIban(String input) {
  final raw = en(input).toUpperCase().replaceAll(RegExp(r"[^0-9A-Z]"), "");
  final digits = raw.replaceFirst(RegExp(r"^IR"), "").replaceAll(RegExp(r"\D"), "");
  return "IR${digits.length > 24 ? digits.substring(0, 24) : digits}";
}

/// بررسی mod-97 شبای ایرانی (IR + ۲۴ رقم).
bool isIban(String input) {
  final iban = normalizeIban(input);
  if (!RegExp(r"^IR\d{24}$").hasMatch(iban)) return false;
  final rearranged = "${iban.substring(4)}1827${iban.substring(2, 4)}"; // I=18, R=27
  var rem = 0;
  for (final ch in rearranged.codeUnits) {
    rem = (rem * 10 + (ch - 0x30)) % 97;
  }
  return rem == 1;
}

/// «IR12 0170 0000 0010 2345 6789 01».
String formatIban(String input) {
  final iban = normalizeIban(input);
  final groups = <String>[];
  for (var i = 0; i < iban.length; i += 4) {
    groups.add(iban.substring(i, i + 4 > iban.length ? iban.length : i + 4));
  }
  return groups.join(" ");
}

const Map<String, String> _banks = {
  "010": "بانک مرکزی", "011": "صنعت و معدن", "012": "ملت", "013": "رفاه کارگران", "014": "مسکن", "015": "سپه",
  "016": "کشاورزی", "017": "ملی", "018": "تجارت", "019": "صادرات", "020": "توسعه صادرات", "021": "پست بانک",
  "022": "توسعه تعاون", "051": "مؤسسه توسعه", "053": "کارآفرین", "054": "پارسیان", "055": "اقتصاد نوین",
  "056": "سامان", "057": "پاسارگاد", "058": "سرمایه", "059": "سینا", "060": "قرض‌الحسنه مهر ایران", "061": "شهر",
  "062": "آینده", "064": "گردشگری", "066": "دی", "069": "ایران زمین", "070": "رسالت", "078": "خاورمیانه",
  "079": "مؤسسه ملل",
};

/// نام بانک از کد سه‌رقمی داخل شبا، یا null.
String? ibanBank(String input) {
  final iban = normalizeIban(input);
  if (iban.length < 7) return null;
  return _banks[iban.substring(4, 7)];
}

/// «ملت» → «بانک ملت»؛ نام‌هایی که خودشان بانک/مؤسسه دارند دست نمی‌خورند.
String bankLabel(String name) =>
    RegExp("بانک|مؤسسه").hasMatch(name) ? name : "بانک $name";

/* ---------- کد ملی ---------- */

/// فقط رقم (فارسی هم پذیرفته)، حداکثر ۱۰ رقم. رشته می‌ماند چون ممکن است با صفر شروع شود.
String normalizeNationalId(String input) {
  final d = en(input).replaceAll(RegExp(r"\D"), "");
  return d.length > 10 ? d.substring(0, 10) : d;
}

/// «۰۰۱-۲۳۴۵۶۷-۸» — گروه‌بندی ۳-۶-۱ روی کارت.
String formatNationalId(String input) {
  final d = normalizeNationalId(input);
  final groups = [
    d.substring(0, d.length > 3 ? 3 : d.length),
    if (d.length > 3) d.substring(3, d.length > 9 ? 9 : d.length),
    if (d.length > 9) d.substring(9),
  ].where((g) => g.isNotEmpty);
  return fa(groups.join("-"));
}

/// اعتبار کد ملی ۱۰ رقمی با رقم کنترل وزنی.
bool isNationalId(String input) {
  final d = en(input).replaceAll(RegExp(r"\D"), "");
  if (!RegExp(r"^\d{10}$").hasMatch(d)) return false;
  if (RegExp(r"^(\d)\1{9}$").hasMatch(d)) return false;
  final check = int.parse(d[9]);
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(d[i]) * (10 - i);
  }
  final r = sum % 11;
  return r < 2 ? check == r : check == 11 - r;
}

/* ---------- کارت بانکی ---------- */

/// حداکثر ۱۶ رقم لاتین؛ رقم فارسی، فاصله و خط تیره حذف می‌شود.
String normalizeCardNumber(String input) {
  final d = en(input).replaceAll(RegExp(r"\D"), "");
  return d.length > 16 ? d.substring(0, 16) : d;
}

/// «۶۰۳۷ ۹۹۱۱ ۲۲۳۳ ۴۴۵۵» — رقم فارسی، چهار گروه.
String formatCardNumber(String input) {
  final d = normalizeCardNumber(input);
  final groups = <String>[];
  for (var i = 0; i < d.length; i += 4) {
    groups.add(d.substring(i, i + 4 > d.length ? d.length : i + 4));
  }
  return fa(groups.join(" "));
}

/// شش رقم اول (BIN / پیش‌شماره) کارت‌های بانکی ایران. بانک‌های ادغام‌شده زیر سپه می‌آیند.
const Map<String, String> cardBins = {
  "603799": "ملی", "589210": "سپه", "627381": "سپه", "639599": "سپه", "636949": "سپه", "639370": "سپه", "505801": "سپه",
  "627648": "توسعه صادرات", "207177": "توسعه صادرات", "627961": "صنعت و معدن", "603770": "کشاورزی", "639217": "کشاورزی",
  "628023": "مسکن", "627760": "پست بانک", "502908": "توسعه تعاون", "627412": "اقتصاد نوین", "622106": "پارسیان",
  "639194": "پارسیان", "627884": "پارسیان", "502229": "پاسارگاد", "639347": "پاسارگاد", "627488": "کارآفرین",
  "502910": "کارآفرین", "621986": "سامان", "639346": "سینا", "639607": "سرمایه", "636214": "آینده", "502806": "شهر",
  "504706": "شهر", "502938": "دی", "603769": "صادرات", "610433": "ملت", "991975": "ملت", "627353": "تجارت",
  "585983": "تجارت", "589463": "رفاه کارگران", "504172": "رسالت", "606373": "قرض‌الحسنه مهر ایران",
  "628157": "مؤسسه توسعه", "505785": "ایران زمین", "505416": "گردشگری", "606256": "مؤسسه ملل", "585947": "خاورمیانه",
  "581874": "ایران‌ونزوئلا", "636795": "بانک مرکزی", "507677": "مؤسسه نور",
};

/// نام بانک از شش رقم اول کارت؛ تا پیش از تایپ شش رقم null.
String? cardBank(String input) {
  final d = normalizeCardNumber(input);
  if (d.length < 6) return null;
  return cardBins[d.substring(0, 6)];
}

/// الگوریتم Luhn برای کارت ۱۶ رقمی.
bool isCardNumber(String input) {
  final d = normalizeCardNumber(input);
  if (d.length != 16) return false;
  var sum = 0;
  for (var i = 0; i < 16; i++) {
    var n = int.parse(d[i]);
    if (i % 2 == 0) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
  }
  return sum % 10 == 0;
}

/* ---------- پلاک خودرو ---------- */

/// چهار بخش پلاک ایران: دو رقم، حرف، سه رقم، دو رقم.
class PlateValue {
  final String left;
  final String letter;
  final String middle;
  final String region;

  const PlateValue({this.left = "", this.letter = "", this.middle = "", this.region = ""});

  static const PlateValue empty = PlateValue();

  bool get isEmpty => left.isEmpty && letter.isEmpty && middle.isEmpty && region.isEmpty;

  @override
  String toString() => stringifyPlate(this);

  @override
  bool operator ==(Object other) =>
      other is PlateValue && other.left == left && other.letter == letter && other.middle == middle && other.region == region;

  @override
  int get hashCode => Object.hash(left, letter, middle, region);
}

/// حرف‌های پلاک ایران و معنایشان؛ «شخصی» اول، بقیه کلاس خودرو.
const List<({String letter, String label})> plateLetters = [
  (letter: "ب", label: "شخصی"), (letter: "ج", label: "شخصی"), (letter: "د", label: "شخصی"),
  (letter: "س", label: "شخصی"), (letter: "ص", label: "شخصی"), (letter: "ط", label: "شخصی"),
  (letter: "ق", label: "شخصی"), (letter: "ل", label: "شخصی"), (letter: "م", label: "شخصی"),
  (letter: "ن", label: "شخصی"), (letter: "و", label: "شخصی"), (letter: "ه", label: "شخصی"),
  (letter: "ی", label: "شخصی"),
  (letter: "الف", label: "دولتی"), (letter: "ت", label: "تاکسی"), (letter: "ع", label: "حمل‌ونقل عمومی"),
  (letter: "ک", label: "کشاورزی"), (letter: "ژ", label: "جانبازان و معلولان"), (letter: "پ", label: "نیروی انتظامی"),
  (letter: "ث", label: "ارتش"), (letter: "ز", label: "وزارت دفاع"), (letter: "ش", label: "سپاه"),
  (letter: "ف", label: "ستاد کل نیروهای مسلح"), (letter: "گ", label: "گذر موقت"),
  (letter: "D", label: "دیپلماتیک"), (letter: "S", label: "کارکنان سفارت"),
];

final Set<String> _plateLetterSet = plateLetters.map((l) => l.letter).toSet();

/// کلید تایپ‌شده را به حرف پلاک مپ می‌کند: ي/ك عربی → ی/ک، «ا» → «الف»، d/s → D/S.
/// اگر حرف پلاک نباشد null.
String? plateLetterFromKey(String key) {
  var k = key.replaceAll("ي", "ی").replaceAll("ك", "ک");
  if (k == "ا") k = "الف";
  if (_plateLetterSet.contains(k)) return k;
  final up = k.toUpperCase();
  if (_plateLetterSet.contains(up)) return up;
  return null;
}

/// هر چهار بخش پر باشد: ۲ رقم، حرف شناخته‌شده، ۳ رقم، ۲ رقم.
bool isPlate(PlateValue value) =>
    RegExp(r"^\d{2}$").hasMatch(value.left) &&
    _plateLetterSet.contains(value.letter) &&
    RegExp(r"^\d{3}$").hasMatch(value.middle) &&
    RegExp(r"^\d{2}$").hasMatch(value.region);

/// شکل ذخیره‌ی «12ب345-11» (رقم لاتین). بخش‌های خالی، خالی می‌مانند.
String stringifyPlate(PlateValue value) =>
    "${value.left}${value.letter}${value.middle}${value.region.isEmpty ? "" : "-${value.region}"}";

/// «۱۲ ب ۳۴۵ ایران ۱۱»، «12ب345-11» یا «۱۲ ب ۳۴۵ ایران ۱۱» را پارس می‌کند؛ بخش‌های نبوده خالی‌اند.
PlateValue parsePlate(String input) {
  final s = en(input).replaceAll("ایران", " ").replaceAll(RegExp(r"[\s\-_/]+"), "");
  final m = RegExp(r"^(\d{0,2})(الف|[^\d]?)(\d{0,3})(\d{0,2})$").firstMatch(s);
  if (m == null) return PlateValue.empty;
  final letter = m.group(2)!.isNotEmpty ? (plateLetterFromKey(m.group(2)!) ?? "") : "";
  return PlateValue(left: m.group(1)!, letter: letter, middle: m.group(3)!, region: m.group(4)!);
}

/// شکل نمایشی «۱۲ ب ۳۴۵ ایران ۱۱».
String formatPlate(PlateValue value) {
  if (value.isEmpty) return "";
  return "${fa(value.left)} ${value.letter} ${fa(value.middle)} ایران ${fa(value.region)}"
      .replaceAll(RegExp(r"\s+"), " ")
      .trim();
}

/* ---------- کد پستی ---------- */

/// حداکثر ۱۰ رقم لاتین از «۸۱۶۳۸-۴۷۳۵۱» یا خط آدرس چسبانده‌شده.
String normalizePostalCode(String input) {
  final d = en(input).replaceAll(RegExp(r"\D"), "");
  return d.length > 10 ? d.substring(0, 10) : d;
}

/// «۸۱۶۳۸-۴۷۳۵۱»: دو گروه پنج‌رقمی، مثل روی قبض.
String formatPostalCode(String input) {
  final d = normalizePostalCode(input);
  return fa(d.length > 5 ? "${d.substring(0, 5)}-${d.substring(5)}" : d);
}

/// ده رقم که یک رقم تکراری نباشد (مثل ۰۰۰۰۰۰۰۰۰۰). بررسی جمع‌شده‌ای منتشر نمی‌شود.
bool isPostalCode(String input) {
  final d = normalizePostalCode(input);
  return d.length == 10 && !RegExp(r"^(\d)\1{9}$").hasMatch(d);
}

/* ---------- زمان نسبی ---------- */

/// «همین حالا»، «۵ دقیقه پیش»، «۳ ساعت پیش»، «دیروز»، «۴ روز پیش».
String timeAgo(DateTime date, [DateTime? now]) {
  final now_ = now ?? DateTime.now();
  final s = now_.difference(date).inSeconds < 0 ? 0 : now_.difference(date).inSeconds;
  if (s < 60) return "همین حالا";
  final m = (s / 60).round();
  if (m < 60) return "${fa(m)} دقیقه پیش";
  final h = (m / 60).round();
  if (h < 24) return "${fa(h)} ساعت پیش";
  final d = (h / 24).round();
  if (d == 1) return "دیروز";
  if (d < 30) return "${fa(d)} روز پیش";
  final mo = (d / 30).round();
  return mo < 12 ? "${fa(mo)} ماه پیش" : "${fa((mo / 12).round())} سال پیش";
}
