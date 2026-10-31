import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';
import 'empty_state.dart';
import 'skeleton.dart';
import 'table.dart';

/// ستون جدول داده. [key] برای مرتب‌سازی و جست‌وجو، [numeric] برای ارقام و مرتب‌سازی عددی.
class VibeDataColumn<T> {
  final String key;
  final Widget header;
  final bool sortable;
  final bool numeric;
  final Widget Function(T row)? cell;
  final double? width;

  const VibeDataColumn({
    required this.key,
    required this.header,
    this.sortable = false,
    this.numeric = false,
    this.cell,
    this.width,
  });
}

/// جدول داده — پورت `registry/ui/data-table.tsx`.
///
/// مرتب‌سازی سمت کلاینت، فیلتر متنی (رقم فارسی و لاتین هم‌ارزش‌اند)، ستون‌های
/// عددی مناسب تومان، اسکلت بارگذاری، حالت خالی و صفحه‌بندی با ارقام فارسی.
///
/// ```dart
/// VibeDataTable(
///   rows: orders,
///   columns: [
///     VibeDataColumn(key: "title", header: Text("سفارش"), sortable: true, cell: (o) => Text(o.title)),
///     VibeDataColumn(key: "amount", header: Text("مبلغ"), numeric: true, cell: (o) => Text(formatToman(o.amount))),
///   ],
///   rowKey: (o) => o.id,
///   searchKeys: ["title"],
/// )
/// ```
class VibeDataTable<T> extends StatefulWidget {
  final List<T> rows;
  final List<VibeDataColumn<T>> columns;
  final String Function(T row) rowKey;
  final bool loading;
  final int pageSize;

  /// کلیدهایی که فیلتر جست‌وجو می‌پیماند؛ خالی = بدون جعبه‌ی جست‌وجو.
  final List<String>? searchKeys;
  final String searchPlaceholder;
  final String emptyTitle;
  final String emptyDescription;

  /// ویجت کنار نوار جست‌وجو.
  final Widget? toolbar;
  final void Function(T row)? onRowClick;

  const VibeDataTable({
    super.key,
    required this.rows,
    required this.columns,
    required this.rowKey,
    this.loading = false,
    this.pageSize = 8,
    this.searchKeys,
    this.searchPlaceholder = "جست‌وجو…",
    this.emptyTitle = "چیزی پیدا نشد",
    this.emptyDescription = "فیلتر را عوض کنید یا مورد جدیدی اضافه کنید.",
    this.toolbar,
    this.onRowClick,
  });

  @override
  State<VibeDataTable<T>> createState() => _VibeDataTableState<T>();
}

class _VibeDataTableState<T> extends State<VibeDataTable<T>> {
  String _q = "";
  String? _sortKey;
  bool _desc = false;
  int _page = 1;

  Object? _value(T row, String key) => switch (row) {
        Map() => (row as Map)[key],
        _ => null,
      };

  List<T> get _filtered {
    final needle = en(_q.trim()).toLowerCase();
    if (needle.isEmpty || widget.searchKeys == null) return widget.rows;
    return widget.rows.where((r) {
      return widget.searchKeys!.any((k) => en("${_value(r, k) ?? ""}").toLowerCase().contains(needle));
    }).toList();
  }

  List<T> get _sorted {
    final list = [..._filtered];
    final key = _sortKey;
    if (key == null) return list;
    final col = widget.columns.where((c) => c.key == key).firstOrNull;
    final dir = _desc ? -1 : 1;
    list.sort((a, b) {
      final av = _value(a, key);
      final bv = _value(b, key);
      if (col?.numeric == true || (av is num && bv is num)) {
        return ((((av as num?) ?? 0) - ((bv as num?) ?? 0)) * dir).toInt();
      }
      if (av is DateTime && bv is DateTime) return av.compareTo(bv) * dir;
      return ("$av".compareTo("$bv") * dir);
    });
    return list;
  }

  void _toggleSort(String key) {
    setState(() {
      if (_sortKey != key) {
        _sortKey = key;
        _desc = false;
      } else if (!_desc) {
        _desc = true;
      } else {
        _sortKey = null;
        _desc = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final sorted = _sorted;
    final pages = sorted.isEmpty ? 1 : (sorted.length / widget.pageSize).ceil();
    final current = _page.clamp(1, pages);
    final view = sorted.sublist(
      (current - 1) * widget.pageSize,
      (current * widget.pageSize).clamp(0, sorted.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.searchKeys != null || widget.toolbar != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.searchKeys != null)
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (v) => setState(() {
                      _q = v;
                      _page = 1;
                    }),
                    decoration: InputDecoration(
                      hintText: widget.searchPlaceholder,
                      prefixIcon: const Icon(Icons.search, size: 16),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(VibeRadius.field),
                        borderSide: BorderSide(color: t.input),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(VibeRadius.field),
                        borderSide: BorderSide(color: t.ring),
                      ),
                    ),
                  ),
                ),
              if (widget.toolbar != null) widget.toolbar!,
              Text(
                "${fa(sorted.length)} مورد",
                style: TextStyle(fontSize: 12, color: t.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        VibeTable(
          columns: [
            for (final c in widget.columns)
              VibeTableColumn(
                header: _header(context, c),
                numeric: c.numeric,
                width: c.width,
              ),
          ],
          rows: widget.loading
              ? [
                  for (var i = 0; i < widget.pageSize.clamp(1, 5); i++)
                    VibeTableRowData(
                      cells: [
                        for (final _ in widget.columns) const VibeSkeleton(width: 96, height: 12),
                      ],
                    ),
                ]
              : view.isEmpty
                  ? [
                      VibeTableRowData(
                        cells: [
                          for (final _ in widget.columns) const SizedBox.shrink(),
                        ],
                      ),
                    ]
                  : [
                      for (final row in view)
                        VibeTableRowData(
                          onTap: widget.onRowClick != null ? () => widget.onRowClick!(row) : null,
                          cells: [
                            for (final c in widget.columns)
                              c.cell != null
                                  ? c.cell!(row)
                                  : Text("${_value(row, c.key) ?? ""}", style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                    ],
        ),
        if (view.isEmpty && !widget.loading) _empty(context),
        if (pages > 1 && !widget.loading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "صفحه‌ی ${fa(current)} از ${fa(pages)}",
                    style: TextStyle(fontSize: 12, color: t.mutedForeground),
                  ),
                ),
                _pageButton(context, icon: Icons.chevron_right, enabled: current > 1, onTap: () => setState(() => _page = current - 1)),
                _pageButton(context, icon: Icons.chevron_left, enabled: current < pages, onTap: () => setState(() => _page = current + 1)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _header(BuildContext context, VibeDataColumn<T> c) {
    final t = context.vibe;
    if (!c.sortable) return c.header;
    final sorted = _sortKey == c.key;
    return GestureDetector(
      onTap: () => _toggleSort(c.key),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          c.header,
          const SizedBox(width: 4),
          Icon(
            sorted ? (_desc ? Icons.arrow_downward : Icons.arrow_upward) : Icons.unfold_more,
            size: 12,
            color: sorted ? t.foreground : t.mutedForeground.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    // یک ردیف خالی رندر شده؛ حالت خودی روی آن می‌نشیند.
    return VibeEmptyState(title: widget.emptyTitle, description: widget.emptyDescription);
  }

  Widget _pageButton(BuildContext context, {required IconData icon, required bool enabled, required VoidCallback onTap}) {
    final t = context.vibe;
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 16),
      style: IconButton.styleFrom(
        foregroundColor: enabled ? t.foreground : t.mutedForeground.withValues(alpha: 0.4),
        minimumSize: const Size(28, 28),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
