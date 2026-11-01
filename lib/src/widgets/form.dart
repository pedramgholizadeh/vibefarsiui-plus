import 'package:flutter/material.dart';

import '../iran.dart';
import '../theme.dart';

/// یک قاعده‌ی اعتبارسنجی: پیام خطا یا null.
typedef VibeValidator = String? Function(Object? value, Map<String, Object?> all);

/// قواعد آماده با پیام فارسی — پورت `rules` وب.
abstract final class VibeRules {
  static VibeValidator required([String msg = "این فیلد الزامی است"]) =>
      (v, all) => v == null || (v is String && v.isEmpty) || (v is List && v.isEmpty) ? msg : null;

  static VibeValidator minLength(int n, [String? msg]) =>
      (v, all) => v is String && v.length < n ? msg ?? "حداقل ${n.toString().replaceAllMapped(RegExp(r"\d"), (d) => "۰۱۲۳۴۵۶۷۸۹"[int.parse(d.group(0)!)])} کاراکتر" : null;

  static VibeValidator pattern(RegExp re, [String msg = "فرمت واردشده درست نیست"]) =>
      (v, all) => v is String && v.isNotEmpty && !re.hasMatch(v) ? msg : null;

  static VibeValidator mobile([String msg = "شماره‌ی موبایل معتبر نیست"]) =>
      (v, all) => v is String && v.isNotEmpty && !isIranMobile(v) ? msg : null;

  static VibeValidator iban([String msg = "شماره‌ی شبا معتبر نیست"]) =>
      (v, all) => v is String && v.isNotEmpty && !isIban(v) ? msg : null;

  static VibeValidator nationalId([String msg = "کد ملی معتبر نیست"]) =>
      (v, all) => v is String && v.isNotEmpty && !isNationalId(v) ? msg : null;

  static VibeValidator email([String msg = "ایمیل معتبر نیست"]) =>
      (v, all) => v is String && v.isNotEmpty && !RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(v) ? msg : null;

  static VibeValidator equals(String other, [String msg = "مقدارها یکسان نیستند"]) =>
      (v, all) => v != all[other] ? msg : null;
}

/// کنترلر فرم — پورت `useForm` وب.
///
/// مقادیر، نقشه‌ی خطا، فلگ لمس‌شدن و اعتبارسنجی هنگام submit؛ بدون کتابخانه.
///
/// ```dart
/// final form = VibeFormController(
///   initial: {"name": "", "phone": ""},
///   schema: {
///     "name": [VibeRules.required()],
///     "phone": [VibeRules.required(), VibeRules.mobile()],
///   },
/// );
/// ```
class VibeFormController extends ChangeNotifier {
  VibeFormController({required this.initial, this.schema = const {}, this.onSubmit});

  final Map<String, Object?> initial;
  final Map<String, List<VibeValidator>> schema;
  final Future<void> Function(Map<String, Object?> values)? onSubmit;

  late Map<String, Object?> _values = {...initial};
  final Map<String, String> _errors = {};
  final Set<String> _touched = {};
  bool _submitting = false;

  Map<String, Object?> get values => _values;
  Map<String, String> get errors => Map.unmodifiable(_errors);
  bool get submitting => _submitting;

  Object? value(String name) => _values[name];

  /// پیام خطای نمایشی: فقط پس از لمس فیلد.
  String? errorOf(String name) => _touched.contains(name) ? _errors[name] : null;

  String? _validateField(String name, Map<String, Object?> all) {
    for (final rule in schema[name] ?? const <VibeValidator>[]) {
      final msg = rule(all[name], all);
      if (msg != null) return msg;
    }
    return null;
  }

  Map<String, String> _validateAll() {
    final next = <String, String>{};
    for (final name in schema.keys) {
      final msg = _validateField(name, _values);
      if (msg != null) next[name] = msg;
    }
    return next;
  }

  bool get isValid => _validateAll().isEmpty;

  void setValue(String name, Object? value) {
    _values = {..._values, name: value};
    if (_touched.contains(name)) {
      final msg = _validateField(name, _values);
      if (msg != null) {
        _errors[name] = msg;
      } else {
        _errors.remove(name);
      }
    }
    notifyListeners();
  }

  void touch(String name) {
    _touched.add(name);
    final msg = _validateField(name, _values);
    if (msg != null) {
      _errors[name] = msg;
    } else {
      _errors.remove(name);
    }
    notifyListeners();
  }

  void setError(String name, String? message) {
    if (message == null) {
      _errors.remove(name);
    } else {
      _errors[name] = message;
    }
    notifyListeners();
  }

  /// اعتبارسنجی همه‌ی فیلدها و اجرای [onSubmit] در صورت اعتبار.
  Future<void> handleSubmit() async {
    final all = _validateAll();
    _errors
      ..clear()
      ..addAll(all);
    _touched.addAll(_values.keys);
    notifyListeners();
    if (all.isNotEmpty || onSubmit == null) return;
    _submitting = true;
    notifyListeners();
    try {
      await onSubmit!(_values);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void reset() {
    _values = {...initial};
    _errors.clear();
    _touched.clear();
    notifyListeners();
  }
}

/// فیلد فرم — پورت `FormField` وب: برچسب، کنترل و راهنما/خطا.
class VibeFormField extends StatelessWidget {
  final Widget label;
  final Widget child;
  final String? error;
  final Widget? hint;
  final bool requiredMark;

  const VibeFormField({
    super.key,
    required this.label,
    required this.child,
    this.error,
    this.hint,
    this.requiredMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.foreground.withValues(alpha: 0.9)),
              child: label,
            ),
            if (requiredMark) ...[
              const SizedBox(width: 4),
              Text("*", style: TextStyle(fontSize: 14, color: t.destructive)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
        if (error != null || hint != null) ...[
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: error != null ? t.destructive : t.mutedForeground),
            child: error != null ? Text(error!) : hint!,
          ),
        ],
      ],
    );
  }
}

/// خلاصه‌ی خطاها بالای دکمه‌ی ثبت — پورت `FormErrors` وب.
class VibeFormErrors extends StatelessWidget {
  final Map<String, String> errors;
  final Map<String, String> labels;

  const VibeFormErrors({super.key, required this.errors, this.labels = const {}});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final entries = errors.entries.where((e) => e.value.isNotEmpty).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: t.destructive.withValues(alpha: 0.3)),
        color: t.destructive.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: labels[e.key] ?? e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                    TextSpan(text: ": ${e.value}"),
                  ],
                ),
                style: TextStyle(fontSize: 12, color: t.destructive),
              ),
            ),
        ],
      ),
    );
  }
}
