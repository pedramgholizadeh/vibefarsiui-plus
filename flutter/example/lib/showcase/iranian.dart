import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// اعتبارسنجی‌های ایرانی: کد ملی، شبا، کارت، موبایل، پلاک، کد پستی.
class IranianShowcase extends StatelessWidget {
  const IranianShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FactList(title: "کد ملی", facts: [
          ("isNationalId(\"0012345678\")", "true"),
          ("formatNationalId(\"0012345678\")", "۰۰۱-۲۳۴۵۶۷-۸"),
        ]),
        const FactList(title: "موبایل", facts: [
          ("isIranMobile(\"+989123456789\")", "true"),
          ("formatIranMobile(\"9123456789\")", "912 345 6789"),
          ("mobileOperator(\"9120000000\")", "همراه اول"),
        ]),
        const FactList(title: "کارت بانکی", facts: [
          ("cardBank(\"6037991234567890\")", "ملی"),
          ("formatCardNumber(\"6104337812345678\")", "۶۱۰۴ ۳۳۷۸ ۱۲۳۴ ۵۶۷۸"),
        ]),
        const FactList(title: "شبا", facts: [
          ("isIban(\"IR820540102680020817909002\")", "true"),
          ("ibanBank(\"IR820540102680020817909002\")", "سامان"),
        ]),
        const FactList(title: "پلاک و کد پستی", facts: [
          ("formatPlate(parsePlate(\"۱۲ ب ۳۴۵ ایران ۱۱\"))", "۱۲ ب ۳۴۵ ایران ۱۱"),
          ("formatPostalCode(\"8163847351\")", "۸۱۶۳۸-۴۷۳۵۱"),
        ]),
        FactList(title: "تقسیمات کشوری", facts: [
          ("provinces.length", fa(provinces.length)),
          ("citiesOf(\"تهران\").length", fa(citiesOf("تهران").length)),
          ("isValidAddress(\"اصفهان\", \"کاشان\")", "true"),
        ]),
      ],
    );
  }
}

