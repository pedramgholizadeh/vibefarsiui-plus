import 'package:flutter/material.dart';

import '../theme.dart';

/// نرمال‌سازی برای تطبیق: ي/ى→ی، ك→ک، آأإ→ا و حذف فاصله و نیم‌فاصله.
/// «علي اباد» با «علی‌آباد» یکی می‌شود، مثل وب.
String vibeFold(String s) {
  return s
      .replaceAll("ي", "ی")
      .replaceAll("ى", "ی")
      .replaceAll("ك", "ک")
      .replaceAllMapped(RegExp(r"[آأإ]"), (_) => "ا")
      .replaceAll(RegExp(r"[\s‌]+"), "");
}

/// کمبوباکس — پورت `registry/ui/combobox.tsx`.
///
/// ورودی با پیشنهاد زنده؛ جست‌وجو اول با پیشوند و بعد با زیررشته. برای
/// موبایل با تایپ، فهرست پیشنهاد زیر فیلد باز می‌شود (Overlay).
///
/// ```dart
/// VibeCombobox(options: cities, value: _city, onChanged: (v) => setState(() => _city = v))
/// ```
class VibeCombobox extends StatefulWidget {
  final List<String> options;

  /// مقدار کنترل‌شده.
  final String? value;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final String emptyText;

  /// فقط مقادیر فهرست: هنگام خروج از فوکوس، متن آزاد به گزینه‌ی منطبق می‌چسبد یا برمی‌گردد.
  final bool strict;
  final bool enabled;

  const VibeCombobox({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = "جست‌وجو…",
    this.emptyText = "چیزی پیدا نشد",
    this.strict = false,
    this.enabled = true,
  });

  @override
  State<VibeCombobox> createState() => _VibeComboboxState();
}

class _VibeComboboxState extends State<VibeCombobox> {
  late final TextEditingController _controller;
  final _focus = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  int _index = 0;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? "");
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(VibeCombobox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final external = widget.value;
    if (external != null && external != _controller.text) {
      _controller.value = TextEditingValue(text: external, selection: TextSelection.collapsed(offset: external.length));
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _controller.text.trim();
    final f = vibeFold(q);
    if (f.isEmpty || q == (widget.value ?? "")) return widget.options;
    final starts = widget.options.where((o) => vibeFold(o).startsWith(f)).toList();
    final contains = widget.options.where((o) => !vibeFold(o).startsWith(f) && vibeFold(o).contains(f)).toList();
    return [...starts, ...contains];
  }

  void _onFocusChanged() {
    if (_focus.hasFocus) {
      _open = true;
      _showOverlay();
    } else {
      // کمی تأخیر تا onTap فهرست فرصت pick داشته باشد.
      Future.delayed(const Duration(milliseconds: 120), () {
        _removeOverlay();
        _open = false;
        _commitStrict();
      });
    }
  }

  void _commitStrict() {
    if (!widget.strict || _controller.text == (widget.value ?? "")) return;
    final f = vibeFold(_controller.text.trim());
    if (f.isEmpty) {
      if ((widget.value ?? "").isNotEmpty) _pick("");
      return;
    }
    final exact = widget.options.where((o) => vibeFold(o) == f).firstOrNull;
    _pick(exact ?? (widget.value ?? ""));
  }

  void _pick(String v) {
    _controller.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
    widget.onChanged?.call(v);
    _removeOverlay();
    _open = false;
    _focus.unfocus();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        width: _fieldWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          showWhenUnlinked: false,
          child: _suggestions(context),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  double get _fieldWidth => (_context?.size?.width ?? 260);

  BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    final t = context.vibe;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
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
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  onChanged: (v) {
                    _index = 0;
                    if (!_open) {
                      _open = true;
                      _showOverlay();
                    } else {
                      // رفرش محتوای overlay.
                      _showOverlay();
                    }
                  },
                  onSubmitted: (v) {
                    final filtered = _filtered;
                    if (_open && _index < filtered.length) _pick(filtered[_index]);
                  },
                  cursorColor: t.foreground,
                  style: TextStyle(fontSize: 14, height: 1.6, color: t.foreground),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(fontSize: 14, color: t.mutedForeground.withValues(alpha: 0.7)),
                  ),
                ),
              ),
              Icon(Icons.expand_more, size: 16, color: t.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestions(BuildContext context) {
    final t = context.vibe;
    final filtered = _filtered;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 224),
        decoration: BoxDecoration(
          color: t.popover,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: t.border),
        ),
        child: ListView(
          padding: const EdgeInsets.all(4),
          shrinkWrap: true,
          children: [
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(widget.emptyText, style: TextStyle(fontSize: 14, color: t.mutedForeground)),
              ),
            for (var i = 0; i < filtered.length; i++)
              _option(context, filtered[i], i),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, String o, int i) {
    final t = context.vibe;
    final q = _controller.text.trim();
    final isMatchPrefix = q.isNotEmpty && q != (widget.value ?? "") && o.startsWith(q);
    return InkWell(
      onTap: () => _pick(o),
      onHover: (hover) {
        if (hover && _index != i) {
          _index = i;
          _showOverlay();
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: i == _index ? t.accent : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: isMatchPrefix
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: q, style: const TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: o.substring(q.length)),
                        ],
                      ),
                      style: TextStyle(fontSize: 14, height: 1.6, color: t.foreground),
                    )
                  : Text(o, style: TextStyle(fontSize: 14, height: 1.6, color: t.foreground)),
            ),
            if (o == (widget.value ?? "")) Icon(Icons.check, size: 14, color: t.foreground),
          ],
        ),
      ),
    );
  }
}
