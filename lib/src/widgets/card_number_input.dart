import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../iran.dart';
import '../theme.dart';

/// شماره‌ی کارت بانکی — پورت `registry/ui/card-number-input.tsx`.
///
/// چهار گروه رقم فارسی در چیدمان چپ‌چین، نام بانک از شش رقم اول در حین تایپ
/// و بررسی Luhan فقط وقتی شانزده رقم کامل شود.
///
/// ```dart
/// VibeCardNumberInput(onChanged: (digits, valid, bank) => save(digits, valid, bank))
/// ```
class VibeCardNumberInput extends StatefulWidget {
  const VibeCardNumberInput({super.key, this.value, this.initialValue = '', this.onChanged, this.autofocus = false, this.enabled = true});

  final String? value;
  final String initialValue;

  /// شانزده رقم لاتین، اعتبار Luhn و نام بانک (یا null).
  final void Function(String digits, bool valid, String? bank)? onChanged;
  final bool autofocus;
  final bool enabled;

  @override
  State<VibeCardNumberInput> createState() => _VibeCardNumberInputState();
}

class _VibeCardNumberInputState extends State<VibeCardNumberInput> {
  String _internal = '';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _sync();
  }

  String get _digits => normalizeCardNumber(widget.value ?? _internal);

  void _sync() {
    final text = formatCardNumber(_digits);
    if (text != _controller.text) {
      _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  void _set(String next) {
    final d = normalizeCardNumber(next);
    setState(() => _internal = d);
    _sync();
    widget.onChanged?.call(d, isCardNumber(d), cardBank(d));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final digits = _digits;
    final complete = digits.length == 16;
    final valid = isCardNumber(digits);
    final invalid = complete && !valid;
    final bank = cardBank(digits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: t.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(VibeRadius.field),
                border: Border.all(color: invalid ? t.destructive.withValues(alpha: 0.6) : t.input),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_outlined, size: 16, color: t.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      autofocus: widget.autofocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩ ]"))],
                      onChanged: _set,
                      cursorColor: t.foreground,
                      style: TextStyle(fontSize: 14, color: t.foreground),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: "۰۰۰۰ ۰۰۰۰ ۰۰۰۰ ۰۰۰۰",
                        hintStyle: TextStyle(fontSize: 14, color: Color(0x8089898B)),
                      ),
                    ),
                  ),
                  if (valid) Icon(Icons.check_circle_outline, size: 16, color: t.success),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (!invalid && bank != null) ...[
              Icon(Icons.account_balance_outlined, size: 12, color: t.mutedForeground),
              const SizedBox(width: 4),
            ],
            Text(
              invalid
                  ? "شماره‌ی کارت معتبر نیست"
                  : bank != null
                      ? bankLabel(bank)
                      : digits.length >= 6
                          ? "بانک این کارت شناخته نشد"
                          : "۱۶ رقم روی کارت",
              style: TextStyle(fontSize: 11, color: invalid ? t.destructive : t.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }
}
