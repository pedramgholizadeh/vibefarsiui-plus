import 'package:flutter_test/flutter_test.dart';
import 'package:vibefarsi/vibefarsi.dart';

void main() {
  group("persian", () {
    test("fa converts Latin digits to Persian", () {
      expect(fa(1405), "۱۴۰۵");
      expect(fa("order-42"), "order-۴۲");
    });

    test("en converts Persian and Arabic-Indic digits to Latin", () {
      expect(en("۱۲a٣"), "12a3");
    });

    test("faNumber groups thousands with Persian separator", () {
      expect(faNumber(12450000), "۱۲٬۴۵۰٬۰۰۰");
    });

    test("formatToman appends the unit", () {
      expect(formatToman(12450000), "۱۲٬۴۵۰٬۰۰۰ تومان");
    });

    test("faPercent uses the Persian percent sign", () {
      expect(faPercent(18), "۱۸٪");
      expect(faPercent(18.44, digits: 1), "۱۸٫۴٪");
    });

    test("faFileSize formats megabytes with Persian decimal separator", () {
      expect(faFileSize(1258291), "۱٫۲ مگابایت");
      expect(faFileSize(512), "۵۱۲ بایت");
    });

    test("mulberry32 matches the JS implementation", () {
      // مقدار مرجع از اجرای مستقیم پیاده‌سازی utils.ts در Node.
      final rand = mulberry32(1);
      expect(rand(), closeTo(0.6270739405881613, 1e-12));
      expect(mulberry32(42)(), closeTo(0.9481023523062766, 1e-12));
    });
  });

  group("jalali", () {
    test("1 Farvardin 1404 is 21 March 2025", () {
      final g = toGregorian(1404, 1, 1);
      expect(g.year, 2025);
      expect(g.month, 3);
      expect(g.day, 21);
    });

    test("round trip for a range of dates", () {
      // UTC تا از ساعت تابستانی ایران (تا ۱۴۰۰) در امان بمانیم؛
      // تاریخ میلادیِ سازنده‌ی محلی فقط در سطح سال/ماه/روز مقایسه می‌شود.
      var d = DateTime.utc(2020, 1, 1);
      while (d.isBefore(DateTime.utc(2030, 1, 1))) {
        final j = toJalali(d);
        final back = toGregorian(j.jy, j.jm, j.jd);
        expect([back.year, back.month, back.day], [d.year, d.month, d.day]);
        d = d.add(const Duration(days: 1));
      }
    });

    test("leap years", () {
      expect(isLeapJalaliYear(1403), isTrue);
      expect(isLeapJalaliYear(1404), isFalse);
      expect(JalaliDate(1403, 12, 1).monthLength, 30);
      expect(JalaliDate(1404, 12, 1).monthLength, 29);
    });

    test("week starts Saturday: 0 = شنبه … 6 = جمعه", () {
      // 21 March 2025 = 1 Farvardin 1404 = جمعه (Friday)
      expect(jalaliWeekday(DateTime(2025, 3, 21)), 6);
      // 22 March 2025 = شنبه
      expect(jalaliWeekday(DateTime(2025, 3, 22)), 0);
      expect(jalaliWeekdays.first, "شنبه");
    });

    test("formatJalali renders Persian date", () {
      final out = formatJalali(DateTime(2025, 3, 21), weekday: true);
      expect(out, "جمعه، ۱ فروردین ۱۴۰۴");
    });
  });

  group("iran", () {
    test("national id checksum", () {
      expect(isNationalId("0012345679"), isTrue); // رقم کنترل ۹ برای ۰۰۱۲۳۴۵۶۷
      expect(isNationalId("0012345678"), isFalse);
      expect(formatNationalId("0012345679"), "۰۰۱-۲۳۴۵۶۷-۹");
    });

    test("mobile normalize, format and operator", () {
      expect(normalizeIranMobile("۰۹۱۲۳۴۵۶۷۸۹"), "9123456789");
      expect(isIranMobile("+989123456789"), isTrue);
      expect(formatIranMobile("9123456789"), "912 345 6789");
      expect(mobileOperator("9120000000"), "همراه اول");
      expect(mobileOperator("9350000000"), "ایرانسل");
    });

    test("card number: Luhn and BIN", () {
      expect(isCardNumber("6104337812345674"), isTrue);
      expect(isCardNumber("6104337812345678"), isFalse);
      expect(cardBank("6037991234567890"), "ملی");
      expect(formatCardNumber("6104337812345674"), "۶۱۰۴ ۳۳۷۸ ۱۲۳۴ ۵۶۷۴");
    });

    test("iban mod-97 and bank", () {
      const iban = "IR820540102680020817909002";
      expect(isIban(iban), isTrue);
      expect(isIban("IR820540102680020817909003"), isFalse);
      expect(ibanBank(iban), "پارسیان"); // کد بانک ۰۵۴
    });

    test("plate parse/format/validate", () {
      final plate = parsePlate("۱۲ ب ۳۴۵ ایران ۱۱");
      expect(plate.left, "12");
      expect(plate.letter, "ب");
      expect(plate.middle, "345");
      expect(plate.region, "11");
      expect(isPlate(plate), isTrue);
      expect(formatPlate(plate), "۱۲ ب ۳۴۵ ایران ۱۱");
    });

    test("postal code", () {
      expect(normalizePostalCode("۸۱۶۳۸-۴۷۳۵۱"), "8163847351");
      expect(formatPostalCode("8163847351"), "۸۱۶۳۸-۴۷۳۵۱");
      expect(isPostalCode("8163847351"), isTrue);
      expect(isPostalCode("1111111111"), isFalse);
    });

    test("relative time", () {
      expect(timeAgo(DateTime.now().subtract(const Duration(minutes: 5))), "۵ دقیقه پیش");
      expect(timeAgo(DateTime.now().subtract(const Duration(days: 1))), "دیروز");
      expect(timeAgo(DateTime.now()), "همین حالا");
    });
  });

  group("iran divisions", () {
    test("31 provinces, sorted, capital first", () {
      expect(provinces.length, 31);
      expect(provinces.first.name, "آذربایجان شرقی");
      expect(citiesOf("تهران").first, "تهران");
      expect(citiesOf("ناموجود"), isEmpty);
      expect(isValidAddress("اصفهان", "کاشان"), isTrue);
    });
  });
}
