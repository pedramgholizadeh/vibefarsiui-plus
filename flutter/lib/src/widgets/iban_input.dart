import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../iran.dart';
import '../theme.dart';

/// شماره‌ی شبا — پورت `registry/ui/iban-input.tsx`.
///
/// پیشوند «IR» ثابت و چپ‌چین، ارقام چهاررقمی گروه‌بندی‌شده، اعتبارسنجی
/// mod-97 و نام بانک پس از تشخیص.
///
/// ```dart
/// VibeIbanInput(onChanged: (iban, valid) => save(iban, valid))
/// ```
class VibeIbanInput extends StatefulWidget {
  const VibeIbanInput({super.key, this.value, this.initialValue = 'IR', this.onChanged, this.enabled = true});

  /// مقدار کنترل‌شده (شکل کامل با IR).
  final String? value;
  final String initialValue;
  final void Function(String iban, bool valid)? onChanged;
  final bool enabled;

  @override
  State<VibeIbanInput> createState() => _VibeIbanInputState();
}

class _VibeIbanInputState extends State<VibeIbanInput> {
  String _internal = 'IR';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _sync();
  }

  @override
  void didUpdateWidget(VibeIbanInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null) _sync();
  }

  void _sync() {
    final text = _groupDigits(_iban.length > 2 ? _iban.substring(2) : "");
    if (text != _controller.text) {
      _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  String get _iban => normalizeIban(widget.value ?? _internal);

  void _set(String next) {
    final n = normalizeIban("IR$next");
    setState(() => _internal = n);
    _sync();
    widget.onChanged?.call(n, isIban(n));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final iban = _iban;
    final digits = iban.length > 2 ? iban.substring(2) : "";
    final valid = isIban(iban);
    final bank = ibanBank(iban);
    final complete = digits.length == 24;
    final invalid = complete && !valid;

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
                  Text("IR", style: TextStyle(fontSize: 14, color: t.mutedForeground)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩ ]"))],
                      onChanged: _set,
                      cursorColor: t.foreground,
                      style: TextStyle(fontSize: 14, color: t.foreground),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: "00 0000 0000 0000 0000 0000 00",
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
            if (bank != null) ...[
              Icon(Icons.account_balance_outlined, size: 12, color: t.mutedForeground),
              const SizedBox(width: 4),
            ],
            Text(
              bank != null
                  ? bankLabel(bank)
                  : invalid
                      ? "شماره‌ی شبا معتبر نیست"
                      : "۲۴ رقم بعد از IR",
              style: TextStyle(
                fontSize: 11,
                color: invalid && bank == null ? t.destructive : t.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _groupDigits(String digits) {
  final groups = <String>[];
  for (var i = 0; i < digits.length; i += 4) {
    groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
  }
  return groups.join(" ");
}
