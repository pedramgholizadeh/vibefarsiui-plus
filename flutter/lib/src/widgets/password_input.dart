import 'package:flutter/material.dart';

import '../theme.dart';

/// سطوح قدرت رمز، مثل وب: خیلی ضعیف تا عالی.
const List<String> vibePasswordLevels = ["خیلی ضعیف", "ضعیف", "متوسط", "قوی", "عالی"];

/// امتیاز قدرت رمز ۰ تا ۴ — پورت `passwordStrength` وب.
int passwordStrength(String v) {
  var s = 0;
  if (v.length >= 8) s++;
  if (v.length >= 12) s++;
  if (RegExp(r"[a-z]").hasMatch(v) && RegExp(r"[A-Z]").hasMatch(v)) s++;
  if (RegExp(r"\d").hasMatch(v) && RegExp(r"[^A-Za-z0-9]").hasMatch(v)) s++;
  return v.isEmpty ? 0 : (s < 1 ? 1 : s);
}

/// رمز عبور — پورت `registry/ui/password-input.tsx`.
///
/// خود فیلد همیشه چپ‌چین است، دکمه‌ی نمایش/پنهان در لبه‌ی پایان قرار دارد و
/// با [showStrength] متر قدرت رمز با برچسب فارسی زیر فیلد می‌آید.
///
/// ```dart
/// VibePasswordInput(onChanged: save, showStrength: true)
/// ```
class VibePasswordInput extends StatefulWidget {
  const VibePasswordInput({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.hintText,
    this.showStrength = false,
    this.enabled = true,
  });

  final String? value;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  /// نمایش متر قدرت رمز زیر فیلد.
  final bool showStrength;
  final bool enabled;

  @override
  State<VibePasswordInput> createState() => _VibePasswordInputState();
}

class _VibePasswordInputState extends State<VibePasswordInput> {
  late final TextEditingController _controller;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? widget.initialValue);
  }

  @override
  void didUpdateWidget(VibePasswordInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.value;
    if (external != null && external != _controller.text) {
      _controller.value = TextEditingValue(text: external, selection: TextSelection.collapsed(offset: external.length));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final level = passwordStrength(widget.value ?? _controller.text);

    final field = Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        obscureText: !_show,
        autocorrect: false,
        enableSuggestions: false,
        onChanged: widget.onChanged,
        cursorColor: t.foreground,
        style: TextStyle(fontSize: 14, height: 1.2, color: t.foreground),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
          filled: true,
          fillColor: t.background.withValues(alpha: 0.6),
          isDense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4, top: 11, bottom: 11),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _show = !_show),
            icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
            color: t.mutedForeground,
            tooltip: _show ? "پنهان کردن رمز" : "نمایش رمز",
            visualDensity: VisualDensity.compact,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(VibeRadius.field),
            borderSide: BorderSide(color: t.input),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(VibeRadius.field),
            borderSide: BorderSide(width: 2, color: t.ring.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(opacity: widget.enabled ? 1 : 0.5, child: field),
        if (widget.showStrength) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 4; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsetsDirectional.only(end: i < 4 ? 4 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: i <= level
                          ? (level <= 1
                              ? t.destructive
                              : level == 2
                                  ? t.warning
                                  : t.success)
                          : t.input,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            level > 0 ? "قدرت رمز: ${vibePasswordLevels[level]}" : "حداقل ۸ کاراکتر، با حرف بزرگ، عدد و نماد",
            style: TextStyle(fontSize: 11, color: t.mutedForeground),
          ),
        ],
      ],
    );
  }
}
