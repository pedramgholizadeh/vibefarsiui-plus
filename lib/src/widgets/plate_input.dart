import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../iran.dart';
import '../persian.dart';
import '../theme.dart';

/// پلاک خودرو — پورت `registry/ui/plate-input.tsx`.
///
/// خود پلاک چپ‌چین است مثل پلاک فلزی (۱۲ ب ۳۴۵ | ایران ۱۱)، نوار «I.R.
/// IRAN» در ابتدای سطر و خانه‌ی حرف با پیکر راست‌چین همه‌ی حرف‌های مجاز و
/// معنایشان. رقم فارسی/لاتین، ي/ك عربی و «ا» برای «الف» پذیرفته می‌شود.
///
/// ```dart
/// VibePlateInput(
///   value: _plate,
///   onChanged: (plate, complete) => save(plate, complete),
/// )
/// ```
class VibePlateInput extends StatefulWidget {
  const VibePlateInput({
    super.key,
    this.value,
    this.initialValue = PlateValue.empty,
    this.onChanged,
    this.letters,
    this.enabled = true,
  });

  /// مقدار کنترل‌شده.
  final PlateValue? value;
  final PlateValue initialValue;

  /// مقدار کامل پلاک و اعتبارش (هر چهار بخش پر).
  final void Function(PlateValue value, bool complete)? onChanged;

  /// محدودکردن پیکر، مثل ["ت"] در فرم تاکسی یا فقط حرف‌های شخصی.
  final List<String>? letters;
  final bool enabled;

  @override
  State<VibePlateInput> createState() => _VibePlateInputState();
}

class _VibePlateInputState extends State<VibePlateInput> {
  late PlateValue _internal;
  late final List<({String letter, String label})> _options;
  late final List<TextEditingController> _digitControllers; // left, middle, region
  final _letterFocus = FocusNode();
  final _leftFocus = FocusNode();
  final _middleFocus = FocusNode();
  final _regionFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _internal = widget.initialValue;
    _options = widget.letters == null
        ? plateLetters
        : plateLetters.where((l) => widget.letters!.contains(l.letter)).toList();
    _digitControllers = List.generate(3, (_) => TextEditingController());
    _syncDigits();
  }

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    _letterFocus.dispose();
    _leftFocus.dispose();
    _middleFocus.dispose();
    _regionFocus.dispose();
    super.dispose();
  }

  PlateValue get _v => widget.value ?? _internal;

  void _commit(PlateValue next) {
    setState(() => _internal = next);
    _syncDigits();
    widget.onChanged?.call(next, isPlate(next));
  }

  void _syncDigits() {
    final texts = [fa(_v.left), fa(_v.middle), fa(_v.region)];
    for (var i = 0; i < 3; i++) {
      if (_digitControllers[i].text != texts[i]) {
        _digitControllers[i].value = TextEditingValue(text: texts[i], selection: TextSelection.collapsed(offset: texts[i].length));
      }
    }
  }

  void _setSegment(int index, String digits, {required void Function(PlateValue) apply}) {
    final d = en(digits).replaceAll(RegExp(r"\D"), "");
    final v = _v;
    final box = switch (index) {
      0 => v.left,
      1 => v.middle,
      _ => v.region,
    };
    final max = switch (index) {
      0 => 2,
      1 => 3,
      _ => 2,
    };
    // تایپ در خانه‌ی پُر، آن را از نو با رقم جدید شروع می‌کند (مثل وب).
    final capped = d.length <= max || box.length < max
        ? (d.length > max ? d.substring(0, max) : d)
        : d.substring(0, max);
    apply(switch (index) {
      0 => PlateValue(left: capped, letter: v.letter, middle: v.middle, region: v.region),
      1 => PlateValue(left: v.left, letter: v.letter, middle: capped, region: v.region),
      _ => PlateValue(left: v.left, letter: v.letter, middle: v.middle, region: capped),
    });
    if (capped.length == max && index < 2) {
      (index == 0 ? _letterFocus : _regionFocus).requestFocus();
    }
  }

  void _chooseLetter(String letter) {
    final v = _v;
    _commit(PlateValue(left: v.left, letter: letter, middle: v.middle, region: v.region));
    _middleFocus.requestFocus();
  }

  Future<void> _openPicker() async {
    final t = context.vibe;
    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: t.popover,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VibeRadius.overlay),
          side: BorderSide(color: t.border),
        ),
        child: _PlateLetterPicker(
          options: _options,
          selected: _v.letter,
          onPick: (l) => Navigator.of(dialogContext).pop(l),
        ),
      ),
    );
    if (picked != null) _chooseLetter(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final v = _v;

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: Semantics(
        label: "پلاک خودرو",
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: t.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.input),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // نوار آبی «I.R. IRAN» — در پلاک واقعی چپ است.
                Container(
                  width: 28,
                  color: t.foreground,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("I.R.", style: TextStyle(fontSize: 7, height: 1.1, fontWeight: FontWeight.w700, color: t.background)),
                        Text("IRAN", style: TextStyle(fontSize: 7, height: 1.1, fontWeight: FontWeight.w700, color: t.background)),
                      ],
                    ),
                  ),
                ),
                _digitBox(
                  controller: _digitControllers[0],
                  focusNode: _leftFocus,
                  hint: "۱۲",
                  width: 40,
                  fontSize: 18,
                  enabled: widget.enabled,
                  onChanged: (s) => _setSegment(0, s, apply: (p) => p),
                  onBackspaceEmpty: () {},
                ),
                // خانه‌ی حرف: دکمه با پیکر.
                GestureDetector(
                  onTap: widget.enabled ? _openPicker : null,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.transparent,
                    child: Center(
                      child: Text(
                        v.letter.isEmpty ? "ب" : v.letter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: v.letter.isEmpty ? t.mutedForeground.withValues(alpha: 0.4) : t.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
                _digitBox(
                  controller: _digitControllers[1],
                  focusNode: _middleFocus,
                  hint: "۳۴۵",
                  width: 56,
                  fontSize: 18,
                  enabled: widget.enabled,
                  onChanged: (s) => _setSegment(1, s, apply: (p) => p),
                  onBackspaceEmpty: _leftFocus.requestFocus,
                ),
                // بخش «ایران» + کد شهر.
                Container(
                  width: 44,
                  decoration: BoxDecoration(border: BorderDirectional(start: BorderSide(color: t.input))),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text("ایران", style: TextStyle(fontSize: 9, height: 1, color: t.mutedForeground)),
                      ),
                      Expanded(
                        child: _digitBox(
                          controller: _digitControllers[2],
                          focusNode: _regionFocus,
                          hint: "۱۱",
                          width: double.infinity,
                          enabled: widget.enabled,
                          fontSize: 16,
                          onChanged: (s) => _setSegment(2, s, apply: (p) => p),
                          onBackspaceEmpty: _middleFocus.requestFocus,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _digitBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required double width,
    required bool enabled,
    required double fontSize,
    required ValueChanged<String> onChanged,
    required VoidCallback onBackspaceEmpty,
  }) {
    final t = context.vibe;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.backspace): onBackspaceEmpty,
      },
      child: SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9۰-۹٠-٩]"))],
          onChanged: onChanged,
          cursorColor: t.foreground,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: t.foreground),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: t.mutedForeground.withValues(alpha: 0.4)),
          ),
        ),
      ),
    );
  }
}

/// پیکر حرف پلاک — شبکه‌ی راست‌چین با معنی حرف در پایین.
class _PlateLetterPicker extends StatefulWidget {
  final List<({String letter, String label})> options;
  final String selected;
  final ValueChanged<String> onPick;

  const _PlateLetterPicker({required this.options, required this.selected, required this.onPick});

  @override
  State<_PlateLetterPicker> createState() => _PlateLetterPickerState();
}

class _PlateLetterPickerState extends State<_PlateLetterPicker> {
  late String _described = widget.options.where((l) => l.letter == widget.selected).firstOrNull?.letter ?? "";

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final described = _described.isEmpty ? widget.selected : _described;
    final describedLabel = widget.options.where((l) => l.letter == described).firstOrNull?.label;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final l in widget.options)
                GestureDetector(
                  onTap: () { widget.onPick(l.letter); },
                  onTapDown: (_) => setState(() { _described = l.letter; }),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: l.letter == widget.selected ? t.primary : Colors.transparent,
                    ),
                    child: Text(
                      l.letter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: l.letter == widget.selected
                            ? t.primaryForeground
                            : (l.label != "شخصی" ? t.mutedForeground : t.foreground),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              describedLabel != null ? "$described · $describedLabel" : "حرف پلاک را انتخاب کنید",
              style: TextStyle(fontSize: 11, color: t.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}
