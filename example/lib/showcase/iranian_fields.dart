import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// فیلدهای ایرانی: شبا، کد ملی، کارت، پلاک، کد پستی، استان/شهر.
class IranianFieldsShowcase extends StatefulWidget {
  const IranianFieldsShowcase({super.key});

  @override
  State<IranianFieldsShowcase> createState() => _IranianFieldsShowcaseState();
}

class _IranianFieldsShowcaseState extends State<IranianFieldsShowcase> {
  VibeAddressValue _address = const VibeAddressValue();
  PlateValue _plate = PlateValue.empty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "شماره‌ی شبا",
          child: VibeIbanInput(onChanged: (iban, valid) {}),
        ),
        ShowSection(
          title: "کد ملی",
          child: VibeNationalIdInput(onChanged: (digits, valid) {}),
        ),
        ShowSection(
          title: "شماره‌ی کارت",
          child: VibeCardNumberInput(onChanged: (digits, valid, bank) {}),
        ),
        ShowSection(
          title: "پلاک خودرو",
          child: VibePlateInput(
            value: _plate,
            onChanged: (plate, complete) => setState(() => _plate = plate),
          ),
        ),
        ShowSection(
          title: "کد پستی",
          child: VibePostalCodeInput(onChanged: (digits, valid) {}),
        ),
        ShowSection(
          title: "استان و شهر",
          child: VibeAddressPicker(
            value: _address,
            onChanged: (v, complete) => setState(() => _address = v),
          ),
        ),
      ],
    );
  }
}
