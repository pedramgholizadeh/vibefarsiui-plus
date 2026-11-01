import 'package:flutter/material.dart';

import '../theme.dart';

/// ستون جدول وایب‌فارسی: سرستون و پرچم عددی (ارقام چپ‌چین).
class VibeTableColumn {
  final Widget header;

  /// برای مبالغ و اعداد: سلول‌ها چپ‌چین می‌شوند.
  final bool numeric;
  final double? width;

  const VibeTableColumn({required this.header, this.numeric = false, this.width});
}

/// یک سطر جدول؛ [onTap] برای سطرهای قابل انتخاب.
class VibeTableRowData {
  final List<Widget> cells;
  final VoidCallback? onTap;

  /// سطر انتخاب‌شده (پس‌زمینه‌ی accent می‌گیرد).
  final bool selected;

  const VibeTableRowData({required this.cells, this.onTap, this.selected = false});
}

/// جدول — پورت `registry/ui/table.tsx`.
///
/// قالب استایل‌شده‌ی جدول وب: کانتینر با گوشه گرد و حاشیه، سرستون کم‌رنگ،
/// خط بین سطرها و hover روی سطرها. ستون اول سمت راست است؛ ستون‌های عددی چپ‌چین.
///
/// ```dart
/// VibeTable(
///   columns: [VibeTableColumn(header: Text("محصول")), VibeTableColumn(header: Text("قیمت"), numeric: true)],
///   rows: [VibeTableRowData(cells: [Text("کیف چرم"), Text(formatToman(2400000))])],
/// )
/// ```
class VibeTable extends StatelessWidget {
  final List<VibeTableColumn> columns;
  final List<VibeTableRowData> rows;

  /// زیرنویس زیر جدول، مثل وب.
  final Widget? caption;

  const VibeTable({super.key, required this.columns, required this.rows, this.caption});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.border),
          ),
          clipBehavior: Clip.antiAlias,
          // ستون‌های بدون عرض، Expanded می‌خواهند؛ پس فقط وقتی عرض‌های ثابت
          // از فضای موجود می‌گذرد اسکرول افقی روشن می‌شود و بقیه‌ی ستون‌ها
          // عرض پیش‌فرض می‌گیرند (Expanded داخل عرض بی‌کران غیرمجاز است).
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minWidthPerFlex = 120.0;
              final fixedTotal = columns.fold(0.0, (a, c) => a + (c.width ?? 0));
              final flexCount = columns.where((c) => c.width == null).length;
              final overflows = fixedTotal + flexCount * minWidthPerFlex > constraints.maxWidth;
              Widget grid = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(columns: columns, flexFallback: overflows ? minWidthPerFlex : null),
                  for (var i = 0; i < rows.length; i++)
                    _BodyRow(
                      columns: columns,
                      row: rows[i],
                      last: i == rows.length - 1,
                      flexFallback: overflows ? minWidthPerFlex : null,
                    ),
                ],
              );
              if (overflows) {
                grid = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: grid,
                );
              }
              return grid;
            },
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: 12, color: t.mutedForeground),
              child: caption!,
            ),
          ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<VibeTableColumn> columns;

  /// وقتی جدول سرریز می‌شود، ستون‌های بدون عرض این عرض را می‌گیرند.
  final double? flexFallback;

  const _HeaderRow({required this.columns, this.flexFallback});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      color: t.muted.withValues(alpha: 0.6),
      padding: const EdgeInsetsDirectional.only(bottom: 1),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            _cell(
              context,
              width: columns[i].width ?? flexFallback,
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: 12, color: t.mutedForeground, fontWeight: FontWeight.w500),
                child: columns[i].header,
              ),
            ),
        ],
      ),
    );
  }
}

class _BodyRow extends StatefulWidget {
  final List<VibeTableColumn> columns;
  final VibeTableRowData row;
  final bool last;

  /// همان منطق سرریزِ [_HeaderRow].
  final double? flexFallback;

  const _BodyRow({required this.columns, required this.row, required this.last, this.flexFallback});

  @override
  State<_BodyRow> createState() => _BodyRowState();
}

class _BodyRowState extends State<_BodyRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final bg = widget.row.selected
        ? t.accent
        : _hover && widget.row.onTap != null
            ? t.accent.withValues(alpha: 0.4)
            : Colors.transparent;
    return MouseRegion(
      onEnter: widget.row.onTap != null ? (_) => setState(() => _hover = true) : null,
      onExit: widget.row.onTap != null ? (_) => setState(() => _hover = false) : null,
      cursor: widget.row.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.row.onTap,
        child: AnimatedContainer(
          duration: VibeMotion.duration,
          curve: VibeMotion.ease,
          color: bg,
          padding: EdgeInsetsDirectional.only(bottom: widget.last ? 0 : 1),
          child: Row(
            children: [
              for (var i = 0; i < widget.columns.length; i++)
                _cell(
                  context,
                  width: widget.columns[i].width ?? widget.flexFallback,
                  numeric: widget.columns[i].numeric,
                  child: widget.row.cells[i],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _cell(BuildContext context, {double? width, bool numeric = false, required Widget child}) {
  final body = Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    alignment: numeric ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
    // ارقام همیشه داخل خودشان LTR خوانده می‌شوند، حتی وسط متن راست‌چین.
    child: numeric ? Directionality(textDirection: TextDirection.ltr, child: child) : child,
  );
  // عرض null فقط وقتی مجاز است که ردیف در عرض محدود باشد (بدون سرریز).
  return width != null ? SizedBox(width: width, child: body) : Expanded(child: body);
}
