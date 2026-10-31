import 'package:flutter/material.dart';

import '../theme.dart';

/// یک گزینه‌ی سلکت.
class VibeSelectOption {
  final String value;
  final String label;
  final bool disabled;

  const VibeSelectOption({required this.value, required this.label, this.disabled = false});
}

/// انتخاب — پورت `registry/ui/select.tsx`.
///
/// پیکر موبایل‌پسند (شیت پایین صفحه) با همان استایل وب: حاشیه، فیلد پرشده و
/// چورون در لبه‌ی پایان (چپ در RTL). با [hint] همان placeholder وب.
///
/// ```dart
/// VibeSelect(
///   options: [VibeSelectOption(value: "teh", label: "تهران")],
///   value: _city,
///   onChanged: (v) => setState(() => _city = v),
///   hint: "شهر را انتخاب کنید",
/// )
/// ```
class VibeSelect extends StatelessWidget {
  final List<VibeSelectOption> options;

  /// مقدار کنترل‌شده.
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? hint;

  /// عنوان شیتی که باز می‌شود؛ پیش‌فرض همان [hint].
  final String? sheetTitle;
  final bool enabled;

  const VibeSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.hint,
    this.sheetTitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final selected = value == null ? null : options.where((o) => o.value == value).firstOrNull;

    Future<void> open() async {
      final picked = await showModalBottomSheet<String?>(
        context: context,
        backgroundColor: t.popover,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeRadius.overlay)),
          side: BorderSide(color: t.border),
        ),
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((sheetTitle ?? hint) != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sheetTitle ?? hint!,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final o in options)
                      ListTile(
                        enabled: !o.disabled,
                        title: Text(o.label, style: const TextStyle(fontSize: 14)),
                        trailing: o.value == value
                            ? Icon(Icons.check, size: 16, color: t.foreground)
                            : null,
                        onTap: o.disabled
                            ? null
                            : () => Navigator.of(sheetContext).pop(o.value),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      if (picked != null) onChanged?.call(picked);
    }

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: enabled ? open : null,
        child: Container(
          height: 40,
          padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
          decoration: BoxDecoration(
            color: t.background.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(VibeRadius.field),
            border: Border.all(color: t.input),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.label ?? hint ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: selected != null ? t.foreground : t.mutedForeground.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.expand_more, size: 16, color: t.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
