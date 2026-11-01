import 'package:flutter/material.dart';

import '../iran_divisions.dart';
import '../theme.dart';
import 'combobox.dart';

/// مقدار آدرس: استان و شهر.
class VibeAddressValue {
  final String province;
  final String city;

  const VibeAddressValue({this.province = '', this.city = ''});

  static const VibeAddressValue empty = VibeAddressValue();

  bool get isComplete => province.isNotEmpty && city.isNotEmpty;

  @override
  bool operator ==(Object other) => other is VibeAddressValue && other.province == province && other.city == city;

  @override
  int get hashCode => Object.hash(province, city);
}

/// استان و شهر — پورت `registry/ui/address-picker.tsx`.
///
/// دو کمبوباکس درهم‌پیوسته روی هر ۳۱ استان؛ فهرست شهرها دنبال استان می‌رود،
/// تغییر استان شهر را خالی می‌کند و هر دو فیلد فقط نام‌های فهرست را می‌پذیرند.
///
/// ```dart
/// VibeAddressPicker(
///   value: _address,
///   onChanged: (v, complete) => setState(() => _address = v),
/// )
/// ```
class VibeAddressPicker extends StatefulWidget {
  const VibeAddressPicker({
    super.key,
    this.value,
    this.initialValue = VibeAddressValue.empty,
    this.onChanged,
    this.provinces,
    this.provinceLabel,
    this.cityLabel,
    this.showInvalid = false,
    this.disabled = false,
    this.stack = false,
  });

  /// مقدار کنترل‌شده.
  final VibeAddressValue? value;
  final VibeAddressValue initialValue;

  /// مقدار و کامل‌بودن جفت (استان + شهرِ همان استان).
  final void Function(VibeAddressValue value, bool complete)? onChanged;

  /// محدود به استان‌های خدمت‌رسانی، مثل ["تهران", "البرز"].
  final List<String>? provinces;
  final String? provinceLabel;
  final String? cityLabel;

  /// نمایش خطای «الزامی» زیر فیلد خالی (بعد از submit بدهید true).
  final bool showInvalid;
  final bool disabled;

  /// چیدمان ستونی همیشه؛ پیش‌فرض کنار هم.
  final bool stack;

  @override
  State<VibeAddressPicker> createState() => _VibeAddressPickerState();
}

class _VibeAddressPickerState extends State<VibeAddressPicker> {
  VibeAddressValue _internal = VibeAddressValue.empty;

  VibeAddressValue get _current => widget.value ?? _internal;

  void _set(VibeAddressValue next) {
    setState(() => _internal = next);
    widget.onChanged?.call(next, next.province.isNotEmpty && citiesOf(next.province).contains(next.city));
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final provinceOptions = widget.provinces == null
        ? provinceNames
        : provinces.where((p) => widget.provinces!.contains(p.name)).map((p) => p.name).toList();
    final cityOptions = citiesOf(current.province);

    final provinceMissing = widget.showInvalid && current.province.isEmpty;
    final cityMissing = widget.showInvalid && current.province.isNotEmpty && current.city.isEmpty;

    final provinceField = _field(
      label: widget.provinceLabel ?? "استان",
      child: VibeCombobox(
        strict: true,
        enabled: !widget.disabled,
        options: provinceOptions,
        value: current.province,
        onChanged: (province) {
          if (province != current.province) _set(VibeAddressValue(province: province, city: ""));
        },
        placeholder: "انتخاب استان",
        emptyText: "استانی با این اسم نیست",
      ),
      error: provinceMissing ? "استان را انتخاب کنید." : null,
    );

    final cityField = _field(
      label: widget.cityLabel ?? "شهر",
      child: VibeCombobox(
        strict: true,
        enabled: !widget.disabled && current.province.isNotEmpty,
        options: cityOptions,
        value: current.city,
        onChanged: (city) => _set(VibeAddressValue(province: current.province, city: city)),
        placeholder: current.province.isNotEmpty ? "شهرهای ${current.province}" : "اول استان را انتخاب کنید",
        emptyText: "این شهر در فهرست نیست",
      ),
      error: cityMissing ? "شهر را انتخاب کنید." : null,
    );

    if (widget.stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          provinceField,
          const SizedBox(height: 16),
          cityField,
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(width: 260, child: provinceField),
        SizedBox(width: 260, child: cityField),
      ],
    );
  }

  Widget _field({required String label, required Widget child, required String? error}) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.foreground.withValues(alpha: 0.9))),
        const SizedBox(height: 6),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error, style: TextStyle(fontSize: 12, color: t.destructive)),
          ),
      ],
    );
  }
}
