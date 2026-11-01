import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// یک گزینه‌ی چندانتخابی.
class VibeMultiOption {
  final String value;
  final String label;
  final bool disabled;

  const VibeMultiOption({required this.value, required this.label, this.disabled = false});
}

/// چندانتخابی — پورت `registry/ui/multi-select.tsx`.
///
/// فهرست با تیک؛ انتخاب‌شده‌ها به شکل چیپ داخل فیلد می‌آیند و با [maxVisible]
/// فرومی‌ریزند به «+۳ مورد دیگر». فیلتر بالای فهرست با [searchable].
///
/// ```dart
/// VibeMultiSelect(
///   options: [VibeMultiOption(value: "b", label: "بسته‌بندی")],
///   value: _picked,
///   onChanged: (v) => setState(() => _picked = v),
/// )
/// ```
class VibeMultiSelect extends StatefulWidget {
  const VibeMultiSelect({
    super.key,
    required this.options,
    this.value,
    this.initialValue = const [],
    this.onChanged,
    this.placeholder = "انتخاب کنید…",
    this.searchable = true,
    this.maxVisible = 3,
    this.max,
    this.emptyText = "چیزی پیدا نشد",
    this.disabled = false,
  });

  final List<VibeMultiOption> options;

  /// مقادیر کنترل‌شده.
  final List<String>? value;
  final List<String> initialValue;
  final ValueChanged<List<String>>? onChanged;
  final String placeholder;

  /// فیلتر بالای فهرست.
  final bool searchable;

  /// تعداد چیپ نمایشی پیش از فروپاشی به «+n مورد دیگر».
  final int maxVisible;

  /// سقف انتخاب‌ها؛ پس از رسیدن، بقیه‌ی فهرست غیرفعال می‌شود.
  final int? max;
  final String emptyText;
  final bool disabled;

  @override
  State<VibeMultiSelect> createState() => _VibeMultiSelectState();
}

class _VibeMultiSelectState extends State<VibeMultiSelect> {
  late List<String> _internal;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _internal = [...widget.initialValue];
  }

  List<String> get _selected => widget.value ?? _internal;

  void _commit(List<String> next) {
    setState(() => _internal = next);
    widget.onChanged?.call(next);
  }

  void _toggle(String v) {
    if (_selected.contains(v)) {
      _commit(_selected.where((x) => x != v).toList());
    } else if (widget.max == null || _selected.length < widget.max!) {
      _commit([..._selected, v]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final chips = [
      for (final v in _selected)
        if (widget.options.where((o) => o.value == v).firstOrNull case final VibeMultiOption c)
          c,
    ];
    final hidden = (chips.length - widget.maxVisible).clamp(0, 1 << 31);
    final visible = chips.take(widget.maxVisible).toList();

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: widget.disabled ? null : () => _openSheet(context),
        child: Opacity(
          opacity: widget.disabled ? 0.5 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: t.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.input),
            ),
            child: Row(
              children: [
                Expanded(
                  child: chips.isEmpty
                      ? Text(
                          widget.placeholder,
                          style: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final c in visible)
                              Container(
                                height: 24,
                                padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: t.secondary,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(c.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: t.secondaryForeground)),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _toggle(c.value),
                                      child: Icon(Icons.close, size: 12, color: t.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                            if (hidden > 0)
                              Text(
                                "+${fa(hidden)} مورد دیگر",
                                style: TextStyle(fontSize: 12, color: t.mutedForeground),
                              ),
                          ],
                        ),
                ),
                Icon(Icons.expand_more, size: 16, color: t.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final t = context.vibe;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.popover,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(VibeRadius.overlay)),
        side: BorderSide(color: t.border),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final q = _query.trim();
            final filtered = q.isEmpty ? widget.options : widget.options.where((o) => o.label.contains(q)).toList();
            final full = widget.max != null && _selected.length >= widget.max!;
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.searchable)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          autofocus: true,
                          onChanged: (v) => setSheetState(() => _query = v),
                          cursorColor: t.foreground,
                          style: TextStyle(fontSize: 14, color: t.foreground),
                          decoration: InputDecoration(
                            hintText: "جست‌وجو…",
                            prefixIcon: Icon(Icons.search, size: 16, color: t.mutedForeground),
                            filled: true,
                            fillColor: t.background.withValues(alpha: 0.6),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(VibeRadius.field),
                              borderSide: BorderSide(color: t.input),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(VibeRadius.field),
                              borderSide: BorderSide(color: t.ring.withValues(alpha: 0.6)),
                            ),
                          ),
                        ),
                      ),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        children: [
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(widget.emptyText, style: TextStyle(fontSize: 14, color: t.mutedForeground)),
                            ),
                          for (final o in filtered)
                            ListTile(
                              enabled: !o.disabled && (!full || _selected.contains(o.value)),
                              title: Text(o.label, style: const TextStyle(fontSize: 14)),
                              trailing: _selected.contains(o.value)
                                  ? Icon(Icons.check, size: 16, color: t.foreground)
                                  : null,
                              onTap: () {
                                setSheetState(() => _toggle(o.value));
                              },
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "${fa(_selected.length)} انتخاب شد",
                        style: TextStyle(fontSize: 12, color: t.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    setState(() => _query = "");
  }
}
